---
editor_options: 
  markdown: 
    wrap: 72
---

# Parameter Recovery and Bayesian Analysis of Reinforcement Learning Data in Computational Psychiatry

I haven't run any of the code below, so test it before publishing. The hyperparameter priors in particular are reasonable defaults, not tuned values. I also left out literature claims I couldn't source here. Add citations where I've flagged them.

***

Moving from a theoretical computational model to a clinical inference takes more than fitting it. Suppose we collect choices from patients doing a reinforcement learning task. The learning rate, reward sensitivity and decision noise are never observed, only the choices and outcomes. Whether those latent quantities can be recovered from the data we have is an empirical question, and it should be answered before anyone interprets a group difference.

Take a typical design: 50 patients with depression and 50 controls, each doing 200 trials of a probabilistic two-armed bandit. A common analysis fits a Q-learning model to each person by maximum likelihood, extracts point estimates of the learning rate α and inverse temperature β, and compares group means with a t-test. That treats noisy estimates as if they were data. It ignores their uncertainty and the trade-off between α and β. It also assumes everyone follows the same learning process.

Bayesian hierarchical modelling doesn't remove these problems, but it makes them visible. Partial pooling stabilises noisy individual estimates. Posterior distributions carry the uncertainty forward into group comparisons. Posterior predictive checks show where the model fails to reproduce behaviour. Here we do three things on simulated data, where the truth is known:

1. Fit a single-subject Q-learning model.
2. Compare it with a win–stay/lose–shift (WSLS) heuristic.
3. Fit a hierarchical two-group model and check how well its parameters are recovered.

## Simulating a Q-learning agent

The environment is a stationary two-armed bandit with binary rewards. Arm 1 pays off with probability 0.8 and arm 2 with 0.2. On each trial the agent chooses with a softmax policy:

$$
\pi(a \mid Q_t) = \frac{\exp(\beta\, Q_t(a))}{\sum_{a'} \exp(\beta\, Q_t(a'))}
$$

After the outcome, the chosen action's value is updated with the delta rule:

$$
Q_{t+1}(a_t) = Q_t(a_t) + \alpha\,\bigl(r_t - Q_t(a_t)\bigr)
$$

We simulate two agents for 2,000 trials. The "healthy-like" agent has α = 0.4 and β = 5. The "depressed-like" agent has α = 0.05 and β = 2. These values are chosen by us to produce contrasting behaviour. They don't come from data, and the labels are a convenience. Whether depression is characterised by lower learning rates, lower reward sensitivity, or neither is an empirical and somewhat contested question in the literature [add citations]. Simulated parameters can't settle it.

```r
set.seed(42)
library(dplyr); library(ggplot2); library(rstan); library(bayesplot); library(loo)
options(mc.cores = 4); rstan_options(auto_write = TRUE)

softmax <- function(x) { e <- exp(x - max(x)); e / sum(e) }

simulate_q <- function(alpha, beta, n_trials, reward_probs = c(0.8, 0.2)) {
  Q <- c(0, 0)
  A <- integer(n_trials); R <- integer(n_trials)
  for (t in seq_len(n_trials)) {
    A[t] <- sample(1:2, 1, prob = softmax(beta * Q))
    R[t] <- rbinom(1, 1, reward_probs[A[t]])
    Q[A[t]] <- Q[A[t]] + alpha * (R[t] - Q[A[t]])
  }
  list(actions = A, rewards = R)
}

healthy   <- simulate_q(alpha = 0.40, beta = 5, n_trials = 2000)
depressed <- simulate_q(alpha = 0.05, beta = 2, n_trials = 2000)

df <- tibble(Trial = 1:2000,
             Healthy = cumsum(healthy$rewards),
             Depressed = cumsum(depressed$rewards)) |>
  tidyr::pivot_longer(-Trial, names_to = "Agent", values_to = "CumulativeReward")

ggplot(df, aes(Trial, CumulativeReward, colour = Agent)) +
  geom_line(linewidth = 1) + theme_minimal() +
  labs(title = "Cumulative reward: healthy-like vs depressed-like agent")
```

