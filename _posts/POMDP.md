
## Partially Observable Markov Decision Process (POMDP) in R

The Markov decision process (MDP) is a mathematical framework for modeling decisions based on a system with a series of states and providing actions to the decision maker based on those states. A partially observable Markov decision process (POMDP) is a generalization of a Markov decision process (MDP). A POMDP models an agent decision process in which it is assumed that the system dynamics are determined by an MDP, but the agent cannot directly observe the underlying state. Instead, there should be a sensor model (the probability distribution of different observations given the underlying state) and the underlying MDP. The policy function in POMDP maps from the history of observations (or belief states) to the actions, in contrast to the policy function in MDP which maps the underlying states to the actions. The POMDP framework is broad enough to describe a range of sequential decision-making processes that occur in the actual world. For each potential belief over the possible world states, an accurate solution to a POMDP produces the best course of action. Over a potentially infinite horizon, the best course of action maximizes predicted gain (or reduces cost) for the actor. The best course of action for an agent to take when interacting with its environment is referred to as the agent's optimal policy.

The POMPD model how a system can deal with the challenges of limited observation. Because the underlying states of the partially observable Markov decision process are hidden to the agent, the idea of a "belief state" is useful. The belief state offers a solution to the model's inherent ambiguity. The MPD or POMPD model can be reviewed by a system using what is already known to provide a clearer picture of likely outcomes. This is where the POMPD is helpful in reinforcement learning. Imperfections in the agent's sensors are one source of ambiguity regarding the real state of the system. The agent cannot know the system's actual states with a flawed sensor. Here we consider an extension of the (fully observable) MDP setting that also deals with uncertainty resulting from the agent’s imperfect sensors. In general the partial observability stems from two sources: (i) multiple states give the same sensor reading, in case the agent can only sense a limited part of the environment, and (ii) its sensor readings are noisy: observing the same state can result in different sensor readings. The partial observability can lead to “perceptual aliasing”: different parts of the environment appear similar to the agent’s sensor system, but require different actions. The POMDP captures the partial observability in a probabilistic observation model, which relates possible observations to states.

In summary POMDP combines a hidden Markov model that probabilistically links unobservable system states to observations with a normal Markov Decision Process to explain system dynamics. To maximise the projected future rewards that depend on the sequence of system state and the agent's activities in the future, the agent can take actions that have an impact on the system (i.e., may cause the system state to change). The objective is to identify the best policy to use to direct the agent's behaviour. In contrast to MDPs, the agent in POMDPs makes observations that depend on the state rather than being able to directly view the entire system state. The agent creates a belief about the state of the system based on these observations. A probability distribution across all potential states is used to express this belief, which is referred to as a belief state. A policy outlining the appropriate course of action for each belief state serves as the POMDP's solution. Remember that POMDPs are far more challenging to solve than MDPs due to the fact that belief states are continuous, resulting in an endless state set. The POMDP framework is general enough to model a variety of real-world sequential decision-making problems. Applications include robot navigation problems, machine maintenance, and planning under uncertainty in general. POMDPs continue to have many uses, but their understanding is still lacking. This is probably due to the difficulty of the mathematics, the difficulty of using POMDP solvers created by the AI community, and the dearth of necessary resources. This post aims to offer an introduction to POMDPs and instructions on how to define a POMDP in R.  


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


#### Transition probability matrix

*a* represents the transition probability matrix. The values chosen are arbitrary but designed to reflect the healthy agent's certainty that action will preserve current belief states. So, for example, if the agent amplifies stress signals then there is a 90% chance the event will be stressful. Intuitviely, waiting will necessarily preserve the current hidden states as they are.

```
library(pomdp)


a = list("Wait"="identity",
 "amplify-stress-signals"= matrix(c(0.9, 0.1, 0.6, 0.4), nrow=2, byrow=TRUE),
 "attenuate-stress-signals"= matrix(c(0.4, 0.6, 0.25, 0.75), nrow=2, byrow=TRUE),
 "amplify-pleasure-signals"= matrix(c(0.25, 0.75, 0.1, 0.9), nrow=2, byrow=TRUE),
 "attenuate-pleasure-signals"= matrix(c(0.75, 0.25, 0.6, 0.4), nrow=2, byrow=TRUE))
```
#### Observation probability matrix

*b* represents the observation probability matrix. Again this reflects a very certain prior belief in the likely consequences of action matching observations to corresponding hidden states.

```


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

```
#### Reward matrix
*c* is the reward matrix. Note that the rewards are framed in terms of the surprisal associated with an end state given a particular action. Thus if the agent amplifies stress signals and the event is non-stressful there is a relative penalty.

```

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
```

#### Model

Matrices above are used to compile the model.

```
 HealthyMood <- POMDP(
     name = "Healthy Mood",
     discount = 0.5,
     states = c("Stressful" , "Not-Stressful"),
     actions = c("Wait", "amplify-stress-signals", "attenuate-stress-signals", "amplify-pleasure-signals", "attenuate-pleasure-signals"),
     observations = c("Stress-Signals", "Pleasure-Signals"),
     start = c(0.5, 0.5),
     transition_prob = a, observation_prob = b, reward = c)
```

#### Solution 

Then we use the *solve_POMDP* function to find the optimal solution.

```     
sol <- solve_POMDP(HealthyMood)
sol     
```

#### Visualization

Here we will visualize the policy graph provided in the solution by the *solve_POMDP()* function.

```
plot_policy_graph(sol)
```

## References

+ [Partially Observable Markov Decision Processes](https://wiki.ubc.ca/Course:CPSC522/Partially_Observable_Markov_Decision_Processes)
+ [POMDP on cran](https://cran.r-project.org/web/packages/pomdp/vignettes/POMDP.html)
+ [Modelling mood updating: a proof of principle study](https://pubmed.ncbi.nlm.nih.gov/36511113/)
[ ](https://artint.info/)
[ ](https://www.st.ewi.tudelft.nl/mtjspaan/pub/Spaan12pomdp.pdf)
[ ](https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.13692)
[ ](https://www.cs.cmu.edu/afs/cs/project/jair/pub/volume23/roy05a-html/node2.html)
