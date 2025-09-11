set.seed(42)

# Environment: Two-armed bandit
reward_probs <- c(0.8, 0.2)  # Probabilities of reward for each arm

q_learning_agent <- function(alpha, beta, episodes = 2000) {
  Q <- c(0, 0)  # Initial Q-values for two actions
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  for (i in 1:episodes) {
    # Softmax action selection
    exp_q <- exp(Q * beta)
    probs <- exp_q / sum(exp_q)
    action <- sample(1:2, 1, prob = probs)  # R is 1-indexed
    reward <- as.numeric(runif(1) < reward_probs[action])
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: normal learning rate and reward sensitivity
healthy <- q_learning_agent(alpha = 0.4, beta = 5)

# Depressed agent: lower learning rate (slower to update beliefs)
depressed <- q_learning_agent(alpha = 0.05, beta = 2)

# Plotting results
library(ggplot2)
df <- data.frame(
  Trial = 1:2000,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- reshape2::melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))







set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arm 1 and 2 are "good", 3-5 are "bad/self-defeating"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards

q_learning_agent <- function(alpha, beta, self_defeat_bias = 0, episodes = 200) {
  K <- length(reward_probs)
  Q <- rep(0, K)  # Initial Q-values for all actions
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  for (i in 1:episodes) {
    # Softmax action selection with self-defeating bias
    # Add bias to the logits of "bad" arms (arms 3,4,5)
    logits <- Q * beta
    logits[3:5] <- logits[3:5] + self_defeat_bias
    probs <- exp(logits) / sum(exp(logits))
    action <- sample(1:K, 1, prob = probs)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: normal learning, no self-defeating bias
healthy <- q_learning_agent(alpha = 0.2, beta = 5, self_defeat_bias = 0)

# Depressed agent: lower learning rate, strong self-defeating bias
depressed <- q_learning_agent(alpha = 0.05, beta = 5, self_defeat_bias = 2)

# Plot cumulative reward and action selection frequencies
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

# Plot cumulative reward
p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)







set.seed(2025)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arm 1 and 2 are "good", 3-5 are "bad/self-defeating"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

simulate_agent <- function(alpha, beta, pessimistic_bias = 0, self_defeat_bias = 0, mood_weight = 0, episodes = 200) {
  K <- length(reward_probs)
  Q <- rep(0, K)  # Initial Q-values
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0
  mood_history <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Pessimistic bias: underestimates all values
    Q_biased <- Q + pessimistic_bias
    
    # Self-defeating bias: increases logit for "bad" arms
    logits <- Q_biased * beta
    logits[self_defeating_arms] <- logits[self_defeating_arms] + self_defeat_bias
    
    # Mood integration: mood modulates exploration (lower mood = more exploration)
    mood_mod_beta <- beta * (1 + mood_weight * mood)
    logits <- Q_biased * mood_mod_beta
    logits[self_defeating_arms] <- logits[self_defeating_arms] + self_defeat_bias
    
    # Softmax action selection
    probs <- exp(logits) / sum(exp(logits))
    action <- sample(1:K, 1, prob = probs)
    
    # Simulate reward
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Q-learning update
    Q[action] <- Q[action] + alpha * (reward - Q[action])
    
    # Update mood: running average of recent outcomes (last 10 trials)
    if (i == 1) {
      mood <- reward
    } else {
      window <- max(1, i-9):i
      mood <- mean(rewards[window])
    }
    mood_history[i] <- mood
    
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards, mood = mood_history)
}

# Healthy agent: normal learning, no pessimism, no self-defeating bias, neutral mood
healthy <- simulate_agent(
  alpha = 0.2, beta = 5, pessimistic_bias = 0, self_defeat_bias = 0, mood_weight = 0, episodes = 200
)

# Depressed agent: lower learning, pessimism, self-defeating bias, mood-exploration coupling
depressed <- simulate_agent(
  alpha = 0.07, beta = 2.5, pessimistic_bias = -0.5, self_defeat_bias = 2, mood_weight = -0.5, episodes = 200
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot mood over time
mood_df <- data.frame(
  Trial = 1:200,
  Healthy = healthy$mood,
  Depressed = depressed$mood
)
mood_long <- melt(mood_df, id.vars = "Trial", variable.name = "Agent", value.name = "Mood")

p3 <- ggplot(mood_long, aes(x = Trial, y = Mood, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Mood Over Time",
       x = "Trials", y = "Mood (Recent Reward Average)") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
print(p3)



set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arms 1,2 are "good"; 3-5 are "bad"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

bayesian_agent <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0
) {
  K <- length(reward_probs)
  # Priors for Q-value mean and precision (1/variance)
  mu <- rep(pessimistic_prior_mean, K)     # Prior mean for each arm
  tau <- rep(1/prior_var, K)               # Prior precision (inverse variance)
  n <- rep(0, K)                           # Number of pulls per arm
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Thompson sampling: sample Q for each arm from current posterior
    sampled_Q <- rnorm(K, mean = mu, sd = 1/sqrt(tau))
    # Add self-defeating bias to arms 3-5 (depressed agent)
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    # Choose arm with highest sampled Q
    action <- which.max(sampled_Q)
    # Get reward
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    # Bayesian update for Normal likelihood with known variance (assume variance=1 for simplicity)
    n[action] <- n[action] + 1
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
  }
  list(actions = actions, rewards = rewards)
}

# Healthy agent: neutral prior, no self-defeating bias
healthy <- bayesian_agent(
  episodes = 200,
  pessimistic_prior_mean = 0,
  prior_var = 10,
  self_defeat_bias = 0
)

# Depressed agent: pessimistic prior, self-defeating bias
depressed <- bayesian_agent(
  episodes = 200,
  pessimistic_prior_mean = -0.5,  # pessimistic prior
  prior_var = 10,
  self_defeat_bias = 2            # bias toward self-defeating arms
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent (Bayesian Q-learning)",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies (Bayesian Q-learning)",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)






set.seed(123)
library(ggplot2)
library(reshape2)

# Environment: 5-armed bandit
reward_probs <- c(0.7, 0.6, 0.2, 0.1, 0.05)   # Arms 1,2 are "good"; 3-5 are "bad"
reward_vals  <- c(1, 1, -1, -1, -2)           # Arms 3-5 yield negative rewards
self_defeating_arms <- 3:5

bayesian_agent_mood <- function(
    episodes = 200,
    pessimistic_prior_mean = 0,
    prior_var = 10,
    self_defeat_bias = 0,
    mood_decay = 0.9,         # Decay factor for mood (exponential smoothing)
    mood_influence = 1.5      # How strongly mood modulates exploration/exploitation
) {
  K <- length(reward_probs)
  mu <- rep(pessimistic_prior_mean, K)     # Prior mean for each arm
  tau <- rep(1/prior_var, K)               # Prior precision (inverse variance)
  n <- rep(0, K)                           # Number of pulls per arm
  actions <- integer(episodes)
  rewards <- numeric(episodes)
  mood <- 0                                # Initial mood
  mood_hist <- numeric(episodes)
  
  for (i in 1:episodes) {
    # Mood-modulated variance: bad mood = more exploration (higher variance)
    # Good mood = more exploitation (lower variance)
    # Clamp mood to [-1,1] for stability
    mood_clamped <- min(max(mood, -1), 1)
    mood_sigma_scale <- exp(-mood_influence * mood_clamped)
    
    sampled_Q <- rnorm(K, mean = mu, sd = mood_sigma_scale / sqrt(tau))
    sampled_Q[self_defeating_arms] <- sampled_Q[self_defeating_arms] + self_defeat_bias
    
    action <- which.max(sampled_Q)
    reward <- ifelse(runif(1) < reward_probs[action], reward_vals[action], 0)
    
    # Bayesian update for Normal likelihood with known variance (assume variance=1)
    n[action] <- n[action] + 1
    tau[action] <- tau[action] + 1
    mu[action] <- (mu[action] * (tau[action] - 1) + reward) / tau[action]
    actions[i] <- action
    rewards[i] <- reward
    
    # Update mood: exponential smoothing of recent rewards
    mood <- mood_decay * mood + (1 - mood_decay) * reward
    mood_hist[i] <- mood
  }
  list(actions = actions, rewards = rewards, mood = mood_hist)
}

# Healthy agent: neutral prior, no self-defeating bias, normal mood influence
healthy <- bayesian_agent_mood(
  episodes = 200,
  pessimistic_prior_mean = 0,
  prior_var = 10,
  self_defeat_bias = 0,
  mood_decay = 0.9,
  mood_influence = 1.5
)

# Depressed agent: pessimistic prior, self-defeating bias, mood has stronger influence on exploration
depressed <- bayesian_agent_mood(
  episodes = 200,
  pessimistic_prior_mean = -0.5,
  prior_var = 10,
  self_defeat_bias = 2,
  mood_decay = 0.9,
  mood_influence = 3.0   # More mood-driven exploration
)

# Plot cumulative reward
df <- data.frame(
  Trial = 1:200,
  Healthy = cumsum(healthy$rewards),
  Depressed = cumsum(depressed$rewards)
)
df_long <- melt(df, id.vars = "Trial", variable.name = "Agent", value.name = "CumulativeReward")

p1 <- ggplot(df_long, aes(x = Trial, y = CumulativeReward, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Cumulative Reward: Healthy vs. Depressed Agent (Bayesian Q-learning + Mood)",
       x = "Trials", y = "Cumulative Reward") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot action selection frequencies
action_freq <- data.frame(
  Action = factor(1:5),
  Healthy = as.numeric(table(factor(healthy$actions, levels = 1:5))),
  Depressed = as.numeric(table(factor(depressed$actions, levels = 1:5)))
)
action_freq_long <- melt(action_freq, id.vars = "Action", variable.name = "Agent", value.name = "Count")

p2 <- ggplot(action_freq_long, aes(x = Action, y = Count, fill = Agent)) +
  geom_bar(stat = "identity", position = "dodge") +
  labs(title = "Action Selection Frequencies (Bayesian Q-learning + Mood)",
       x = "Action (Arm)", y = "Count") +
  theme_minimal() +
  scale_fill_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

# Plot mood over time
mood_df <- data.frame(
  Trial = 1:200,
  Healthy = healthy$mood,
  Depressed = depressed$mood
)
mood_long <- melt(mood_df, id.vars = "Trial", variable.name = "Agent", value.name = "Mood")

p3 <- ggplot(mood_long, aes(x = Trial, y = Mood, color = Agent)) +
  geom_line(size = 1) +
  labs(title = "Mood Over Time (Bayesian Q-learning + Mood)",
       x = "Trials", y = "Mood (Exp. Avg. Reward)") +
  theme_minimal() +
  scale_color_manual(values = c("Healthy" = "blue", "Depressed" = "red"))

print(p1)
print(p2)
print(p3)

