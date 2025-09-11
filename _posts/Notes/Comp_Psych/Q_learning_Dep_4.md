# Parameter Recovery in Computational Psychiatry: Bayesian Analysis of Clinical Reinforcement Learning Data

Computational psychiatry holds immense promise for understanding the mechanisms underlying mental health disorders, but translating theoretical models into clinical insights requires careful attention to parameter recovery and model validation. When we collect behavioral data from clinical populations performing reinforcement learning tasks, we face a fundamental question: can we reliably recover the computational parameters that drove their behavior, and what do these parameters tell us about psychiatric symptoms?

This post demonstrates how to apply Bayesian parameter recovery techniques to real clinical data, focusing on the practical challenges of working with behavioral datasets where we assume an underlying reinforcement learning process generated the observed choices. We'll explore how to validate our parameter estimates, assess model reliability, and interpret individual differences in a clinically meaningful way.

## The Parameter Recovery Challenge in Clinical Data

Unlike controlled simulation studies where we know the true generating parameters, clinical behavioral data presents unique challenges. When a depressed patient performs 200 trials of a two-armed bandit task, we observe only their choices and outcomes—the underlying learning rate, reward sensitivity, and decision noise remain hidden. Yet these latent parameters may be precisely what distinguishes healthy from pathological cognition.

The stakes for accurate parameter recovery are high in clinical contexts. If we conclude that depression involves reduced learning rates based on model fitting, this could influence treatment decisions, theoretical understanding, and future research directions. But what if our parameter estimates are unreliable due to limited data, model misspecification, or individual heterogeneity? Bayesian approaches provide tools to quantify this uncertainty and validate our computational inferences.

Consider a typical clinical dataset: 50 depressed patients and 50 healthy controls, each completing 200 trials of a probabilistic learning task. Standard analysis might fit Q-learning models to each participant, extract point estimates of α (learning rate) and β (inverse temperature), then compare group means with t-tests. This approach ignores parameter uncertainty, model fit quality, and the possibility that different individuals might be using entirely different learning strategies.

## Hierarchical Bayesian Parameter Recovery

A more principled approach treats parameter recovery as a hierarchical inference problem. Rather than estimating parameters independently for each individual, we simultaneously model individual-level parameters and group-level distributions. This approach provides several advantages: improved parameter estimates through partial pooling, explicit modeling of individual differences, and natural incorporation of group-level comparisons.

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

This hierarchical structure enables several key improvements over individual fitting approaches. First, participants with limited or noisy data borrow strength from the group, leading to more stable parameter estimates. Second, we explicitly model the distribution of individual differences within each group, capturing heterogeneity that might be clinically relevant. Third, group comparisons emerge naturally from the posterior distributions rather than requiring separate statistical tests.

## Validating Parameter Recovery with Posterior Predictive Checks

Parameter estimates are only meaningful if our model adequately captures the behavioral patterns in the data. Posterior predictive checking provides a systematic approach to model validation by generating simulated data from fitted models and comparing against observed behavior.

For clinical RL data, several behavioral signatures are particularly important to capture:

**Learning Curves**: Does the model reproduce the trial-by-trial evolution of choice preferences? Healthy individuals might show rapid convergence to optimal choices, while depressed participants might show slower or more volatile learning.

**Choice Consistency**: How well does the model capture the relationship between choice probability and reward history? Individual differences in this relationship might reflect distinct computational phenotypes.

**Perseveration vs. Exploration**: Can the model account for how participants balance exploitation of known good options against exploration of alternatives? This balance might be disrupted in various psychiatric conditions.

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

## Addressing Individual Heterogeneity and Mixture Models

One of the most challenging aspects of clinical data analysis is individual heterogeneity. Not all depressed patients show the same computational profile, and some might use entirely different learning strategies than others. Traditional group-level analyses can obscure this heterogeneity, leading to conclusions about "depressed cognition" that don't apply to many individuals in the clinical population.

Mixture models provide one approach to this challenge by allowing different individuals to be governed by different computational processes. For instance, some participants might use Q-learning while others rely on simpler heuristics like Win-Stay-Lose-Shift:

```stan
data {
  // [Same as hierarchical model plus:]
  int<lower=1> N_strategies;    // Number of possible strategies (e.g., 2)
}

parameters {
  // Strategy selection
  simplex[N_strategies] strategy_prob[2];  // Strategy probabilities by group
  
  // Strategy-specific parameters
  vector[2] mu_alpha_ql;       // Q-learning parameters by group
  vector[2] mu_beta_ql;
  vector[2] mu_pstay_wsls;     // WSLS parameters by group
  vector[2] mu_pshift_wsls;
  
  // [Additional variance parameters and individual effects]
}

model {
  // [Mixture likelihood combining Q-learning and WSLS]
  for (s in 1:N_subj) {
    vector[N_strategies] log_lik_strategy = rep_vector(0, N_strategies);
    
    // Q-learning likelihood
    log_lik_strategy[1] = compute_ql_likelihood(s, alpha[s], beta[s]);
    
    // WSLS likelihood  
    log_lik_strategy[2] = compute_wsls_likelihood(s, pstay[s], pshift[s]);
    
    // Weight by strategy probabilities
    target += log_sum_exp(log(strategy_prob[group[s] + 1]) + log_lik_strategy);
  }
}
```

This approach reveals whether clinical populations are characterized by altered parameters within preserved computational architectures (e.g., reduced learning rates in Q-learning) or fundamental changes in learning strategies (e.g., shift from Q-learning to simple heuristics). The clinical implications differ substantially: parameter changes might respond to targeted interventions, while strategy changes might require different therapeutic approaches.

## Computational Psychiatry Applications: Beyond Group Differences

