



# Understanding Forest Fire Dynamics: Building an Agent-Based Model with Mesa

Forest fires are complex natural phenomena that involve growth, destruction, and regeneration cycles. Today, we'll explore how to simulate these dynamics using Python's Mesa framework, creating a model that demonstrates staged activation, spatial propagation, and stochastic processes.

## What We're Building

Our Forest Fire Model simulates a grid-based ecosystem where:
- Trees grow slowly on empty land
- Lightning strikes randomly ignite forests  
- Fires spread to neighboring trees
- Burned areas eventually regenerate

The model uses Mesa's advanced scheduling features to separate growth and fire dynamics into distinct phases, creating realistic temporal patterns.

## Setting Up the Foundation

```python
import mesa
import random
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum

class TreeState(Enum):
    EMPTY = 0
    TREE = 1
    FIRE = 2
    BURNED = 3
```

We start by importing our dependencies and defining the possible states for each cell in our forest. Using an `Enum` makes our code more readable and helps prevent bugs by giving meaningful names to our states rather than using raw numbers.

## Creating the TreeAgent

```python
class TreeAgent(mesa.Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.state = TreeState.EMPTY
        self.age = 0
```

Each cell in our forest is represented by a `TreeAgent`. Every agent starts as empty land with age 0. The agent inherits from Mesa's base `Agent` class, which provides the basic structure for agents in the framework.

### The Growth Phase

```python
def step(self):
    """Growth phase - trees can grow on empty land"""
    if self.state == TreeState.EMPTY:
        if random.random() < self.model.growth_rate:
            self.state = TreeState.TREE
            self.age = 0
    elif self.state == TreeState.TREE:
        self.age += 1
```

The `step()` method handles the growth phase of our model. Empty land has a small probability of growing a new tree each time step, controlled by the `growth_rate` parameter. Existing trees simply age with each step. This stochastic approach creates natural variation in forest density.

### The Fire Phase  

```python
def fire_step(self):
    """Fire phase - fire spreads and burns out"""
    if self.state == TreeState.FIRE:
        # Fire burns out after one step
        self.state = TreeState.BURNED
    elif self.state == TreeState.TREE:
        # Check for fire spread from neighbors
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False
        )
        
        # Fire spreads from burning neighbors
        for neighbor in neighbors:
            if neighbor.state == TreeState.FIRE:
                if random.random() < self.model.fire_spread_rate:
                    self.state = TreeState.FIRE
                    break
        
        # Lightning strikes
        if random.random() < self.model.lightning_rate:
            self.state = TreeState.FIRE
```

The `fire_step()` method is where the drama happens! This method implements our fire dynamics:

1. **Burnout**: Any cell currently on fire burns out and becomes a burned cell
2. **Fire Spread**: Trees check their Moore neighborhood (8 surrounding cells) and can catch fire from burning neighbors with probability `fire_spread_rate`
3. **Lightning Strikes**: Trees can spontaneously ignite due to lightning with a very low probability

The separation of growth and fire phases using staged activation prevents unrealistic same-step interactions.

## Building the Forest Model

```python
class ForestFireModel(mesa.Model):
    def __init__(self, width=50, height=50, growth_rate=0.01, 
                 fire_spread_rate=0.8, lightning_rate=0.0001):
        super().__init__()
        
        self.width = width
        self.height = height
        self.growth_rate = growth_rate
        self.fire_spread_rate = fire_spread_rate
        self.lightning_rate = lightning_rate
```

Our main model class stores the grid dimensions and the three key parameters that control our system's behavior. These parameters allow us to experiment with different forest dynamics.

### Spatial Structure with MultiGrid

```python
# Use MultiGrid to allow multiple agents per cell
self.grid = mesa.space.MultiGrid(width, height, torus=False)
```

We use Mesa's `MultiGrid` to create our spatial environment. While we only place one agent per cell in this model, `MultiGrid` provides flexibility for future extensions. The `torus=False` parameter means our forest has edges (fires can't wrap around).

### Staged Activation: The Heart of Temporal Dynamics

```python
# Use StagedActivation for two-phase updates
self.schedule = mesa.time.StagedActivation(
    self, 
    stage_list=["step", "fire_step"],
    shuffle=True
)
```

This is where Mesa's power shines! `StagedActivation` allows us to define multiple phases that execute in sequence:

1. First, all agents execute their `step()` method (growth phase)
2. Then, all agents execute their `fire_step()` method (fire phase)

The `shuffle=True` parameter randomizes the order agents are processed within each stage, preventing spatial biases.

### Population and Initialization

