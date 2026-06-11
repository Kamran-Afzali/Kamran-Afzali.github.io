# Modeling Depression-Related Cognitive Biases Through POMDPs

A Stepped-Care POMDP for Depression

Partially observable Markov decision processes are useful when the clinician cannot directly observe the patient’s latent clinical state, but must still choose an intervention under uncertainty. In depression care, that uncertainty is not incidental: symptom reports are noisy, remission is incomplete, and relapse risk can remain elevated even after apparent improvement. A POMDP formalism makes that uncertainty explicit by separating hidden states from observations and then optimizing actions over a belief distribution rather than a single observed status.[^3][^1]

The model below is a simplified stepped-care representation of depression treatment. It distinguishes acute illness, partial response, remission with residual relapse risk, and stable remission. That distinction matters because clinical decisions are rarely binary; they are usually conditional on whether the patient is still symptomatic, only partially improved, or clinically stable enough that more intensive treatment may be unnecessary or even burdensome.[^1]

## Model specification

The hidden state space is

$$
S = \{\text{Acute\_MDD}, \text{Partial\_Response}, \text{Remission\_HighRelapseRisk}, \text{Stable\_Remission}\}.
$$

The action space is

$$
A = \{\text{Monitor}, \text{Behavioral\_Activation}, \text{Medication\_Adjust}, \text{Combined\_CBT\_Med}\}.
$$

The observation space is

$$
O = \{\text{Severe\_Symptoms}, \text{Residual\_Symptoms}, \text{Minimal\_Symptoms}, \text{Good\_Functioning}\}.
$$

The policy is then a mapping from belief states $b \in \Delta(S)$ to actions, where $\Delta(S)$ is the probability simplex over hidden states. The value of a belief state is piecewise linear in the α-vectors:

$$
V(b) = \max_{i} b^\top \alpha_i,
$$

and each α-vector corresponds to one policy region in belief space.[^4][^2]

## Why this model is clinically more plausible

The states are arranged around symptom persistence and functional recovery rather than a naive depressed/not depressed dichotomy. That is closer to how depression is actually managed: residual symptoms and partial response are clinically meaningful because they often predict future relapse and treatment escalation decisions. A patient in `Stable_Remission` is not the same as someone in `Remission_HighRelapseRisk`, and the model gives those states different dynamics and different rewards.[^1]

The actions also reflect stepped care. `Monitor` is a low-burden option; `Behavioral_Activation` is a moderate psychosocial intervention; `Medication_Adjust` captures medication initiation, dose change, or switch; and `Combined_CBT_Med` represents a higher-intensity intervention. This is not a full clinical guideline, but it is a reasonable abstraction of escalation and de-escalation under uncertainty.[^1]

## The code

