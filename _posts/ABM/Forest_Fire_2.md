import mesa
import random
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum
import math
import matplotlib.patches as mpatches

# --- Agent States ---
class TreeState(Enum):
    """Defines the possible states of a grid cell."""
    EMPTY, TREE, FIRE, BURNED, WATER, ROAD = range(6)

class FirefighterState(Enum):
    """Defines the possible states of a firefighter agent."""
    AVAILABLE, MOVING_TO_FIRE, FIGHTING, REFILLING, PATROLLING = range(5)

# --- Agent Definitions ---
class TreeAgent(mesa.Agent):
    """Represents a single cell in the forest grid."""
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.state = TreeState.TREE if self.random.random() < 0.6 else TreeState.EMPTY
        self.fire_intensity = 0
        self.suppression_effort = 0

    def step(self):
        """Growth phase: Trees can grow on empty land."""
        if self.state == TreeState.EMPTY and self.random.random() < self.model.p["growth_rate"]:
            self.state = TreeState.TREE

    def fire_step(self):
        """Fire phase: Fire spreads, burns, and is suppressed."""
        if self.state == TreeState.FIRE:
            if self.suppression_effort >= self.fire_intensity or self.random.random() < 0.05:
                self.state = TreeState.BURNED
            self.fire_intensity = max(0, self.fire_intensity - self.suppression_effort - self.random.randint(1, 5))
            self.suppression_effort = 0 # Reset for the next step
            return

        if self.state == TreeState.TREE:
            neighbors = self.model.grid.get_neighbors(self.pos, moore=True)
            burning_neighbors = sum(1 for n in neighbors if isinstance(n, TreeAgent) and n.state == TreeState.FIRE)

            if burning_neighbors > 0:
                spread_chance = self.model.p["fire_spread_rate"]
                if any(isinstance(n, TreeAgent) and n.state == TreeState.ROAD for n in neighbors):
                    spread_chance *= 0.2
                if self.random.random() < spread_chance * burning_neighbors:
                    self.state = TreeState.FIRE
                    self.fire_intensity = self.random.randint(40, 100)
            elif self.random.random() < (self.model.p["lightning_rate"] + self.model.p["human_ignition_rate"]):
                 self.state = TreeState.FIRE
                 self.fire_intensity = self.random.randint(50, 100)

class FirefighterAgent(mesa.Agent):
    """Responds to fires to suppress them."""
    def __init__(self, unique_id, model, base_pos):
        super().__init__(unique_id, model)
        self.base_pos = base_pos
        self.state = FirefighterState.AVAILABLE
        self.target_fire = None
        self.patrol_target = None

        # Attributes based on policy
        self.water_capacity = self.model.p["ff_water_capacity"]
        self.suppression_power = self.model.p["ff_suppression_power"]
        self.speed = self.model.p["ff_speed"]
        self.patrol_radius = self.model.p["ff_patrol_radius"]
        self.current_water = self.water_capacity

    def step(self):
        """Define firefighter behavior based on their current state."""
        # If a fire is detected, prioritize it over any other state
        if self.model.active_fires and self.state in [FirefighterState.AVAILABLE, FirefighterState.PATROLLING]:
            self._find_target()

        if self.state == FirefighterState.PATROLLING:
            self._patrol()
        elif self.state == FirefighterState.MOVING_TO_FIRE:
            self._handle_movement_to_fire()
        elif self.state == FirefighterState.FIGHTING:
            self._fight_fire()
        elif self.state == FirefighterState.REFILLING:
            self._refill_water()
        elif self.state == FirefighterState.AVAILABLE and self.patrol_radius > 0:
            self.state = FirefighterState.PATROLLING

    def _move_towards(self, target_pos):
        """Move towards a target position."""
        dx = target_pos[0] - self.pos[0]
        dy = target_pos[1] - self.pos[1]
        dist = math.hypot(dx, dy)
        if dist <= self.speed:
            new_pos = target_pos
        else:
            new_pos = (
                self.pos[0] + int(round(self.speed * dx / dist)),
                self.pos[1] + int(round(self.speed * dy / dist))
            )
        new_x = max(0, min(self.model.width - 1, new_pos[0]))
        new_y = max(0, min(self.model.height - 1, new_pos[1]))
        self.model.grid.move_agent(self, (new_x, new_y))

    def _find_target(self):
        """Find the closest, unassigned fire to fight."""
        unassigned = self.model.active_fires - set(self.model.assigned_fires.keys())
        if unassigned:
            self.target_fire = min(unassigned, key=lambda pos: math.dist(self.pos, pos))
            self.model.assigned_fires[self.target_fire] = self.unique_id
            self.state = FirefighterState.MOVING_TO_FIRE

    def _handle_movement_to_fire(self):
        """Logic for moving towards a fire target."""
        if not self.target_fire or self.target_fire not in self.model.active_fires:
            self._become_available()
            return
        self._move_towards(self.target_fire)
        if math.dist(self.pos, self.target_fire) < 2: # Is adjacent
            self.state = FirefighterState.FIGHTING

    def _fight_fire(self):
        """Apply suppression effort to the target fire."""
        if not self.target_fire or self.target_fire not in self.model.active_fires:
            self._become_available()
            return

        if self.current_water <= 0:
            self.state = FirefighterState.REFILLING
            self._release_target()
            return

        # Fix: Get agents at the target position correctly
        agents_at_pos = self.model.grid.get_cell_list_contents([self.target_fire])
        target_cell = None
        for agent in agents_at_pos:
            if isinstance(agent, TreeAgent):
                target_cell = agent
                break
                
        if target_cell and target_cell.state == TreeState.FIRE:
            target_cell.suppression_effort += self.suppression_power
            self.current_water -= 5

    def _refill_water(self):
        """Find and move to the nearest water source to refill."""
        if not self.model.water_sources:
            return
        closest_water = min(self.model.water_sources, key=lambda pos: math.dist(self.pos, pos))
        if self.pos == closest_water:
            self.current_water = self.water_capacity
            self.state = FirefighterState.AVAILABLE
        else:
            self._move_towards(closest_water)

    def _patrol(self):
        """Move to random points within a radius of the base station."""
        if not self.patrol_target or self.pos == self.patrol_target:
            px = self.base_pos[0] + self.random.randint(-self.patrol_radius, self.patrol_radius)
            py = self.base_pos[1] + self.random.randint(-self.patrol_radius, self.patrol_radius)
            self.patrol_target = (
                max(0, min(self.model.width - 1, px)),
                max(0, min(self.model.height - 1, py))
            )
        self._move_towards(self.patrol_target)

    def _release_target(self):
        """Release a target fire from assignment."""
        if self.target_fire in self.model.assigned_fires:
            del self.model.assigned_fires[self.target_fire]
        self.target_fire = None

    def _become_available(self):
        """Reset state to available and release any target."""
        self._release_target()
        self.state = FirefighterState.AVAILABLE

    def fire_step(self):
        pass # Firefighters only act in the main `step` phase.

