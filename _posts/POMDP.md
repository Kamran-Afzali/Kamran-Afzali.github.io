
## What Does Partially Observable Markov Decision Process (POMDP) Mean?

The Markov decision process (MDP) is a mathematical framework for modeling decisions showing a system with a series of states and providing actions to the decision maker based on those states. A partially observable Markov decision process (POMDP) is a generalization of a Markov decision process (MDP). A POMDP models an agent decision process in which it is assumed that the system dynamics are determined by an MDP, but the agent cannot directly observe the underlying state. Instead, it must maintain a sensor model (the probability distribution of different observations given the underlying state) and the underlying MDP. Unlike the policy function in MDP which maps the underlying states to the actions, POMDP's policy is a mapping from the history of observations (or belief states) to the actions. The POMDP framework is general enough to model a variety of real-world sequential decision processes. An exact solution to a POMDP yields the optimal action for each possible belief over the world states. The optimal action maximizes the expected reward (or minimizes the cost) of the agent over a possibly infinite horizon. The sequence of optimal actions is known as the optimal policy of the agent for interacting with its environment.

The POMPD model how a system can deal with the challenges of limited observation. In the partially observable Markov decision process, because the underlying states are not transparent to the agent, a concept called a “belief state” is helpful. The belief state provides a way to deal with the ambiguity inherent in the model. The POMPD is useful in reinforcement learning where a system can go over the MPD or POMPD model utilizing what is known to build a clearer picture of probability outcomes. A source of uncertainty regarding the true state of the system are imperfections in the agent’s sensors. Such an imperfect sensor also prevents the agent from knowing the true state of the system. Here we consider an extension of the (fully observable) MDP setting that also deals with uncertainty resulting from the agent’s imperfect sensors. In general the partial observability stems from two sources: (i) multiple states give the same sensor reading, in case the agent can only sense a limited part of the environment, and (ii) its sensor readings are noisy: observing the same state can result in different sensor readings. The partial observability can lead to “perceptual aliasing”: different parts of the environment appear similar to the agent’s sensor system, but require different actions. The POMDP captures the partial observability in a probabilistic observation model, which relates possible observations to states.


Despite an increasing number of applications POMDPs are still poorly understood. The complexity of the mathematics, the inaccessibility of POMDP solvers developed by the Artificial Intelligence (AI) community, and the lack of introductory material are likely reasons for this. This post bridges this gap by providing a primer on POMDPs, a typology of case studies drawn from the literature explaining the steps required to define a POMDP when the state of the system is imperfectly detected (state uncertainty) and when the dynamics of the system are unknown (model uncertainty). 


The POMDP framework is general enough to model a variety of real-world sequential decision-making problems. Applications include robot navigation problems, machine maintenance, and planning under uncertainty in general. A partially observable Markov decision process (POMDP) is a combination of an regular Markov Decision Process to model system dynamics with a hidden Markov model that connects unobservable system states probabilistically to observations. The agent can perform actions which affect the system (i.e., may cause the system state to change) with the goal to maximize the expected future rewards that depend on the sequence of system state and the agent’s actions in the future. The goal is to find the optimal policy that guides the agent’s actions. Different to MDPs, for POMDPs, the agent cannot directly observe the complete system state, but the agent makes observations that depend on the state. The agent uses these observations to form a belief about in what state the system currently is. This belief is called a belief state and is expressed as a probability distribution over all possible states. The solution of the POMDP is a policy prescribing which action to take in each belief state. Note that belief states are continuous resulting in an infinite state set which makes POMDPs much harder to solve compared to MDPs.


## Package Functionality
Solving a POMDP problem with the pomdp package consists of two steps:

1. Define a POMDP problem using the function POMDP()
2. solve the problem using solve_POMDP()


### Defining a POMDP Problem
The POMDP() function has the following arguments, each corresponds to one of the elements of a POMDP.

      str(args(POMDP))

+ states defines the set of states S

+ actions defines the set of actions A

+ observations defines the set of observations Ω

+ transition_prob defines the conditional transition probabilities T(s′∣s,a)

+ observation_prob specifies the conditional observation probabilities O(o∣s′,a)

+ reward specifies the reward function R

+ discount is the discount factor γ in range [0,1]

+ horizon is the problem horizon as the number of periods to consider.

+ terminal_values is a vector of state utilities at the end of the horizon.

+ start is the initial probability distribution over the system states S

+ max indicates whether the problem is a maximization or a minimization, and

+ name used to give the POMDP problem a name.



### Solving a POMDP

POMDP problems are solved with the function solve_POMDP(). The list of available parameters can be obtained using the function solve_POMDP_parameter(). Details on the other arguments can be found in the manual page for `solve_POMDP()`.

      str(args(solve_POMDP))  
   
+ The horizon argument specifies the finite time horizon (i.e, the number of time steps) considered in solving the problem. If the horizon is unspecified (i.e., NULL), then the algorithm continues running iterations till it converges to the infinite horizon solution. 

+ The method argument specifies what algorithm the solver should use. Available methods including "grid", "enum", "twopass", "witness", and "incprune". Further solver parameters can be specified as a list in parameters.

### Example

