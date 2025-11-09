




Nice — below is a ready-to-run **Google Colab** notebook-style sequence of Python cells that implement a Mesa-based agent-based predator–prey model with a simple resource (grass) dynamic. It includes:

* `Sheep` that move, eat grass (gain energy), reproduce.
* `Wolf` that move, hunt sheep (gain energy), reproduce, and die when out of energy.
* `GrassPatch` that regrows after being eaten.
* A `RandomActivation` scheduler and `MultiGrid`.
* A `DataCollector` capturing population sizes every step.
* A headless run you can execute in Colab and a matplotlib time-series plot of populations.
* Optional animation code (may work in Colab; if JS embedding is an issue you can save animations as GIFs).

Run the cells in order in a Colab notebook.

---

### Cell 1 — Install Mesa and supporting packages

```python
# Cell 1: install mesa (and imageio for optional gif saving)
!pip install mesa==1.2.1 imageio matplotlib
```

---

### Cell 2 — Imports and helper functions

```python
# Cell 2: imports
import random
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.space import MultiGrid
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector

# For optional animation
from matplotlib import animation
from IPython.display import HTML
import imageio
```

---

### Cell 3 — Agent classes (Sheep, Wolf, GrassPatch)

```python
# Cell 3: define agents

class GrassPatch(Agent):
    """
    A patch of grass that can be eaten by sheep and regrows after a fixed regrowth_time.
    """
    def __init__(self, unique_id, model, fully_grown=True, regrowth_time=10):
        super().__init__(unique_id, model)
        self.fully_grown = fully_grown
        self.countdown = 0
        self.regrowth_time = regrowth_time

    def step(self):
        if not self.fully_grown:
            self.countdown -= 1
            if self.countdown <= 0:
                self.fully_grown = True


class Sheep(Agent):
    """
    Sheep move randomly. If they are on a grass patch that is grown,
    they eat it (gain energy). They lose energy each step. They reproduce
    with probability `sheep_birth_rate` if energy above a threshold.
    """
    def __init__(self, unique_id, model, energy=6):
        super().__init__(unique_id, model)
        self.energy = energy

    def move(self):
        possible_steps = self.model.grid.get_neighborhood(self.pos, moore=True, include_center=False)
        new_pos = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_pos)

    def eat(self):
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        grasses = [obj for obj in cellmates if isinstance(obj, GrassPatch)]
        if grasses:
            grass = grasses[0]
            if grass.fully_grown:
                grass.fully_grown = False
                grass.countdown = grass.regrowth_time
                self.energy += self.model.sheep_gain_from_food

    def reproduce(self):
        if self.random.random() < self.model.sheep_birth_rate and self.energy >= self.model.sheep_reproduce_energy:
            # create new sheep in same cell
            child = Sheep(self.model.next_id(), self.model, energy=self.model.sheep_start_energy)
            self.model.grid.place_agent(child, self.pos)
            self.model.schedule.add(child)
            # reproduction energy cost (optional): split energy
            self.energy = self.energy // 2
            child.energy = self.energy

    def step(self):
        self.move()
        self.eat()
        self.energy -= self.model.sheep_energy_loss
        if self.energy <= 0:
            # die
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)
            return
        self.reproduce()


class Wolf(Agent):
    """
    Wolves move randomly. If they are with sheep they attempt to hunt one.
    Hunting gives energy; wolves lose energy each step. They reproduce probabilistically.
    """
    def __init__(self, unique_id, model, energy=20):
        super().__init__(unique_id, model)
        self.energy = energy

    def move(self):
        possible_steps = self.model.grid.get_neighborhood(self.pos, moore=True, include_center=False)
        new_pos = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_pos)

    def hunt(self):
        # If there are sheep in the same cell, eat one at random
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        sheep_here = [obj for obj in cellmates if isinstance(obj, Sheep)]
        if sheep_here:
            victim = self.random.choice(sheep_here)
            # remove sheep
            self.model.grid.remove_agent(victim)
            try:
                self.model.schedule.remove(victim)
            except ValueError:
                # already removed from schedule maybe
                pass
            self.energy += self.model.wolf_gain_from_food

    def reproduce(self):
        if self.random.random() < self.model.wolf_birth_rate and self.energy >= self.model.wolf_reproduce_energy:
            child = Wolf(self.model.next_id(), self.model, energy=self.model.wolf_start_energy)
            self.model.grid.place_agent(child, self.pos)
            self.model.schedule.add(child)
            # energy split
            self.energy = self.energy // 2
            child.energy = self.energy

    def step(self):
        self.move()
        self.hunt()
        self.energy -= self.model.wolf_energy_loss
        if self.energy <= 0:
            # die
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)
            return
        self.reproduce()
```