## Single-subject Bayesian Q-learning

The Stan model uses weakly informative priors: α ~ Beta(1, 1) and β ~ half-normal(0, 5). Stan parameterises the normal by its standard deviation, so 5 is an SD. The half-normal comes from the lower bound of 0 on β. The likelihood is a categorical-logit over β·Q, with Q updated sequentially. We also store pointwise log-likelihoods, starting from trial 2, so the model can later be compared with WSLS on exactly the same observations.

```r
stan_q <- "
data {
  int<lower=2> N;
  array[N] int<lower=1, upper=2> A;
  array[N] int<lower=0, upper=1> R;
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
    target += categorical_logit_lpmf(A[n] | beta * Q);
    Q[A[n]] += alpha * (R[n] - Q[A[n]]);
  }
}
generated quantities {
  vector[N - 1] log_lik;
  {
    vector[2] Q = rep_vector(0, 2);
    for (n in 1:N) {
      if (n > 1) log_lik[n - 1] = categorical_logit_lpmf(A[n] | beta * Q);
      Q[A[n]] += alpha * (R[n] - Q[A[n]]);
    }
  }
}
"

sim <- healthy
stan_data <- list(N = length(sim$actions), A = sim$actions, R = sim$rewards)
fit_q <- stan(model_code = stan_q, data = stan_data,
              iter = 2000, warmup = 1000, chains = 4, seed = 42,
              control = list(adapt_delta = 0.95))
print(fit_q, pars = c("alpha", "beta"))
mcmc_areas(as.array(fit_q), pars = c("alpha", "beta"))
```

Before reading the posteriors, check R-hat (should be near 1.00), effective sample sizes and divergent transitions. Then look at the joint posterior of α and β. With few trials the two trade off, since a fast learner with low noise and a slow learner with high sensitivity can produce similar choices:

```r
post <- rstan::extract(fit_q)
cor(post$alpha, post$beta)
mcmc_scatter(as.array(fit_q), pars = c("alpha", "beta"), alpha = 0.2)
```

## A free-running posterior predictive check

A common shortcut is to plug posterior means into the model and compute the probability of each observed choice given the observed history. That check is weak for two reasons. It discards posterior uncertainty, and because it conditions on the participant's own past actions, it tends to track the data closely whatever the model's quality. A stronger test lets the fitted model generate its own choices and its own rewards from the environment, then compares those simulated learning curves with the observed one.

```r
ppc_free_running <- function(post, n_trials, reward_probs, n_draws = 200) {
  idx <- sample(length(post$alpha), n_draws)
  sapply(idx, function(i) {
    sim <- simulate_q(post$alpha[i], post$beta[i], n_trials, reward_probs)
    as.numeric(sim$actions == 1)
  })
}

bin_curve <- function(x, bin = 50) {
  tapply(x, ceiling(seq_along(x) / bin), mean)
}

pred <- ppc_free_running(post, n_trials = 2000, reward_probs = c(0.8, 0.2))
pred_binned <- apply(pred, 2, bin_curve)
obs_binned  <- bin_curve(as.numeric(sim$actions == 1))

ppc_df <- tibble(
  Bin   = seq_along(obs_binned),
  Obs   = as.numeric(obs_binned),
  Mean  = rowMeans(pred_binned),
  Lo    = apply(pred_binned, 1, quantile, 0.025),
  Hi    = apply(pred_binned, 1, quantile, 0.975)
)

ggplot(ppc_df, aes(Bin)) +
  geom_ribbon(aes(ymin = Lo, ymax = Hi), fill = "steelblue", alpha = 0.3) +
  geom_line(aes(y = Mean), colour = "steelblue") +
  geom_point(aes(y = Obs), colour = "red") +
  scale_y_continuous(limits = c(0, 1)) + theme_minimal() +
  labs(x = "Trial bin (50 trials)", y = "P(choose arm 1)",
       title = "Free-running posterior predictive check")
```

