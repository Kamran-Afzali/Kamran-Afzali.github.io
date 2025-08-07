

# parameter recovery and stan modelling



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




stan_model_1='data {
  int<lower=1> N;
  int<lower=1, upper=2> A[N];
  int<lower=0, upper=1> R[N];
}

parameters {
  real<lower=0, upper=1> alpha;
  real<lower=0> beta;
}

model {
  vector[2] Q = rep_vector(0, 2);
  alpha ~ beta(1, 1);
  beta ~ normal(0, 5);

  for (n in 1:N) {
    vector[2] logit_p = beta * Q;
    target += categorical_logit_lpmf(A[n] | logit_p);
    Q[A[n]] += alpha * (R[n] - Q[A[n]]);
  }
}

generated quantities {
  vector[N] log_lik;
  vector[2] Q = rep_vector(0, 2);

  for (n in 1:N) {
    vector[2] logit_p = beta * Q;
    log_lik[n] = categorical_logit_lpmf(A[n] | logit_p);
    Q[A[n]] += alpha * (R[n] - Q[A[n]]);
  }
}'




library(rstan)
library(dplyr)

# Use the 'healthy' simulation data or 'depressed'
sim_data <- healthy  # or depressed

# Format data for Stan
stan_data <- list(
  N = length(sim_data$actions),
  A = sim_data$actions,
  R = as.integer(sim_data$rewards)
)

# Compile and sample
fit_q <- stan(
  model_code = stan_model_1,
  data = stan_data,
  iter = 2000,
  warmup = 1000,
  chains = 4,
  cores = 4,
  seed = 42,
  control = list(adapt_delta = 0.95)
)

# Print posterior summaries
print(fit_q, pars = c("alpha", "beta"))


# Posterior plots
library(bayesplot)
posterior <- extract(fit_q)
mcmc_areas(as.data.frame(posterior), pars = c("alpha", "beta"))








library(dplyr)
library(ggplot2)

# Predict choices from MAP estimates
q_post <- rstan::extract(fit_q)
alpha_hat <- mean(q_post$alpha)
beta_hat <- mean(q_post$beta)

predict_q_learning <- function(alpha, beta, rewards, actions) {
  Q <- c(0, 0)
  probs <- numeric(length(rewards))
  for (i in seq_along(rewards)) {
    exp_q <- exp(Q * beta)
    p1 <- exp_q[1] / sum(exp_q)
    probs[i] <- p1
    a <- actions[i]
    r <- rewards[i]
    Q[a] <- Q[a] + alpha * (r - Q[a])
  }
  probs
}

predicted_probs <- predict_q_learning(alpha_hat, beta_hat, sim_data$rewards, sim_data$actions)
actual_choices <- sim_data$actions

# Combine into data frame
df <- data.frame(
  Trial = 1:length(predicted_probs),
  Predicted = predicted_probs,
  Actual = as.numeric(actual_choices == 1)
)

# Bin and compute means
df_binned <- df %>%
  mutate(Bin = cut(Trial, breaks = seq(0, length(Trial), by = 50), include.lowest = TRUE)) %>%
  group_by(Bin) %>%
  summarise(
    BinMid = mean(Trial),
    PredictedProb = mean(Predicted),
    ActualProb = mean(Actual)
  )

# Plot
ggplot(df_binned, aes(x = BinMid)) +
  geom_line(aes(y = PredictedProb), color = "blue", size = 1.2) +
  geom_point(aes(y = ActualProb), color = "red", size = 2) +
  geom_line(aes(y = ActualProb), color = "red", linetype = "dashed", size = 1) +
  labs(
    title = "Binned Model Predictions vs. Actual Behavior",
    x = "Trial (Binned)", y = "Probability of Choosing Action 1"
  ) +
  theme_minimal() +
  scale_y_continuous(limits = c(0, 1))