---

### Cell 4 — The Model

```python
# Cell 4: define Model

class PredatorPrey(Model):
    """
    A simple predator-prey model with grass resource patches.
    """
    def __init__(self, width=20, height=20, initial_sheep=50, initial_wolves=20,
                 sheep_start_energy=6, wolf_start_energy=20,
                 sheep_gain_from_food=4, wolf_gain_from_food=20,
                 sheep_birth_rate=0.04, wolf_birth_rate=0.02,
                 sheep_energy_loss=1, wolf_energy_loss=2,
                 sheep_reproduce_energy=8, wolf_reproduce_energy=30,
                 grass_regrowth_time=15, seed=None):
        super().__init__(seed=seed)
        self.width = width
        self.height = height
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)
        self.initial_sheep = initial_sheep
        self.initial_wolves = initial_wolves

        # parameters accessible to agents
        self.sheep_start_energy = sheep_start_energy
        self.wolf_start_energy = wolf_start_energy
        self.sheep_gain_from_food = sheep_gain_from_food
        self.wolf_gain_from_food = wolf_gain_from_food
        self.sheep_birth_rate = sheep_birth_rate
        self.wolf_birth_rate = wolf_birth_rate
        self.sheep_energy_loss = sheep_energy_loss
        self.wolf_energy_loss = wolf_energy_loss
        self.sheep_reproduce_energy = sheep_reproduce_energy
        self.wolf_reproduce_energy = wolf_reproduce_energy
        self.grass_regrowth_time = grass_regrowth_time

        # create grass patches everywhere
        uid = 0
        for (x, y) in [(x, y) for x in range(width) for y in range(height)]:
            patch = GrassPatch(uid, self, fully_grown=True, regrowth_time=grass_regrowth_time)
            self.grid.place_agent(patch, (x, y))
            self.schedule.add(patch)
            uid += 1

        # create sheep
        for i in range(initial_sheep):
            s = Sheep(self.next_id(), self, energy=self.sheep_start_energy)
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            self.grid.place_agent(s, (x, y))
            self.schedule.add(s)

        # create wolves
        for i in range(initial_wolves):
            w = Wolf(self.next_id(), self, energy=self.wolf_start_energy)
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            self.grid.place_agent(w, (x, y))
            self.schedule.add(w)

        # Data collector
        self.datacollector = DataCollector(
            {
                "Sheep": lambda m: self.count_type(m, Sheep),
                "Wolves": lambda m: self.count_type(m, Wolf),
                "Grass": lambda m: self.count_grass(m)
            }
        )

    def count_type(self, model, agent_type):
        count = 0
        for a in model.schedule.agents:
            if isinstance(a, agent_type):
                count += 1
        return count

    def count_grass(self, model):
        # number of grown grass patches
        return sum(1 for a in self.schedule.agents if isinstance(a, GrassPatch) and a.fully_grown)

    def step(self):
        # collect data then step
        self.datacollector.collect(self)
        self.schedule.step()
```

---

### Cell 5 — Run a simulation and plot population time series

```python
# Cell 5: run the model and plot populations

# Parameters (you can tweak these)
params = dict(
    width=30,
    height=30,
    initial_sheep=80,
    initial_wolves=25,
    sheep_start_energy=6,
    wolf_start_energy=20,
    sheep_gain_from_food=4,
    wolf_gain_from_food=20,
    sheep_birth_rate=0.04,
    wolf_birth_rate=0.02,
    sheep_energy_loss=1,
    wolf_energy_loss=2,
    sheep_reproduce_energy=8,
    wolf_reproduce_energy=30,
    grass_regrowth_time=15,
    seed=42
)

model = PredatorPrey(**params)

n_steps = 300
for i in range(n_steps):
    model.step()

# collect results
results = model.datacollector.get_model_vars_dataframe()

# Plot
plt.figure(figsize=(10,6))
plt.plot(results["Sheep"], label="Sheep")
plt.plot(results["Wolves"], label="Wolves")
plt.plot(results["Grass"], label="Grown grass")
plt.xlabel("Step")
plt.ylabel("Count")
plt.title("Predator-Prey with Resource (Grass) — population dynamics")
plt.legend()
plt.grid(True)
plt.show()
```

