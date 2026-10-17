---
layout: post
categories: posts
title: Mood, Social Feedback, and Sequential Decision-Making
featured-image: /images/comp01.png
tags: [Computational psychiatry, Decision-Making, Reinforcement learning, Social feedback]
date-string: October 2026
---

# Mood, Social Feedback, and Sequential Decision-Making in Reinforcement Learning

## Introduction

In the previous post, we incorporated mood, asymmetric responses to outcomes, and learned helplessness into reinforcement learning models. Those agents faced a multi-armed bandit, where each choice produced an immediate outcome and left the context of later decisions unchanged. That setup allowed us to study feedback between affect and learning, but it omitted a familiar feature of everyday behavior: actions shape both what happens now and which situations become available next.

Choosing to exercise, socialize, or spend an evening on a screen changes the circumstances of later choices, and it may also draw responses from other people. A computational account of affective decision-making therefore has to separate three things: immediate reward, transitions between behavioral contexts, and social feedback. They can overlap, but they need not act through the same mechanism.

Here we extend the earlier work to a finite-state Markov decision process. Agents move among five activity contexts, learn state-dependent action values with Q-learning, and update mood from both task rewards and peer feedback. Mood, in turn, changes the learning rate. We compare two illustrative parameter profiles, labeled "Healthy" and "Depressed" in the code, which differ in mood persistence, outcome weighting, mood-dependent learning, and sensitivity to social feedback.

These labels describe simulated parameter sets, not validated clinical populations. The model does not show that people with depression learn or respond socially in the ways specified here. Its purpose is narrower: to make assumptions explicit and to examine what follows from them. Two implementation details limit what can be inferred, namely the fixed exploration rate and the inert optimism and pessimism terms discussed below.

## From Bandits to Behavioral States

The environment has five states:

$$
\mathcal{S}=\{\text{ScreenTime},\text{PhysicalActivity},\text{Socializing},\text{Alcohol},\text{Cinema}\}.
$$

The action set uses the same labels. An action is an attempt to move toward an activity, whereas the state is the agent's current context. The distinction matters because actions do not fix the next state.

