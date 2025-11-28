# Emergent Order in Continuous Space: The Boids Flocking Model

Our journey through agent-based modeling began with random walks, where solitary agents wandered aimlessly across discrete grids, generating unpredictable trajectories from pure chance. We then progressed to the Schelling model, where agents made purposeful decisions based on their social environment, creating segregation patterns from mild preferences. Now we venture into a realm where collective behavior produces stunning displays of coordination without central control: the flocking behavior of birds, fish, and other social organisms.

Watch a murmuration of starlings twist and turn through the sky, thousands of individuals moving as one fluid entity. Observe a school of fish evading a predator, their synchronized movements creating waves of coordinated motion. These natural phenomena captivate us precisely because they exhibit remarkable order emerging from what appears to be chaos. No leader directs the flock, no blueprint prescribes the pattern, yet the collective behavior displays a coherence that seems almost choreographed. The Boids model, developed by Craig Reynolds in 1987, demonstrates how such mesmerizing patterns arise from three simple behavioral rules operating in continuous space.

## The Mathematics of Flocking

The transition from discrete grid-based models to continuous space represents a fundamental shift in how we conceptualize agent movement and interaction. Rather than occupying distinct cells and moving in discrete steps, boids exist at precise coordinates in continuous two-dimensional space and move with velocity vectors that change smoothly over time. Each boid i possesses a position vector **p**ᵢ = (xᵢ, yᵢ) and velocity vector **v**ᵢ = (vₓ, vᵧ), both evolving continuously as the simulation progresses.

The flocking behavior emerges from three fundamental rules that Reynolds identified by observing natural flocks. These rules translate into force vectors that modify each boid's velocity at every time step. The separation rule prevents crowding by applying a repulsive force when neighbors come too close. For boid i with neighbors within a critical distance, the separation force **F**ₛₑₚ becomes:

**F**ₛₑₚ = Σⱼ (**p**ᵢ - **p**ⱼ) / ||**p**ᵢ - **p**ⱼ||²

where the sum extends over all neighbors j within the separation threshold and the inverse square distance weighting ensures stronger repulsion from closer neighbors. This mathematical formulation mirrors physical forces like electrostatic repulsion, creating natural spacing between individuals.

The alignment rule steers each boid toward the average heading of its neighbors, promoting coordinated movement. If **N**ᵢ represents the set of neighbors within boid i's perception radius, the alignment force becomes:

**F**ₐₗᵢ = (Σⱼ∈**N**ᵢ **v**ⱼ / |**N**ᵢ|) - **v**ᵢ

This force represents the difference between the average neighbor velocity and the boid's current velocity, creating a steering force that gradually aligns the boid with its neighbors' movement patterns. The cohesion rule attracts boids toward the average position of their neighbors, preventing the flock from dispersing. The cohesion force takes the form:

**F**cₒₕ = (Σⱼ∈**N**ᵢ **p**ⱼ / |**N**ᵢ|) - **p**ᵢ

representing the difference between the center of mass of nearby neighbors and the boid's current position. These three forces combine with adjustable weights w₁, w₂, w₃ to produce the total acceleration:

**a**ᵢ = w₁**F**ₛₑₚ + w₂**F**ₐₗᵢ + w₃**F**cₒₕ

The boid's velocity then updates according to **v**ᵢ(t+Δt) = **v**ᵢ(t) + **a**ᵢΔt, with constraints ensuring velocities remain within physically reasonable bounds. The position updates through standard kinematic equations: **p**ᵢ(t+Δt) = **p**ᵢ(t) + **v**ᵢ(t)Δt.

## Implementation in Continuous Space

Our Mesa implementation leverages continuous space rather than discrete grids, fundamentally changing how we represent positions and calculate interactions. The `Boid` class encapsulates both position and velocity as numpy arrays, enabling efficient vector operations:

```python
class Boid(Agent):
    def __init__(self, model, pos, velocity=None):
        super().__init__(model)
        self.pos = np.array(pos, dtype=float)
        
        if velocity is None:
            angle = np.random.uniform(0, 2 * np.pi)
            speed = np.random.uniform(1, 3)
            self.velocity = np.array([np.cos(angle) * speed, np.sin(angle) * speed])
        else:
            self.velocity = np.array(velocity, dtype=float)
        
        self.max_speed = 4.0
        self.max_force = 0.3
        self.perception_radius = 15.0
```

The initialization demonstrates careful attention to physical realism. Each boid begins with a random velocity whose direction spans the full circle (0 to 2π radians) and whose magnitude varies within reasonable bounds. The parameters max_speed and max_force constrain the boid's motion, preventing unrealistic accelerations or velocities that would break the illusion of natural movement.

The separation force implementation translates the mathematical formulation directly into code while handling edge cases and numerical stability:

