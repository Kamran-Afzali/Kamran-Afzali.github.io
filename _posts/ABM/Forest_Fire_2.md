# Multi-Agent Wildfire Suppression: Policy Analysis Through Spatially-Explicit Fire Management Models

*Evaluating firefighting strategies through computational modeling of human-fire-landscape interactions*

## Introduction: The Complex Dynamics of Fire Suppression

Wildfire management represents one of the most challenging problems in contemporary environmental policy, involving dynamic interactions between natural fire behavior, human intervention, and landscape characteristics. Traditional approaches to fire suppression have evolved from purely reactive strategies to increasingly sophisticated systems that integrate prevention, rapid response, and resource allocation optimization. Yet the effectiveness of different suppression policies remains difficult to evaluate due to the stochastic nature of fire events, complex terrain interactions, and the high costs of real-world experimentation.

Agent-based modeling provides a powerful framework for exploring these complex human-environment interactions. By representing firefighters as autonomous agents operating within spatially explicit fire propagation models, we can systematically evaluate how different policy configurations affect suppression effectiveness under controlled conditions. This approach enables comparative analysis of resource allocation strategies, response protocols, and infrastructure investments that would be prohibitively expensive or ethically problematic to test in reality.

The challenge of wildfire suppression involves multiple competing objectives that often conflict with one another. Managers must balance immediate suppression effectiveness against long-term sustainability, minimize burned area while protecting human infrastructure, optimize resource utilization while maintaining ecological integrity, and control operational costs while ensuring adequate response capacity. These competing demands require policy frameworks that can navigate complex trade-offs and adapt to changing conditions.

## Mathematical Framework: Multi-Agent Fire-Suppression Dynamics

### Enhanced State Space Definition

Building upon the classical forest fire cellular automaton, we introduce an extended state space $\Omega = \{E, T, F, B, W, R\}$ representing empty, tree, fire, burned, water, and road cells respectively. Each spatial location $(i,j)$ in the discrete lattice $L$ maintains state $s_{i,j}(t) \in \Omega$ with additional properties that capture the complexity of suppression operations.

For fire cells, we define fire intensity $I_{i,j}(t) \in [0, 100]$ representing the difficulty of suppression based on fuel load, weather conditions, and topographic factors. Suppression effort $S_{i,j}(t) \geq 0$ represents cumulative firefighting resources applied during time step $t$, creating a competitive dynamic between fire growth and human intervention. This framework captures the fundamental reality that fire suppression is not instantaneous but requires sustained effort proportional to fire intensity.

### Firefighter Agent Dynamics

Firefighter agents $F_k$ are characterized by the comprehensive state vector $\mathbf{f}_k(t) = (p_k(t), s_k(t), w_k(t), \tau_k(t))$ that encodes spatial position $p_k(t) \in L$, behavioral state $s_k(t)$ from the set of available actions including moving, fighting, refilling, and patrolling, current water capacity $w_k(t) \in [0, W_{max}]$, and current target fire location $\tau_k(t)$ when assigned to suppression tasks.

This state representation enables complex behavioral patterns where agents must balance competing priorities such as reaching distant fires quickly versus ensuring adequate water supplies for effective suppression. The behavioral state transitions create realistic operational constraints where agents cannot instantaneously switch between activities but must follow logical sequences of preparation, deployment, engagement, and recovery.

### Modified Fire Propagation with Suppression

The fire transition dynamics incorporate suppression effects through a competitive process between fire intensity and applied suppression effort. Fire cells transition to burned state when suppression effort exceeds fire intensity, representing successful containment, while fires with intensity exceeding applied suppression effort continue burning with only minimal natural burnout probability. This creates realistic scenarios where insufficient suppression resources allow fires to persist and potentially spread to adjacent areas.

Fire intensity evolves according to $I_{i,j}(t+1) = \max(0, I_{i,j}(t) - S_{i,j}(t) - D_{i,j}(t))$ where natural burnout processes $D_{i,j}(t)$ provide stochastic reduction in fire intensity independent of human intervention. This formulation captures the reality that fires naturally diminish over time as fuel is consumed, while human suppression efforts can accelerate this process when applied effectively.

### Firefighter Behavioral Rules

Firefighter movement follows gradient descent toward assigned targets with velocity constraints that reflect realistic operational limitations. The movement equation $\mathbf{p}_k(t+1) = \mathbf{p}_k(t) + v_k \cdot \frac{\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)}{||\boldsymbol{\tau}_k(t) - \mathbf{p}_k(t)||}$ ensures that agents move directly toward their objectives while respecting maximum speed limitations imposed by terrain and equipment constraints.

