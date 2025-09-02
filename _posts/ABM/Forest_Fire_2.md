# Multi-Agent Wildfire Suppression: Policy Analysis Through Spatially-Explicit Fire Management Models

*Evaluating firefighting strategies through computational modeling of human-fire-landscape interactions*

## Introduction: The Complex Dynamics of Fire Suppression

Wildfire management represents one of the most challenging problems in contemporary environmental policy, involving dynamic interactions between natural fire behavior, human intervention, and landscape characteristics. Traditional approaches to fire suppression have evolved from purely reactive strategies to increasingly sophisticated systems that integrate prevention, rapid response, and resource allocation optimization. Yet the effectiveness of different suppression policies remains difficult to evaluate due to the stochastic nature of fire events, complex terrain interactions, and the high costs of real-world experimentation.

Agent-based modeling provides a powerful framework for exploring these complex human-environment interactions. By representing firefighters as autonomous agents operating within spatially explicit fire propagation models, we can systematically evaluate how different policy configurations affect suppression effectiveness under controlled conditions. This approach enables comparative analysis of resource allocation strategies, response protocols, and infrastructure investments that would be prohibitively expensive or ethically problematic to test in reality.

The challenge of wildfire suppression involves multiple competing objectives: minimizing burned area, protecting human infrastructure, optimizing resource utilization, and maintaining ecological integrity. These objectives often conflict, requiring policy frameworks that balance immediate suppression effectiveness with long-term sustainability and cost considerations.

## Mathematical Framework: Multi-Agent Fire-Suppression Dynamics

### Enhanced State Space Definition

Building upon the classical forest fire cellular automaton, we introduce an extended state space $\Omega = \{E, T, F, B, W, R\}$ representing empty, tree, fire, burned, water, and road cells respectively. Each spatial location $(i,j)$ in the discrete lattice $L$ maintains state $s_{i,j}(t) \in \Omega$ with additional properties:

For fire cells, we define **fire intensity** $I_{i,j}(t) \in [0, 100]$ representing the difficulty of suppression, and **suppression effort** $S_{i,j}(t) \geq 0$ representing cumulative firefighting resources applied during time step $t$.

### Firefighter Agent Dynamics

Firefighter agents $F_k$ are characterized by the state vector:

$$\mathbf{f}_k(t) = (p_k(t), s_k(t), w_k(t), \tau_k(t))$$

where:
- $p_k(t) \in L$ represents spatial position
- $s_k(t) \in \{Available, Moving, Fighting, Refilling, Patrolling\}$ represents behavioral state  
- $w_k(t) \in [0, W_{max}]$ represents current water capacity
- $\tau_k(t)$ represents current target fire location (if any)

### Modified Fire Propagation with Suppression

The fire transition dynamics incorporate suppression effects through a competitive process between fire intensity and applied suppression effort:

$$P(s_{i,j}(t+1) = B | s_{i,j}(t) = F) = \begin{cases}
1 & \text{if } S_{i,j}(t) \geq I_{i,j}(t) \\
0.05 & \text{if } S_{i,j}(t) < I_{i,j}(t) \\
1 & \text{if } I_{i,j}(t) \leq \epsilon
\end{cases}$$

Fire intensity evolves according to:

$$I_{i,j}(t+1) = \max(0, I_{i,j}(t) - S_{i,j}(t) - D_{i,j}(t))$$

where $D_{i,j}(t) \sim \text{Uniform}(1, 5)$ represents natural burnout processes.

### Firefighter Behavioral Rules

Firefighter movement follows gradient descent toward assigned targets:

$$\mathbf{p}_k(t+1) = \mathbf{p}_k(t) + v_k \cdot \frac{\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)}{||\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)||}$$

where $v_k$ represents the agent's movement speed.

Target assignment uses nearest-neighbor allocation with constraint satisfaction:

$$\tau_k(t) = \arg\min_{\mathbf{f} \in \mathcal{F}_{unassigned}} ||\mathbf{p}_k(t) - \mathbf{f}||$$

subject to water availability $w_k(t) > w_{min}$ and state compatibility.

### Infrastructure Effects on Fire Dynamics

Road cells modify fire spread probability through a multiplicative factor:

$$P(s_{i,j}(t+1) = F | s_{i,j}(t) = T, \text{road adjacent}) = 0.2 \cdot P_{baseline}$$

Water sources enable agent refilling when $||\mathbf{p}_k(t) - \mathbf{w}_j|| = 0$:

$$w_k(t+1) = W_{max} \text{ if positioned at water source}$$

## Policy Architecture: Comparative Strategy Frameworks

### Reactive Suppression Policy

The reactive policy minimizes initial resource commitment, deploying limited personnel only after fires are detected:

**Parameter Configuration**:
- Firefighter count: $N_f = 3$
- Patrol radius: $R_p = 0$ (no preventive patrol)  
- Suppression power: $P_s = 15$
- Movement speed: $v = 2$

This represents traditional "attack when burning" strategies that prioritize cost minimization over prevention.

### Preventive Suppression Policy  

The preventive policy emphasizes early detection through systematic patrol coverage:

**Parameter Configuration**:
- Firefighter count: $N_f = 5$
- Patrol radius: $R_p = 8$ (wide-area surveillance)
- Suppression power: $P_s = 15$ 
- Movement speed: $v = 2$

Firefighters execute random walks within patrol zones $B(b_k, R_p)$ centered on base stations $b_k$, maximizing early fire detection probability.

### Aggressive Suppression Policy

The aggressive policy maximizes suppression capacity through enhanced equipment and personnel:

**Parameter Configuration**:
- Firefighter count: $N_f = 7$
- Patrol radius: $R_p = 0$ (rapid response focus)
- Suppression power: $P_s = 25$ (enhanced capability)
- Movement speed: $v = 3$ (faster deployment)
- Water capacity: $W_{max} = 150$ (extended operational duration)

This approach prioritizes overwhelming force application over distributed prevention.

## Implementation Architecture: Multi-Phase Staged Activation

### Staged Temporal Dynamics

The model employs a two-phase activation schedule that separates ecological processes from suppression activities:

**Phase 1: Growth and Agent Positioning**
```python
def step(self):
    # Tree growth and firefighter movement/state updates
    if self.state == TreeState.EMPTY:
        if random.random() < self.model.p["growth_rate"]:
            self.state = TreeState.TREE
```

**Phase 2: Fire Dynamics and Suppression**
```python
def fire_step(self):
    # Fire spread, suppression application, intensity updates
    if self.state == TreeState.FIRE:
        if self.suppression_effort >= self.fire_intensity:
            self.state = TreeState.BURNED
```

This temporal separation prevents synchronization artifacts where agent actions taken early in a time step affect decisions made later in the same step.

### Multi-Agent Coordination Mechanisms

Firefighters coordinate through a shared assignment table $A: \mathcal{F} \rightarrow \mathcal{A}$ that maps fire locations to assigned agents, preventing resource conflicts:

```python
def _find_target(self):
    unassigned = self.model.active_fires - set(self.model.assigned_fires.keys())
    if unassigned:
        self.target_fire = min(unassigned, key=lambda pos: math.dist(self.pos, pos))
        self.model.assigned_fires[self.target_fire] = self.unique_id
```

### State Machine Implementation

Each firefighter agent implements a finite state automaton with transitions triggered by environmental conditions and internal resource states:

$$\delta: S \times \Gamma \rightarrow S$$

where $S$ represents the behavioral state space and $\Gamma$ represents the observation space including fire locations, water levels, and position information.

## Emergent Dynamics: Resource Allocation and Spatial Coverage

### Spatial Response Patterns

Different policies generate distinct spatial coverage patterns that affect suppression effectiveness:

**Reactive Clustering**: Firefighters concentrate around active fires, creating effective local suppression but potential coverage gaps for new ignitions.

**Preventive Distribution**: Patrol patterns create distributed surveillance coverage, improving detection latency but potentially reducing local suppression density.

**Aggressive Concentration**: Higher agent density enables rapid overwhelming of fire events but may create spatial inefficiencies during low-activity periods.

### Temporal Resource Utilization

The dynamic interplay between fire ignition rates and suppression capacity creates temporal resource utilization patterns:

$$U(t) = \frac{\sum_k \mathbb{I}[s_k(t) \in \{Fighting, Moving\}]}{N_f}$$

This utilization metric reveals policy effectiveness under varying fire pressure.

### Fire Size Distribution Effects

Different policies alter the statistical distribution of fire sizes through early intervention mechanisms. The cumulative distribution function for fire sizes under policy $\pi$ becomes:

$$F_\pi(A) = P(\text{Fire Area} \leq A | \text{Policy } \pi)$$

Preventive policies typically shift this distribution toward smaller fire sizes through improved detection, while aggressive policies reduce the tail probability of large fires through rapid suppression.

