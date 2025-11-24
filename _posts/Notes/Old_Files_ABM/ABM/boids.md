

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