# --- Model Definition ---
class ForestFireModel(mesa.Model):
    """The main model for the forest fire simulation."""
    POLICY_PARAMS = {
        "reactive": {"num_firefighters": 3, "ff_water_capacity": 100, "ff_suppression_power": 15, "ff_speed": 2, "ff_patrol_radius": 0},
        "preventive": {"num_firefighters": 5, "ff_water_capacity": 100, "ff_suppression_power": 15, "ff_speed": 2, "ff_patrol_radius": 8},
        "aggressive": {"num_firefighters": 7, "ff_water_capacity": 150, "ff_suppression_power": 25, "ff_speed": 3, "ff_patrol_radius": 0},
    }

    def __init__(self, width=50, height=50, policy="reactive"):
        super().__init__()
        self.width, self.height = width, height
        self.p = self.POLICY_PARAMS[policy] # Load policy parameters
        self.p.update({ # Add general parameters
            "growth_rate": 0.015, "fire_spread_rate": 0.6,
            "lightning_rate": 0.0001, "human_ignition_rate": 0.0002,
            "num_water_sources": 3, "road_density": 0.04
        })

        self.grid = mesa.space.MultiGrid(width, height, torus=False)
        self.active_fires, self.assigned_fires = set(), {}
        self.water_sources = []

        # Create agents and infrastructure
        agent_id = 0
        all_agents = []
        for x in range(width):
            for y in range(height):
                agent = TreeAgent(agent_id, self)
                self.grid.place_agent(agent, (x, y))
                all_agents.append(agent)
                agent_id += 1

        self._add_infrastructure()

        fire_stations = [(5, 5), (width-5, 5), (5, height-5), (width-5, height-5)]
        for i in range(self.p["num_firefighters"]):
            base_pos = fire_stations[i % len(fire_stations)]
            firefighter = FirefighterAgent(agent_id, self, base_pos)
            self.grid.place_agent(firefighter, base_pos)
            all_agents.append(firefighter)
            agent_id += 1

        # Add all agents to the schedule after they are created
        # Fix: Correctly initialize StagedActivation with stage names
        self.schedule = mesa.time.StagedActivation(self, stage_list=["step", "fire_step"], shuffle=True)
        for agent in all_agents:
            self.schedule.add(agent)

        # Setup data collection
        self.datacollector = mesa.DataCollector(model_reporters={
            "Trees": lambda m: sum(1 for a in m.schedule.agents if isinstance(a, TreeAgent) and a.state == TreeState.TREE),
            "Fires": lambda m: len(m.active_fires),
            "Burned": lambda m: sum(1 for a in m.schedule.agents if isinstance(a, TreeAgent) and a.state == TreeState.BURNED)
        })
        self.running = True
        self.datacollector.collect(self)

    def _add_infrastructure(self):
        """Helper to add roads and water sources to the grid."""
        for _ in range(self.p["num_water_sources"]):
            x, y = self.random.randrange(self.width), self.random.randrange(self.height)
            self.water_sources.append((x,y))
            # Fix: Get cell contents properly
            agents = self.grid.get_cell_list_contents([(x, y)])
            if agents:
                agents[0].state = TreeState.WATER # Set cell to water

        for _ in range(int(self.width * self.p["road_density"])):
            y = self.random.randrange(self.height)
            for x in range(self.width):
                agents = self.grid.get_cell_list_contents([(x, y)])
                if agents:
                    agents[0].state = TreeState.ROAD
            x = self.random.randrange(self.width)
            for y in range(self.height):
                agents = self.grid.get_cell_list_contents([(x, y)])
                if agents:
                    agents[0].state = TreeState.ROAD

    def step(self):
        """Execute one time step of the model."""
        # 1. Update model-level fire information
        self.active_fires = {a.pos for a in self.schedule.agents if isinstance(a, TreeAgent) and a.state == TreeState.FIRE}
        extinguished = self.assigned_fires.keys() - self.active_fires
        for pos in list(extinguished):
            del self.assigned_fires[pos]

        # 2. Execute agent steps
        self.schedule.step()
        self.datacollector.collect(self)

        # 3. Check for simulation end condition
        if not any(a.state in [TreeState.TREE, TreeState.FIRE] for a in self.schedule.agents if isinstance(a, TreeAgent)):
            self.running = False
            
    def run_model(self, n):
        """Run the model for n steps."""
        for i in range(n):
            if not self.running:
                break
            self.step()

