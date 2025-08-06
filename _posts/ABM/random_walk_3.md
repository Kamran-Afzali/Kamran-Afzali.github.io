# Beyond Random: When Agents Learn to Navigate Their World

What if our wandering agents could learn from experience? What if, instead of moving purely at random, they could develop preferences, avoid dangers, and gradually become more efficient at finding resources? In our latest evolution of Mesa-based simulations, we transform simple random walkers into adaptive, learning agents that demonstrate one of the most fundamental aspects of intelligence: the ability to modify behavior based on experience.

This third installment in our random walk series introduces reinforcement learning concepts into agent-based modeling, creating agents that start naive but develop sophisticated navigation strategies through trial and error. Along the way, we'll explore how individual learning aggregates into collective intelligence and examine the delicate balance between exploration and exploitation that drives adaptive behavior.

## From Random to Rational: The Learning Paradigm

The transition from random to learning behavior represents a profound shift in our modeling approach. While pure random walks provide valuable baselines for understanding stochastic processes, real-world entities—from foraging animals to search algorithms—rarely operate with complete randomness. Instead, they adapt their strategies based on accumulated experience, gradually becoming more effective at achieving their goals.

Our learning walker agents embody this adaptive intelligence. They begin each simulation with minimal knowledge about their environment, making largely random moves while slowly building internal models of which locations yield rewards and which pose dangers. Over time, these initially naive agents develop preferences that guide their movements toward beneficial outcomes and away from harmful ones.

## Environmental Complexity: Resources and Hazards

To enable meaningful learning, we've enriched our simulation environment with heterogeneous cell types that provide different experiences:

**Resource Cells**: Scattered across the grid at low density (3% by default), these locations represent positive experiences—food sources, shelter, or other beneficial opportunities that agents should learn to seek out.

**Toxic Cells**: Even more sparsely distributed (2% by default), these locations represent negative experiences—dangers, obstacles, or harmful conditions that wise agents learn to avoid.

**Neutral Cells**: The majority of the grid consists of neutral territory where agents can move without immediate consequences, but also without particular benefits.

This environmental structure creates a landscape of opportunity and risk that gives learning its purpose. Without meaningful differences between locations, there would be nothing valuable to learn.

## The Architecture of Adaptive Behavior

Our `LearningWalkerAgent` class implements a sophisticated yet understandable learning mechanism that balances multiple competing objectives:

```python
class LearningWalkerAgent(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        # Learning parameters
        self.resource_attraction = 0.1  # Initial attraction to resource cells
        self.toxic_avoidance = 0.1      # Initial avoidance of toxic cells
        self.learning_rate = 0.05       # How fast the agent learns
        self.exploration_rate = 0.3     # Probability of random move vs learned behavior
        self.memory_decay = 0.99        # How memory fades over time
```

Each agent maintains internal parameters that evolve throughout the simulation. The `resource_attraction` and `toxic_avoidance` variables represent learned preferences that strengthen through positive and negative experiences. The `learning_rate` controls how quickly these preferences adapt, while `memory_decay` ensures that very old experiences gradually fade in importance.

### The Exploration-Exploitation Dilemma

At the heart of our learning mechanism lies one of the most fundamental challenges in adaptive behavior: the exploration-exploitation trade-off. Should an agent exploit its current knowledge by moving toward known resources, or explore new areas that might contain even better opportunities?

```python
def step(self):
    # Choose move based on learning or exploration
    if self.random.random() < self.exploration_rate:
        # Explore randomly
        new_position = self.random.choice(possible_steps)
    else:
        # Use learned preferences
        new_position = self._choose_best_move(possible_steps)
```

Our agents handle this dilemma through a probabilistic approach. Early in the simulation, high exploration rates ensure broad sampling of the environment. As agents accumulate experience and develop reliable preferences, the exploration rate gradually decreases, shifting behavior toward exploitation of learned knowledge.

### Adaptive Decision Making

