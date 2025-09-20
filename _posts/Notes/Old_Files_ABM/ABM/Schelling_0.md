# From Random Walks to Social Segregation: The Schelling Model

In our previous exploration of random walks, we witnessed how simple movement rules could generate complex, unpredictable patterns. A single agent following one basic instruction—move randomly to a neighboring cell—created trajectories that appeared chaotic yet revealed underlying statistical properties. Now we venture into more sophisticated territory, where individual preferences and social dynamics intersect to produce one of the most striking examples of emergence in social science: the Schelling segregation model.

Thomas Schelling's groundbreaking work in the 1970s demonstrated how even mild preferences for similar neighbors could lead to dramatic residential segregation. Unlike our random walker, who moved without purpose or preference, Schelling agents possess desires and make decisions based on their local social environment. This transition from pure randomness to preference-driven behavior marks a fundamental shift in complexity, revealing how individual choices aggregate into system-wide patterns that often surprise even the agents themselves.

## The Mechanics of Social Preference

The Schelling model operates on a deceptively simple premise: agents belonging to different groups prefer to live near others who share their characteristics. This preference need not be extreme—agents don't require complete homogeneity in their neighborhood, merely a certain threshold of similarity. The mathematical formalization captures this elegantly through a similarity ratio S_i for agent i:

S_i = N_similar,i / N_total,i

where N_similar,i represents the number of neighbors sharing agent i's type, and N_total,i denotes the total number of neighbors. Agent i remains content when S_i ≥ τ, where τ represents the similarity threshold. When this condition fails, the agent seeks a new location where greater similarity might be found.

The agent's decision-making process translates directly into code through the step method:

```python
def step(self) -> None:
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
```

This formulation reveals the model's power: the threshold τ serves as a control parameter that governs the strength of segregation preferences. Setting τ = 0.3 means agents require only 30% of their neighbors to share their type—a remarkably tolerant stance. Yet even this mild preference can generate surprising outcomes when scaled across an entire population.

The neighborhood definition itself merits attention. Using Moore neighborhoods—the eight cells surrounding each agent—creates local interaction patterns that mirror real-world social geography. Each agent's decision depends entirely on immediate neighbors, embodying the principle of local interaction that characterizes many social phenomena. This locality constraint ensures that global patterns emerge from purely local processes, making the model's outcomes genuinely emergent rather than predetermined.

## Implementation Architecture and Design Decisions

Our Mesa implementation builds upon the foundation established in the random walk tutorial while introducing several sophisticated enhancements. The `SchellingAgent` class now carries state—specifically, an agent type that determines group membership. This seemingly minor addition fundamentally alters the model's dynamics, transforming aimless wandering into purposeful relocation based on social preferences.

```python
class SchellingAgent(Agent):
    def __init__(self, unique_id: int, model: 'SchellingModel', agent_type: int):
        super().__init__(unique_id, model)
        self.type = agent_type
```

The agent's decision-making process encapsulates the core behavioral logic through the step method. Each agent surveys its immediate neighborhood, calculates the proportion of similar neighbors, and compares this ratio against the similarity threshold. When dissatisfaction occurs—when the local similarity falls below the threshold—the agent initiates a search for a more congenial location. This search process selects randomly from available empty cells, introducing an element of contingency that prevents the model from reaching overly deterministic outcomes.

The `SchellingModel` class orchestrates the complex interplay between individual decisions and collective outcomes. The model initializes by randomly distributing agents across the grid according to specified density and minority proportion parameters:

```python
def _place_agents(self) -> None:
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
```

This random initialization ensures that any subsequent segregation patterns result from the agents' behavioral rules rather than biased starting conditions. The grid topology remains toroidal, eliminating edge effects that might artificially constrain agent movement patterns.

Data collection mechanisms have evolved significantly from our simple random walk implementation. The model now tracks two key metrics: the overall segregation level and the total number of agent moves:

```python
self.datacollector = DataCollector(
    model_reporters={
        "Segregation": self.calculate_segregation,
        "Total_Moves": self.count_total_moves
    }
)
```

The segregation measure aggregates individual similarity ratios across all agents, providing a system-level indicator of residential homogeneity:

```python
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
```

This aggregate measure enables us to quantify emergent phenomena that would be invisible when examining individual agents in isolation.

## The Emergence of Segregated Patterns

When we execute the Schelling model with moderate parameters—say, a 20×20 grid with 80% density, 30% minority agents, and a 60% similarity threshold—the results often prove startling. Despite the seemingly tolerant preferences (agents accept neighborhoods where 40% of neighbors differ from themselves), distinct clusters of similar agents emerge over time. These clusters grow and consolidate as dissatisfied agents relocate, creating increasingly homogeneous neighborhoods.

The mathematical intuition behind this emergence centers on the concept of cascading effects. Consider an initially random distribution where most agents find themselves satisfied with their local similarity ratios. A small number of agents, perhaps those unlucky enough to land in particularly diverse neighborhoods, become dissatisfied and move. Their departure slightly alters the composition of their former neighborhoods, potentially pushing some previously satisfied agents below the similarity threshold. These newly dissatisfied agents then relocate, continuing the cascade.

This process exhibits positive feedback: each relocation potentially creates new dissatisfaction elsewhere while simultaneously increasing homogeneity in the destination neighborhood. The system evolves toward configurations where most agents achieve their desired similarity levels, but this individual satisfaction comes at the cost of global segregation that likely exceeds what any individual agent intended or desired.

The temporal dynamics reveal additional complexity. Early simulation steps often show rapid changes as many agents discover their initial placements unsatisfactory. Movement rates typically peak in these early phases, then gradually decline as agents find suitable neighborhoods. However, the system rarely reaches perfect equilibrium—periodic relocations continue as changing neighborhood compositions create new dissatisfactions. This ongoing turnover reflects the inherent instability of social systems where individual preferences interact through spatial constraints.

## Quantifying Segregation Dynamics

The mathematical analysis of Schelling dynamics has generated substantial theoretical insights. The segregation index S(t) = Σᵢ Sᵢ(t)/N provides a global measure of residential homogeneity, where the sum extends over all N agents at time t. This index ranges from theoretical limits determined by the minority proportion and spatial constraints.

For a system with minority proportion p and majority proportion (1-p), perfect random mixing would yield an expected segregation index of:

S_random = p² + (1-p)²

This baseline represents the segregation level that would arise purely by chance in a well-mixed population. Values of S(t) substantially exceeding S_random indicate genuine segregation beyond random clustering.

The threshold parameter τ critically influences both the final segregation level and the dynamics of reaching that state. Higher threshold values—indicating stronger preferences for similarity—naturally produce more segregated outcomes. However, the relationship between τ and final segregation proves nonlinear, with small increases in the threshold sometimes producing disproportionately large increases in segregation. This nonlinearity suggests the existence of critical threshold values where the system's behavior undergoes qualitative changes.

Agent heterogeneity adds another layer of complexity. In our basic implementation, all agents share identical similarity thresholds, but real populations exhibit diverse tolerance levels. Some individuals strongly prefer homogeneous neighborhoods while others actively seek diversity. Incorporating threshold heterogeneity can significantly alter model dynamics, sometimes reducing overall segregation as diversity-seeking agents act as "bridges" between different groups.

The spatial structure of segregation also merits attention. Clustered segregation—where similar agents form contiguous neighborhoods—differs qualitatively from scattered segregation where similar agents concentrate in disconnected pockets. The Schelling model typically produces clustered patterns, as agents can more easily achieve high similarity ratios by joining existing clusters rather than forming new ones. This clustering tendency reflects the efficiency of spatial proximity in social organization.

## Extensions and Variations