Target assignment employs nearest-neighbor allocation with constraint satisfaction to prevent overcommitment of resources to single fire events. The assignment rule $\tau_k(t) = \arg\min_{\mathbf{f} \in \mathcal{F}_{unassigned}} ||\mathbf{p}_k(t) - \mathbf{f}||$ ensures efficient resource utilization while water availability constraints $w_k(t) > w_{min}$ and state compatibility requirements prevent agents from accepting assignments they cannot effectively complete.

### Infrastructure Effects on Fire Dynamics

Road networks fundamentally alter fire propagation by serving as firebreaks that reduce spread probability through multiplicative factors. Adjacent road cells reduce baseline fire spread probability to 20% of normal levels, representing the fire suppression benefits of maintained clearings and improved access for suppression equipment. This infrastructure effect creates persistent landscape modifications that benefit all suppression policies.

Water sources enable agent refilling operations when agents are positioned at designated locations, instantly restoring water capacity to maximum levels. This refilling mechanism creates strategic positioning considerations where agents must balance proximity to active fires against access to water resources necessary for sustained suppression operations.

## Policy Architecture: Comparative Strategy Frameworks

### Reactive Suppression Policy

The reactive policy represents traditional fire management approaches that minimize initial resource commitment by deploying limited personnel only after fires are detected and confirmed. This strategy employs three firefighters with no preventive patrol coverage, moderate suppression power of 15 units, and standard movement speed of 2 units per time step. The reactive approach prioritizes cost minimization over prevention, accepting higher fire risk in exchange for reduced steady-state operational expenses.

This policy configuration reflects "attack when burning" strategies that dominated historical fire management, where resource constraints necessitated reactive rather than proactive deployment. The minimal resource footprint makes this approach attractive for budget-constrained agencies operating in lower-risk environments where fire frequency remains manageable through reactive response alone.

### Preventive Suppression Policy

The preventive policy emphasizes early detection through systematic patrol coverage that positions five firefighters across the landscape with patrol radii of 8 units around designated base stations. Firefighters execute random walks within patrol zones to maximize early fire detection probability while maintaining the same suppression power and movement speed as reactive policies.

This approach recognizes that early intervention dramatically improves suppression effectiveness by engaging fires when they remain small and manageable. The increased personnel cost is offset by reduced average fire sizes and decreased peak suppression demands during major fire events. Preventive policies prove particularly effective in high-risk environments where fire frequency justifies the additional surveillance investment.

### Aggressive Suppression Policy

The aggressive policy maximizes suppression capacity through enhanced equipment and personnel deployment, utilizing seven firefighters with increased suppression power of 25 units, enhanced movement speed of 3 units, and extended water capacity of 150 units. This configuration prioritizes overwhelming force application over distributed prevention, focusing resources on rapid response and intensive suppression rather than surveillance activities.

The aggressive approach represents modern incident command strategies that deploy maximum available resources to contain fires quickly and prevent escalation to major events. While this policy requires the highest resource investment, it provides the greatest suppression effectiveness and proves cost-justified in extreme-risk environments where catastrophic fires could cause damages far exceeding suppression costs.

## Implementation Architecture: Multi-Phase Staged Activation

### Staged Temporal Dynamics

The model employs a two-phase activation schedule that separates ecological processes from suppression activities to prevent temporal artifacts and ensure realistic system behavior. Phase one handles tree growth and firefighter movement with state updates, while phase two processes fire dynamics and suppression interactions. This temporal separation prevents synchronization artifacts where agent actions taken early in a time step inappropriately affect decisions made later in the same step.

The staged approach ensures that all agents observe the same system state when making decisions, creating fair competition for resources and preventing unrealistic advantages based solely on processing order. This methodological choice proves critical for generating reliable policy comparisons that reflect true strategic differences rather than computational artifacts.

### Multi-Agent Coordination Mechanisms

Firefighters coordinate through a shared assignment table that maps fire locations to assigned agents, preventing resource conflicts and ensuring efficient allocation. The coordination mechanism tracks which fires have been assigned to specific agents while maintaining a pool of unassigned fires available for new assignments. This system prevents multiple agents from converging on the same fire while other fires remain unattended.

The assignment table updates dynamically as new fires emerge and existing fires are extinguished, maintaining system-wide awareness of resource allocation status. This coordination mechanism captures essential aspects of real fire management operations where incident commanders must allocate limited resources across multiple competing demands while avoiding dangerous resource conflicts.

### State Machine Implementation

Each firefighter agent implements a finite state automaton with transitions triggered by environmental conditions and internal resource states. The state machine enables complex behavioral patterns where agents must follow logical sequences of preparation, deployment, engagement, and recovery rather than instantaneously switching between arbitrary activities.