---

### Cell 6 — Optional: quick animation (frames saved to memory then displayed)

```python
# Cell 6: create an animation of the spatial distribution over time.
# WARNING: can be slower for big grids/long runs. Reduce n_frames for speed.
from copy import deepcopy
import numpy as np

def snapshot_from_model(model):
    """Return arrays of x,y and type for plotting."""
    xs, ys, types = [], [], []
    for agent in model.schedule.agents:
        if isinstance(agent, Sheep) or isinstance(agent, Wolf):
            x, y = agent.pos
            xs.append(x)
            ys.append(y)
            types.append("Sheep" if isinstance(agent, Sheep) else "Wolf")
    return xs, ys, types

# Create frames by re-running the model from same seed (or you could have stored positions during the run)
anim_model = PredatorPrey(**params)
frames = []
n_frames = 120  # reduce for speed
for i in range(n_frames):
    xs, ys, types = snapshot_from_model(anim_model)
    # plot frame
    fig, ax = plt.subplots(figsize=(5,5))
    ax.set_xlim(-0.5, anim_model.width - 0.5)
    ax.set_ylim(-0.5, anim_model.height - 0.5)
    ax.set_xticks([])
    ax.set_yticks([])
    # scatter
    if xs:
        xs_arr = np.array(xs)
        ys_arr = np.array(ys)
        colors = ['C0' if t == 'Sheep' else 'C3' for t in types]
        ax.scatter(xs_arr + 0.1*np.random.randn(len(xs_arr)), ys_arr + 0.1*np.random.randn(len(ys_arr)), s=20, c=colors, alpha=0.9)
    ax.set_title(f"Step {i}")
    # save to image buffer via canvas
    fig.canvas.draw()
    image = np.frombuffer(fig.canvas.tostring_rgb(), dtype='uint8')
    image = image.reshape(fig.canvas.get_width_height()[::-1] + (3,))
    frames.append(image)
    plt.close(fig)
    anim_model.step()

# Display a short animation using imageio
gif_path = "/tmp/predprey_anim.gif"
imageio.mimsave(gif_path, frames, fps=8)
from IPython.display import Image
Image(gif_path)
```