With a single observed sequence, the observed curve will wander within a fairly wide band by chance. Observed points sitting outside the band across several consecutive bins would be the signal worth worrying about.

## Win–stay/lose–shift as a rival model

The WSLS model drops latent values entirely. Choice on trial n depends only on the previous action and its outcome. After a reward the agent repeats its choice with probability p_stay. After no reward it switches with probability p_shift. The first trial has no history, so it is excluded from the likelihood. This is also why the Q-learning log-likelihood above starts at trial 2.

```r
stan_wsls <- "
data {
  int<lower=2> N;
  array[N] int<lower=1, upper=2> A;
  array[N] int<lower=0, upper=1> R;
}
parameters {
  real<lower=0, upper=1> p_stay;
  real<lower=0, upper=1> p_shift;
}
model {
  p_stay ~ beta(1, 1);
  p_shift ~ beta(1, 1);
  for (n in 2:N) {
    if (R[n - 1] == 1) target += bernoulli_lpmf(A[n] == A[n - 1] | p_stay);
    else               target += bernoulli_lpmf(A[n] != A[n - 1] | p_shift);
  }
}
generated quantities {
  vector[N - 1] log_lik;
  for (n in 2:N) {
    if (R[n - 1] == 1) log_lik[n - 1] = bernoulli_lpmf(A[n] == A[n - 1] | p_stay);
    else               log_lik[n - 1] = bernoulli_lpmf(A[n] != A[n - 1] | p_shift);
  }
}
"

fit_w <- stan(model_code = stan_wsls, data = stan_data,
              iter = 2000, warmup = 1000, chains = 4, seed = 42)

loo_q <- loo(extract_log_lik(fit_q, "log_lik"))
loo_w <- loo(extract_log_lik(fit_w, "log_lik"))
loo_compare(loo_q, loo_w)
```

The comparison uses expected log predictive density from leave-one-out cross-validation. A difference of a few units relative to its standard error is weak evidence. For a Q-learning agent with high β, WSLS may fit reasonably well, because strong exploitation makes the choices look like repeated wins and shifts. Whether the two models can be told apart depends on the parameters and the number of trials. A model-recovery exercise, simulating from each model and checking that the comparison picks the right one, answers that directly.

## Hierarchical parameter recovery

Now we move to the clinical-style design. Each subject s has a learning rate α_s and inverse temperature β_s drawn from group-specific distributions on unconstrained scales:

$$
\text{logit}(\alpha_s) = \mu_{\alpha,g} + \sigma_{\alpha,g}\,\alpha^{\text{raw}}_s, \qquad
\log(\beta_s) = \mu_{\beta,g} + \sigma_{\beta,g}\,\beta^{\text{raw}}_s
$$

where g is the subject's group and the raw terms are standard normal (the non-centred parameterisation, which usually helps sampling in hierarchical models). Here the reward probabilities are 0.7 and 0.3. These are the same as in the dataset we simulate below, so the model and the generating process line up. The group means below are again assumptions, with the "depressed" group given a lower α and β.

```r
n_per_group <- 50; n_trials <- 200
group <- rep(c(0, 1), each = n_per_group)
n_subj <- length(group)
p_rew <- c(0.7, 0.3)

true_mu_alpha <- c(qlogis(0.40), qlogis(0.20))
true_mu_beta  <- c(log(4), log(2.5))
true_sd_alpha <- c(0.5, 0.5)
true_sd_beta  <- c(0.3, 0.3)

alpha_true <- plogis(rnorm(n_subj, true_mu_alpha[group + 1], true_sd_alpha[group + 1]))
beta_true  <- exp(rnorm(n_subj, true_mu_beta[group + 1], true_sd_beta[group + 1]))

choice <- matrix(NA_integer_, n_subj, n_trials)
reward <- matrix(NA_integer_, n_subj, n_trials)
for (s in seq_len(n_subj)) {
  sim_s <- simulate_q(alpha_true[s], beta_true[s], n_trials, p_rew)
  choice[s, ] <- sim_s$actions
  reward[s, ] <- sim_s$rewards
}
```

