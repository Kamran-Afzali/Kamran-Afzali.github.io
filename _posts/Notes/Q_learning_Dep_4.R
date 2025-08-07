
# beyond multiarm MDP models

# The provided R code implements a simulation of a mood-sensitive Q-learning agent operating within a stylized behavioral environment consisting of five states: ScreenTime, PhysicalActivity, Socializing, Alcohol, and Cinema. Each state serves both as a context and as a potential action target. Transition probabilities are constructed to favor self-directed actions, while a predefined reward matrix reflects the desirability of each action-state pairing. The agent, governed by mood-dependent learning dynamics, adapts its behavior across 200 episodes using a reinforcement learning algorithm that incorporates traditional parameters (learning rate, discount factor, and exploration rate), as well as psychological constructs such as rumination and emotional valence. Two distinct agent profiles—"Healthy" and "Depressed"—are defined through differing parameterizations of mood decay, rumination weights, and affective biases. The simulation captures how mood influences decision-making and learning, with trajectories logged for subsequent analysis. Visualizations illustrate the evolution of mood, cumulative reward acquisition, and state visitation patterns, revealing the behavioral divergence between the two agent profiles. This framework enables the investigation of affective-cognitive interactions in reinforcement learning and offers a computational lens through which mood disorders might be modeled and better understood.

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


#This R script extends a mood-sensitive Q-learning framework by integrating a model of social influence into agent-based simulations. The environment consists of five behavioral states, each associated with specific reward structures and transition probabilities that favor action-related state persistence. A Q-learning agent learns over 200 episodes, adjusting its action values (Q-values) in response to both intrinsic mood dynamics and extrinsic peer feedback. Mood is influenced by a combination of reinforcement (positive or negative reward-based rumination) and social appraisal, which is modeled via a feedback mechanism. Depending on the specified mode—random or state-based—peer responses are either probabilistically assigned or derived from a normative evaluation of the selected action (e.g., rewarding socializing, penalizing alcohol use). Two agent profiles, representing "Healthy" and "Depressed" individuals, are simulated using distinct parameter configurations that modulate sensitivity to reward, social feedback, and mood inertia. The resulting trajectories are analyzed through visualizations of mood evolution, cumulative reward, behavioral state transitions, and peer feedback patterns. This simulation framework provides a computational approach for examining the interplay between affect, learning, and social context, offering insights into behavioral trajectories characteristic of differing mental health profiles.



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





# This script implements a simulation of Q-learning agents embedded within a behavioral environment, with a focus on dynamic identity traits and their influence on learning and affect. The environment comprises five states representing common daily activities, each associated with fixed rewards and uniform state transition probabilities. A central feature of the model is the integration of three mutable identity parameters—rumination bias, social sensitivity, and goal orientation—which evolve in response to experience. Mood updates are driven by both intrinsic reward processing and extrinsic peer feedback, with the magnitude and direction of these effects modulated by the agent’s current identity profile. Action selection follows an ε-greedy policy, and Q-values are updated using an optimism-weighted delta, accounting for motivational framing. Identity traits are adjusted across episodes based on recent affective and social experiences, providing a feedback loop between psychological traits and behavior. The simulation runs across multiple agents to generate heterogeneous trajectories, with visualizations depicting mood fluctuation and the evolution of identity traits over time. This model contributes to computational affective science by capturing the bidirectional interactions between mood, behavior, learning, and personality-like traits in a socially influenced decision-making context.



set.seed(123)
library(ggplot2)
library(dplyr)
library(tidyr)

# Define environment
states <- c("screen_time", "physical_activity", "socializing", "alcohol_use", "cinema")
n_states <- length(states)
actions <- 1:n_states
state_names <- states
n_actions <- length(actions)

# Transition probabilities (uniform for simplicity)
transition_matrix <- matrix(1/n_states, nrow=n_states, ncol=n_states)

# Reward function per state
reward_function <- c(
  screen_time = -0.5,
  physical_activity = 1.0,
  socializing = 0.8,
  alcohol_use = -1.0,
  cinema = 0.5
)

