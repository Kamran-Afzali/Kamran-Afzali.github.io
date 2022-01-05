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

Agent based approach can be a basis for research addressing characteristics of complex systems such as emergent phenomenon, the self-organization, and adaptation. Complex systems are comprised of autonomous yet interacting components with capability for agents to adapt at the individual or population levels.  More specifically one of the motivations for agent-based simulation is the capacity to model emergence. Emergence can exhibit emergent behavior resulting from agent-agent or agent-environment interactions. By definition, emergent phenomena cannot be reduced to micro-level unites as “the whole is more than the sum of its parts” because of the interactions between the parts. An emergent phenomenon has properties that are dissociated/transcend the properties of individual units that makes them difficult to understand, predict and sometimes counterintuitive. In other words, *Even simple agent- based models in which agents are completely described by simple, deterministic rules and use only local information can self-organize and sustain themselves in ways that have not been explicitly programmed into the models.* 


## Structure of an agent-based model
A typical agent-based model has two elements:
•	Agents, with their attributes and behaviors.
•	Environment. Agents live in and interact according to the affordance their environment.
These elements define the quality of quantity of interaction between agents as well as topology of connectedness that outlines how and with whom agents interact.

### Agents
With the context of ABS the precise definition of the term agent is the subject of much discussion as there is no universal agreement how to define the base unit. Some authors insist that agents’ behavior must be adaptive for it to be considered as an agent. That is agents’ attributes should include both base-level rules of behavior as well as a higher-level set of “rules to change the rules.” The base-level rules provide responses to the environment, while the rules-to- change-the-rules provide adaptation. Along these lines, there are important implications of describing a model in terms of agents as major effects can emerge through relatively minor modification in agents’ attributes.


For practical modeling purposes, we consider agents to have certain properties and attributes, as follows (Figure 1):

- Autonomy. An agent is autonomous and self-directed. An agent can function independently in its environment and in its interactions with other agents, generally from a limited range of situations that are of interest and that arise in the model. When we refer to an agent’s behavior, we refer to a general process that links the information the agent senses from its environment and interactions to its decisions and actions.

- Modularity. Agents are modular or self-contained. An agent is an identifiable, discrete entity with a set of characteristics or attributes, behaviors, and decision-making capability. The modularity requirement implies that an agent has a boundary, and one can easily determine whether something (that is, an element of the model’s state) is part of an agent or is not part of an agent, or is a characteristic shared among agents.

- Sociality. An agent is social, interacting with other agents. Common agent interaction protocols include contention for space and collision avoidance, agent recognition, communication and information exchange, influence, and other domain-or application-specific mechanisms.

- Conditionality. An agent has a state that varies over time. Just as a system has a state consisting of the collection of its state variables, an agent also has a state that represents its condition, defined by the essential variables associated with its current situation. An agent’s state consists of a set or subset of its attributes and its behaviors. The state of an agent-based model is the collective states of all the agents along with the state of the environment. An agent’s behaviors are conditioned on its state. As such, the richer the set of an agent’s possible states, the richer the set of behaviors that an agent can have.


Based on why and how ABS models are built and for practical modeling purposes, agents are built to have certain properties and attributes as their essential characteristics:

- Autonomy: An agent is autonomous and self-directed. An agent can function independently in its environment and in its interactions with other agents over a limited range of situations that are of interest in the model, generally from a limited range of situations that are of interest and that arise in the model. When we refer to an agent’s behavior, we refer to a general process that links the information the agent senses from its environment and interactions to its decisions and actions. In other words, an agent's behaviour can be specified by anything from simple rules to abstract models, such as neural networks or genetic programs that relate agent inputs to outputs through adaptive mechanisms.

- Modularity: Agents are modular or self-contained. Agents have attributes that allow the agents to be distinguished from and recognized by other agents.The modularity requirement implies that an agent has a boundary. One can easily determine whether something is part of an agent, is not part of an agent, or is a shared attribute.
An agent is an identifiable, discrete entity with a set of characteristics or attributes, behaviors, and decision-making capability. 

- Sociality: An agent is social having dynamic interactions with other agents that influence its behaviour.  Common agent interaction protocols include communication/ agent recognition, movement and contention for space and collision avoidance, the capability to respond to the environment.


- Conditionality: An agent has a state that varies over time. Just as a system has a state consisting of the collection of its state variables, an agent also has a state that represents the essential variables associated with its current situation. An agent's state consists of a set or subset of its attributes. The state of an agent-based model is the collective states of all the agents along with the state of the environment. An agent's behaviours are conditioned on its state. As such, the richer the set of an agent's possible states, the richer the set of behaviours that an agent can have. In an agent-based simulation, the state at any time is all the information needed to move the system from that point forward.

