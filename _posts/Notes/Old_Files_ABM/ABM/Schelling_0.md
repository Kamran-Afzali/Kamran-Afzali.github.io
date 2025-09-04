# Understanding Social Segregation: The Schelling Model in Mesa

From the chaotic beauty of random walks, we turn our attention to one of the most profound and unsettling phenomena in social science: the emergence of segregation from seemingly innocuous individual preferences. Thomas Schelling's groundbreaking model, first introduced in the 1970s, demonstrated how even mild preferences for similarity could lead to dramatic patterns of residential segregation—a finding that fundamentally changed our understanding of how individual choices aggregate into societal outcomes.

This tutorial presents a sophisticated implementation of the Schelling segregation model using Mesa, showcasing advanced software engineering practices while exploring one of the most important models in computational social science. Unlike our previous random walk exploration, where agents moved without purpose or preference, here we encounter agents with clear motivations whose collective behavior reveals the hidden dynamics of social sorting.

## The Schelling Model: A Window into Social Dynamics

The genius of Schelling's model lies in its simplicity and its shocking implications. Imagine a neighborhood where residents have only a modest preference for living near others who share their characteristics—perhaps they want just 30% or 40% of their neighbors to be similar to themselves. Intuitively, this mild preference seems harmless, even reasonable. Yet Schelling showed that such preferences, when aggregated across many individuals, can produce nearly complete segregation.

This counterintuitive result illustrates a fundamental principle in complex systems: macro-level patterns often bear little resemblance to the micro-level rules that generate them. Individual tolerance can coexist with collective intolerance, and understanding this paradox is crucial for anyone seeking to comprehend social phenomena, urban planning, or organizational dynamics.

## Professional Implementation Architecture

Our Mesa implementation demonstrates several advanced software engineering practices that make the code not just functional but maintainable, extensible, and production-ready. These architectural decisions reflect best practices in scientific computing and show how thoughtful design enables more sophisticated research.

### Type-Annotated Agent Design

```python
class SchellingAgent(Agent):
    def __init__(self, unique_id: int, model: 'SchellingModel', agent_type: int):
        super().__init__(unique_id, model)
        self.type = agent_type
    
    def step(self) -> None:
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False
        )
        
        if not neighbors:
            return
        
        similar = sum(1 for neighbor in neighbors if neighbor.type == self.type)
        similarity_ratio = similar / len(neighbors)
        
        if similarity_ratio < self.model.similarity_threshold:
            self._move_to_empty_cell()
```

Our agent implementation showcases several professional practices. Type annotations make the code more readable and enable better IDE support and error detection. The separation of concerns between neighbor analysis and movement decisions creates modular, testable code. The early return pattern when no neighbors exist demonstrates defensive programming that prevents division by zero errors.

The agent's decision-making process mirrors the psychological reality Schelling described: agents evaluate their local environment, calculate their satisfaction based on neighbor similarity, and respond by relocating if unhappy. This local decision-making, replicated across many agents, generates the global patterns we observe.

### Sophisticated Model Architecture

```python
class SchellingModel(Model):
    def __init__(
        self,
        width: int = 20,
        height: int = 20,
        density: float = 0.8,
        minority_pc: float = 0.3,
        similarity_threshold: float = 0.6
    ):
        super().__init__()
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)
        
        self.datacollector = DataCollector(
            model_reporters={
                "Segregation": self.calculate_segregation,
                "Total_Moves": self.count_total_moves
            }
        )
```

The model class demonstrates professional parameter handling with meaningful defaults and comprehensive type hints. The initialization process is clean and follows a logical sequence: create environment, initialize schedulers, set up data collection, then populate with agents. This pattern scales well and makes the code easy to understand and modify.

### Advanced Data Collection Strategy

Our data collection approach goes beyond simple position tracking to capture the essential dynamics of segregation:

```python
def calculate_segregation(self) -> float:
    total_similar = 0
    total_neighbors = 0
    
    for agent in self.schedule.agents:
        neighbors = self.grid.get_neighbors(
            agent.pos, moore=True, include_center=False
        )
        
        if neighbors:
            similar = sum(1 for neighbor in neighbors if neighbor.type == agent.type)
            total_similar += similar
            total_neighbors += len(neighbors)
    
    return total_similar / total_neighbors if total_neighbors > 0 else 0.0
```

This metric captures the core phenomenon Schelling identified: the proportion of similar neighbors across all agents. By aggregating individual similarity ratios, we get a system-level measure that tracks how segregated the population becomes over time. Values near 0.5 indicate integration, while values approaching 1.0 reveal high segregation.