```python
# Create agents for each cell
for x in range(width):
    for y in range(height):
        agent = TreeAgent(x * height + y, self)
        self.grid.place_agent(agent, (x, y))
        self.schedule.add(agent)
        
        # Start with some random trees
        if random.random() < 0.3:
            agent.state = TreeState.TREE
```

We populate our forest by creating one agent for each grid cell. Each agent gets a unique ID and position. We start with about 30% tree coverage to create an interesting initial condition.

### Data Collection

```python
self.datacollector = mesa.DataCollector(
    model_reporters={
        "Trees": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.TREE),
        "Fires": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.FIRE),
        "Burned": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.BURNED),
        "Empty": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.EMPTY)
    }
)
```

Mesa's `DataCollector` automatically tracks statistics over time. We count how many cells are in each state at every time step, allowing us to analyze population dynamics.

## Visualization: Bringing the Model to Life

```python
def visualize_forest(model, step_num):
    """Create visualization of the forest state"""
    grid = np.zeros((model.width, model.height))
    
    for agent in model.schedule.agents:
        x, y = agent.pos
        grid[x][y] = agent.state.value
    
    # Create color map
    colors = ['white', 'green', 'red', 'black']  # Empty, Tree, Fire, Burned
    cmap = plt.matplotlib.colors.ListedColormap(colors)
```

Our visualization function converts the agent states into a numpy array and uses matplotlib to create intuitive color-coded maps:
- **White**: Empty land ready for growth
- **Green**: Living trees  
- **Red**: Active fires
- **Black**: Recently burned areas

## Running the Simulation

```python
def run_simulation():
    """Run the forest fire simulation"""
    model = ForestFireModel(
        width=50, 
        height=50, 
        growth_rate=0.02,      # Trees grow slowly
        fire_spread_rate=0.7,   # Fire spreads readily
        lightning_rate=0.0005   # Occasional lightning strikes
    )
    
    steps_to_run = 200
    
    for i in range(steps_to_run):
        model.step()
        
        # Visualize every 50 steps
        if i % 50 == 0:
            visualize_forest(model, i)
```

The simulation runs for 200 time steps, showing snapshots every 50 steps. Each call to `model.step()` executes both phases of our staged activation.

## Understanding the Dynamics

When you run this model, you'll observe several fascinating patterns:

**Growth Patterns**: Trees slowly fill empty spaces, creating patchy forest coverage due to stochastic growth.

**Fire Propagation**: When lightning strikes, fires spread rapidly through connected tree clusters, creating burn patterns that follow the forest structure.

**Regeneration Cycles**: After fires pass through, the forest slowly regenerates, leading to cyclical dynamics between dense forest periods and sparse recovery periods.

**Edge Effects**: Fires that reach the grid boundaries stop spreading, creating natural firebreaks.

## Key Learning Points

This model demonstrates several important concepts in agent-based modeling:

1. **Staged Activation**: Separating different processes (growth vs. fire) into distinct phases creates more realistic dynamics
2. **Spatial Propagation**: Local interactions between neighboring agents create global patterns
3. **Stochastic Processes**: Randomness at the individual level leads to complex system-level behaviors
4. **Temporal Dynamics**: The interplay between slow processes (growth) and fast processes (fire) creates interesting rhythms

## Extending the Model

This basic framework provides a foundation for exploring more complex forest dynamics. You could add:
- Different tree species with varying fire resistance
- Wind effects that bias fire spread direction  
- Firefighting agents that suppress fires
- Seasonal variations in growth and lightning rates
- Topographical effects on fire spread

The Mesa framework's modular design makes these extensions straightforward to implement while maintaining the core staged activation structure.

## Conclusion

Agent-based models like this Forest Fire simulation reveal how simple local rules can create complex global patterns. By using Mesa's staged activation and spatial grids, we can explore the intricate dance between growth, destruction, and regeneration that characterizes real forest ecosystems.

The model shows us that complexity doesn't always require complicated rules – sometimes the most interesting behaviors emerge from the interplay of simple processes operating at different timescales. This is the beauty and power of agent-based modeling: turning simple interactions into insights about complex systems.

