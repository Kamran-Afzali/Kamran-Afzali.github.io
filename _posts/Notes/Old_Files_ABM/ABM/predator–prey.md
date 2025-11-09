# Install Mesa if not already installed
!pip install -q mesa

import random
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.space import MultiGrid
from mesa.time import RandomActivation
from mesa.datacollection import DataCollector


# ----------------------------
# AGENT CLASSES
# ----------------------------

class Sheep(Agent):
    """Sheep that move, eat grass, reproduce, and die."""
    def __init__(self, unique_id, model, energy=None):
        super().__init__(unique_id, model)
        self.energy = energy if energy is not None else 2 * model.sheep_gain_from_food

    def step(self):
        # Move randomly
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_pos = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_pos)

        # Eat grass if available
        if self.model.grass:
            cell_contents = self.model.grid.get_cell_list_contents([self.pos])
            grass_patches = [obj for obj in cell_contents if isinstance(obj, GrassPatch)]
            if grass_patches and grass_patches[0].fully_grown:
                grass_patches[0].fully_grown = False
                self.energy += self.model.sheep_gain_from_food

        # Reproduce
        if self.random.random() < self.model.sheep_reproduce:
            offspring_energy = self.energy // 2
            self.energy -= offspring_energy
            lamb = Sheep(self.model.next_id(), self.model, energy=offspring_energy)
            self.model.grid.place_agent(lamb, self.pos)
            self.model.schedule.add(lamb)

        # Lose energy and possibly die
        self.energy -= 1
        if self.energy <= 0:
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)


class Wolf(Agent):
    """Wolves that move, hunt sheep, reproduce, and die."""
    def __init__(self, unique_id, model, energy=None):
        super().__init__(unique_id, model)
        self.energy = energy if energy is not None else 2 * model.wolf_gain_from_food

    def step(self):
        # Move randomly
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_pos = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_pos)

        # Hunt sheep if present
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        sheep = [obj for obj in cellmates if isinstance(obj, Sheep)]
        if sheep:
            prey = self.random.choice(sheep)
            self.energy += self.model.wolf_gain_from_food
            self.model.grid.remove_agent(prey)
            self.model.schedule.remove(prey)

        # Reproduce
        if self.random.random() < self.model.wolf_reproduce:
            offspring_energy = self.energy // 2
            self.energy -= offspring_energy
            pup = Wolf(self.model.next_id(), self.model, energy=offspring_energy)
            self.model.grid.place_agent(pup, self.pos)
            self.model.schedule.add(pup)

        # Lose energy and possibly die
        self.energy -= 1
        if self.energy <= 0:
            self.model.grid.remove_agent(self)
            self.model.schedule.remove(self)


class GrassPatch(Agent):
    """A patch of grass that regrows after a countdown."""
    def __init__(self, unique_id, model, fully_grown, countdown):
        super().__init__(unique_id, model)
        self.fully_grown = fully_grown
        self.countdown = countdown

    def step(self):
        if not self.fully_grown:
            self.countdown -= 1
            if self.countdown <= 0:
                self.fully_grown = True
                self.countdown = self.model.grass_regrowth_time


# ----------------------------
# MODEL CLASS
# ----------------------------

class WolfSheepPredation(Model):
    """Wolf–Sheep Predation Model with optional grass dynamics."""

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
        seed=None,
    ):
        super().__init__(seed=seed)
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
        self.grid = MultiGrid(width, height, torus=True)
        self.running = True

        # Add sheep
        for _ in range(self.initial_sheep):
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            sheep = Sheep(self.next_id(), self)
            self.grid.place_agent(sheep, (x, y))
            self.schedule.add(sheep)

        # Add wolves
        for _ in range(self.initial_wolves):
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            wolf = Wolf(self.next_id(), self)
            self.grid.place_agent(wolf, (x, y))
            self.schedule.add(wolf)

        # Add grass patches
        if self.grass:
            for x in range(self.width):
                for y in range(self.height):
                    fully_grown = self.random.choice([True, False])
                    countdown = (
                        0 if fully_grown else self.random.randrange(self.grass_regrowth_time)
                    )
                    patch = GrassPatch(self.next_id(), self, fully_grown, countdown)
                    self.grid.place_agent(patch, (x, y))
                    self.schedule.add(patch)

        # Data collector
        self.datacollector = DataCollector(
            model_reporters={
                "Wolves": lambda m: sum(isinstance(a, Wolf) for a in m.schedule.agents),
                "Sheep": lambda m: sum(isinstance(a, Sheep) for a in m.schedule.agents),
                "Grass": lambda m: sum(
                    1 for a in m.schedule.agents if isinstance(a, GrassPatch) and a.fully_grown
                ),
            }
        )

    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()


# ----------------------------
# RUN SIMULATION & PLOT
# ----------------------------

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

model = WolfSheepPredation(**params)
for _ in range(200):
    model.step()

# Plot
data = model.datacollector.get_model_vars_dataframe()
plt.figure(figsize=(10, 6))
plt.plot(data["Wolves"], label="Wolves", color="red")
plt.plot(data["Sheep"], label="Sheep", color="blue")
plt.plot(data["Grass"], label="Grass (Fully Grown)", color="green", alpha=0.6)
plt.xlabel("Steps")
plt.ylabel("Population")
plt.title("Wolf–Sheep Predation Dynamics")
plt.legend()
plt.grid(True)
plt.show()
