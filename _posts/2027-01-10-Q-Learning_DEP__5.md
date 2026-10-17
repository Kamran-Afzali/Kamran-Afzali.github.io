---
layout: post
categories: posts
title: Identity as a Slow Variable in Mood-Sensitive Reinforcement Learning
tags: [Computational psychiatry, Decision-making, Reinforcement learning, Identity, Social feedback]
date-string: October 2026
---

# Identity as a Slow Variable in Mood-Sensitive Reinforcement Learning

## Introduction

The earlier posts in this series treated mood as a fast variable that tracks recent outcomes and, in some versions, rescales the learning rate. Parameters such as outcome weighting or sensitivity to feedback were fixed for the whole simulation. That is convenient, but it sits uneasily with how people talk about traits, which are supposed to be stable yet not immutable. A tendency to dwell on bad outcomes may itself be shaped by a history of bad outcomes.

Here we add a slower layer. Three "identity" quantities (rumination bias, social sensitivity, and goal orientation) are updated by experience and in turn shape how outcomes are converted into mood. The agent still learns action values with Q-learning, now with an asymmetric learning rate governed by an optimism parameter.

The labels are borrowed from psychology, but the quantities are simple state variables with hand-chosen update rules. Nothing here is fitted to data, and a simulated agent drifting toward a "ruminative" setting says little about how rumination develops in people. The more useful question is narrower: what does this particular set of assumptions do, and what does it fail to do?

I should say at the outset that this version differs from the previous ones in ways that matter. Mood no longer modulates learning, the transitions ignore the chosen action, and reward depends on the state reached rather than the state left. Those changes are discussed below, because they determine what the simulations can show.

## The Environment

There are five states: screen time, physical activity, socializing, alcohol use, and cinema. Transitions are uniform, so the next state is drawn with probability $1/5$ regardless of the current state or the action:

$$
P(s'\mid s,a)=\tfrac{1}{5}.
$$

Reward is a function of the state reached:

$$
r_t=R(s_{t+1}),\qquad
R=\{-0.5,\;1.0,\;0.8,\;-1.0,\;0.5\}
$$

in the order listed above. Peer feedback is also tied to the state reached. Arriving in socializing yields feedback drawn from $U(-1,1)$, arriving in alcohol use yields $U(-0.5,0.5)$, and every other state yields zero. Both distributions are symmetric around zero, so feedback has no average direction. It adds variability to mood and, as we will see, to one of the traits, but it carries no systematic approval or disapproval.

A consequence follows immediately, and it shapes everything else. Because the next state is independent of the action, the agent cannot influence what happens to it. Expected reward per step is $(-0.5+1.0+0.8-1.0+0.5)/5=0.16$ whatever policy is followed. In this respect the environment resembles an uncontrollable setting, which is a different thing from the controllable sequential task used earlier.

## Learning with an Optimism Parameter

The agent keeps a $5\times5$ matrix $Q$, initialized at zero, and uses an $\epsilon$-greedy policy with $\epsilon=0.1$. The temporal-difference error is the standard one,

$$
\delta_t=r_t+\gamma\max_{a'}Q(s_{t+1},a')-Q(s_t,a_t),\qquad \gamma=0.9,
$$

but the update rate depends on the sign of $\delta_t$:

$$
Q(s_t,a_t)\leftarrow Q(s_t,a_t)+
\begin{cases}
\alpha_{\text{base}}\,\kappa\,\delta_t, & \delta_t>0,\\[2pt]
\alpha_{\text{base}}\,(2-\kappa)\,\delta_t, & \delta_t\le 0,
\end{cases}
$$

where $\kappa$ is the `optimism` argument. At $\kappa=1$ the two rates coincide. Values above 1 weight positive errors more heavily, and values below 1 weight negative errors more heavily. This is a more consequential mechanism than the additive optimism and pessimism terms of the previous post, which turned out to leave the argmax unchanged. Here the asymmetry changes what the agent learns.

All simulated agents in the script use the default $\kappa=1$, so the asymmetric branch is present but inactive. I mention it because a reader could reasonably assume that optimism varies across agents. It does not.

Mood does not appear anywhere in this update. That is a real departure from the earlier posts, in which negative mood raised the learning rate. In the present script, mood is an output of the model, and learning is unaffected by it.

## Mood and Identity

Each outcome is converted to a mood input using the current rumination bias $b_t$ and social sensitivity $s_t$:

$$
u_t=
\begin{cases}
(1-b_t)\,r_t, & r_t>0,\\
(1+b_t)\,r_t, & r_t<0,
\end{cases}
\;+\; s_t F_t,
\qquad
m_{t+1}=0.9\,m_t+0.1\,u_t .
$$

A higher $b_t$ therefore shrinks the mood impact of good outcomes and enlarges that of bad ones. This is the same asymmetry as before, now expressed through a single bias parameter that can change over time. Since every reward is nonzero, the zero-reward branch is never reached.

Because outcomes are drawn uniformly, it is possible to say something about mood without simulating. Ignoring feedback, which averages to zero, the expected input is

$$
\mathbb{E}[u]=\frac{2.3(1-b)-1.5(1+b)}{5}=0.16-0.76\,b,
$$

where 2.3 is the sum of the positive rewards and 1.5 the sum of the absolute negative rewards. Expected mood is negative whenever $b>0.21$. At the starting value $b=0.5$ it is about $-0.22$, and at $b=1$ about $-0.6$. The default agent is therefore expected to hover below zero before any learning or identity change takes place. That is a property of the reward values and the starting trait, and it should not be read as a result about vulnerability.

The traits update as follows:

-   Rumination bias rises by 0.01 (capped at 1) whenever the reward is negative and mood is below $-0.5$.
-   Social sensitivity moves by $0.01F_t$ (clamped to $[0,1]$) whenever $|F_t|>0.2$.
-   Goal orientation is set to one minus the mean absolute reward over the previous ten steps, once ten steps have elapsed.

The first rule creates a positive feedback loop. Low mood raises $b$, a higher $b$ lowers expected mood, and lower mood makes the rule fire more often. The loop is slow, since each increment is small and the rule requires both a negative outcome and a low mood at the same moment. The second rule is a random walk with zero drift because feedback is symmetric. The third deserves comment: rewards here have absolute values between 0.5 and 1.0, so the rule yields values between 0 and 0.5 and mostly reflects how large recent outcomes were. It measures outcome intensity, not anything about goals, and the name overstates what it does.

The traits do not feed back into behavior. They change mood, and mood changes nothing else. The identity layer is therefore decoupled from action selection and from learning.

## Simulation

The script below runs 20 agents for 200 steps with identical parameters; they differ only through random draws. A small extension adds an `update_identity` switch, which lets us freeze the traits and see what the identity layer contributes. The corrected code is at the end of the post.

For summary statistics I simulated 500 agents (using a Python port of the script, so the figures are approximate and would shift slightly under R's random number generator). Three observations stand out.

First, mood sits below zero for most of the run. Averaged across agents and steps it is about $-0.26$, against $-0.21$ when the traits are frozen, and roughly 96% of agents dip below $-0.5$ at least once, whether or not traits can change. That matches the analytic expectation above and shows that the threshold for the rumination rule is reached routinely.

Second, rumination bias drifts upward. The mean value at step 200 is about 0.66, with a 5th to 95th percentile range of 0.51 to 0.92, and about 30% of agents end at or above 0.7. The drift is modest on average and wide across agents, which is what one would expect from a slow positive feedback loop driven by chance sequences of bad outcomes. Social sensitivity barely moves (mean 0.50, SD 0.04), as the zero-drift argument predicts. Goal orientation settles near 0.24 (SD 0.07), the value implied by an average absolute reward near 0.76.

Third, none of this changes task performance. Mean reward per step is 0.157 with or without identity updating, which is the 0.16 predicted for an environment the agent cannot influence. The Q-values stay close to zero (mean about 0.00 across entries, with a mean gap of about 0.08 between the best and worst action in a state), partly because only about eight updates per entry occur in 200 steps and partly because the greedy choice keeps rotating among entries that fall below their zero starting point.

The mood plot and the trait plot from the script show the same pattern at the level of individual agents. Mood trajectories fluctuate around a negative level with some separation between agents, and rumination bias fans out over time.

## Limitations

Several design choices constrain what can be concluded.

The environment offers no control. Since transitions are uniform and independent of the action, Q-learning has nothing to learn, and the finding that reward is policy-independent is built in. If the aim is to model uncontrollability, that is arguably a feature, but it should then be framed as such and contrasted with a controllable version.

The identity layer is causally downstream of mood only. Traits do not influence learning rates, exploration, or action choice, so they cannot change behavior in this model. A stronger test of the idea that traits and decisions co-evolve would let at least one trait alter learning or policy.

Mood and the learning rule are decoupled from each other, unlike in the earlier posts. If the series is read as a progression, the mood-dependent learning rate has quietly disappeared, and readers should be told.

The agents are homogeneous. Without varying $\kappa$, $b_0$, $s_0$, or the mood persistence, the "agents" are replicates of a single configuration, and spread across them reflects chance alone. No group comparison, "Healthy" versus "Depressed" or otherwise, is made here.

Finally, the trait update rules are arbitrary in their constants (0.01 steps, a threshold of $-0.5$, a ten-step window). Different choices would change the speed and perhaps the direction of drift. Sensitivity analyses over these constants would be the minimum needed before reading anything into the trajectories.

## Closing the Series

Across the posts, the models have moved from a bandit with mood-dependent learning to a sequential task with social feedback, and finally to one in which dispositions change over time. Each step made some assumptions explicit and exposed others. The most durable lessons are methodological. Parameters with psychological names do not necessarily do psychological work (the optimism and pessimism terms in the second model were inert). Equally, mechanisms that look sensible in isolation can be disconnected from behavior once the loop is written out, as the traits here are.

What this line of work can offer, I think, is a set of explicit hypotheses and the ability to check whether a proposed mechanism produces the pattern it is claimed to explain. It cannot say whether those patterns occur in people. For that, the parameters would have to be estimated from behavioral and mood data, preferably in a task where choices matter, and the competing mechanisms compared on their fit and their out-of-sample predictions.

## References

Eldar, E., Rutledge, R. B., Dolan, R. J., & Niv, Y. (2016). Mood as representation of momentum. *Trends in Cognitive Sciences, 20*(1), 15–24. <https://doi.org/10.1016/j.tics.2015.07.010>

Huys, Q. J. M., Daw, N. D., & Dayan, P. (2015). Depression: A decision-theoretic analysis. *Annual Review of Neuroscience, 38*, 1–23. <https://doi.org/10.1146/annurev-neuro-071714-033928>

Watkins, C. J. C. H., & Dayan, P. (1992). Q-learning. *Machine Learning, 8*, 279–292. <https://doi.org/10.1007/BF00992698>

## Full Code

``` r
set.seed(123)
library(ggplot2)
library(dplyr)
library(tidyr)

# ---- ENVIRONMENT ----

states   <- c("screen_time", "physical_activity", "socializing", "alcohol_use", "cinema")
n_states <- length(states)
actions  <- seq_len(n_states)

transition_matrix <- matrix(1 / n_states, nrow = n_states, ncol = n_states)

reward_function <- c(
  screen_time = -0.5, physical_activity = 1.0, socializing = 0.8,
  alcohol_use = -1.0, cinema = 0.5
)

peer_feedback_function <- function(state) {
  if (state == "socializing") return(runif(1, -1, 1))
  if (state == "alcohol_use") return(runif(1, -0.5, 0.5))
  0
}

# ---- AGENT ----

simulate_q_agent <- function(agent_id, n_steps = 200,
                             alpha_base = 0.1, gamma = 0.9, epsilon = 0.1,
                             optimism = 1.0, update_identity = TRUE,
                             initial_identity = list(
                               rumination_bias = 0.5,
                               social_sensitivity = 0.5,
                               goal_orientation = 0.5)) {
  Q <- matrix(0, nrow = n_states, ncol = n_states)
  mood <- 0
  state <- sample(n_states, 1)
  identity <- initial_identity

  identity_trace <- vector("list", n_steps)
  mood_trace     <- numeric(n_steps)
  reward_trace   <- numeric(n_steps)
  state_trace    <- character(n_steps)

  for (t in seq_len(n_steps)) {
    action <- if (runif(1) < epsilon) sample(actions, 1) else which.max(Q[state, ])

    next_state      <- sample(n_states, 1, prob = transition_matrix[state, ])
    next_state_name <- states[next_state]
    reward          <- unname(reward_function[next_state_name])
    peer_feedback   <- peer_feedback_function(next_state_name)

    # mood
    mood_delta <- if (reward > 0) reward * (1 - identity$rumination_bias)
                  else            reward * (1 + identity$rumination_bias)
    mood_delta <- mood_delta + identity$social_sensitivity * peer_feedback
    mood <- 0.9 * mood + 0.1 * mood_delta

    # Q-learning with sign-dependent learning rate
    delta <- reward + gamma * max(Q[next_state, ]) - Q[state, action]
    rate  <- if (delta > 0) alpha_base * optimism else alpha_base * (2 - optimism)
    Q[state, action] <- Q[state, action] + rate * delta

    # identity updates
    if (update_identity) {
      if (reward < 0 && mood < -0.5) {
        identity$rumination_bias <- min(identity$rumination_bias + 0.01, 1)
      }
      if (abs(peer_feedback) > 0.2) {
        identity$social_sensitivity <-
          max(min(identity$social_sensitivity + 0.01 * peer_feedback, 1), 0)
      }
      if (t > 10) {
        recent <- reward_trace[(t - 10):(t - 1)]
        identity$goal_orientation <- 1 - mean(abs(recent))
      }
    }

    identity_trace[[t]] <- identity
    mood_trace[t]       <- mood
    reward_trace[t]     <- reward
    state_trace[t]      <- next_state_name
    state               <- next_state
  }

  data.frame(
    trial = seq_len(n_steps),
    agent = agent_id,
    mood = mood_trace,
    reward = reward_trace,
    state = state_trace,
    rumination_bias    = sapply(identity_trace, `[[`, "rumination_bias"),
    social_sensitivity = sapply(identity_trace, `[[`, "social_sensitivity"),
    goal_orientation   = sapply(identity_trace, `[[`, "goal_orientation")
  )
}

# ---- SIMULATE ----

n_agents <- 20
results <- bind_rows(lapply(seq_len(n_agents), simulate_q_agent))

# ---- FIGURES ----

ggplot(results, aes(trial, mood, color = factor(agent))) +
  geom_line(alpha = 0.6, show.legend = FALSE) +
  labs(title = "Mood Trajectories", x = "Trial", y = "Mood") +
  theme_minimal()

traits_long <- results %>%
  pivot_longer(c(rumination_bias, social_sensitivity, goal_orientation),
               names_to = "trait", values_to = "value")

ggplot(traits_long, aes(trial, value, color = factor(agent))) +
  geom_line(alpha = 0.6, show.legend = FALSE) +
  facet_wrap(~trait, scales = "free_y") +
  labs(title = "Identity Trait Evolution", x = "Trial", y = "Trait value") +
  theme_minimal()

# ---- REPLICATION AND FROZEN-TRAIT CONTROL ----

run_group <- function(label, n = 500, ...) {
  bind_rows(lapply(seq_len(n), function(i) {
    set.seed(1000 + i)
    df <- simulate_q_agent(i, ...)
    df$group <- label
    df
  }))
}

rep_df <- bind_rows(
  run_group("Identity updating", update_identity = TRUE),
  run_group("Traits frozen",     update_identity = FALSE)
)

rep_df %>%
  group_by(group, agent) %>%
  summarise(mean_mood = mean(mood), min_mood = min(mood),
            mean_reward = mean(reward),
            final_rumination = last(rumination_bias),
            final_social = last(social_sensitivity),
            final_goal = last(goal_orientation), .groups = "drop") %>%
  group_by(group) %>%
  summarise(across(-agent, list(mean = mean, sd = sd), .names = "{.col}_{.fn}"))
```