stan_model_2='
data {
  int<lower=1> N;
  int<lower=1, upper=2> A[N];  // Actions
  int<lower=0, upper=1> R[N];  // Rewards
}

parameters {
  real<lower=0, upper=1> p_stay;   // Prob. of repeating action after reward
  real<lower=0, upper=1> p_shift;  // Prob. of switching action after no reward
}

model {
  p_stay ~ beta(1, 1);
  p_shift ~ beta(1, 1);

  for (n in 2:N) {
    if (R[n - 1] == 1) {
      target += bernoulli_lpmf(A[n] == A[n - 1] ? 1 : 0 | p_stay);
    } else {
      target += bernoulli_lpmf(A[n] != A[n - 1] ? 1 : 0 | p_shift);
    }
  }
}

generated quantities {
  vector[N] log_lik;

  for (n in 1:N) {
    if (n == 1) {
      log_lik[n] = 0;  // undefined for first trial
    } else {
      if (R[n - 1] == 1) {
        log_lik[n] = bernoulli_lpmf(A[n] == A[n - 1] ? 1 : 0 | p_stay);
      } else {
        log_lik[n] = bernoulli_lpmf(A[n] != A[n - 1] ? 1 : 0 | p_shift);
      }
    }
  }
}
'


stan_data <- list(
  N = length(sim_data$actions),
  A = sim_data$actions,
  R = as.integer(sim_data$rewards)
)

# Fit Q-learning model
fit_wsls <- stan(  model_code = stan_model_2, data = stan_data,
              iter = 2000, warmup = 1000, chains = 4, seed = 42)

summary(fit_wsls)

wsls_post <- rstan::extract(fit_wsls)
p_stay_hat <- mean(wsls_post$p_stay)
p_shift_hat <- mean(wsls_post$p_shift)

predict_wsls <- function(p_stay, p_shift, actions, rewards) {
  N <- length(actions)
  probs <- numeric(N)
  probs[1] <- 0.5  # No previous trial to inform the first choice
  
  for (i in 2:N) {
    if (rewards[i - 1] == 1) {
      # If rewarded, probability of repeating last action
      probs[i] <- if (actions[i - 1] == 1) p_stay else 1 - p_stay
    } else {
      # If not rewarded, probability of switching
      probs[i] <- if (actions[i - 1] == 1) 1 - p_shift else p_shift
    }
  }
  probs
}

predicted_probs_wsls <- predict_wsls(p_stay_hat, p_shift_hat, sim_data$actions, sim_data$rewards)


df_wsls <- data.frame(
  Trial = 1:length(predicted_probs_wsls),
  Predicted = predicted_probs_wsls,
  Actual = as.numeric(sim_data$actions == 1)
)

library(dplyr)

df_binned_wsls <- df_wsls %>%
  mutate(Bin = cut(Trial, breaks = seq(0, length(Trial), by = 50), include.lowest = TRUE)) %>%
  group_by(Bin) %>%
  summarise(
    BinMid = mean(Trial),
    PredictedProb = mean(Predicted),
    ActualProb = mean(Actual)
  )

library(ggplot2)

ggplot(df_binned_wsls, aes(x = BinMid)) +
  geom_line(aes(y = PredictedProb), color = "blue", size = 1.2) +
  geom_point(aes(y = ActualProb), color = "red", size = 2) +
  geom_line(aes(y = ActualProb), color = "red", linetype = "dashed", size = 1) +
  labs(
    title = "WSLS Model Predictions vs. Actual Behavior (Binned)",
    x = "Trial (Binned)", y = "Probability of Choosing Action 1"
  ) +
  theme_minimal() +
  scale_y_continuous(limits = c(0, 1))









# Compare models using LOO
library(loo)

log_lik_q <- extract_log_lik(fit_q)
log_lik_wsls <- extract_log_lik(fit_wsls)

loo_q <- loo(log_lik_q)
loo_wsls <- loo(log_lik_wsls)

loo_compare(loo_q, loo_wsls)