```
import mesa
import random
import matplotlib.pyplot as plt
import numpy as np
from enum import Enum

class TreeState(Enum):
    EMPTY = 0
    TREE = 1
    FIRE = 2
    BURNED = 3

class TreeAgent(mesa.Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        self.state = TreeState.EMPTY
        self.age = 0
    
    def step(self):
        """Growth phase - trees can grow on empty land"""
        if self.state == TreeState.EMPTY:
            if random.random() < self.model.growth_rate:
                self.state = TreeState.TREE
                self.age = 0
        elif self.state == TreeState.TREE:
            self.age += 1
    
    def fire_step(self):
        """Fire phase - fire spreads and burns out"""
        if self.state == TreeState.FIRE:
            # Fire burns out after one step
            self.state = TreeState.BURNED
        elif self.state == TreeState.TREE:
            # Check for fire spread from neighbors
            neighbors = self.model.grid.get_neighbors(
                self.pos, moore=True, include_center=False
            )
            
            # Fire spreads from burning neighbors
            for neighbor in neighbors:
                if neighbor.state == TreeState.FIRE:
                    if random.random() < self.model.fire_spread_rate:
                        self.state = TreeState.FIRE
                        break
            
            # Lightning strikes
            if random.random() < self.model.lightning_rate:
                self.state = TreeState.FIRE

class ForestFireModel(mesa.Model):
    def __init__(self, width=50, height=50, growth_rate=0.01, 
                 fire_spread_rate=0.8, lightning_rate=0.0001):
        super().__init__()
        
        self.width = width
        self.height = height
        self.growth_rate = growth_rate
        self.fire_spread_rate = fire_spread_rate
        self.lightning_rate = lightning_rate
        
        # Use MultiGrid to allow multiple agents per cell (not needed here but good practice)
        self.grid = mesa.space.MultiGrid(width, height, torus=False)
        
        # Use StagedActivation for two-phase updates
        self.schedule = mesa.time.StagedActivation(
            self, 
            stage_list=["step", "fire_step"],
            shuffle=True
        )
        
        # Create agents for each cell
        for x in range(width):
            for y in range(height):
                agent = TreeAgent(x * height + y, self)
                self.grid.place_agent(agent, (x, y))
                self.schedule.add(agent)
                
                # Start with some random trees
                if random.random() < 0.3:
                    agent.state = TreeState.TREE
        
        # Data collection
        self.datacollector = mesa.DataCollector(
            model_reporters={
                "Trees": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.TREE),
                "Fires": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.FIRE),
                "Burned": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.BURNED),
                "Empty": lambda m: sum(1 for a in m.schedule.agents if a.state == TreeState.EMPTY)
            }
        )
        
        self.running = True
        self.datacollector.collect(self)
    
    def step(self):
        """Execute one step of the model"""
        self.schedule.step()
        self.datacollector.collect(self)

def visualize_forest(model, step_num):
    """Create visualization of the forest state"""
    grid = np.zeros((model.width, model.height))
    
    for agent in model.schedule.agents:
        x, y = agent.pos
        grid[x][y] = agent.state.value
    
    # Create color map
    colors = ['white', 'green', 'red', 'black']  # Empty, Tree, Fire, Burned
    cmap = plt.matplotlib.colors.ListedColormap(colors)
    
    plt.figure(figsize=(10, 8))
    plt.imshow(grid.T, cmap=cmap, origin='lower', vmin=0, vmax=3)
    plt.title(f'Forest Fire Model - Step {step_num}')
    plt.colorbar(ticks=[0, 1, 2, 3], label='State')
    
    # Add legend
    legend_elements = [
        plt.Rectangle((0,0),1,1, facecolor='white', edgecolor='black', label='Empty'),
        plt.Rectangle((0,0),1,1, facecolor='green', label='Tree'),
        plt.Rectangle((0,0),1,1, facecolor='red', label='Fire'),
        plt.Rectangle((0,0),1,1, facecolor='black', label='Burned')
    ]
    plt.legend(handles=legend_elements, loc='upper left', bbox_to_anchor=(1.02, 1))
    
    plt.tight_layout()
    plt.show()

def run_simulation():
    """Run the forest fire simulation"""
    # Create model
    model = ForestFireModel(
        width=50, 
        height=50, 
        growth_rate=0.02,      # Trees grow slowly
        fire_spread_rate=0.7,   # Fire spreads readily
        lightning_rate=0.0005   # Occasional lightning strikes
    )
    
    # Run simulation and collect data
    steps_to_run = 200
    
    for i in range(steps_to_run):
        model.step()
        
        # Visualize every 50 steps
        if i % 50 == 0:
            print(f"Step {i}")
            visualize_forest(model, i)
    
    # Plot time series data
    model_data = model.datacollector.get_model_vars_dataframe()
    
    plt.figure(figsize=(12, 6))
    plt.plot(model_data.index, model_data['Trees'], label='Trees', color='green')
    plt.plot(model_data.index, model_data['Fires'], label='Fires', color='red')
    plt.plot(model_data.index, model_data['Burned'], label='Burned', color='black')
    plt.plot(model_data.index, model_data['Empty'], label='Empty', color='lightgray')
    
    plt.xlabel('Time Steps')
    plt.ylabel('Number of Cells')
    plt.title('Forest Fire Model - Population Dynamics')
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.show()
    
    return model

# Run the simulation
if __name__ == "__main__":
    model = run_simulation()
```