When agents choose to exploit rather than explore, they engage a sophisticated decision-making process that weighs multiple factors:

```python
def _choose_best_move(self, possible_steps):
    move_scores = []
    for pos in possible_steps:
        score = 0
        
        # Attraction to resource cells
        if pos in self.model.resource_cells:
            score += self.resource_attraction
        
        # Avoidance of toxic cells
        if pos in self.model.toxic_cells:
            score -= self.toxic_avoidance
            
        # Add small random component for tie-breaking
        score += self.random.random() * 0.01
        
        move_scores.append(score)
    
    # Choose move with highest score
    best_idx = np.argmax(move_scores)
    return possible_steps[best_idx]
```

This scoring system demonstrates how simple rules can create complex, adaptive behavior. Each potential move receives a score based on the agent's learned preferences, with a small random component to break ties and maintain some unpredictability. The highest-scoring move wins, but the definition of "highest-scoring" evolves as the agent learns.

### Learning Through Experience

The learning process itself operates through reinforcement principles that mirror biological and artificial intelligence systems:

```python
def _update_learning(self, new_position):
    if new_position in self.model.resource_cells:
        # Positive reinforcement for finding resources
        self.resource_attraction = min(1.0, self.resource_attraction + self.learning_rate)
        self.resource_visits += 1
    elif new_position in self.model.toxic_cells:
        # Negative reinforcement for toxic cells
        self.toxic_avoidance = min(1.0, self.toxic_avoidance + self.learning_rate)
        self.toxic_visits += 1
    
    # Gradually reduce exploration as agent learns
    self.exploration_rate = max(0.05, self.exploration_rate * 0.999)
```

Each experience—whether positive (finding resources) or negative (encountering toxins)—strengthens the corresponding preference. The learning rate determines how much each individual experience influences future behavior, while bounds prevent preferences from becoming infinitely strong. Simultaneously, the exploration rate decays slowly, implementing a form of simulated annealing that balances curiosity with accumulated wisdom.

## Environmental Architecture and Complexity

Our enhanced model creates rich environmental complexity through careful initialization and management of different cell types:

```python
def _initialize_cell_types(self):
    all_cells = [(x, y) for x in range(self.width) for y in range(self.height)]
    total_cells = self.width * self.height
    
    num_resource_cells = max(1, int(total_cells * self.resource_percentage))
    num_toxic_cells = max(1, int(total_cells * self.toxic_percentage))
    
    # Randomly select special cells
    self.resource_cells = set(random.sample(all_cells, num_resource_cells))
    remaining_cells = [cell for cell in all_cells if cell not in self.resource_cells]
    self.toxic_cells = set(random.sample(remaining_cells, num_toxic_cells))
```

This initialization process ensures that resource and toxic cells never overlap, creating a clear distinction between positive and negative experiences. The percentage-based allocation makes the model scalable—larger grids automatically contain proportionally more special cells, maintaining consistent environmental complexity regardless of size.

## Comprehensive Data Collection and Analysis

To understand how learning emerges and evolves, our model collects extensive data on both individual and collective behaviors:

```python
model_reporters = {
    "resource_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                   if agent.pos in m.resource_cells),
    "toxic_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                if agent.pos in m.toxic_cells),
    "avg_resource_attraction": lambda m: np.mean([agent.resource_attraction 
                                                for agent in m.schedule.agents]),
    "avg_toxic_avoidance": lambda m: np.mean([agent.toxic_avoidance 
                                            for agent in m.schedule.agents]),
    "avg_exploration_rate": lambda m: np.mean([agent.exploration_rate 
                                             for agent in m.schedule.agents]),
    "total_resource_visits": lambda m: sum([agent.resource_visits 
                                          for agent in m.schedule.agents]),
    "total_toxic_visits": lambda m: sum([agent.toxic_visits 
                                       for agent in m.schedule.agents])
}
```

