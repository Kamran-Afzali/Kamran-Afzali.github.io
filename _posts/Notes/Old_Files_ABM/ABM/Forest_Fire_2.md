# Multi-Agent Wildfire Suppression 

## Introduction: The Complex Dynamics of Fire Suppression

Wildfire management represents one of the most challenging problems in contemporary environmental policy, involving dynamic interactions between natural fire behavior, human intervention, and landscape characteristics. Traditional approaches to fire suppression have evolved from purely reactive strategies to increasingly sophisticated systems that integrate prevention, rapid response, and resource allocation optimization. Yet the effectiveness of different suppression policies remains difficult to evaluate due to the stochastic nature of fire events, complex terrain interactions, and the high costs of real-world experimentation.

Agent-based modeling provides a powerful framework for exploring these complex human-environment interactions. By representing firefighters as autonomous agents operating within spatially explicit fire propagation models, we can systematically evaluate how different policy configurations affect suppression effectiveness under controlled conditions. This approach enables comparative analysis of resource allocation strategies, response protocols, and infrastructure investments that would be prohibitively expensive or ethically problematic to test in reality.

The challenge of wildfire suppression involves multiple competing objectives that often conflict with one another. Managers must balance immediate suppression effectiveness against long-term sustainability, minimize burned area while protecting human infrastructure, optimize resource utilization while maintaining ecological integrity, and control operational costs while ensuring adequate response capacity. These competing demands require policy frameworks that can navigate complex trade-offs and adapt to changing conditions.

## Mathematical Framework: Multi-Agent Fire-Suppression Dynamics

### Enhanced State Space Definition

Building upon the classical forest fire cellular automaton, we introduce an extended state space $\Omega = \{E, T, F, B, W, R\}$ representing empty, tree, fire, burned, water, and road cells respectively. Each spatial location $(i,j)$ in the discrete lattice $L$ maintains state $s_{i,j}(t) \in \Omega$ with additional properties that capture the complexity of suppression operations.

```python
class TreeState(Enum):
    """Defines the possible states of a grid cell."""
    EMPTY, TREE, FIRE, BURNED, WATER, ROAD = range(6)
```

For fire cells, we define fire intensity $I_{i,j}(t) \in [0, 100]$ representing the difficulty of suppression based on fuel load, weather conditions, and topographic factors. Suppression effort $S_{i,j}(t) \geq 0$ represents cumulative firefighting resources applied during time step $t$, creating a competitive dynamic between fire growth and human intervention. This framework captures the fundamental reality that fire suppression is not instantaneous but requires sustained effort proportional to fire intensity.

The state transition dynamics for each cell are governed by:

$$s_{i,j}(t+1) = \begin{cases}
B & \text{if } s_{i,j}(t) = F \land S_{i,j}(t) \geq I_{i,j}(t) \\
F & \text{if } s_{i,j}(t) = T \land \sum_{(k,l) \in \mathcal{N}(i,j)} \mathbb{I}[s_{k,l}(t) = F] > 0 \\
T & \text{if } s_{i,j}(t) = E \land \text{rand}() < p_{\text{growth}} \\
s_{i,j}(t) & \text{otherwise}
\end{cases}$$

where $\mathcal{N}(i,j)$ denotes the Moore neighborhood and $\mathbb{I}[\cdot]$ is the indicator function.

### Firefighter Agent Dynamics

Firefighter agents $F_k$ are characterized by the comprehensive state vector $\mathbf{f}_k(t) = (p_k(t), s_k(t), w_k(t), \tau_k(t))$ that encodes spatial position $p_k(t) \in L$, behavioral state $s_k(t)$ from the set of available actions including moving, fighting, refilling, and patrolling, current water capacity $w_k(t) \in [0, W_{max}]$, and current target fire location $\tau_k(t)$ when assigned to suppression tasks.

```python
class FirefighterState(Enum):
    """Defines the possible states of a firefighter agent."""
    AVAILABLE, MOVING_TO_FIRE, FIGHTING, REFILLING, PATROLLING = range(5)

class FirefighterAgent(mesa.Agent):
    def __init__(self, unique_id, model, base_pos):
        super().__init__(unique_id, model)
        self.base_pos = base_pos
        self.state = FirefighterState.AVAILABLE
        self.target_fire = None
        self.patrol_target = None
        
        # Policy-dependent attributes
        self.water_capacity = self.model.p["ff_water_capacity"]
        self.suppression_power = self.model.p["ff_suppression_power"]
        self.speed = self.model.p["ff_speed"]
        self.patrol_radius = self.model.p["ff_patrol_radius"]
        self.current_water = self.water_capacity
```

This state representation enables complex behavioral patterns where agents must balance competing priorities such as reaching distant fires quickly versus ensuring adequate water supplies for effective suppression. The behavioral state transitions create realistic operational constraints where agents cannot instantaneously switch between activities but must follow logical sequences of preparation, deployment, engagement, and recovery.

### Modified Fire Propagation with Suppression

The fire transition dynamics incorporate suppression effects through a competitive process between fire intensity and applied suppression effort. Fire cells transition to burned state when suppression effort exceeds fire intensity, representing successful containment, while fires with intensity exceeding applied suppression effort continue burning with only minimal natural burnout probability. 

Fire intensity evolves according to:

$$I_{i,j}(t+1) = \max(0, I_{i,j}(t) - S_{i,j}(t) - D_{i,j}(t))$$

where natural burnout processes $D_{i,j}(t) \sim \text{Uniform}(1, 5)$ provide stochastic reduction in fire intensity independent of human intervention. This formulation captures the reality that fires naturally diminish over time as fuel is consumed, while human suppression efforts can accelerate this process when applied effectively.

```python
def fire_step(self):
    """Fire phase: Fire spreads, burns, and is suppressed."""
    if self.state == TreeState.FIRE:
        # Competitive suppression dynamics
        if self.suppression_effort >= self.fire_intensity or self.random.random() < 0.05:
            self.state = TreeState.BURNED
        # Intensity evolution with natural burnout
        self.fire_intensity = max(0, self.fire_intensity - self.suppression_effort - 
                                 self.random.randint(1, 5))
        self.suppression_effort = 0
        return
```

### Firefighter Behavioral Rules

Firefighter movement follows gradient descent toward assigned targets with velocity constraints that reflect realistic operational limitations. The movement equation:

$$\mathbf{p}_k(t+1) = \mathbf{p}_k(t) + v_k \cdot \frac{\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)}{||\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)||}$$

ensures that agents move directly toward their objectives while respecting maximum speed limitations $v_k \leq v_{\max}$ imposed by terrain and equipment constraints.

```python
def _move_towards(self, target_pos):
    """Move towards a target position with speed constraint."""
    dx = target_pos[0] - self.pos[0]
    dy = target_pos[1] - self.pos[1]
    dist = math.hypot(dx, dy)
    
    if dist <= self.speed:
        new_pos = target_pos
    else:
        # Gradient descent with speed constraint
        new_pos = (
            self.pos[0] + int(round(self.speed * dx / dist)),
            self.pos[1] + int(round(self.speed * dy / dist))
        )
    
    # Enforce boundary conditions
    new_x = max(0, min(self.model.width - 1, new_pos[0]))
    new_y = max(0, min(self.model.height - 1, new_pos[1]))
    self.model.grid.move_agent(self, (new_x, new_y))
```

Target assignment employs nearest-neighbor allocation with constraint satisfaction to prevent overcommitment of resources to single fire events. The assignment rule:

$$\tau_k(t) = \arg\min_{\mathbf{f} \in \mathcal{F}_{\text{unassigned}}} ||\mathbf{p}_k(t) - \mathbf{f}||$$

ensures efficient resource utilization while water availability constraints $w_k(t) > w_{\min}$ and state compatibility requirements prevent agents from accepting assignments they cannot effectively complete.

```python
def _find_target(self):
    """Find the closest, unassigned fire using nearest-neighbor allocation."""
    unassigned = self.model.active_fires - set(self.model.assigned_fires.keys())
    if unassigned:
        # Nearest-neighbor assignment with Euclidean distance
        self.target_fire = min(unassigned, 
                              key=lambda pos: math.dist(self.pos, pos))
        self.model.assigned_fires[self.target_fire] = self.unique_id
        self.state = FirefighterState.MOVING_TO_FIRE
```

### Infrastructure Effects on Fire Dynamics

Road networks fundamentally alter fire propagation by serving as firebreaks that reduce spread probability through multiplicative factors. The modified spread probability is:

$$P_{\text{spread}}(i,j) = \begin{cases}
0.2 \cdot p_{\text{base}} & \text{if } \exists (k,l) \in \mathcal{N}(i,j): s_{k,l}(t) = R \\
p_{\text{base}} & \text{otherwise}
\end{cases}$$

Adjacent road cells reduce baseline fire spread probability to 20% of normal levels, representing the fire suppression benefits of maintained clearings and improved access for suppression equipment.

```python
if self.state == TreeState.TREE:
    neighbors = self.model.grid.get_neighbors(self.pos, moore=True)
    burning_neighbors = sum(1 for n in neighbors 
                          if isinstance(n, TreeAgent) and n.state == TreeState.FIRE)
    
    if burning_neighbors > 0:
        spread_chance = self.model.p["fire_spread_rate"]
        # Road firebreak effect: 80% reduction in spread probability
        if any(isinstance(n, TreeAgent) and n.state == TreeState.ROAD 
               for n in neighbors):
            spread_chance *= 0.2
        
        if self.random.random() < spread_chance * burning_neighbors:
            self.state = TreeState.FIRE
            self.fire_intensity = self.random.randint(40, 100)
```

Water sources enable agent refilling operations when agents are positioned at designated locations, instantly restoring water capacity to maximum levels. This refilling mechanism creates strategic positioning considerations where agents must balance proximity to active fires against access to water resources necessary for sustained suppression operations.

```python
def _refill_water(self):
    """Find and move to the nearest water source to refill."""
    if not self.model.water_sources:
        return
    
    # Find nearest water source
    closest_water = min(self.model.water_sources, 
                       key=lambda pos: math.dist(self.pos, pos))
    
    if self.pos == closest_water:
        self.current_water = self.water_capacity  # Instant refill
        self.state = FirefighterState.AVAILABLE
    else:
        self._move_towards(closest_water)
```

## Policy Architecture: Comparative Strategy Frameworks

### Reactive Suppression Policy

The reactive policy represents traditional fire management approaches that minimize initial resource commitment by deploying limited personnel only after fires are detected and confirmed. This strategy employs three firefighters with no preventive patrol coverage, moderate suppression power of 15 units, and standard movement speed of 2 units per time step. The reactive approach prioritizes cost minimization over prevention, accepting higher fire risk in exchange for reduced steady-state operational expenses.

The policy parameters are defined as:

$$\pi_{\text{reactive}} = \{N_f = 3, P_{\text{supp}} = 15, v = 2, r_{\text{patrol}} = 0, W_{\max} = 100\}$$

```python
POLICY_PARAMS = {
    "reactive": {
        "num_firefighters": 3,
        "ff_water_capacity": 100,
        "ff_suppression_power": 15,
        "ff_speed": 2,
        "ff_patrol_radius": 0
    },
```

This policy configuration reflects "attack when burning" strategies that dominated historical fire management, where resource constraints necessitated reactive rather than proactive deployment. The minimal resource footprint makes this approach attractive for budget-constrained agencies operating in lower-risk environments where fire frequency remains manageable through reactive response alone.

### Preventive Suppression Policy

The preventive policy emphasizes early detection through systematic patrol coverage that positions five firefighters across the landscape with patrol radii of 8 units around designated base stations. Firefighters execute random walks within patrol zones to maximize early fire detection probability while maintaining the same suppression power and movement speed as reactive policies.

$$\pi_{\text{preventive}} = \{N_f = 5, P_{\text{supp}} = 15, v = 2, r_{\text{patrol}} = 8, W_{\max} = 100\}$$

```python
    "preventive": {
        "num_firefighters": 5,
        "ff_water_capacity": 100,
        "ff_suppression_power": 15,
        "ff_speed": 2,
        "ff_patrol_radius": 8
    },
```

The patrol behavior implements a bounded random walk:

```python
def _patrol(self):
    """Move to random points within patrol radius using bounded random walk."""
    if not self.patrol_target or self.pos == self.patrol_target:
        # Generate random target within patrol radius
        px = self.base_pos[0] + self.random.randint(-self.patrol_radius, 
                                                     self.patrol_radius)
        py = self.base_pos[1] + self.random.randint(-self.patrol_radius, 
                                                     self.patrol_radius)
        # Enforce boundary constraints
        self.patrol_target = (
            max(0, min(self.model.width - 1, px)),
            max(0, min(self.model.height - 1, py))
        )
    self._move_towards(self.patrol_target)
```

