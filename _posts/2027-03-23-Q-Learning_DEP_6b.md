---
editor_options: 
  markdown: 
    wrap: 72
---

# Comparing Mechanisms and Recovering Group Differences: WSLS, Q-Learning and a Hierarchical Clinical Model

I haven't run the Stan code, so the post reports no fitted output. The one number I did compute is the expected true group difference, from 10⁶ draws of the generating distributions. I've marked where your own results should go. I've also flagged a few problems in the code that you should fix before publishing.

***

The previous post argued that a parameter estimate is only worth interpreting if we know how well it can be recovered. Here I apply that argument to two practical questions. First, does the behaviour need incremental value learning at all, or does a simple win–stay/lose–shift (WSLS) rule account for it equally well? Second, if we do commit to Q-learning, can a hierarchical model recover a group difference between 50 controls and 50 patients, each with only 200 trials?

## Part 1: A model without values

WSLS has no value function. It has two parameters:

- `p_stay`: the probability of repeating the previous action after a reward.
- `p_shift`: the probability of switching after no reward.

The first trial has no history, so it contributes nothing to the likelihood and the loop starts at trial 2.

```r
stan_model_2 <- '
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
    if (R[n - 1] == 1) target += bernoulli_lpmf((A[n] == A[n - 1]) | p_stay);
    else               target += bernoulli_lpmf((A[n] != A[n - 1]) | p_shift);
  }
}
generated quantities {
  vector[N - 1] log_lik;
  for (n in 2:N) {
    if (R[n - 1] == 1) log_lik[n - 1] = bernoulli_lpmf((A[n] == A[n - 1]) | p_stay);
    else               log_lik[n - 1] = bernoulli_lpmf((A[n] != A[n - 1]) | p_shift);
  }
}
'
```

Two changes from the original code matter here. The array declarations use current Stan syntax, and the ternary `? 1 : 0` is replaced by a parenthesised comparison, which Stan accepts as an integer outcome. The log-likelihood vector also has length N − 1 instead of padding the first trial with 0. Padding matters for model comparison, as the next section explains.

Fitting and prediction follow the same pattern as the Q-learning model. For each trial we compute the probability of choosing arm 1 given the previous action and outcome, then bin the predictions in windows of 50 trials against observed choice frequencies.

```r
fit_wsls <- stan(model_code = stan_model_2, data = stan_data,
                 iter = 2000, warmup = 1000, chains = 4, seed = 42)
print(fit_wsls, pars = c("p_stay", "p_shift"))
```

One caution on interpreting this check. The prediction at each trial conditions on the actual previous action and reward, so it is a one-step-ahead prediction. It will follow the data closely whenever choices are autocorrelated, which they usually are for any reasonable model. A close match here doesn't validate the model. A visible mismatch does count against it.

## Part 2: Which model predicts better?

Leave-one-out cross-validation (LOO) estimates each model's expected log predictive density on held-out observations. Differences are reported with a standard error.

```r
log_lik_q    <- extract_log_lik(fit_q,    "log_lik")
log_lik_wsls <- extract_log_lik(fit_wsls, "log_lik")
loo_compare(loo(log_lik_q), loo(log_lik_wsls))
```

The two log-likelihood matrices must cover the same observations. In the original code the Q-learning model scored all N trials, including trial 1, where it assigns probability 0.5. The WSLS model assigned a log-likelihood of 0 to trial 1, which is a probability of 1. That offset of about 0.69 favours WSLS by a constant, and it is small only because N is large. The cleanest fix is to drop trial 1 from both models. The Q-learning model should still update its values on trial 1 but store its log-likelihood from trial 2 onward, as in the first post.

How to read the result depends on the generating process, and a single comparison can mislead. A Q-learning agent with high β, such as the healthy-like agent (α = 0.4, β = 5), repeats rewarded choices and switches after losses fairly reliably. WSLS may therefore fit it reasonably well. A low-α, low-β agent (α = 0.05, β = 2) integrates outcomes over many trials, which WSLS can't represent. I'd expect the difference to be larger for that agent, but this is an expectation, not a result. To find out, simulate from each model, fit both, and count how often LOO picks the generating model. That is model recovery, and it is as important as parameter recovery.

## Part 3: Hierarchical recovery of group differences

The second script scales up to 100 simulated subjects, 200 trials each. Each person has α_s and β_s drawn from group-specific distributions on the logit and log scales:

$$
\text{logit}(\alpha_s) \sim \mathcal{N}(\mu_{\alpha,g}, \sigma_{\alpha,g}^2), \qquad
\log(\beta_s) \sim \mathcal{N}(\mu_{\beta,g}, \sigma_{\beta,g}^2)
$$

The true values are μ_α = (−0.2, −0.6), σ_α = (0.5, 0.6) for controls and patients respectively. For β they are μ_β = (log 4, log 2.5) and σ_β = (0.35, 0.45). The task is a bandit with reward probabilities 0.7 and 0.3.

