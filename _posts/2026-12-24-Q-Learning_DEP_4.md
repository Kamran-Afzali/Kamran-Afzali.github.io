

# Parameter Recovery and Bayesian Analysis of Clinical Reinforcement Learning Data in Computational Psychiatry: 

Translating theoretical computational psychiatry models into clinical insights is a difficult task that needs some knowledge about parameter recovery and bayesian modeling. When we collect behavioral data from clinical populations performing reinforcement learning tasks, the next step is to reliably recover the computational parameters that drove their behavior, and to understand what do these parameters tell us about psychiatric symptoms. In this post demonstrates how we apply Bayesian parameter recovery techniques to real clinical data, focusing on the practical challenges of working with behavioral datasets where we assume an underlying reinforcement learning process generated the observed choices. We'll explore how to validate our parameter estimates, assess model reliability, and interpret individual differences in a clinically meaningful way.

Unlike controlled simulation studies where we know the true generating parameters, in clinical behavioral data, when a depressed patient performs 200 trials of a two-armed bandit task, we observe only their choices and outcomes—the underlying learning rate, reward sensitivity, and decision noise remain hidden. Yet these latent parameters may be precisely what distinguishes healthy from pathological cognition. Consider a typical clinical dataset: 50 depressed patients and 50 healthy controls, each completing 200 trials of a probabilistic learning task. Standard analysis might fit Q-learning models to each participant, extract point estimates of α (learning rate) and β (inverse temperature), then compare group means with t-tests. This approach ignores parameter uncertainty, model fit quality, and the possibility that different individuals might be using entirely different learning strategies. If we conclude that depression involves reduced learning rates based on model fitting, this could influence treatment decisions, theoretical understanding, and future research directions. But what if our parameter estimates are unreliable due to limited data, model misspecification, or individual heterogeneity? Bayesian approaches provide tools to quantify this uncertainty and validate our computational inferences.

## Hierarchical Bayesian Parameter Recovery

It is possibe to approach parameter recovery as a hierarchical inference problem, where we simultaneously model individual-level parameters and group-level distributions. This approach provides advantages like improved parameter estimates through partial pooling, explicit modeling of individual differences, and natural incorporation of group-level comparisons.

```stan
data {
  int<lower=1> N_subj;          // Number of subjects
  int<lower=1> N_trials;        // Trials per subject
  int<lower=1> N_total;         // Total observations
  int<lower=1,upper=N_subj> subj[N_total];  // Subject index
  int<lower=1,upper=2> choice[N_total];     // Choices (1 or 2)
  int<lower=0,upper=1> reward[N_total];     // Rewards (0 or 1)
  int<lower=0,upper=1> group[N_subj];       // Group membership (0=control, 1=depressed)
}

parameters {
  // Group-level parameters
  vector[2] mu_alpha;           // Mean learning rate by group
  vector[2] mu_beta;            // Mean inverse temp by group
  vector<lower=0>[2] sigma_alpha;  // SD learning rate by group
  vector<lower=0>[2] sigma_beta;   // SD inverse temp by group
  
  // Individual-level parameters (raw)
  vector[N_subj] alpha_raw;
  vector[N_subj] beta_raw;
}

transformed parameters {
  // Individual parameters (constrained)
  vector<lower=0,upper=1>[N_subj] alpha;
  vector<lower=0>[N_subj] beta;
  
  for (s in 1:N_subj) {
    alpha[s] = Phi_approx(mu_alpha[group[s] + 1] + sigma_alpha[group[s] + 1] * alpha_raw[s]);
    beta[s] = exp(mu_beta[group[s] + 1] + sigma_beta[group[s] + 1] * beta_raw[s]);
  }
}

model {
  // Priors
  mu_alpha ~ normal(0, 1);
  mu_beta ~ normal(1, 1);
  sigma_alpha ~ normal(0, 0.5);
  sigma_beta ~ normal(0, 0.5);
  alpha_raw ~ normal(0, 1);
  beta_raw ~ normal(0, 1);
  
  // Likelihood
  {
    vector[N_total] log_lik;
    int idx = 1;
    
    for (s in 1:N_subj) {
      vector[2] Q = rep_vector(0.0, 2);
      
      for (t in 1:N_trials) {
        vector[2] action_prob = softmax(beta[s] * Q);
        log_lik[idx] = categorical_lpmf(choice[idx] | action_prob);
        
        // Update Q-values
        Q[choice[idx]] += alpha[s] * (reward[idx] - Q[choice[idx]]);
        idx += 1;
      }
    }
    
    target += sum(log_lik);
  }
}

generated quantities {
  // Posterior predictions and diagnostics
  vector[N_total] log_lik;
  vector[N_subj] alpha_diff;    // Individual deviations from group mean
  real group_diff_alpha;       // Group difference in learning rate
  real group_diff_beta;        // Group difference in inverse temperature
  
  // [Implementation of posterior predictions and group comparisons]
}
```