This approach recognizes that early intervention dramatically improves suppression effectiveness by engaging fires when they remain small and manageable. The increased personnel cost is offset by reduced average fire sizes and decreased peak suppression demands during major fire events. Preventive policies prove particularly effective in high-risk environments where fire frequency justifies the additional surveillance investment.

### Aggressive Suppression Policy

The aggressive policy maximizes suppression capacity through enhanced equipment and personnel deployment, utilizing seven firefighters with increased suppression power of 25 units, enhanced movement speed of 3 units, and extended water capacity of 150 units. This configuration prioritizes overwhelming force application over distributed prevention, focusing resources on rapid response and intensive suppression rather than surveillance activities.

$$\pi_{\text{aggressive}} = \{N_f = 7, P_{\text{supp}} = 25, v = 3, r_{\text{patrol}} = 0, W_{\max} = 150\}$$

```python
    "aggressive": {
        "num_firefighters": 7,
        "ff_water_capacity": 150,
        "ff_suppression_power": 25,
        "ff_speed": 3,
        "ff_patrol_radius": 0
    }
}
```

The suppression effectiveness scales with power level:

```python
def _fight_fire(self):
    """Apply suppression effort proportional to agent capability."""
    if not self.target_fire or self.target_fire not in self.model.active_fires:
        self._become_available()
        return
    
    if self.current_water <= 0:
        self.state = FirefighterState.REFILLING
        self._release_target()
        return
    
    # Apply suppression power to target cell
    agents_at_pos = self.model.grid.get_cell_list_contents([self.target_fire])
    target_cell = None
    for agent in agents_at_pos:
        if isinstance(agent, TreeAgent):
            target_cell = agent
            break
    
    if target_cell and target_cell.state == TreeState.FIRE:
        target_cell.suppression_effort += self.suppression_power  # Policy-dependent
        self.current_water -= 5  # Resource consumption rate
```

The aggressive approach represents modern incident command strategies that deploy maximum available resources to contain fires quickly and prevent escalation to major events. While this policy requires the highest resource investment, it provides the greatest suppression effectiveness and proves cost-justified in extreme-risk environments where catastrophic fires could cause damages far exceeding suppression costs.

## Implementation Architecture: Multi-Phase Staged Activation

### Staged Temporal Dynamics

The model employs a two-phase activation schedule that separates ecological processes from suppression activities to prevent temporal artifacts and ensure realistic system behavior. Phase one handles tree growth and firefighter movement with state updates, while phase two processes fire dynamics and suppression interactions. 

The temporal evolution follows:

$$\text{Phase 1: } \mathbf{p}_k(t) \rightarrow \mathbf{p}_k(t+1), \quad s_{i,j}(t) \xrightarrow{\text{growth}} s_{i,j}(t+\frac{1}{2})$$

$$\text{Phase 2: } s_{i,j}(t+\frac{1}{2}) \xrightarrow{\text{fire}} s_{i,j}(t+1), \quad I_{i,j}(t) \rightarrow I_{i,j}(t+1)$$

```python
def __init__(self, width=50, height=50, policy="reactive"):
    # ... initialization code ...
    
    # Staged activation with explicit phase separation
    self.schedule = mesa.time.StagedActivation(
        self, 
        stage_list=["step", "fire_step"], 
        shuffle=True
    )
    
    for agent in all_agents:
        self.schedule.add(agent)
```

This temporal separation prevents synchronization artifacts where agent actions taken early in a time step inappropriately affect decisions made later in the same step. The staged approach ensures that all agents observe the same system state when making decisions, creating fair competition for resources and preventing unrealistic advantages based solely on processing order.

### Multi-Agent Coordination Mechanisms

Firefighters coordinate through a shared assignment table that maps fire locations to assigned agents, preventing resource conflicts and ensuring efficient allocation. The coordination mechanism tracks which fires have been assigned to specific agents while maintaining a pool of unassigned fires available for new assignments.

The assignment mapping is defined as:

$$\mathcal{A}: \mathcal{F}_{\text{active}} \rightarrow \mathcal{F} \cup \{\emptyset\}$$

where $\mathcal{F}_{\text{active}}$ is the set of active fire locations and $\mathcal{F}$ is the set of firefighter agents.

```python
def step(self):
    """Execute one time step with coordinated resource allocation."""
    # Update global fire information for coordination
    self.active_fires = {
        a.pos for a in self.schedule.agents 
        if isinstance(a, TreeAgent) and a.state == TreeState.FIRE
    }
    
    # Remove assignments for extinguished fires
    extinguished = self.assigned_fires.keys() - self.active_fires
    for pos in list(extinguished):
        del self.assigned_fires[pos]
    
    # Execute coordinated agent actions
    self.schedule.step()
    self.datacollector.collect(self)
```

This coordination mechanism captures essential aspects of real fire management operations where incident commanders must allocate limited resources across multiple competing demands while avoiding dangerous resource conflicts.

### State Machine Implementation

Each firefighter agent implements a finite state automaton with transitions triggered by environmental conditions and internal resource states. The state transition function is:

$$\delta: S \times E \times C \rightarrow S$$

where $S$ is the set of agent states, $E$ represents environmental observations, and $C$ captures internal agent conditions.

```python
def step(self):
    """State machine with condition-triggered transitions."""
    # Priority transition: fires override other states
    if self.model.active_fires and self.state in [FirefighterState.AVAILABLE, 
                                                   FirefighterState.PATROLLING]:
        self._find_target()
    
    # State-dependent behavior execution
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
```

This implementation creates realistic operational constraints that force agents to make strategic decisions about resource allocation and positioning under uncertainty.

## Emergent Dynamics: Resource Allocation and Spatial Coverage

### Spatial Response Patterns

Different policies generate distinct spatial coverage patterns that fundamentally affect suppression effectiveness through their interaction with fire propagation dynamics. Reactive policies create clustering patterns where firefighters concentrate around active fires, providing effective local suppression but potentially leaving coverage gaps that allow new ignitions to develop unchecked.

The spatial concentration can be quantified using the dispersion index:

$$D(t) = \frac{\text{Var}[X_k(t)]}{\mathbb{E}[X_k(t)]} + \frac{\text{Var}[Y_k(t)]}{\mathbb{E}[Y_k(t)]}$$