We write the environment as $\mathcal{M}=(\mathcal{S},\mathcal{A},P,R,\gamma)$, where $P(s'\mid s,a)$ is the transition probability, $R(s,a)$ the immediate reward, and $\gamma=0.9$ the discount factor. Whatever the current state, choosing action $a$ leads to the matching state with probability $0.6$ and to each other state with probability $0.1$:

$$
P(s'\mid s,a)=
\begin{cases}
0.6, & s'=a,\\
0.1, & s'\neq a.
\end{cases}
$$

``` r
transition_probs <- array(0, dim = c(n_states, n_states, n_states))

for (s in 1:n_states) {
  for (a in 1:n_states) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6
    transition_probs[s, , a] <- prob
  }
}
```

Although the environment is sequential, these probabilities do not depend on the current state. Trying to socialize is equally likely to succeed from the couch or from a bar. The model captures imperfect control over the next activity, but not state-dependent barriers to changing activities.

The reward function does depend on the current state. Rows index the current context, columns the selected action:

| Current state    | ScreenTime | PhysicalActivity | Socializing | Alcohol | Cinema |
|------------------|-----------:|-----------------:|------------:|--------:|-------:|
| ScreenTime       |          0 |                1 |           2 |      −2 |      1 |
| PhysicalActivity |          1 |                0 |           2 |      −1 |      2 |
| Socializing      |          2 |                1 |           0 |      −2 |      2 |
| Alcohol          |         −2 |               −1 |           0 |       0 |     −1 |
| Cinema           |          1 |                2 |           2 |      −1 |      0 |

These values define a hypothetical task. They are not empirical estimates of how any activity affects anyone, and the negative values for alcohol and positive values for social or physical activity are modeling choices.

Reward depends on the current state and the intended action, not on the state actually reached:

$$
r_t=R(s_t,a_t).
$$

Selecting Socializing from ScreenTime yields a reward of $2$ even if the stochastic transition lands elsewhere. This separates the value of attempting an activity from success in changing context. If the intended interpretation required successful participation, reward could instead depend on the realized transition, $R(s_t,a_t,s_{t+1})$.

Unlike in a bandit, the agent must weigh immediate reward against the value of the state it is likely to reach. An action with a modest payoff may still be worthwhile if it tends to lead somewhere favorable.

## Learning, Mood, and Social Feedback

The agent keeps an action-value matrix $Q_t(s,a)$, initialized at zero, and updates it with the temporal-difference rule

$$
\delta_t=r_t+\gamma\max_{a'}Q_t(s_{t+1},a')-Q_t(s_t,a_t),
\qquad
Q_{t+1}(s_t,a_t)=Q_t(s_t,a_t)+\alpha_t\delta_t.
$$

Unselected entries are unchanged. Unlike the earlier Bayesian model, there are no posterior distributions or explicit uncertainty estimates, only point estimates and a mood-dependent update rate.

### Mood-dependent learning

Mood is clamped before it affects learning, $\bar m_t=\max(-1,\min(m_t,1))$, and the effective learning rate is

$$
\alpha_t=\alpha_{\text{base}}\exp(-\beta\bar m_t),
$$

where $\beta$ is `mood_influence`. Negative mood raises the learning rate and positive mood lowers it. With $\alpha_{\text{base}}=0.1$, the healthy-like profile ($\beta=1$) ranges from about $0.037$ to $0.272$, and the depressed-like profile ($\beta=2$) from about $0.014$ to $0.739$.

This is not reduced learning under low mood, and it is not selective amplification of negative prediction errors. Low mood increases sensitivity to whatever error comes next, positive or negative. After a bad experience that could speed further downward revision, but after a better-than-expected outcome it could just as easily speed recovery.

Timing matters. Mood before the current outcome sets the learning rate for that outcome. The reward and feedback at time $t$ update mood afterward, so they affect learning only on later steps.

### Action selection and valuation biases

Actions follow an $\epsilon$-greedy policy with $\epsilon=0.1$. With probability $0.1$ the agent picks uniformly among the five actions. Otherwise it picks the action with the highest transformed value

$$
\widetilde Q_t(s,a)=Q_t(s,a)+o-p\bigl(1-Q_t(s,a)\bigr),
$$

with $o$ and $p$ denoting optimism and pessimism. This simplifies to

$$
\widetilde Q_t(s,a)=(1+p)Q_t(s,a)+(o-p).
$$

For $1+p>0$ the transformation is a positive affine map, so $\arg\max_a\widetilde Q_t(s,a)=\arg\max_a Q_t(s,a)$. The two parameters therefore have no behavioral effect here, and they do not enter the Q-update either. A model in which pessimism shifts initial beliefs, subjective rewards, or expected transition success could change behavior, but this one does not. We keep the parameters in the code to make that point concrete.

Exploration is also independent of mood. Both agents share the same $\epsilon$, so differences between them cannot come from a programmed increase in random exploration under negative affect. Ties among maximal values are broken at random. R's `which.max()` would instead always return the first index, and since all values start at zero, that would send early non-exploratory choices to ScreenTime by convention rather than preference.

### Socially informed mood

Peer feedback feeds mood but not the task reward. In the default action-based mode,

$$
F(a_t)=
\begin{cases}
1, & a_t\in\{\text{Socializing},\text{PhysicalActivity}\},\\
-1, & a_t=\text{Alcohol},\\
0, & \text{otherwise}.
\end{cases}
$$

Feedback depends on the selected action, not the realized next state. A random mode is also available, drawing from $\{-1,0,1\}$ with probabilities $0.2$, $0.6$, and $0.2$.

Reward enters mood through an asymmetric weighting,

$$
g(r_t)=
\begin{cases}
w_+r_t, & r_t>0,\\
w_-r_t, & r_t<0,\\
0, & r_t=0,
\end{cases}
$$

and mood evolves as

$$
m_{t+1}=\lambda m_t+(1-\lambda)\bigl[g(r_t)+\omega F(a_t)\bigr],
$$

where $\lambda$ sets affective persistence and $\omega$ sensitivity to feedback. The resulting pathway is indirect:

$$
a_t\rightarrow F(a_t)\rightarrow m_{t+1}\rightarrow\alpha_{t+1}\rightarrow Q_{t+2}.
$$

Social approval changes later learning only through mood. It is not part of the temporal-difference target, and the agent does not learn a separate value for approval.

The weights $w_+$ and $w_-$ describe asymmetric outcome weighting. They are not a model of rumination, which would require something like memory replay or sustained attention to a particular negative event. The model has neither.

## Simulation and Interpretation

The two profiles differ in several parameters at once:

| Parameter                                  | Healthy-like | Depressed-like |
|--------------------------------------------|-------------:|---------------:|
| Base learning rate, $\alpha_{\text{base}}$ |          0.1 |            0.1 |
| Mood persistence, $\lambda$                |         0.95 |           0.90 |
| Mood influence on learning, $\beta$        |          1.0 |            2.0 |
| Positive outcome weight, $w_+$             |          0.6 |            0.2 |
| Negative outcome weight, $w_-$             |          0.4 |            0.8 |
| Social feedback weight, $\omega$           |          0.3 |            0.5 |
| Pessimism, $p$ (inert)                     |          0.0 |            0.3 |
| Optimism, $o$ (inert)                      |          0.1 |            0.0 |

Both use action-based feedback, $\gamma=0.9$, and $\epsilon=0.1$. The depressed-like profile gives less weight to positive outcomes and more to negative ones. Its larger $\omega$ raises responsiveness to approval and disapproval alike, so it does not encode sensitivity to rejection specifically.

A worked example separates these effects. From ScreenTime, selecting Socializing gives $r_t=2$ and $F=1$. The mood input is $0.6(2)+0.3(1)=1.5$ for the healthy-like agent and $0.2(2)+0.5(1)=0.9$ for the depressed-like agent. From neutral mood the one-step changes are $0.05(1.5)=0.075$ and $0.1(0.9)=0.09$. The depressed-like agent shows the larger immediate rise because its lower $\lambda$ gives more weight to the current input. A smaller positive reward weight does not by itself imply a smaller one-step response.

Selecting Alcohol from the same state gives $r_t=-2$ and $F=-1$. The inputs are $0.4(-2)+0.3(-1)=-1.1$ and $0.8(-2)+0.5(-1)=-2.1$, so the initial changes are $-0.055$ and $-0.21$. Here stronger negative weighting, greater feedback sensitivity, and faster adjustment all point the same way.

Lower $\lambda$ means faster adaptation, not necessarily greater volatility, since observed fluctuations also depend on the sequence and size of outcomes.

### What the figures can show

The script produces one trajectory per profile over 200 decision steps. The agent is never reset and no terminal state exists, so these are continuing-task time steps, not 200 independent episodes. Four plots are generated:

-   Mood: the accumulated affective response to outcomes and feedback.
-   Cumulative reward: undiscounted task performance, although Q-learning optimizes a discounted objective.
-   State visits: where the agent actually arrives, which need not match what it chose.
-   Cumulative peer feedback: the output of a prescribed approval rule, not of an adapting social partner.

A single trajectory per group, from one seed and one random starting state, is weak evidence. The replication code in the full script addresses this. Matching seeds across groups helps organize comparisons but does not guarantee identical environmental experience once policies diverge. Replication estimates simulation variability and says nothing about clinical populations.

### Limitations and next steps

The model's contribution is the coupling of activity selection, social evaluation, mood, and learning in one transparent sequential framework. It does not show that these profiles reproduce depression.

Several assumptions deserve testing. Social feedback is externally prescribed and identical across profiles, so there are no reciprocal relationships, disagreeing peers, or uncertainty about others' intentions. Mood depends on weighted reward levels, not prediction errors, so a good outcome lifts mood equally whether expected or surprising. This differs from Eldar and colleagues' account of mood as momentum in prediction errors (2016), and a prediction-error version would be a natural contrast. The agent also learns values over activity states without representing mood as part of the state, even though mood alters the learning dynamics.

The comparison changes several parameters at once, so differences in outcomes cannot be tied to one mechanism. Varying $\omega$ with outcome weights fixed would isolate the social pathway, and varying $\beta$ with mood dynamics fixed would isolate mood-dependent learning. If optimism and pessimism are meant to influence choice, they need reformulating as action-specific priors, biased perceived rewards, or altered beliefs about transition success. These imply different empirical predictions and are not interchangeable.

Clinical interpretation would require estimating parameters from behavioral and mood data. For now the simulation offers hypotheses: social feedback may alter later learning through affect, asymmetric weighting may shape mood trajectories, and mood-dependent learning may either entrench unfavorable evaluations or speed their correction. Which pathway dominates is an empirical question.

## References

Eldar, E., Rutledge, R. B., Dolan, R. J., & Niv, Y. (2016). Mood as representation of momentum. *Trends in Cognitive Sciences, 20*(1), 15–24. <https://doi.org/10.1016/j.tics.2015.07.010>

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience, 38*, 1–23. <https://doi.org/10.1146/annurev-neuro-071714-033928>

Watkins, C. J. C. H., & Dayan, P. (1992). Q-learning. *Machine Learning, 8*, 279–292. <https://doi.org/10.1007/BF00992698>

## Full Code

The script simulates a mood-sensitive Q-learning agent in a five-state behavioral environment. Mood is updated from asymmetrically weighted rewards and prescribed peer feedback, and it scales the learning rate. Two parameter profiles are compared over 200 steps, then replicated across 100 seeds. The profiles are illustrative and do not represent clinical groups.

``` r
library(ggplot2)
library(dplyr)

# ---- ENVIRONMENT ----

states   <- c("ScreenTime", "PhysicalActivity", "Socializing", "Alcohol", "Cinema")
n_states <- length(states)

transition_probs <- array(0, dim = c(n_states, n_states, n_states))
for (s in 1:n_states) {
  for (a in 1:n_states) {
    prob <- rep(0.1, n_states)
    prob[a] <- 0.6
    transition_probs[s, , a] <- prob
  }
}

rewards <- matrix(c(
   0,  1,  2, -2,  1,   # ScreenTime
   1,  0,  2, -1,  2,   # PhysicalActivity
   2,  1,  0, -2,  2,   # Socializing
  -2, -1,  0,  0, -1,   # Alcohol
   1,  2,  2, -1,  0    # Cinema
), nrow = n_states, byrow = TRUE)

env <- list(states = states, transition_probs = transition_probs, rewards = rewards)

# ---- HELPERS ----

argmax_random <- function(x, tol = 1e-12) {
  idx <- which(x >= max(x) - tol)
  idx[sample.int(length(idx), 1)]
}

peer_feedback <- function(action, states, mode = c("action_based", "random")) {
  mode <- match.arg(mode)
  if (mode == "random") {
    return(sample(c(-1, 0, 1), 1, prob = c(0.2, 0.6, 0.2)))
  }
  a <- states[action]
  if (a %in% c("Socializing", "PhysicalActivity")) 1
  else if (a == "Alcohol") -1
  else 0
}

# ---- AGENT ----

simulate_q_agent <- function(
    env,
    n_steps = 200,
    alpha_base = 0.1,
    gamma = 0.9,
    epsilon = 0.1,
    mood_decay = 0.95,
    mood_influence = 1.0,
    w_pos = 0.5,
    w_neg = 0.5,
    social_weight = 0.3,
    feedback_mode = "action_based",
    pessimism = 0.0,
    optimism = 0.0
) {
  n_s <- nrow(env$transition_probs)
  n_a <- length(env$states)
  Q <- matrix(0, nrow = n_s, ncol = n_a)
  mood <- 0
  state <- sample.int(n_s, 1)

  out <- data.frame(
    Step = seq_len(n_steps), State = NA_character_, Action = NA_character_,
    Reward = NA_real_, Feedback = NA_real_, Alpha = NA_real_, Mood = NA_real_
  )

  for (t in seq_len(n_steps)) {
    biased_Q <- Q[state, ] + optimism - pessimism * (1 - Q[state, ])  # rank-preserving
    action <- if (runif(1) < epsilon) sample.int(n_a, 1) else argmax_random(biased_Q)

    next_state <- sample.int(n_s, 1, prob = env$transition_probs[state, , action])
    reward <- env$rewards[state, action]

    # mood before this outcome sets the learning rate
    alpha <- alpha_base * exp(-mood_influence * max(min(mood, 1), -1))
    Q[state, action] <- Q[state, action] +
      alpha * (reward + gamma * max(Q[next_state, ]) - Q[state, action])

    # mood update from reward and peer feedback
    fb <- peer_feedback(action, env$states, feedback_mode)
    mood_reward <- if (reward > 0) w_pos * reward else if (reward < 0) w_neg * reward else 0
    mood <- mood_decay * mood + (1 - mood_decay) * (mood_reward + social_weight * fb)

    out[t, c("State", "Action", "Reward", "Feedback", "Alpha", "Mood")] <-
      list(env$states[state], env$states[action], reward, fb, alpha, mood)

    state <- next_state
  }
  out
}

# ---- PARAMETERS ----

params_healthy <- list(
  alpha_base = 0.1, mood_decay = 0.95, mood_influence = 1.0,
  w_pos = 0.6, w_neg = 0.4, social_weight = 0.3,
  pessimism = 0.0, optimism = 0.1
)

params_depressed <- list(
  alpha_base = 0.1, mood_decay = 0.90, mood_influence = 2.0,
  w_pos = 0.2, w_neg = 0.8, social_weight = 0.5,
  pessimism = 0.3, optimism = 0.0
)

# ---- SINGLE TRAJECTORY PER PROFILE ----

set.seed(42)
healthy_df   <- do.call(simulate_q_agent, c(list(env = env), params_healthy))
healthy_df$Group <- "Healthy"
depressed_df <- do.call(simulate_q_agent, c(list(env = env), params_depressed))
depressed_df$Group <- "Depressed"

combined_df <- bind_rows(healthy_df, depressed_df) %>%
  group_by(Group) %>%
  mutate(CumulativeReward   = cumsum(Reward),
         CumulativeFeedback = cumsum(Feedback)) %>%
  ungroup()

# ---- FIGURES ----

ggplot(combined_df, aes(Step, Mood, color = Group)) +
  geom_line(linewidth = 1) +
  labs(title = "Mood Trajectories", y = "Mood") + theme_minimal()

ggplot(combined_df, aes(Step, CumulativeReward, color = Group)) +
  geom_line(linewidth = 1) +
  labs(title = "Cumulative Reward", y = "Cumulative reward") + theme_minimal()

ggplot(combined_df, aes(Step, State, color = Group)) +
  geom_point(alpha = 0.5, size = 2) +
  labs(title = "State Visits") + theme_minimal()

ggplot(combined_df, aes(Step, CumulativeFeedback, color = Group)) +
  geom_line(linewidth = 1) +
  labs(title = "Cumulative Peer Feedback", y = "Cumulative feedback") + theme_minimal()

# ---- REPLICATION ----

run_replicates <- function(params, group, n_agents = 100, n_steps = 200) {
  bind_rows(lapply(seq_len(n_agents), function(i) {
    set.seed(1000 + i)
    df <- do.call(simulate_q_agent, c(list(env = env, n_steps = n_steps), params))
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
  summarise(TotalReward = sum(Reward),
            MeanMood    = mean(Mood),
            MoodSD      = sd(Mood),
            .groups = "drop")

agent_summary %>%
  group_by(Group) %>%
  summarise(across(c(TotalReward, MeanMood, MoodSD),
                   list(mean = mean, sd = sd), .names = "{.col}_{.fn}"))
```
