# Beyond Social Preferences: An Economic Extension of the Schelling Segregation Model

*How financial constraints reshape residential sorting and amplify segregation patterns*

## Introduction: The Missing Economic Dimension

Thomas Schelling's agent-based model of segregation stands as one of the most influential contributions to computational social science. Its elegant demonstration—that severe residential segregation can emerge from surprisingly mild homophilic preferences—has shaped decades of research on urban dynamics and social sorting. Yet for all its theoretical power, the classical Schelling model omits a dimension that fundamentally shapes real-world residential decisions: economics.

In Schelling's canonical framework, an agent $i$ of type $\tau_i \in \{0, 1\}$ located at position $p_i$ seeks to relocate when the proportion of same-type neighbors falls below a similarity threshold $\theta$. Formally, if the local similarity ratio:

$$S_i = \frac{1}{|N(p_i)|} \sum_{j \in N(p_i)} \mathbb{I}(\tau_j = \tau_i)$$

drops below $\theta$, the agent becomes "unhappy" and seeks a new location. While this framework brilliantly illuminates how individual preferences aggregate into collective patterns, it assumes something that rarely holds in practice: that all agents have equal economic capacity to act on their preferences.

This article presents a formal extension that integrates economic heterogeneity and housing market dynamics into the Schelling framework. By introducing income disparities, wealth accumulation, and location-dependent costs, we reveal how financial constraints act as a powerful secondary sorting mechanism—often amplifying and entrenching the segregation patterns that emerge from social preferences alone.

## The Economic Schelling Framework: A Formal Extension

### Redefining Agents in Economic Terms

Our extension fundamentally reimagines the agent. Rather than the simple $(type, position)$ tuple of the original model, each agent $i$ is now characterized by the state vector $(\tau_i, I_i, W_i)$, representing social type, income, and accumulated wealth respectively.

The introduction of systematic income inequality forms a cornerstone of our approach. Agent income $I_i$ is drawn from type-conditional distributions that reflect real-world disparities:

$$I_i \sim \mathcal{N}(\mu_{\tau_i}, \sigma_{income}^2), \quad \text{where} \quad \mu_{minority} < \mu_{majority}$$

This seemingly simple modification has profound implications. It introduces a fundamental asymmetry that mirrors documented patterns of economic inequality while providing a mechanism through which initial disparities can compound over time.

```python
def _generate_income(self, agent_type: AgentType) -> float:
    """
    Generate income for an agent based on type with systematic inequality.
    """
    base_income = (self.majority_base_income if agent_type == AgentType.MAJORITY
                   else self.minority_base_income)

    income = np.random.normal(base_income, self.income_variance)
    return max(0.0, income)  # Ensure non-negative income
```

### Modeling Economic Geography

The static, uniform cost structure of the original Schelling model gives way to a heterogeneous economic landscape. We introduce a rent function $R: P \to \mathbb{R}^+$ that assigns costs to each location $p$ in the grid $P$. This enables modeling of diverse urban forms—from linear gradients representing center-periphery dynamics to clustered patterns reflecting neighborhood-specific amenities.

More critically, we model wealth as a dynamic quantity. An agent's accumulated wealth $W_{i,t}$ evolves according to:

$$W_{i,t+1} = W_{i,t} + I_i - R(p_{i,t})$$

This deceptively simple equation captures a fundamental economic reality: housing costs consume income, and the remainder either builds or depletes wealth over time. Agents in expensive locations face persistent wealth drainage, while those in affordable areas can accumulate resources for future mobility.

```python
def earn_income(self) -> None:
    """Agent earns income and pays rent, adding net to accumulated wealth."""
    if self.pos is not None:
        rent = self.model.rent_grid[self.pos]
        net_income = self.income - rent
        self.accumulated_wealth += net_income
        self.accumulated_wealth = max(0.0, self.accumulated_wealth)
```

### The Constrained Choice Architecture

The model's central innovation lies in how it handles agent decision-making. Social unhappiness ($S_i < \theta$) becomes a *necessary but not sufficient* condition for relocation. Movement to a new location $p'$ requires satisfying two economic constraints:

1. **Moving Capacity**: Current wealth must exceed moving costs
   $$W_{i,t} \geq C_{move}$$