Such a hierarchical structure allows parameters for participants with limited or noisy data to borrow some precision from the group, leading to more stable estimates. Also, as we explicitly model the distribution of individual differences within each group, capturing heterogeneity that might be clinically relevant. This latter also facilitates group comparisons from the posterior distributions rather than requiring separate statistical tests.

## Validating Parameter Recovery with Posterior Predictive Checks

Parameter estimates are only meaningful if our model captures the behavioral patterns in the data. For this reason, posterior predictive checking is a systematic approach to model validation by generating simulated data from fitted models and comparing against observed behavior. For clinical RL data, several behavioral signatures are particularly important to capture **Learning Curves** that reffers to if the model reproduce the trial-by-trial evolution of choice preferences? Healthy individuals might show rapid convergence to optimal choices, while depressed participants might show slower or more volatile learning. **Choice Consistency**, that shows how well does the model capture the relationship between choice probability and reward history. Individual differences in this relationship might reflect distinct computational phenotypes. **Perseveration vs. Exploration**, where the model account for how participants balance exploitation of known good options against exploration of alternatives? This balance might be disrupted in various psychiatric conditions.

```r
# Posterior predictive validation
validate_learning_curves <- function(fit, observed_data) {
  posterior_samples <- extract(fit)
  n_samples <- 100  # Use subset of posterior samples
  
  predictions <- array(dim = c(n_samples, n_subjects, n_trials))
  
  for (i in 1:n_samples) {
    for (s in 1:n_subjects) {
      alpha_s <- posterior_samples$alpha[i, s]
      beta_s <- posterior_samples$beta[i, s]
      
      # Simulate choices using fitted parameters
      Q <- c(0, 0)
      for (t in 1:n_trials) {
        action_probs <- softmax(beta_s * Q)
        choice <- sample(1:2, 1, prob = action_probs)
        reward <- observed_data$rewards[s, t]  # Use actual rewards
        
        predictions[i, s, t] <- choice
        Q[choice] <- Q[choice] + alpha_s * (reward - Q[choice])
      }
    }
  }
  
  return(predictions)
}

# Compare predicted vs observed learning curves
plot_learning_validation <- function(predictions, observed_choices) {
  # Aggregate predictions across posterior samples
  pred_mean <- apply(predictions == 1, c(2, 3), mean)  # P(choose option 1)
  pred_ci <- apply(predictions == 1, c(2, 3), function(x) quantile(x, c(0.025, 0.975)))
  
  # Plot for each group
  for (group in c("Control", "Depressed")) {
    # Implementation of group-specific learning curve plots
    # with confidence intervals from posterior predictions
  }
}
```

The key insight from posterior predictive validation is identifying systematic discrepancies between model predictions and observed behavior. If the model consistently under-predicts learning speed in depressed participants, this might indicate that our Q-learning framework misses important aspects of how depression affects reinforcement learning. Such discrepancies guide model refinement and theoretical development.

## Conclusion

