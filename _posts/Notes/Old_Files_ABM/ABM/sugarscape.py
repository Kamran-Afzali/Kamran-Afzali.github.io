# Install Mesa if not already installed

import mesa
import random
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np

# Economic Agent with trading capability
class EconomicAgent(mesa.Agent):
    def __init__(self, model, initial_wealth):
        super().__init__(model)
        self.wealth = initial_wealth
    
    def trade(self, other_agent):
        """Trade with another agent - transfers wealth randomly"""
        if self.wealth > 0 and other_agent.wealth > 0:
            trade_amount = min(self.wealth, other_agent.wealth)
            transfer = self.random.randint(0, trade_amount)
            self.wealth -= transfer
            other_agent.wealth += transfer
    
    def step(self):
        """Agent's action each step: move and trade"""
        # Move to a random neighboring cell
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False
        )
        new_position = self.random.choice(possible_steps)
        self.model.grid.move_agent(self, new_position)
        
        # Find agents in the same cell and trade with one
        cellmates = self.model.grid.get_cell_list_contents([self.pos])
        if len(cellmates) > 1:
            other_agent = self.random.choice(cellmates)
            if other_agent != self:
                self.trade(other_agent)

# Wealth Distribution Model
class WealthModel(mesa.Model):
    def __init__(self, n_agents=100, width=10, height=10, initial_wealth=10):
        super().__init__()
        self.num_agents = n_agents
        self.grid = mesa.space.MultiGrid(width, height, torus=True)
        
        # Create agents with initial wealth
        for i in range(self.num_agents):
            agent = EconomicAgent(self, initial_wealth)
            
            # Place agent randomly on grid
            x = self.random.randrange(self.grid.width)
            y = self.random.randrange(self.grid.height)
            self.grid.place_agent(agent, (x, y))
        
        # Data storage
        self.wealth_history = []
        self.gini_history = []
        self.mean_history = []
        self.max_history = []
        self.min_history = []
        
    def compute_gini(self):
        """Calculate Gini coefficient for wealth inequality"""
        agent_wealths = [agent.wealth for agent in self.agents]
        x = sorted(agent_wealths)
        n = len(x)
        cumsum = sum(x)
        if cumsum == 0:
            return 0
        return (2 * sum([(i+1) * xi for i, xi in enumerate(x)])) / (n * cumsum) - (n + 1) / n
    
    def collect_data(self):
        """Collect wealth data for analysis"""
        wealths = [agent.wealth for agent in self.agents]
        self.wealth_history.append(wealths)
        self.gini_history.append(self.compute_gini())
        self.mean_history.append(np.mean(wealths))
        self.max_history.append(np.max(wealths))
        self.min_history.append(np.min(wealths))
    
    def step(self):
        """Advance model by one step"""
        self.collect_data()
        self.agents.shuffle_do("step")

# Run simulation
print("Running Wealth Distribution Simulation...")
model = WealthModel(n_agents=100, width=10, height=10, initial_wealth=10)

for i in range(100):
    model.step()

# Collect final data
model.collect_data()

# Get final wealth distribution
final_wealth = np.array(model.wealth_history[-1])

# Visualizations
fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# 1. Wealth distribution histogram (final state)
axes[0, 0].hist(final_wealth, bins=30, color='steelblue', edgecolor='black')
axes[0, 0].set_xlabel('Wealth')
axes[0, 0].set_ylabel('Number of Agents')
axes[0, 0].set_title('Final Wealth Distribution (Step 100)')
axes[0, 0].axvline(final_wealth.mean(), color='red', linestyle='--', 
                   label=f'Mean: {final_wealth.mean():.2f}')
axes[0, 0].legend()

# 2. Gini coefficient over time
axes[0, 1].plot(range(len(model.gini_history)), model.gini_history, 
                linewidth=2, color='darkred')
axes[0, 1].set_xlabel('Step')
axes[0, 1].set_ylabel('Gini Coefficient')
axes[0, 1].set_title('Wealth Inequality Over Time')
axes[0, 1].grid(True, alpha=0.3)

# 3. Wealth statistics over time
steps = range(len(model.mean_history))
axes[1, 0].plot(steps, model.mean_history, label='Mean', linewidth=2)
axes[1, 0].plot(steps, model.max_history, label='Max', linewidth=2)
axes[1, 0].plot(steps, model.min_history, label='Min', linewidth=2)
axes[1, 0].set_xlabel('Step')
axes[1, 0].set_ylabel('Wealth')
axes[1, 0].set_title('Wealth Statistics Over Time')
axes[1, 0].legend()
axes[1, 0].grid(True, alpha=0.3)

# 4. Lorenz curve (final state)
sorted_wealth = sorted(final_wealth)
cumulative_wealth = [sum(sorted_wealth[:i+1]) for i in range(len(sorted_wealth))]
total_wealth = sum(sorted_wealth)
lorenz = [w / total_wealth for w in cumulative_wealth]
population_share = [(i+1) / len(sorted_wealth) for i in range(len(sorted_wealth))]

axes[1, 1].plot([0] + population_share, [0] + lorenz, linewidth=2, label='Lorenz Curve')
axes[1, 1].plot([0, 1], [0, 1], 'k--', label='Perfect Equality')
axes[1, 1].fill_between([0] + population_share, [0] + lorenz, 
                        [0] + [p for p in population_share], 
                        alpha=0.3, label='Gini Area')
axes[1, 1].set_xlabel('Cumulative Share of Population')
axes[1, 1].set_ylabel('Cumulative Share of Wealth')
axes[1, 1].set_title(f'Lorenz Curve (Gini: {model.gini_history[-1]:.3f})')
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

plt.tight_layout()
plt.show()

# Print summary statistics
print("\n" + "="*50)
print("SIMULATION SUMMARY")
print("="*50)
print(f"Number of agents: {model.num_agents}")
print(f"Initial wealth per agent: 10")
print(f"Total steps: 100")
print(f"\nFinal Statistics:")
print(f"  Mean wealth: {final_wealth.mean():.2f}")
print(f"  Median wealth: {np.median(final_wealth):.2f}")
print(f"  Std deviation: {final_wealth.std():.2f}")
print(f"  Min wealth: {final_wealth.min()}")
print(f"  Max wealth: {final_wealth.max()}")
print(f"  Final Gini coefficient: {model.gini_history[-1]:.3f}")
print(f"  Initial Gini coefficient: {model.gini_history[0]:.3f}")
print("="*50)