```python
def separate(self, neighbors):
    separation_vector = np.array([0.0, 0.0])
    if len(neighbors) == 0:
        return separation_vector
    
    for neighbor in neighbors:
        distance = np.linalg.norm(self.pos - neighbor.pos)
        if 0 < distance < self.perception_radius / 3:
            diff = self.pos - neighbor.pos
            separation_vector += diff / (distance ** 2)
    
    if np.linalg.norm(separation_vector) > 0:
        separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_speed
        separation_vector = separation_vector - self.velocity
        if np.linalg.norm(separation_vector) > self.max_force:
            separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_force
    
    return separation_vector
```

The distance check prevents division by zero when a boid evaluates separation from itself, while the perception threshold (one-third the full perception radius) creates a zone of strong repulsion that maintains natural spacing. The force limiting ensures realistic dynamics by preventing instantaneous velocity changes that would violate physical constraints.

The alignment rule computes the average velocity of neighbors and steers the boid toward this consensus heading:

```python
def align(self, neighbors):
    if len(neighbors) == 0:
        return np.array([0.0, 0.0])
    
    avg_velocity = np.mean([n.velocity for n in neighbors], axis=0)
    
    if np.linalg.norm(avg_velocity) > 0:
        avg_velocity = (avg_velocity / np.linalg.norm(avg_velocity)) * self.max_speed
        steering = avg_velocity - self.velocity
        if np.linalg.norm(steering) > self.max_force:
            steering = (steering / np.linalg.norm(steering)) * self.max_force
        return steering
    
    return np.array([0.0, 0.0])
```

The steering force represents desired velocity minus current velocity, implementing a proportional control mechanism that smoothly adjusts the boid's heading toward the group consensus. This approach mirrors control theory principles, creating stable feedback that prevents oscillation.

Cohesion attracts boids toward their neighbors' center of mass, implemented through a similar steering mechanism:

```python
def cohere(self, neighbors):
    if len(neighbors) == 0:
        return np.array([0.0, 0.0])
    
    center_of_mass = np.mean([n.pos for n in neighbors], axis=0)
    desired = center_of_mass - self.pos
    
    if np.linalg.norm(desired) > 0:
        desired = (desired / np.linalg.norm(desired)) * self.max_speed
        steering = desired - self.velocity
        if np.linalg.norm(steering) > self.max_force:
            steering = (steering / np.linalg.norm(steering)) * self.max_force
        return steering
    
    return np.array([0.0, 0.0])
```

The complete step method integrates these three forces with adjustable weights, updates velocity and position, and handles boundary conditions through toroidal wrapping:

```python
def step(self):
    neighbors = self.model.space.get_neighbors(self.pos, self.perception_radius, include_center=False)
    
    separation = self.separate(neighbors) * 1.5
    alignment = self.align(neighbors) * 1.0
    cohesion = self.cohere(neighbors) * 1.0
    
    acceleration = separation + alignment + cohesion
    self.velocity += acceleration
    
    speed = np.linalg.norm(self.velocity)
    if speed > self.max_speed:
        self.velocity = (self.velocity / speed) * self.max_speed
    
    new_pos = self.pos + self.velocity
    new_pos[0] = new_pos[0] % self.model.space.x_max
    new_pos[1] = new_pos[1] % self.model.space.y_max
    
    self.model.space.move_agent(self, new_pos)
    self.pos = new_pos
```

The weighting scheme (1.5 for separation, 1.0 for alignment and cohesion) reflects empirical tuning that balances the competing forces. Heavier weighting on separation prevents collision and maintains natural spacing, while equal weights on alignment and cohesion encourage group coordination without over-clustering.

## Model Architecture and Data Collection

The `FlockingModel` class manages the continuous space environment and coordinates agent interactions:

```python
class FlockingModel(Model):
    def __init__(self, n_boids=100, width=100, height=100):
        super().__init__()
        self.n_boids = n_boids
        self.space = ContinuousSpace(width, height, torus=True)
        
        for i in range(self.n_boids):
            x = np.random.uniform(0, width)
            y = np.random.uniform(0, height)
            boid = Boid(self, (x, y))
            self.space.place_agent(boid, boid.pos)
        
        self.datacollector = DataCollector(
            model_reporters={
                "Avg Speed": lambda m: np.mean([np.linalg.norm(a.velocity) for a in m.agents]),
                "Avg Neighbors": lambda m: np.mean([len(m.space.get_neighbors(a.pos, a.perception_radius, False)) for a in m.agents])
            }
        )
```

The continuous space contrasts sharply with the discrete grids of previous models. Positions can take any real-valued coordinates within the bounds, and distance calculations use Euclidean geometry rather than grid metrics. The toroidal topology eliminates edge effects by wrapping around boundaries, creating an unbounded environment that prevents artifacts from wall interactions.