# --- Visualization and Execution ---
def get_model_state(model):
    """Extracts grid data from the model for visualization."""
    grid = np.zeros((model.width, model.height))
    ff_pos = []
    for agent in model.schedule.agents:
        if isinstance(agent, TreeAgent):
            grid[agent.pos] = agent.state.value
        elif isinstance(agent, FirefighterAgent):
            ff_pos.append(agent.pos)
    return grid, ff_pos

def plot_simulation(model_data, step_num):
    """Generates a visualization of the model state."""
    grid, ff_pos = model_data
    fig, ax = plt.subplots(figsize=(8, 8))
    colors = ['#FFFFFF', '#228B22', '#FF4500', '#000000', '#1E90FF', '#A9A9A9']
    cmap = plt.matplotlib.colors.ListedColormap(colors)
    ax.imshow(grid.T, cmap=cmap, origin='lower', vmin=0, vmax=len(colors)-1)

    if ff_pos:
        ff_x, ff_y = zip(*ff_pos)
        ax.scatter(ff_x, ff_y, c='yellow', s=60, marker='s', edgecolors='black')

    patches = [mpatches.Patch(color=c, label=s.name.capitalize()) for s, c in zip(TreeState, colors)]
    patches.append(plt.Line2D([0], [0], marker='s', color='w', label='Firefighter', markerfacecolor='yellow', markersize=8))
    ax.legend(handles=patches, bbox_to_anchor=(1.05, 1), loc='upper left')
    ax.set_title(f"Step: {step_num}")
    plt.tight_layout()
    plt.show()

def plot_results(results):
    """Plots a comparison of different policy results."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    metrics = ['Trees', 'Burned', 'Fires']
    for ax, metric in zip(axes, metrics):
        for policy, data in results.items():
            ax.plot(data.index, data[metric], label=policy.capitalize())
        ax.set_title(f"{metric} Over Time")
        ax.set_xlabel("Time Steps")
        ax.grid(True, linestyle='--', alpha=0.6)
        ax.legend()
    plt.tight_layout()
    plt.show()

# --- Main Execution Block ---
if __name__ == "__main__":
    STEPS = 200
    # 1. Run a single detailed simulation with visualization
    print("--- Running single 'Preventive' simulation with visualization ---")
    model = ForestFireModel(policy="preventive")
    for i in range(STEPS):
        if not model.running: 
            break
        model.step()
        if i % 50 == 0: # Visualize every 50 steps
            plot_simulation(get_model_state(model), i)

    # 2. Compare different policies without step-by-step visualization
    print("\n--- Running simulations to compare policies ---")
    all_results = {}
    for policy in ForestFireModel.POLICY_PARAMS.keys():
        print(f"Simulating '{policy}' policy...")
        model = ForestFireModel(policy=policy)
        model.run_model(STEPS)
        all_results[policy] = model.datacollector.get_model_vars_dataframe()

    print("\n--- Plotting Comparison Results ---")
    plot_results(all_results)