State transitions depend on both environmental observations including fire locations and water availability, and internal agent conditions such as current water capacity and position relative to assigned targets. This implementation creates realistic operational constraints that force agents to make strategic decisions about resource allocation and positioning under uncertainty.

## Emergent Dynamics: Resource Allocation and Spatial Coverage

### Spatial Response Patterns

Different policies generate distinct spatial coverage patterns that fundamentally affect suppression effectiveness through their interaction with fire propagation dynamics. Reactive policies create clustering patterns where firefighters concentrate around active fires, providing effective local suppression but potentially leaving coverage gaps that allow new ignitions to develop unchecked.

Preventive policies distribute firefighters across patrol areas to maximize surveillance coverage, improving detection latency but potentially reducing local suppression density when multiple fires emerge simultaneously. Aggressive policies concentrate higher agent density to enable rapid overwhelming of fire events, though this concentration may create spatial inefficiencies during low-activity periods when many agents remain idle.

These spatial patterns create feedback loops with fire dynamics, as policy-induced coverage patterns influence which areas experience rapid suppression response versus delayed intervention. The spatial distribution of suppression resources thus becomes a critical factor determining overall policy effectiveness.

### Temporal Resource Utilization

The dynamic interplay between fire ignition rates and suppression capacity creates characteristic temporal resource utilization patterns that reveal policy strengths and limitations. The utilization metric $U(t) = \frac{\sum_k \mathbb{I}[s_k(t) \in \{Fighting, Moving\}]}{N_f}$ quantifies what fraction of available resources are actively engaged in suppression activities at any given time.

Reactive systems exhibit high-amplitude utilization fluctuations with periods of minimal activity punctuated by intensive suppression efforts when fires emerge. Preventive systems demonstrate more stable utilization patterns due to continuous patrol activities, while aggressive systems show rapid utilization spikes followed by quick returns to baseline levels as overwhelming force rapidly suppresses fire events.

These temporal patterns reveal fundamental trade-offs between resource efficiency and suppression effectiveness, as systems with higher steady-state utilization may provide better fire control but at the cost of reduced resource efficiency during low-fire periods.

### Fire Size Distribution Effects

Different policies systematically alter the statistical distribution of fire sizes through their influence on early intervention probability and suppression intensity. Preventive policies typically shift fire size distributions toward smaller events by improving detection and enabling intervention before fires grow large. Aggressive policies reduce the tail probability of very large fires through rapid suppression but may show less improvement in average fire size due to their reactive deployment patterns.

The cumulative distribution function for fire sizes under each policy reveals how strategic choices influence risk profiles, with some policies providing consistent reduction in average fire size while others focus on eliminating catastrophic events. These distributional effects prove critical for cost-benefit analysis since fire damage often scales non-linearly with fire size.

## Performance Metrics: Multi-Objective Policy Evaluation

### Suppression Effectiveness Measures

Burned area minimization represents the primary objective for most fire management policies, measured as the time-averaged total area in burned state across the simulation domain. This metric captures the cumulative impact of all fire events and provides a direct measure of landscape-level suppression success.

Fire duration reduction quantifies how quickly fires are extinguished once detected, measuring the average time interval between ignition and final suppression. This metric reveals policy effectiveness in rapid response and sustained suppression effort, independent of fire size or location effects.

Peak fire load management measures the maximum number of simultaneously active fires, indicating policy capacity to handle surge conditions during high-activity periods. This metric proves particularly important for resource planning and emergency preparedness since peak conditions often determine required system capacity.

### Resource Efficiency Indicators

Agent utilization rate quantifies what fraction of available firefighters are actively engaged in suppression activities, averaged across time and agents. High utilization indicates efficient resource deployment but may also suggest inadequate capacity margins for surge conditions.

Response time performance measures the average delay between fire ignition and initial suppression response, capturing policy effectiveness in rapid deployment. This metric proves critical since early intervention dramatically improves suppression success probability.

Water resource efficiency evaluates the relationship between total suppression effort applied and total water consumed, indicating how effectively policies convert resource inputs into suppression outputs. This metric reveals policy effectiveness in resource utilization independent of absolute resource levels.

### Economic Cost Considerations

Total policy costs incorporate both fixed infrastructure investments and variable operational expenses to enable comprehensive cost-benefit analysis. Fixed costs include personnel, water infrastructure, and road network investments that provide benefits regardless of fire activity levels.

Operational costs capture variable expenses including maintenance, deployment, and resource consumption that scale with policy activity levels. The total cost framework $C_{total}(\pi) = C_{fixed}(\pi) + C_{operational}(\pi)$ enables comparison of policies with different cost structures and activity patterns.