Below is the r code with explanation for simulations run in the healthy mood updating network from [Modelling mood updating: a proof of principle study](https://pubmed.ncbi.nlm.nih.gov/36511113/).

```

library(pomdp)

# a represents the transition probability matrix. The values chosen are arbitrary but designed to reflect the healthy agent's certainty that action will preserve current belief states. So, for example, if the agent amplifies stress signals then there is a 90% chance the event will be stressful. Intuitviely, waiting will necessarily preserve the current hidden states as they are.

a = list("Wait"="identity",
 "amplify-stress-signals"= matrix(c(0.9, 0.1, 0.6, 0.4), nrow=2, byrow=TRUE),
 "attenuate-stress-signals"= matrix(c(0.4, 0.6, 0.25, 0.75), nrow=2, byrow=TRUE),
 "amplify-pleasure-signals"= matrix(c(0.25, 0.75, 0.1, 0.9), nrow=2, byrow=TRUE),
 "attenuate-pleasure-signals"= matrix(c(0.75, 0.25, 0.6, 0.4), nrow=2, byrow=TRUE))

# b represents the observation probability matrix. Again this reflects a very certain prior belief in the likely consequences of action matching observations to corresponding hidden states.

b = rbind(
 O_("amplify-stress-signals", "Stressful", "Stress-Signals", 0.9),
 O_("amplify-stress-signals", "Not-Stressful", "Stress-Signals", 0.3),
 O_("amplify-stress-signals", "Stressful", "Pleasure-Signals", 0.1),
 O_("amplify-stress-signals", "Not-Stressful", "Pleasure-Signals", 0.7),
 O_("attenuate-stress-signals", "Stressful", "Stress-Signals", 0.6),
 O_("attenuate-stress-signals", "Not-Stressful", "Stress-Signals", 0.1),
 O_("attenuate-stress-signals", "Stressful", "Pleasure-Signals", 0.4),
 O_("attenuate-stress-signals", "Not-Stressful", "Pleasure-Signals", 0.9),
 O_("amplify-pleasure-signals", "Stressful", "Stress-Signals", 0.6),
 O_("amplify-pleasure-signals", "Not-Stressful", "Stress-Signals", 0.1),
 O_("amplify-pleasure-signals", "Stressful", "Pleasure-Signals", 0.4),
 O_("amplify-pleasure-signals", "Not-Stressful", "Pleasure-Signals", 0.9),
 O_("attenuate-pleasure-signals", "Stressful", "Stress-Signals", 0.9),
 O_("attenuate-pleasure-signals", "Not-Stressful", "Stress-Signals", 0.4),
 O_("attenuate-pleasure-signals", "Stressful", "Pleasure-Signals", 0.1),
 O_("attenuate-pleasure-signals", "Not-Stressful", "Pleasure-Signals", 0.6),
 O_("Wait", "Stressful", "Stress-Signals", 0.7),
 O_("Wait", "Not-Stressful", "Stress-Signals", 0.3),
 O_("Wait", "Stressful", "Pleasure-Signals", 0.3),
 O_("Wait", "Not-Stressful", "Pleasure-Signals", 0.7))


# c is the reward matrix. Note that the rewards are framed in terms of the surprisal associated with an end state given a particular action. Thus if the agent amplifies stress signals and the event is non-stressful there is a relative penalty.

c = rbind(
 R_("amplify-stress-signals", "Not-Stressful", "*", "*", -1.39),
 R_("amplify-stress-signals", "Stressful", "*", "*", -0.29),
 R_("attenuate-stress-signals", "Not-Stressful", "*", "*", -0.39),
 R_("attenuate-stress-signals", "Stressful", "*", "*", -1.12),
 R_("amplify-pleasure-signals", "Not-Stressful", "*", "*", -0.19),
 R_("amplify-pleasure-signals", "Stressful", "*", "*", -1.74),
 R_("attenuate-pleasure-signals", "Not-Stressful", "*", "*", -1.12),
 R_("attenuate-pleasure-signals", "Stressful", "*", "*", -0.39),
 R_("Wait", "*", "*", "*", -1))


 HealthyMood <- POMDP(
     name = "Healthy Mood",
     discount = 0.5,
     states = c("Stressful" , "Not-Stressful"),
     actions = c("Wait", "amplify-stress-signals", "attenuate-stress-signals", "amplify-pleasure-signals", "attenuate-pleasure-signals"),
     observations = c("Stress-Signals", "Pleasure-Signals"),
     start = c(0.5, 0.5),
     transition_prob = a, observation_prob = b, reward = c)
     
sol <- solve_POMDP(HealthyMood)
sol     
```

Visualization
In this section, we will visualize the policy graph provided in the solution by the solve_POMDP() function.

```
plot_policy_graph(sol)
```

## References
+ https://artint.info/
+ https://www.st.ewi.tudelft.nl/mtjspaan/pub/Spaan12pomdp.pdf
+ https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13692
+ https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume23/roy05a-html/node2.html
+ https://wiki.ubc.ca/Course:CPSC522/Partially_Observable_Markov_Decision_Processes
+ https://cran.r-project.org/web/packages/pomdp/vignettes/POMDP.html
+ [Modelling mood updating: a proof of principle study](https://pubmed.ncbi.nlm.nih.gov/36511113/)