## Performance Metrics: Multi-Objective Policy Evaluation

### Suppression Effectiveness Measures

**Burned Area Minimization**:
$$E_{burned}(\pi) = \frac{1}{T} \sum_{t=1}^T |\{(i,j) : s_{i,j}(t) = B\}|$$

**Fire Duration Reduction**:
$$E_{duration}(\pi) = \frac{1}{|\mathcal{F}|} \sum_{f \in \mathcal{F}} (t_{extinguish}^f - t_{ignite}^f)$$

**Peak Fire Load Management**:
$$E_{peak}(\pi) = \max_t |\{(i,j) : s_{i,j}(t) = F\}|$$

### Resource Efficiency Indicators

**Agent Utilization Rate**:
$$\eta_{utilization}(\pi) = \frac{1}{T \cdot N_f} \sum_{t=1}^T \sum_{k=1}^{N_f} \mathbb{I}[s_k(t) = Fighting]$$

**Response Time Performance**:
$$\eta_{response}(\pi) = \frac{1}{|\mathcal{F}|} \sum_{f \in \mathcal{F}} (t_{assignment}^f - t_{ignite}^f)$$

**Water Resource Efficiency**:
$$\eta_{water}(\pi) = \frac{\text{Total Suppression Applied}}{\text{Total Water Consumed}}$$

### Economic Cost Considerations

Total policy cost incorporates both fixed infrastructure investments and variable operational expenses:

$$C_{total}(\pi) = C_{fixed}(\pi) + C_{operational}(\pi)$$

where:
$$C_{fixed}(\pi) = N_f \cdot c_{agent} + N_w \cdot c_{water} + L_r \cdot c_{road}$$

$$C_{operational}(\pi) = T \cdot (N_f \cdot c_{maintenance} + \overline{U}(\pi) \cdot c_{deployment})$$

## Simulation Results: Comparative Policy Analysis

### Burned Area Performance

Simulation results across 200 time steps reveal systematic differences in burned area outcomes:

- **Reactive Policy**: High variability with occasional large fire events due to delayed response
- **Preventive Policy**: Reduced average burned area through early detection and intervention  
- **Aggressive Policy**: Lowest burned area but with diminishing marginal returns relative to resource investment

### Temporal Dynamics Comparison

Fire population dynamics show distinct patterns under different policies:

**Reactive Systems** exhibit high-amplitude fluctuations with periods of rapid fire growth followed by intensive suppression efforts.

**Preventive Systems** demonstrate more stable fire populations with smaller amplitude variations due to continuous surveillance.

**Aggressive Systems** show rapid fire suppression with minimal persistence of active fires but higher baseline resource consumption.

### Resource Utilization Trade-offs

Analysis reveals fundamental trade-offs between resource investment and performance outcomes:

1. **Prevention vs. Response**: Higher preventive investment reduces peak suppression demands but increases steady-state costs

2. **Capacity vs. Coverage**: Enhanced individual agent capability reduces total agent requirements but may create coverage gaps

3. **Speed vs. Persistence**: Rapid response capability provides immediate benefits but requires sustained resource commitment

## Policy Implications: Strategic Fire Management

### Cost-Benefit Optimization

The simulation framework enables systematic cost-benefit analysis across different fire risk environments:

**Low-Risk Environments**: Reactive policies may provide optimal cost-effectiveness due to infrequent fire events.

**High-Risk Environments**: Preventive policies demonstrate superior performance through early intervention benefits.

**Extreme-Risk Environments**: Aggressive policies become cost-justified due to catastrophic fire potential.

### Infrastructure Investment Strategies

Simulation results inform infrastructure development priorities:

**Road Networks**: Provide systematic fire spread reduction with persistent benefits across all policy types.

**Water Sources**: Critical for aggressive policies but show diminishing returns under preventive strategies due to reduced suppression demands.

**Base Station Positioning**: Optimal locations depend on policy type, with preventive policies favoring distributed coverage and aggressive policies favoring centralized rapid response.

### Adaptive Management Frameworks

The model suggests benefits from adaptive policy selection based on environmental conditions:

$$\pi^*(t) = \arg\max_{\pi \in \Pi} \left[ E[\text{Benefits}|\pi, \text{conditions}(t)] - C(\pi) \right]$$

This framework enables dynamic switching between policies based on seasonal fire risk, weather conditions, and resource availability.

## Model Extensions and Future Directions

### Environmental Heterogeneity