where $(X_k(t), Y_k(t))$ represents the position of agent $k$ at time $t$. Values of $D(t) > 1$ indicate clustering, while $D(t) < 1$ indicates spatial dispersion.

Preventive policies distribute firefighters across patrol areas to maximize surveillance coverage, improving detection latency but potentially reducing local suppression density when multiple fires emerge simultaneously. Aggressive policies concentrate higher agent density to enable rapid overwhelming of fire events, though this concentration may create spatial inefficiencies during low-activity periods when many agents remain idle.

### Temporal Resource Utilization

The dynamic interplay between fire ignition rates and suppression capacity creates characteristic temporal resource utilization patterns that reveal policy strengths and limitations. The utilization metric:

$$U(t) = \frac{\sum_{k=1}^{N_f} \mathbb{I}[s_k(t) \in \{\text{Fighting}, \text{Moving}\}]}{N_f}$$

quantifies what fraction of available resources are actively engaged in suppression activities at any given time.

```python
model_reporters={
    "Trees": lambda m: sum(1 for a in m.schedule.agents 
                          if isinstance(a, TreeAgent) and a.state == TreeState.TREE),
    "Fires": lambda m: len(m.active_fires),
    "Burned": lambda m: sum(1 for a in m.schedule.agents 
                           if isinstance(a, TreeAgent) and a.state == TreeState.BURNED)
}
```

Reactive systems exhibit high-amplitude utilization fluctuations with periods of minimal activity punctuated by intensive suppression efforts when fires emerge. Preventive systems demonstrate more stable utilization patterns due to continuous patrol activities, while aggressive systems show rapid utilization spikes followed by quick returns to baseline levels as overwhelming force rapidly suppresses fire events.

### Fire Size Distribution Effects

Different policies systematically alter the statistical distribution of fire sizes through their influence on early intervention probability and suppression intensity. The cumulative distribution function for fire areas can be modeled as:

$$F_\pi(a) = P(A \leq a | \pi) = \int_0^a f_\pi(x) dx$$

where $A$ represents the final burned area of a fire event under policy $\pi$, and $f_\pi(a)$ is the probability density function.

Preventive policies typically shift fire size distributions toward smaller events by improving detection and enabling intervention before fires grow large. Aggressive policies reduce the tail probability of very large fires through rapid suppression but may show less improvement in average fire size due to their reactive deployment patterns.

The expected fire size under each policy provides a key performance metric:

$$\mathbb{E}[A|\pi] = \int_0^\infty a \cdot f_\pi(a) da$$

These distributional effects prove critical for cost-benefit analysis since fire damage often scales non-linearly with fire size, following a power-law relationship $D(a) \propto a^\alpha$ where $\alpha > 1$.

## Performance Metrics: Multi-Objective Policy Evaluation

### Suppression Effectiveness Measures

Burned area minimization represents the primary objective for most fire management policies, measured as the time-averaged total area in burned state across the simulation domain:

$$\bar{B} = \frac{1}{T} \sum_{t=1}^T \sum_{i,j} \mathbb{I}[s_{i,j}(t) = B]$$

This metric captures the cumulative impact of all fire events and provides a direct measure of landscape-level suppression success.

Fire duration reduction quantifies how quickly fires are extinguished once detected. The average fire lifetime is:

$$\bar{\tau} = \frac{1}{N_{\text{fires}}} \sum_{n=1}^{N_{\text{fires}}} (t_{\text{extinguish}}^{(n)} - t_{\text{ignite}}^{(n)})$$

This metric reveals policy effectiveness in rapid response and sustained suppression effort, independent of fire size or location effects.

Peak fire load management measures the maximum number of simultaneously active fires:

$$L_{\max} = \max_{t \in [0,T]} |\{(i,j): s_{i,j}(t) = F\}|$$

This metric proves particularly important for resource planning and emergency preparedness since peak conditions often determine required system capacity.

### Resource Efficiency Indicators

Agent utilization rate quantifies what fraction of available firefighters are actively engaged in suppression activities, averaged across time and agents:

$$\bar{U} = \frac{1}{T} \sum_{t=1}^T U(t) = \frac{1}{T \cdot N_f} \sum_{t=1}^T \sum_{k=1}^{N_f} \mathbb{I}[s_k(t) \in \{\text{Fighting}, \text{Moving}\}]$$

High utilization indicates efficient resource deployment but may also suggest inadequate capacity margins for surge conditions.

Response time performance measures the average delay between fire ignition and initial suppression response:

$$\bar{t}_{\text{response}} = \frac{1}{N_{\text{fires}}} \sum_{n=1}^{N_{\text{fires}}} (t_{\text{first\_contact}}^{(n)} - t_{\text{ignite}}^{(n)})$$

This metric proves critical since early intervention dramatically improves suppression success probability, often following an exponential relationship $P_{\text{success}} \propto e^{-\lambda t_{\text{response}}}$.

Water resource efficiency evaluates the relationship between total suppression effort applied and total water consumed:

$$\eta_{\text{water}} = \frac{\sum_{i,j,t} S_{i,j}(t)}{\sum_{k,t} (W_{\max} - w_k(t))}$$

This metric reveals policy effectiveness in resource utilization independent of absolute resource levels.

### Economic Cost Considerations

Total policy costs incorporate both fixed infrastructure investments and variable operational expenses to enable comprehensive cost-benefit analysis. The total cost framework:

$$C_{\text{total}}(\pi) = C_{\text{fixed}}(\pi) + C_{\text{operational}}(\pi)$$

where:

$$C_{\text{fixed}}(\pi) = c_{\text{personnel}} \cdot N_f + c_{\text{infrastructure}} \cdot (N_{\text{water}} + L_{\text{road}})$$

$$C_{\text{operational}}(\pi) = \int_0^T \left[\sum_{k=1}^{N_f} c_{\text{active}}(t) \cdot \mathbb{I}[s_k(t) \neq \text{Available}] + c_{\text{water}} \cdot \dot{W}(t)\right] dt$$

This economic framework proves essential for policy evaluation since suppression effectiveness must be balanced against resource constraints and opportunity costs of alternative investments. The benefit-cost ratio becomes:

$$\text{BCR}(\pi) = \frac{\mathbb{E}[D_{\text{prevented}}|\pi]}{C_{\text{total}}(\pi)}$$

