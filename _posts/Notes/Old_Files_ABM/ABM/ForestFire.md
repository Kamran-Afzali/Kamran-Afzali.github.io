# Forest Fire Dynamics Modeling Complexity from Simple Rules

## Introduction: When Simple Rules Create Complex Patterns

Imagine standing at the edge of a vast forest after a wildfire. The landscape tells a story: patches of green survivors, black scars of destruction, and empty clearings awaiting rebirth. This isn't random chaos—it's the signature of a complex adaptive system, where simple local interactions between trees, fire, and chance create intricate patterns spanning thousands of acres.

Forest fires represent one of nature's most dramatic examples of **emergent behavior**: sophisticated patterns arising from simple rules. While predicting exactly where fire will spread remains challenging, we can understand the fundamental principles governing fire dynamics through computational modeling. This post explores how cellular automata—grid-based models where each cell follows simple rules—reveal the hidden order within seemingly chaotic fire patterns.

## The Forest Fire Model: Four States, Infinite Possibilities

The classical forest fire model, introduced by Drossel and Schwabl in 1992, reduces forest dynamics to their essence. Each location on a grid exists in one of four states:

- **Empty** (E): Bare ground, ready for regrowth
- **Tree** (T): Living vegetation that can burn
- **Fire** (F): Active combustion
- **Burned** (B): Recently consumed, temporarily barren

These states transition according to three fundamental processes:

1. **Growth**: Empty cells sprout new trees with probability `p_g`
2. **Lightning**: Trees ignite spontaneously with probability `p_l`  
3. **Spread**: Fire jumps to neighboring trees with probability `p_f`

Let's implement this in Python using the Mesa agent-based modeling framework:

```python
from enum import Enum
import random

class TreeState(Enum):
    EMPTY = 0
    TREE = 1
    FIRE = 2
    BURNED = 3

class TreeAgent:
    def __init__(self, unique_id, model):
        self.unique_id = unique_id
        self.model = model
        self.state = TreeState.EMPTY
        self.age = 0
```

Each cell is an autonomous agent tracking its current state and age. This simple structure enables surprisingly rich dynamics.

## Two-Phase Evolution: Separating Growth from Fire

The model's temporal evolution uses a **staged activation** protocol—a critical design choice that prevents artifacts from update ordering. Without staging, cells updated early in a timestep would influence those updated later, breaking the synchronous nature of cellular automata.

We separate each timestep into two phases:

**Phase 1 - Growth**: Trees grow on empty land, existing trees age

```python
def growth_step(self):
    """Trees grow probabilistically on empty cells"""
    if self.state == TreeState.EMPTY:
        if random.random() < self.model.growth_rate:
            self.state = TreeState.TREE
            self.age = 0
    elif self.state == TreeState.TREE:
        self.age += 1  # Track forest maturity
```

**Phase 2 - Fire**: Burning cells become burned, fires spread to neighbors, lightning strikes occur

```python
def fire_step(self):
    """Fire spreads and burns out"""
    if self.state == TreeState.FIRE:
        self.state = TreeState.BURNED  # Fire burns out after one step
        
    elif self.state == TreeState.TREE:
        # Check if fire spreads from burning neighbors
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False
        )
        
        for neighbor in neighbors:
            if neighbor.state == TreeState.FIRE:
                if random.random() < self.model.fire_spread_rate:
                    self.state = TreeState.FIRE
                    return  # Already ignited, no need to check lightning
        
        # Random lightning strikes
        if random.random() < self.model.lightning_rate:
            self.state = TreeState.FIRE
```

This staged approach ensures all cells evaluate their state based on the *previous* timestep's configuration, maintaining mathematical consistency.

## Building the Complete Model

Let's construct the full forest fire simulation:

```python
import mesa
import numpy as np

class ForestFireModel(mesa.Model):
    def __init__(self, width=100, height=100, 
                 growth_rate=0.01, 
                 fire_spread_rate=0.7, 
                 lightning_rate=0.0001):
        super().__init__()
        
        # Model parameters
        self.width = width
        self.height = height
        self.growth_rate = growth_rate
        self.fire_spread_rate = fire_spread_rate
        self.lightning_rate = lightning_rate
        
        # Spatial grid
        self.grid = mesa.space.MultiGrid(width, height, torus=False)
        
        # Staged scheduler: growth phase, then fire phase
        self.schedule = mesa.time.StagedActivation(
            self, 
            stage_list=["growth_step", "fire_step"],
            shuffle=True
        )
        
        # Create agents
        for x in range(width):
            for y in range(height):
                agent = TreeAgent(x * height + y, self)
                self.grid.place_agent(agent, (x, y))
                self.schedule.add(agent)
                
                # Initialize with 30% tree cover
                if random.random() < 0.3:
                    agent.state = TreeState.TREE
        
        # Track population dynamics over time
        self.datacollector = mesa.DataCollector(
            model_reporters={
                "Trees": lambda m: self.count_state(m, TreeState.TREE),
                "Fires": lambda m: self.count_state(m, TreeState.FIRE),
                "Burned": lambda m: self.count_state(m, TreeState.BURNED)
            }
        )
        
    @staticmethod
    def count_state(model, state):
        return sum(1 for a in model.schedule.agents if a.state == state)
    
    def step(self):
        """Execute one timestep"""
        self.schedule.step()
        self.datacollector.collect(self)
```

## Emergent Dynamics: Self-Organized Criticality

When you run this model, something remarkable happens. The system doesn't settle into a boring steady state. Instead, it exhibits **self-organized criticality**—the forest naturally evolves toward a critical threshold where small perturbations (a single lightning strike) can trigger avalanches of change (massive fires).

Here's what a typical simulation reveals:

```python
def analyze_fire_sizes(model, steps=5000):
    """Track the size distribution of fire events"""
    fire_sizes = []
    current_fire_size = 0
    
    for _ in range(steps):
        fires_before = model.count_state(model, TreeState.FIRE)
        model.step()
        fires_after = model.count_state(model, TreeState.FIRE)
        
        if fires_after > 0:
            current_fire_size += fires_after
        elif current_fire_size > 0:
            fire_sizes.append(current_fire_size)
            current_fire_size = 0
    
    return fire_sizes
```

When you plot fire size distributions, you often see a **power law**: many small fires and occasional catastrophic ones. This scale-invariant pattern appears throughout nature—from earthquakes to avalanches—and signals that the system operates at a critical point.

## The Critical Fire Spread Probability

The model's behavior transforms dramatically at a critical fire spread probability, **p_f^c**. This phase transition separates two distinct regimes:

**Subcritical** (p_f < p_f^c): Fires remain localized, burning small patches before dying out. The forest maintains high tree density with frequent small disturbances.

**Supercritical** (p_f > p_f^c): Fires percolate across the landscape, creating system-spanning burns. Tree density crashes during major events, then slowly recovers.

The critical value depends on the grid's connectivity. For the Moore neighborhood (8 neighbors), it's approximately:

```python
def estimate_critical_probability(grid_type='moore'):
    """Estimate percolation threshold"""
    if grid_type == 'moore':
        return 1.0 / 8  # ~0.125 for 8-connected grid
    elif grid_type == 'von_neumann':
        return 1.0 / 4  # ~0.25 for 4-connected grid
```

However, the interplay of growth and lightning creates complex dynamics that shift this threshold in practice.

## Spatial Patterns: Forest Mosaics

The model generates striking spatial patterns. After a large fire event, the landscape resembles a patchwork quilt:

- **Fire scars**: Contiguous burned areas marking where flames spread
- **Survivor patches**: Isolated tree clusters that escaped ignition
- **Recovery zones**: Young forests regrowing on old burn scars

These patterns aren't random—they reflect the spatial correlation inherent in fire spread. Trees cluster because empty spaces between them act as firebreaks. When fire does arrive, these dense clusters provide connected fuel that enables rapid propagation.

```python
def calculate_spatial_correlation(model, distance_range=20):
    """Measure how tree presence correlates with distance"""
    correlations = []
    
    for distance in range(1, distance_range):
        correlation_sum = 0
        sample_count = 0
        
        # Sample random cell pairs at this distance
        for _ in range(1000):
            x1, y1 = random.randint(0, model.width-1), random.randint(0, model.height-1)
            angle = random.uniform(0, 2 * np.pi)
            x2 = int(x1 + distance * np.cos(angle))
            y2 = int(y1 + distance * np.sin(angle))
            
            if 0 <= x2 < model.width and 0 <= y2 < model.height:
                agent1 = model.grid.get_cell_list_contents((x1, y1))[0]
                agent2 = model.grid.get_cell_list_contents((x2, y2))[0]
                
                # Both trees = 1, otherwise 0
                both_trees = int(agent1.state == TreeState.TREE and 
                               agent2.state == TreeState.TREE)
                correlation_sum += both_trees
                sample_count += 1
        
        correlations.append(correlation_sum / sample_count if sample_count > 0 else 0)
    
    return correlations
```

