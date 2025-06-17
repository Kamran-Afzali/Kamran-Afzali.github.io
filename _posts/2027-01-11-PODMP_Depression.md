## Modeling Depression-Related Cognitive Biases Through POMDPs 

### Introduction

The complexities of human emotion and cognition requires complex modeling applied to mental disorders such as depression. Traditional psychological theories have long grappled with the question of how individuals maintain, exacerbate, or recover from depressed mood states, often emphasizing the roles of cognition, behavior, and environment. Increasingly, computational modeling is emerging as a powerful lens through which to formalize and test these theories. In particular, the **Partially Observable Markov Decision Process** (POMDP) framework offers a novel probabilistic tool to model the dynamic and uncertain nature of psychological processes.

This post explores a novel application of the POMDP framework to simulate depression-related biases in action selection and perceptual inference. Using the R `pomdp` package, we develop a simple model that captures how behavior influences—and is influenced by—an agent’s internal affective state. Specifically, we examine how actions such as physical exercise or screen time modulate the agent’s perception of environmental stimuli and belief about its own mood. The model encapsulates both cognitive and behavioral components of depression and provides insights into how certain interventions might shift an individual toward a more adaptive emotional trajectory.



### Formalizing Mood-Dependent Behavior in a POMDP Framework

As mentioned in a previous post POMDP is a mathematical model suited for agents making decisions under uncertainty. Unlike fully observable Markov Decision Processes, where the agent has complete knowledge of its current state, a POMDP acknowledges the epistemic gap between the agent's knowledge and the actual environment. The agent must rely on indirect observations to update its beliefs and determine optimal actions.

In our implementation, the agent's internal emotional state can be either **Positive** or **Negative**. Crucially, the agent does not directly observe this state; instead, it perceives environmental cues—**Positive Stimulus** or **Negative Stimulus**—which probabilistically reflect the underlying mood. This structure mimics real-world emotional ambiguity, where individuals must infer their mental state based on bodily sensations, social feedback, and cognitive appraisals. The agent has three possible actions: **Attend Positive**, **Attend Negative**, and **Wait**, conceptual placeholders for behavioral strategies. In psychological terms, these might correspond to **Physical Exercise**, **Screen Time**, and **Inaction**, respectively. These behaviors are not mere responses to mood but actively shape the kinds of stimuli the agent is likely to perceive. For example, attending to positive cues (akin to engaging in exercise) increases the likelihood of observing positive stimuli if the agent is indeed in a Positive state, reinforcing a healthy feedback loop. Conversely, attending to negative cues (analogous to screen time or rumination) heightens the chances of perceiving negative stimuli, particularly if the agent is already in a Negative state, thereby perpetuating depressive symptoms.

The observation probabilities are asymmetrical and state-dependent, reflecting empirical findings in affective neuroscience. The agent's action modifies the salience of stimuli based on the internal state: **Physical Exercise** enhances positive perceptions in a Positive state but provides attenuated benefits in a Negative state. In contrast, **Screen Time** disproportionately increases negative perceptions when the agent is in a Negative state, consistent with evidence linking passive media consumption to emotional worsening in depression (Twenge & Campbell, 2018). To simulate motivational and cognitive dynamics, a reward structure is implemented. The agent earns rewards based on the congruence between its action and internal state. Adaptive actions, such as engaging with positive stimuli while in a Negative state, yield modest benefits, modeling the effortful but valuable nature of behavioral activation. Maladaptive actions, such as attending to negative cues in a Negative state, incur higher costs, reinforcing the real-world consequences of depressive behavior cycles. The **Wait** action represents emotional inertia or avoidance, associated with minor but cumulative penalties reflecting missed opportunities for improvement.



### Dynamics of Belief Updating and Decision-Making

At initialization, the agent is epistemically neutral, assigning equal probability to being in a Positive or Negative state. Over the course of the simulation, it performs Bayesian updates on its belief distribution after each action-observation pair. This captures the process by which individuals gradually form and revise their beliefs about their emotional state based on feedback from their environment. The simulation proceeds by applying the policy computed from the optimal solution to the POMDP. This policy maps belief states to actions, indicating the most rational behavioral choice given the current uncertainty. The value iteration algorithm accounts for the **discount factor**—set at 0.95—emphasizing long-term gains over immediate rewards. This parameter reflects the forward-looking nature of behavioral planning and allows the model to simulate sustained interventions like therapy or habit formation. The simulation also reveals emergent behavior patterns. For instance, initially uncertain, the agent oscillates between exploration and exploitation. As observations accumulate, belief become more precise/less variant, and the agent increasingly selects actions aligned with the inferred state. Repeated experiences of positive stimuli following Physical Exercise may reinforce the belief in a Positive state, creating a virtuous cycle. Conversely, initial selections of Screen Time in a Negative state can lead to spiraling negativity and persistent misbelief in a Negative state, mirroring clinical depression's persistence and resistance to change.



