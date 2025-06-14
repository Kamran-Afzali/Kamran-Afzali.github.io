## Modeling Depression-Related Cognitive Biases Through POMDPs 

### Introduction

The complexities of human emotion and cognition requires complex modeling applied to mental disorders such as depression. Traditional psychological theories have long grappled with the question of how individuals maintain, exacerbate, or recover from depressed mood states, often emphasizing the roles of cognition, behavior, and environment. Increasingly, computational modeling is emerging as a powerful lens through which to formalize and test these theories. In particular, the **Partially Observable Markov Decision Process** (POMDP) framework offers a novel probabilistic tool to model the dynamic and uncertain nature of psychological processes.

This post explores a novel application of the POMDP framework to simulate depression-related biases in action selection and perceptual inference. Using the R `pomdp` package, we develop a simple model that captures how behavior influences—and is influenced by—an agent’s internal affective state. Specifically, we examine how actions such as physical exercise or screen time modulate the agent’s perception of environmental stimuli and belief about its own mood. The model encapsulates both cognitive and behavioral components of depression and provides insights into how certain interventions might shift an individual toward a more adaptive emotional trajectory.



### Formalizing Mood-Dependent Behavior in a POMDP Framework

At the heart of our approach lies the POMDP—a mathematical model suited for agents making decisions under uncertainty. Unlike fully observable Markov Decision Processes, where the agent has complete knowledge of its current state, a POMDP acknowledges the epistemic gap between the agent's knowledge and the actual environment. The agent must rely on indirect observations to update its beliefs and determine optimal actions.

In our implementation, the agent's internal emotional state can be either **Positive** or **Negative**. Crucially, the agent does not directly observe this state; instead, it perceives environmental cues—**Positive Stimulus** or **Negative Stimulus**—which probabilistically reflect the underlying mood. This structure mimics real-world emotional ambiguity, where individuals must infer their mental state based on bodily sensations, social feedback, and cognitive appraisals.

The agent has three possible actions: **Attend Positive**, **Attend Negative**, and **Wait**, conceptual placeholders for behavioral strategies. In psychological terms, these might correspond to **Physical Exercise**, **Screen Time**, and **Inaction**, respectively. These behaviors are not mere responses to mood but actively shape the kinds of stimuli the agent is likely to perceive. For example, attending to positive cues (akin to engaging in exercise) increases the likelihood of observing positive stimuli if the agent is indeed in a Positive state, reinforcing a healthy feedback loop. Conversely, attending to negative cues (analogous to screen time or rumination) heightens the chances of perceiving negative stimuli, particularly if the agent is already in a Negative state, thereby perpetuating depressive symptoms.

The observation probabilities are asymmetrical and state-dependent, reflecting empirical findings in affective neuroscience. The agent's action modifies the salience of stimuli based on the internal state: **Physical Exercise** enhances positive perceptions in a Positive state but provides attenuated benefits in a Negative state. In contrast, **Screen Time** disproportionately increases negative perceptions when the agent is in a Negative state, consistent with evidence linking passive media consumption to emotional worsening in depression (Twenge & Campbell, 2018).

To simulate motivational and cognitive dynamics, a reward structure is implemented. The agent earns rewards based on the congruence between its action and internal state. Adaptive actions, such as engaging with positive stimuli while in a Negative state, yield modest benefits, modeling the effortful but valuable nature of behavioral activation. Maladaptive actions, such as attending to negative cues in a Negative state, incur higher costs, reinforcing the real-world consequences of depressive behavior cycles. The **Wait** action represents emotional inertia or avoidance, associated with minor but cumulative penalties reflecting missed opportunities for improvement.



### Dynamics of Belief Updating and Decision-Making

At initialization, the agent is epistemically neutral, assigning equal probability to being in a Positive or Negative state. Over the course of the simulation, it performs Bayesian updates on its belief distribution after each action-observation pair. This captures the process by which individuals gradually form and revise their beliefs about their emotional state based on feedback from their environment.

The simulation proceeds by applying the policy computed from the optimal solution to the POMDP. This policy maps belief states to actions, indicating the most rational behavioral choice given the current uncertainty. The value iteration algorithm accounts for the **discount factor**—set at 0.95—emphasizing long-term gains over immediate rewards. This parameter reflects the forward-looking nature of behavioral planning and allows the model to simulate sustained interventions like therapy or habit formation.

Interestingly, the simulation reveals emergent behavior patterns. Initially uncertain, the agent oscillates between exploration and exploitation. As observations accumulate, belief sharpens, and the agent increasingly selects actions aligned with the inferred state. For example, repeated experiences of positive stimuli following Physical Exercise may reinforce the belief in a Positive state, creating a virtuous cycle. Conversely, initial selections of Screen Time in a Negative state can lead to spiraling negativity and persistent misbelief in a Negative state, mirroring clinical depression's persistence and resistance to change.



### Psychological Interpretation and Clinical Relevance

This model aligns closely with the **behavioral activation** approach to depression treatment, which posits that increasing engagement with rewarding activities can disrupt maladaptive patterns and shift emotional trajectories (Jacobson et al., 1996). By simulating how actions affect perception and belief updating, the model provides a computational instantiation of this theory. Furthermore, it offers insights into why certain behaviors—though immediately soothing—may ultimately reinforce depression, while others require effort but yield long-term benefit.

The model also has implications for understanding **cognitive biases** in depression. The asymmetry in observation probabilities demonstrates how depressive individuals may differentially attend to negative stimuli, especially when in a Negative state. This endogenous perceptual bias is not merely passive but actively constructed through behavior. Thus, interventions targeting attentional control and behavioral habits may serve to recalibrate not just mood but also cognitive appraisal processes.

Importantly, the model underscores the **interactive nature of mood and behavior**. Unlike static models that treat emotion as a consequence of cognition alone, the POMDP approach illustrates how action and perception co-evolve. This has profound implications for treatment design, particularly in contexts where verbal therapy is limited and behavioral change is the primary vehicle of transformation.



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