```
# Install Mesa if not already installed
!pip install mesa

import random
import numpy as np
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.space import MultiGrid
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector

# ----------------------------
# AGENT CLASSES
# ----------------------------

class Sheep(Agent):
    def __init__(self, unique_id, model, energy=None):
        super().__init__(unique_id, model)
        self.energy = energy if energy is not None else 2 * self.model.sheep_gain_from_food

    def step(self):
        # Move randomly
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)

        # Eat grass if available
        cell_contents = self.model.grid.get_cell_list_contents([self.pos])
        grass_patch = [obj for obj in cell_contents if isinstance(obj, GrassPatch)]
        if grass_patch and grass_patch[0].fully_grown:
            grass_patch[0].fully_grown = False
            self.energy += self.model.sheep_gain_from_food

        # Reproduce
        if self.random.random() < self.model.sheep_reproduce:
            self.energy //= 2
            lamb = Sheep(self.model.next_id(), self.model, self.energy)
            self.model.grid.place_agent(lamb, self.pos)
            self.model.schedule.add(lamb)

        # Die if energy is gone
        self.energy -= 1
        if self.energy <= 0:
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)

class Wolf(Agent):
    def __init__(self, unique_id, model, energy=None):
        super().__init__(unique_id, model)
        self.energy = energy if energy is not None else 2 * self.model.wolf_gain_from_food

    def step(self):
        # Move randomly
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)

        # Hunt sheep
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        sheep = [obj for obj in cellmates if isinstance(obj, Sheep)]
        if len(sheep) > 0:
            sheep_to_eat = self.random.choice(sheep)
            self.energy += self.model.wolf_gain_from_food
            self.model.grid.remove_agent(sheep_to_eat)
            self.model.schedule.remove(sheep_to_eat)

        # Reproduce
        if self.random.random() < self.model.wolf_reproduce:
            self.energy //= 2
            pup = Wolf(self.model.next_id(), self.model, self.energy)
            self.model.grid.place_agent(pup, self.pos)
            self.model.schedule.add(pup)

        # Die if energy is gone
        self.energy -= 1
        if self.energy <= 0:
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)

class GrassPatch(Agent):
    """A patch of grass that grows every X steps if fully_grown=False."""

    def __init__(self, unique_id, model, fully_grown, countdown):
        super().__init__(unique_id, model)
        self.fully_grown = fully_grown
        self.countdown = countdown

    def step(self):
        if not self.fully_grown:
            if self.countdown <= 0:
                self.fully_grown = True
                self.countdown = self.model.grass_regrowth_time
            else:
                self.countdown -= 1

# ----------------------------
# MODEL CLASS
# ----------------------------

class WolfSheepPredation(Model):
    """A model with some number of wolves, sheep, and grass."""

    def __init__(
        self,
        width=20,
        height=20,
        initial_sheep=100,
        initial_wolves=25,
        sheep_reproduce=0.04,
        wolf_reproduce=0.05,
        wolf_gain_from_food=20,
        sheep_gain_from_food=4,
        grass=True,
        grass_regrowth_time=20,
    ):
        self.width = width
        self.height = height
        self.initial_sheep = initial_sheep
        self.initial_wolves = initial_wolves
        self.sheep_reproduce = sheep_reproduce
        self.wolf_reproduce = wolf_reproduce
        self.wolf_gain_from_food = wolf_gain_from_food
        self.sheep_gain_from_food = sheep_gain_from_food
        self.grass = grass
        self.grass_regrowth_time = grass_regrowth_time

        self.schedule = RandomActivation(self)
        self.grid = MultiGrid(self.width, self.height, torus=True)
        self.running = True

        # Create sheep:
        for i in range(self.initial_sheep):
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            sheep = Sheep(self.next_id(), self)
            self.grid.place_agent(sheep, (x, y))
            self.schedule.add(sheep)

        # Create wolves:
        for i in range(self.initial_wolves):
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            wolf = Wolf(self.next_id(), self)
            self.grid.place_agent(wolf, (x, y))
            self.schedule.add(wolf)

        # Create grass patches if enabled
        if self.grass:
            for x in range(self.width):
                for y in range(self.height):
                    fully_grown = self.random.choice([True, False])
                    countdown = (
                        self.grass_regrowth_time
                        if not fully_grown
                        else self.random.randrange(self.grass_regrowth_time)
                    )
                    patch = GrassPatch(self.next_id(), self, fully_grown, countdown)
                    self.grid.place_agent(patch, (x, y))
                    self.schedule.add(patch)

        self.datacollector = DataCollector(
            model_reporters={
                "Wolves": lambda m: self.count_type(m, Wolf),
                "Sheep": lambda m: self.count_type(m, Sheep),
                "Grass": lambda m: self.count_type(m, GrassPatch, lambda x: x.fully_grown),
            }
        )

    @staticmethod
    def count_type(model, agent_type, condition=None):
        count = 0
        for agent in model.schedule.agents:
            if isinstance(agent, agent_type):
                if condition is None or condition(agent):
                    count += 1
        return count

    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()

# ----------------------------
# RUN SIMULATION & PLOT
# ----------------------------

# Parameters
params = {
    "width": 20,
    "height": 20,
    "initial_sheep": 100,
    "initial_wolves": 25,
    "sheep_reproduce": 0.04,
    "wolf_reproduce": 0.05,
    "wolf_gain_from_food": 20,
    "sheep_gain_from_food": 4,
    "grass": True,
    "grass_regrowth_time": 20,
}

# Create and run model
model = WolfSheepPredation(**params)
for i in range(200):  # Run for 200 steps
    model.step()

# Plot results
data = model.datacollector.get_model_vars_dataframe()
plt.figure(figsize=(10, 6))
plt.plot(data["Wolves"], label="Wolves", color="red")
plt.plot(data["Sheep"], label="Sheep", color="blue")
plt.plot(data["Grass"], label="Grass (Fully Grown)", color="green", alpha=0.6)
plt.xlabel("Steps")
plt.ylabel("Population")
plt.title("Wolf-Sheep Predation Model")
plt.legend()
plt.grid(True)
plt.show()
```
