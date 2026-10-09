---
layout: post
categories: posts
title: Social Feedback and Mood-Dependent Learning in a Sequential Environment
tags: [Computational psychiatry, Decision-making, Reinforcement learning, Social feedback]
date-string: October 2026
---

# Social Feedback and Mood-Dependent Learning in a Sequential Environment

## Introduction

In the previous post, we considered how mood can influence learning in a sequential decision-making environment. An agent moved between behavioral contexts, received rewards, and updated its estimates of which actions were worthwhile. Mood depended on recent outcomes and, in turn, changed the rate at which the agent learned from subsequent experiences. This established a feedback loop between affect and value learning, but it did not distinguish the consequences of an activity from the responses that activity might elicit from other people.

That distinction matters. Attempting to socialize may produce a task reward and receive social approval, whereas another action may have an immediate payoff but attract disapproval. These signals need not agree, and they need not enter the learning process in the same way. A model that combines them into a single reward would make different assumptions from one in which social feedback changes mood without directly changing the value-learning target.

Here we implement the second possibility. The agent learns task-related action values through Q-learning, while its mood responds to both rewards and peer feedback. Social appraisal therefore influences subsequent learning indirectly: it changes mood, which changes the learning rate applied to later outcomes.

We compare two parameter profiles, labeled “Healthy” and “Depressed” in the code. These labels identify illustrative configurations rather than clinically validated populations. The simulation does not establish that depression corresponds to the specified parameter values, nor that the resulting trajectories reproduce observed symptoms. Its purpose is to make a proposed mechanism explicit and examine what follows from its implementation.

The central distinction is **indirect** social influence. Peer feedback enters the affective update, but not the temporal-difference reward target.

## A Sequential Behavioral Environment

The environment contains five states:

$$
\mathcal{S}
=
\{
\text{ScreenTime},
\text{PhysicalActivity},
\text{Socializing},
\text{Alcohol},
\text{Cinema}
\}.
$$

The action set uses the same labels. A state describes the agent’s current context, whereas an action represents an attempt to move toward an activity. Selecting an action does not guarantee arrival in the corresponding state.

We describe the task as a finite Markov decision process:

$$
\mathcal{M}
=
(\mathcal{S},\mathcal{A},P,R,\gamma),
$$

where $P$ specifies transitions, $R$ specifies immediate rewards, and $\gamma=0.9$ discounts future rewards.

``` r
states <- c(
  "ScreenTime", "PhysicalActivity",
  "Socializing", "Alcohol", "Cinema"
)

n_states <- length(states)
actions <- seq_len(n_states)

transition_probs <- array(
  0, dim = c(n_states, n_states, n_states)
)

for (s in seq_len(n_states)) {
  for (a in seq_len(n_states)) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6
    transition_probs[s, , a] <- prob / sum(prob)
  }
}
```

For every current state, an action has a probability of $0.6$ of reaching its corresponding context and a probability of $0.1$ of reaching each alternative:

$$
P(s'\mid s,a)
=
\begin{cases}
0.6, & s'=a,\\
0.1, & s'\neq a.
\end{cases}
$$

This is action-directed movement, not necessarily state persistence. Selecting PhysicalActivity increases the probability of reaching PhysicalActivity whether the agent currently occupies ScreenTime, Alcohol, or another context.

The transition distribution also does not depend on the current state. The model therefore includes imperfect control over the next activity, but it does not represent context-specific obstacles. Moving toward socializing is no more difficult from Alcohol than from Cinema.

### Immediate reward and future opportunities

Rewards depend on the current state and selected action:

| Current state    | ScreenTime | PhysicalActivity | Socializing | Alcohol | Cinema |
|------------------|-----------:|-----------------:|------------:|--------:|-------:|
| ScreenTime       |          0 |                1 |           2 |      −2 |      1 |
| PhysicalActivity |          1 |                0 |           2 |      −1 |      2 |
| Socializing      |          2 |                1 |           0 |      −2 |      2 |
| Alcohol          |         −2 |               −1 |           0 |       0 |     −1 |
| Cinema           |          1 |                2 |           2 |      −1 |      0 |

``` r
rewards <- matrix(
  c(
     0,  1, 2, -2,  1,
     1,  0, 2, -1,  2,
     2,  1, 0, -2,  2,
    -2, -1, 0,  0, -1,
     1,  2, 2, -1,  0
  ),
  nrow = n_states,
  byrow = TRUE
)

env <- list(
  states = states,
  transition_probs = transition_probs,
  rewards = rewards
)
```

These values define a hypothetical task. They are not empirical estimates of the psychological value of exercise, alcohol consumption, or social interaction.

The immediate reward is

$$
r_t=R(s_t,a_t),
$$

rather than a function of the state actually reached. Selecting Socializing from ScreenTime yields $r_t=2$, even if the transition leads to Cinema. The model thus assigns value to the attempted action separately from its success in changing context.

Nevertheless, the next state matters for future decisions. An action may be useful because of its immediate reward, because it tends to lead to a favorable context, or because of both. This is the sequential component that distinguishes the task from a bandit environment.

## Q-Learning with a Mood-Dependent Update Rate

The agent maintains a matrix $Q_t(s,a)$, initialized to zero. Its entries estimate the discounted return associated with selecting each action in each state.

At time $t$, the temporal-difference error is

$$
\delta_t
=
r_t
+
\gamma\max_{a'}Q_t(s_{t+1},a')
-
Q_t(s_t,a_t).
$$

Only the selected state–action entry is updated:

$$
Q_{t+1}(s_t,a_t)
=
Q_t(s_t,a_t)
+
\alpha_t\delta_t.
$$

``` r
Q <- matrix(
  0, nrow = n_states, ncol = n_states
)

delta <- reward +
  gamma * max(Q[next_state, ]) -
  Q[current_state, action]

Q[current_state, action] <-
  Q[current_state, action] + alpha * delta
```

The target contains task reward and the estimated value of the next state. It contains no peer-feedback term. Social approval therefore does not directly increase the reward the agent attempts to predict.

### How mood changes learning

Before determining the learning rate, the agent clamps mood to the interval $[-1,1]$:

$$
\bar m_t
=
\max(-1,\min(m_t,1)).
$$

The learning rate is then

$$
\alpha_t
=
\alpha_{\mathrm{base}}
\exp(-\beta\bar m_t),
$$

where $\beta$ is the code’s `mood_influence` parameter.

``` r
mood_clamped <- max(min(mood, 1), -1)

alpha <- alpha_base *
  exp(-mood_influence * mood_clamped)
```

For positive $\beta$, negative mood increases learning and positive mood decreases it. With $\alpha_{\mathrm{base}}=0.1$, the healthy-like profile has an effective range of approximately $0.037$ to $0.272$. The depressed-like profile, with $\beta=2$, has a range of approximately $0.014$ to $0.739$.

This mechanism does not implement preferential learning from negative prediction errors. It increases the size of the update under negative mood regardless of the error’s sign. An unexpectedly poor outcome can produce a larger downward revision, but an unexpectedly favorable outcome can also produce a larger upward revision.

The ordering of operations matters. Mood before the current outcome determines $\alpha_t$. The current reward and social feedback update mood afterward, affecting learning on the next decision step rather than the current one.

Mood itself is not restricted to $[-1,1]$. Only its influence on the learning rate is clamped. Once mood falls below $-1$, further decreases remain visible in the mood trajectory but do not increase $\alpha_t$ any further.

## Action Selection and the Limits of Valuation Bias

The agent uses an $\epsilon$-greedy policy with $\epsilon=0.1$. It samples uniformly from the five actions with probability $0.1$; otherwise, it chooses the action with the largest transformed value.

$$
\widetilde Q_t(s,a)
=
Q_t(s,a)+o-p\bigl(1-Q_t(s,a)\bigr),
$$

where $o$ and $p$ denote optimism and pessimism.

``` r
biased_Q <- Q[current_state, ] +
  optimism -
  pessimism * (1 - Q[current_state, ])

action <- if (runif(1) < epsilon) {
  sample(seq_len(n_states), 1)
} else {
  which.max(biased_Q)
}
```

Despite their psychological labels, these parameters do not alter action selection for the values used here. Rearranging gives

$$
\widetilde Q_t(s,a)
=
(1+p)Q_t(s,a)+(o-p).
$$

Because $1+p>0$, this transformation preserves action rankings:

$$
\arg\max_a \widetilde Q_t(s,a)
=
\arg\max_a Q_t(s,a).
$$

The Q-learning update also uses the original values rather than the transformed ones. Optimism and pessimism therefore have no behavioral effect in this implementation, apart from possible numerical edge cases that are not the intended mechanism.

Exploration is likewise independent of mood. Both profiles use the same fixed $\epsilon$, so a difference in their trajectories cannot be explained by a programmed difference in random exploration.

Tie-breaking introduces another detail. R’s `which.max()` returns the first maximum. Since all initial values are zero, an initial non-exploratory choice selects ScreenTime by indexing convention, not because the agent has learned to prefer it.

## Peer Feedback as a Separate Affective Signal

The script supports two feedback modes. In random mode, peer feedback is sampled independently from three possible values:

$$
F_t\in\{-1,0,1\},
$$

with probabilities

$$
\Pr(F_t=-1)=0.2,\qquad
\Pr(F_t=0)=0.6,\qquad
\Pr(F_t=1)=0.2.
$$

Its expected value is zero. Random feedback can still perturb mood on individual steps, even though it has no average positive or negative direction.

Both illustrated profiles instead use `"state-based"` feedback:

$$
F(a_t)
=
\begin{cases}
1, & a_t\in\{\text{Socializing},\text{PhysicalActivity}\},\\
-1, & a_t=\text{Alcohol},\\
0, & \text{otherwise}.
\end{cases}
$$

``` r
peer_feedback <- if (peer_feedback_mode == "random") {
  sample(
    c(-1, 0, 1), 1,
    prob = c(0.2, 0.6, 0.2)
  )
} else if (peer_feedback_mode == "state-based") {
  selected_action <- env$states[action]

  if (selected_action %in%
      c("Socializing", "PhysicalActivity")) {
    1
  } else if (selected_action == "Alcohol") {
    -1
  } else {
    0
  }
} else {
  0
}
```

The name “state-based” is slightly misleading: feedback depends on the selected action, not the current state or realized destination. Attempting to socialize receives approval even when the transition leads elsewhere.

This feedback rule encodes a prescribed social norm. It does not represent a peer who learns, changes preferences, or responds to relationship history. The model contains a social evaluation signal, but not an interacting social agent.

Task reward and appraisal can disagree. From Alcohol, selecting PhysicalActivity produces a task reward of $-1$ and peer feedback of $+1$. Conversely, selecting Socializing while already in Socializing produces zero task reward but positive feedback. Keeping the two signals separate allows the model to represent such cases without treating social approval as synonymous with task success.

## Combining Reward and Appraisal in Mood

Reward contributes to mood through an asymmetric transformation:

$$
g(r_t)
=
\begin{cases}
w_+r_t, & r_t>0,\\
w_-r_t, & r_t<0,\\
0, & r_t=0.
\end{cases}
$$

Mood evolves according to

$$
m_{t+1}
=
\lambda m_t
+
(1-\lambda)
\left[g(r_t)+\omega F_t\right].
$$

Here, $\lambda$ controls persistence, $w_+$ and $w_-$ control outcome weighting, and $\omega$ controls sensitivity to social feedback.

``` r
mood_reward <- if (reward > 0) {
  rumination_weight_success * reward
} else {
  rumination_weight_failure * reward
}

mood_social <- social_feedback_weight * peer_feedback

mood <- mood_decay * mood +
  (1 - mood_decay) * (mood_reward + mood_social)
```

The parameters called “rumination weights” implement differential weighting of positive and negative rewards. There is no replay of earlier events or repeated updating from a remembered outcome. Previous experiences persist through the mood variable, but the code does not explicitly model recurrent attention to a particular event.

Writing

$$
u_t=g(r_t)+\omega F_t
$$

makes the temporal structure clearer:

$$
m_t
=
\lambda^t m_0
+
(1-\lambda)
\sum_{k=0}^{t-1}
\lambda^{t-1-k}u_k.
$$

Mood is an exponentially weighted history of combined reward and appraisal inputs. A larger $\lambda$ retains earlier inputs for longer, whereas a smaller $\lambda$ gives more weight to the current input.

The social pathway is therefore

$$
F_t
\longrightarrow
m_{t+1}
\longrightarrow
\alpha_{t+1}
\longrightarrow
Q_{t+2}.
$$

Positive feedback increases mood relative to otherwise identical conditions and subsequently lowers the learning rate. Negative feedback does the reverse. Neither effect guarantees better or worse task performance: its consequences depend on the prediction errors that follow.

## Comparing the Two Parameter Profiles

The profiles differ in several mechanisms simultaneously:

| Parameter                                    | Healthy-like | Depressed-like |
|----------------------------------------------|-------------:|---------------:|
| Base learning rate, $\alpha_{\mathrm{base}}$ |          0.1 |            0.1 |
| Mood persistence, $\lambda$                  |         0.95 |           0.90 |
| Mood influence, $\beta$                      |          1.0 |            2.0 |
| Positive outcome weight, $w_+$               |          0.6 |            0.2 |
| Negative outcome weight, $w_-$               |          0.4 |            0.8 |
| Social feedback weight, $\omega$             |          0.3 |            0.5 |
| Pessimism, $p$                               |          0.0 |            0.3 |
| Optimism, $o$                                |          0.1 |            0.0 |

Both use $\gamma=0.9$, $\epsilon=0.1$, and action-contingent feedback.

``` r
params_healthy <- list(
  alpha_base = 0.1,
  mood_decay = 0.95,
  mood_influence = 1.0,
  rumination_weight_success = 0.6,
  rumination_weight_failure = 0.4,
  pessimism = 0.0,
  optimism = 0.1,
  social_feedback_weight = 0.3,
  peer_feedback_mode = "state-based"
)

params_depressed <- list(
  alpha_base = 0.1,
  mood_decay = 0.9,
  mood_influence = 2.0,
  rumination_weight_success = 0.2,
  rumination_weight_failure = 0.8,
  pessimism = 0.3,
  optimism = 0.0,
  social_feedback_weight = 0.5,
  peer_feedback_mode = "state-based"
)
```

The depressed-like profile gives less affective weight to positive reward and more to negative reward. Its larger social coefficient increases sensitivity to both approval and disapproval; it does not selectively increase rejection sensitivity.

Its lower persistence parameter also means that previous mood decays faster. The parameterization therefore does not encode more persistent negative mood through $\lambda$, even though repeated negative inputs could still maintain a negative trajectory.

### A one-step comparison

From ScreenTime, selecting Socializing gives $r_t=2$ and $F_t=1$. The healthy-like input is

$$
u_t^{(H)}=0.6(2)+0.3=1.5,
$$

whereas the depressed-like input is

$$
u_t^{(D)}=0.2(2)+0.5=0.9.
$$

Starting from neutral mood, the updates are

$$
m_{t+1}^{(H)}=0.05(1.5)=0.075,
$$

$$
m_{t+1}^{(D)}=0.10(0.9)=0.09.
$$

Despite its smaller positive reward weight, the depressed-like profile has the larger initial mood increase because it assigns more weight to the current input.

Selecting Alcohol from the same state produces $r_t=-2$ and $F_t=-1$. The corresponding mood changes are

$$
m_{t+1}^{(H)}
=
0.05[-0.4(2)-0.3]
=
-0.055,
$$

$$
m_{t+1}^{(D)}
=
0.10[-0.8(2)-0.5]
=
-0.21.
$$

These calculations can be checked independently of the stochastic simulation:

``` r
mood_step <- function(
    mood, reward, feedback, persistence,
    positive_weight, negative_weight, social_weight
) {
  weighted_reward <- if (reward > 0) {
    positive_weight * reward
  } else {
    negative_weight * reward
  }

  persistence * mood +
    (1 - persistence) *
    (weighted_reward + social_weight * feedback)
}

mood_step(0, 2, 1, 0.95, 0.6, 0.4, 0.3)
mood_step(0, 2, 1, 0.90, 0.2, 0.8, 0.5)
```

The examples illustrate why individual parameters should not be interpreted in isolation. Outcome weighting, feedback sensitivity, and persistence jointly determine the immediate affective response.

## Simulating and Inspecting Trajectories

The script runs one trajectory per profile:

``` r
set.seed(42)

healthy_df <- do.call(
  simulate_q_agent,
  c(list(env = env), params_healthy)
)
healthy_df$Group <- "Healthy"

depressed_df <- do.call(
  simulate_q_agent,
  c(list(env = env), params_depressed)
)
depressed_df$Group <- "Depressed"

combined_df <- bind_rows(healthy_df, depressed_df)
```

Although the function argument is named `n_episodes`, the agent is not reset during the loop and no terminal state is defined. Each run therefore consists of 200 continuing-task decision steps, not 200 independent episodes.

The trajectory records the current state and selected action, followed by the reward, updated mood, and peer feedback. The `Mood` entry on row $t$ is the post-outcome value $m_{t+1}$, whereas `State` is the pre-transition state $s_t$. The realized destination is not recorded directly, although it becomes the next row’s current state except at the end of the run.

### Mood and cumulative task reward

The mood plot describes affective history:

``` r
ggplot(
  combined_df,
  aes(x = Episode, y = Mood, color = Group)
) +
  geom_line(linewidth = 1) +
  labs(
    title = "Mood Trajectories with Social Influence",
    x = "Decision step",
    y = "Mood"
  ) +
  theme_minimal()
```

Cumulative reward describes a different quantity:

$$
C_T=\sum_{t=0}^{T-1}r_t.
$$

It excludes social feedback and does not discount later rewards, whereas the learned action values use a discounted objective.

``` r
combined_df <- combined_df %>%
  group_by(Group) %>%
  mutate(CumulativeReward = cumsum(Reward)) %>%
  ungroup()

ggplot(
  combined_df,
  aes(x = Episode, y = CumulativeReward, color = Group)
) +
  geom_line(linewidth = 1) +
  labs(
    title = "Cumulative Task Reward",
    x = "Decision step",
    y = "Cumulative reward"
  ) +
  theme_minimal()
```

A more positive mood trajectory need not imply greater task reward. Approval can improve mood without entering cumulative reward, and mood can change learning in ways that either help or hinder subsequent value estimates.

### State visits and peer feedback

State visits describe occupied contexts rather than attempted actions:

``` r
ggplot(
  combined_df,
  aes(x = Episode, y = State, color = Group)
) +
  geom_point(alpha = 0.5) +
  labs(
    title = "Behavioral Contexts Over Time",
    x = "Decision step",
    y = "Current state"
  ) +
  theme_minimal()
```

The feedback plot follows the action sequence under the prescribed appraisal rule:

``` r
ggplot(
  combined_df,
  aes(x = Episode, y = PeerFeedback, color = Group)
) +
  geom_line(alpha = 0.4) +
  geom_smooth(se = FALSE) +
  labs(
    title = "Peer Feedback Over Time",
    x = "Decision step",
    y = "Peer feedback"
  ) +
  theme_minimal()
```

The smoother summarizes the plotted sequence; it is not an additional social process in the simulation. In action-contingent mode, receiving more approval means selecting more approved actions. It does not indicate that a peer has become more supportive.

Without executing the R script, we should not claim numerical endpoints or a particular ordering of the trajectories. Even after execution, one run per profile would remain an illustration rather than an estimate of a reliable difference.

## Replication and Mechanism-Specific Comparisons

The two runs consume different portions of the random-number sequence. Differences between them reflect both parameter changes and stochastic variation in transitions and exploration.

Repeated simulations provide a more informative comparison:

``` r
run_replicates <- function(params, group, n_agents = 100) {
  bind_rows(lapply(seq_len(n_agents), function(i) {
    set.seed(1000 + i)

    df <- do.call(
      simulate_q_agent,
      c(list(env = env, n_episodes = 200), params)
    )

    df$Agent <- i
    df$Group <- group
    df
  }))
}

replicated_df <- bind_rows(
  run_replicates(params_healthy, "Healthy"),
  run_replicates(params_depressed, "Depressed")
)

agent_summary <- replicated_df %>%
  group_by(Group, Agent) %>%
  summarise(
    TotalReward = sum(Reward),
    MeanMood = mean(Mood),
    MeanFeedback = mean(PeerFeedback),
    .groups = "drop"
  )
```

Corresponding seeds organize comparisons but do not guarantee identical realized experiences once action sequences differ. Replication estimates variability within the specified model; it does not validate the profiles against clinical data.

A separate issue is attribution. Because several parameters change together, a performance difference cannot be assigned specifically to social sensitivity or negative outcome weighting.

A social-feedback ablation offers a narrower comparison:

``` r
params_without_social <- params_healthy
params_without_social$social_feedback_weight <- 0

replicated_social <- bind_rows(
  run_replicates(params_healthy, "Social feedback"),
  run_replicates(params_without_social, "No social contribution")
)
```

This preserves the feedback-generation rule but removes its contribution to mood. Similar comparisons could vary $\beta$, $\lambda$, or reward weights individually. These analyses would test mechanisms more directly than contrasting two bundles of psychologically named parameters.

## Limitations and Next Steps

The model links task reward, prescribed social evaluation, mood, and learning within a sequential environment. Its interpretation remains constrained by how each component is represented.

First, the social signal is externally specified. There are no reciprocal relationships, competing peers, or beliefs about another person’s intentions. An extension could make feedback depend on peer identity, previous interactions, or uncertain social expectations, but that would introduce mechanisms absent from the current script.

Second, mood responds to weighted reward levels rather than prediction errors. An expected reward and an unexpectedly favorable reward have the same immediate affective contribution when their magnitudes match. A prediction-error-based formulation would instead distinguish outcome value from surprise:

$$
m_{t+1}
=
\lambda m_t
+
(1-\lambda)
\left[h(\delta_t)+\omega F_t\right].
$$

That alternative should be treated as a different hypothesis, not a correction that is automatically preferable.

Third, the agent does not learn separate values for social approval. It also does not represent mood as part of its state. Consequently, the action-value matrix does not distinguish the same activity context under different affective conditions, even though mood changes the learning dynamics.

Finally, the optimism and pessimism terms need revision if they are intended to alter behavior. Action-specific initial values, subjective reward transformations, or biased beliefs about transition success would have different computational consequences. A positive affine transformation followed by `which.max()` does not implement those mechanisms.

A prediction-error-based mood rule, for example, could be explored with:

``` r
affective_error <- if (delta > 0) {
  positive_error_weight * delta
} else {
  negative_error_weight * delta
}

mood <- mood_decay * mood +
  (1 - mood_decay) *
  (affective_error + social_feedback_weight * peer_feedback)
```

This snippet is a proposed extension, not part of the supplied implementation. It would require separate simulation and interpretation.

The present framework is best understood as a set of explicit computational hypotheses. Social appraisal can influence later value learning through mood; asymmetric reward weighting can change affective trajectories; and faster learning under negative mood can amplify unfavorable revisions or accelerate their correction. Establishing which effects dominate requires replicated simulations. Establishing whether they describe human behavior requires behavioral and affective data.

## Scientific Literature

Eldar, E., Rutledge, R. B., Dolan, R. J., & Niv, Y. (2016). Mood as representation of momentum. *Trends in Cognitive Sciences, 20*(1), 15–24. <https://doi.org/10.1016/j.tics.2015.07.010> [pubmed.ncbi.nlm.nih](https://pubmed.ncbi.nlm.nih.gov/26545853/)

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience, 38*, 1–23. <https://doi.org/10.1146/annurev-neuro-071714-033928> [pubmed.ncbi.nlm.nih](https://pubmed.ncbi.nlm.nih.gov/25705929/)

Watkins, C. J. C. H., & Dayan, P. (1992). Q-learning. *Machine Learning, 8*, 279–292. <https://doi.org/10.1007/BF00992698> [link.springer](https://link.springer.com/article/10.1007/BF00992698)

``` r
set.seed(123)
library(ggplot2)
library(reshape2)
library(dplyr)

# ---- ENVIRONMENT SETUP ----

states <- c("ScreenTime", "PhysicalActivity", "Socializing", "Alcohol", "Cinema")
n_states <- length(states)
actions <- 1:n_states

transition_probs <- array(0, dim = c(n_states, n_states, n_states))
for (s in 1:n_states) {
  for (a in 1:n_states) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6
    transition_probs[s, , a] <- prob / sum(prob)
  }
}

rewards <- matrix(c(
  0, 1, 2, -2, 1,
  1, 0, 2, -1, 2,
  2, 1, 0, -2, 2,
  -2, -1, 0, 0, -1,
  1, 2, 2, -1, 0
), nrow = n_states, byrow = TRUE)

env <- list(
  states = states,
  transition_probs = transition_probs,
  rewards = rewards
)

# ---- Q-LEARNING AGENT FUNCTION WITH SOCIAL INFLUENCE ----

simulate_q_agent <- function(
    env,
    n_episodes = 200,
    alpha_base = 0.1,
    gamma = 0.9,
    epsilon = 0.1,
    mood_decay = 0.95,
    mood_influence = 1.5,
    rumination_weight_success = 0.5,
    rumination_weight_failure = 0.5,
    pessimism = 0.0,
    optimism = 0.0,
    social_feedback_weight = 0.3,
    peer_feedback_mode = "random" # or "state-based"
) {
  n_states <- length(env$states)
  Q <- matrix(0, nrow = n_states, ncol = n_states)
  mood <- 0
  current_state <- sample(1:n_states, 1)
  
  trajectory <- data.frame(
    Episode = integer(n_episodes),
    State = character(n_episodes),
    Action = character(n_episodes),
    Reward = numeric(n_episodes),
    Mood = numeric(n_episodes),
    PeerFeedback = numeric(n_episodes)
  )
  
  for (ep in 1:n_episodes) {
    mood_clamped <- max(min(mood, 1), -1)
    biased_Q <- Q[current_state, ] + optimism - pessimism * (1 - Q[current_state, ])
    action <- if (runif(1) < epsilon) sample(1:n_states, 1) else which.max(biased_Q)
    next_state <- sample(1:n_states, 1, prob = env$transition_probs[current_state, , action])
    reward <- env$rewards[current_state, action]
    
    # Peer feedback
    peer_feedback <- if (peer_feedback_mode == "random") {
      sample(c(-1, 0, 1), 1, prob = c(0.2, 0.6, 0.2))
    } else if (peer_feedback_mode == "state-based") {
      if (env$states[action] %in% c("Socializing", "PhysicalActivity")) {
        1
      } else if (env$states[action] == "Alcohol") {
        -1
      } else {
        0
      }
    } else {
      0
    }
    
    # Q-learning update
    alpha <- alpha_base * exp(-mood_influence * mood_clamped)
    Q[current_state, action] <- Q[current_state, action] +
      alpha * (reward + gamma * max(Q[next_state, ]) - Q[current_state, action])
    
    # Mood update: rumination + social feedback
    mood_reward <- if (reward > 0) rumination_weight_success * reward else rumination_weight_failure * reward
    mood_social <- social_feedback_weight * peer_feedback
    mood_update <- mood_reward + mood_social
    mood <- mood_decay * mood + (1 - mood_decay) * mood_update
    
    # Record
    trajectory[ep, ] <- list(
      Episode = ep,
      State = env$states[current_state],
      Action = env$states[action],
      Reward = reward,
      Mood = mood,
      PeerFeedback = peer_feedback
    )
    
    current_state <- next_state
  }
  trajectory
}

# ---- AGENT PARAMETER SETS ----

params_healthy <- list(
  alpha_base = 0.1,
  mood_decay = 0.95,
  mood_influence = 1.0,
  rumination_weight_success = 0.6,
  rumination_weight_failure = 0.4,
  pessimism = 0.0,
  optimism = 0.1,
  social_feedback_weight = 0.3,
  peer_feedback_mode = "state-based"
)

params_depressed <- list(
  alpha_base = 0.1,
  mood_decay = 0.9,
  mood_influence = 2.0,
  rumination_weight_success = 0.2,
  rumination_weight_failure = 0.8,
  pessimism = 0.3,
  optimism = 0.0,
  social_feedback_weight = 0.5,
  peer_feedback_mode = "state-based"
)

# ---- SIMULATE ----

set.seed(42)
healthy_df <- do.call(simulate_q_agent, c(list(env = env), params_healthy))
healthy_df$Group <- "Healthy"

depressed_df <- do.call(simulate_q_agent, c(list(env = env), params_depressed))
depressed_df$Group <- "Depressed"

combined_df <- bind_rows(healthy_df, depressed_df)

# ---- VISUALIZE ----

# Mood over time
ggplot(combined_df, aes(x = Episode, y = Mood, color = Group)) +
  geom_line(size = 1) +
  labs(title = "Mood Trajectories with Social Influence", y = "Mood") +
  theme_minimal()

# Cumulative reward
combined_df <- combined_df %>%
  group_by(Group) %>%
  mutate(CumulativeReward = cumsum(Reward))

ggplot(combined_df, aes(x = Episode, y = CumulativeReward, color = Group)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward Over Time", y = "Cumulative Reward") +
  theme_minimal()

# State visits
ggplot(combined_df, aes(x = Episode, y = State, color = Group)) +
  geom_point(alpha = 0.5) +
  labs(title = "State Visits Over Time") +
  theme_minimal()

# Peer feedback
ggplot(combined_df, aes(x = Episode, y = PeerFeedback, color = Group)) +
  geom_line(alpha = 0.4) +
  geom_smooth(se = FALSE) +
  labs(title = "Peer Feedback Over Time") +
  theme_minimal()
```