# Peer feedback
peer_feedback_function <- function(state) {
  if (state == "socializing") return(runif(1, -1, 1))
  if (state == "alcohol_use") return(runif(1, -0.5, 0.5))
  return(0)
}

# Q-learning agent with identity dynamics
simulate_q_agent <- function(agent_id, episodes = 200,
                             alpha_base = 0.1, gamma = 0.9,
                             optimism = 1.0,
                             initial_identity = list(
                               rumination_bias = 0.5,
                               social_sensitivity = 0.5,
                               goal_orientation = 0.5
                             )) {
  Q <- matrix(0, nrow=n_states, ncol=n_actions)
  mood <- 0
  state <- sample(1:n_states, 1)
  identity <- initial_identity
  
  identity_trace <- list()
  mood_trace <- numeric(episodes)
  reward_trace <- numeric(episodes)
  state_trace <- character(episodes)
  
  for (t in 1:episodes) {
    # Epsilon-greedy action selection
    epsilon <- 0.1
    if (runif(1) < epsilon) {
      action <- sample(actions, 1)
    } else {
      action <- which.max(Q[state, ])
    }
    
    next_state <- sample(1:n_states, 1, prob = transition_matrix[state, ])
    next_state_name <- state_names[next_state]
    reward <- reward_function[next_state_name]
    peer_feedback <- peer_feedback_function(next_state_name)
    
    # Mood dynamics
    mood_delta <- if (reward > 0) {
      reward * (1 - identity$rumination_bias)
    } else {
      reward * (1 + identity$rumination_bias)
    }
    mood_delta <- mood_delta + identity$social_sensitivity * peer_feedback
    mood <- 0.9 * mood + 0.1 * mood_delta
    
    # Q-learning update with optimism/pessimism
    delta <- reward + gamma * max(Q[next_state, ]) - Q[state, action]
    if (delta > 0) {
      Q[state, action] <- Q[state, action] + alpha_base * optimism * delta
    } else {
      Q[state, action] <- Q[state, action] + alpha_base * (2 - optimism) * delta
    }
    
    # Identity trait updates
    if (reward < 0 && mood < -0.5) {
      identity$rumination_bias <- min(identity$rumination_bias + 0.01, 1)
    }
    if (abs(peer_feedback) > 0.2) {
      identity$social_sensitivity <- max(min(identity$social_sensitivity + 0.01 * peer_feedback, 1), 0)
    }
    if (t > 10) {
      recent_rewards <- reward_trace[(t-10):(t-1)]
      identity$goal_orientation <- 1 - mean(abs(recent_rewards), na.rm = TRUE)
    }
    
    identity_trace[[t]] <- identity
    mood_trace[t] <- mood
    reward_trace[t] <- reward
    state_trace[t] <- next_state_name
    state <- next_state
  }
  
  identity_df <- do.call(rbind, lapply(1:episodes, function(i) {
    cbind(
      trial = i,
      agent = agent_id,
      mood = mood_trace[i],
      reward = reward_trace[i],
      state = state_trace[i],
      rumination_bias = identity_trace[[i]]$rumination_bias,
      social_sensitivity = identity_trace[[i]]$social_sensitivity,
      goal_orientation = identity_trace[[i]]$goal_orientation
    )
  }))
  
  as.data.frame(identity_df)
}

# Simulate multiple agents
n_agents <- 20
results <- do.call(rbind, lapply(1:n_agents, simulate_q_agent))

# Plot mood trajectories
ggplot(results, aes(x = trial, y = mood, color = factor(agent))) +
  geom_line(alpha = 0.6) +
  labs(title = "Mood Trajectories", x = "Trial", y = "Mood") +
  theme_minimal()

# Plot identity trait evolution
traits_long <- results %>%
  pivot_longer(cols = c(rumination_bias, social_sensitivity, goal_orientation),
               names_to = "trait", values_to = "value")

ggplot(traits_long, aes(x = trial, y = value, color = factor(agent))) +
  geom_line(alpha = 0.6) +
  facet_wrap(~trait, scales = "free_y") +
  labs(title = "Identity Trait Evolution", x = "Trial", y = "Trait Value") +
  theme_minimal()