```r
library(pomdp)

DepressionSteppedCare <- POMDP(
  name = "DepressionSteppedCare",
  
  states = c(
    "Acute_MDD",
    "Partial_Response",
    "Remission_HighRelapseRisk",
    "Stable_Remission"
  ),
  
  actions = c(
    "Monitor",
    "Behavioral_Activation",
    "Medication_Adjust",
    "Combined_CBT_Med"
  ),
  
  observations = c(
    "Severe_Symptoms",
    "Residual_Symptoms",
    "Minimal_Symptoms",
    "Good_Functioning"
  ),
  
  start = c(
    Acute_MDD = 0.45,
    Partial_Response = 0.30,
    Remission_HighRelapseRisk = 0.15,
    Stable_Remission = 0.10
  ),
  
  transition_prob = list(
    "Monitor" = matrix(
      c(0.70, 0.20, 0.07, 0.03,
        0.20, 0.45, 0.25, 0.10,
        0.15, 0.20, 0.45, 0.20,
        0.03, 0.07, 0.15, 0.75),
      nrow = 4, byrow = TRUE
    ),
    "Behavioral_Activation" = matrix(
      c(0.45, 0.35, 0.15, 0.05,
        0.10, 0.40, 0.35, 0.15,
        0.08, 0.12, 0.45, 0.35,
        0.03, 0.04, 0.10, 0.83),
      nrow = 4, byrow = TRUE
    ),
    "Medication_Adjust" = matrix(
      c(0.35, 0.35, 0.20, 0.10,
        0.08, 0.30, 0.37, 0.25,
        0.10, 0.15, 0.40, 0.35,
        0.05, 0.06, 0.12, 0.77),
      nrow = 4, byrow = TRUE
    ),
    "Combined_CBT_Med" = matrix(
      c(0.22, 0.33, 0.25, 0.20,
        0.05, 0.20, 0.35, 0.40,
        0.06, 0.10, 0.29, 0.55,
        0.08, 0.06, 0.10, 0.76),
      nrow = 4, byrow = TRUE
    )
  ),
  
  observation_prob = rbind(
    O_("Monitor", "Acute_MDD", "Severe_Symptoms", 0.55),
    O_("Monitor", "Acute_MDD", "Residual_Symptoms", 0.30),
    O_("Monitor", "Acute_MDD", "Minimal_Symptoms", 0.10),
    O_("Monitor", "Acute_MDD", "Good_Functioning", 0.05),
    # ... remaining observation rows omitted here for brevity ...
  ),
  
  reward = rbind(
    R_("Monitor", "Acute_MDD", "Acute_MDD", "*", -7),
    R_("Monitor", "Acute_MDD", "Partial_Response", "*", -2),
    R_("Monitor", "Acute_MDD", "Remission_HighRelapseRisk", "*", 1),
    R_("Monitor", "Acute_MDD", "Stable_Remission", "*", 2)
    # ... remaining reward rows omitted here for brevity ...
  ),
  
  discount = 0.95,
  horizon = Inf
)

DepressionSteppedCare <- normalize_POMDP(DepressionSteppedCare)
solution <- solve_POMDP(DepressionSteppedCare)

policy(solution)
plot_policy_graph(solution)
```


## Transition dynamics

The transition matrices encode how treatment changes the latent state over time. `Monitor` is intentionally weak; it mostly preserves the current state, with only small movement toward improvement. By contrast, `Behavioral_Activation`, `Medication_Adjust`, and especially `Combined_CBT_Med` are progressively more effective at moving the patient toward better states. This ordering gives the solver a real trade-off: use low-intensity care when the belief is already favorable, and reserve stronger treatment for beliefs that suggest persistent illness.[^1]

