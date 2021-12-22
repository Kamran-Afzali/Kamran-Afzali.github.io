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

Computational modelling of the complex systems of interacting, autonomous gents is made possible through recent innovations in agent-based modelling and simulation (ABMS). In this approach individual agents have behaviours and interactions with other agents and the affordance of their environment which in turn influence their own behaviours. Autonomous agent acts and interacts in response to situations the agent encounters during the simulation. Simulating attributes of individual agents and their environment, enables study if the emergent properties of the system as well as the full effects of the diversity that exists among agents. In other words, self-organizing patterns, structures, and behaviours that were not explicitly encoded into the models but rise through the system interactions can be studied through modelling systems from the ‘ground up’—agent-by-agent and agent-by-environment interactions. The emphasis on modelling the attributes and diversity of agents, affordance of the environment, and the emergence of self-organizng patterns are unique qualities of agent-based modelling as compared to other simulation techniques. Agent-based modelling offers a way to model social systems that are composed of agents who interact with and influence each other, learn from their experiences, and adapt their behaviours so they are better suited to their environment. Given these qualities agent-based simulation is most commonly used to model individual decision-making and social and organizational behavior.


Agent-based simulation has been used in a large range of domains including physical, biological, social, and behavioral sciences. Simulations covers a continuum that goes from elegant, yet minimalist academic models based on a set of idealized assumptions, designed to capture only the most salient features of a system to large-scale decision support systems for all-encompassing applications based on real data, and have passed appropriate validation tests to establish credibility.
In both cases agent-based modelling is a powerful approach to guide researchers' intuition for the analysis of unprecedented scenarios (e.g., counterfactuals), as the following insights of Doran, Gilbert, and Hales.

> We can therefor hope to develop an abstract theory of multiple agent systems and then to transfer its insights to human social systems, without a priori commitment to existing particular social theory. (Doran 1998).

> Our stress… is on a new experimental methodology consisting of observing theoretical models performing on some testbed. Such a new methodology could be defined as ‘exploratory simulation’ … (Gilbert 1995).

> Artificial societies do not aim to model real societies in any direct sense. They can be seen as an aid to intuition in which the researcher formalizes abstract and logical relationships between entities. (Hales 1998).
Also, there is a growing number of academic courses and conferences devoted to agent-based modelling, as well as the growing number of peer-reviewed publications across a wide range of application areas as well as interest on the part of funding agencies in supporting programmes that require agent-based models.
 
It is noteworthy that rather than a specific toolset/software, ABM can be conceptualized as a mindset/viewpoint emphasizing description of a system from the perspective of its constituent units. This is a micro-level or microscopic modeling, which is an alternative the macro-level or macroscopic modeling. Along these lines it is important to have a clear notion of when and how to use ABM before attempting an implementation.  Indeed, there is fundamental understanding of why to simulate a system, it is fairly easy to program an agent-based model. But although ABM is technically simple, it is also conceptually deep. This unusual combination can sometimes leads to improper use of ABM.


## Agent-based modelling and complexity

ABMS can be traced to investigations into complex systems. Complex systems consist of interacting, autonomous components; complex adaptive systems have the additional capability for agents to adapt at the individual or population levels. These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. 

These collective investigations into complex systems sought to identify universal principles of such systems, such as the basis for self-organization, emergent phenomenon, and the origins of adaptation in nature. ABMS began largely as the set of ideas, techniques, and tools for implementing computational models of complex adaptive systems. Many of the early agent-based models were developed using the Swarm modelling software designed by Langton and others to model ALife (Minar et al, 1996). Initially, agent behaviours were modelled using exceedingly simple rules that still led to exceedingly complex emergent behaviours. In the past 10 years or so, available agent-based modelling software tools and development environments have expanded considerably in both numbers and capabilities.

One of the motivations for agent-based modeling is its ability to capture emergence. Even simple agent- based models in which agents are completely described by simple, deterministic rules and use only local information can self-organize and sustain themselves in ways that have not been explicitly programmed into the models. Emergence can be illustrated by simple agent-based models such as Life and Boids. More complex models of the kind that people are likely to build to represent real-world phenomenon can also exhibit emergent behavior resulting from agent interactions. Agent-based modeling algorithms based on emergence have led to specialized optimization techniques, such as ant colony optimization and particle swarm optimization, that have been used to solve practical problems (Bonabeau, Dorigo, and Theraulaz 1999; Barbati, Bruno, and Genovese 2011).

Emergent phenomena result from the interactions of individual entities. By definition, they cannot be reduced to the system’s parts: the whole is more than the sum of its parts because of the interactions between the parts. An emergent phenomenon can have properties that are decoupled from the properties of the part. For example, a traffic jam, which results from the behavior of and interactions between individual vehicle drivers, may be moving in the direction opposite that of the cars that cause it. This characteristic of emergent phenomena makes them difficult to understand and predict: emergent phenomena can be counterintuitive. Numerous examples of counterintuitive emer- gent phenomena will be described in the following sections. ABM is, by its very nature, the canonical approach to modeling emergent phenomena: in ABM, one models and simulates the behavior of the system’s constituent units (the agents) and their interactions, cap- turing emergence from the bottom up when the simulation is run.