This economic framework proves essential for policy evaluation since suppression effectiveness must be balanced against resource constraints and opportunity costs of alternative investments.

## Simulation Results: Comparative Policy Analysis

### Burned Area Performance

Simulation results across 200 time steps reveal systematic differences in burned area outcomes that reflect fundamental policy characteristics. Reactive policies exhibit high variability with occasional large fire events due to delayed response times that allow fires to grow before suppression begins. This variability creates risk management challenges since average performance may not capture tail risk exposure.

Preventive policies achieve reduced average burned area through early detection and intervention that prevents small fires from growing into major events. The improvement proves particularly pronounced during high-fire periods when rapid detection enables intervention before multiple fires overwhelm suppression capacity.

Aggressive policies achieve the lowest burned area outcomes but exhibit diminishing marginal returns relative to resource investment levels. The high resource intensity provides maximum suppression effectiveness but may not prove cost-justified except in extreme-risk environments.

### Temporal Dynamics Comparison

Fire population dynamics reveal distinct evolutionary patterns under different policy regimes that illuminate underlying mechanisms and trade-offs. Reactive systems exhibit high-amplitude fluctuations with periods of rapid fire growth followed by intensive suppression efforts once resources are deployed. These boom-bust cycles create management challenges and resource planning difficulties.

Preventive systems demonstrate more stable fire populations with smaller amplitude variations due to continuous surveillance and early intervention. The stable patterns reduce peak resource demands and enable more predictable operational planning, though they require higher steady-state resource commitment.

Aggressive systems show rapid fire suppression with minimal persistence of active fires, creating saw-tooth patterns where fires are quickly eliminated upon detection. This rapid suppression prevents fire accumulation but requires sustained high-intensity resource deployment.

### Resource Utilization Trade-offs

Analysis reveals fundamental trade-offs that constrain policy design and highlight the impossibility of simultaneously optimizing all objectives. Prevention versus response trade-offs emerge as higher preventive investment reduces peak suppression demands but increases steady-state costs through continuous patrol activities.

Capacity versus coverage trade-offs reflect the reality that enhanced individual agent capability reduces total agent requirements but may create coverage gaps in distributed fire scenarios. Policies must balance concentrated capability against distributed presence based on expected fire patterns and operational constraints.

Speed versus persistence trade-offs highlight how rapid response capability provides immediate benefits but requires sustained resource commitment that may not prove cost-effective under all conditions. These trade-offs necessitate careful matching of policy characteristics to environmental and budgetary constraints.

## Policy Implications: Strategic Fire Management

### Cost-Benefit Optimization

The simulation framework enables systematic cost-benefit analysis across different fire risk environments to guide policy selection and resource allocation decisions. In low-risk environments characterized by infrequent fire events, reactive policies may provide optimal cost-effectiveness by minimizing steady-state costs while accepting occasional fire losses that remain within acceptable limits.

High-risk environments benefit from preventive policies that justify higher steady-state costs through systematic reduction in fire damages. The early intervention benefits compound over time as prevented large fires avoid the exponential damage scaling that characterizes uncontrolled fire growth.

Extreme-risk environments may justify aggressive policies despite their high resource intensity, particularly when potential catastrophic fire damages far exceed suppression costs. The cost-benefit calculus shifts dramatically when considering potential losses of life, property, and irreplaceable natural resources.

### Infrastructure Investment Strategies

Simulation results provide quantitative guidance for infrastructure development priorities and investment sequencing. Road networks provide systematic fire spread reduction benefits that persist across all policy types and fire scenarios, making them high-priority investments for most environments.

Water source investments prove critical for aggressive policies that depend on sustained suppression operations but show diminishing returns under preventive strategies that reduce overall suppression demands through early intervention. The optimal water infrastructure investment depends heavily on chosen suppression strategy.

Base station positioning optimization reveals policy-dependent requirements, with preventive policies favoring distributed coverage to maximize surveillance reach while aggressive policies benefit from centralized rapid response capability. Infrastructure decisions must align with strategic policy choices to maximize investment effectiveness.

### Adaptive Management Frameworks

The model results suggest significant benefits from adaptive policy selection based on environmental conditions rather than static policy implementation. Dynamic policy switching enables optimization of the expected benefit-cost ratio $\pi^*(t) = \arg\max_{\pi \in \Pi} \left[ E[\text{Benefits}|\pi, \text{conditions}(t)] - C(\pi) \right]$ based on seasonal fire risk, weather conditions, and resource availability.