Formally, if $T_a(s' \mid s)$ is the action-specific transition kernel, then the one-step predictive belief is

$$
\tilde b_{t+1}(s') = \sum_{s \in S} T_a(s' \mid s)\, b_t(s).
$$

The observation update then combines this predictive belief with the likelihood of the observed symptom pattern. That update is what allows the same action to be optimal in one belief region and suboptimal in another.[^4]

### Dry run: acute-looking belief

Suppose the belief is $b = (0.70, 0.20, 0.08, 0.02)$. That is still heavily weighted toward acute depression. The model should favor `Combined_CBT_Med` because the gain from more aggressive treatment likely outweighs its burden. In plain terms, this is the “don’t just watch it” region.

### Dry run: partial response

If the belief shifts to $b = (0.20, 0.50, 0.20, 0.10)$, the choice becomes less obvious. `Behavioral_Activation` or `Medication_Adjust` may now be competitive, because the patient is no longer clearly acute but is not safely recovered either. This is the classic stepped-care middle ground.

## Observation model

The observation model matters because symptoms do not reveal the true state cleanly. A patient in `Acute_MDD` can still report `Residual_Symptoms` rather than `Severe_Symptoms`, while a patient in `Stable_Remission` may still show some symptom noise. That noise is what creates the need for belief updating rather than direct classification.[^1]

Mathematically, the observation kernel $Z_a(o \mid s')$ determines the posterior belief

$$
b_{t+1}(s') \propto Z_a(o_{t+1} \mid s') \sum_{s \in S} T_a(s' \mid s) b_t(s).
$$

Because this update is nonlinear in the belief, the resulting optimal policy is not a single threshold on one observation. Instead, it is a partition of belief space into regions, each represented by one α-vector.[^2][^4]

### Dry run: symptom improvement signal

If the observed symptom pattern moves from `Severe_Symptoms` toward `Minimal_Symptoms`, the posterior belief should shift away from `Acute_MDD` and toward remission states. The policy may then switch from `Combined_CBT_Med` to `Behavioral_Activation` or even `Monitor`, depending on the rest of the belief vector. That is the point where a POMDP becomes more informative than a static rule.

## Reward structure

The reward function is where the clinical trade-offs are encoded. It penalizes untreated acute illness, rewards improvement, and assigns explicit burden costs to treatment intensity. That means `Combined_CBT_Med` is not automatically best; it is only best when its expected long-run benefit exceeds its burden.[^1]

In a discounted infinite-horizon problem, the objective is to maximize

$$
\mathbb{E}\left[\sum_{t=0}^{\infty} \gamma^t r(s_t, a_t, s_{t+1}, o_{t+1})\right],
$$

with discount factor $\gamma = 0.95$. The discounting matters because it rewards sustained improvement rather than one-step gains. That is clinically reasonable: a treatment is not good merely because it changes one observation; it is good if it moves the patient toward durable recovery.[^3]

### Dry run: stable-remission belief

Suppose $b = (0.03, 0.07, 0.20, 0.70)$. In that case, a high-burden intervention should be penalized, and `Monitor` or `Behavioral_Activation` should often dominate. If `Combined_CBT_Med` still wins here, then the overtreatment penalty is probably too weak.

## Alpha vectors and policy geometry

The solver output is a set of α-vectors. Each row of `policy(solution)` gives one vector $\alpha_i$ and the action associated with it. The value function is the upper envelope of these vectors:

$$
V(b) = \max_i b^\top \alpha_i.
$$

This is the standard geometry of exact and approximate POMDP solutions: a belief region corresponds to the α-vector that dominates there, and the action attached to that vector is the policy recommendation.[^2][^4]

In your results, the policy was split into two broad action families. Lower-symptom or lower-burden beliefs were associated with `Behavioral_Activation`, while more severe or more ambiguous beliefs leaned toward `Combined_CBT_Med`. That means the policy is doing what a stepped-care model should do: it escalates care when uncertainty and severity justify it, but avoids unnecessary intensity when remission is more plausible.

### Dry run: reading an alpha vector

Take a vector like

$$
\alpha = (9.39,\ 9.81,\ 9.91,\ 9.99)
$$

with action `Combined_CBT_Med`. If the belief is $b = (0.6, 0.2, 0.1, 0.1)$, then its value is

$$
V_\alpha(b) = 0.6(9.39) + 0.2(9.81) + 0.1(9.91) + 0.1(9.99).
$$

A different α-vector with action `Behavioral_Activation` may dominate when the belief shifts closer to remission states. So the rows are not competing claims about the world; they are competing linear approximations to the return surface.

## Interpreting the policy graph

The policy graph is the graph representation of those α-vectors. Nodes are policy regions, and edges connect nodes after observations are realized. In your graph, the early nodes were mainly `Behavioral_Activation`, while later nodes were mainly `Combined_CBT_Med`. That implies a relatively smooth boundary between lower-intensity and higher-intensity care rather than a messy, highly fragmented policy.[^4][^2]

### Dry run: node interpretation

If a node labeled `Behavioral_Activation` is reached after a posterior belief that still has substantial weight on `Acute_MDD`, the model is effectively saying the patient is symptomatic but not yet in the regime where combined treatment pays off enough. If an edge moves to a `Combined_CBT_Med` node after a symptom observation that suggests persistence or relapse risk, the policy is escalating in a clinically plausible way.

## What the solution is saying

The main substantive result is modest but meaningful: the model does not collapse to one action everywhere, and it does distinguish between moderate and intensive care. That is what you want from a POMDP in this setting. The policy is not a definitive clinical guideline, of course; it is a formalized decision heuristic that makes its assumptions explicit.[^1]

The deeper point is methodological. By using hidden states, noisy observations, and action-dependent rewards, you can encode a clinical decision problem that is both interpretable and mathematically transparent. The α-vectors then become a compact summary of how the policy trades off symptom severity, relapse risk, treatment burden, and uncertainty.[^2]

## Closing note

If you use this in a blog post or methods note, I would emphasize that the model is illustrative rather than validated. It is best understood as a structured decision toy model for depression care, not as a clinical recommender. Still, it is useful because it forces the assumptions into the open, and that alone is often more honest than an opaque black-box policy.[^3][^1]

If you want, I can turn this into a polished Markdown document with a title, abstract, numbered equations, and code blocks formatted for direct publication.
 [^5][^6][^7][^8] 





```r
library(pomdp)

DepressionSteppedCare <- POMDP(
  name = "DepressionSteppedCare",
  
  states = c(
    "Acute_MDD",
    "Partial_Response",
    "Remission_HighRelapseRisk",
    "Stable_Remission"
  ),
  
  actions = c(
    "Monitor",
    "Behavioral_Activation",
    "Medication_Adjust",
    "Combined_CBT_Med"
  ),
  
  observations = c(
    "Severe_Symptoms",
    "Residual_Symptoms",
    "Minimal_Symptoms",
    "Good_Functioning"
  ),
  
  start = c(
    Acute_MDD = 0.45,
    Partial_Response = 0.30,
    Remission_HighRelapseRisk = 0.15,
    Stable_Remission = 0.10
  ),
  
  transition_prob = list(
    
    "Monitor" = matrix(
      c(
        0.70, 0.20, 0.07, 0.03,   # Acute_MDD
        0.20, 0.45, 0.25, 0.10,   # Partial_Response
        0.15, 0.20, 0.45, 0.20,   # Remission_HighRelapseRisk
        0.03, 0.07, 0.15, 0.75    # Stable_Remission
      ),
      nrow = 4, byrow = TRUE,
      dimnames = list(
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission"),
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission")
      )
    ),
    
    "Behavioral_Activation" = matrix(
      c(
        0.45, 0.35, 0.15, 0.05,
        0.10, 0.40, 0.35, 0.15,
        0.08, 0.12, 0.45, 0.35,
        0.03, 0.04, 0.10, 0.83
      ),
      nrow = 4, byrow = TRUE,
      dimnames = list(
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission"),
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission")
      )
    ),
    
    "Medication_Adjust" = matrix(
      c(
        0.35, 0.35, 0.20, 0.10,
        0.08, 0.30, 0.37, 0.25,
        0.10, 0.15, 0.40, 0.35,
        0.05, 0.06, 0.12, 0.77
      ),
      nrow = 4, byrow = TRUE,
      dimnames = list(
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission"),
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission")
      )
    ),
    
    "Combined_CBT_Med" = matrix(
      c(
        0.22, 0.33, 0.25, 0.20,
        0.05, 0.20, 0.35, 0.40,
        0.06, 0.10, 0.29, 0.55,
        0.08, 0.06, 0.10, 0.76
      ),
      nrow = 4, byrow = TRUE,
      dimnames = list(
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission"),
        c("Acute_MDD", "Partial_Response", "Remission_HighRelapseRisk", "Stable_Remission")
      )
    )
  ),
  
  observation_prob = rbind(
    O_("Monitor",               "Acute_MDD",                 "Severe_Symptoms",   0.55),
    O_("Monitor",               "Acute_MDD",                 "Residual_Symptoms", 0.30),
    O_("Monitor",               "Acute_MDD",                 "Minimal_Symptoms",  0.10),
    O_("Monitor",               "Acute_MDD",                 "Good_Functioning",  0.05),
    
    O_("Monitor",               "Partial_Response",          "Severe_Symptoms",   0.15),
    O_("Monitor",               "Partial_Response",          "Residual_Symptoms", 0.55),
    O_("Monitor",               "Partial_Response",          "Minimal_Symptoms",  0.20),
    O_("Monitor",               "Partial_Response",          "Good_Functioning",  0.10),
    
    O_("Monitor",               "Remission_HighRelapseRisk", "Severe_Symptoms",   0.05),
    O_("Monitor",               "Remission_HighRelapseRisk", "Residual_Symptoms", 0.35),
    O_("Monitor",               "Remission_HighRelapseRisk", "Minimal_Symptoms",  0.40),
    O_("Monitor",               "Remission_HighRelapseRisk", "Good_Functioning",  0.20),
    
    O_("Monitor",               "Stable_Remission",          "Severe_Symptoms",   0.02),
    O_("Monitor",               "Stable_Remission",          "Residual_Symptoms", 0.08),
    O_("Monitor",               "Stable_Remission",          "Minimal_Symptoms",  0.30),
    O_("Monitor",               "Stable_Remission",          "Good_Functioning",  0.60),
    
    O_("Behavioral_Activation", "Acute_MDD",                 "Severe_Symptoms",   0.50),
    O_("Behavioral_Activation", "Acute_MDD",                 "Residual_Symptoms", 0.30),
    O_("Behavioral_Activation", "Acute_MDD",                 "Minimal_Symptoms",  0.12),
    O_("Behavioral_Activation", "Acute_MDD",                 "Good_Functioning",  0.08),
    
    O_("Behavioral_Activation", "Partial_Response",          "Severe_Symptoms",   0.10),
    O_("Behavioral_Activation", "Partial_Response",          "Residual_Symptoms", 0.50),
    O_("Behavioral_Activation", "Partial_Response",          "Minimal_Symptoms",  0.25),
    O_("Behavioral_Activation", "Partial_Response",          "Good_Functioning",  0.15),
    
    O_("Behavioral_Activation", "Remission_HighRelapseRisk", "Severe_Symptoms",   0.04),
    O_("Behavioral_Activation", "Remission_HighRelapseRisk", "Residual_Symptoms", 0.28),
    O_("Behavioral_Activation", "Remission_HighRelapseRisk", "Minimal_Symptoms",  0.42),
    O_("Behavioral_Activation", "Remission_HighRelapseRisk", "Good_Functioning",  0.26),
    
    O_("Behavioral_Activation", "Stable_Remission",          "Severe_Symptoms",   0.02),
    O_("Behavioral_Activation", "Stable_Remission",          "Residual_Symptoms", 0.07),
    O_("Behavioral_Activation", "Stable_Remission",          "Minimal_Symptoms",  0.28),
    O_("Behavioral_Activation", "Stable_Remission",          "Good_Functioning",  0.63),
    
    O_("Medication_Adjust",     "Acute_MDD",                 "Severe_Symptoms",   0.48),
    O_("Medication_Adjust",     "Acute_MDD",                 "Residual_Symptoms", 0.30),
    O_("Medication_Adjust",     "Acute_MDD",                 "Minimal_Symptoms",  0.14),
    O_("Medication_Adjust",     "Acute_MDD",                 "Good_Functioning",  0.08),
    
    O_("Medication_Adjust",     "Partial_Response",          "Severe_Symptoms",   0.10),
    O_("Medication_Adjust",     "Partial_Response",          "Residual_Symptoms", 0.47),
    O_("Medication_Adjust",     "Partial_Response",          "Minimal_Symptoms",  0.25),
    O_("Medication_Adjust",     "Partial_Response",          "Good_Functioning",  0.18),
    
    O_("Medication_Adjust",     "Remission_HighRelapseRisk", "Severe_Symptoms",   0.05),
    O_("Medication_Adjust",     "Remission_HighRelapseRisk", "Residual_Symptoms", 0.30),
    O_("Medication_Adjust",     "Remission_HighRelapseRisk", "Minimal_Symptoms",  0.40),
    O_("Medication_Adjust",     "Remission_HighRelapseRisk", "Good_Functioning",  0.25),
    
    O_("Medication_Adjust",     "Stable_Remission",          "Severe_Symptoms",   0.03),
    O_("Medication_Adjust",     "Stable_Remission",          "Residual_Symptoms", 0.10),
    O_("Medication_Adjust",     "Stable_Remission",          "Minimal_Symptoms",  0.32),
    O_("Medication_Adjust",     "Stable_Remission",          "Good_Functioning",  0.55),
    
    O_("Combined_CBT_Med",      "Acute_MDD",                 "Severe_Symptoms",   0.45),
    O_("Combined_CBT_Med",      "Acute_MDD",                 "Residual_Symptoms", 0.30),
    O_("Combined_CBT_Med",      "Acute_MDD",                 "Minimal_Symptoms",  0.15),
    O_("Combined_CBT_Med",      "Acute_MDD",                 "Good_Functioning",  0.10),
    
    O_("Combined_CBT_Med",      "Partial_Response",          "Severe_Symptoms",   0.08),
    O_("Combined_CBT_Med",      "Partial_Response",          "Residual_Symptoms", 0.42),
    O_("Combined_CBT_Med",      "Partial_Response",          "Minimal_Symptoms",  0.28),
    O_("Combined_CBT_Med",      "Partial_Response",          "Good_Functioning",  0.22),
    
    O_("Combined_CBT_Med",      "Remission_HighRelapseRisk", "Severe_Symptoms",   0.03),
    O_("Combined_CBT_Med",      "Remission_HighRelapseRisk", "Residual_Symptoms", 0.22),
    O_("Combined_CBT_Med",      "Remission_HighRelapseRisk", "Minimal_Symptoms",  0.40),
    O_("Combined_CBT_Med",      "Remission_HighRelapseRisk", "Good_Functioning",  0.35),
    
    O_("Combined_CBT_Med",      "Stable_Remission",          "Severe_Symptoms",   0.03),
    O_("Combined_CBT_Med",      "Stable_Remission",          "Residual_Symptoms", 0.10),
    O_("Combined_CBT_Med",      "Stable_Remission",          "Minimal_Symptoms",  0.30),
    O_("Combined_CBT_Med",      "Stable_Remission",          "Good_Functioning",  0.57)
  ),
  
  reward = rbind(
    # Monitor: cheap, but risky in sicker states
    R_("Monitor", "Acute_MDD",                 "Acute_MDD",                 "*", -7),
    R_("Monitor", "Acute_MDD",                 "Partial_Response",          "*", -2),
    R_("Monitor", "Acute_MDD",                 "Remission_HighRelapseRisk", "*",  1),
    R_("Monitor", "Acute_MDD",                 "Stable_Remission",          "*",  2),
    
    R_("Monitor", "Partial_Response",          "Acute_MDD",                 "*", -6),
    R_("Monitor", "Partial_Response",          "Partial_Response",          "*", -2),
    R_("Monitor", "Partial_Response",          "Remission_HighRelapseRisk", "*",  1),
    R_("Monitor", "Partial_Response",          "Stable_Remission",          "*",  3),
    
    R_("Monitor", "Remission_HighRelapseRisk", "Acute_MDD",                 "*", -8),
    R_("Monitor", "Remission_HighRelapseRisk", "Partial_Response",          "*", -4),
    R_("Monitor", "Remission_HighRelapseRisk", "Remission_HighRelapseRisk", "*", -1),
    R_("Monitor", "Remission_HighRelapseRisk", "Stable_Remission",          "*",  4),
    
    R_("Monitor", "Stable_Remission",          "Acute_MDD",                 "*", -8),
    R_("Monitor", "Stable_Remission",          "Partial_Response",          "*", -4),
    R_("Monitor", "Stable_Remission",          "Remission_HighRelapseRisk", "*", -2),
    R_("Monitor", "Stable_Remission",          "Stable_Remission",          "*",  5),
    
    # Behavioral Activation: moderate burden, good for partial/residual states
    R_("Behavioral_Activation", "Acute_MDD",                 "Acute_MDD",                 "*", -4),
    R_("Behavioral_Activation", "Acute_MDD",                 "Partial_Response",          "*",  2),
    R_("Behavioral_Activation", "Acute_MDD",                 "Remission_HighRelapseRisk", "*",  4),
    R_("Behavioral_Activation", "Acute_MDD",                 "Stable_Remission",          "*",  6),
    
    R_("Behavioral_Activation", "Partial_Response",          "Acute_MDD",                 "*", -5),
    R_("Behavioral_Activation", "Partial_Response",          "Partial_Response",          "*",  0),
    R_("Behavioral_Activation", "Partial_Response",          "Remission_HighRelapseRisk", "*",  4),
    R_("Behavioral_Activation", "Partial_Response",          "Stable_Remission",          "*",  6),
    
    R_("Behavioral_Activation", "Remission_HighRelapseRisk", "Acute_MDD",                 "*", -6),
    R_("Behavioral_Activation", "Remission_HighRelapseRisk", "Partial_Response",          "*", -1),
    R_("Behavioral_Activation", "Remission_HighRelapseRisk", "Remission_HighRelapseRisk", "*",  1),
    R_("Behavioral_Activation", "Remission_HighRelapseRisk", "Stable_Remission",          "*",  5),
    
    R_("Behavioral_Activation", "Stable_Remission",          "Acute_MDD",                 "*", -7),
    R_("Behavioral_Activation", "Stable_Remission",          "Partial_Response",          "*", -3),
    R_("Behavioral_Activation", "Stable_Remission",          "Remission_HighRelapseRisk", "*", -1),
    R_("Behavioral_Activation", "Stable_Remission",          "Stable_Remission",          "*",  3),
    
    # Medication adjustment: stronger effect, more burden / side-effect cost
    R_("Medication_Adjust", "Acute_MDD",                 "Acute_MDD",                 "*", -3),
    R_("Medication_Adjust", "Acute_MDD",                 "Partial_Response",          "*",  3),
    R_("Medication_Adjust", "Acute_MDD",                 "Remission_HighRelapseRisk", "*",  5),
    R_("Medication_Adjust", "Acute_MDD",                 "Stable_Remission",          "*",  7),
    
    R_("Medication_Adjust", "Partial_Response",          "Acute_MDD",                 "*", -5),
    R_("Medication_Adjust", "Partial_Response",          "Partial_Response",          "*",  0),
    R_("Medication_Adjust", "Partial_Response",          "Remission_HighRelapseRisk", "*",  4),
    R_("Medication_Adjust", "Partial_Response",          "Stable_Remission",          "*",  6),
    
    R_("Medication_Adjust", "Remission_HighRelapseRisk", "Acute_MDD",                 "*", -6),
    R_("Medication_Adjust", "Remission_HighRelapseRisk", "Partial_Response",          "*", -2),
    R_("Medication_Adjust", "Remission_HighRelapseRisk", "Remission_HighRelapseRisk", "*",  0),
    R_("Medication_Adjust", "Remission_HighRelapseRisk", "Stable_Remission",          "*",  5),
    
    R_("Medication_Adjust", "Stable_Remission",          "Acute_MDD",                 "*", -8),
    R_("Medication_Adjust", "Stable_Remission",          "Partial_Response",          "*", -4),
    R_("Medication_Adjust", "Stable_Remission",          "Remission_HighRelapseRisk", "*", -2),
    R_("Medication_Adjust", "Stable_Remission",          "Stable_Remission",          "*",  1),
    
    # Combined treatment: best in severe illness, clear overtreatment cost in stable remission
    R_("Combined_CBT_Med", "Acute_MDD",                 "Acute_MDD",                 "*", -1),
    R_("Combined_CBT_Med", "Acute_MDD",                 "Partial_Response",          "*",  4),
    R_("Combined_CBT_Med", "Acute_MDD",                 "Remission_HighRelapseRisk", "*",  6),
    R_("Combined_CBT_Med", "Acute_MDD",                 "Stable_Remission",          "*",  9),
    
    R_("Combined_CBT_Med", "Partial_Response",          "Acute_MDD",                 "*", -4),
    R_("Combined_CBT_Med", "Partial_Response",          "Partial_Response",          "*",  0),
    R_("Combined_CBT_Med", "Partial_Response",          "Remission_HighRelapseRisk", "*",  4),
    R_("Combined_CBT_Med", "Partial_Response",          "Stable_Remission",          "*",  7),
    
    R_("Combined_CBT_Med", "Remission_HighRelapseRisk", "Acute_MDD",                 "*", -5),
    R_("Combined_CBT_Med", "Remission_HighRelapseRisk", "Partial_Response",          "*", -1),
    R_("Combined_CBT_Med", "Remission_HighRelapseRisk", "Remission_HighRelapseRisk", "*",  1),
    R_("Combined_CBT_Med", "Remission_HighRelapseRisk", "Stable_Remission",          "*",  6),
    
    R_("Combined_CBT_Med", "Stable_Remission",          "Acute_MDD",                 "*", -10),
    R_("Combined_CBT_Med", "Stable_Remission",          "Partial_Response",          "*", -6),
    R_("Combined_CBT_Med", "Stable_Remission",          "Remission_HighRelapseRisk", "*", -4),
    R_("Combined_CBT_Med", "Stable_Remission",          "Stable_Remission",          "*", -1),
    
    # Generic action costs to break ties and encode burden
    R_("Monitor",               NA, NA, NA, -0.2),
    R_("Behavioral_Activation", NA, NA, NA, -0.6),
    R_("Medication_Adjust",     NA, NA, NA, -1.0),
    R_("Combined_CBT_Med",      NA, NA, NA, -1.6),
    
    # Observation-linked utility/disutility to make functioning matter
    R_(NA, NA, NA, "Good_Functioning",   1.2),
    R_(NA, NA, NA, "Minimal_Symptoms",   0.3),
    R_(NA, NA, NA, "Residual_Symptoms", -0.5),
    R_(NA, NA, NA, "Severe_Symptoms",   -1.5)
  ),
  
  discount = 0.95,
  horizon = Inf
)

DepressionSteppedCare <- normalize_POMDP(DepressionSteppedCare)

solution <- solve_POMDP(DepressionSteppedCare)

print(solution)
policy(solution)
solution$solution$pg
solution$solution$alpha
# Useful diagnostics
plot_policy_graph(solution)
# Example simulations
set.seed(1)
sim <- simulate_POMDP(
  model = DepressionSteppedCare,
  policy = policy(solution),
  belief = c(
    Acute_MDD = 0.35,
    Partial_Response = 0.35,
    Remission_HighRelapseRisk = 0.20,
    Stable_Remission = 0.10
  ),
  n = 50
)

sim

```



### References

<div align="center">⁂</div>

[^1]: https://journal.r-project.org/articles/RJ-2024-021/

[^2]: https://rdrr.io/cran/pomdp/man/solve_POMDP.html

[^3]: https://algorithmsbook.com/files/chapter-20.pdf

[^4]: https://www.cs.cmu.edu/~ggordon/780-fall07/lectures/POMDP_lecture.pdf

[^5]: https://www.rdocumentation.org/packages/pomdp/versions/1.2.4

[^6]: https://www.kaggle.com/code/runway/point-based-value-iteration-for-pomdps

[^7]: http://juliapomdp.github.io/POMDPs.jl/v0.2/def_solver/

[^8]: https://dariusb.bitbucket.io/papers/POMDP_survey.pdf


Jacobson, N. S., Martell, C. R., & Dimidjian, S. (2001). [Behavioral activation treatment for depression: Returning to contextual roots](https://doi.org/10.1037/0003-066X.56.3.255). *American Psychologist, 56*(3), 255–265.

Twenge, J. M., & Campbell, W. K. (2018). [Associations between screen time and lower psychological well-being among children and adolescents: Evidence from a population-based study](https://doi.org/10.1016/j.puhe.2018.06.005). *Preventive Medicine Reports, 12*, 271–283.

Kaelbling, L. P., Littman, M. L., & Cassandra, A. R. (1998). [Planning and acting in partially observable stochastic domains](https://doi.org/10.1016/S0004-3702%2898%2900023-X). *Artificial Intelligence, 101*(1–2), 99–134.