These settings fix a target. Averaging over the generating distributions, the expected mean learning rate is about 0.45 for controls and 0.36 for patients, a difference of roughly 0.09. The mean inverse temperature is about 4.25 against 2.77, a difference of about 1.49. So the simulated groups differ modestly in α and more clearly in β. This is a deliberate design choice, and it matters for what follows: a hierarchical model that recovers the β difference comfortably but struggles with the α difference would be behaving as expected, not failing.

The Stan model uses a non-centred parameterisation. Subject-level raw values are standard normal and are scaled by the group mean and SD:

```stan
alpha[s] = inv_logit(mu_alpha[group[s] + 1] + sigma_alpha[group[s] + 1] * alpha_raw[s]);
beta[s]  = exp(mu_beta[group[s] + 1]  + sigma_beta[group[s] + 1]  * beta_raw[s]);
```

The hyperpriors are weakly informative: `mu_alpha ~ normal(0, 1)`, `mu_beta ~ normal(1, 1)`, and half-normal(0, 0.5) for both SDs. The generated quantities block computes two contrasts, the difference in mean subject-level α and β between the first and second groups. Because the groups are ordered control then depressed, a positive value means higher in controls. State this sign convention in the post, since readers often assume the opposite.

```r
fit <- stan(model_code = stan_code, data = stan_data,
            chains = 4, iter = 2000, warmup = 1000, seed = 1234)

print(fit, pars = c("mu_alpha", "mu_beta", "sigma_alpha", "sigma_beta",
                    "group_diff_alpha", "group_diff_beta"),
      probs = c(0.025, 0.5, 0.975))
```

### What to report

Paste your actual output here. Before interpreting any contrast, report convergence: R-hat, effective sample sizes and the number of divergent transitions. Then compare the posteriors of `group_diff_alpha` and `group_diff_beta` with the true values above (about 0.09 and 1.49). Three questions are worth answering explicitly:

- Does the 95% credible interval contain the true difference? A single simulation can't establish calibration, but a miss in one dataset is informative.
- How wide is the interval for α relative to its true size? If it comfortably includes zero, 200 trials per subject may be too few to detect a difference of this size.
- Are subject-level estimates shrunk toward their group means? Some shrinkage is the point of partial pooling, but it also compresses the spread of recovered values.

### Problems in the code to fix

**Missing recovery step.** The script computes group contrasts, but it never compares recovered subject-level parameters with `alpha_true` and `beta_true`, which are sitting in memory. Adding correlation, bias and interval coverage takes a few lines and is what the post is about:

```r
alpha_draws <- rstan::extract(fit)$alpha
beta_draws  <- rstan::extract(fit)$beta
c(r_alpha = cor(alpha_true, colMeans(alpha_draws)),
  r_beta  = cor(beta_true,  colMeans(beta_draws)),
  cover_alpha = mean(alpha_true >= apply(alpha_draws, 2, quantile, .025) &
                     alpha_true <= apply(alpha_draws, 2, quantile, .975)))
```

**Name collision.** The WSLS script and the hierarchical script both define `sim_data`, with different structures. If both are run in one session, the second overwrites the first. Use different names, for example `sim_single` and `sim_group`.

**Hard-coded group layout.** `group_diff_alpha` uses `segment(alpha, 1, n_subj_per_group)`, which assumes controls come first and groups are equal in size. This holds in the simulation. In real data it breaks silently. Index by the `group` vector instead.

**The `y_rep` check is weak.** `y_rep[i] = categorical_logit_rng(beta[s] * Q)` is a one-step-ahead prediction using the observed rewards and updating Q from the observed choice. It will track the data well even for a poor model. A stronger check simulates each subject's full sequence from the posterior, with rewards drawn from the environment, and compares summaries such as proportion of best-arm choices and switch rate by group. Part 2 of the previous post gives code for that.

**Unused data.** `subj` is passed to Stan but never used, since the indexing is `(s - 1) * N_trials + t`. This works only if trials are ordered by subject, with exactly `N_trials` each. That holds in the simulation but not in real data with missing trials.

**Pointwise log-likelihood.** The 20,000-element `log_lik` is suitable for LOO but treats trials as exchangeable. In sequential learning, trial-level cross-validation can overstate predictive performance. Leave-one-subject-out comparison, using a summed log-likelihood per subject, is more defensible for questions about people.

## Limits

Everything here is simulated. The data were generated by the same Q-learning process that the model fits, so the results show what the method can do under ideal conditions. Real patients' behaviour will deviate in ways we haven't modelled. Positive and negative prediction errors may be weighted differently, choices may be sticky regardless of reward, and values may decay. A group difference in α estimated under a misspecified model may partly reflect those omitted features.

There is a second limit. Even a perfectly recovered group difference in a model parameter doesn't show what causes it. The parameter is a summary of behaviour on one task. Interpreting it as a mechanism of depression requires converging evidence from other tasks, other samples and, ideally, other measures.

The next post addresses a related problem. If some patients use WSLS-like strategies and others use incremental learning, a single group distribution misdescribes both. Mixture models estimate which strategy each person is likely using, and the comparison here is where that question starts.


``` r
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

``` r
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