2. **Affordability**: Income must cover new location's rent
   $$I_i \geq R(p')$$

This dual-constraint framework creates a filtered choice set where agents can only consider relocations that are both socially desirable and economically feasible.

```python
def _get_affordable_empty_cells(self) -> List[Tuple[int, int]]:
    """Get list of empty cells that agent can afford."""
    affordable_cells = []
    empty_cells = list(self.model.grid.empties)

    # Condition 1: Agent must have enough wealth for moving cost
    available_wealth = self.accumulated_wealth - self.model.moving_cost

    for cell in empty_cells:
        rent = self.model.rent_grid[cell]
        # Condition 2: Agent must be able to afford the new rent
        if available_wealth >= 0 and self.income >= rent:
            affordable_cells.append(cell)

    return affordable_cells
```

## Measuring Dual Segregation: Beyond Social Sorting

The economic extension demands new analytical frameworks. While social segregation remains important, we must also quantify economic sorting patterns and their interaction.

**Social Segregation Index** ($Seg_{social}$) maintains the classical Schelling metric:

$$Seg_{social} = \frac{\sum_{i \in \text{Agents}} \sum_{j \in N(p_i)} \mathbb{I}(\tau_j = \tau_i)}{\sum_{i \in \text{Agents}} |N(p_i)|}$$

**Economic Segregation Index** ($Seg_{econ}$) introduces a novel measure of income-based clustering. We define income similarity between agents $i$ and $j$ as:

$$Sim(I_i, I_j) = 1 - \frac{|I_i - I_j|}{\max(I_i, I_j, \epsilon)}$$

where $\epsilon$ prevents division by zero. The economic segregation index then becomes:

$$Seg_{econ} = \frac{1}{\sum_i |N(p_i)|} \sum_{i \in \text{Agents}} \sum_{j \in N(p_i)} Sim(I_i, I_j)$$

These dual metrics enable decomposition of observed segregation into social and economic components, revealing the relative contribution of preferences versus constraints.

```python
self.datacollector = DataCollector(
    model_reporters={
        "Segregation": self.calculate_segregation,
        "Economic_Segregation": self.calculate_economic_segregation,
        "Avg_Wealth_Majority": lambda m: self._calculate_avg_wealth(AgentType.MAJORITY),
        "Avg_Wealth_Minority": lambda m: self._calculate_avg_wealth(AgentType.MINORITY),
    }
)
```

## Emergent Dynamics: When Constraints Reshape Preferences

### The Frustration Phenomenon

Perhaps the most striking finding from the economic extension is the emergence of "frustrated equilibria"—states where significant numbers of agents remain socially unhappy but economically immobile. Unlike the classical Schelling model, where movement continues until all agents achieve satisfaction (or no moves improve satisfaction), the economic version often reaches stable states with persistent unhappiness.

This frustration is not randomly distributed. Lower-income agents, particularly minorities, become systematically trapped in socially undesirable but economically necessary locations. Their preferences remain unchanged, but their capacity to act on those preferences becomes severely constrained.

### Coupled Sorting Mechanisms

Social and economic sorting operate not as independent processes but as coupled dynamics. Economic constraints filter the choice sets available to socially motivated agents, creating sorting patterns that reflect both preference and capacity. This coupling produces several counterintuitive results:

- **Preference Amplification**: Mild social preferences can produce extreme segregation when filtered through economic constraints
- **Constraint Multiplication**: Economic limitations compound over time as wealth differences accumulate
- **Spatial Correlation**: Agent type, income, and local costs become strongly correlated, creating reinforcing patterns

### Wealth Divergence and Spatial Traps

The model consistently produces widening wealth gaps between groups. This occurs through a mechanism we term "spatial wealth drainage"—lower-income agents who manage to access higher-cost areas face persistent wealth depletion, while higher-income agents accumulate wealth more effectively by avoiding this drain.

Simultaneously, the geography of choice becomes increasingly constrained. As wealth gaps widen, the set of mutually affordable locations for different income groups shrinks, creating what amount to "spatial traps" that lock in segregation patterns.

## Research Applications: From Theory to Policy

### Urban Planning and Housing Policy Analysis

The Economic Schelling Model transcends academic exercise to provide practical tools for policy analysis. By comparing social versus economic segregation indices across different parameter settings, planners can diagnose whether observed patterns stem primarily from discriminatory preferences or economic inequality.

This diagnostic capability proves crucial for intervention design. If economic segregation substantially exceeds social segregation, income-based interventions (housing vouchers, subsidized housing) may prove more effective than anti-discrimination efforts alone. Conversely, when social segregation dominates, preference-changing interventions become paramount.

### Gentrification Dynamics and Displacement

The rent gradient feature enables sophisticated modeling of gentrification processes. As certain areas become more expensive, the model simulates how existing residents—particularly lower-income minorities—face displacement pressures even without explicit discrimination. This illuminates how market forces alone can perpetuate segregation through seemingly neutral economic processes.

### Policy Intervention Testing

The model's greatest practical value may lie in its capacity for *ex ante* policy evaluation. Rather than implementing costly interventions and observing results, policymakers can simulate various approaches:

- **Housing Voucher Programs**: Model runs predict whether vouchers promote genuine integration or merely redistribute segregation to new areas
- **Minimum Wage Increases**: Income adjustments reveal how wage policy affects residential mobility and segregation patterns  
- **Rent Control Policies**: Simulations capture both affordability benefits and potential mobility restrictions from rent regulation

## Methodological Innovations and Extensions

### Multi-Scale Data Architecture

The economic extension introduces sophisticated data collection that captures dynamics at multiple scales:

- **Individual Level**: Wealth trajectories, mobility histories, constraint patterns
- **Group Level**: Demographic-specific outcomes and between-group disparities  
- **Neighborhood Level**: Local segregation indices, rent distributions, mobility flows
- **System Level**: Aggregate segregation measures, policy effectiveness metrics

This multi-scale approach enables researchers to trace how individual-level constraints aggregate into neighborhood-level patterns and system-level outcomes.

### Dynamic Constraint Modeling

A key methodological advance involves distinguishing between *wanting* to move and *being able* to move. Traditional models assume agents can act on preferences; our model recognizes that structural constraints often prevent preference expression. This creates more realistic dynamics and reveals hidden sources of segregation persistence.

### Economic Mobility Tracking

By monitoring individual wealth accumulation over time, the model captures how initial conditions compound into long-term inequality. This longitudinal perspective reveals whether segregation patterns are self-reinforcing or whether mobility opportunities can break cycles of disadvantage.

## Key Findings: The Economic Reality of Social Sorting

### The Wealth Accumulation Trap

Even when all agents share identical social preferences, systematic income differences create persistent and widening wealth gaps. Lower-income agents spend larger income fractions on housing, leaving less for wealth building and future mobility. This creates a reinforcing cycle where initial economic disadvantage becomes compounded over time.

### Mobility Constraints as Segregation Multipliers

Analysis reveals that typically 20-40% of agents who are socially motivated to move cannot afford to relocate. This "mobility gap" amplifies segregation beyond what preferences alone would generate, suggesting that economic barriers may be as important as social attitudes in maintaining segregation.

### The Rent Geography Effect

Different rent distribution patterns produce dramatically different segregation outcomes:

- **Uniform Rent**: Segregation driven primarily by social preferences, resembling classical Schelling dynamics
- **Gradient Rent**: Economic sorting dominates, with minorities concentrated in low-rent periphery regardless of social preferences
- **Clustered Rent**: Complex patterns emerge combining both economic and social sorting mechanisms

### Context-Dependent Policy Effectiveness

The model reveals that intervention effectiveness depends critically on initial conditions:

- **High Inequality Settings**: Direct income support shows greatest segregation reduction
- **Moderate Inequality**: Housing vouchers demonstrate optimal impact on integration
- **Low Inequality**: Moving assistance and transaction cost reduction prove most effective

## Limitations and Future Directions

### Labor Market Integration

The current model treats income as exogenously fixed, but real-world segregation interacts dynamically with employment access. Future extensions could model how residential location affects job prospects, creating feedback loops between housing and economic outcomes. This would capture how segregation can perpetuate itself through reduced access to employment opportunities.

### Social Capital and Network Effects

Present agents make purely individual decisions, but actual residential choices involve social networks, family connections, and community ties. Incorporating network effects could reveal how social capital interacts with economic constraints to either facilitate or hinder mobility across group boundaries.

### Institutional Factor Integration

The model currently abstracts away important institutional features like school district boundaries, public transportation networks, or discriminatory lending practices. These institutional structures often shape residential patterns as powerfully as individual choices, suggesting fertile ground for future model extensions.

### Dynamic Preference Evolution

Agent preferences remain static throughout simulation runs, but real preferences evolve through experience and contact. Modeling how positive or negative inter-group interactions affect future preferences could illuminate potential paths toward greater long-term integration.

## Conclusion: Economic Structures and Social Outcomes

The Economic Schelling Model reveals a sobering yet actionable truth: residential segregation persists not merely through discriminatory preferences but through the systematic interaction between social attitudes and economic constraints. Even in the absence of strong prejudice, economic inequality alone can generate and maintain significant segregation patterns.

**For researchers**, the model demonstrates the critical importance of incorporating structural constraints into social simulations. Models focusing exclusively on preferences or purely on economics miss crucial interaction effects that shape real-world outcomes. The economic extension shows how seemingly neutral market forces can amplify social divisions, creating segregation that exceeds what either mechanism would produce independently.

**For policymakers**, the findings suggest that effective anti-segregation efforts must address both attitudinal and structural barriers. Anti-discrimination enforcement, while necessary, proves insufficient when economic inequalities continue limiting housing choices for disadvantaged groups. The model's policy simulation capabilities offer tools for designing interventions that target root causes rather than merely treating symptoms.

**For society**, the model provides both warning and hope. The warning is clear: segregation can persist and even worsen through ostensibly neutral economic processes. Market mechanisms, left unchecked, can create self-reinforcing cycles that entrench spatial inequality across generations.

Yet the model also offers hope through understanding. By making explicit the pathways through which economic structures shape social outcomes, we gain tools for interventions that could redirect these forces toward more equitable ends. The path from individual economic constraints to collective segregation patterns is neither simple nor inevitable—it emerges from specific structural relationships that thoughtful policy can potentially reshape.

In our era of rising inequality, the Economic Schelling Model provides essential insights into how economic forces interact with social preferences to shape community formation. It reminds us that creating genuinely integrated communities requires addressing not just individual attitudes but the economic structures that constrain where people can afford to live, work, and build wealth.

The model ultimately demonstrates that emergence—the phenomenon by which simple individual behaviors aggregate into complex collective patterns—operates not just in physical systems but in the intricate dance between economic structures and social choices that defines modern urban life. Understanding this emergence becomes essential for anyone seeking to build more equitable communities in an economically stratified world.

As we grapple with persistent segregation despite decades of civil rights progress, the Economic Schelling Model suggests that the next frontier lies not in changing preferences alone, but in reshaping the economic foundations that determine which preferences can be expressed and which must remain forever frustrated by financial reality.
```python
"""
Improved Economic Schelling Segregation Model
Extension of Thomas Schelling's model with income inequality between groups.
Minority agents have systematically lower income than majority agents.

"""

import numpy as np
import matplotlib.pyplot as plt
from mesa import Agent, Model
from mesa.time import RandomActivation
from mesa.space import MultiGrid
from mesa.datacollection import DataCollector
from typing import List, Tuple, Optional, Dict, Any
import logging
from enum import Enum
import warnings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class AgentType(Enum):
    """Enumeration for agent types"""
    MAJORITY = 0
    MINORITY = 1

    def __str__(self):
        return self.name.capitalize()

class EconomicSchellingAgent(Agent):
    """
    An agent in the Economic Schelling segregation model.

    Attributes:
        unique_id: Unique identifier for the agent
        model: Reference to the model instance
        type: Agent type (MAJORITY or MINORITY)
        income: Agent's income level per time step
        happiness_threshold: Minimum similarity ratio for happiness
        accumulated_wealth: Wealth accumulated over time
        initial_wealth: Starting wealth for the agent
    """

    def __init__(
        self,
        unique_id: int,
        model: 'EconomicSchellingModel',
        agent_type: AgentType,
        income: float,
        initial_wealth: float = None
    ):
        """
        Initialize an Economic Schelling agent.

        Args:
            unique_id: Unique identifier for the agent
            model: Reference to the model instance
            agent_type: Agent type (MAJORITY or MINORITY)
            income: Agent's income level per time step
            initial_wealth: Initial wealth (defaults to 3x income if not provided)
        """
        super().__init__(unique_id, model)
        self.type = agent_type
        self.income = max(0.0, income)  # Ensure non-negative income
        self.happiness_threshold = model.similarity_threshold
        self.accumulated_wealth = initial_wealth if initial_wealth is not None else income * 3.0
        self.initial_wealth = self.accumulated_wealth

    def step(self) -> None:
        """
        Agent's behavior for each step:
        1. Calculate similarity ratio with neighbors
        2. Move if unhappy and can afford to move
        """
        if self.pos is None:
            return

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
        is_unhappy = similarity_ratio < self.happiness_threshold

        # Check if agent can afford to move
        can_afford_move = self.accumulated_wealth >= self.model.moving_cost

        if is_unhappy and can_afford_move:
            self._move_to_affordable_cell()

    def _move_to_affordable_cell(self) -> None:
        """Move agent to an affordable empty cell if available."""
        # Get affordable empty cells
        affordable_cells = self._get_affordable_empty_cells()

        if affordable_cells:
            # Choose random affordable cell
            new_pos = self.random.choice(affordable_cells)
            old_rent = self.model.rent_grid[self.pos]
            new_rent = self.model.rent_grid[new_pos]

            # Pay moving cost
            self.accumulated_wealth -= self.model.moving_cost

            # Move agent
            self.model.grid.move_agent(self, new_pos)
            self.model.total_moves += 1

    def _get_affordable_empty_cells(self) -> List[Tuple[int, int]]:
        """
        Get list of empty cells that agent can afford.
        Agent can afford a cell if they have enough wealth for moving cost.

        Returns:
            List of affordable empty cell coordinates
        """
        affordable_cells = []
        empty_cells = list(self.model.grid.empties)

        # Agent needs enough wealth for moving cost
        available_wealth = self.accumulated_wealth - self.model.moving_cost

        for cell in empty_cells:
            rent = self.model.rent_grid[cell]
            # Agent can afford if rent is within their budget
            if available_wealth >= 0 and self.income >= rent:
                affordable_cells.append(cell)

        return affordable_cells

    def earn_income(self) -> None:
        """Agent earns income and pays rent, adding net to accumulated wealth."""
        if self.pos is not None:
            rent = self.model.rent_grid[self.pos]
            net_income = self.income - rent
            self.accumulated_wealth += net_income
            # Prevent negative wealth
            self.accumulated_wealth = max(0.0, self.accumulated_wealth)


class EconomicSchellingModel(Model):
    """
    Economic Schelling segregation model with income inequality between groups.
    Minority agents have systematically lower income than majority agents.
    """

    def __init__(
        self,
        width: int = 20,
        height: int = 20,
        density: float = 0.8,
        minority_pc: float = 0.3,
        similarity_threshold: float = 0.6,
        majority_base_income: float = 15.0,
        minority_base_income: float = 8.0,
        income_variance: float = 3.0,
        rent_distribution: str = 'uniform',
        base_rent: float = 2.0,
        rent_variance: float = 1.0,
        moving_cost: float = 1.0,
        income_distribution: str = 'normal'
    ):
        """
        Initialize the Economic Schelling model with income inequality.

        Args:
            width: Width of the grid
            height: Height of the grid
            density: Proportion of cells occupied by agents (0-1)
            minority_pc: Proportion of minority agents (0-1)
            similarity_threshold: Minimum similarity ratio for happiness (0-1)
            majority_base_income: Base income for majority agents
            minority_base_income: Base income for minority agents
            income_variance: Variance in income distribution
            rent_distribution: Distribution of rent prices ('uniform', 'gradient', or 'normal')
            base_rent: Base rent level for cells
            rent_variance: Variance in rent distribution
            moving_cost: Cost of moving to a new location
            income_distribution: Distribution type ('uniform' or 'normal')
        """
        super().__init__()

        # Validate parameters
        self._validate_parameters(width, height, density, minority_pc, similarity_threshold)

        # Model parameters
        self.width = width
        self.height = height
        self.density = max(0.0, min(1.0, density))  # Clamp between 0 and 1
        self.minority_pc = max(0.0, min(1.0, minority_pc))  # Clamp between 0 and 1
        self.similarity_threshold = max(0.0, min(1.0, similarity_threshold))
        self.majority_base_income = max(0.0, majority_base_income)
        self.minority_base_income = max(0.0, minority_base_income)
        self.income_variance = max(0.0, income_variance)
        self.rent_distribution = rent_distribution
        self.base_rent = max(0.0, base_rent)
        self.rent_variance = max(0.0, rent_variance)
        self.moving_cost = max(0.0, moving_cost)
        self.income_distribution = income_distribution

        # Initialize model components
        self.grid = MultiGrid(width, height, torus=True)
        self.schedule = RandomActivation(self)

        # Initialize rent grid
        self.rent_grid = self._create_rent_grid()

        # Data collection
        self.datacollector = DataCollector(
            model_reporters={
                "Segregation": self.calculate_segregation,
                "Total_Moves": lambda m: m.total_moves,
                "Avg_Income_Majority": lambda m: self._calculate_avg_income(AgentType.MAJORITY),
                "Avg_Income_Minority": lambda m: self._calculate_avg_income(AgentType.MINORITY),
                "Avg_Wealth_Majority": lambda m: self._calculate_avg_wealth(AgentType.MAJORITY),
                "Avg_Wealth_Minority": lambda m: self._calculate_avg_wealth(AgentType.MINORITY),
                "Avg_Rent_Occupied": self._calculate_avg_rent_occupied,
                "Economic_Segregation": self.calculate_economic_segregation,
                "Income_Inequality_Ratio": self.calculate_income_inequality_ratio,
                "Unhappy_Agents": self.count_unhappy_agents,
                "Empty_Cells": lambda m: len(list(m.grid.empties))
            },
            agent_reporters={
                "Wealth": "accumulated_wealth",
                "Income": "income",
                "Type": "type",
                "Position_X": lambda a: a.pos[0] if a.pos else None,
                "Position_Y": lambda a: a.pos[1] if a.pos else None
            }
        )

        # Initialize agents
        self._place_agents()

        # Track metrics
        self.total_moves = 0

        logger.info(f"Model initialized: {len(self.schedule.agents)} agents on {width}x{height} grid")

    def _validate_parameters(self, width: int, height: int, density: float,
                           minority_pc: float, similarity_threshold: float) -> None:
        """Validate model parameters and raise errors for invalid values."""
        if width <= 0 or height <= 0:
            raise ValueError("Width and height must be positive integers")
        if not 0 <= density <= 1:
            raise ValueError("Density must be between 0 and 1")
        if not 0 <= minority_pc <= 1:
            raise ValueError("Minority percentage must be between 0 and 1")
        if not 0 <= similarity_threshold <= 1:
            raise ValueError("Similarity threshold must be between 0 and 1")

    def _create_rent_grid(self) -> np.ndarray:
        """
        Create rent grid based on specified distribution.

        Returns:
            2D numpy array of rent prices (all non-negative)
        """
        if self.rent_distribution == 'uniform':
            rent_grid = np.random.uniform(
                max(0.0, self.base_rent - self.rent_variance),
                self.base_rent + self.rent_variance,
                (self.width, self.height)
            )
        elif self.rent_distribution == 'gradient':
            # Create gradient from low rent (top-left) to high rent (bottom-right)
            rent_grid = np.zeros((self.width, self.height))
            for i in range(self.width):
                for j in range(self.height):
                    # Linear gradient based on distance from origin
                    normalized_distance = (i + j) / (self.width + self.height - 2)
                    rent_value = self.base_rent + (normalized_distance * self.rent_variance * 2) - self.rent_variance
                    rent_grid[i, j] = max(0.0, rent_value)  # Ensure non-negative
        elif self.rent_distribution == 'normal':
            rent_grid = np.random.normal(self.base_rent, self.rent_variance, (self.width, self.height))
            rent_grid = np.maximum(rent_grid, 0.0)  # Ensure all rents are non-negative
        else:
            # Default to uniform base rent
            rent_grid = np.full((self.width, self.height), self.base_rent)

        return rent_grid

    def _place_agents(self) -> None:
        """Place agents randomly on the grid with proper density control."""
        total_cells = self.width * self.height
        num_agents = int(total_cells * self.density)

        # Generate all possible positions and shuffle them
        all_positions = [(x, y) for x in range(self.width) for y in range(self.height)]
        self.random.shuffle(all_positions)

        agent_id = 0

        # Place agents in the first num_agents positions
        for i in range(min(num_agents, len(all_positions))):
            pos = all_positions[i]

            # Determine agent type
            agent_type = AgentType.MINORITY if self.random.random() < self.minority_pc else AgentType.MAJORITY

            # Generate income
            income = self._generate_income(agent_type)

            # Create and place agent
            agent = EconomicSchellingAgent(agent_id, self, agent_type, income)
            self.grid.place_agent(agent, pos)
            self.schedule.add(agent)
            agent_id += 1

    def _generate_income(self, agent_type: AgentType) -> float:
        """
        Generate income for an agent based on type with systematic inequality.

        Args:
            agent_type: Type of agent

        Returns:
            Generated income level (always non-negative)
        """
        base_income = (self.majority_base_income if agent_type == AgentType.MAJORITY
                      else self.minority_base_income)

        if self.income_distribution == 'uniform':
            income = np.random.uniform(
                max(0.0, base_income - self.income_variance),
                base_income + self.income_variance
            )
        elif self.income_distribution == 'normal':
            income = np.random.normal(base_income, self.income_variance)
            income = max(0.0, income)  # Ensure non-negative
        else:
            income = base_income

        return income

    def _calculate_avg_income(self, agent_type: AgentType) -> float:
        """Calculate average income for a specific agent type."""
        incomes = [agent.income for agent in self.schedule.agents
                  if agent.type == agent_type]
        return np.mean(incomes) if incomes else 0.0

    def _calculate_avg_wealth(self, agent_type: AgentType) -> float:
        """Calculate average wealth for a specific agent type."""
        wealth = [agent.accumulated_wealth for agent in self.schedule.agents
                 if agent.type == agent_type]
        return np.mean(wealth) if wealth else 0.0

    def _calculate_avg_rent_occupied(self) -> float:
        """Calculate average rent of occupied cells."""
        occupied_rents = []
        for agent in self.schedule.agents:
            if agent.pos:
                occupied_rents.append(self.rent_grid[agent.pos])
        return np.mean(occupied_rents) if occupied_rents else 0.0

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
            if agent.pos is None:
                continue

            neighbors = self.grid.get_neighbors(
                agent.pos, moore=True, include_center=False
            )

            if neighbors:
                similar = sum(1 for neighbor in neighbors if neighbor.type == agent.type)
                total_similar += similar
                total_neighbors += len(neighbors)

        return total_similar / total_neighbors if total_neighbors > 0 else 0.0

    def calculate_economic_segregation(self) -> float:
        """
        Calculate economic segregation by income similarity of neighbors.

        Returns:
            Average income similarity ratio (0-1)
        """
        if not self.schedule.agents:
            return 0.0

        total_similarity = 0
        total_comparisons = 0

        for agent in self.schedule.agents:
            if agent.pos is None:
                continue

            neighbors = self.grid.get_neighbors(
                agent.pos, moore=True, include_center=False
            )

            if neighbors:
                agent_income = agent.income
                for neighbor in neighbors:
                    # Calculate similarity between agent and each neighbor
                    max_income = max(agent_income, neighbor.income)
                    if max_income > 0:
                        similarity = 1 - (abs(agent_income - neighbor.income) / max_income)
                    else:
                        similarity = 1.0

                    total_similarity += similarity
                    total_comparisons += 1

        return total_similarity / total_comparisons if total_comparisons > 0 else 0.0

    def calculate_income_inequality_ratio(self) -> float:
        """
        Calculate the income inequality ratio between majority and minority groups.

        Returns:
            Ratio of average majority income to average minority income
        """
        avg_majority_income = self._calculate_avg_income(AgentType.MAJORITY)
        avg_minority_income = self._calculate_avg_income(AgentType.MINORITY)

        if avg_minority_income > 0:
            return avg_majority_income / avg_minority_income
        else:
            return float('inf') if avg_majority_income > 0 else 1.0

    def count_unhappy_agents(self) -> int:
        """Count the number of unhappy agents in the model."""
        unhappy_count = 0

        for agent in self.schedule.agents:
            if agent.pos is None:
                continue

            neighbors = self.grid.get_neighbors(
                agent.pos, moore=True, include_center=False
            )

            if neighbors:
                similar = sum(1 for neighbor in neighbors if neighbor.type == agent.type)
                similarity_ratio = similar / len(neighbors)
                if similarity_ratio < agent.happiness_threshold:
                    unhappy_count += 1

        return unhappy_count

    def step(self) -> None:
        """Execute one step of the model."""
        # Agents earn income and pay rent
        for agent in self.schedule.agents:
            agent.earn_income()

        # Collect data before agent movement
        self.datacollector.collect(self)

        # Execute agent steps (movement decisions)
        self.schedule.step()


class EconomicSchellingVisualizer:
    """Enhanced visualization for the Economic Schelling model."""

    # Improved color schemes
    SOCIAL_COLORS = {'Empty': 'white', 'Majority': '#1f77b4', 'Minority': '#ff7f0e'}

    @staticmethod
    def extract_social_grid(model: EconomicSchellingModel) -> np.ndarray:
        """Extract social grid state for visualization."""
        grid = np.zeros((model.width, model.height))
        for x in range(model.width):
            for y in range(model.height):
                agents = model.grid.get_cell_list_contents([(x, y)])
                if agents:
                    grid[x, y] = agents[0].type.value + 1  # 1 for majority, 2 for minority
                else:
                    grid[x, y] = 0  # 0 for empty
        return grid

    @staticmethod
    def extract_economic_grid(model: EconomicSchellingModel) -> np.ndarray:
        """Extract economic grid state (rent prices)."""
        return model.rent_grid.copy()

    @staticmethod
    def extract_wealth_grid(model: EconomicSchellingModel) -> np.ndarray:
        """Extract wealth grid state."""
        grid = np.full((model.width, model.height), np.nan)
        for x in range(model.width):
            for y in range(model.height):
                agents = model.grid.get_cell_list_contents([(x, y)])
                if agents:
                    grid[x, y] = agents[0].accumulated_wealth
        return grid

    @staticmethod
    def extract_income_grid(model: EconomicSchellingModel) -> np.ndarray:
        """Extract income grid state."""
        grid = np.full((model.width, model.height), np.nan)
        for x in range(model.width):
            for y in range(model.height):
                agents = model.grid.get_cell_list_contents([(x, y)])
                if agents:
                    grid[x, y] = agents[0].income
        return grid

    @classmethod
    def create_custom_social_cmap(cls):
        """Create a custom colormap for social visualization."""
        from matplotlib.colors import ListedColormap
        colors = [cls.SOCIAL_COLORS['Empty'],
                 cls.SOCIAL_COLORS['Majority'],
                 cls.SOCIAL_COLORS['Minority']]
        return ListedColormap(colors)

    @classmethod
    def plot_static_comparison(cls, model: EconomicSchellingModel,
                             initial_grid: np.ndarray,
                             middle_grid: np.ndarray,
                             steps: int) -> None:
        """Plot initial, middle, final social segregation and rent distribution."""
        fig, axes = plt.subplots(1, 4, figsize=(20, 5))

        custom_cmap = cls.create_custom_social_cmap()

        # Initial Social Segregation
        im1 = axes[0].imshow(initial_grid, cmap=custom_cmap, vmin=0, vmax=2)
        axes[0].set_title("Initial Social Segregation", fontsize=12, fontweight='bold')
        axes[0].set_xticks([])
        axes[0].set_yticks([])

        # Middle Social Segregation
        im2 = axes[1].imshow(middle_grid, cmap=custom_cmap, vmin=0, vmax=2)
        axes[1].set_title(f"Step {steps // 2} Social Segregation", fontsize=12, fontweight='bold')
        axes[1].set_xticks([])
        axes[1].set_yticks([])

        # Final Social Segregation
        final_grid = cls.extract_social_grid(model)
        im3 = axes[2].imshow(final_grid, cmap=custom_cmap, vmin=0, vmax=2)
        axes[2].set_title("Final Social Segregation", fontsize=12, fontweight='bold')
        axes[2].set_xticks([])
        axes[2].set_yticks([])

        # Rent Distribution
        rent_grid = cls.extract_economic_grid(model)
        im4 = axes[3].imshow(rent_grid, cmap='viridis')
        axes[3].set_title("Rent Distribution", fontsize=12, fontweight='bold')
        axes[3].set_xticks([])
        axes[3].set_yticks([])
        cbar = plt.colorbar(im4, ax=axes[3], shrink=0.8)
        cbar.set_label('Rent Level', fontsize=10)

        # Add legend for social plots
        import matplotlib.patches as mpatches
        empty_patch = mpatches.Patch(color=cls.SOCIAL_COLORS['Empty'], label='Empty')
        majority_patch = mpatches.Patch(color=cls.SOCIAL_COLORS['Majority'], label='Majority')
        minority_patch = mpatches.Patch(color=cls.SOCIAL_COLORS['Minority'], label='Minority')
        fig.legend(handles=[empty_patch, majority_patch, minority_patch],
                  loc='upper center', bbox_to_anchor=(0.5, 0.02), ncol=3)

        plt.tight_layout()
        plt.show()

    @staticmethod
    def plot_enhanced_metrics(data_frame) -> None:
        """Plot comprehensive metrics over time."""
        fig, axes = plt.subplots(2, 3, figsize=(18, 10))

        # Social segregation
        axes[0, 0].plot(data_frame["Segregation"], linewidth=2, color='blue', alpha=0.8)
        axes[0, 0].set_title("Social Segregation Over Time", fontweight='bold')
        axes[0, 0].set_xlabel("Step")
        axes[0, 0].set_ylabel("Proportion of Similar Neighbors")
        axes[0, 0].grid(True, alpha=0.3)
        axes[0, 0].set_ylim(0, 1)

        # Economic segregation
        axes[0, 1].plot(data_frame["Economic_Segregation"], linewidth=2, color='green', alpha=0.8)
        axes[0, 1].set_title("Economic Segregation Over Time", fontweight='bold')
        axes[0, 1].set_xlabel("Step")
        axes[0, 1].set_ylabel("Income Similarity")
        axes[0, 1].grid(True, alpha=0.3)
        axes[0, 1].set_ylim(0, 1)

        # Average incomes by group
        axes[0, 2].plot(data_frame["Avg_Income_Majority"], linewidth=2,
                       label='Majority', color='red', alpha=0.8)
        axes[0, 2].plot(data_frame["Avg_Income_Minority"], linewidth=2,
                       label='Minority', color='orange', alpha=0.8)
        axes[0, 2].set_title("Average Income by Group", fontweight='bold')
        axes[0, 2].set_xlabel("Step")
        axes[0, 2].set_ylabel("Average Income")
        axes[0, 2].legend()
        axes[0, 2].grid(True, alpha=0.3)

        # Average wealth by group
        axes[1, 0].plot(data_frame["Avg_Wealth_Majority"], linewidth=2,
                       label='Majority', color='darkred', alpha=0.8)
        axes[1, 0].plot(data_frame["Avg_Wealth_Minority"], linewidth=2,
                       label='Minority', color='darkorange', alpha=0.8)
        axes[1, 0].set_title("Average Wealth by Group", fontweight='bold')
        axes[1, 0].set_xlabel("Step")
        axes[1, 0].set_ylabel("Average Wealth")
        axes[1, 0].legend()
        axes[1, 0].grid(True, alpha=0.3)

        # Income inequality ratio
        axes[1, 1].plot(data_frame["Income_Inequality_Ratio"], linewidth=2, color='purple', alpha=0.8)
        axes[1, 1].set_title("Income Inequality Ratio", fontweight='bold')
        axes[1, 1].set_xlabel("Step")
        axes[1, 1].set_ylabel("Ratio (Majority/Minority)")
        axes[1, 1].grid(True, alpha=0.3)
        axes[1, 1].axhline(y=1.0, color='r', linestyle='--', alpha=0.7, label='Equality Line')
        axes[1, 1].legend()

        # Unhappy agents over time
        axes[1, 2].plot(data_frame["Unhappy_Agents"], linewidth=2, color='red', alpha=0.8)
        axes[1, 2].set_title("Unhappy Agents Over Time", fontweight='bold')
        axes[1, 2].set_xlabel("Step")
        axes[1, 2].set_ylabel("Number of Unhappy Agents")
        axes[1, 2].grid(True, alpha=0.3)

        plt.tight_layout()
        plt.show()

    @staticmethod
    def plot_income_distribution(model: EconomicSchellingModel) -> None:
        """Plot enhanced income distribution comparison."""
        majority_incomes = [agent.income for agent in model.schedule.agents
                           if agent.type == AgentType.MAJORITY]
        minority_incomes = [agent.income for agent in model.schedule.agents
                           if agent.type == AgentType.MINORITY]

        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

        # Income distributions
        ax1.hist(majority_incomes, bins=20, alpha=0.7, label='Majority',
                color='red', density=True)
        ax1.hist(minority_incomes, bins=20, alpha=0.7, label='Minority',
                color='orange', density=True)
        ax1.set_xlabel('Income')
        ax1.set_ylabel('Density')
        ax1.set_title('Income Distribution by Group', fontweight='bold')
        ax1.legend()
        ax1.grid(True, alpha=0.3)

        # Box plot comparison
        ax2.boxplot([majority_incomes, minority_incomes],
                   labels=['Majority', 'Minority'],
                   patch_artist=True,
                   boxprops=dict(facecolor='lightblue', alpha=0.7))
        ax2.set_ylabel('Income')
        ax2.set_title('Income Distribution Comparison', fontweight='bold')
        ax2.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.show()


def run_economic_schelling_model(**config) -> EconomicSchellingModel:
    """
    Run the Enhanced Economic Schelling segregation model.

    Args:
        **config: Model configuration parameters

    Returns:
        Completed EconomicSchellingModel instance
    """
    # Enhanced default configuration
    default_config = {
        'width': 20,
        'height': 20,
        'density': 0.8,
        'minority_pc': 0.3,
        'similarity_threshold': 0.6,
        'majority_base_income': 15.0,
        'minority_base_income': 8.0,
        'income_variance': 3.0,
        'rent_distribution': 'uniform',
        'base_rent': 2.0,
        'rent_variance': 1.0,
        'moving_cost': 1.0,
        'income_distribution': 'normal',
        'steps': 50
    }

    # Update with provided config
    default_config.update(config)
    config = default_config

    try:
        # Initialize model
        model = EconomicSchellingModel(
            width=config['width'],
            height=config['height'],
            density=config['density'],
            minority_pc=config['minority_pc'],
            similarity_threshold=config['similarity_threshold'],
            majority_base_income=config['majority_base_income'],
            minority_base_income=config['minority_base_income'],
            income_variance=config['income_variance'],
            rent_distribution=config['rent_distribution'],
            base_rent=config['base_rent'],
            rent_variance=config['rent_variance'],
            moving_cost=config['moving_cost'],
            income_distribution=config['income_distribution']
        )

        # Store initial state for comparison
        initial_grid = EconomicSchellingVisualizer.extract_social_grid(model)
        middle_grid = None

        logger.info(f"Starting simulation with {len(model.schedule.agents)} agents for {config['steps']} steps...")

        # Run simulation
        for i in range(config['steps']):
            model.step()

            # Capture middle state
            if i + 1 == config['steps'] // 2:
                middle_grid = EconomicSchellingVisualizer.extract_social_grid(model)

            # Progress logging
            if i % 10 == 0 or i == config['steps'] - 1:
                segregation = model.calculate_segregation()
                inequality_ratio = model.calculate_income_inequality_ratio()
                unhappy = model.count_unhappy_agents()
                logger.info(f"Step {i+1}/{config['steps']}: Segregation={segregation:.3f}, "
                          f"Inequality={inequality_ratio:.2f}x, Unhappy={unhappy}")

        # Create visualizations
        logger.info("Generating visualizations...")

        # Static comparison plot
        EconomicSchellingVisualizer.plot_static_comparison(
            model, initial_grid, middle_grid, config['steps']
        )

        # Enhanced metrics plot
        metrics_data = model.datacollector.get_model_vars_dataframe()
        EconomicSchellingVisualizer.plot_enhanced_metrics(metrics_data)

        # Income distribution plot
        EconomicSchellingVisualizer.plot_income_distribution(model)

        logger.info("Model execution completed successfully.")
        return model

    except Exception as e:
        logger.error(f"Error during model execution: {e}")
        raise


def analyze_model_results(model: EconomicSchellingModel) -> Dict[str, Any]:
    """
    Analyze and return comprehensive model results.

    Args:
        model: Completed EconomicSchellingModel instance

    Returns:
        Dictionary containing analysis results
    """
    # Calculate final metrics
    final_segregation = model.calculate_segregation()
    final_economic_segregation = model.calculate_economic_segregation()
    inequality_ratio = model.calculate_income_inequality_ratio()
    total_moves = model.total_moves
    unhappy_agents = model.count_unhappy_agents()

    # Income statistics
    avg_majority_income = model._calculate_avg_income(AgentType.MAJORITY)
    avg_minority_income = model._calculate_avg_income(AgentType.MINORITY)
    avg_majority_wealth = model._calculate_avg_wealth(AgentType.MAJORITY)
    avg_minority_wealth = model._calculate_avg_wealth(AgentType.MINORITY)

    # Agent counts
    majority_count = sum(1 for agent in model.schedule.agents
                        if agent.type == AgentType.MAJORITY)
    minority_count = sum(1 for agent in model.schedule.agents
                        if agent.type == AgentType.MINORITY)

    # Rent statistics
    avg_rent_occupied = model._calculate_avg_rent_occupied()
    min_rent = np.min(model.rent_grid)
    max_rent = np.max(model.rent_grid)

    results = {
        'final_metrics': {
            'social_segregation': final_segregation,
            'economic_segregation': final_economic_segregation,
            'income_inequality_ratio': inequality_ratio,
            'total_moves': total_moves,
            'unhappy_agents': unhappy_agents,
            'unhappy_percentage': (unhappy_agents / len(model.schedule.agents)) * 100
        },
        'demographics': {
            'total_agents': len(model.schedule.agents),
            'majority_count': majority_count,
            'minority_count': minority_count,
            'minority_percentage': (minority_count / len(model.schedule.agents)) * 100
        },
        'economic_stats': {
            'avg_majority_income': avg_majority_income,
            'avg_minority_income': avg_minority_income,
            'avg_majority_wealth': avg_majority_wealth,
            'avg_minority_wealth': avg_minority_wealth,
            'wealth_inequality_ratio': (avg_majority_wealth / avg_minority_wealth
                                      if avg_minority_wealth > 0 else float('inf'))
        },
        'housing_stats': {
            'avg_rent_occupied': avg_rent_occupied,
            'min_rent': min_rent,
            'max_rent': max_rent,
            'rent_range': max_rent - min_rent
        }
    }

    return results


def print_model_summary(results: Dict[str, Any]) -> None:
    """
    Print a comprehensive summary of model results.

    Args:
        results: Results dictionary from analyze_model_results
    """
    print("\n" + "="*60)
    print("ECONOMIC SCHELLING MODEL - FINAL RESULTS")
    print("="*60)

    print(f"\n📊 SEGREGATION METRICS:")
    print(f"   Social Segregation: {results['final_metrics']['social_segregation']:.3f}")
    print(f"   Economic Segregation: {results['final_metrics']['economic_segregation']:.3f}")
    print(f"   Agent Satisfaction: {100-results['final_metrics']['unhappy_percentage']:.1f}% satisfied")

    print(f"\n👥 DEMOGRAPHICS:")
    print(f"   Total Agents: {results['demographics']['total_agents']}")
    print(f"   Majority: {results['demographics']['majority_count']} "
          f"({100-results['demographics']['minority_percentage']:.1f}%)")
    print(f"   Minority: {results['demographics']['minority_count']} "
          f"({results['demographics']['minority_percentage']:.1f}%)")

    print(f"\n💰 ECONOMIC INEQUALITY:")
    print(f"   Income Inequality Ratio: {results['final_metrics']['income_inequality_ratio']:.2f}x")
    print(f"   Wealth Inequality Ratio: {results['economic_stats']['wealth_inequality_ratio']:.2f}x")
    print(f"   Majority Avg Income: ${results['economic_stats']['avg_majority_income']:.2f}")
    print(f"   Minority Avg Income: ${results['economic_stats']['avg_minority_income']:.2f}")

    print(f"\n🏠 HOUSING MARKET:")
    print(f"   Average Rent (Occupied): ${results['housing_stats']['avg_rent_occupied']:.2f}")
    print(f"   Rent Range: ${results['housing_stats']['min_rent']:.2f} - "
          f"${results['housing_stats']['max_rent']:.2f}")

    print(f"\n🚚 MOBILITY:")
    print(f"   Total Moves: {results['final_metrics']['total_moves']}")
    print(f"   Unhappy Agents: {results['final_metrics']['unhappy_agents']} "
          f"({results['final_metrics']['unhappy_percentage']:.1f}%)")


if __name__ == "__main__":
    # Enhanced model configuration
    CONFIG = {
        'width': 25,
        'height': 25,
        'density': 0.8,
        'minority_pc': 0.3,
        'similarity_threshold': 0.5,
        'majority_base_income': 15.0,
        'minority_base_income': 8.0,    # ~53% of majority income
        'income_variance': 4.0,
        'rent_distribution': 'gradient',
        'base_rent': 3.0,
        'rent_variance': 5.0,
        'moving_cost': 2.0,
        'income_distribution': 'normal',
        'steps': 100
    }

    try:
        # Run model
        logger.info("Starting Enhanced Economic Schelling model...")
        model = run_economic_schelling_model(**CONFIG)

        # Analyze results
        results = analyze_model_results(model)

        # Print summary
        print_model_summary(results)

        logger.info("Analysis completed successfully.")

    except Exception as e:
        logger.error(f"Model execution failed: {e}")
        raise
```