Data collection tracks aggregate properties that reveal flock-level dynamics. Average speed indicates whether the flock moves coherently or fragments into independently moving subgroups. Average neighbor count measures local density and interaction patterns, providing insight into flock cohesion. These metrics enable quantitative analysis of emergent properties that would be difficult to assess through visualization alone.

## Emergent Phenomena and Pattern Formation

When we run the flocking simulation, the initial chaos of randomly positioned and oriented boids gradually gives way to organized collective motion. This transition from disorder to order occurs without any central coordination—no boid leads the flock, no global information guides the process. Each boid responds only to its immediate neighbors, yet the local interactions propagate through the population to create system-wide patterns.

The temporal evolution reveals distinct phases in flock formation. Initially, boids with random velocities move in many different directions, creating a dispersed, disordered configuration. As the simulation progresses, local groups begin forming where nearby boids happen to move in similar directions. These proto-flocks grow as adjacent boids align with the local consensus, and eventually multiple groups merge into larger aggregations. The mature flock exhibits coherent collective motion with all boids moving roughly in the same direction while maintaining appropriate spacing.

The mathematical description of this order-disorder transition resembles phase transitions in statistical physics. We can define an order parameter Φ that measures the degree of velocity alignment across the flock:

Φ = ||Σᵢ **v**ᵢ/||**v**ᵢ|||| / N

where the sum extends over all N boids and we normalize individual velocities to unit length before averaging. This order parameter ranges from Φ ≈ 0 for completely disordered motion (velocities pointing in random directions cancel out) to Φ = 1 for perfect alignment (all boids moving in exactly the same direction). The transition from random initial conditions to organized flocking corresponds to Φ increasing from near-zero to high values approaching unity.

The perception radius plays a crucial role in determining whether flocking behavior emerges. Too small a perception radius prevents boids from sensing enough neighbors to coordinate effectively, leaving the system fragmented into small, disconnected groups. Too large a perception radius creates excessive interaction that can lead to unstable oscillations or unrealistic clustering. The optimal perception radius balances local interaction with computational efficiency, typically spanning several times the average inter-boid distance.

## Variations and Extensions

The basic boids model admits numerous extensions that capture additional aspects of natural flocking behavior. Obstacle avoidance introduces environmental features that boids must navigate around, requiring an additional force that steers away from detected obstacles. Predator evasion adds predatory agents that trigger escape responses, creating dramatic collective evasion maneuvers where the flock scatters and reforms. Leader-follower dynamics introduce heterogeneity where some boids preferentially follow designated leaders, creating hierarchical flock structures.

Three-dimensional extensions naturally accommodate aerial flocking in birds or swimming schools of fish. The mathematics generalizes straightforwardly by adding a z-component to position and velocity vectors, though visualization becomes more challenging. The additional degree of freedom enables more complex maneuvering patterns, including banking turns and vertical climbs or dives.

Energy constraints provide biological realism by making speed costly. Boids might have energy reserves that deplete with sustained high-speed motion, forcing them to balance the benefits of staying with the flock against the costs of rapid movement. This extension can create interesting dynamics where flocks periodically slow down to conserve energy before accelerating again.

Information propagation through flocks represents another fascinating extension. If we give one boid knowledge of a distant food source or threat, how does this information spread through the flock? The boids model provides a framework for studying how individual knowledge becomes collective knowledge through purely local interactions, with potential applications to understanding communication in animal groups.

## Computational Considerations

The continuous space implementation requires more sophisticated spatial indexing than grid-based models. Finding neighbors within a given radius becomes computationally expensive when done naively by checking distances to all other agents. For N boids, this naive approach requires O(N²) distance calculations per time step, becoming prohibitively expensive for large flocks. Mesa's ContinuousSpace implements spatial indexing techniques that reduce this cost, though large-scale simulations still demand computational resources.

The animation capabilities demonstrate the power of modern scientific visualization:

```python
def update(frame):
    positions = positions_history[frame]
    velocities = velocities_history[frame]
    
    ax1.scatter(positions[:, 0], positions[:, 1], c='blue', s=30, alpha=0.6)
    ax1.quiver(positions[:, 0], positions[:, 1], 
               velocities[:, 0], velocities[:, 1],
               color='red', alpha=0.4, scale=50, width=0.003)
    ax1.set_xlim(0, model.space.x_max)
    ax1.set_ylim(0, model.space.y_max)
    ax1.set_title(f'Boids Flocking Simulation (Step {frame})')
```

The visualization combines positional information (scatter plot) with velocity vectors (quiver plot), providing both state and dynamics information in a single view. The transparency settings prevent visual clutter when many boids overlap, while the scaling parameters ensure velocity vectors remain visible without dominating the plot.

The dual-panel display showing both the spatial configuration and temporal metrics provides complementary perspectives on flock behavior. The spatial view reveals pattern geometry and local structure, while the time series reveals dynamics and stability. Together, they provide comprehensive understanding of the flocking phenomenon.

## Biological Parallels and Theoretical Insights