This data collection strategy captures both instantaneous states (how many agents are currently on resource cells) and cumulative outcomes (total visits over time). By tracking average learning parameters across all agents, we can observe how collective intelligence emerges from individual adaptation.

## The Complete Learning Walker Implementation

Here's our full implementation with all the learning mechanisms and analysis tools:

```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import random
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector

class LearningWalkerAgent(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        # Learning parameters
        self.resource_attraction = 0.1
        self.toxic_avoidance = 0.1
        self.learning_rate = 0.05
        self.exploration_rate = 0.3
        self.memory_decay = 0.99
        
        # Track visits for this agent
        self.resource_visits = 0
        self.toxic_visits = 0

    def step(self):
        # Decay memory slightly each step
        self.resource_attraction *= self.memory_decay
        self.toxic_avoidance *= self.memory_decay
        
        # Get possible moves
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False)
        
        # Choose move based on learning or exploration
        if self.random.random() < self.exploration_rate:
            new_position = self.random.choice(possible_steps)
        else:
            new_position = self._choose_best_move(possible_steps)
        
        # Move and learn
        self.model.grid.move_agent(self, new_position)
        self._update_learning(new_position)

    def _choose_best_move(self, possible_steps):
        if not possible_steps:
            return self.pos
        
        move_scores = []
        for pos in possible_steps:
            score = 0
            if pos in self.model.resource_cells:
                score += self.resource_attraction
            if pos in self.model.toxic_cells:
                score -= self.toxic_avoidance
            score += self.random.random() * 0.01
            move_scores.append(score)
        
        best_idx = np.argmax(move_scores)
        return possible_steps[best_idx]

    def _update_learning(self, new_position):
        if new_position in self.model.resource_cells:
            self.resource_attraction = min(1.0, self.resource_attraction + self.learning_rate)
            self.resource_visits += 1
        elif new_position in self.model.toxic_cells:
            self.toxic_avoidance = min(1.0, self.toxic_avoidance + self.learning_rate)
            self.toxic_visits += 1
        
        self.exploration_rate = max(0.05, self.exploration_rate * 0.999)

class LearningWalkerModel(Model):
    def __init__(self, width=20, height=20, n_steps=200, num_agents=10, 
                 resource_percentage=0.03, toxic_percentage=0.02):
        super().__init__()
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)
        self.num_agents = num_agents
        self.n_steps = n_steps
        self.resource_percentage = resource_percentage
        self.toxic_percentage = toxic_percentage
        self.width = width
        self.height = height

        # Initialize environment and agents
        self._initialize_cell_types()
        self._initialize_agents()
        self._initialize_datacollector()

    def _initialize_cell_types(self):
        all_cells = [(x, y) for x in range(self.width) for y in range(self.height)]
        total_cells = self.width * self.height
        
        num_resource_cells = max(1, int(total_cells * self.resource_percentage))
        num_toxic_cells = max(1, int(total_cells * self.toxic_percentage))
        
        self.resource_cells = set(random.sample(all_cells, num_resource_cells))
        remaining_cells = [cell for cell in all_cells if cell not in self.resource_cells]
        self.toxic_cells = set(random.sample(remaining_cells, num_toxic_cells))

    def _initialize_agents(self):
        all_cells = [(x, y) for x in range(self.width) for y in range(self.height)]
        safe_cells = [cell for cell in all_cells 
                     if cell not in self.resource_cells and cell not in self.toxic_cells]
        
        for i in range(self.num_agents):
            agent = LearningWalkerAgent(i, self)
            self.schedule.add(agent)
            start_pos = random.choice(safe_cells if safe_cells else all_cells)
            self.grid.place_agent(agent, start_pos)

    def _initialize_datacollector(self):
        model_reporters = {
            "resource_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                           if agent.pos in m.resource_cells),
            "toxic_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                        if agent.pos in m.toxic_cells),
            "avg_resource_attraction": lambda m: np.mean([agent.resource_attraction 
                                                        for agent in m.schedule.agents]),
            "avg_toxic_avoidance": lambda m: np.mean([agent.toxic_avoidance 
                                                    for agent in m.schedule.agents]),
            "avg_exploration_rate": lambda m: np.mean([agent.exploration_rate 
                                                     for agent in m.schedule.agents]),
            "total_resource_visits": lambda m: sum([agent.resource_visits 
                                                  for agent in m.schedule.agents]),
            "total_toxic_visits": lambda m: sum([agent.toxic_visits 
                                               for agent in m.schedule.agents])
        }
        
        self.datacollector = DataCollector(model_reporters=model_reporters)

    def step(self):
        self.datacollector.collect(self)
        self.schedule.step()

    def run_model(self, steps=None):
        if steps is None:
            steps = self.n_steps
            
        for i in range(steps):
            self.step()
        
        return self.datacollector.get_model_vars_dataframe()
```