## Professional Visualization Framework

The visualization system demonstrates another level of software sophistication, separating visualization logic from model logic and providing multiple analytical views:

```python
class SchellingVisualizer:
    COLOR_MAP = plt.get_cmap('viridis', 3)
    TITLES = ["Initial", "Step 10", "Final"]
    
    @staticmethod
    def extract_grid(model: SchellingModel) -> np.ndarray:
        grid = np.zeros((model.width, model.height))
        for x in range(model.width):
            for y in range(model.height):
                agents = model.grid.get_cell_list_contents([(x, y)])
                if agents:
                    grid[x, y] = agents[0].type + 1
                else:
                    grid[x, y] = 0
        return grid
```

This design pattern separates data extraction from visualization, making the code more modular and testable. The static methods can be called without instantiating the class, and the grid extraction function creates a clean numerical representation perfect for analysis or alternative visualization approaches.

## The Complete Professional Implementation

Here's our sophisticated Schelling model with all architectural improvements:

```python
import numpy as np
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector
from typing import List, Tuple, Optional
import logging

class SchellingAgent(Agent):
    def __init__(self, unique_id: int, model: 'SchellingModel', agent_type: int):
        super().__init__(unique_id, model)
        self.type = agent_type

    def step(self) -> None:
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False
        )

        if not neighbors:
            return

        similar = sum(1 for neighbor in neighbors if neighbor.type == self.type)
        similarity_ratio = similar / len(neighbors)
        
        if similarity_ratio < self.model.similarity_threshold:
            self._move_to_empty_cell()

    def _move_to_empty_cell(self) -> None:
        empty_cells = list(self.model.grid.empties)
        if empty_cells:
            new_pos = self.random.choice(empty_cells)
            self.model.grid.move_agent(self, new_pos)

class SchellingModel(Model):
    def __init__(
        self,
        width: int = 20,
        height: int = 20,
        density: float = 0.8,
        minority_pc: float = 0.3,
        similarity_threshold: float = 0.6
    ):
        super().__init__()
        self.width = width
        self.height = height
        self.density = density
        self.minority_pc = minority_pc
        self.similarity_threshold = similarity_threshold

        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)

        self.datacollector = DataCollector(
            model_reporters={
                "Segregation": self.calculate_segregation,
                "Total_Moves": self.count_total_moves
            }
        )

        self._place_agents()
        self.total_moves = 0

    def _place_agents(self) -> None:
        agent_id = 0
        num_agents = int(self.width * self.height * self.density)

        for _ in range(num_agents):
            agent_type = 1 if self.random.random() < self.minority_pc else 0
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)

            agent = SchellingAgent(agent_id, self, agent_type)
            self.grid.place_agent(agent, (x, y))
            self.schedule.add(agent)
            agent_id += 1

    def calculate_segregation(self) -> float:
        if not self.schedule.agents:
            return 0.0

        total_similar = 0
        total_neighbors = 0

        for agent in self.schedule.agents:
            neighbors = self.grid.get_neighbors(
                agent.pos, moore=True, include_center=False
            )

            if neighbors:
                similar = sum(1 for neighbor in neighbors if neighbor.type == agent.type)
                total_similar += similar
                total_neighbors += len(neighbors)

        return total_similar / total_neighbors if total_neighbors > 0 else 0.0

    def count_total_moves(self) -> int:
        return self.total_moves

    def step(self) -> None:
        self.datacollector.collect(self)
        self.schedule.step()
        self.total_moves += 1
```

## Understanding Emergent Segregation Patterns

When you run this simulation, the results are often startling. Starting from a randomly integrated population, within just a few dozen time steps, distinct clusters of similar agents emerge. The visualization reveals how individual preferences aggregate into collective patterns that appear far more extreme than any individual intended.

### The Dynamics of Unhappiness

The model reveals how unhappiness propagates through the system. When an agent moves to escape an unsatisfactory neighborhood, they potentially make their former neighbors happier while possibly displacing satisfaction in their new location. These cascading effects create feedback loops that can either stabilize into integrated equilibria or spiral toward high segregation.

### Tipping Points and Phase Transitions

One of the most important insights from Schelling's work involves tipping points—threshold values of the similarity preference that dramatically change system behavior. With very low thresholds (agents barely caring about neighbor similarity), integration persists. But above a critical threshold, even modest preferences trigger cascading segregation processes that reshape the entire population distribution.

