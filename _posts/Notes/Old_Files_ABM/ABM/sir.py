# Install Mesa if needed
try:
    import mesa
except ImportError:
    !pip install -q mesa
    import mesa

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation
from IPython.display import HTML
from mesa import Agent, Model
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector

# Agent class
class PersonAgent(Agent):
    def __init__(self, model, state='S'):
        super().__init__(model)
        self.state = state  # 'S', 'I', or 'R'
        self.infection_time = 0
        
    def step(self):
        if self.state == 'I':
            self.infect()
            self.infection_time += 1
            # Recover after infection period
            if self.infection_time >= self.model.recovery_time:
                self.state = 'R'
                self.infection_time = 0
    
    def infect(self):
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False)
        susceptible_neighbors = [agent for agent in neighbors 
                                if agent.state == 'S']
        for neighbor in susceptible_neighbors:
            if self.random.random() < self.model.infection_rate:
                neighbor.state = 'I'

# Model class
class EpidemicModel(Model):
    def __init__(self, width=50, height=50, density=0.8, 
                 initial_infected=5, infection_rate=0.3, recovery_time=10):
        super().__init__()
        self.width = width
        self.height = height
        self.infection_rate = infection_rate
        self.recovery_time = recovery_time
        self.grid = MultiGrid(width, height, torus=True)
        
        # Create agents
        n_agents = int(width * height * density)
        for i in range(n_agents):
            state = 'I' if i < initial_infected else 'S'
            agent = PersonAgent(self, state)
            
            # Place agent on grid
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)
            self.grid.place_agent(agent, (x, y))
        
        # Data collection
        self.datacollector = DataCollector(
            model_reporters={
                "Susceptible": lambda m: sum(1 for a in m.agents if a.state == 'S'),
                "Infected": lambda m: sum(1 for a in m.agents if a.state == 'I'),
                "Recovered": lambda m: sum(1 for a in m.agents if a.state == 'R')
            }
        )
        self.datacollector.collect(self)
    
    def step(self):
        # Shuffle and activate all agents
        self.agents.shuffle_do("step")
        self.datacollector.collect(self)

# Run simulation and collect frames for animation
print("Running SIR Epidemic Model with animation...")
model = EpidemicModel(
    width=50, 
    height=50, 
    density=0.8,
    initial_infected=5,
    infection_rate=0.25,
    recovery_time=10
)

# Store grid states for animation
grid_states = []
n_steps = 100

for step in range(n_steps):
    # Capture grid state
    grid_state = np.zeros((model.height, model.width))
    for agent in model.agents:
        x, y = agent.pos
        if agent.state == 'S':
            grid_state[y, x] = 0
        elif agent.state == 'I':
            grid_state[y, x] = 1
        elif agent.state == 'R':
            grid_state[y, x] = 2
    grid_states.append(grid_state.copy())
    
    model.step()
    if step % 20 == 0:
        print(f"Step {step}/{n_steps}")

print("Simulation complete! Creating visualizations...")
    
# Get and plot results
data = model.datacollector.get_model_vars_dataframe()

# Create figure with 3 subplots
fig = plt.figure(figsize=(16, 5))

# Plot 1: Time series
ax1 = plt.subplot(1, 3, 1)
plt.plot(data['Susceptible'], label='Susceptible', color='blue', linewidth=2)
plt.plot(data['Infected'], label='Infected', color='red', linewidth=2)
plt.plot(data['Recovered'], label='Recovered', color='green', linewidth=2)
plt.xlabel('Time Steps', fontsize=12)
plt.ylabel('Number of Agents', fontsize=12)
plt.title('SIR Epidemic Model Dynamics', fontsize=14, fontweight='bold')
plt.legend(fontsize=10)
plt.grid(alpha=0.3)

# Plot 2: Final state visualization
ax2 = plt.subplot(1, 3, 2)
plt.imshow(grid_states[-1], cmap='RdYlGn_r', interpolation='nearest')
plt.colorbar(ticks=[0, 1, 2], label='State')
plt.title('Final Spatial Distribution', fontsize=14, fontweight='bold')
plt.xlabel('X Position', fontsize=12)
plt.ylabel('Y Position', fontsize=12)

# Plot 3: Animation frame
ax3 = plt.subplot(1, 3, 3)
im = ax3.imshow(grid_states[0], cmap='RdYlGn_r', interpolation='nearest', vmin=0, vmax=2)
plt.colorbar(im, ax=ax3, ticks=[0, 1, 2], label='State')
title = ax3.set_title('Animation - Step 0', fontsize=14, fontweight='bold')
ax3.set_xlabel('X Position', fontsize=12)
ax3.set_ylabel('Y Position', fontsize=12)

plt.tight_layout()
plt.show()

print(f"\nFinal Statistics (after {len(data)} steps):")
print(f"Susceptible: {data['Susceptible'].iloc[-1]}")
print(f"Infected: {data['Infected'].iloc[-1]}")
print(f"Recovered: {data['Recovered'].iloc[-1]}")
print(f"Peak infection: {data['Infected'].max()} at step {data['Infected'].idxmax()}")

# Create animation
print("\nCreating animation (this may take a moment)...")
fig_anim, ax_anim = plt.subplots(figsize=(8, 8))
im_anim = ax_anim.imshow(grid_states[0], cmap='RdYlGn_r', interpolation='nearest', vmin=0, vmax=2)
plt.colorbar(im_anim, ax=ax_anim, ticks=[0, 1, 2], label='State (0=S, 1=I, 2=R)')
title_anim = ax_anim.set_title('SIR Epidemic Spread - Step 0', fontsize=14, fontweight='bold')
ax_anim.set_xlabel('X Position', fontsize=12)
ax_anim.set_ylabel('Y Position', fontsize=12)

# Add statistics text
stats_text = ax_anim.text(0.02, 0.98, '', transform=ax_anim.transAxes, 
                          fontsize=10, verticalalignment='top',
                          bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

def animate(frame):
    im_anim.set_array(grid_states[frame])
    title_anim.set_text(f'SIR Epidemic Spread - Step {frame}')
    
    # Update statistics
    s_count = int(data['Susceptible'].iloc[frame])
    i_count = int(data['Infected'].iloc[frame])
    r_count = int(data['Recovered'].iloc[frame])
    stats_text.set_text(f'S: {s_count}\nI: {i_count}\nR: {r_count}')
    
    return [im_anim, title_anim, stats_text]

# Create animation (sample every 2 frames for speed)
anim = FuncAnimation(fig_anim, animate, frames=range(0, len(grid_states), 2), 
                     interval=100, blit=True, repeat=True)

plt.close()  # Close the figure to prevent duplicate display
print("Animation ready!")

# Display animation
HTML(anim.to_jshtml())
