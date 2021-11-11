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

Agent-based modelling has been used in an enormous variety of applications spanning the physical, biological, social, and management sciences. Applications range from modelling ancient civilizations that have been gone for hundreds of years to modelling how to design new markets that do not currently exist. Several agent-based modelling applications are summarized in this section, but the list is only a small sampling. Several of the papers covered here make the case that agent-based modelling, versus other modelling techniques is necessary because agent-based models can explicitly model the complexity arising from individual actions and interactions that exist in the real world.

Agent-based model structure spans a continuum, from elegant, minimalist academic models to large-scale decision support systems. Minimalist models are based on a set of idealized assumptions, designed to capture only the most salient features of a system. Decision support models tend to serve large-scale applications, are designed to answer real-world policy questions, include real data, and have passed appropriate validation tests to establish credibility.

## Agent-based modelling and complexity

ABMS can be traced to investigations into complex systems. Complex systems consist of interacting, autonomous components; complex adaptive systems have the additional capability for agents to adapt at the individual or population levels. These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. 

These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. Many of the early agent-based models were developed using the Swarm modelling software designed by Langton and others to model ALife (Minar et al, 1996). Initially, agent behaviours were modelled using exceedingly simple rules that still led to exceedingly complex emergent behaviours. In the past 10 years or so, available agent-based modelling software tools and development environments have expanded considerably in both numbers and capabilities.

One of the motivations for agent-based modeling is its ability to capture emergence. Even simple agent- based models in which agents are completely described by simple, deterministic rules and use only local information can self-organize and sustain themselves in ways that have not been explicitly programmed into the models. Emergence can be illustrated by simple agent-based models such as Life and Boids. More complex models of the kind that people are likely to build to represent real-world phenomenon can also exhibit emergent behavior resulting from agent interactions. Agent-based modeling algorithms based on emergence have led to specialized optimization techniques, such as ant colony optimization and particle swarm optimization, that have been used to solve practical problems (Bonabeau, Dorigo, and Theraulaz 1999; Barbati, Bruno, and Genovese 2011).

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


From a practical modelling standpoint, based on how and why agent-models are actually built and described in applications, we consider agents to have certain essential characteristics:

- An agent is a self-contained, modular, and uniquely identifiable individual. The modularity requirement implies that an agent has a boundary. One can easily determine whether something is part of an agent, is not part of an agent, or is a shared attribute. Agents have attributes that allow the agents to be distinguished from and recognized by other agents.

- An agent is autonomous and self-directed. An agent can function independently in its environment and in its interactions with other agents, at least over a limited range of situations that are of interest in the model. An agent has behaviours that relate information sensed by the agent to its decisions and actions. An agent's information comes through interactions with other agents and with the environment. An agent's behaviour can be specified by anything from simple rules to abstract models, such as neural networks or genetic programs that relate agent inputs to outputs through adaptive mechanisms.

- An agent has a state that varies over time. Just as a system has a state consisting of the collection of its state variables, an agent also has a state that represents the essential variables associated with its current situation. An agent's state consists of a set or subset of its attributes. The state of an agent-based model is the collective states of all the agents along with the state of the environment. An agent's behaviours are conditioned on its state. As such, the richer the set of an agent's possible states, the richer the set of behaviours that an agent can have. In an agent-based simulation, the state at any time is all the information needed to move the system from that point forward.

- An agent is social having dynamic interactions with other agents that influence its behaviour. Agents have protocols for interaction with other agents, such as for communication, movement and contention for space, the capability to respond to the environment, and others. Agents have the ability to recognize and distinguish the traits of other agents.

- An agent may be adaptive, for example, by having rules or more abstract mechanisms that modify its behaviours. An agent may have the ability to learn and adapt its behaviours based on its accumulated experiences. Learning requires some form of memory. In addition to adaptation at the individual level, populations of agents may be adaptive through the process of selection, as individuals better suited to the environment proportionately increase in numbers.

- An agent may be goal-directed, having goals to achieve (not necessarily objectives to maximize) with respect to its behaviours. This allows an agent to compare the outcome of its behaviours relative to its goals and adjust its responses and behaviours in future interactions.

- Agents may be heterogeneous. Unlike particle simulation that considers relatively homogeneous particles, such as idealized gas particles, or molecular dynamics simulations that model individual molecules and their interactions, agent simulations often consider the full range of agent diversity across a population. Agent characteristics and behaviours may vary in their extent and sophistication, how much information is considered in the agent's decisions, the agent's internal models of the external world, the agent's view of the possible reactions of other agents in response to its actions, and the extent of memory of past events the agent retains and uses in making its decisions. Agents may also be endowed with different amounts of resources or accumulate different levels of resources as a result of agent interactions, further differentiating agents.

## Environment 

Agents interact with their environment and with other agents. The environment may simply be used to provide information on the spatial location of an agent relative to other agents or it may provide a rich set of geographic information, as in a GIS. An agent's location, included as a dynamic attribute, is sometimes needed to track agents as they move across a landscape, contend for space, acquire resources, and encounter other situations. Complex environmental models can be used to model the agents’ environment. For example, hydrology or atmospheric dispersion models can provide point location-specific data on groundwater levels or atmospheric pollutants, respectively, which are accessible by agents. The environment may thus constrain agent actions. For example, the environment in an agent-based transportation model would include the infrastructure and capacities of the nodes and links of the road network. These capacities would create congestion effects (reduced travel speeds) and limit the number of agents moving through the transportation network at any given time.

## ABS Software and Toolkits

## References

-   [INTRODUCTORY TUTORIAL: AGENT-BASED MODELING AND SIMULATION](http://simulation.su/uploads/files/default/2014-macal-north.pdf)

-   [Tutorial on agent-based modelling and simulation](https://link.springer.com/article/10.1057/jos.2010.3)

-   [Agent-based modeling: Methods and techniques for simulating human systems](https://www.pnas.org/content/pnas/99/suppl_3/7280.full.pdf)

- [The Missing Data of Theory and Metaphor-driven Agent-based Evolutionary Social Simulation](https://www.carsonhlbao.com/post/filling-in-the-missing-data-of-theory-driven-agent-based-simulation-in-social-sciences/)

- [Robust coordination in adversarial social networks: From human behavior to agent-based modeling](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/C7D1EBF1898FB098EFCD1E4944600BF9/S2050124221000059a.pdf/robust_coordination_in_adversarial_social_networks_from_human_behavior_to_agentbased_modeling.pdf)
