---
layout: post
categories: posts
title: Mood, Social Feedback, and Sequential Decision-Making
tags: [Computational psychiatry, Decision-Making, Reinforcement learning, Social feedback]
date-string: October 2026
---

# Mood, Social Feedback, and Sequential Decision-Making in Reinforcement Learning

## Introduction

In the previous post, we explored how mood, asymmetric responses to outcomes, and learned helplessness can be incorporated into reinforcement learning models. Our agents interacted with a multi-armed bandit environment, where each choice produced an immediate outcome without changing the context of subsequent decisions. That framework allowed us to examine feedback between affect and learning, but it left out an important feature of everyday behavior: actions influence not only what happens now, but also which situations become available next.

Choosing to exercise, socialize, or spend time on a screen can alter the circumstances in which later decisions occur. These choices may also elicit responses from other people. A computational account of affective decision-making therefore needs to distinguish immediate reward, transitions between behavioral contexts, and social feedback. Their effects can overlap, but they need not operate through the same mechanism.

Here we extend the earlier posts to a finite-state Markov decision process. Agents move among five activity contexts, learn state-dependent action values through Q-learning, and update mood using both task rewards and peer feedback. Mood, in turn, changes the learning rate. We compare two illustrative parameterizations, labeled “Healthy” and “Depressed” in the code, that differ in affective persistence, outcome weighting, mood-dependent learning, and sensitivity to social feedback.

These labels describe simulated parameter profiles rather than validated clinical populations. The model does not establish that people with depression learn or respond socially in the ways specified here. Its purpose is narrower: to make assumptions explicit and examine their computational consequences. Several details of the implementation also constrain what we can infer, particularly the fixed exploration rate and the proposed pessimism and optimism terms.

## From Bandits to Behavioral States

The environment consists of five states:

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

The action set uses the same labels. An action represents an attempt to move toward a particular activity, whereas the state represents the agent’s current context. The distinction matters because actions do not determine the next state with certainty.

We write the environment as

$$
\mathcal{M}
=
(\mathcal{S},\mathcal{A},P,R,\gamma),
$$