The Stan model mirrors this process. Hyperpriors are weakly informative. The group SDs are half-normal because of their lower bound. The generated quantities block returns group contrasts and one summed log-likelihood per subject, which is what leave-one-subject-out comparison needs.

```r
stan_hier <- "
data {
  int<lower=1> N_subj;
  int<lower=2> N_trials;
  array[N_subj] int<lower=0, upper=1> group;
  array[N_subj, N_trials] int<lower=1, upper=2> choice;
  array[N_subj, N_trials] int<lower=0, upper=1> reward;
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
  vector<lower=0, upper=1>[N_subj] alpha;
  vector<lower=0>[N_subj] beta;
  for (s in 1:N_subj) {
    int g = group[s] + 1;
    alpha[s] = inv_logit(mu_alpha[g] + sigma_alpha[g] * alpha_raw[s]);
    beta[s]  = exp(mu_beta[g] + sigma_beta[g] * beta_raw[s]);
  }
}
model {
  mu_alpha ~ normal(0, 1);
  mu_beta ~ normal(0.5, 1);
  sigma_alpha ~ normal(0, 1);
  sigma_beta ~ normal(0, 1);
  alpha_raw ~ std_normal();
  beta_raw ~ std_normal();
  for (s in 1:N_subj) {
    vector[2] Q = rep_vector(0, 2);
    for (t in 1:N_trials) {
      target += categorical_logit_lpmf(choice[s, t] | beta[s] * Q);
      Q[choice[s, t]] += alpha[s] * (reward[s, t] - Q[choice[s, t]]);
    }
  }
}
generated quantities {
  real delta_mu_alpha = mu_alpha[2] - mu_alpha[1];
  real delta_mu_beta  = mu_beta[2] - mu_beta[1];
  vector[N_subj] log_lik_subj;
  for (s in 1:N_subj) {
    vector[2] Q = rep_vector(0, 2);
    log_lik_subj[s] = 0;
    for (t in 1:N_trials) {
      log_lik_subj[s] += categorical_logit_lpmf(choice[s, t] | beta[s] * Q);
      Q[choice[s, t]] += alpha[s] * (reward[s, t] - Q[choice[s, t]]);
    }
  }
}
"

fit_h <- stan(model_code = stan_hier,
              data = list(N_subj = n_subj, N_trials = n_trials, group = group,
                          choice = choice, reward = reward),
              iter = 2000, warmup = 1000, chains = 4, seed = 42,
              control = list(adapt_delta = 0.95))

print(fit_h, pars = c("mu_alpha", "mu_beta", "sigma_alpha", "sigma_beta",
                      "delta_mu_alpha", "delta_mu_beta"))
```

The group contrasts are differences on the logit and log scales. Their posteriors, with 95% credible intervals, give the group comparison directly. In this simulation the true values are about −0.97 for α (logit 0.2 minus logit 0.4) and −0.47 for β (log 2.5 minus log 4). A credible interval that excludes zero tells us a difference was detected. It doesn't establish that the model is right.

## Checking parameter recovery

Recovery has to be shown against the truth, which we can do only because we simulated the data. Compare posterior means with true values per subject, then examine bias, correlation and interval coverage.