The remarkable success of the boids model in reproducing realistic flocking patterns raises profound questions about natural cognition and behavior. Real birds and fish obviously don't compute vector forces and update velocity arrays, yet their behavior produces patterns nearly indistinguishable from the simulation. This suggests that evolution has discovered similar computational principles implemented through very different neural and sensory mechanisms.

Research in animal behavior has indeed confirmed that many flocking species follow rules remarkably similar to Reynolds' three principles. Birds maintain preferred distances from neighbors (separation), match their neighbors' flight speeds and directions (alignment), and stay near the group (cohesion). The specific parameter values—perception radii, force weights, speed limits—vary across species and contexts, but the underlying algorithmic structure appears conserved.

This convergence between computational models and natural behavior exemplifies the power of agent-based modeling as a theoretical tool. Rather than merely describing what happens, the model explains how simple local rules generate complex global patterns. The model makes testable predictions about how changing parameters should affect flock behavior, enabling systematic experimental validation.

The boids model also illuminates fundamental principles of distributed systems and collective computation. The flock exhibits properties that no individual boid possesses—coherent motion, adaptive shape changes, robustness to individual removal. These emergent properties arise from the interaction network rather than being programmed into any component. This principle finds applications far beyond biological flocking, informing the design of distributed algorithms, swarm robotics, and multi-agent systems.

## From Local Rules to Global Order

The progression from random walks through Schelling segregation to boids flocking reveals increasingly sophisticated forms of emergence. Random walks showed how simple stochastic rules generate complex trajectories. Schelling demonstrated how individual preferences aggregate into system-wide patterns that transcend individual intentions. Boids completes this trajectory by showing how purely local interactions create globally coherent collective behavior that appears purposeful and coordinated.

Each model builds conceptual foundations for the next. The random walk established the basic mechanics of agent-based simulation and data collection. Schelling added decision-making based on local neighborhood assessment. Boids extends these principles to continuous space with vector-based motion, multiple simultaneous forces, and dynamic group formation. Together, these models demonstrate the breadth and power of agent-based approaches to understanding complex systems.

The mathematical frameworks underlying these models share common themes despite their superficial differences. All three involve local interaction rules—random walks through grid adjacency, Schelling through neighborhood similarity, boids through spatial proximity. All three exhibit emergent phenomena where system-level patterns arise from agent-level rules. All three demonstrate sensitive dependence on parameters, with small changes producing qualitatively different outcomes.

The visualization and analysis techniques also build progressively. We moved from simple trajectory plots to spatial pattern visualization to animated vector fields showing both position and velocity. The data collection evolved from basic position tracking to aggregate measures of segregation to sophisticated metrics of collective order. This methodological progression parallels the conceptual development, with each model introducing new analytical tools appropriate to its specific phenomena.

## Practical Applications and Future Directions

The boids model has found applications far beyond its original purpose of generating realistic animal animation. Swarm robotics employs boids-like algorithms to coordinate multiple robots performing collective tasks like area coverage, formation flying, or collaborative transport. Traffic flow models use modified boids rules to simulate vehicle behavior on highways, helping transportation engineers optimize road networks and predict congestion patterns.

Crowd simulation for emergency planning implements boids-inspired models to understand how human crowds move through building exits during evacuations. The balance between individual goal-seeking and crowd-following produces realistic crowd dynamics that inform architectural design and safety protocols. Military applications explore how autonomous drone swarms might coordinate using distributed boids-like rules, enabling resilient collective behavior without centralized command structures requiring vulnerable communication networks.

The model's influence extends even to abstract domains like distributed computing and optimization algorithms. Particle swarm optimization adapts the boids framework to search parameter spaces, with particles representing candidate solutions that move toward better solutions while maintaining swarm cohesion. This marriage of collective behavior with computational problem-solving demonstrates how biological inspiration can yield powerful algorithms for practical applications.

Future extensions might incorporate more sophisticated environmental representations, including three-dimensional terrain, wind fields, or complex obstacle geometries. Enhanced behavioral realism could include fatigue, hunger, or reproductive behaviors that create additional constraints and objectives beyond simple flocking. Learning mechanisms might allow boids to adapt their parameters based on experience, potentially discovering novel collective strategies through reinforcement learning or evolutionary algorithms.

The integration of boids models with real animal tracking data offers exciting research opportunities. Modern GPS and accelerometer tags can record detailed movement data from wild animals, providing ground truth for validating and refining flocking models. Discrepancies between model predictions and observed behavior highlight gaps in our understanding, driving new hypotheses about the mechanisms governing natural flocking.

## Conclusion: The Beauty of Emergent Coordination

The boids flocking model stands as one of the most elegant demonstrations of how complexity arises from simplicity. Three straightforward rules—separate, align, cohere—combined with continuous space and vector-based motion, generate patterns that capture the essence of natural flocking behavior. The model requires no central coordinator, no global communication, no predetermined choreography. Order emerges spontaneously from purely local interactions, creating the mesmerizing coordinated motion we observe in nature.