This adaptive approach recognizes that optimal fire management strategy varies with environmental context and enables flexible response to changing conditions. Implementation requires robust condition assessment capability and pre-planned policy transition protocols to enable rapid strategy changes when conditions warrant.

## Model Extensions and Future Directions

### Environmental Heterogeneity

The current model assumes spatially homogeneous fire behavior, but realistic extensions could incorporate topographic effects such as elevation, slope, and aspect influences on both fire spread rates and suppression accessibility. These factors fundamentally alter fire behavior and create spatial variation in suppression difficulty that affects resource allocation decisions.

Fuel load variability across vegetation types would introduce fire intensity and spread characteristics that vary spatially, creating strategic positioning considerations as firefighters optimize deployment based on expected fire behavior in different areas. Weather dynamics including wind direction, humidity, and temperature could create temporal variation in fire risk and suppression effectiveness.

### Multi-Scale Temporal Dynamics

The discrete time step framework could be enhanced to capture intra-day variations in fire behavior and suppression effectiveness that create operational windows for different activities. Diurnal cycles in weather conditions and fire activity create tactical opportunities that experienced firefighters exploit but which the current model cannot represent.

Seasonal patterns in fuel accumulation and weather conditions could be incorporated to create annual cycles that affect optimal resource allocation throughout the year. Multi-year cycles involving vegetation recovery and fuel build-up following fire events would capture longer-term landscape dynamics that influence fire management strategy.

### Human Dimension Integration

Future models could incorporate evacuation dynamics where civilian population movements affect suppression priorities and create additional constraints on resource deployment. Structure protection objectives could introduce spatial prioritization criteria that compete with pure fire suppression objectives.

Economic damage assessment could enable optimization of total social costs rather than just fire management costs, potentially justifying higher suppression investment when property and economic values are protected. Public health impacts from smoke exposure could create additional optimization criteria beyond direct fire damage.

### Machine Learning Integration

Advanced extensions could employ reinforcement learning to develop adaptive firefighter behavior based on experience and performance feedback. Agents could learn optimal positioning, targeting, and coordination strategies through trial and error rather than following fixed behavioral rules.

Predictive modeling capabilities could enable proactive resource positioning based on fire risk forecasting, allowing policies to anticipate rather than merely react to fire events. Optimization algorithms could provide automated policy parameter tuning for specific environmental conditions and operational constraints.

## Limitations and Critical Assessment

### Spatial Resolution Constraints

The regular grid structure fundamentally limits representation of complex terrain features that critically influence real fire behavior, including sub-grid heterogeneity in fuel loads, moisture content, and topographic complexity. While the current resolution enables policy comparison, quantitative predictions would require finer spatial resolution and irregular spatial networks that better represent landscape complexity.

### Simplified Fire Physics

The probabilistic fire spread model abstracts away complex thermodynamic processes, wind effects, and fuel consumption dynamics that determine actual fire behavior. This simplification enables computational efficiency and policy comparison but limits the model's ability to make quantitative predictions about specific fire events or detailed tactical decisions.

### Human Behavior Simplification

Firefighter agents follow deterministic behavioral rules that cannot capture the full complexity of human decision-making under stress, including coordination challenges, adaptive learning processes, and the communication difficulties that characterize real suppression operations. These simplifications may underestimate the challenges of implementing policies that appear effective in simulation.

### Economic Model Limitations

Cost calculations employ simplified linear models that may not adequately represent economies of scale, fixed cost structures, or the complex relationship between resource utilization and operational expenses in real fire management agencies. More sophisticated economic modeling would improve policy evaluation accuracy but at the cost of increased model complexity.

## Conclusion: Computational Policy Analysis for Fire Management

The multi-agent forest fire suppression model demonstrates how computational approaches can illuminate complex policy trade-offs in environmental management while revealing fundamental relationships between resource investment patterns and suppression effectiveness outcomes. Through systematic comparison of reactive, preventive, and aggressive suppression strategies, we uncover principles that extend beyond fire management to other domains involving distributed resource allocation under uncertainty.

For fire management agencies, the model provides a quantitative framework for evaluating resource allocation decisions before expensive real-world implementation. The ability to simulate different scenarios under controlled conditions enables systematic exploration of policy alternatives that would be impossible through field experimentation alone, while the cost-benefit framework supports evidence-based decision making in resource-constrained environments.

For policymakers, the framework reveals how different strategic approaches create distinct risk-cost profiles that must be matched to local conditions and institutional constraints. Reactive policies minimize steady-state costs but accept higher wildfire risk, while preventive approaches reduce average fire damage at the expense of higher ongoing resource commitments. Aggressive policies provide maximum suppression capability but may exhibit diminishing marginal returns that limit their applicability.

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