The canonical Schelling model admits numerous extensions that illuminate different aspects of segregation dynamics. Multi-group extensions replace the binary agent classification with multiple types, examining how segregation patterns change when three, four, or more groups compete for residential space. These extensions reveal interesting dynamics: sometimes intermediate groups become "buffer zones" between more distinct populations, while in other configurations, minority groups form coalitions against dominant majorities.

Economic constraints provide another avenue for model extension. Real housing markets involve financial considerations that can either amplify or mitigate segregation tendencies. Agents with limited economic resources face restricted housing choices, potentially forcing them to accept less preferred neighborhood compositions. Conversely, wealth disparities can enable some groups to monopolize desirable areas, creating segregation patterns that transcend mere social preferences.

Network-based variations replace the regular grid topology with more realistic social networks. Instead of caring only about immediate spatial neighbors, agents might respond to the composition of their broader social networks, including friends, colleagues, and family members. These network effects can create segregation patterns that persist even when residential segregation decreases, highlighting the multiple dimensions along which social separation can occur.

Dynamic preferences represent a particularly intriguing extension. Rather than maintaining fixed similarity thresholds throughout the simulation, agents might adjust their preferences based on experience. Agents who successfully find satisfying neighborhoods might become more tolerant over time, while those who repeatedly face rejection might develop stronger preferences for similarity. Such adaptive mechanisms could either stabilize or destabilize segregation patterns, depending on the specific adaptation rules employed.

## Policy Implications and Interventions

The Schelling model's insights extend far beyond academic curiosity, offering valuable perspectives on real-world segregation and potential policy interventions. If mild individual preferences can generate substantial segregation, then reducing segregation might require interventions that address either the preferences themselves or the mechanisms through which those preferences operate.

Housing policy represents one intervention domain. Regulations that promote mixed-income housing developments or prevent discriminatory practices might disrupt the feedback loops that sustain segregated patterns. However, the model suggests that such interventions must be carefully designed—simply mandating diversity without addressing underlying preferences might create unstable situations where agents continuously relocate to escape unwanted heterogeneity.

Information and social contact provide alternative intervention strategies. If segregation partly results from limited inter-group contact that reinforces stereotypes and preferences for similarity, then policies promoting interaction across group boundaries might gradually reduce segregation preferences. Schools, workplaces, and community organizations could serve as venues for such cross-cutting interactions.

The model also illuminates the challenge of unintended consequences in social policy. Well-intentioned interventions might sometimes backfire by creating new incentives for segregation or by concentrating problems in particular areas. Understanding the complex feedback loops inherent in social systems becomes crucial for designing effective policies.

## Computational Considerations and Future Directions

From a computational perspective, the Schelling model demonstrates how object-oriented programming principles facilitate complex social simulations. The clear separation between agent behavior and model coordination makes the code both readable and extensible. The modular design allows researchers to easily modify individual components—changing decision rules, spatial structures, or measurement techniques—without restructuring the entire simulation.

The visualization capabilities highlight another important aspect of agent-based modeling: the ability to directly observe emergent patterns as they unfold. The implementation includes sophisticated visualization tools that capture both spatial patterns and temporal dynamics:

```python
@staticmethod
def extract_grid(model: SchellingModel) -> np.ndarray:
    grid = np.zeros((model.width, model.height))
    for x in range(model.width):
        for y in range(model.height):
            agents = model.grid.get_cell_list_contents([(x, y)])
            if agents:
                grid[x, y] = agents[0].type + 1  # 1 or 2 for agents
            else:
                grid[x, y] = 0  # 0 for empty
    return grid
```

The complete simulation workflow demonstrates how these components integrate:

```python
def run_schelling_model(
    width: int = 20,
    height: int = 20,
    density: float = 0.8,
    minority_pc: float = 0.3,
    similarity_threshold: float = 0.6,
    steps: int = 50
) -> SchellingModel:

    model = SchellingModel(
        width=width,
        height=height,
        density=density,
        minority_pc=minority_pc,
        similarity_threshold=similarity_threshold
    )

    grids = [SchellingVisualizer.extract_grid(model)]

    for i in range(steps):
        model.step()
        if i in [10, steps - 1]:
            grids.append(SchellingVisualizer.extract_grid(model))

    SchellingVisualizer.plot_grids(grids)
    seg_data = model.datacollector.get_model_vars_dataframe()
    SchellingVisualizer.plot_segregation(seg_data)

    return model
```

Unlike mathematical models that provide analytical solutions, agent-based simulations generate dynamic visualizations that can reveal unexpected behaviors and provide intuitive understanding of complex processes. The animated visualizations of segregation formation often prove more convincing than statistical measures alone.

Performance considerations become important as model complexity increases. While our basic implementation handles modest grid sizes efficiently, extensions involving multiple agent types, complex decision rules, or detailed spatial environments might require optimization strategies. Parallel processing, efficient data structures, and careful algorithm design become crucial for maintaining reasonable execution times as model sophistication grows.

## Connecting Theory and Reality

The Schelling model's enduring influence stems from its ability to connect abstract theoretical insights with observable real-world phenomena. Residential segregation remains a persistent feature of many societies, and the model provides one compelling explanation for how such patterns might arise and persist even in the absence of explicit discriminatory policies or extreme prejudices.

However, the model also illustrates the limitations of simplified representations. Real segregation involves complex historical, economic, and institutional factors that the basic Schelling framework ignores. Discriminatory lending practices, zoning regulations, transportation systems, and employment patterns all influence residential choices in ways that pure preference-based models cannot capture. The model serves as a starting point for understanding segregation, not a complete explanation.

This tension between simplicity and realism represents a fundamental challenge in agent-based modeling. Simple models offer clear insights and robust predictions but risk oversimplifying complex phenomena. Detailed models might capture more realistic behaviors but become difficult to understand and analyze. The art of modeling lies in finding the appropriate balance between simplicity and complexity for addressing specific research questions.

## Emergence and Individual Responsibility

Perhaps the most profound insight from the Schelling model concerns the relationship between individual actions and collective outcomes. The model demonstrates how individually rational and even tolerant preferences can generate collectively problematic patterns. No single agent intends to create a segregated society—each simply seeks a comfortable neighborhood composition. Yet the aggregation of these reasonable individual decisions produces system-wide segregation that might disadvantage everyone.

This disconnect between individual intentions and collective outcomes raises important questions about responsibility and intervention in social systems. If segregation emerges from the interaction of individual preferences rather than explicit discriminatory policies, how should society address such patterns? The model suggests that changing outcomes might require changing either individual preferences or the structural constraints within which those preferences operate.

The emergence of segregation from tolerance also challenges common intuitions about social problems. We might expect that moderate, tolerant attitudes would produce moderate, integrated outcomes. The Schelling model reveals how nonlinear social dynamics can amplify mild preferences into extreme patterns, suggesting that maintaining integrated communities might require more active effort than simple tolerance.

Understanding these dynamics becomes particularly important in an era of increasing social and political polarization. If the basic mechanisms that drive residential segregation also operate in other social domains—political affiliation, media consumption, social networking—then we might expect to see similar clustering patterns across multiple dimensions of social life. The model provides a framework for understanding how individual choices about social environments can create broader patterns of social division.

The Schelling model thus serves as both a specific analysis of residential segregation and a general illustration of how social systems can generate unintended consequences from reasonable individual behaviors. It exemplifies the power of agent-based modeling to reveal counterintuitive dynamics and challenge conventional wisdom about social phenomena. As we continue exploring agent-based approaches to social problems, the Schelling model reminds us that understanding individual behavior represents only the first step—the real challenge lies in comprehending how those individual behaviors interact to produce the complex social world we observe around us.


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