An agent-based simulation is a powerful technique if serving as an aid to human intuition and an option in the theoretical interpretation toolbox for the analysis of unprecedented scenarios (e.g., counterfactuals), as the following insights of Doran, Gilbert, and Hales.

> We can therefor hope to develop an abstract theory of multiple agent systems and then to transfer its insights to human social systems, without a priori commitment to existing particular social theory. (Doran 1998).

> Our stress… is on a new experimental methodology consisting of observing theoretical models performing on some testbed. Such a new methodology could be defined as ‘exploratory simulation’ … (Gilbert 1995).

> Artificial societies do not aim to model real societies in any direct sense. They can be seen as an aid to intuition in which the researcher formalizes abstract and logical relationships between entities. (Hales 1998).

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

### Environment 

Agents interact with their environment and with other agents. The environment may simply be used to provide information on the spatial location of an agent relative to other agents or it may provide a rich set of geographic information, as in a GIS. An agent's location, included as a dynamic attribute, is sometimes needed to track agents as they move across a landscape, contend for space, acquire resources, and encounter other situations. Complex environmental models can be used to model the agents’ environment. For example, hydrology or atmospheric dispersion models can provide point location-specific data on groundwater levels or atmospheric pollutants, respectively, which are accessible by agents. The environment may thus constrain agent actions. For example, the environment in an agent-based transportation model would include the infrastructure and capacities of the nodes and links of the road network. These capacities would create congestion effects (reduced travel speeds) and limit the number of agents moving through the transportation network at any given time.

## When to do ABS
We conclude by offering some ideas on the situations for which agent-based modeling can offer distinct advantages to conventional simulation approaches such as discrete event simulation (Law 2007), system dynamics (Sterman 2000) and other quantitative modeling techniques. Axtell (2000) discusses several reasons for agent-based modeling especially compared to traditional approaches to modeling economic systems. The benefits of ABM over other modeling techniques can be captured in three statements: (i) ABM captures emergent phenomena; (ii) ABM provides a natural description of a system; and (iii) ABM is flexible. It is clear, however, that the ability of ABM to deal with emergent phenomena is what drives the other benefits.


When is it beneficial to think in terms of agents? When any of the following criteria are satisfied:
- When the problem has a natural representation as being comprised of agents
- When there are decisions and behaviors that can be well-defined
- When it is important that agents have behaviors that reflect how individuals actually behave (if known)
- When it is important that agents adapt and change their behaviors
- When it is important that agents learn and engage in dynamic strategic interactions
- When it is important that agents have dynamic relationships with other agents, and agent relationships form, change, and decay
- When it is important to model the processes by which agents form organizations, and adaptation and learning are important at the organization level
- When it is important that agents have a spatial component to their behaviors and interactions
- When the structure of the system does not depend entirely on the past, and new dynamic mechanisms may be invoked or emerge that govern how the system will evolve in the future.
- When arbitrarily large numbers of agents, agent interactions and agent states is important
- When process structural change needs to be an endogenous result of the model, rather than an input to the model

## ABS Software and Toolkits

Agent-based modeling can be done using general, all-purpose software or programming languages, or can be done using specially designed software and toolkits that address the specific requirements for modeling agents. Agent modeling can be done in the small, on the desktop, or in the large, using large-scale computing clusters, or it can be done at any scale in-between. Projects often begin small, using one of the desktop ABS tools, or whatever tool or programming language the developers are familiar with. The initial prototype then grows in stages into a larger-scale agent-based model, often using dedicated ABS toolkits. Often one begins developing their first agent model using the approach that one is most familiar with, or the approach that one finds easiest to learn given their background and experience.

Over the years, numerous agent-based modelling and simulation tools have been developed each with a somewhat unique motive for its presence. Every strategy marks a specific programming syntax and semantics for the agents and has a differing base concerning the generality, usability, modifiability, scalability and performance.

## References

-   [INTRODUCTORY TUTORIAL: AGENT-BASED MODELING AND SIMULATION](http://simulation.su/uploads/files/default/2014-macal-north.pdf)

-   [Tutorial on agent-based modelling and simulation](https://link.springer.com/article/10.1057/jos.2010.3)

-   [Agent-based modeling: Methods and techniques for simulating human systems](https://www.pnas.org/content/pnas/99/suppl_3/7280.full.pdf)

- [The Missing Data of Theory and Metaphor-driven Agent-based Evolutionary Social Simulation](https://www.carsonhlbao.com/post/filling-in-the-missing-data-of-theory-driven-agent-based-simulation-in-social-sciences/)
<!-- 
- [Robust coordination in adversarial social networks: From human behavior to agent-based modeling](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/C7D1EBF1898FB098EFCD1E4944600BF9/S2050124221000059a.pdf/robust_coordination_in_adversarial_social_networks_from_human_behavior_to_agentbased_modeling.pdf)
 -->
- [Agent Based Modelling and Simulation tools: A review of the state-of-art software](https://www.sciencedirect.com/science/article/pii/S1574013716301198?casa_token=_zSawSxRC1AAAAAA:UxWt1a36Wrh8q3liF5KyIj7FqjtZUoDnM9eCBeS3iTyfUpWF01inDSHGUzAZ70uYBsZ1dDTuVx8a)
