# Modeling Depression-Related Cognitive Biases Through POMDPs

Mental health disorders like depression involve complex feedback loops between cognition, behavior, and environment. Traditional psychological theories have long explored how individuals maintain, exacerbate, or recover from depressed mood states, but computational modeling offers a new lens through which to formalize and test these theories. The Partially Observable Markov Decision Process (POMDP) framework provides a particularly powerful tool for modeling the dynamic and uncertain nature of psychological processes.

This post explores a novel application of POMDPs to simulate depression-related biases in action selection and perceptual inference, using the R `pomdp` package to develop a model that captures how behavior influences—and is influenced by—an agent's internal emotional state.

## The POMDP Framework for Mental Health

A POMDP is a mathematical model designed for agents making decisions under uncertainty. Unlike fully observable Markov Decision Processes, where the agent has complete knowledge of its current state, a POMDP acknowledges the gap between what an agent knows and the actual environment. The agent must rely on indirect observations to update its beliefs and determine optimal actions.

This framework maps naturally onto psychological processes. Consider how individuals must infer their emotional state based on bodily sensations, social feedback, and cognitive appraisals—they rarely have direct access to their "true" mood state. Similarly, the behaviors they choose don't just respond to their mood; they actively shape what kinds of stimuli they're likely to perceive and how they interpret those stimuli.

## Building the Model: States, Actions, and Observations

Our model represents an agent whose internal emotional state can be either **Positive** or **Negative**. Crucially, the agent cannot directly observe this state. Instead, it perceives environmental cues—**Positive Stimulus** or **Negative Stimulus**—which probabilistically reflect the underlying mood.

The agent has three possible actions representing different behavioral strategies:

- **Attend Positive** (analogous to physical exercise): Actively engaging with positive stimuli
- **Attend Negative** (analogous to screen time or rumination): Focusing on negative stimuli  
- **Wait** (analogous to inaction): Passive observation without directed attention

These behaviors don't merely respond to mood—they actively shape perception. Attending to positive cues increases the likelihood of observing positive stimuli when in a positive state, creating a reinforcing feedback loop. Conversely, attending to negative cues heightens the chances of perceiving negative stimuli, particularly when already in a negative state, potentially perpetuating depressive symptoms.

The observation probabilities are deliberately asymmetrical and state-dependent, reflecting empirical findings from affective neuroscience. For instance, when the agent attends to positive stimuli:
- In a **Positive** state: 90% chance of observing positive stimuli, 10% negative
- In a **Negative** state: Only 40% chance of observing positive stimuli, 60% negative

This asymmetry captures how depression can bias perception, making positive experiences less accessible even when actively sought.

## Reward Structure and Motivation

The model implements a reward structure based on the adaptiveness of actions given the emotional context. Adaptive behaviors—like attending to positive stimuli while in a positive state—yield the highest rewards (+2). Attending to positive stimuli while in a negative state provides modest benefits (-1), modeling the effortful but valuable nature of behavioral activation therapy.

Maladaptive actions incur higher costs. Attending to negative stimuli while in a positive state carries a severe penalty (-2), while doing so in a negative state still results in a smaller penalty (-1). The **Wait** action consistently produces a small penalty (-0.5), reflecting the opportunity cost of inaction.

## Implementation and Dynamics

Here's the complete R implementation:

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

# Normalize and solve the model
model <- normalize_POMDP(model)
solution <- solve_POMDP(model)