## Emergent Intelligence: What the Data Reveals

When we run our learning walker simulation, the results reveal fascinating patterns of adaptive behavior that emerge from simple learning rules. The comprehensive analysis function visualizes four key aspects of the learning process:

**Current Location Dynamics**: Over time, we observe agents spending increasing amounts of time on resource cells while avoiding toxic areas. This shift reflects the gradual development of environmental knowledge and preference-based navigation.

**Cumulative Learning Curves**: The total number of resource and toxic visits reveals learning efficiency. Successful learning produces accelerating resource discovery rates and plateauing toxic encounters as agents become better at avoiding dangers.

**Preference Evolution**: Average resource attraction and toxic avoidance parameters show how collective preferences develop. These curves typically display rapid initial growth followed by gradual stabilization as learning rates and memory decay reach equilibrium.

**Exploration-Exploitation Balance**: The declining exploration rate demonstrates how agents transition from broad environmental sampling to focused exploitation of learned knowledge, implementing a form of computational wisdom that balances curiosity with experience.

## Research Implications and Real-World Connections

Our learning walker model bridges abstract computational concepts with tangible real-world phenomena. The learning mechanisms we've implemented mirror those found in biological systems, from bacterial chemotaxis to animal foraging behavior. The exploration-exploitation trade-off appears throughout ecology, where organisms must balance the safety of known resources against the potential benefits of exploring new territories.

In artificial intelligence, these same principles underlie reinforcement learning algorithms that power everything from game-playing systems to robotic navigation. Our Mesa implementation demonstrates how these sophisticated concepts can emerge from surprisingly simple rules and interactions.

### Extensions and Future Directions

The learning walker framework opens numerous avenues for further exploration:

**Social Learning**: Agents could observe and learn from each other's successes and failures, creating collective intelligence that exceeds individual capabilities.

**Dynamic Environments**: Resources and toxins could appear, disappear, or move over time, forcing agents to continuously adapt their strategies and challenging their ability to distinguish between environmental change and learning progress.

**Specialized Roles**: Different agent types could have varying learning rates, exploration tendencies, or sensory capabilities, creating diverse populations with complementary survival strategies.

**Memory Architectures**: More sophisticated memory systems could allow agents to remember specific locations, create mental maps, or develop complex behavioral routines based on spatial and temporal patterns.

## Computational Insights and Performance

From a software engineering perspective, our learning walker implementation demonstrates several important principles for building scalable agent-based models. The modular separation of learning logic from movement mechanics makes the code maintainable and extensible. The comprehensive data collection system enables deep analysis without cluttering the core simulation logic.

The use of NumPy for vectorized operations in decision-making and pandas for data analysis showcases the power of Python's scientific computing ecosystem. These tools make complex simulations both computationally efficient and analytically rich.

## Conclusion: Intelligence as Emergent Property

Our journey from random walks through multi-agent systems to learning walkers illustrates a fundamental principle: intelligence is not a binary property but an emergent characteristic that arises from the interaction of simple adaptive mechanisms with complex environments. Our agents begin each simulation as naive wanderers, indistinguishable from random walkers. Through experience, reinforcement, and the gradual accumulation of preferences, they develop sophisticated navigation strategies that dramatically improve their environmental outcomes.