Our implementation makes exploring these phase transitions straightforward by parameterizing the similarity threshold and other key variables. Researchers can systematically vary parameters to map the boundary between integration and segregation regimes.

## Research Applications and Policy Implications

The Schelling model transcends academic interest to address urgent real-world challenges. Urban planners use variants to understand residential segregation patterns and design interventions. Organizational researchers apply similar logic to workplace diversity and team formation. Economists study how preference structures affect market segmentation and consumer behavior.

### Housing Policy Insights

The model suggests that combating segregation requires more than addressing overt discrimination—it demands understanding how seemingly reasonable individual preferences create problematic collective outcomes. Policies aimed at maintaining integration must account for these dynamics, possibly requiring sustained intervention rather than one-time fixes.

### Educational Applications

School choice policies often exhibit Schelling-like dynamics, where parents' modest preferences for certain school characteristics can lead to dramatic sorting patterns. The model provides a framework for anticipating these outcomes and designing choice systems that promote rather than undermine integration.

### Organizational Design

In corporate settings, understanding how employee preferences for team composition affect departmental diversity can inform hiring practices, team formation strategies, and workplace culture initiatives. The model's insights about tipping points are particularly relevant for maintaining diverse work environments.

## Technical Extensions and Advanced Research

Our professional implementation provides a foundation for numerous extensions that could advance both the technical sophistication and research applications of the model:

### Network-Based Segregation

Extending the model from grid-based neighborhoods to arbitrary network structures could illuminate segregation in social media, professional networks, or friendship patterns. The same preference dynamics might operate differently when relationships are non-spatial.

### Multi-Group Dynamics

While our implementation focuses on binary group distinctions, real-world segregation often involves multiple groups with complex preference patterns. Extending to three or more groups reveals richer dynamics and more realistic policy scenarios.

### Dynamic Preferences

Allowing similarity preferences to evolve based on experience—perhaps becoming more tolerant through positive inter-group contact—could model intervention strategies and social learning processes.

### Economic Constraints

Adding housing costs, income differences, or mobility limitations would create more realistic models that capture how economic factors interact with preference-driven sorting.

## Performance Optimization and Scalability

Our implementation demonstrates several performance considerations crucial for larger-scale research:

```python
def _move_to_empty_cell(self) -> None:
    empty_cells = list(self.model.grid.empties)
    if empty_cells:
        new_pos = self.random.choice(empty_cells)
        self.model.grid.move_agent(self, new_pos)
```

The use of Mesa's built-in `empties` property efficiently tracks available locations without requiring expensive grid searches. For very large populations, additional optimizations might include spatial indexing for neighbor searches or parallel processing of agent updates.

## Visualization and Analysis Tools

The integrated visualization framework provides multiple analytical perspectives:

```python
class SchellingVisualizer:
    @classmethod
    def plot_grids(cls, grids: List[np.ndarray]) -> None:
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))
        for ax, grid, title in zip(axes, grids, cls.TITLES):
            im = ax.imshow(grid, cmap=cls.COLOR_MAP)
            ax.set_title(title)
        plt.tight_layout()
        plt.show()
```

This approach creates compelling before-and-after comparisons that make the segregation process viscerally apparent. The progression from random integration to clustered segregation provides immediate visual confirmation of the model's key insights.

## Statistical Analysis Opportunities

The rich dataset generated by our implementation enables sophisticated statistical analysis:

**Segregation Trajectories**: Tracking how segregation measures evolve over time reveals whether systems reach stable equilibria or exhibit ongoing dynamics.

**Parameter Sensitivity**: Systematic variation of threshold values, population composition, and density parameters can map the model's behavior space and identify critical tipping points.

**Spatial Pattern Analysis**: Beyond aggregate segregation measures, spatial statistics can characterize cluster sizes, shapes, and distributions, providing insights into different types of segregation patterns.

**Movement Pattern Studies**: Analyzing agent relocation patterns—who moves, when, and where—can reveal the micro-dynamics that drive macro-patterns.

## Conclusion: From Individual Choices to Collective Outcomes

The Schelling segregation model stands as one of the most important contributions to our understanding of social phenomena. It demonstrates how reasonable individual behavior can produce unreasonable collective outcomes, how micro-motives can create macro-patterns that no individual intended or desired.

Our sophisticated Mesa implementation not only reproduces Schelling's original insights but provides a platform for extending his work into new domains and applications. The professional software architecture—with its type annotations, modular design, comprehensive data collection, and integrated visualization—demonstrates how good scientific computing practices enable better research.