This post walked through the practical application of Bayesian parameter recovery to clinical reinforcement learning data. Rather than relying on simple point estimates, we built a hierarchical Bayesian model in Stan that simultaneously infers individual-level parameters (learning rate \(\alpha\) and inverse temperature \(\beta\)) and group-level distributions, enabling partial pooling across participants and principled group comparisons. We then validated these estimates using posterior predictive checks, examining whether the fitted model reproduces key behavioral signatures like learning curves, choice consistency, and exploration-exploitation balance. Together, these tools move us beyond asking "do depressed patients have lower learning rates?" toward a richer question: "how reliably can we estimate these parameters, and does our model faithfully capture the behavioral process we care about?" Bayesian parameter recovery doesn't eliminate uncertainty—it makes that uncertainty explicit and actionable, which is precisely what clinical translation requires. In the next blog post, we'll tackle one of the most consequential challenges in computational psychiatry: **Addressing Individual Heterogeneity and Mixture Models**—exploring how to handle the reality that not all patients within a diagnostic group are using the same learning strategy, and how mixture modeling approaches can uncover latent computational subtypes.


## Full code for simulations

```r
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

```











```r
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
```


```r
# ============================================================
# Parameter recovery and Bayesian analysis of clinical RL data
# Hierarchical Q-learning model with Stan + posterior checks
# ============================================================
library(rstan)
library(posterior)
library(bayesplot)
library(tidyverse)
library(MASS)

set.seed(1234)
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# ------------------------------------------------------------
# 1) Simulate clinical reinforcement learning data
# ------------------------------------------------------------

n_subj_per_group <- 50
n_groups <- 2
n_subj <- n_subj_per_group * n_groups
n_trials <- 200
n_total <- n_subj * n_trials

group <- rep(0:1, each = n_subj_per_group)  # 0 = control, 1 = depressed

# True group-level parameters on unconstrained scale
true_mu_alpha <- c(-0.2, -0.6)
true_sigma_alpha <- c(0.5, 0.6)

true_mu_beta <- c(log(4), log(2.5))
true_sigma_beta <- c(0.35, 0.45)

# Individual parameters
alpha_true <- numeric(n_subj)
beta_true <- numeric(n_subj)

for (s in 1:n_subj) {
  g <- group[s] + 1
  alpha_true[s] <- plogis(rnorm(1, true_mu_alpha[g], true_sigma_alpha[g]))
  beta_true[s] <- exp(rnorm(1, true_mu_beta[g], true_sigma_beta[g]))
}

# Task environment: probabilistic 2-armed bandit
p_rew_arm1 <- 0.70
p_rew_arm2 <- 0.30

subj_id <- integer(n_total)
trial_id <- integer(n_total)
choice <- integer(n_total)
reward <- integer(n_total)

row_idx <- 1
for (s in 1:n_subj) {
  Q <- c(0, 0)
  for (t in 1:n_trials) {
    logits <- beta_true[s] * Q
    probs <- exp(logits - max(logits))
    probs <- probs / sum(probs)
    
    ch <- sample(1:2, size = 1, prob = probs)
    rew <- rbinom(1, size = 1, prob = ifelse(ch == 1, p_rew_arm1, p_rew_arm2))
    pe <- rew - Q[ch]
    Q[ch] <- Q[ch] + alpha_true[s] * pe
    
    subj_id[row_idx] <- s
    trial_id[row_idx] <- t
    choice[row_idx] <- ch
    reward[row_idx] <- rew
    row_idx <- row_idx + 1
  }
}

sim_data <- tibble(
  subj = subj_id,
  trial = trial_id,
  choice = choice,
  reward = reward,
  group = group[subj_id]
)

# ------------------------------------------------------------
# 2) Stan model
# ------------------------------------------------------------

stan_code <- "
data {
  int<lower=1> N_subj;
  int<lower=1> N_trials;
  int<lower=1> N_total;
  int<lower=1> n_subj_per_group;
  array[N_total] int<lower=1,upper=N_subj> subj;
  array[N_total] int<lower=1,upper=2> choice;
  array[N_total] int<lower=0,upper=1> reward;
  array[N_subj] int<lower=0,upper=1> group;
}

parameters {
  vector[2] mu_alpha;
  vector[2] mu_beta;
  vector<lower=0>[2] sigma_alpha;
  vector<lower=0>[2] sigma_beta;

  vector[N_subj] alpha_raw;
  vector[N_subj] beta_raw;
}

transformed parameters {
  vector<lower=0,upper=1>[N_subj] alpha;
  vector<lower=0>[N_subj] beta;

  for (s in 1:N_subj) {
    alpha[s] = inv_logit(mu_alpha[group[s] + 1] + sigma_alpha[group[s] + 1] * alpha_raw[s]);
    beta[s] = exp(mu_beta[group[s] + 1] + sigma_beta[group[s] + 1] * beta_raw[s]);
  }
}

model {
  mu_alpha ~ normal(0, 1);
  mu_beta ~ normal(1, 1);
  sigma_alpha ~ normal(0, 0.5);
  sigma_beta ~ normal(0, 0.5);
  alpha_raw ~ normal(0, 1);
  beta_raw ~ normal(0, 1);

  for (s in 1:N_subj) {
    vector[2] Q = rep_vector(0.0, 2);
    for (t in 1:N_trials) {
      int i = (s - 1) * N_trials + t;
      target += categorical_logit_lpmf(choice[i] | beta[s] * Q);
      Q[choice[i]] += alpha[s] * (reward[i] - Q[choice[i]]);
    }
  }
}

generated quantities {
  vector[N_total] log_lik;
  array[N_total] int<lower=1,upper=2> y_rep;
  real group_diff_alpha;
  real group_diff_beta;

  group_diff_alpha =
    mean(segment(alpha, 1, n_subj_per_group)) -
    mean(segment(alpha, n_subj_per_group + 1, n_subj_per_group));

  group_diff_beta =
    mean(segment(beta, 1, n_subj_per_group)) -
    mean(segment(beta, n_subj_per_group + 1, n_subj_per_group));

  for (s in 1:N_subj) {
    vector[2] Q = rep_vector(0.0, 2);
    for (t in 1:N_trials) {
      int i = (s - 1) * N_trials + t;
      log_lik[i] = categorical_logit_lpmf(choice[i] | beta[s] * Q);
      y_rep[i] = categorical_logit_rng(beta[s] * Q);
      Q[choice[i]] += alpha[s] * (reward[i] - Q[choice[i]]);
    }
  }
}
"

# ------------------------------------------------------------
# 3) Fit model
# ------------------------------------------------------------

stan_data <- list(
  N_subj = n_subj,
  N_trials = n_trials,
  N_total = n_total,
  n_subj_per_group = n_subj_per_group,
  subj = sim_data$subj,
  choice = sim_data$choice,
  reward = sim_data$reward,
  group = group
)

fit <- stan(
  model_code = stan_code,
  data = stan_data,
  chains = 4,
  iter = 2000,
  warmup = 1000,
  seed = 1234,
  cores = parallel::detectCores()
)

print(
  fit,
  pars = c("mu_alpha", "mu_beta", "sigma_alpha", "sigma_beta",
           "group_diff_alpha", "group_diff_beta"),
  probs = c(0.025, 0.5, 0.975)
)

# ------------------------------------------------------------
# 4) Optional posterior summaries
# ------------------------------------------------------------

post_df <- as_draws_df(fit)

post_df %>%
  summarise(
    alpha_diff_mean = mean(group_diff_alpha),
    alpha_diff_q025 = quantile(group_diff_alpha, 0.025),
    alpha_diff_q975 = quantile(group_diff_alpha, 0.975),
    beta_diff_mean  = mean(group_diff_beta),
    beta_diff_q025  = quantile(group_diff_beta, 0.025),
    beta_diff_q975  = quantile(group_diff_beta, 0.975)
  ) %>%
  print()

# Optional traceplots
mcmc_trace(as.array(fit), pars = c("group_diff_alpha", "group_diff_beta"))
```