This emergence exemplifies a fundamental principle of complex systems: the whole can exhibit properties and behaviors that are not present in any individual component. No boid knows about the flock's overall motion or shape, yet the flock moves as a coherent entity. No boid tries to create beautiful aerial patterns, yet the collective produces forms of striking aesthetic appeal. The disconnect between individual rules and collective outcomes reveals the surprising consequences of interaction and feedback in multi-agent systems.

As we've progressed from random walks through segregation to flocking, we've witnessed increasing sophistication in both the models themselves and our tools for analyzing them. We've moved from discrete to continuous space, from single agents to coordinated groups, from static preferences to dynamic forces. Each step has revealed new aspects of how complex patterns emerge from simple rules, building our intuition about agent-based modeling while developing practical skills in implementation and analysis.

The journey continues, with many fascinating agent-based models still to explore. From epidemic spread to economic markets, from ecosystem dynamics to cultural evolution, agent-based approaches illuminate phenomena across every scientific domain. The boids model, with its elegant simplicity and visual beauty, provides both inspiration and foundation for understanding these more complex systems. As we watch the simulated flock wheel and turn across our screens, we glimpse the profound truth that underlies all agent-based modeling: the universe's most complex patterns may arise from rules simple enough to fit in a few lines of code.

## Complete Implementation

```python
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from mesa import Agent, Model
from mesa.space import ContinuousSpace
from mesa.datacollection import DataCollector

class Boid(Agent):
    """
    A Boid agent following flocking rules: separation, alignment, cohesion
    """
    def __init__(self, model, pos, velocity=None):
        super().__init__(model)
        self.pos = np.array(pos, dtype=float)
        
        # Initialize random velocity if not provided
        if velocity is None:
            angle = np.random.uniform(0, 2 * np.pi)
            speed = np.random.uniform(1, 3)
            self.velocity = np.array([np.cos(angle) * speed, np.sin(angle) * speed])
        else:
            self.velocity = np.array(velocity, dtype=float)
        
        # Boid parameters
        self.max_speed = 4.0
        self.max_force = 0.3
        self.perception_radius = 15.0
    
    def separate(self, neighbors):
        """Avoid crowding neighbors (short range repulsion)"""
        separation_vector = np.array([0.0, 0.0])
        if len(neighbors) == 0:
            return separation_vector
        
        for neighbor in neighbors:
            distance = np.linalg.norm(self.pos - neighbor.pos)
            if 0 < distance < self.perception_radius / 3:
                diff = self.pos - neighbor.pos
                separation_vector += diff / (distance ** 2)
        
        if np.linalg.norm(separation_vector) > 0:
            separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_speed
            separation_vector = separation_vector - self.velocity
            if np.linalg.norm(separation_vector) > self.max_force:
                separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_force
        
        return separation_vector
    
    def align(self, neighbors):
        """Steer towards average heading of neighbors"""
        if len(neighbors) == 0:
            return np.array([0.0, 0.0])
        
        avg_velocity = np.mean([n.velocity for n in neighbors], axis=0)
        
        if np.linalg.norm(avg_velocity) > 0:
            avg_velocity = (avg_velocity / np.linalg.norm(avg_velocity)) * self.max_speed
            steering = avg_velocity - self.velocity
            if np.linalg.norm(steering) > self.max_force:
                steering = (steering / np.linalg.norm(steering)) * self.max_force
            return steering
        
        return np.array([0.0, 0.0])
    
    def cohere(self, neighbors):
        """Steer towards average position of neighbors"""
        if len(neighbors) == 0:
            return np.array([0.0, 0.0])
        
        center_of_mass = np.mean([n.pos for n in neighbors], axis=0)
        desired = center_of_mass - self.pos
        
        if np.linalg.norm(desired) > 0:
            desired = (desired / np.linalg.norm(desired)) * self.max_speed
            steering = desired - self.velocity
            if np.linalg.norm(steering) > self.max_force:
                steering = (steering / np.linalg.norm(steering)) * self.max_force
            return steering
        
        return np.array([0.0, 0.0])
    
    def step(self):
        """Execute one step of the boid"""
        neighbors = self.model.space.get_neighbors(self.pos, self.perception_radius, include_center=False)
        
        separation = self.separate(neighbors) * 1.5
        alignment = self.align(neighbors) * 1.0
        cohesion = self.cohere(neighbors) * 1.0
        
        acceleration = separation + alignment + cohesion
        self.velocity += acceleration
        
        speed = np.linalg.norm(self.velocity)
        if speed > self.max_speed:
            self.velocity = (self.velocity / speed) * self.max_speed
        
        new_pos = self.pos + self.velocity
        new_pos[0] = new_pos[0] % self.model.space.x_max
        new_pos[1] = new_pos[1] % self.model.space.y_max
        
        self.model.space.move_agent(self, new_pos)
        self.pos = new_pos


class FlockingModel(Model):
    """
    Model of flocking behavior using Boids algorithm
    """
    def __init__(self, n_boids=100, width=100, height=100):
        super().__init__()
        self.n_boids = n_boids
        self.space = ContinuousSpace(width, height, torus=True)
        
        for i in range(self.n_boids):
            x = np.random.uniform(0, width)
            y = np.random.uniform(0, height)
            boid = Boid(self, (x, y))
            self.space.place_agent(boid, boid.pos)
        
        self.datacollector = DataCollector(
            model_reporters={
                "Avg Speed": lambda m: np.mean([np.linalg.norm(a.velocity) for a in m.agents]),
                "Avg Neighbors": lambda m: np.mean([len(m.space.get_neighbors(a.pos, a.perception_radius, False)) for a in m.agents])
            }
        )
    
    def step(self):
        """Advance the model by one step"""
        self.datacollector.collect(self)
        all_agents = list(self.agents)
        self.random.shuffle(all_agents)
        for agent in all_agents:
            agent.step()


# Run simulation
model = FlockingModel(n_boids=80, width=100, height=100)

n_steps = 200
positions_history = []
velocities_history = []

for i in range(n_steps):
    model.step()
    positions = np.array([agent.pos for agent in model.agents])
    velocities = np.array([agent.velocity for agent in model.agents])
    positions_history.append(positions)
    velocities_history.append(velocities)

# Visualization
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

def update(frame):
    ax1.clear()
    ax2.clear()
    
    positions = positions_history[frame]
    velocities = velocities_history[frame]
    
    ax1.scatter(positions[:, 0], positions[:, 1], c='blue', s=30, alpha=0.6)
    ax1.quiver(positions[:, 0], positions[:, 1], 
               velocities[:, 0], velocities[:, 1],
               color='red', alpha=0.4, scale=50, width=0.003)
    ax1.set_xlim(0, model.space.x_max)
    ax1.set_ylim(0, model.space.y_max)
    ax1.set_title(f'Boids Flocking Simulation (Step {frame})')
    
    data = model.datacollector.get_model_vars_dataframe()
    ax2.plot(data['Avg Speed'], 'b-', label='Avg Speed', linewidth=2)
    ax2_twin = ax2.twinx()
    ax2_twin.plot(data['Avg Neighbors'], 'g-', label='Avg Neighbors', linewidth=2)
    ax2.axvline(x=frame, color='red', linestyle='--', alpha=0.5)
    
    plt.tight_layout()

anim = animation.FuncAnimation(fig, update, frames=range(0, n_steps, 2), 
                              interval=50, repeat=True)
plt.show()
```