## Temporal Oscillations: Boom and Bust Cycles

Long-term dynamics reveal quasi-periodic oscillations—alternating phases of forest accumulation and catastrophic fire:

1. **Accumulation phase**: Trees grow and spread, connectivity increases
2. **Critical buildup**: Dense fuel loads make the landscape highly flammable  
3. **Trigger event**: Lightning strike initiates fire in the mature forest
4. **Catastrophic burn**: Fire spreads rapidly through connected fuel
5. **Reset**: Landscape returns to sparse cover, cycle restarts

The characteristic timescale of these cycles depends on parameter ratios:

**τ_cycle ≈ (1/p_l) × ln(1/p_g) / p_f**

- **1/p_l**: Average waiting time between lightning strikes
- **ln(1/p_g)**: Time to rebuild forest density
- **1/p_f**: Inverse fire efficiency

For typical parameters (p_g=0.01, p_f=0.7, p_l=0.0001), cycles span hundreds to thousands of timesteps.

## Equilibrium and Stability

Despite oscillations, the system exhibits a dynamic equilibrium where average tree density stabilizes. A mean-field approximation estimates:

**ρ_T* = p_g / (p_g + p_l + ⟨p_spread⟩)**

Here, **⟨p_spread⟩** represents the effective fire spread rate accounting for spatial correlations. This equilibrium balances growth (which increases tree density) against mortality from lightning and neighbor-induced fire.

The stability of this equilibrium determines whether perturbations dissipate or amplify:

```python
def analyze_stability(model, perturbation_size=0.1):
    """Test response to density perturbations"""
    # Reach equilibrium
    for _ in range(1000):
        model.step()
    
    baseline_density = model.count_state(model, TreeState.TREE) / (model.width * model.height)
    
    # Introduce perturbation: randomly remove trees
    agents_to_perturb = random.sample(
        [a for a in model.schedule.agents if a.state == TreeState.TREE],
        int(perturbation_size * model.width * model.height)
    )
    for agent in agents_to_perturb:
        agent.state = TreeState.EMPTY
    
    # Track recovery
    densities = []
    for _ in range(500):
        model.step()
        density = model.count_state(model, TreeState.TREE) / (model.width * model.height)
        densities.append(density - baseline_density)
    
    return densities
```

Systems returning smoothly to equilibrium exhibit **damped oscillations**, while those with amplifying perturbations may spiral into chaos or alternative stable states.

## Applications: From Theory to Management

### Fuel Reduction Strategies

Forest managers can use the model to evaluate thinning programs. Reducing tree density (lowering initial tree cover or growth rate) can shift the system below the critical fire spread threshold:

```python
def compare_fuel_treatments(baseline_growth=0.01, reduced_growth=0.005):
    """Compare fire regimes with and without fuel reduction"""
    
    # Baseline scenario
    model_baseline = ForestFireModel(growth_rate=baseline_growth)
    for _ in range(2000):
        model_baseline.step()
    
    # Fuel reduction scenario  
    model_treated = ForestFireModel(growth_rate=reduced_growth)
    for _ in range(2000):
        model_treated.step()
    
    # Compare fire frequencies
    fires_baseline = model_baseline.datacollector.get_model_vars_dataframe()['Fires']
    fires_treated = model_treated.datacollector.get_model_vars_dataframe()['Fires']
    
    return fires_baseline.mean(), fires_treated.mean()
```

However, excessive thinning eliminates the natural fire cycles that maintain ecosystem health. The model helps identify the sweet spot balancing fire risk and ecological integrity.

### Climate Change Scenarios

Rising temperatures increase both ignition probability (drier fuels) and fire spread rates (faster combustion). We can simulate these changes:

```python
def climate_change_scenario(temperature_increase_celsius):
    """Model fire regime under climate warming"""
    
    # Empirical relationships (simplified)
    lightning_multiplier = 1 + 0.1 * temperature_increase_celsius
    spread_multiplier = 1 + 0.05 * temperature_increase_celsius
    
    model = ForestFireModel(
        lightning_rate=0.0001 * lightning_multiplier,
        fire_spread_rate=min(0.9, 0.7 * spread_multiplier)
    )
    
    return model
```