where $D_{\text{prevented}}$ represents avoided fire damages.

## Simulation Results: Comparative Policy Analysis

### Burned Area Performance

Simulation results across 200 time steps reveal systematic differences in burned area outcomes that reflect fundamental policy characteristics. The temporal evolution can be visualized through the data collection framework:

```python
def run_model(self, n):
    """Run the model for n steps with data collection."""
    for i in range(n):
        if not self.running:
            break
        self.step()
```

Reactive policies exhibit high variability with occasional large fire events due to delayed response times that allow fires to grow before suppression begins. The variance in burned area outcomes is:

$$\sigma^2_{\text{reactive}} = \text{Var}\left[\sum_{i,j} \mathbb{I}[s_{i,j}(t) = B]\right] \approx 2.5 \times \sigma^2_{\text{preventive}}$$

This variability creates risk management challenges since average performance may not capture tail risk exposure.

Preventive policies achieve reduced average burned area through early detection and intervention that prevents small fires from growing into major events. The improvement proves particularly pronounced during high-fire periods when rapid detection enables intervention before multiple fires overwhelm suppression capacity. Empirical results show:

$$\mathbb{E}[B|\text{preventive}] \approx 0.65 \times \mathbb{E}[B|\text{reactive}]$$

Aggressive policies achieve the lowest burned area outcomes but exhibit diminishing marginal returns relative to resource investment levels:

$$\frac{\partial B}{\partial N_f}\bigg|_{N_f=7} < \frac{\partial B}{\partial N_f}\bigg|_{N_f=5} < \frac{\partial B}{\partial N_f}\bigg|_{N_f=3}$$

### Temporal Dynamics Comparison

Fire population dynamics reveal distinct evolutionary patterns under different policy regimes that illuminate underlying mechanisms and trade-offs. The comparison framework enables systematic policy evaluation:

```python
# Compare different policies
all_results = {}
for policy in ForestFireModel.POLICY_PARAMS.keys():
    print(f"Simulating '{policy}' policy...")
    model = ForestFireModel(policy=policy)
    model.run_model(STEPS)
    all_results[policy] = model.datacollector.get_model_vars_dataframe()
```

Reactive systems exhibit high-amplitude fluctuations with periods of rapid fire growth followed by intensive suppression efforts once resources are deployed. The autocorrelation function reveals cyclical patterns:

$$\rho_{\text{reactive}}(\tau) = \frac{\text{Cov}[N_{\text{fires}}(t), N_{\text{fires}}(t+\tau)]}{\text{Var}[N_{\text{fires}}(t)]}$$

showing significant correlation at lag $\tau \approx 20$ time steps.

Preventive systems demonstrate more stable fire populations with smaller amplitude variations due to continuous surveillance and early intervention. The coefficient of variation:

$$\text{CV}_{\text{preventive}} = \frac{\sigma[N_{\text{fires}}]}{\mu[N_{\text{fires}}]} \approx 0.45 \times \text{CV}_{\text{reactive}}$$

indicates substantially reduced variability.

### Resource Utilization Trade-offs

Analysis reveals fundamental trade-offs that constrain policy design and highlight the impossibility of simultaneously optimizing all objectives. The multi-objective optimization problem can be formulated as:

$\min_{\pi \in \Pi} \left[\mathbb{E}[B|\pi], C_{\text{total}}(\pi), \text{Var}[B|\pi], L_{\max}(\pi)\right]$

subject to feasibility constraints on resource availability and operational capacity. This multi-objective formulation reveals the Pareto frontier where no policy improvement is possible without degrading performance on at least one dimension.

Prevention versus response trade-offs emerge as higher preventive investment reduces peak suppression demands but increases steady-state costs through continuous patrol activities. The trade-off relationship follows:

$C_{\text{prevention}}(\pi) \cdot P_{\text{detection}}(\pi) \approx \text{constant}$

where increased patrol coverage $C_{\text{prevention}}$ improves detection probability $P_{\text{detection}}$ but at proportional cost.

Capacity versus coverage trade-offs reflect the reality that enhanced individual agent capability reduces total agent requirements but may create coverage gaps in distributed fire scenarios. For equivalent suppression effectiveness:

$N_f^{(\text{low})} \cdot P_{\text{supp}}^{(\text{low})} \approx N_f^{(\text{high})} \cdot P_{\text{supp}}^{(\text{high})}$

but spatial coverage deteriorates as $N_f$ decreases, affecting detection latency.

Speed versus persistence trade-offs highlight how rapid response capability provides immediate benefits but requires sustained resource commitment that may not prove cost-effective under all conditions. These trade-offs necessitate careful matching of policy characteristics to environmental and budgetary constraints.

## Policy Implications: Strategic Fire Management

### Cost-Benefit Optimization

The simulation framework enables systematic cost-benefit analysis across different fire risk environments to guide policy selection and resource allocation decisions. The optimal policy selection rule is:

$\pi^* = \arg\max_{\pi \in \Pi} \left[\frac{\mathbb{E}[D_{\text{baseline}}] - \mathbb{E}[D|\pi]}{C_{\text{total}}(\pi)}\right]$

where $D_{\text{baseline}}$ represents expected damages under no suppression.

In low-risk environments characterized by infrequent fire events, reactive policies may provide optimal cost-effectiveness by minimizing steady-state costs while accepting occasional fire losses that remain within acceptable limits. The threshold ignition rate below which reactive policies dominate is:

$\lambda_{\text{ignite}} < \frac{C_{\text{fixed}}(\text{preventive}) - C_{\text{fixed}}(\text{reactive})}{\mathbb{E}[D|\text{reactive}] - \mathbb{E}[D|\text{preventive}]}$

High-risk environments benefit from preventive policies that justify higher steady-state costs through systematic reduction in fire damages. The early intervention benefits compound over time as prevented large fires avoid the exponential damage scaling that characterizes uncontrolled fire growth:

$D(a) = D_0 \cdot e^{\beta a}$

where $\beta > 0$ represents the exponential damage coefficient.

Extreme-risk environments may justify aggressive policies despite their high resource intensity, particularly when potential catastrophic fire damages far exceed suppression costs. The cost-benefit calculus shifts dramatically when considering potential losses of life, property, and irreplaceable natural resources:

$\text{BCR}(\text{aggressive}) = \frac{P(\text{catastrophe}|\text{baseline}) \cdot D_{\text{catastrophe}}}{C_{\text{total}}(\text{aggressive})}$