```python
# Install Mesa if not already installed
# !pip install mesa matplotlib numpy

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from mesa import Agent, Model
from mesa.space import ContinuousSpace
from mesa.datacollection import DataCollector

class Boid(Agent):
    """
    A Boid agent following flocking rules: separation, alignment, cohesion
    """
    def __init__(self, model, pos, velocity=None):
        super().__init__(model)
        self.pos = np.array(pos, dtype=float)
        
        # Initialize random velocity if not provided
        if velocity is None:
            angle = np.random.uniform(0, 2 * np.pi)
            speed = np.random.uniform(1, 3)
            self.velocity = np.array([np.cos(angle) * speed, np.sin(angle) * speed])
        else:
            self.velocity = np.array(velocity, dtype=float)
        
        # Boid parameters
        self.max_speed = 4.0
        self.max_force = 0.3
        self.perception_radius = 15.0
    
    def separate(self, neighbors):
        """Avoid crowding neighbors (short range repulsion)"""
        separation_vector = np.array([0.0, 0.0])
        if len(neighbors) == 0:
            return separation_vector
        
        for neighbor in neighbors:
            distance = np.linalg.norm(self.pos - neighbor.pos)
            if 0 < distance < self.perception_radius / 3:
                diff = self.pos - neighbor.pos
                # Weight by distance (closer = stronger repulsion)
                separation_vector += diff / (distance ** 2)
        
        if np.linalg.norm(separation_vector) > 0:
            # Normalize and scale to max_speed
            separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_speed
            # Steering = desired - velocity
            separation_vector = separation_vector - self.velocity
            # Limit force
            if np.linalg.norm(separation_vector) > self.max_force:
                separation_vector = (separation_vector / np.linalg.norm(separation_vector)) * self.max_force
        
        return separation_vector
    
    def align(self, neighbors):
        """Steer towards average heading of neighbors"""
        if len(neighbors) == 0:
            return np.array([0.0, 0.0])
        
        avg_velocity = np.mean([n.velocity for n in neighbors], axis=0)
        
        # Normalize and scale to max_speed
        if np.linalg.norm(avg_velocity) > 0:
            avg_velocity = (avg_velocity / np.linalg.norm(avg_velocity)) * self.max_speed
            # Steering = desired - velocity
            steering = avg_velocity - self.velocity
            # Limit force
            if np.linalg.norm(steering) > self.max_force:
                steering = (steering / np.linalg.norm(steering)) * self.max_force
            return steering
        
        return np.array([0.0, 0.0])
    
    def cohere(self, neighbors):
        """Steer towards average position of neighbors"""
        if len(neighbors) == 0:
            return np.array([0.0, 0.0])
        
        center_of_mass = np.mean([n.pos for n in neighbors], axis=0)
        desired = center_of_mass - self.pos
        
        if np.linalg.norm(desired) > 0:
            # Normalize and scale to max_speed
            desired = (desired / np.linalg.norm(desired)) * self.max_speed
            # Steering = desired - velocity
            steering = desired - self.velocity
            # Limit force
            if np.linalg.norm(steering) > self.max_force:
                steering = (steering / np.linalg.norm(steering)) * self.max_force
            return steering
        
        return np.array([0.0, 0.0])
    
    def step(self):
        """Execute one step of the boid"""
        # Get neighbors within perception radius
        neighbors = self.model.space.get_neighbors(self.pos, self.perception_radius, include_center=False)
        
        # Apply flocking rules
        separation = self.separate(neighbors) * 1.5  # Weight separation more
        alignment = self.align(neighbors) * 1.0
        cohesion = self.cohere(neighbors) * 1.0
        
        # Update velocity
        acceleration = separation + alignment + cohesion
        self.velocity += acceleration
        
        # Limit speed
        speed = np.linalg.norm(self.velocity)
        if speed > self.max_speed:
            self.velocity = (self.velocity / speed) * self.max_speed
        
        # Update position
        new_pos = self.pos + self.velocity
        
        # Wrap around edges (toroidal space)
        new_pos[0] = new_pos[0] % self.model.space.x_max
        new_pos[1] = new_pos[1] % self.model.space.y_max
        
        self.model.space.move_agent(self, new_pos)
        self.pos = new_pos


class FlockingModel(Model):
    """
    Model of flocking behavior using Boids algorithm
    """
    def __init__(self, n_boids=100, width=100, height=100):
        super().__init__()
        self.n_boids = n_boids
        self.space = ContinuousSpace(width, height, torus=True)
        
        # Create boids - Mesa 3.0 automatically tracks agents
        for i in range(self.n_boids):
            x = np.random.uniform(0, width)
            y = np.random.uniform(0, height)
            boid = Boid(self, (x, y))
            self.space.place_agent(boid, boid.pos)
        
        # Data collection
        self.datacollector = DataCollector(
            model_reporters={
                "Avg Speed": lambda m: np.mean([np.linalg.norm(a.velocity) for a in m.agents]),
                "Avg Neighbors": lambda m: np.mean([len(m.space.get_neighbors(a.pos, a.perception_radius, False)) for a in m.agents])
            }
        )
    
    def step(self):
        """Advance the model by one step"""
        self.datacollector.collect(self)
        # Get all agents and shuffle for random activation
        all_agents = list(self.agents)
        self.random.shuffle(all_agents)
        for agent in all_agents:
            agent.step()


# Initialize and run model
print("Initializing Boids Flocking Model...")
model = FlockingModel(n_boids=80, width=100, height=100)

# Run simulation and collect data for animation
n_steps = 200
positions_history = []
velocities_history = []

for i in range(n_steps):
    model.step()
    positions = np.array([agent.pos for agent in model.agents])
    velocities = np.array([agent.velocity for agent in model.agents])
    positions_history.append(positions)
    velocities_history.append(velocities)
    if (i + 1) % 50 == 0:
        print(f"Step {i + 1}/{n_steps}")

print("Simulation complete!")

# Create animation
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

def update(frame):
    ax1.clear()
    ax2.clear()
    
    positions = positions_history[frame]
    velocities = velocities_history[frame]
    
    # Main flocking visualization
    ax1.scatter(positions[:, 0], positions[:, 1], c='blue', s=30, alpha=0.6)
    # Draw velocity vectors
    ax1.quiver(positions[:, 0], positions[:, 1], 
               velocities[:, 0], velocities[:, 1],
               color='red', alpha=0.4, scale=50, width=0.003)
    ax1.set_xlim(0, model.space.x_max)
    ax1.set_ylim(0, model.space.y_max)
    ax1.set_xlabel('X Position')
    ax1.set_ylabel('Y Position')
    ax1.set_title(f'Boids Flocking Simulation (Step {frame})')
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')
    
    # Statistics plot
    data = model.datacollector.get_model_vars_dataframe()
    steps = range(len(data))
    
    ax2_twin = ax2.twinx()
    
    line1 = ax2.plot(steps, data['Avg Speed'], 'b-', label='Avg Speed', linewidth=2)
    line2 = ax2_twin.plot(steps, data['Avg Neighbors'], 'g-', label='Avg Neighbors', linewidth=2)
    
    ax2.axvline(x=frame, color='red', linestyle='--', alpha=0.5)
    
    ax2.set_xlabel('Step')
    ax2.set_ylabel('Average Speed', color='b')
    ax2_twin.set_ylabel('Average Neighbors', color='g')
    ax2.tick_params(axis='y', labelcolor='b')
    ax2_twin.tick_params(axis='y', labelcolor='g')
    ax2.set_title('Swarm Metrics Over Time')
    ax2.grid(True, alpha=0.3)
    
    # Combine legends
    lines = line1 + line2
    labels = [l.get_label() for l in lines]
    ax2.legend(lines, labels, loc='upper right')
    
    plt.tight_layout()

# Create animation
anim = animation.FuncAnimation(fig, update, frames=range(0, n_steps, 2), 
                              interval=50, repeat=True)

plt.show()

# Display final statistics
print("\n=== Simulation Statistics ===")
data = model.datacollector.get_model_vars_dataframe()
print(f"Final Average Speed: {data['Avg Speed'].iloc[-1]:.2f}")
print(f"Final Average Neighbors: {data['Avg Neighbors'].iloc[-1]:.2f}")
print(f"Speed Std Dev: {data['Avg Speed'].std():.2f}")
print(f"Neighbors Std Dev: {data['Avg Neighbors'].std():.2f}")

# Show final state
fig, ax = plt.subplots(figsize=(10, 10))
final_positions = positions_history[-1]
final_velocities = velocities_history[-1]

ax.scatter(final_positions[:, 0], final_positions[:, 1], c='blue', s=50, alpha=0.6, label='Boids')
ax.quiver(final_positions[:, 0], final_positions[:, 1], 
          final_velocities[:, 0], final_velocities[:, 1],
          color='red', alpha=0.5, scale=40, width=0.004, label='Velocity')
ax.set_xlim(0, model.space.x_max)
ax.set_ylim(0, model.space.y_max)
ax.set_xlabel('X Position')
ax.set_ylabel('Y Position')
ax.set_title('Final Flocking Pattern')
ax.legend()
ax.grid(True, alpha=0.3)
ax.set_aspect('equal')
plt.tight_layout()
plt.show()
```