These scenarios reveal how correlated parameter changes create non-linear responses potentially pushing ecosystems beyond historical ranges of variability.

### Firebreak Design

The model illuminates optimal firebreak design by showing how barrier width affects fire connectivity:

```python
def add_firebreak(model, x_position, width):
    """Create a vertical firebreak by clearing trees"""
    for x in range(x_position, min(x_position + width, model.width)):
        for y in range(model.height):
            agent = model.grid.get_cell_list_contents((x, y))[0]
            agent.state = TreeState.EMPTY
```

Narrow firebreaks prove ineffective as ember transport and extreme fire behavior can jump gaps. Excessively wide breaks fragment habitat. Optimal design emerges from this trade-off.


## Applications and Policy Implications

### Forest Management Strategies

The model enables systematic evaluation of different management interventions by manipulating parameters that represent various management tools and strategies. Fuel reduction programs that decrease tree density effectively lower the probability of fire connectivity, potentially shifting the system below critical fire spread thresholds where large fires become rare events. However, the model also reveals potential unintended consequences, such as how excessive fuel reduction might eliminate the natural fire cycles that maintain ecosystem integrity.

Prescribed burning strategies can be evaluated by introducing controlled fires with specific spatial and temporal patterns. The model suggests that strategically timed and positioned prescribed fires can break up large fuel loads while maintaining overall forest structure, essentially mimicking the natural role of lightning strikes but with enhanced spatial and temporal control. The effectiveness of prescribed burning depends critically on timing relative to fuel accumulation cycles and spatial positioning relative to natural fire barriers.

Firebreaks and landscape fragmentation strategies create permanent empty cells that disrupt fire connectivity across the landscape. The model reveals that firebreak effectiveness depends on width relative to characteristic fire correlation lengths, with narrow firebreaks having minimal impact while excessively wide firebreaks may fragment habitat beyond acceptable ecological limits. Optimal firebreak design emerges as a balance between fire containment and habitat connectivity.

### Climate Change Adaptation

Parameter sensitivity analysis provides a framework for assessing how changing environmental conditions might alter fire regimes and inform adaptive management strategies. Increased drought conditions translate to higher lightning ignition probabilities and enhanced fire spread rates, shifting the system toward more frequent and intense fire cycles that may exceed historical ranges of variability.

Temperature increases affect multiple model parameters simultaneously by influencing both ignition probability through fuel desiccation and fire spread rates through enhanced combustion efficiency. The model enables exploration of how these correlated parameter changes interact to produce potentially non-linear responses in fire regime characteristics.

Precipitation changes influence growth rates and fuel moisture content, creating complex interactions between fuel accumulation and fire spread potential. The model suggests that moderate increases in growing season precipitation might enhance fuel loads while simultaneously reducing fire spread efficiency, creating competing effects whose net impact depends on the relative magnitude of parameter changes.

### Conservation Planning

The model provides insights into spatial patterns that promote biodiversity through intermediate disturbance mechanisms. Moderate fire frequencies create habitat heterogeneity by maintaining a mosaic of different-aged forest patches while preventing both complete forest loss and fire exclusion that leads to homogeneous mature forests.

Conservation planning applications can use the model to identify landscape configurations that maintain fire regime integrity while protecting critical habitats. The analysis reveals trade-offs between fire management objectives and conservation goals, helping planners develop strategies that balance multiple objectives across complex landscapes.

## Model Extensions and Future Directions

### Spatial Heterogeneity

The current model assumes uniform parameters across space, but real landscapes exhibit significant spatial variation in factors that influence fire behavior. Extensions incorporating topographic effects could represent how slope and aspect influence fire spread rates and directions, while fuel load variability could capture different vegetation types with distinct flammability characteristics.

Weather pattern extensions could introduce spatially and temporally varying wind, humidity, and temperature conditions that create realistic fire weather scenarios. These extensions would enable exploration of how synoptic weather patterns create correlated fire conditions across large regions, leading to widespread fire activity during extreme weather events.

### Multi-scale Dynamics

Hierarchical models could capture interactions between local fire behavior and landscape-scale patterns that operate over different temporal and spatial scales. Seed dispersal mechanisms could represent long-distance forest recovery following large fires, while regional fire weather systems could create correlations in fire activity across multiple landscapes.