This transformation from random to rational behavior demonstrates how learning can bootstrap itself from minimal initial knowledge. The agents don't require complex programming or extensive training data—they develop effective strategies through direct environmental interaction, guided by simple reinforcement principles and the fundamental trade-off between exploration and exploitation.

The patterns that emerge from our simulations—the gradual shift from exploration to exploitation, the development of environmental preferences, the collective improvement in resource-finding efficiency—mirror phenomena we observe throughout the natural world. From the molecular level to ecosystem dynamics, learning and adaptation operate through remarkably similar principles, suggesting deep connections between biological and artificial intelligence.

As we continue to develop more sophisticated agent-based models, the learning walker framework provides both a foundation and an inspiration. It shows how complex, adaptive behaviors can emerge from simple rules, how individual learning aggregates into collective intelligence, and how computational models can illuminate fundamental questions about intelligence, adaptation, and the relationship between individual behavior and system-level outcomes.

In a world increasingly shaped by artificial intelligence and autonomous systems, understanding these basic principles of adaptive behavior has never been more important. Our learning walkers may exist only in computational worlds, but the insights they provide about learning, adaptation, and intelligence apply far beyond the boundaries of any simulation grid. They remind us that intelligence is not just about having the right answers—it's about learning to ask better questions and adapting our strategies based on what we discover along the way.