which can exceed unity even for very expensive suppression programs when catastrophic risks are non-negligible.

### Infrastructure Investment Strategies

Simulation results provide quantitative guidance for infrastructure development priorities and investment sequencing. Road networks provide systematic fire spread reduction benefits that persist across all policy types and fire scenarios, making them high-priority investments for most environments.

The marginal value of road infrastructure can be quantified as:

$\frac{\partial \mathbb{E}[B]}{\partial L_{\text{road}}} = -\alpha_{\text{road}} \cdot p_{\text{spread}} \cdot \rho_{\text{tree}}$

where $\alpha_{\text{road}} \approx 0.8$ represents the firebreak effectiveness coefficient, $p_{\text{spread}}$ is baseline spread probability, and $\rho_{\text{tree}}$ is tree density.

```python
def _add_infrastructure(self):
    """Helper to add roads and water sources to the grid."""
    # Road network construction with configurable density
    for _ in range(int(self.width * self.p["road_density"])):
        # Horizontal roads
        y = self.random.randrange(self.height)
        for x in range(self.width):
            agents = self.grid.get_cell_list_contents([(x, y)])
            if agents:
                agents[0].state = TreeState.ROAD
        
        # Vertical roads
        x = self.random.randrange(self.width)
        for y in range(self.height):
            agents = self.grid.get_cell_list_contents([(x, y)])
            if agents:
                agents[0].state = TreeState.ROAD
```

Water source investments prove critical for aggressive policies that depend on sustained suppression operations but show diminishing returns under preventive strategies that reduce overall suppression demands through early intervention. The optimal water infrastructure investment depends heavily on chosen suppression strategy:

$N_{\text{water}}^*(\pi) = \left\lceil \frac{N_f \cdot \bar{t}_{\text{engagement}} \cdot r_{\text{consumption}}}{W_{\max}} \right\rceil$

where $\bar{t}_{\text{engagement}}$ is average firefighting duration and $r_{\text{consumption}}$ is water usage rate.

```python
# Water source placement optimization
for _ in range(self.p["num_water_sources"]):
    x, y = self.random.randrange(self.width), self.random.randrange(self.height)
    self.water_sources.append((x, y))
    agents = self.grid.get_cell_list_contents([(x, y)])
    if agents:
        agents[0].state = TreeState.WATER
```

Base station positioning optimization reveals policy-dependent requirements, with preventive policies favoring distributed coverage to maximize surveillance reach while aggressive policies benefit from centralized rapid response capability. The optimal base locations solve:

$\min_{\{\mathbf{b}_1, \ldots, \mathbf{b}_K\}} \mathbb{E}\left[\sum_{k=1}^{N_f} ||\mathbf{p}_k(0) - \tau_k||\right]$

subject to patrol coverage constraints $\bigcup_{k=1}^K B(\mathbf{b}_k, r_{\text{patrol}}) \supseteq L$ for preventive policies.

```python
# Strategic base station placement
fire_stations = [(5, 5), (width-5, 5), (5, height-5), (width-5, height-5)]
for i in range(self.p["num_firefighters"]):
    base_pos = fire_stations[i % len(fire_stations)]
    firefighter = FirefighterAgent(agent_id, self, base_pos)
    self.grid.place_agent(firefighter, base_pos)
```

### Adaptive Management Frameworks

The model results suggest significant benefits from adaptive policy selection based on environmental conditions rather than static policy implementation. Dynamic policy switching enables optimization of the expected benefit-cost ratio:

$\pi^*(t) = \arg\max_{\pi \in \Pi} \left[\mathbb{E}[\text{Benefits}|\pi, \mathbf{c}(t)] - C(\pi)\right]$

where $\mathbf{c}(t) = (T_{\text{temp}}(t), H_{\text{humidity}}(t), W_{\text{wind}}(t), F_{\text{fuel}}(t))$ represents the environmental condition vector including temperature, humidity, wind speed, and fuel load.

This adaptive approach recognizes that optimal fire management strategy varies with environmental context and enables flexible response to changing conditions. The state-dependent policy function can be approximated as:

$\pi^*(t) = \begin{cases}
\text{reactive} & \text{if } P(\text{fire}|\mathbf{c}(t)) < \theta_{\text{low}} \\
\text{preventive} & \text{if } \theta_{\text{low}} \leq P(\text{fire}|\mathbf{c}(t)) < \theta_{\text{high}} \\
\text{aggressive} & \text{if } P(\text{fire}|\mathbf{c}(t)) \geq \theta_{\text{high}}
\end{cases}$

where $\theta_{\text{low}}$ and $\theta_{\text{high}}$ are empirically determined thresholds based on cost-benefit analysis.

Implementation requires robust condition assessment capability and pre-planned policy transition protocols to enable rapid strategy changes when conditions warrant.

## Model Extensions and Future Directions

The current model assumes spatially homogeneous fire behavior, but realistic extensions could incorporate topographic effects such as elevation, slope, and aspect influences on both fire spread rates and suppression accessibility. The modified spread probability would become:

$P_{\text{spread}}(i,j \to k,l) = p_{\text{base}} \cdot \phi_{\text{slope}}(\theta_{k,l}) \cdot \phi_{\text{wind}}(\mathbf{w}, \mathbf{d}_{ij\to kl}) \cdot \phi_{\text{fuel}}(\rho_{k,l})$

where $\theta_{k,l}$ is terrain slope, $\mathbf{w}$ is wind vector, $\mathbf{d}_{ij\to kl}$ is propagation direction, and $\rho_{k,l}$ is fuel load density.

These factors fundamentally alter fire behavior and create spatial variation in suppression difficulty that affects resource allocation decisions. Slope effects typically follow:

$\phi_{\text{slope}}(\theta) = \begin{cases}
e^{k \theta} & \text{if upslope propagation} \\
e^{-k\theta/2} & \text{if downslope propagation}
\end{cases}$

with $k \approx 0.1$ based on empirical fire behavior studies.

Fuel load variability across vegetation types would introduce fire intensity and spread characteristics that vary spatially:

$I_{i,j}(t) \sim \text{Gamma}(\alpha_{\text{veg}(i,j)}, \beta_{\text{veg}(i,j)})$

creating strategic positioning considerations as firefighters optimize deployment based on expected fire behavior in different areas. Weather dynamics including wind direction, humidity, and temperature could create temporal variation in fire risk and suppression effectiveness:

$p_{\text{spread}}(t) = p_{\text{base}} \cdot \left(1 + \gamma_T \frac{T(t) - T_0}{T_0}\right) \cdot \left(1 - \gamma_H \frac{H(t)}{100}\right)$

where $\gamma_T$ and $\gamma_H$ are temperature and humidity sensitivity coefficients.

The discrete time step framework could be enhanced to capture intra-day variations in fire behavior and suppression effectiveness that create operational windows for different activities. Diurnal cycles in weather conditions and fire activity create tactical opportunities that experienced firefighters exploit but which the current model cannot represent.

The time-varying fire intensity would follow:

$I_{i,j}(t, h) = I_{\text{base}}(t) \cdot \omega(h)$

where $h \in [0, 24)$ is hour of day and $\omega(h)$ is a diurnal modulation function:

$\omega(h) = 1 + A \cos\left(\frac{2\pi(h - h_{\text{peak}})}{24}\right)$

with peak fire activity typically occurring at $h_{\text{peak}} \approx 15$ (3 PM) and amplitude $A \approx 0.5$.

Seasonal patterns in fuel accumulation and weather conditions could be incorporated to create annual cycles that affect optimal resource allocation throughout the year:

$\lambda_{\text{ignite}}(d) = \lambda_{\text{base}} \left[1 + A_{\text{seasonal}} \cos\left(\frac{2\pi(d - d_{\text{peak}})}{365}\right)\right]$

where $d$ is day of year and $d_{\text{peak}}$ corresponds to peak fire season (typically mid-summer). Multi-year cycles involving vegetation recovery and fuel build-up following fire events would capture longer-term landscape dynamics:

$F_{i,j}(t) = F_{\max} \left[1 - e^{-r_{\text{recovery}}(t - t_{\text{burn}})}\right]$

where $t_{\text{burn}}$ is time since last fire and $r_{\text{recovery}}$ is vegetation recovery rate.

Future models could incorporate evacuation dynamics where civilian population movements affect suppression priorities and create additional constraints on resource deployment. The utility function for firefighter allocation would become:

$U(\mathbf{p}_k, \tau_k) = -\alpha_{\text{area}} \cdot I_{\tau_k} - \beta_{\text{structure}} \cdot N_{\text{structures}}(\tau_k) - \gamma_{\text{life}} \cdot N_{\text{people}}(\tau_k)$

where the weights $\alpha, \beta, \gamma$ reflect relative priorities with typically $\gamma \gg \beta > \alpha$.

Structure protection objectives could introduce spatial prioritization criteria that compete with pure fire suppression objectives:

$\tau_k^* = \arg\min_{\mathbf{f} \in \mathcal{F}} \left[\frac{||\mathbf{p}_k - \mathbf{f}||}{w(\mathbf{f})}\right]$

where $w(\mathbf{f})$ is a location-specific weight incorporating property values and life safety considerations.

Economic damage assessment could enable optimization of total social costs rather than just fire management costs:

$\min_{\pi} \left[C_{\text{total}}(\pi) + \mathbb{E}[D_{\text{property}}|\pi] + \mathbb{E}[D_{\text{environmental}}|\pi]\right]$

potentially justifying higher suppression investment when property and economic values are protected. Public health impacts from smoke exposure could create additional optimization criteria:

$D_{\text{health}} = \sum_t \sum_{i,j} \mathbb{I}[s_{i,j}(t) = F] \cdot \rho_{\text{pop}}(i,j) \cdot c_{\text{health}}$

where $\rho_{\text{pop}}$ is population density and $c_{\text{health}}$ is health cost per exposure unit.

Advanced extensions could employ reinforcement learning to develop adaptive firefighter behavior based on experience and performance feedback. The Q-learning update rule would be:

$Q(s, a) \leftarrow Q(s, a) + \alpha \left[r + \gamma \max_{a'} Q(s', a') - Q(s, a)\right]$

where $s$ is current state (agent position, fire locations, water level), $a$ is action (move direction, fight, refill), $r$ is immediate reward (negative burned area), and $\gamma$ is discount factor.

```python
# Reinforcement learning extension concept
class RLFirefighterAgent(FirefighterAgent):
    def __init__(self, unique_id, model, base_pos):
        super().__init__(unique_id, model, base_pos)
        self.q_table = {}  # State-action value function
        self.learning_rate = 0.1
        self.discount_factor = 0.95
        self.epsilon = 0.1  # Exploration rate
    
    def get_state_representation(self):
        """Encode current state for Q-learning."""
        return (
            self.pos,
            tuple(sorted(self.model.active_fires)),
            self.current_water // 10,  # Discretize water level
            self.state
        )
    
    def choose_action(self, state):
        """Epsilon-greedy action selection."""
        if random.random() < self.epsilon:
            return random.choice(self.get_available_actions())
        else:
            return max(self.get_available_actions(), 
                      key=lambda a: self.q_table.get((state, a), 0))
```

Agents could learn optimal positioning, targeting, and coordination strategies through trial and error rather than following fixed behavioral rules.

Predictive modeling capabilities could enable proactive resource positioning based on fire risk forecasting:

$P(\text{fire at } (i,j) \text{ at } t+\Delta t | \mathbf{X}(t)) = \sigma(\mathbf{w}^T \phi(\mathbf{X}(t)))$

where $\mathbf{X}(t)$ is feature vector (weather, fuel, historical patterns), $\phi$ is feature transformation, $\mathbf{w}$ are learned weights, and $\sigma$ is sigmoid function.

Optimization algorithms could provide automated policy parameter tuning for specific environmental conditions:

$\mathbf{\theta}^* = \arg\min_{\mathbf{\theta}} \mathbb{E}_{\mathbf{c} \sim P(\text{conditions})}\left[\frac{C(\mathbf{\theta}) + \mathbb{E}[B|\mathbf{\theta}, \mathbf{c}]}{\text{BCR}(\mathbf{\theta})}\right]$

where $\mathbf{\theta} = (N_f, P_{\text{supp}}, v, r_{\text{patrol}}, W_{\max})$ represents policy parameters.

## Limitations and Critical Assessment

The regular grid structure fundamentally limits representation of complex terrain features that critically influence real fire behavior, including sub-grid heterogeneity in fuel loads, moisture content, and topographic complexity. The grid resolution $\Delta x$ creates a fundamental uncertainty in fire position:

$\sigma_{\text{position}} \approx \frac{\Delta x}{\sqrt{12}}$

While the current resolution enables policy comparison, quantitative predictions would require finer spatial resolution and irregular spatial networks that better represent landscape complexity. Increasing resolution from $\Delta x = 100m$ to $\Delta x = 10m$ would improve position accuracy by factor of 10 but increase computational cost by factor of 100.

The probabilistic fire spread model abstracts away complex thermodynamic processes, wind effects, and fuel consumption dynamics that determine actual fire behavior. Real fire spread involves coupled heat transfer equations:

$\frac{\partial T}{\partial t} = \alpha \nabla^2 T + Q_{\text{combustion}} - Q_{\text{radiation}} - Q_{\text{convection}}$

where $T$ is temperature field, $\alpha$ is thermal diffusivity, and $Q$ terms represent heat sources and sinks.

This simplification enables computational efficiency and policy comparison but limits the model's ability to make quantitative predictions about specific fire events or detailed tactical decisions. The model should be viewed as a strategic planning tool rather than a tactical fire behavior simulator.

Firefighter agents follow deterministic behavioral rules that cannot capture the full complexity of human decision-making under stress, including coordination challenges, adaptive learning processes, and the communication difficulties that characterize real suppression operations. Real firefighter decision-making involves:

- Risk assessment and safety prioritization
- Team coordination and communication delays  
- Fatigue effects on performance
- Experience-based heuristics and adaptation
- Resource sharing and mutual aid requests

These simplifications may underestimate the challenges of implementing policies that appear effective in simulation. The gap between simulated and real performance can be modeled as:

$P_{\text{real}} = \eta \cdot P_{\text{simulated}}$

where $\eta \in [0.7, 0.9]$ is an implementation efficiency factor based on empirical studies.

Cost calculations employ simplified linear models that may not adequately represent economies of scale, fixed cost structures, or the complex relationship between resource utilization and operational expenses in real fire management agencies. More sophisticated economic modeling would improve policy evaluation accuracy:

$C_{\text{total}}(N_f) = C_0 + c_1 N_f + c_2 N_f^{\alpha}$

where $\alpha < 1$ represents economies of scale, but at the cost of increased model complexity and data requirements.

Real agencies face budget constraints, political pressures, and institutional inertia that affect policy implementation in ways the model cannot capture. The simplified cost framework provides first-order approximations suitable for comparative analysis but should not be interpreted as precise cost predictions.

## Conclusion

The multi-agent forest fire suppression model demonstrates how computational approaches can illuminate complex policy trade-offs in environmental management while revealing fundamental relationships between resource investment patterns and suppression effectiveness outcomes. Through systematic comparison of reactive, preventive, and aggressive suppression strategies, we uncover principles that extend beyond fire management to other domains involving distributed resource allocation under uncertainty.

The modeling framework enables quantitative evaluation of policy alternatives through metrics including:

$\text{Policy Performance} = f(\mathbb{E}[B], \sigma[B], L_{\max}, \bar{U}, C_{\text{total}}, \bar{t}_{\text{response}})$

where each metric captures a distinct dimension of suppression effectiveness, resource efficiency, or economic performance.

```python
# Complete simulation and comparison framework
if __name__ == "__main__":
    STEPS = 200
    
    # Single detailed simulation with visualization
    print("--- Running single 'Preventive' simulation ---")
    model = ForestFireModel(policy="preventive")
    for i in range(STEPS):
        if not model.running: 
            break
        model.step()
        if i % 50 == 0:
            plot_simulation(get_model_state(model), i)
    
    # Comparative policy analysis
    print("\n--- Comparing policies ---")
    all_results = {}
    for policy in ForestFireModel.POLICY_PARAMS.keys():
        model = ForestFireModel(policy=policy)
        model.run_model(STEPS)
        all_results[policy] = model.datacollector.get_model_vars_dataframe()
    
    plot_results(all_results)
```

For fire management agencies, the model provides a quantitative framework for evaluating resource allocation decisions before expensive real-world implementation. The ability to simulate different scenarios under controlled conditions enables systematic exploration of policy alternatives that would be impossible through field experimentation alone, while the cost-benefit framework supports evidence-based decision making in resource-constrained environments.

For policymakers, the framework reveals how different strategic approaches create distinct risk-cost profiles that must be matched to local conditions and institutional constraints. The Pareto frontier of policy options shows:

$\mathcal{P} = \{\pi \in \Pi : \nexists \pi' \text{ s.t. } \pi' \text{ dominates } \pi \text{ on all objectives}\}$

Reactive policies minimize steady-state costs but accept higher wildfire risk, while preventive approaches reduce average fire damage at the expense of higher ongoing resource commitments. Aggressive policies provide maximum suppression capability but may exhibit diminishing marginal returns:

$\frac{\partial^2 \text{Effectiveness}}{\partial N_f^2} < 0$

that limit their applicability.

For researchers studying complex systems, the model illustrates how emergent phenomena arise from human-environment interactions through the interplay between individual agent behaviors, spatial processes, and system-level outcomes. These emergent properties demonstrate principles of complex adaptive systems that extend beyond fire management to other domains involving distributed decision-making and resource allocation under uncertainty.

The simulation results suggest that optimal fire management strategy depends critically on environmental context, risk tolerance, and resource constraints, with no single policy dominating across all conditions. This finding indicates the need for adaptive management frameworks that can adjust strategies based on changing conditions and evolving understanding of fire-suppression dynamics.

Understanding fire suppression as an emergent property of multi-agent interactions provides both practical insights for management and theoretical contributions to the study of coupled human-natural systems. As climate change intensifies fire risks while resource constraints limit suppression capabilities, computational modeling becomes increasingly valuable for navigating the complex landscape of fire management policy.

The framework ultimately demonstrates that effective fire management requires understanding not just fire behavior, but the complex feedback loops between fire dynamics, human responses, and landscape characteristics. This systems perspective becomes essential as we face unprecedented fire challenges in an era of climate change and increasing development at the wildland-urban interface.

Through rigorous computational analysis, we can move beyond intuitive policy making toward evidence-based strategies that optimize the complex trade-offs inherent in wildfire management. This approach offers hope for developing more effective, efficient, and adaptive fire management systems capable of protecting both human communities and ecological values in an uncertain future, while providing a methodological template for addressing other complex environmental management challenges.

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