The model's enduring relevance reflects its fundamental insight: understanding social systems requires looking beyond individual behavior to examine how individual actions aggregate into collective patterns. In our increasingly connected and complex world, this perspective has never been more crucial.

Whether applied to residential segregation, educational choice, workplace diversity, or online community formation, the Schelling model provides both a warning and a tool. It warns us that good intentions at the individual level don't guarantee good outcomes at the collective level. But it also provides a tool for understanding these dynamics and potentially designing interventions that align individual incentives with collective welfare.

The path from individual tolerance to collective segregation is neither inevitable nor irreversible—but it requires understanding the hidden dynamics that our model reveals. Through careful analysis of how micro-preferences aggregate into macro-patterns, we can better navigate the complex relationship between individual choice and collective outcomes that defines so much of social life.

In the end, the Schelling model teaches us that emergence isn't just a feature of random systems or physical phenomena—it's a fundamental characteristic of social life that demands our attention, understanding, and thoughtful response.

```python
"""
Schelling Segregation Model
"""

import numpy as np
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector
from typing import List, Tuple, Optional
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SchellingAgent(Agent):
    """
    An agent in the Schelling segregation model.

    Attributes:
        unique_id: Unique identifier for the agent
        model: Reference to the model instance
        type: Agent type (0 or 1, representing different groups)
    """

    def __init__(self, unique_id: int, model: 'SchellingModel', agent_type: int):
        """
        Initialize a Schelling agent.

        Args:
            unique_id: Unique identifier for the agent
            model: Reference to the model instance
            agent_type: Agent type (0 or 1)
        """
        super().__init__(unique_id, model)
        self.type = agent_type

    def step(self) -> None:
        """
        Agent's behavior for each step:
        - Calculate similarity ratio with neighbors
        - Move if unhappy (similarity < threshold)
        """
        # Get neighbors
        neighbors = self.model.grid.get_neighbors(
            self.pos, moore=True, include_center=False
        )

        if not neighbors:
            return  # No neighbors to compare with

        # Count similar neighbors
        similar = sum(1 for neighbor in neighbors if neighbor.type == self.type)

        # Check if agent is unhappy
        similarity_ratio = similar / len(neighbors)
        if similarity_ratio < self.model.similarity_threshold:
            self._move_to_empty_cell()

    def _move_to_empty_cell(self) -> None:
        """Move agent to a random empty cell if available."""
        empty_cells = list(self.model.grid.empties)
        if empty_cells:
            new_pos = self.random.choice(empty_cells)
            self.model.grid.move_agent(self, new_pos)


class SchellingModel(Model):
    """
    Schelling segregation model.

    Attributes:
        width: Width of the grid
        height: Height of the grid
        density: Proportion of cells occupied by agents
        minority_pc: Proportion of minority agents
        similarity_threshold: Minimum similarity ratio for agent happiness
        grid: MultiGrid environment
        schedule: Activation schedule for agents
        datacollector: Data collection utility
    """

    def __init__(
        self,
        width: int = 20,
        height: int = 20,
        density: float = 0.8,
        minority_pc: float = 0.3,
        similarity_threshold: float = 0.6
    ):
        """
        Initialize the Schelling model.

        Args:
            width: Width of the grid
            height: Height of the grid
            density: Proportion of cells occupied by agents
            minority_pc: Proportion of minority agents
            similarity_threshold: Minimum similarity ratio for happiness
        """
        super().__init__()

        # Model parameters
        self.width = width
        self.height = height
        self.density = density
        self.minority_pc = minority_pc
        self.similarity_threshold = similarity_threshold

        # Initialize model components
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)

        # Data collection
        self.datacollector = DataCollector(
            model_reporters={
                "Segregation": self.calculate_segregation,
                "Total_Moves": self.count_total_moves
            }
        )

        # Initialize agents
        self._place_agents()

        # Track metrics
        self.total_moves = 0

    def _place_agents(self) -> None:
        """Place agents randomly on the grid."""
        agent_id = 0
        num_agents = int(self.width * self.height * self.density)

        for _ in range(num_agents):
            # Determine agent type
            agent_type = 1 if self.random.random() < self.minority_pc else 0

            # Find empty position
            x = self.random.randrange(self.width)
            y = self.random.randrange(self.height)

            # Create and place agent
            agent = SchellingAgent(agent_id, self, agent_type)
            self.grid.place_agent(agent, (x, y))
            self.schedule.add(agent)
            agent_id += 1

    def calculate_segregation(self) -> float:
        """
        Calculate the average proportion of similar neighbors across all agents.

        Returns:
            Average similarity ratio (0-1)
        """
        if not self.schedule.agents:
            return 0.0

        total_similar = 0
        total_neighbors = 0

        for agent in self.schedule.agents:
            neighbors = self.grid.get_neighbors(
                agent.pos, moore=True, include_center=False
            )

            if neighbors:
                similar = sum(1 for neighbor in neighbors if neighbor.type == agent.type)
                total_similar += similar
                total_neighbors += len(neighbors)

        return total_similar / total_neighbors if total_neighbors > 0 else 0.0

    def count_total_moves(self) -> int:
        """
        Count total moves made by agents.

        Returns:
            Total number of moves
        """
        return self.total_moves

    def step(self) -> None:
        """Execute one step of the model."""
        self.datacollector.collect(self)
        self.schedule.step()
        self.total_moves += 1


class SchellingVisualizer:
    """Handles visualization of the Schelling model."""

    COLOR_MAP = plt.get_cmap('viridis', 3)
    TITLES = ["Initial", "Step 10", "Final"]

    @staticmethod
    def extract_grid(model: SchellingModel) -> np.ndarray:
        """
        Extract grid state as a numpy array for visualization.

        Args:
            model: SchellingModel instance

        Returns:
            2D numpy array representing grid state
        """
        grid = np.zeros((model.width, model.height))
        for x in range(model.width):
            for y in range(model.height):
                agents = model.grid.get_cell_list_contents([(x, y)])
                if agents:
                    grid[x, y] = agents[0].type + 1  # 1 or 2 for agents
                else:
                    grid[x, y] = 0  # 0 for empty
        return grid

    @classmethod
    def plot_grids(cls, grids: List[np.ndarray]) -> None:
        """
        Plot grid states at different time steps.

        Args:
            grids: List of grid arrays to plot
        """
        fig, axes = plt.subplots(1, 3, figsize=(15, 5))

        for ax, grid, title in zip(axes, grids, cls.TITLES):
            im = ax.imshow(grid, cmap=cls.COLOR_MAP)
            ax.set_title(title)
            ax.set_xticks([])
            ax.set_yticks([])

        plt.tight_layout()
        plt.show()

    @staticmethod
    def plot_segregation(data_frame) -> None:
        """
        Plot segregation measure over time.

        Args:
            data_frame: Pandas DataFrame with collected data
        """
        plt.figure(figsize=(10, 6))
        plt.plot(data_frame["Segregation"], linewidth=2)
        plt.title("Segregation Over Time", fontsize=14)
        plt.xlabel("Step", fontsize=12)
        plt.ylabel("Proportion of Similar Neighbors", fontsize=12)
        plt.grid(True, alpha=0.3)
        plt.tight_layout()
        plt.show()


def run_schelling_model(
    width: int = 20,
    height: int = 20,
    density: float = 0.8,
    minority_pc: float = 0.3,
    similarity_threshold: float = 0.6,
    steps: int = 50
) -> SchellingModel:
    """
    Run the Schelling segregation model.

    Args:
        width: Grid width
        height: Grid height
        density: Proportion of occupied cells
        minority_pc: Proportion of minority agents
        similarity_threshold: Minimum similarity for happiness
        steps: Number of simulation steps

    Returns:
        Completed SchellingModel instance
    """
    # Initialize model
    model = SchellingModel(
        width=width,
        height=height,
        density=density,
        minority_pc=minority_pc,
        similarity_threshold=similarity_threshold
    )

    # Collect initial state
    grids = [SchellingVisualizer.extract_grid(model)]

    # Run simulation
    for i in range(steps):
        model.step()

        # Save intermediate states
        if i in [10, steps - 1]:
            grids.append(SchellingVisualizer.extract_grid(model))

    # Visualize results
    SchellingVisualizer.plot_grids(grids)

    # Plot segregation data
    seg_data = model.datacollector.get_model_vars_dataframe()
    SchellingVisualizer.plot_segregation(seg_data)

    return model


if __name__ == "__main__":
    # Model parameters
    CONFIG = {
        'width': 20,
        'height': 20,
        'density': 0.8,
        'minority_pc': 0.3,
        'similarity_threshold': 0.6,
        'steps': 50
    }

    # Run model
    logger.info("Starting Schelling segregation model...")
    model = run_schelling_model(**CONFIG)
    logger.info("Model execution completed.")
```