## Full code
```python
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import random
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector

class LearningWalkerAgent(Agent):
    def __init__(self, unique_id, model):
        super().__init__(unique_id, model)
        # Learning parameters
        self.resource_attraction = 0.1  # Initial attraction to resource cells
        self.toxic_avoidance = 0.1      # Initial avoidance of toxic cells
        self.learning_rate = 0.05       # How fast the agent learns
        self.exploration_rate = 0.3     # Probability of random move vs learned behavior
        self.memory_decay = 0.99        # How memory fades over time
        
        # Track visits for this agent
        self.resource_visits = 0
        self.toxic_visits = 0

    def step(self):
        # Decay memory slightly each step
        self.resource_attraction *= self.memory_decay
        self.toxic_avoidance *= self.memory_decay
        
        # Get possible moves
        possible_steps = self.model.grid.get_neighborhood(
            self.pos, moore=True, include_center=False)
        
        # Choose move based on learning or exploration
        if self.random.random() < self.exploration_rate:
            # Explore randomly
            new_position = self.random.choice(possible_steps)
        else:
            # Use learned preferences
            new_position = self._choose_best_move(possible_steps)
        
        # Move to new position
        self.model.grid.move_agent(self, new_position)
        
        # Update learning based on new position
        self._update_learning(new_position)

    def _choose_best_move(self, possible_steps):
        """Choose move based on learned preferences"""
        if not possible_steps:
            return self.pos
        
        # Calculate scores for each possible move
        move_scores = []
        for pos in possible_steps:
            score = 0
            
            # Attraction to resource cells
            if pos in self.model.resource_cells:
                score += self.resource_attraction
            
            # Avoidance of toxic cells
            if pos in self.model.toxic_cells:
                score -= self.toxic_avoidance
                
            # Add small random component for tie-breaking
            score += self.random.random() * 0.01
            
            move_scores.append(score)
        
        # Choose move with highest score
        best_idx = np.argmax(move_scores)
        return possible_steps[best_idx]

    def _update_learning(self, new_position):
        """Update learning parameters based on experience"""
        if new_position in self.model.resource_cells:
            # Positive reinforcement for finding resources
            self.resource_attraction = min(1.0, self.resource_attraction + self.learning_rate)
            self.resource_visits += 1
        elif new_position in self.model.toxic_cells:
            # Negative reinforcement for toxic cells
            self.toxic_avoidance = min(1.0, self.toxic_avoidance + self.learning_rate)
            self.toxic_visits += 1
        
        # Gradually reduce exploration as agent learns
        self.exploration_rate = max(0.05, self.exploration_rate * 0.999)

class LearningWalkerModel(Model):
    def __init__(self, width=20, height=20, n_steps=200, num_agents=10, 
                 resource_percentage=0.03, toxic_percentage=0.02):
        super().__init__()
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)
        self.num_agents = num_agents
        self.n_steps = n_steps
        self.resource_percentage = resource_percentage
        self.toxic_percentage = toxic_percentage
        self.width = width
        self.height = height
        self.running = True

        # Initialize cell types
        self._initialize_cell_types()
        
        # Initialize agents
        self._initialize_agents()
        
        # Initialize data collection
        self._initialize_datacollector()

    def _initialize_cell_types(self):
        """Initialize resource and toxic cells"""
        all_cells = [(x, y) for x in range(self.width) for y in range(self.height)]
        total_cells = self.width * self.height
        
        num_resource_cells = max(1, int(total_cells * self.resource_percentage))
        num_toxic_cells = max(1, int(total_cells * self.toxic_percentage))
        
        # Ensure we don't exceed available cells
        num_resource_cells = min(num_resource_cells, len(all_cells) - 1)
        num_toxic_cells = min(num_toxic_cells, len(all_cells) - num_resource_cells - 1)
        
        # Randomly select special cells
        self.resource_cells = set(random.sample(all_cells, num_resource_cells))
        remaining_cells = [cell for cell in all_cells if cell not in self.resource_cells]
        self.toxic_cells = set(random.sample(remaining_cells, num_toxic_cells))
        
        print(f"Initialized {len(self.resource_cells)} resource cells and {len(self.toxic_cells)} toxic cells")

    def _initialize_agents(self):
        """Initialize agents in safe starting positions"""
        all_cells = [(x, y) for x in range(self.width) for y in range(self.height)]
        safe_cells = [cell for cell in all_cells 
                     if cell not in self.resource_cells and cell not in self.toxic_cells]
        
        for i in range(self.num_agents):
            agent = LearningWalkerAgent(i, self)
            self.schedule.add(agent)
            
            if safe_cells:
                start_pos = random.choice(safe_cells)
            else:
                # Fallback to any position if no safe cells available
                start_pos = random.choice(all_cells)
                
            self.grid.place_agent(agent, start_pos)

    def _initialize_datacollector(self):
        """Initialize data collection"""
        model_reporters = {
            "resource_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                           if agent.pos in m.resource_cells),
            "toxic_visits": lambda m: sum(1 for agent in m.schedule.agents 
                                        if agent.pos in m.toxic_cells),
            "avg_resource_attraction": lambda m: np.mean([agent.resource_attraction 
                                                        for agent in m.schedule.agents]),
            "avg_toxic_avoidance": lambda m: np.mean([agent.toxic_avoidance 
                                                    for agent in m.schedule.agents]),
            "avg_exploration_rate": lambda m: np.mean([agent.exploration_rate 
                                                     for agent in m.schedule.agents]),
            "total_resource_visits": lambda m: sum([agent.resource_visits 
                                                  for agent in m.schedule.agents]),
            "total_toxic_visits": lambda m: sum([agent.toxic_visits 
                                               for agent in m.schedule.agents])
        }
        
        agent_reporters = {
            "pos_x": "pos",
            "pos_y": "pos", 
            "resource_attraction": "resource_attraction",
            "toxic_avoidance": "toxic_avoidance",
            "exploration_rate": "exploration_rate"
        }
        
        self.datacollector = DataCollector(
            model_reporters=model_reporters,
            agent_reporters=agent_reporters
        )

    def step(self):
        """Advance the model by one step"""
        self.datacollector.collect(self)
        self.schedule.step()

    def run_model(self, steps=None):
        """Run the model for specified number of steps"""
        if steps is None:
            steps = self.n_steps
            
        for i in range(steps):
            self.step()
            if i % 50 == 0:  # Progress indicator
                print(f"Step {i}/{steps}")
        
        return self.datacollector.get_model_vars_dataframe()

def analyze_results(model_data):
    """Analyze and plot the results"""
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    
    # Plot 1: Current visits over time
    axes[0, 0].plot(model_data.index, model_data['resource_visits'], 
                    label='Agents on Resource Cells', color='green', linewidth=2)
    axes[0, 0].plot(model_data.index, model_data['toxic_visits'], 
                    label='Agents on Toxic Cells', color='red', linestyle='--', linewidth=2)
    axes[0, 0].set_xlabel("Step")
    axes[0, 0].set_ylabel("Number of Agents")
    axes[0, 0].set_title("Current Agent Locations Over Time")
    axes[0, 0].legend()
    axes[0, 0].grid(True, alpha=0.3)
    
    # Plot 2: Cumulative visits over time
    axes[0, 1].plot(model_data.index, model_data['total_resource_visits'], 
                    label='Total Resource Visits', color='green', linewidth=2)
    axes[0, 1].plot(model_data.index, model_data['total_toxic_visits'], 
                    label='Total Toxic Visits', color='red', linestyle='--', linewidth=2)
    axes[0, 1].set_xlabel("Step")
    axes[0, 1].set_ylabel("Cumulative Visits")
    axes[0, 1].set_title("Cumulative Visits Over Time")
    axes[0, 1].legend()
    axes[0, 1].grid(True, alpha=0.3)
    
    # Plot 3: Learning parameters over time
    axes[1, 0].plot(model_data.index, model_data['avg_resource_attraction'], 
                    label='Resource Attraction', color='green', linewidth=2)
    axes[1, 0].plot(model_data.index, model_data['avg_toxic_avoidance'], 
                    label='Toxic Avoidance', color='red', linewidth=2)
    axes[1, 0].set_xlabel("Step")
    axes[1, 0].set_ylabel("Average Learning Parameter")
    axes[1, 0].set_title("Learning Evolution Over Time")
    axes[1, 0].legend()
    axes[1, 0].grid(True, alpha=0.3)
    
    # Plot 4: Exploration rate over time
    axes[1, 1].plot(model_data.index, model_data['avg_exploration_rate'], 
                    label='Exploration Rate', color='blue', linewidth=2)
    axes[1, 1].set_xlabel("Step")
    axes[1, 1].set_ylabel("Average Exploration Rate")
    axes[1, 1].set_title("Exploration vs Exploitation Over Time")
    axes[1, 1].legend()
    axes[1, 1].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.show()
    
    # Print summary statistics
    print("\n=== SIMULATION SUMMARY ===")
    print(f"Final resource attraction: {model_data['avg_resource_attraction'].iloc[-1]:.3f}")
    print(f"Final toxic avoidance: {model_data['avg_toxic_avoidance'].iloc[-1]:.3f}")
    print(f"Final exploration rate: {model_data['avg_exploration_rate'].iloc[-1]:.3f}")
    print(f"Total resource visits: {model_data['total_resource_visits'].iloc[-1]}")
    print(f"Total toxic visits: {model_data['total_toxic_visits'].iloc[-1]}")
    
    # Calculate visit ratios
    resource_ratio = model_data['total_resource_visits'].iloc[-1] / model_data.index[-1] if model_data.index[-1] > 0 else 0
    toxic_ratio = model_data['total_toxic_visits'].iloc[-1] / model_data.index[-1] if model_data.index[-1] > 0 else 0
    
    print(f"Resource visits per step: {resource_ratio:.3f}")
    print(f"Toxic visits per step: {toxic_ratio:.3f}")

# Run the improved model
if __name__ == "__main__":
    print("Running Learning Walker Model...")
    model = LearningWalkerModel(width=20, height=20, n_steps=200, num_agents=10)
    model_data = model.run_model()
    
    print("\nAnalyzing results...")
    analyze_results(model_data)
```