- An agent may be adaptive, for example, by having rules or more abstract mechanisms that modify its behaviours. An agent may have the ability to learn and adapt its behaviours based on its accumulated experiences. Learning requires some form of memory. In addition to adaptation at the individual level, populations of agents may be adaptive through the process of selection, as individuals better suited to the environment proportionately increase in numbers.

- An agent may be goal-directed, having goals to achieve (not necessarily objectives to maximize) with respect to its behaviours. This allows an agent to compare the outcome of its behaviours relative to its goals and adjust its responses and behaviours in future interactions.

- Agents may be heterogeneous. Unlike particle simulation that considers relatively homogeneous particles, such as idealized gas particles, or molecular dynamics simulations that model individual molecules and their interactions, agent simulations often consider the full range of agent diversity across a population. Agent characteristics and behaviours may vary in their extent and sophistication, how much information is considered in the agent's decisions, the agent's internal models of the external world, the agent's view of the possible reactions of other agents in response to its actions, and the extent of memory of past events the agent retains and uses in making its decisions. Agents may also be endowed with different amounts of resources or accumulate different levels of resources as a result of agent interactions, further differentiating agents.

### Environment 

The environment provides information on the spatial location of an agent relative to other agents and hence if it is possible for a given agent to interact with other agents. An agent's location, is a dynamic attribute that is required to track agents as they change their location across a landscape, interact with other agents, acquire resources, and encounter new situations. Other information can be included to build complex environmental schemas to model the agents’ surroundings. For instance, the environment may provide a rich set of geographic information about the affordance of the surrounding circumstances of an agent and hence their interaction with the environment. Along these lines, the environment in an agent-based disease model would include the focal points (e.g. city centers) and capacities of the cities and links of the road network. These capacities would create dispersion effects (reduced/increased infection speeds) and set limit the number of agents moving through a given city network at any given time. 

## When to do ABS
As a conclusion we put forward some insights on distinct advantages of ABM conventional simulation approaches. Several reasons have been highlighted as advantages of agent-based modeling compared to traditional approaches to modeling dynamic systems, including the capacity to captures emergent phenomena, providing a naturalistic description of a system and the inherent flexibility of ABM. More specifically, ABS relevant when a problem has a natural representation as being comprised of agents, with behaviors that can be well-defined, where agents adapt/change their behaviors and engage in dynamic strategic interactions such as dynamic relationships with other agents. It is possible to do an ABS using specially designed ABS toolkits and software adapted to the specific requirements for modeling environments and agents or using all-purpose general, programming or languages software. In the same vein, ABS can be performed on a regular desktop computer, or using large-scale computing clusters, or it can be done at any scale in-between. Projects often begin from a small scale, using all-purpose general programming language or desktop ABS tools. The initial prototype ABS then grows in stages into a larger-scale agent-based model, often using dedicated ABS toolkits. Over the years, numerous agent-based modelling and simulation tools have been developed each with a somewhat unique motive for its presence such generality, usability, modifiability, scalability and performance. In our next post we will go through an example of ABS using MESA framework in python. 

## References

-   [INTRODUCTORY TUTORIAL: AGENT-BASED MODELING AND SIMULATION](http://simulation.su/uploads/files/default/2014-macal-north.pdf)

-   [Tutorial on agent-based modelling and simulation](https://link.springer.com/article/10.1057/jos.2010.3)

-   [Agent-based modeling: Methods and techniques for simulating human systems](https://www.pnas.org/content/pnas/99/suppl_3/7280.full.pdf)

- [The Missing Data of Theory and Metaphor-driven Agent-based Evolutionary Social Simulation](https://www.carsonhlbao.com/post/filling-in-the-missing-data-of-theory-driven-agent-based-simulation-in-social-sciences/)
<!-- 
- [Robust coordination in adversarial social networks: From human behavior to agent-based modeling](https://www.cambridge.org/core/services/aop-cambridge-core/content/view/C7D1EBF1898FB098EFCD1E4944600BF9/S2050124221000059a.pdf/robust_coordination_in_adversarial_social_networks_from_human_behavior_to_agentbased_modeling.pdf)
 -->
- [Agent Based Modelling and Simulation tools: A review of the state-of-art software](https://www.sciencedirect.com/science/article/pii/S1574013716301198?casa_token=_zSawSxRC1AAAAAA:UxWt1a36Wrh8q3liF5KyIj7FqjtZUoDnM9eCBeS3iTyfUpWF01inDSHGUzAZ70uYBsZ1dDTuVx8a)