# Run simulation starting with uncertain beliefs
simulate_POMDP(
  model = model,
  policy = policy(solution),
  belief = c(Positive = 0.5, Negative = 0.5),
  n = 10
)
```

The simulation begins with the agent epistemically neutral, assigning equal probability to positive and negative states. Over time, it performs Bayesian updates on its belief distribution after each action-observation pair, gradually forming and revising beliefs about its emotional state.

The model reveals emergent behavior patterns. Initially uncertain agents oscillate between exploration and exploitation. As observations accumulate, beliefs become more precise, and agents increasingly select actions aligned with their inferred state. Repeated experiences of positive stimuli following positive attention may create virtuous cycles, while initial selections of negative attention in negative states can lead to spiraling negativity.

## Clinical Relevance and Psychological Interpretation

This model aligns closely with behavioral activation approaches to depression treatment, which propose that increasing engagement with rewarding activities can disrupt maladaptive patterns and shift emotional trajectories. By simulating how actions affect perception and belief updating, the model provides a computational framework for this therapeutic approach.

The model underscores the interactive nature of mood and behavior. Unlike static models that treat emotion as merely a consequence of cognition, this POMDP approach illustrates how action and perception co-evolve. It demonstrates why certain behaviors—though immediately soothing—may ultimately reinforce depression, while others require effort but yield long-term benefits.

The asymmetry in observation probabilities reveals how depressive individuals may differentially attend to negative stimuli, especially when already in negative states. This perceptual bias isn't merely passive but actively constructed through behavior, suggesting that interventions targeting attentional control and behavioral habits may recalibrate both mood and cognitive appraisal processes.

## Limitations and Future Directions

Several limitations warrant consideration. The model assumes stationarity of internal states—mood doesn't change independently of action. In reality, emotional states are dynamic and shift due to biological rhythms, life events, or pharmacological interventions. Future models could include stochastic state transitions to enhance ecological validity.

The observation and reward matrices are manually specified rather than empirically derived. While inspired by psychological theory and empirical trends, fully data-driven models would require parameter estimation from longitudinal behavioral and affective datasets. Techniques like inverse reinforcement learning or hierarchical Bayesian inference could fit models to individual patients, opening paths toward personalized computational psychiatry.

The current model operates in discrete, low-dimensional space, which simplifies analysis but may overlook nuanced gradations of mood and behavior. Continuous-state POMDPs or hybrid models could offer richer representations, though at increased computational cost.

## Expanding the Framework

Several extensions could enhance the model's utility. Incorporating state transitions would allow simulation of recovery and relapse cycles, offering insights into depression's temporal dynamics. Extending the observation space to include multi-modal sensory and cognitive inputs could improve fidelity.

Adapting the model for intervention testing—by simulating outcomes under different policy constraints—could assist clinicians in evaluating various therapeutic strategies. Learning model parameters from real-world behavioral traces, such as smartphone usage or wearable device data, could enable adaptive digital interventions where agents' beliefs and policies update in real-time based on user behavior.

Finally, embedding this model within agent-based frameworks could simulate social feedback loops, exploring how peer interactions or family dynamics influence mood regulation and perception. These extensions would bridge individual-level models with broader social and environmental factors, aligning with ecological theories of mental health.

## Conclusion

This exploration demonstrates how POMDPs can serve as computational frameworks for modeling affective dynamics and behavioral biases in depression. By simulating how agents infer internal states based on action-dependent observations and rewards, the model captures essential features of depressive cognition and behavior while aligning with established psychological theories.

Though simplified, this model illustrates the potential of combining decision-theoretic modeling with psychological insight. Future work aimed at increasing complexity, empirical grounding, and clinical integration promises to transform our understanding of mental health disorders and pave the way toward individualized, dynamically adaptive mental health care.

Computational models like this not only deepen theoretical understanding but may also revolutionize how we intervene in mental health, moving beyond one-size-fits-all approaches toward personalized, evidence-based treatments that adapt to individual behavioral patterns and cognitive biases.

### References

Jacobson, N. S., Martell, C. R., & Dimidjian, S. (2001). [Behavioral activation treatment for depression: Returning to contextual roots](https://doi.org/10.1037/0003-066X.56.3.255). *American Psychologist, 56*(3), 255–265.

Twenge, J. M., & Campbell, W. K. (2018). [Associations between screen time and lower psychological well-being among children and adolescents: Evidence from a population-based study](https://doi.org/10.1016/j.puhe.2018.06.005). *Preventive Medicine Reports, 12*, 271–283.

Kaelbling, L. P., Littman, M. L., & Cassandra, A. R. (1998). [Planning and acting in partially observable stochastic domains](https://doi.org/10.1016/S0004-3702%2898%2900023-X). *Artificial Intelligence, 101*(1–2), 99–134.
