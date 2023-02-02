
## What Does Partially Observable Markov Decision Process (POMDP) Mean?

A partially observable Markov decision process (POMDP) is a generalization of a Markov decision process (MDP). A POMDP models an agent decision process in which it is assumed that the system dynamics are determined by an MDP, but the agent cannot directly observe the underlying state. Instead, it must maintain a sensor model (the probability distribution of different observations given the underlying state) and the underlying MDP. Unlike the policy function in MDP which maps the underlying states to the actions, POMDP's policy is a mapping from the history of observations (or belief states) to the actions.

The POMDP framework is general enough to model a variety of real-world sequential decision processes. Applications include robot navigation problems, machine maintenance, and planning under uncertainty in general. The general framework of Markov decision processes with imperfect information was described by Karl Johan Åström in 1965 in the case of a discrete state space, and it was further studied in the operations research community where the acronym POMDP was coined. It was later adapted for problems in artificial intelligence and automated planning by Leslie P. Kaelbling and Michael L. Littman.

An exact solution to a POMDP yields the optimal action for each possible belief over the world states. The optimal action maximizes the expected reward (or minimizes the cost) of the agent over a possibly infinite horizon. The sequence of optimal actions is known as the optimal policy of the agent for interacting with its environment.

A partially observable Markov decision process (POMPD) is a Markov decision process in which the agent cannot directly observe the underlying states in the model. The Markov decision process (MDP) is a mathematical framework for modeling decisions showing a system with a series of states and providing actions to the decision maker based on those states.

The POMPD builds on that concept to show how a system can deal with the challenges of limited observation. In the partially observable Markov decision process, because the underlying states are not transparent to the agent, a concept called a “belief state” is helpful. The belief state provides a way to deal with the ambiguity inherent in the model.

The POMPD is useful in reinforcement learning where a system can go over the MPD or POMPD model utilizing what is known to build a clearer picture of probability outcomes.








The Markov decision process model has proven very successful for learning how to act in stochastic environments. In this chapter, we explore methods for reinforcement learning by relaxing one of the limiting factors of the MDP model, namely the assumption that the agent knows with full certainty the state of the environment. Put otherwise, the agent’s sensors allow it to perfectly monitor the state at all times, where the state captures all aspects of the environment relevant for optimal decision making. Clearly, this is a strong assumption that can restrict the applicability of the MDP framework. For instance, when certain state features are hidden from

the agent the state signal will no longer be Markovian, violating a key assumption of most reinforcement-learning techniques (Sutton and Barto, 1998).
One example of particular interest arises when applying reinforcement learning to embodied agents. In many robotic applications the robot’s on-board sensors do not allow it to unambiguously identify its own location or pose (Thrun et al, 2005).
Furthermore, a robot’s sensors are often limited to observing its direct surroundings, and might not be adequate to monitor those features of the environment’s state beyond its vicinity, so-called hidden state. Another source of uncertainty regarding the true state of the system are imperfections in the robot’s sensors. For instance, let us suppose a robot uses a camera to identify the person it is interacting with. The
face-recognition algorithm processing the camera images is likely to make mistakes sometimes, and report the wrong identity. Such an imperfect sensor also prevents the robot from knowing the true state of the system: even if the vision algorithm reports person A, it is still possible that person B is interacting with the robot. Although in some domains the issues resulting from imperfect sensing might be ignored, in general they can lead to severe performance deterioration (Singh et al, 1994).
Instead, in this chapter we consider an extension of the (fully observable) MDP setting that also deals with uncertainty resulting from the agent’s imperfect sensors. A partially observable Markov decision process (POMDP) allows for optimal decision making in environments which are only partially observable to the agent (Kaelbling et al, 1998), in contrast with the full observability mandated by the MDP model. In general the partial observability stems from two sources: (i) multiple states give the same sensor reading, in case the agent can only sense a limited part of the environment, and (ii) its sensor readings are noisy: observing the same state can result in different sensor readings. The partial observability can lead to “perceptual aliasing”: different parts of the environment appear similar to the agent’s sensor system, but require different actions. The POMDP captures the partial observability in a probabilistic observation model, which relates possible observations to states.



## References
+ https://artint.info/
+ https://www.st.ewi.tudelft.nl/mtjspaan/pub/Spaan12pomdp.pdf
+ https://www.techopedia.com/definition/32824/partially-observable-markov-decision-process-pomdp
+ https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume23/roy05a-html/node2.html
+ https://wiki.ubc.ca/Course:CPSC522/Partially_Observable_Markov_Decision_Processes