The ultimate goal of computational psychiatry is not just to identify group differences, but to link computational parameters to clinically relevant outcomes. Parameter recovery techniques enable several important applications:

**Symptom Prediction**: Can computational parameters predict symptom severity or treatment response? If learning rate α correlates with anhedonia scores, this suggests mechanistic links between reinforcement learning and motivational symptoms.

**Longitudinal Tracking**: How do computational parameters change over time, treatment, or mood episodes? Reliable parameter recovery enables tracking of computational "vital signs" that might predict relapse or recovery.

**Personalized Medicine**: Can individual computational profiles guide treatment selection? Patients with low learning rates might benefit from different interventions than those with high decision noise.

**Biological Validation**: Do recovered parameters correlate with neural measures or genetic variants? Such convergent validity strengthens confidence in computational interpretations.

```r
# Clinical correlation analysis
analyze_clinical_correlations <- function(fit, clinical_data) {
  posterior_means <- summary(fit, pars = c("alpha", "beta"))$summary[, "mean"]
  
  # Extract individual parameter estimates
  alpha_estimates <- posterior_means[grep("alpha\\[", names(posterior_means))]
  beta_estimates <- posterior_means[grep("beta\\[", names(posterior_means))]
  
  # Correlate with clinical measures
  depression_scores <- clinical_data$beck_depression_inventory
  anhedonia_scores <- clinical_data$snaith_hamilton_pleasure_scale
  
  # Bayesian correlation analysis accounting for parameter uncertainty
  correlation_results <- list(
    alpha_depression = cor.test(alpha_estimates, depression_scores),
    alpha_anhedonia = cor.test(alpha_estimates, anhedonia_scores),
    beta_depression = cor.test(beta_estimates, depression_scores),
    beta_anhedonia = cor.test(beta_estimates, anhedonia_scores)
  )
  
  return(correlation_results)
}
```

## Model Comparison and Selection in Clinical Contexts

When working with clinical data, we often face competing hypotheses about which computational models best explain observed behavior. Rather than assuming Q-learning applies universally, Bayesian model comparison enables principled evaluation of alternative frameworks:

```r
# Comprehensive model comparison
compare_clinical_models <- function(data) {
  models <- list(
    "Q-learning" = fit_q_learning(data),
    "WSLS" = fit_wsls(data),  
    "Dual-system" = fit_dual_system(data),
    "Decay" = fit_q_learning_decay(data)
  )
  
  # Compute information criteria
  loo_results <- map(models, ~ loo(extract_log_lik(.x)))
  loo_comparison <- loo_compare(loo_results)
  
  # Weight models by evidence
  model_weights <- loo_model_weights(loo_results)
  
  return(list(
    comparison = loo_comparison,
    weights = model_weights,
    best_model = rownames(loo_comparison)[1]
  ))
}
```

The results of model comparison can reveal important insights about psychiatric populations. If depressed individuals are better explained by simpler heuristic models while controls are better explained by Q-learning, this suggests cognitive simplification under depressive symptoms. Alternatively, if both groups are best explained by the same model but with different parameters, this supports mechanistic hypotheses about altered but preserved computational processes.

## Practical Considerations and Limitations

Several practical issues deserve attention when applying these methods to clinical data:

**Sample Size Requirements**: Hierarchical Bayesian models require adequate sample sizes at both individual and group levels. Underpowered studies may show unreliable parameter estimates or spurious group differences.

**Data Quality**: Clinical populations may show increased noise, missing data, or task non-compliance. Robust modeling approaches and careful data preprocessing become crucial.

**Clinical Interpretation**: Statistical significance of parameter differences doesn't guarantee clinical significance. Effect sizes, confidence intervals, and correlation with symptoms provide more meaningful measures of clinical relevance.

**Generalizability**: Parameters recovered from specific tasks may not generalize to real-world behavior. Validation across multiple paradigms strengthens computational interpretations.

## Future Directions: Toward Computational Clinical Tools

The long-term vision for computational psychiatry involves translating parameter recovery techniques into clinical decision-making tools. Several developments could accelerate this translation:

**Real-time Parameter Estimation**: Online Bayesian updating could enable parameter tracking during behavioral assessment, providing immediate computational profiles for clinical use.

**Multi-modal Integration**: Combining behavioral parameters with neural, genetic, and clinical data could improve prediction accuracy and mechanistic understanding.

**Treatment Matching**: Large-scale studies could identify computational profiles that predict treatment response, enabling precision medicine approaches in psychiatry.

**Digital Therapeutics**: Understanding individual computational parameters could guide personalized cognitive interventions delivered through digital platforms.

## Conclusion

Parameter recovery in computational psychiatry requires moving beyond simple model fitting toward principled Bayesian inference that accounts for uncertainty, individual differences, and model comparison. When applied to clinical reinforcement learning data, these approaches can reveal the computational mechanisms underlying psychiatric symptoms and guide the development of more targeted interventions.

The key insight is that computational parameters are not just statistical estimates—they represent hypotheses about the cognitive processes that generate behavior. Validating these hypotheses through posterior predictive checking, model comparison, and clinical correlation analysis is essential for ensuring that computational psychiatry delivers on its promise of mechanistic insight into mental health.

As the field matures, the focus should shift from demonstrating that computational models can be fit to clinical data toward establishing which models provide reliable, validated, and clinically actionable insights into psychiatric conditions. This requires the kind of rigorous Bayesian parameter recovery approaches demonstrated here, applied at scale to diverse clinical populations performing validated behavioral tasks.

The future of computational psychiatry depends on our ability to extract reliable computational signatures from behavioral data and translate these signatures into improved understanding and treatment of mental health conditions. Bayesian parameter recovery provides the methodological foundation for this translation, but success will ultimately depend on careful validation, clinical integration, and therapeutic application of computational insights.
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