Current model assumes spatially homogeneous fire behavior, but realistic extensions could incorporate:

- **Topographic Effects**: Elevation, slope, and aspect influences on fire spread rates and suppression accessibility
- **Fuel Load Variability**: Vegetation type-specific fire intensity and spread characteristics  
- **Weather Dynamics**: Wind direction, humidity, and temperature effects on fire behavior

### Multi-Scale Temporal Dynamics

The discrete time step framework could be enhanced to capture:

- **Intra-Day Variations**: Diurnal cycles in fire behavior and suppression effectiveness
- **Seasonal Patterns**: Long-term fuel accumulation and weather pattern effects
- **Multi-Year Cycles**: Vegetation recovery and fuel build-up following fire events

### Human Dimension Integration

Future models could incorporate:

- **Evacuation Dynamics**: Civilian population movements affecting suppression priorities
- **Economic Damage Assessment**: Structure protection and economic loss minimization objectives
- **Public Health Impacts**: Smoke exposure and air quality considerations

### Machine Learning Integration

Advanced extensions could employ:

- **Reinforcement Learning**: Adaptive firefighter behavior based on experience and performance feedback
- **Predictive Modeling**: Fire risk forecasting to enable proactive resource positioning
- **Optimization Algorithms**: Automated policy parameter tuning for specific environmental conditions

## Limitations and Critical Assessment

### Spatial Resolution Constraints

The regular grid structure limits representation of complex terrain features that critically influence real fire behavior. Sub-grid heterogeneity in fuel loads, moisture content, and topographic complexity cannot be captured at the current resolution.

### Simplified Fire Physics

The probabilistic fire spread model abstracts away complex thermodynamic processes, wind effects, and fuel consumption dynamics that determine actual fire behavior. While suitable for policy comparison, quantitative predictions require more sophisticated fire physics models.

### Human Behavior Simplification

Firefighter agents follow deterministic behavioral rules that may not capture the complexity of human decision-making under stress, coordination challenges, or adaptive learning processes that occur in real suppression operations.

### Economic Model Limitations

Cost calculations employ simplified linear models that may not capture economies of scale, fixed cost structures, or the complex relationship between resource utilization and operational expenses in real fire management agencies.

## Conclusion: Computational Policy Analysis for Fire Management

The multi-agent forest fire suppression model demonstrates how computational approaches can illuminate complex policy trade-offs in environmental management. Through systematic comparison of reactive, preventive, and aggressive suppression strategies, we reveal fundamental relationships between resource investment patterns and suppression effectiveness outcomes.

**For fire management agencies**, the model provides a quantitative framework for evaluating resource allocation decisions before expensive real-world implementation. The ability to simulate different scenarios under controlled conditions enables systematic exploration of policy space that would be impossible through field experimentation alone.

**For policymakers**, the framework reveals how different strategic approaches create distinct risk-cost profiles. Reactive policies minimize steady-state costs but accept higher wildfire risk, while preventive approaches reduce average fire damage at the expense of higher ongoing resource commitments. Aggressive policies provide maximum suppression capability but may exhibit diminishing marginal returns.

**For researchers**, the model illustrates how complex systems approaches can capture emergent phenomena arising from human-environment interactions. The interplay between individual agent behaviors, spatial processes, and system-level outcomes demonstrates principles of complex adaptive systems that extend beyond fire management to other domains involving distributed decision-making and resource allocation.

The simulation results suggest that optimal fire management strategy depends critically on environmental context, risk tolerance, and resource constraints. No single policy dominates across all conditions, indicating the need for adaptive management frameworks that can adjust strategies based on changing conditions and evolving understanding of fire-suppression dynamics.

Understanding fire suppression as an emergent property of multi-agent interactions provides both practical insights for management and theoretical contributions to the study of coupled human-natural systems. As climate change intensifies fire risks and resource constraints limit suppression capabilities, computational modeling becomes increasingly valuable for navigating the complex landscape of fire management policy.

The framework ultimately demonstrates that effective fire management requires understanding not just fire behavior, but the complex feedback loops between fire dynamics, human responses, and landscape characteristics. This systems perspective becomes essential as we face unprecedented fire challenges in an era of climate change and increasing human-wildland interface development.

Through rigorous computational analysis, we can move beyond intuitive policy making toward evidence-based strategies that optimize the complex trade-offs inherent in wildfire management. This approach offers hope for developing more effective, efficient, and adaptive fire management systems capable of protecting both human communities and ecological values in an uncertain future.


```python
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
```