### Psychological Interpretation and Clinical Relevance

This model aligns closely with the **behavioral activation** approach to depression treatment, which posits that increasing engagement with rewarding activities can disrupt maladaptive patterns and shift emotional trajectories (Jacobson et al., 1996). By simulating how actions affect perception and belief updating, the model provides a computational framework for this theory. Furthermore, it offers insights into why certain behaviors—though immediately soothing—may ultimately reinforce depression, while others require effort but yield long-term benefit. Moreover, the model underscores the **interactive nature of mood and behavior**. Unlike static models that treat emotion as a consequence of cognition alone, the POMDP approach illustrates how action and perception co-evolve. The model also has implications for understanding **cognitive biases** in depression. The asymmetry in observation probabilities demonstrates how depressive individuals may differentially attend to negative stimuli, especially when in a Negative state. This endogenous perceptual bias is not merely passive but actively constructed through behavior. Thus, interventions targeting attentional control and behavioral habits may serve to recalibrate not just mood but also cognitive appraisal processes.


### Challenges and Limitations

Here we discuss some of the limitations of the presented model, first it assumes **stationarity of internal states**, meaning that mood does not change independently of action. In reality, emotional states are dynamic and can shift due to unmodeled exogenous factors such as biological rhythms, life events, or pharmacological interventions. Extending the model to include stochastic transitions between states would enhance ecological validity. Second, the observation and reward matrices are **manually specified** rather than empirically derived. Although they are inspired by psychological theory and empirical trends, a fully data-driven model would require parameter estimation from longitudinal behavioral and affective datasets. Techniques such as inverse reinforcement learning or hierarchical Bayesian inference could be integrated to fit models to individual patients, opening paths toward **personalized computational psychiatry**. Third, the current model operates in a **discrete and low-dimensional space**, which simplifies analysis but may overlook the nuanced gradations of mood and behavior. Continuous-state POMDPs or hybrid models could offer richer representations, though at the cost of increased computational complexity.



### Future Directions

The presented model can be expanded by incorporating **state transitions** would allow the simulation of recovery and relapse cycles, offering insights into the temporal dynamics of depression. Likewise, extending the observation space to include **multi-modal sensory and cognitive inputs** could also improve fidelity. Moreover, adapting the model for **intervention testing**—by simulating outcomes under different policy constraints—could assist clinicians in evaluating the likely impact of various therapeutic strategies. Another direction involves **learning the model parameters** from real-world behavioral traces, such as data from smartphone usage or wearable devices. Such approaches could enable the development of **adaptive digital interventions**, where the agent's beliefs and policy are updated in real time based on user behavior. Finally, embedding this model within **agent based frameworks** could simulate social feedback loops, such as how peer interactions or family dynamics influence mood regulation and perception. These extensions would bridge individual-level models with broader social and environmental factors, aligning with ecological theories of mental health.



### Conclusion

This blog post has explored the use of POMDPs as a computational framework for modeling affective dynamics and behavioral biases in depression. By simulating how an agent infers its internal state based on action-dependent observations and rewards, the model captures essential features of depressive cognition and behavior. It aligns with established psychological theories such as behavioral activation and cognitive bias frameworks, while offering a formal structure for simulation and hypothesis testing. While the model remains a simplification, it demonstrates the potential of combining decision-theoretic modeling with psychological insight. Future work aimed at increasing complexity, empirical grounding, and clinical integration promises to transform how we understand and intervene in mental health disorders. Computational models like this one not only deepen theoretical understanding but may also pave the way toward individualized, dynamically adaptive mental health care.



### References