where $P(s'\mid s,a)$ is the transition probability, $R(s,a)$ is the immediate reward, and $\gamma$ discounts future rewards. In this implementation, $\gamma=0.9$.

For every current state, choosing action $a$ gives a probability of $0.6$ of entering the corresponding state and a probability of $0.1$ of entering each alternative:

$$
P(s'\mid s,a)
=
\begin{cases}
0.6, & s'=a,\\
0.1, & s'\neq a.
\end{cases}
$$

The R code constructs this transition structure as follows:

``` r
transition_probs <- array(
  0, dim = c(n_states, n_states, n_states)
)

for (s in 1:n_states) {
  for (a in 1:n_states) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6
    transition_probs[s, , a] <- prob / sum(prob)
  }
}
```

Although this is a sequential environment, the transition probabilities do not depend on the current state. Attempting to socialize has the same probability of reaching the socializing state whether the agent is currently exercising or drinking alcohol. The model therefore represents imperfect control over the next activity, but not state-dependent barriers to changing activities.

The reward function does depend on the current state. Its rows index current contexts and its columns index selected actions:

| Current state    | ScreenTime | PhysicalActivity | Socializing | Alcohol | Cinema |
|------------------|-----------:|-----------------:|------------:|--------:|-------:|
| ScreenTime       |          0 |                1 |           2 |      −2 |      1 |
| PhysicalActivity |          1 |                0 |           2 |      −1 |      2 |
| Socializing      |          2 |                1 |           0 |      −2 |      2 |
| Alcohol          |         −2 |               −1 |           0 |       0 |     −1 |
| Cinema           |          1 |                2 |           2 |      −1 |      0 |

These values define a hypothetical task rather than empirical estimates of the psychological effects of each activity. In particular, the negative rewards assigned to alcohol and the positive rewards assigned to several social or physical activities are modeling choices. They should not be interpreted as universal valuations.

Reward is determined by the current state and intended action, not by the state actually reached:

$$
r_t=R(s_t,a_t).
$$

For example, selecting Socializing from ScreenTime produces a reward of $2$, even if the stochastic transition takes the agent elsewhere. This separates the immediate value of an attempted activity from its success in changing the next context. An alternative model could make reward depend on the realized transition, $R(s_t,a_t,s_{t+1})$, if the intended interpretation required successful participation.

Unlike a bandit, the agent must now consider both immediate reward and the value of the resulting state. An action with a modest immediate payoff may still be useful if it tends to lead toward a context with favorable future opportunities.

## Learning, Mood, and Social Feedback

The agent maintains an action-value matrix $Q_t(s,a)$, initialized to zero. Each entry estimates the discounted return associated with selecting action $a$ in state $s$. Learning follows the temporal-difference update

$$
\delta_t
=
r_t
+
\gamma\max_{a'}Q_t(s_{t+1},a')
-
Q_t(s_t,a_t),
$$

$$
Q_{t+1}(s_t,a_t)
=
Q_t(s_t,a_t)+\alpha_t\delta_t.
$$

All unselected entries remain unchanged. Unlike the previous Bayesian model, this implementation does not maintain posterior distributions or explicit uncertainty estimates. It uses point estimates of action values and a mood-dependent update rate.

### Mood-dependent learning

Mood is clamped before it influences learning:

$$
\bar m_t
=
\max(-1,\min(m_t,1)).
$$

The effective learning rate is

$$
\alpha_t
=
\alpha_{\text{base}}
\exp(-\beta\bar m_t),
$$

where $\beta$ corresponds to `mood_influence`.

``` r
mood_clamped <- max(min(mood, 1), -1)

alpha <- alpha_base *
  exp(-mood_influence * mood_clamped)

Q[current_state, action] <- Q[current_state, action] +
  alpha * (
    reward +
    gamma * max(Q[next_state, ]) -
    Q[current_state, action]
  )
```

This equation has a specific directional implication: negative mood increases the learning rate, while positive mood decreases it. With $\alpha_{\text{base}}=0.1$, the healthy-like profile has an effective learning-rate range of approximately $0.037$ to $0.272$. The depressed-like profile, with $\beta=2$, has a wider range of approximately $0.014$ to $0.739$.

The mechanism therefore does not implement reduced learning under negative mood. Nor does it selectively increase learning from negative prediction errors. Negative mood increases sensitivity to whichever temporal-difference error occurs next, whether positive or negative. Following an unfavorable experience, this could accelerate further downward revisions of value, but it could also accelerate recovery when a better-than-expected outcome follows.

Mood before the current outcome determines the learning rate for that outcome. The reward and peer feedback observed at time $t$ update mood afterward and consequently influence learning on later steps.

### Action selection and valuation biases

Actions are selected using an $\epsilon$-greedy policy with $\epsilon=0.1$. With probability $0.1$, the agent samples uniformly from all five actions; otherwise, it selects the action with the highest transformed value:

$$
\widetilde Q_t(s,a)
=
Q_t(s,a)+o-p\bigl(1-Q_t(s,a)\bigr),
$$

where $o$ and $p$ denote optimism and pessimism.

A useful algebraic simplification reveals a limitation:

$$
\widetilde Q_t(s,a)
=
(1+p)Q_t(s,a)+(o-p).
$$

For the parameter values used here, $1+p>0$. The transformation therefore preserves action rankings:

$$
\arg\max_a\widetilde Q_t(s,a)
=
\arg\max_a Q_t(s,a).
$$

The optimism and pessimism parameters do not change greedy choices. They also do not affect the Q-learning update, which uses the original $Q$-values. Under this implementation, these parameters have no behavioral effect.

This is worth distinguishing from a model in which pessimism changes initial beliefs, subjective rewards, or expectations about future transitions. Those mechanisms could alter behavior, but they are not implemented by a positive affine transformation followed by an argmax policy.

Exploration is also independent of mood. Both agents use the same fixed $\epsilon$, so differences between their trajectories cannot be attributed to a programmed increase in random exploration under negative affect. When values tie, R’s `which.max()` selects the first maximum. Because all values initially equal zero, the first non-exploratory choice favors ScreenTime by indexing convention rather than preference.

### Socially informed mood

Peer feedback contributes to mood but not directly to task reward. Under the state-based mode used in both simulations,

$$
F(a_t)
=
\begin{cases}
1, & a_t\in\{\text{Socializing},\text{PhysicalActivity}\},\\
-1, & a_t=\text{Alcohol},\\
0, & \text{otherwise}.
\end{cases}
$$

Despite its name, this mode is action-based: feedback depends on the selected action, not the realized next state. The code also permits random feedback drawn from $\{-1,0,1\}$ with probabilities $0.2$, $0.6$, and $0.2$, respectively.

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

Mood then evolves according to

$$
m_{t+1}
=
\lambda m_t
+
(1-\lambda)
\left[g(r_t)+\omega F(a_t)\right],
$$

where $\lambda$ controls affective persistence and $\omega$ controls sensitivity to feedback.

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

The resulting feedback pathway is indirect:

$$
a_t
\longrightarrow
F(a_t)
\longrightarrow
m_{t+1}
\longrightarrow
\alpha_{t+1}
\longrightarrow
Q_{t+2}.
$$

Social approval changes subsequent learning through mood. It is not added to the reward in the temporal-difference target, and the agent does not explicitly learn a separate value function for social approval.

The “rumination” parameters likewise describe asymmetric outcome weighting rather than repeated mental rehearsal. The model contains no memory replay or sustained attention to a particular negative event. Asymmetry is a useful abstraction, but it should not be equated with a complete mechanism of rumination.

## Simulation and Interpretation

The two profiles differ across several parameters:

| Parameter                                  | Healthy-like | Depressed-like |
|--------------------------------------------|-------------:|---------------:|
| Base learning rate, $\alpha_{\text{base}}$ |          0.1 |            0.1 |
| Mood persistence, $\lambda$                |         0.95 |           0.90 |
| Mood influence on learning, $\beta$        |          1.0 |            2.0 |
| Positive outcome weight, $w_+$             |          0.6 |            0.2 |
| Negative outcome weight, $w_-$             |          0.4 |            0.8 |
| Social feedback weight, $\omega$           |          0.3 |            0.5 |
| Pessimism, $p$                             |          0.0 |            0.3 |
| Optimism, $o$                              |          0.1 |            0.0 |

Both simulations use state-based feedback, $\gamma=0.9$, and $\epsilon=0.1$. The depressed-like profile assigns less affective weight to positive outcomes and more weight to negative outcomes. Its larger social feedback coefficient increases responsiveness to both approval and disapproval; it does not selectively encode sensitivity to rejection.

A concrete example helps separate these effects. From ScreenTime, selecting Socializing yields $r_t=2$ and $F(a_t)=1$. The healthy-like mood input is

$$
0.6(2)+0.3(1)=1.5,
$$

whereas the depressed-like input is

$$
0.2(2)+0.5(1)=0.9.
$$

However, starting from neutral mood, the immediate changes are $0.05(1.5)=0.075$ and $0.1(0.9)=0.09$, respectively. The depressed-like agent initially shows the larger mood increase because its lower persistence parameter gives more weight to the current input. A smaller positive reward weight does not, by itself, imply a smaller one-step affective response.

For the same state, selecting Alcohol produces $r_t=-2$ and feedback of $-1$. The mood inputs become $-1.1$ and $-2.1$, giving initial mood changes of $-0.055$ and $-0.21$. Here, stronger negative weighting, greater feedback sensitivity, and faster mood adjustment all act in the same direction.

Lower $\lambda$ means faster adaptation and less persistence of previous mood. It does not independently establish greater volatility: observed fluctuations also depend on the sequence and magnitude of outcomes.

### What the figures establish

The script generates one trajectory per profile over 200 decision steps. Although the variable is named `n_episodes`, the agent is not reset after each step, and no terminal state is defined. These are therefore continuing-task time steps rather than 200 independent episodes.

The four plots describe complementary aspects of those trajectories. Mood records the accumulated affective response to outcomes and feedback. Cumulative reward measures undiscounted task performance, although Q-learning uses a discounted objective. State visits show where the agent actually arrives, which need not match its selected actions. Peer feedback reflects the action sequence under the prescribed approval rule; it does not represent an independently adapting social partner.

Without executing the script, we should not assign numerical endpoints or claim a particular ordering of the reward curves. More importantly, even a visible difference between the two plotted trajectories would not establish a reliable group effect. The agents encounter different stochastic transitions and exploratory choices, and each profile is represented by only one realization.

A modest extension would replicate the simulation across seeds and retain an agent identifier:

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

reward_summary <- replicated_df %>%
  group_by(Group, Agent) %>%
  summarise(
    TotalReward = sum(Reward),
    MeanMood = mean(Mood),
    .groups = "drop"
  )
```

Using corresponding seeds helps organize comparisons, but does not guarantee identical environmental experiences once policies diverge. Replication would estimate simulation variability; it would still not provide evidence about clinical populations.

### Limitations and next steps

The present model couples activity selection, social evaluation, mood, and learning within a transparent sequential framework. Its main contribution is this coupling, rather than a demonstration that the chosen profiles reproduce depression.

Several assumptions deserve further testing. Social feedback is externally prescribed and identical across profiles, so the environment contains no reciprocal relationships, disagreement between peers, or uncertainty about another person’s intentions. Mood depends on weighted reward levels rather than prediction errors, making a favorable outcome equally mood-enhancing whether expected or surprising. The agent also learns values over activity states without explicitly representing mood as part of the state, even though mood changes the learning dynamics.

A useful next analysis would vary mechanisms separately. Holding outcome weights constant while changing social sensitivity would isolate one pathway; holding mood dynamics constant while changing $\beta$ would isolate another. In contrast, the current comparison changes several parameters simultaneously, so any difference in performance cannot be attributed to a single mechanism.

The optimism and pessimism terms require particular revision if they are intended to influence choice. Action-specific priors, biased perceived rewards, or altered beliefs about transition success would provide more consequential formulations. These alternatives would also imply different empirical predictions and should not be treated as interchangeable.

Finally, the parameter profiles would need estimation from behavioral and mood data before supporting clinical interpretations. The current simulation offers a set of explicit hypotheses: social feedback may alter later learning through affect, asymmetric outcome weighting may shape mood trajectories, and mood-dependent learning may either reinforce unfavorable evaluations or accelerate their correction. Which pathway dominates remains a question for simulation analysis and empirical testing.

## References

Eldar, E., Rutledge, R. B., Dolan, R. J., & Niv, Y. (2016). Mood as representation of momentum. *Trends in Cognitive Sciences, 20*(1), 15–24. <https://doi.org/10.1016/j.tics.2015.07.010> [pubmed.ncbi.nlm.nih](https://pubmed.ncbi.nlm.nih.gov/26545853/)

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience, 38*, 1–23. <https://doi.org/10.1146/annurev-neuro-071714-033928> [tnu.ethz](https://www.tnu.ethz.ch/fileadmin/user_upload/documents/Publications/2015/2015_Huys_Daw_Dayan.pdf)

Watkins, C. J. C. H., & Dayan, P. (1992). Q-learning. *Machine Learning, 8*, 279–292. <https://doi.org/10.1007/BF00992698> [link.springer](https://link.springer.com/article/10.1007/BF00992698)

## Full Code

The provided R code implements a simulation of a mood-sensitive Q-learning agent operating within a stylized behavioral environment consisting of five states: ScreenTime, PhysicalActivity, Socializing, Alcohol, and Cinema. Each state serves both as a context and as a potential action target. Transition probabilities are constructed to favor self-directed actions, while a predefined reward matrix reflects the desirability of each action-state pairing. The agent, governed by mood-dependent learning dynamics, adapts its behavior across 200 episodes using a Reinforcement Learning algorithm that incorporates traditional parameters (learning rate, discount factor, and exploration rate), as well as psychological constructs such as rumination and Emotional Valence. Two distinct agent profiles—"Healthy" and "Depressed"—are defined through differing parameterizations of mood decay, rumination weights, and affective biases. The simulation captures how mood influences decision-making and learning, with trajectories logged for subsequent analysis. Visualizations illustrate the evolution of mood, cumulative reward acquisition, and state visitation patterns, revealing the behavioral divergence between the two agent profiles. This framework enables the investigation of affective-cognitive interactions in Reinforcement Learning and offers a computational lens through which mood disorders might be modeled and better understood.

``` r
set.seed(123)
library(ggplot2)
library(reshape2)
library(dplyr)

# ---- ENVIRONMENT SETUP ----

states <- c("ScreenTime", "PhysicalActivity", "Socializing", "Alcohol", "Cinema")
n_states <- length(states)
actions <- 1:n_states

# Transition probabilities: [from_state, to_state, action]
transition_probs <- array(0, dim = c(n_states, n_states, n_states))
for (s in 1:n_states) {
  for (a in 1:n_states) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6  # High chance of transitioning to action-related state
    transition_probs[s, , a] <- prob / sum(prob)
  }
}

# Rewards for each [state, action]
rewards <- matrix(c(
  0, 1, 2, -2, 1,   # ScreenTime
  1, 0, 2, -1, 2,   # PhysicalActivity
  2, 1, 0, -2, 2,   # Socializing
  -2, -1, 0, 0, -1,  # Alcohol
  1, 2, 2, -1, 0    # Cinema
), nrow = n_states, byrow = TRUE)

env <- list(
  states = states,
  transition_probs = transition_probs,
  rewards = rewards
)

# ---- Q-LEARNING AGENT FUNCTION ----

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
    optimism = 0.0
) {
  n_states <- nrow(env$transition_probs)
  n_actions <- length(env$states)
  Q <- matrix(0, nrow = n_states, ncol = n_actions)
  mood <- 0
  current_state <- sample(1:n_states, 1)
  
  trajectory <- data.frame(
    Episode = integer(n_episodes),
    State = character(n_episodes),
    Action = character(n_episodes),
    Reward = numeric(n_episodes),
    Mood = numeric(n_episodes)
  )
  
  for (ep in 1:n_episodes) {
    mood_clamped <- max(min(mood, 1), -1)
    
    biased_Q <- Q[current_state, ] + optimism - pessimism * (1 - Q[current_state, ])
    
    if (runif(1) < epsilon) {
      action <- sample(1:n_actions, 1)
    } else {
      action <- which.max(biased_Q)
    }
    
    next_state <- sample(1:n_states, 1, prob = env$transition_probs[current_state, , action])
    reward <- env$rewards[current_state, action]
    
    # Mood-influenced learning rate
    alpha <- alpha_base * exp(-mood_influence * mood_clamped)
    
    # Q-learning update
    Q[current_state, action] <- Q[current_state, action] + 
      alpha * (reward + gamma * max(Q[next_state, ]) - Q[current_state, action])
    
    # Rumination-based mood update
    if (reward > 0) {
      mood_update <- rumination_weight_success * reward
    } else if (reward < 0) {
      mood_update <- rumination_weight_failure * reward
    } else {
      mood_update <- 0
    }
    mood <- mood_decay * mood + (1 - mood_decay) * mood_update
    
    # Record trajectory
    trajectory[ep, ] <- list(
      Episode = ep,
      State = env$states[current_state],
      Action = env$states[action],
      Reward = reward,
      Mood = mood
    )
    
    current_state <- next_state
  }
  trajectory
}