```r
p <- rstan::extract(fit_h)
rec <- tibble(
  subj = 1:n_subj, group = factor(group, labels = c("Control", "Depressed")),
  alpha_true, beta_true,
  alpha_est = colMeans(p$alpha), beta_est = colMeans(p$beta),
  alpha_lo = apply(p$alpha, 2, quantile, 0.025), alpha_hi = apply(p$alpha, 2, quantile, 0.975),
  beta_lo  = apply(p$beta,  2, quantile, 0.025), beta_hi  = apply(p$beta,  2, quantile, 0.975)
)

with(rec, c(r_alpha = cor(alpha_true, alpha_est), r_beta = cor(beta_true, beta_est),
            bias_alpha = mean(alpha_est - alpha_true),
            bias_beta  = mean(beta_est - beta_true),
            cover_alpha = mean(alpha_true >= alpha_lo & alpha_true <= alpha_hi),
            cover_beta  = mean(beta_true  >= beta_lo  & beta_true  <= beta_hi)))

ggplot(rec, aes(alpha_true, alpha_est, colour = group)) +
  geom_pointrange(aes(ymin = alpha_lo, ymax = alpha_hi), alpha = 0.6) +
  geom_abline(linetype = "dashed") + theme_minimal() +
  labs(title = "Recovery of learning rate")
```

Three outcomes are worth looking for:

- **Shrinkage.** Partial pooling pulls extreme estimates toward the group mean. This is expected, and it can inflate correlations with the truth while compressing the range.
- **Coverage.** About 95% of true values should fall in their 95% intervals. Much lower coverage suggests overconfident estimates.
- **Trade-off between α and β.** Compute `cor(p$alpha[, s], p$beta[, s])` for several subjects. A strongly negative or positive value signals that the two parameters aren't separately identifiable at 200 trials.

A single simulation of 100 subjects can't establish recovery in general. For a stronger claim, repeat the exercise over many simulated datasets and a plausible range of true parameters. Also check that recovery holds at the parameter values that matter, since a low learning rate such as 0.05 is intrinsically harder to estimate.

## Hierarchical posterior predictive checks

The same logic applies at the group level: let the fitted model generate new data, including rewards, and compare it with the observed data. Behavioural signatures to compare include learning curves, the dependence of choice on recent reward history, and how often subjects switch arms. The last one captures perseveration against exploration.

```r
ppc_group <- function(p, group, n_trials, p_rew, n_draws = 100) {
  idx <- sample(dim(p$alpha)[1], n_draws)
  sapply(idx, function(i) {
    sapply(seq_along(group), function(s) {
      sim_s <- simulate_q(p$alpha[i, s], p$beta[i, s], n_trials, p_rew)
      c(p_best = mean(sim_s$actions == 1),
        switch_rate = mean(diff(sim_s$actions) != 0))
    }, simplify = "array")
  }, simplify = "array")
}

pred_stats <- ppc_group(p, group, n_trials, p_rew)

obs_stats <- tibble(
  group = factor(group, labels = c("Control", "Depressed")),
  p_best = rowMeans(choice == 1),
  switch_rate = apply(choice, 1, function(x) mean(diff(x) != 0))
)
```

Summarise `pred_stats` by group for each draw, then plot the group means against the corresponding observed means. Systematic misses are the useful finding. If the model under-predicts learning speed in the patient group, for instance, then a single learning rate may be missing something about how that group learns. Candidates include separate rates for positive and negative prediction errors, choice perseveration, and value decay. In real data the discrepancies would motivate model refinement. In this simulation we know the generating model, so large misses would point to a coding error.

## Limits and next steps

Hierarchical modelling and predictive checks don't solve model misspecification or heterogeneity, and I'd be cautious about claiming otherwise. They diagnose these problems. Partial pooling can even mask them. If a subset of patients uses a different strategy altogether, a single group-level distribution will give a misleading picture of the group.

Clinical readings need further caution. A posterior difference in α between groups is a statement about a parameter in one model, estimated on one task. It isn't direct evidence about the biological processes behind depression. The better question is how reliably these parameters can be estimated, and whether the model describes the behaviour we care about.

The next post takes up that heterogeneity directly, using mixture models to ask whether patients with the same diagnosis may be using different learning strategies.

## Full code for simulations

``` r
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