Jacobson, N. S., Martell, C. R., & Dimidjian, S. (2001). [Behavioral activation treatment for depression: Returning to contextual roots](https://doi.org/10.1037/0003-066X.56.3.255). *American Psychologist, 56*(3), 255–265.

Twenge, J. M., & Campbell, W. K. (2018). [Associations between screen time and lower psychological well-being among children and adolescents: Evidence from a population-based study](https://doi.org/10.1016/j.puhe.2018.06.005). *Preventive Medicine Reports, 12*, 271–283.

Kaelbling, L. P., Littman, M. L., & Cassandra, A. R. (1998). [Planning and acting in partially observable stochastic domains](https://doi.org/10.1016/S0004-3702%2898%2900023-X). *Artificial Intelligence, 101*(1–2), 99–134.



```r
library(pomdp)

model <- POMDP(
  name = "DepressionBias",
  states = c("Positive", "Negative"),
  actions = c("Attend Positive", "Attend Negative", "Wait"),
  observations = c("Pos Stimulus", "Neg Stimulus"),
  transition_prob = list(
    "Attend Positive" = "identity",
    "Attend Negative" = "identity",
    "Wait" = "identity"
  ),
  observation_prob = rbind(
    O_("Attend Positive", "Positive", "Pos Stimulus", 0.9),
    O_("Attend Positive", "Positive", "Neg Stimulus", 0.1),
    O_("Attend Positive", "Negative", "Pos Stimulus", 0.4),
    O_("Attend Positive", "Negative", "Neg Stimulus", 0.6),

    O_("Attend Negative", "Positive", "Pos Stimulus", 0.3),
    O_("Attend Negative", "Positive", "Neg Stimulus", 0.7),
    O_("Attend Negative", "Negative", "Pos Stimulus", 0.2),
    O_("Attend Negative", "Negative", "Neg Stimulus", 0.8),

    O_("Wait", "Positive", "Pos Stimulus", 0.5),
    O_("Wait", "Positive", "Neg Stimulus", 0.5),
    O_("Wait", "Negative", "Pos Stimulus", 0.5),
    O_("Wait", "Negative", "Neg Stimulus", 0.5)
  ),
  reward = rbind(
    R_("Attend Positive", "Positive", "*", "*", 2),
    R_("Attend Positive", "Negative", "*", "*", -1),
    R_("Attend Negative", "Positive", "*", "*", -2),
    R_("Attend Negative", "Negative", "*", "*", -1),
    R_("Wait", "*", "*", "*", -0.5)
  ),
  discount = 0.95,
  horizon = Inf
)

# Normalize before solving
model <- normalize_POMDP(model)

solution <- solve_POMDP(model)

simulate_POMDP(
  model = model,
  policy = policy(solution),
  belief = c(Positive = 0.5, Negative = 0.5),
  n = 10
)
```


In this model, we conceptualize an agent—analogous to an individual—operating in an environment where their internal mood state fluctuates between two conditions: *Positive* and *Negative*. These internal states are not directly observable to the agent; instead, the agent must infer them based on cues from its environment. This is the essence of a POMDP: the agent must make decisions under uncertainty about its own internal state. The agent has three possible actions: "Screen Time", "Physical Exercise", and "Wait". These actions represent different behavioral strategies that influence and are influenced by the agent’s emotional state. "Screen Time" is meant to capture behaviors such as passive media consumption, which research often associates with rumination and worsening mood in depression. In contrast, "Physical Exercise" represents an active behavioral intervention known to improve mood and promote emotional resilience. "Wait" continues to represent a neutral or avoidant strategy, such as doing nothing to change one’s state.

The internal states—Positive and Negative—do not transition between one another in this simplified model. That is, they are modeled as stable within the time frame of the simulation. This decision helps isolate the effects of behavior on perception and mood inference. Observations, come in two forms: “Positive Stimulus” and “Negative Stimulus.” This models how behavioral choices can either reinforce or challenge one's mood state. Rewards are assigned based on the adaptiveness of the action given the emotional context. Physical Exercise tends to yield higher rewards, especially in Negative states, modeling its known therapeutic effects. Screen Time may offer minor relief in the Positive state but becomes maladaptive in the Negative state, incurring higher costs. The Wait action always results in a modest penalty, reflecting opportunity cost or stagnation. The simulation begins with the agent unsure of its current state, assigning equal belief to Positive and Negative. Over time, as the agent makes choices and receives feedback, it updates its belief using Bayes' rule and selects actions based on an optimal policy derived through planning. Through this model, we can explore how behavioral choices—rather than internal cognitive tuning—affect the perception of mood-relevant information and the trajectory of mental health. It enables us to simulate how, for example, regular physical activity can gradually shift beliefs and perceived experiences toward a more positive pattern, offering a computational window into behavioral activation therapy and related interventions for depression.




### **Chunk 1: Loading the `pomdp` Library**
```r
library(pomdp)
```

---

### **Chunk 2: Defining the POMDP Model**
```r
model <- POMDP(
  name = "DepressionBias",
  states = c("Positive", "Negative"),
  actions = c("Attend Positive", "Attend Negative", "Wait"),
  observations = c("Pos Stimulus", "Neg Stimulus"),
  transition_prob = list(
    "Attend Positive" = "identity",
    "Attend Negative" = "identity",
    "Wait" = "identity"
  ),
  observation_prob = rbind(
    O_("Attend Positive", "Positive", "Pos Stimulus", 0.9),
    O_("Attend Positive", "Positive", "Neg Stimulus", 0.1),
    O_("Attend Positive", "Negative", "Pos Stimulus", 0.4),
    O_("Attend Positive", "Negative", "Neg Stimulus", 0.6),

    O_("Attend Negative", "Positive", "Pos Stimulus", 0.3),
    O_("Attend Negative", "Positive", "Neg Stimulus", 0.7),
    O_("Attend Negative", "Negative", "Pos Stimulus", 0.2),
    O_("Attend Negative", "Negative", "Neg Stimulus", 0.8),

    O_("Wait", "Positive", "Pos Stimulus", 0.5),
    O_("Wait", "Positive", "Neg Stimulus", 0.5),
    O_("Wait", "Negative", "Pos Stimulus", 0.5),
    O_("Wait", "Negative", "Neg Stimulus", 0.5)
  ),
  reward = rbind(
    R_("Attend Positive", "Positive", "*", "*", 2),
    R_("Attend Positive", "Negative", "*", "*", -1),
    R_("Attend Negative", "Positive", "*", "*", -2),
    R_("Attend Negative", "Negative", "*", "*", -1),
    R_("Wait", "*", "*", "*", -0.5)
  ),
  discount = 0.95,
  horizon = Inf
)
```
This chunk defines the POMDP model. Let’s break it down by its components:

- **`name = "DepressionBias"`**:
  - **Explanation**: Assigns a name to the model, "DepressionBias," suggesting it models a decision-making process related to attention bias, possibly in a psychological context like depression.
  - **Purpose**: Provides a descriptive identifier for the model.

- **`states = c("Positive", "Negative")`**:
  - **Explanation**: Defines the possible hidden states of the system: "Positive" (e.g., a positive mental state) and "Negative" (e.g., a negative or depressive mental state).
  - **Purpose**: These are the underlying states the agent is trying to influence or infer, but they are not directly observable.

- **`actions = c("Attend Positive", "Attend Negative", "Wait")`**:
  - **Explanation**: Specifies the actions the agent can take:
    - "Attend Positive": Focus attention on positive stimuli.
    - "Attend Negative": Focus attention on negative stimuli.
    - "Wait": Take no action, observe the environment.
  - **Purpose**: These actions represent the choices available to the agent, which may influence the state or observations.

- **`observations = c("Pos Stimulus", "Neg Stimulus")`**:
  - **Explanation**: Defines the possible observations the agent can receive: a positive stimulus or a negative stimulus.
  - **Purpose**: Since the true state is hidden, the agent relies on these observations to infer the state.

- **`transition_prob = list(...)`**:
  - **Explanation**: Specifies the state transition probabilities for each action. Here, all actions ("Attend Positive," "Attend Negative," "Wait") use the `"identity"` transition matrix, meaning the state does not change (the probability of staying in the current state is 1, and transitioning to another state is 0).
    - For example, if the current state is "Positive" and the action is "Attend Positive," the next state is still "Positive" with probability 1.
  - **Purpose**: Models a static environment where actions do not alter the underlying state, which is unusual for POMDPs but may reflect a specific assumption in this model (e.g., mental state is stable over time).

- **`observation_prob = rbind(...)`**:
  - **Explanation**: Defines the observation probabilities, which specify the likelihood of observing a particular stimulus given the action and the true state. The `O_` function is used to create observation probability entries in the format `O_(action, state, observation, probability)`. The `rbind` function combines these into a matrix. Let’s break down the probabilities:
    - **For action "Attend Positive"**:
      - If the state is "Positive," the agent observes "Pos Stimulus" with probability 0.9 and "Neg Stimulus" with 0.1.
      - If the state is "Negative," the agent observes "Pos Stimulus" with probability 0.4 and "Neg Stimulus" with 0.6.
      - This suggests that attending to positive stimuli makes positive observations more likely in a positive state but less reliable in a negative state.
    - **For action "Attend Negative"**:
      - If the state is "Positive," the agent observes "Pos Stimulus" with 0.3 and "Neg Stimulus" with 0.7.
      - If the state is "Negative," the agent observes "Pos Stimulus" with 0.2 and "Neg Stimulus" with 0.8.
      - This indicates a bias toward negative observations when attending to negative stimuli, especially in a negative state.
    - **For action "Wait"**:
      - Regardless of the state ("Positive" or "Negative"), the agent observes "Pos Stimulus" or "Neg Stimulus" with equal probability (0.5).
      - This models a neutral action where observations are uninformative about the state.
  - **Purpose**: These probabilities define how observations relate to the hidden state and the chosen action, capturing the uncertainty in the POMDP.

- **`reward = rbind(...)`**:
  - **Explanation**: Specifies the reward structure using the `R_` function, which defines rewards in the format `R_(action, start_state, end_state, observation, reward)`. The asterisks (`*`) indicate that the reward applies to any end state or observation. Let’s break it down:
    - **R_("Attend Positive", "Positive", "*", "*", 2)**: If the agent attends to positive stimuli while in a "Positive" state, they receive a reward of +2, regardless of the observation or next state.
    - **R_("Attend Positive", "Negative", "*", "*", -1)**: If the agent attends to positive stimuli while in a "Negative" state, they receive a reward of -1.
    - **R_("Attend Negative", "Positive", "*", "*", -2)**: If the agent attends to negative stimuli while in a "Positive" state, they receive a reward of -2.
    - **R_("Attend Negative", "Negative", "*", "*", -1)**: If the agent attends to negative stimuli while in a "Negative" state, they receive a reward of -1.
    - **R_("Wait", "*", "*", "*", -0.5)**: Taking the "Wait" action results in a small negative reward of -0.5, regardless of the state or observation.
  - **Purpose**: The reward structure incentivizes attending to positive stimuli in a positive state (+2) and penalizes mismatches (e.g., attending to negative stimuli in a positive state, -2). The "Wait" action has a small penalty, possibly to discourage inaction.

- **`discount = 0.95`**:
  - **Explanation**: Sets the discount factor to 0.95, meaning future rewards are discounted by 5% per time step. This reflects the time value of rewards, where immediate rewards are valued more than future ones.
  - **Purpose**: Encourages the agent to prioritize short-term rewards while still considering long-term outcomes.

- **`horizon = Inf`**:
  - **Explanation**: Specifies an infinite horizon, meaning the decision process continues indefinitely rather than terminating after a fixed number of steps.
  - **Purpose**: Models a scenario where the agent makes decisions over an unbounded time period, aiming to maximize the discounted sum of rewards.

---

### **Chunk 3: Normalizing the POMDP Model**
```r
model <- normalize_POMDP(model)
```
- **Explanation**: The `normalize_POMDP` function ensures that the model’s probabilities (transition and observation probabilities) are valid by checking that they sum to 1 where required and correcting any numerical inconsistencies. It also validates the model’s structure.
- **Purpose**: Prepares the model for solving by ensuring mathematical correctness and consistency, which is crucial for numerical algorithms used in `solve_POMDP`.

---

### **Chunk 4: Solving the POMDP**
```r
solution <- solve_POMDP(model)
```
- **Explanation**: The `solve_POMDP` function computes an optimal policy for the POMDP model using numerical methods (e.g., value iteration or policy iteration). The policy maps belief states (probability distributions over the states "Positive" and "Negative") to actions ("Attend Positive," "Attend Negative," or "Wait") that maximize the expected discounted sum of rewards.
- **Purpose**: Produces a `solution` object containing the optimal policy, value function, and other details. The policy guides the agent on which action to take based on its belief about the current state.

---

### **Chunk 5: Simulating the POMDP**
```r
simulate_POMDP(
  model = model,
  policy = policy(solution),
  belief = c(Positive = 0.5, Negative = 0.5),
  n = 10
)
```
- **Explanation**: This simulates the POMDP model using the computed policy for 10 time steps (`n = 10`). Let’s break down the arguments:
  - **`model = model`**: Specifies the POMDP model defined earlier.
  - **`policy = policy(solution)`**: Uses the optimal policy from the `solution` object, which dictates the action to take based on the current belief.
  - **`belief = c(Positive = 0.5, Negative = 0.5)`**: Initializes the agent’s belief as a 50-50 probability distribution over the "Positive" and "Negative" states, reflecting complete uncertainty about the initial state.
  - **`n = 10`**: Runs the simulation for 10 time steps.
- **What Happens in Simulation**:
  - At each time step, the agent:
    1. Uses the current belief to select an action based on the policy.
    2. Receives an observation based on the observation probabilities.
    3. Updates its belief using Bayesian updating, combining the prior belief, action, and observation.
    4. Receives a reward based on the reward structure.
    5. Since transitions are "identity," the true state remains unchanged, but the belief evolves based on observations.
  - The simulation outputs a sequence of states, actions, observations, rewards, and belief updates.
- **Purpose**: Tests the policy in a simulated environment, allowing analysis of how the agent behaves and what rewards it accumulates over 10 steps.

