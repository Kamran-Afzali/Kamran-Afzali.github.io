# Post 1: Introduction to Agent-Based Modeling and Mesa with Schelling’s Segregation Model

Agent-based modeling (ABM) is a computational approach to studying complex systems by simulating the actions and interactions of autonomous agents. Unlike traditional mathematical models that rely on aggregate equations, ABMs focus on individual entities, their behaviors, and their local interactions, which collectively give rise to emergent macro-level patterns. This approach is particularly valuable in disciplines such as sociology, economics, and ecology, where micro-level decisions lead to unexpected system-wide outcomes. In this post, we introduce the core concepts of ABM using Mesa, a Python library designed for building, simulating, and visualizing agent-based models. We implement Thomas Schelling’s seminal segregation model to demonstrate how simple agent preferences can produce striking patterns of residential segregation. Through this implementation, we explore Mesa’s fundamental components, develop a dynamic visualization, and formalize the model mathematically to provide a rigorous foundation for understanding ABM.

## Agent-Based Modeling: Core Concepts

ABM represents a system as a collection of agents—discrete entities with defined attributes and behaviors—operating within an environment. Agents interact locally according to rules, and their collective behavior generates emergent phenomena, such as segregation, cooperation, or resource depletion. ABMs are particularly suited to systems where heterogeneity, local interactions, and adaptation are critical, as they allow researchers to observe how micro-level rules scale to macro-level outcomes. Key components of an ABM include:

- **Agents**: Individual entities with attributes (e.g., type, location) and behaviors (e.g., movement, decision-making).
- **Environment**: The spatial or relational structure in which agents operate, such as a grid or network.
- **Scheduler**: A mechanism to determine the order and timing of agent actions.
- **Emergence**: System-wide patterns arising from local interactions, not explicitly programmed into the model.

Mesa, a Python-based ABM framework, provides tools to implement these components efficiently. It includes classes for agents (`Agent`), models (`Model`), spatial structures (e.g., `MultiGrid`), schedulers (e.g., `RandomActivation`), and visualization tools (e.g., `ModularServer`). In this post, we use these components to build Schelling’s segregation model, a classic example of how simple preferences can lead to complex social outcomes.

## Schelling’s Segregation Model

Proposed by Thomas Schelling in the 1970s, the segregation model explores how individuals with mild preferences for living near similar neighbors can inadvertently produce highly segregated neighborhoods. The model assumes a population of agents, each belonging to one of two types (e.g., red or blue), placed on a grid. Each agent evaluates their neighborhood based on the proportion of similar neighbors and moves to a new location if their preference threshold is not met. Despite its simplicity, the model generates emergent patterns of segregation, illustrating how individual choices aggregate into societal outcomes.

Mathematically, consider a grid of size \( N \times N \), with a population of agents distributed across cells. Let each agent belong to one of two types, denoted \( t_i \in \{1, 2\} \), where \( i \) indexes the agent. The grid is partially occupied, with a fraction of cells empty. Each agent assesses their neighborhood, defined as the Moore neighborhood (the eight adjacent cells), and computes the proportion of neighbors of the same type:

\[
p_i = \frac{\text{Number of neighbors with } t_j = t_i}{\text{Total number of occupied neighboring cells}}
\]

An agent is satisfied if \( p_i \geq \tau \), where \( \tau \in [0, 1] \) is the similarity threshold. If unsatisfied (\( p_i < \tau \)), the agent moves to a randomly selected empty cell. The model iterates until all agents are satisfied or a maximum number of steps is reached. The key metric is the degree of segregation, often measured by the average similarity across agents:

\[
S = \frac{1}{M} \sum_{i=1}^M p_i
\]

where \( M \) is the number of agents. Higher values of \( S \) indicate greater segregation.

## Implementing the Model in Mesa

We now implement Schelling’s model using Mesa. The code defines an agent class, a model class, and a visualization server. Agents are assigned a type and a satisfaction threshold, and the model tracks their positions on a grid, updating them based on satisfaction. The visualization displays the grid dynamically, allowing users to observe segregation patterns as they emerge.



This code defines the `SchellingAgent` class, which checks its neighborhood’s composition and moves if unsatisfied, and the `SchellingModel` class, which initializes the grid, places agents, and tracks segregation. The `agent_portrayal` function maps agent types to colors (red or blue), and the `ModularServer` creates a browser-based interface with a grid visualization and a chart tracking the segregation metric over time.

## Running and Interpreting the Model

To run the model, ensure Mesa is installed (`pip install mesa`). Save the code in a file (e.g., `schelling_model.py`) and add `server.launch()` at the end to start the server. The visualization will appear in a browser at `http://127.0.0.1:8521`. The grid shows agents as colored squares (red for type 1, blue for type 2), with empty cells in white. The chart plots the average similarity \( S \) over time, typically increasing as agents cluster with similar types.

Initial runs with a 20x20 grid, 80% density, and a threshold of 0.3 show agents starting in a random configuration. Over iterations, clusters of same-type agents form, reflecting segregation despite the modest threshold. This emergent pattern aligns with Schelling’s insight: even weak preferences for similarity can lead to highly segregated outcomes, a phenomenon observable in real-world urban settings.

## Mathematical Formalism

The model’s dynamics can be formalized as a discrete-time stochastic process. Let \( G = (V, E) \) represent the grid as a graph, where \( V \) is the set of cells and \( E \) defines the Moore neighborhood. Each cell \( v \in V \) is either empty or occupied by an agent with type \( t_v \in \{1, 2\} \). The state of the system at time \( t \) is the configuration of agent positions and types, \( \sigma(t) \). The transition rule for an agent at position \( v \) is:

1. Compute \( p_v(t) = \frac{|\{u \in N(v) : t_u = t_v\}|}{|\{u \in N(v) : u \text{ occupied}\}|} \), where \( N(v) \) is the set of neighbors.
2. If \( p_v(t) < \tau \), select a random empty cell \( u \in V_{\text{empty}} \) and update \( \sigma(t+1) \) by moving the agent to \( u \).

The system evolves until a stable state is reached (all agents satisfied or a fixed point) or a maximum number of steps is completed. The segregation metric \( S(t) \) quantifies the system’s state, with \( S \to 1 \) indicating complete segregation.

## Learning Outcomes and Implications

This implementation introduces Mesa’s core architecture: agents, models, grids, schedulers, and visualization. Learners gain hands-on experience with ABM by building a model that produces emergent patterns from simple rules. The visualization highlights how local decisions (moving when unsatisfied) create global segregation, a key insight in social science. The mathematical formalism provides a rigorous basis for analyzing the model, enabling extensions such as varying thresholds or grid topologies.

Future posts in this series will build on these foundations, exploring more complex dynamics, such as resource competition and network interactions. By mastering Schelling’s model, learners are equipped to tackle advanced ABM challenges, leveraging Mesa’s flexibility to simulate diverse systems.
