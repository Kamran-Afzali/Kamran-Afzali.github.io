---
title: "Agent Based Simulation"
output:
  html_document:
    df_print: paged
    keep_md: yes
editor_options: 
  markdown: 
    wrap: 72
---

# Agent Based Simulation

Agent-based modelling and simulation (ABMS) is a relatively new approach to modelling complex systems composed of interacting, autonomous ‘agents’. Agents have behaviours, often described by simple rules, and interactions with other agents, which in turn influence their behaviours. By modelling agents individually, the full effects of the diversity that exists among agents in their attributes and behaviours can be observed as it gives rise to the behaviour of the system as a whole. By modelling systems from the ‘ground up’—agent-by-agent and interaction-by-interaction—self-organization can often be observed in such models. Patterns, structures, and behaviours emerge that were not explicitly programmed into the models, but arise through the agent interactions. The emphasis on modelling the heterogeneity of agents across a population and the emergence of self-organization are two of the distinguishing features of agent-based simulation as compared to other simulation techniques such as discrete-event simulation and system dynamics. Agent-based modelling offers a way to model social systems that are composed of agents who interact with and influence each other, learn from their experiences, and adapt their behaviours so they are better suited to their environment.

ABM is a modeling and computational framework for simulating dynamic processes that involve autonomous agents. An autonomous agent acts on its own without external direction in response to situations the agent encounters during the simulation. Modeling a population of autonomous agents, each with its own characteristics and behaviors, that extensively interact is a defining feature of an ABS. Agent-based simulation is most commonly used to model individual decision-making and social and organizational behavior.

Several indicators of the growing interest in agent-based modelling include the number of conferences and workshops devoted entirely to or having tracks on agent-based modelling, the growing number of peer-reviewed publications in discipline-specific academic journals across a wide range of application areas as well as in modelling and simulation journals, the growing number of openings for people specializing in agent-based modelling, and interest on the part of funding agencies in supporting programmes that require agent-based models.

## Agent-based modelling and complexity

ABMS can be traced to investigations into complex systems. Complex systems consist of interacting, autonomous components; complex adaptive systems have the additional capability for agents to adapt at the individual or population levels. These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. 

These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. Many of the early agent-based models were developed using the Swarm modelling software designed by Langton and others to model ALife (Minar et al, 1996). Initially, agent behaviours were modelled using exceedingly simple rules that still led to exceedingly complex emergent behaviours. In the past 10 years or so, available agent-based modelling software tools and development environments have expanded considerably in both numbers and capabilities.

## Structure of an agent-based model
A typical agent-based model has three elements:

- Agents, their attributes and behaviors.
- Agent relationships and methods of interaction. An underlying topology of connectedness defines how and with whom agents interact.
- Agents’ environment. Agents live in and interact with their environment, in addition to other agents.

### Agents
There is not universal agreement on the precise definition of the term agent in the context of ABS. It is the subject of much discussion and occasional debate. The issue is more than an academic one, as it often surfaces when one makes a claim that their model is agent-based or when one is trying to discern whether such claims made by others are valid. There are important implications of the term agent-based when used to describe a model in terms of the model’s capabilities or potential capabilities that could be attained through relatively minor modification. In the literature, descriptions of the term agent tend to agree on more points than they disagree. Some modelers consider any type of independent component, whether it be a software component or a model to be an agent (Bonabeau 2001). Some authors insist that a component’s behavior must also be adaptive in order for it to be considered an agent. Casti (1997) argues that agents should contain both base-level rules for behavior as well as a higher-level set of “rules to change the rules.” The base-level rules provide responses to the environment, while the rules-to- change-the-rules provide adaptation. Jennings’ (2000) computer science-based view of agent emphasizes the essential agent characteristic of autonomous behavior.
For practical modeling purposes, we consider agents to have certain properties and attributes, as follows (Figure 1):

- Autonomy. An agent is autonomous and self-directed. An agent can function independently in its environment and in its interactions with other agents, generally from a limited range of situations that are of interest and that arise in the model. When we refer to an agent’s behavior, we refer to a general process that links the information the agent senses from its environment and interactions to its decisions and actions.

- Modularity. Agents are modular or self-contained. An agent is an identifiable, discrete entity with a set of characteristics or attributes, behaviors, and decision-making capability. The modularity requirement implies that an agent has a boundary, and one can easily determine whether something (that is, an element of the model’s state) is part of an agent or is not part of an agent, or is a characteristic shared among agents.

- Sociality. An agent is social, interacting with other agents. Common agent interaction protocols include contention for space and collision avoidance, agent recognition, communication and information exchange, influence, and other domain-or application-specific mechanisms.

- Conditionality. An agent has a state that varies over time. Just as a system has a state consisting of the collection of its state variables, an agent also has a state that represents its condition, defined by the essential variables associated with its current situation. An agent’s state consists of a set or subset of its attributes and its behaviors. The state of an agent-based model is the collective states of all the agents along with the state of the environment. An agent’s behaviors are conditioned on its state. As such, the richer the set of an agent’s possible states, the richer the set of behaviors that an agent can have.

## References

-   [INTRODUCTORY TUTORIAL: AGENT-BASED MODELING AND SIMULATION](http://simulation.su/uploads/files/default/2014-macal-north.pdf)

-   [Tutorial on agent-based modelling and simulation](https://link.springer.com/article/10.1057/jos.2010.3)

-   [Agent-based modeling: Methods and techniques for simulating human systems](https://www.pnas.org/content/pnas/99/suppl_3/7280.full.pdf)

- [The Missing Data of Theory and Metaphor-driven Agent-based Evolutionary Social Simulation](https://www.carsonhlbao.com/post/filling-in-the-missing-data-of-theory-driven-agent-based-simulation-in-social-sciences/)

- [Robust coordination in adversarial social networks: From human behavior to agent-based modeling](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/C7D1EBF1898FB098EFCD1E4944600BF9/S2050124221000059a.pdf/robust_coordination_in_adversarial_social_networks_from_human_behavior_to_agentbased_modeling.pdf)