Human impact extensions could incorporate road networks, urban interfaces, and fire suppression efforts that increasingly dominate fire regimes in many regions. These extensions would enable exploration of how human infrastructure and management activities interact with natural fire processes to create novel fire regimes.

### Stochastic Fire Spread

Rather than uniform fire spread probability, more realistic models could incorporate directional spread patterns driven by wind conditions and topographic effects. Variable fire intensity could represent how different fire temperatures affect vegetation recovery and soil properties, while ember transport could enable long-distance fire spread that creates complex spatial patterns.

These extensions would enhance model realism while maintaining computational efficiency and conceptual clarity. The challenge lies in balancing added complexity with interpretability and computational tractability.

## Limitations and Model Assumptions

### Temporal Resolution

The discrete time step approach assumes that all processes occur at similar temporal scales, which conflicts with the reality that fire spread occurs over hours or days while forest growth operates over years or decades. Multi-scale temporal approaches could address this limitation by implementing hierarchical time stepping or continuous-time formulations that better represent the natural separation of temporal scales.

### Spatial Resolution

The regular grid assumes uniform spatial discretization that may not capture fine-scale heterogeneity in fuel loads, moisture, or topography that critically influence real fire behavior. Adaptive spatial resolution or irregular spatial networks could provide more realistic representations of landscape heterogeneity while maintaining computational efficiency.

### Deterministic vs. Stochastic Elements

While the model includes stochastic elements for tree growth and ignition, fire spread remains purely probabilistic without incorporating the complex feedbacks between fire behavior, local weather, and fuel consumption that create deterministic elements within stochastic frameworks. Enhanced fire spread models could incorporate fire intensity effects, fuel depletion, and weather feedback mechanisms.

### Human Dimensions

The current model excludes human factors that increasingly dominate fire regimes in many regions, including fire suppression, anthropogenic ignition sources, land use patterns, and the wildland-urban interface. These human dimensions fundamentally alter fire regime characteristics and represent critical factors for contemporary fire management.

## Conclusion: Emergent Complexity from Simple Rules

The cellular automaton approach to forest fire modeling demonstrates how complex spatiotemporal patterns emerge from simple local interaction rules operating across spatial networks. Through the interplay of stochastic growth processes, probabilistic ignition, and deterministic fire spread, the model reproduces many qualitative features observed in real forest ecosystems, including patchy spatial patterns, quasi-periodic temporal dynamics, and critical behavior near phase transition boundaries.

For ecological research, the model provides a conceptual framework for understanding how local processes scale up to landscape-level patterns through emergent phenomena. The emergence of self-organized criticality suggests that forest ecosystems naturally evolve toward states that maximize information transfer and pattern formation, providing insight into fundamental principles governing ecological organization and resilience.

For forest management, the model offers practical tools for evaluating intervention strategies under different scenarios while revealing potential unintended consequences of management actions. The ability to manipulate parameters representing fuel loads, ignition sources, and fire spread rates enables systematic exploration of management trade-offs between fire suppression objectives and ecological integrity requirements.

For climate adaptation, the framework provides a foundation for assessing how changing environmental conditions might alter fire regimes and challenge existing management paradigms. By linking climate variables to model parameters, managers can explore potential futures and develop adaptive strategies that maintain ecosystem resilience under novel environmental conditions.

The model ultimately illustrates a fundamental principle of complex systems: sophisticated collective behaviors can arise from simple individual rules operating across networks of interacting agents. In the case of forest fire dynamics, the interaction between growth, death, and disturbance creates rich spatiotemporal patterns that mirror those observed in real ecosystems, despite the underlying simplicity of the cellular automaton framework.

As we face increasing challenges from climate change and altered fire regimes, computational models like this provide essential tools for understanding and managing complex ecological systems. The marriage of mathematical formalism with agent-based implementation creates a powerful approach for exploring how local actions aggregate into global patterns, a perspective essential for navigating the complex dynamics of our changing planet.

Understanding fire as an emergent phenomenon arising from simple local rules provides both humility about our ability to control complex natural systems and confidence in our capacity to understand the fundamental principles governing their behavior. In an era of unprecedented environmental change, such understanding becomes crucial for developing effective strategies that work with, rather than against, the inherent dynamics of ecological systems.

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