# ---- AGENT PARAMETERS ----

params_healthy <- list(
  alpha_base = 0.1,
  mood_decay = 0.95,
  mood_influence = 1.0,
  rumination_weight_success = 0.6,
  rumination_weight_failure = 0.4,
  pessimism = 0.0,
  optimism = 0.1
)

params_depressed <- list(
  alpha_base = 0.1,
  mood_decay = 0.9,
  mood_influence = 2.0,
  rumination_weight_success = 0.2,
  rumination_weight_failure = 0.8,
  pessimism = 0.3,
  optimism = 0.0
)

# ---- SIMULATION ----

set.seed(42)
healthy_df <- do.call(simulate_q_agent, c(list(env = env), params_healthy))
healthy_df$Group <- "Healthy"

depressed_df <- do.call(simulate_q_agent, c(list(env = env), params_depressed))
depressed_df$Group <- "Depressed"

combined_df <- bind_rows(healthy_df, depressed_df)

# ---- VISUALIZATION ----

# Mood plot
ggplot(combined_df, aes(x = Episode, y = Mood, color = Group)) +
  geom_line(size = 1) +
  labs(title = "Mood Trajectories", y = "Mood") +
  theme_minimal()

# Cumulative reward plot
combined_df <- combined_df %>%
  group_by(Group) %>%
  mutate(CumulativeReward = cumsum(Reward))

ggplot(combined_df, aes(x = Episode, y = CumulativeReward, color = Group)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward Over Time", y = "Cumulative Reward") +
  theme_minimal()

# State transitions
ggplot(combined_df, aes(x = Episode, y = State, color = Group)) +
  geom_point(alpha = 0.5, size = 2) +
  labs(title = "State Visits Over Time") +
  theme_minimal()
```