```python
from IPython.display import HTML
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import numpy as np

# The 'model', 'positions_history', 'velocities_history', 'n_steps' variables
# are already available in the kernel state from the previous cell's execution.

# Create animation
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7))

def update(frame):
    ax1.clear()
    ax2.clear()

    positions = positions_history[frame]
    velocities = velocities_history[frame]

    # Main flocking visualization
    ax1.scatter(positions[:, 0], positions[:, 1], c='blue', s=30, alpha=0.6)
    # Draw velocity vectors
    ax1.quiver(positions[:, 0], positions[:, 1],
               velocities[:, 0], velocities[:, 1],
               color='red', alpha=0.4, scale=50, width=0.003)
    ax1.set_xlim(0, model.space.x_max)
    ax1.set_ylim(0, model.space.y_max)
    ax1.set_xlabel('X Position')
    ax1.set_ylabel('Y Position')
    ax1.set_title(f'Boids Flocking Simulation (Step {frame})')
    ax1.grid(True, alpha=0.3)
    ax1.set_aspect('equal')

    # Statistics plot
    data = model.datacollector.get_model_vars_dataframe()
    steps = range(len(data))

    ax2_twin = ax2.twinx()

    line1 = ax2.plot(steps, data['Avg Speed'], 'b-', label='Avg Speed', linewidth=2)
    line2 = ax2_twin.plot(steps, data['Avg Neighbors'], 'g-', label='Avg Neighbors', linewidth=2)

    ax2.axvline(x=frame, color='red', linestyle='--', alpha=0.5)

    ax2.set_xlabel('Step')
    ax2.set_ylabel('Average Speed', color='b')
    ax2_twin.set_ylabel('Average Neighbors', color='g')
    ax2.tick_params(axis='y', labelcolor='b')
    ax2_twin.tick_params(axis='y', labelcolor='g')
    ax2.set_title('Swarm Metrics Over Time')
    ax2.grid(True, alpha=0.3)

    # Combine legends
    lines = line1 + line2
    labels = [l.get_label() for l in lines]
    ax2.legend(lines, labels, loc='upper right')

    plt.tight_layout()

# Create animation
# Note: frames are skipped (range(0, n_steps, 2)) to reduce animation size/length
anim = animation.FuncAnimation(fig, update, frames=range(0, n_steps, 2),
                              interval=50, repeat=True)

# Display the animation in Colab output using HTML
HTML(anim.to_jshtml())


```
