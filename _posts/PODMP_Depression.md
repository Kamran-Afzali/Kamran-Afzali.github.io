


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

# ✅ Normalize before solving
model <- normalize_POMDP(model)

solution <- solve_POMDP(model)

simulate_POMDP(
  model = model,
  policy = policy(solution),
  belief = c(Positive = 0.5, Negative = 0.5),
  n = 10
)
```




In this model, we conceptualize an agent—analogous to an individual—operating in an environment where their internal mood state fluctuates between two conditions: *Positive* and *Negative*. These internal states are not directly observable to the agent; instead, the agent must infer them based on cues from its environment. This is the essence of a Partially Observable Markov Decision Process (POMDP): the agent must make decisions under uncertainty about its own internal state.

The agent has three possible actions: "Screen Time", "Physical Exercise", and "Wait". These actions represent different behavioral strategies that influence and are influenced by the agent’s emotional state. "Screen Time" is meant to capture behaviors such as passive media consumption, which research often associates with rumination and worsening mood in depression. In contrast, "Physical Exercise" represents an active behavioral intervention known to improve mood and promote emotional resilience. "Wait" continues to represent a neutral or avoidant strategy, such as doing nothing to change one’s state.

The internal states—Positive and Negative—do not transition between one another in this simplified model. That is, they are modeled as stable within the time frame of the simulation. This decision helps isolate the effects of behavior on perception and mood inference.

Perceptions, or observations, come in two forms: “Positive Stimulus” and “Negative Stimulus.” These could correspond to internal sensations (e.g., energy levels, bodily feedback) or external feedback (e.g., social interaction, cognitive appraisal) that the agent uses to infer its emotional state. The likelihood of observing these stimuli depends on both the action taken and the underlying state. For instance, engaging in Physical Exercise while in a Positive state increases the chance of perceiving a Positive Stimulus, while Screen Time in a Negative state increases the chance of a Negative Stimulus. This models how behavioral choices can either reinforce or challenge one's mood state.

Rewards are assigned based on the adaptiveness of the action given the emotional context. Physical Exercise tends to yield higher rewards, especially in Negative states, modeling its known therapeutic effects. Screen Time may offer minor relief in the Positive state but becomes maladaptive in the Negative state, incurring higher costs. The Wait action always results in a modest penalty, reflecting opportunity cost or stagnation.

The simulation begins with the agent unsure of its current state, assigning equal belief to Positive and Negative. Over time, as the agent makes choices and receives feedback, it updates its belief using Bayes' rule and selects actions based on an optimal policy derived through planning.

Through this model, we can explore how behavioral choices—rather than internal cognitive tuning—affect the perception of mood-relevant information and the trajectory of mental health. It enables us to simulate how, for example, regular physical activity can gradually shift beliefs and perceived experiences toward a more positive pattern, offering a computational window into behavioral activation therapy and related interventions for depression.
