

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

## Addressing Individual Heterogeneity and Mixture Models

One of the most challenging aspects of clinical data analysis is individual heterogeneity. Not all depressed patients show the same computational profile, and some might use entirely different learning strategies than others. Traditional group-level analyses can obscure this heterogeneity, leading to conclusions about "depressed cognition" that don't apply to many individuals in the clinical population.

Mixture models provide one approach to this challenge by allowing different individuals to be governed by different computational processes. For instance, some participants might use Q-learning while others rely on simpler heuristics like Win-Stay-Lose-Shift:

```stan
data {
  int<lower=1> N_subj;
  int<lower=1> N_trials;
  int<lower=1> N_total;
  int<lower=1, upper=N_subj> subj[N_total];
  int<lower=1, upper=2>      choice[N_total];
  int<lower=0, upper=1>      reward[N_total];
  int<lower=0, upper=1>      group[N_subj];   // 0=control, 1=depressed
  int<lower=1> N_strategies;                  // Should be 2
}

parameters {
  // Strategy mixing weights per group (simplex sums to 1)
  simplex[N_strategies] strategy_prob[2];

  // ---- Q-learning parameters (group-level, unconstrained) ----
  vector[2] mu_alpha_ql;
  vector[2] mu_beta_ql;
  vector<lower=0>[2] sigma_alpha_ql;
  vector<lower=0>[2] sigma_beta_ql;

  // ---- WSLS parameters (group-level, unconstrained) ----
  // pstay: P(repeat last choice | rewarded)
  // pshift: P(switch choice | not rewarded)
  vector[2] mu_pstay_wsls;
  vector[2] mu_pshift_wsls;
  vector<lower=0>[2] sigma_pstay_wsls;
  vector<lower=0>[2] sigma_pshift_wsls;

  // ---- Individual-level raw deviations (non-centered) ----
  vector[N_subj] alpha_raw;
  vector[N_subj] beta_raw;
  vector[N_subj] pstay_raw;
  vector[N_subj] pshift_raw;
}

transformed parameters {
  // Constrained individual parameters
  vector<lower=0, upper=1>[N_subj] alpha;   // Q-learning rate in (0,1)
  vector<lower=0>[N_subj]          beta;    // Inverse temperature > 0
  vector<lower=0, upper=1>[N_subj] pstay;  // Win-stay probability in (0,1)
  vector<lower=0, upper=1>[N_subj] pshift; // Lose-shift probability in (0,1)

  for (s in 1:N_subj) {
    int g = group[s] + 1;  // Stan is 1-indexed; group 0->1, group 1->2

    // Q-learning: alpha via Phi_approx (squashes to (0,1)), beta via exp (keeps positive)
    alpha[s]  = Phi_approx(mu_alpha_ql[g]   + sigma_alpha_ql[g]   * alpha_raw[s]);
    beta[s]   = exp(        mu_beta_ql[g]    + sigma_beta_ql[g]    * beta_raw[s]);

    // WSLS: both probabilities via Phi_approx
    pstay[s]  = Phi_approx(mu_pstay_wsls[g] + sigma_pstay_wsls[g] * pstay_raw[s]);
    pshift[s] = Phi_approx(mu_pshift_wsls[g]+ sigma_pshift_wsls[g]* pshift_raw[s]);
  }
}

model {
  // ---- Priors: group-level ----
  mu_alpha_ql     ~ normal(0, 1);
  mu_beta_ql      ~ normal(1, 1);
  sigma_alpha_ql  ~ normal(0, 0.5);
  sigma_beta_ql   ~ normal(0, 0.5);

  mu_pstay_wsls   ~ normal(1, 1);   // Phi_approx(1) ≈ 0.84, reasonable win-stay
  mu_pshift_wsls  ~ normal(1, 1);   // Phi_approx(1) ≈ 0.84, reasonable lose-shift
  sigma_pstay_wsls  ~ normal(0, 0.5);
  sigma_pshift_wsls ~ normal(0, 0.5);

  // Symmetric Dirichlet(2,2) prior — mildly favors equal mixing
  for (g in 1:2)
    strategy_prob[g] ~ dirichlet(rep_vector(2.0, N_strategies));

  // ---- Priors: individual raw deviations (non-centered) ----
  alpha_raw  ~ normal(0, 1);
  beta_raw   ~ normal(0, 1);
  pstay_raw  ~ normal(0, 1);
  pshift_raw ~ normal(0, 1);

  // ---- Mixture Likelihood ----
  {
    int idx = 1;

    for (s in 1:N_subj) {
      int g = group[s] + 1;

      // Accumulate per-strategy log-likelihoods across all trials for subject s
      real ll_ql   = 0;   // Q-learning log-likelihood for subject s
      real ll_wsls = 0;   // WSLS log-likelihood for subject s

      // ----- Q-learning trajectory -----
      vector[2] Q = rep_vector(0.0, 2);

      // ----- WSLS state -----
      // We track the last choice and whether it was rewarded to compute WSLS probs.
      // On trial 1 there is no prior trial, so we use a flat prior (0.5 each choice).
      int   last_choice  = 0;   // 0 = no previous trial yet
      int   last_reward  = -1;

      for (t in 1:N_trials) {
        int c = choice[idx];
        int r = reward[idx];

        // --- Q-learning action probabilities ---
        vector[2] action_prob_ql = softmax(beta[s] * Q);
        ll_ql += categorical_lpmf(c | action_prob_ql);

        // Update Q-value for chosen action (Rescorla-Wagner)
        Q[c] += alpha[s] * (r - Q[c]);

        // --- WSLS action probabilities ---
        vector[2] action_prob_wsls;
        if (last_choice == 0) {
          // First trial: uniform over choices
          action_prob_wsls = rep_vector(0.5, 2);
        } else {
          // Determine WSLS probability of repeating last choice
          real p_repeat;
          if (last_reward == 1)
            p_repeat = pstay[s];    // Win → stay
          else
            p_repeat = 1 - pshift[s]; // Lose → shift (so p_repeat = 1 - pshift)

          // Build probability vector over choices {1, 2}
          action_prob_wsls[last_choice]     = p_repeat;
          action_prob_wsls[3 - last_choice] = 1 - p_repeat; // 3-1=2 or 3-2=1
        }
        ll_wsls += categorical_lpmf(c | action_prob_wsls);

        // Update WSLS state
        last_choice = c;
        last_reward = r;
        idx += 1;
      }

      // ---- Mix the two log-likelihoods using log_sum_exp ----
      // log p(data_s) = log[ π_ql * L_ql  +  π_wsls * L_wsls ]
      //              = log_sum_exp( log(π_ql) + ll_ql,
      //                            log(π_wsls) + ll_wsls )
      vector[N_strategies] log_lik_strategy;
      log_lik_strategy[1] = log(strategy_prob[g][1]) + ll_ql;
      log_lik_strategy[2] = log(strategy_prob[g][2]) + ll_wsls;

      target += log_sum_exp(log_lik_strategy);
    }
  }
}

generated quantities {
  // Per-observation log-likelihoods for LOO-CV
  vector[N_total] log_lik;

  // Posterior strategy assignment probability per subject
  // P(subject s uses strategy k) = softmax of log_lik_strategy
  matrix[N_subj, N_strategies] strategy_assignment;

  // Group-level differences
  real group_diff_alpha;   // Depressed - control mean Q-learning rate
  real group_diff_beta;    // Depressed - control mean inverse temperature
  real group_diff_pstay;   // Depressed - control mean win-stay probability
  real group_diff_pshift;  // Depressed - control mean lose-shift probability
  real group_diff_ql_prob; // Depressed - control probability of using Q-learning

  {
    int idx = 1;

    for (s in 1:N_subj) {
      int g = group[s] + 1;

      real ll_ql   = 0;
      real ll_wsls = 0;

      vector[2] Q           = rep_vector(0.0, 2);
      int   last_choice     = 0;
      int   last_reward     = -1;

      for (t in 1:N_trials) {
        int c = choice[idx];
        int r = reward[idx];

        // Q-learning
        vector[2] action_prob_ql = softmax(beta[s] * Q);
        real trial_ll_ql         = categorical_lpmf(c | action_prob_ql);
        ll_ql += trial_ll_ql;
        Q[c]  += alpha[s] * (r - Q[c]);

        // WSLS
        vector[2] action_prob_wsls;
        if (last_choice == 0) {
          action_prob_wsls = rep_vector(0.5, 2);
        } else {
          real p_repeat = (last_reward == 1) ? pstay[s] : (1 - pshift[s]);
          action_prob_wsls[last_choice]     = p_repeat;
          action_prob_wsls[3 - last_choice] = 1 - p_repeat;
        }
        real trial_ll_wsls = categorical_lpmf(c | action_prob_wsls);
        ll_wsls += trial_ll_wsls;

        // Per-trial log_lik: marginalise over strategies
        vector[N_strategies] trial_log_mix;
        trial_log_mix[1] = log(strategy_prob[g][1]) + trial_ll_ql;
        trial_log_mix[2] = log(strategy_prob[g][2]) + trial_ll_wsls;
        log_lik[idx] = log_sum_exp(trial_log_mix);

        last_choice = c;
        last_reward = r;
        idx += 1;
      }

      // Posterior probability of each strategy for subject s
      vector[N_strategies] log_post_strategy;
      log_post_strategy[1] = log(strategy_prob[g][1]) + ll_ql;
      log_post_strategy[2] = log(strategy_prob[g][2]) + ll_wsls;
      strategy_assignment[s] = to_row_vector(softmax(log_post_strategy));
    }
  }

  // Group differences (depressed [index 2] minus control [index 1])
  group_diff_alpha   = Phi_approx(mu_alpha_ql[2])    - Phi_approx(mu_alpha_ql[1]);
  group_diff_beta    = exp(mu_beta_ql[2])             - exp(mu_beta_ql[1]);
  group_diff_pstay   = Phi_approx(mu_pstay_wsls[2])  - Phi_approx(mu_pstay_wsls[1]);
  group_diff_pshift  = Phi_approx(mu_pshift_wsls[2]) - Phi_approx(mu_pshift_wsls[1]);
  group_diff_ql_prob = strategy_prob[2][1]            - strategy_prob[1][1];
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

In this post we saw parameter recovery in computational psychiatry starts with fitting a principled Bayesian inference that accounts for uncertainty, then moving forward to individual differences analysis and model comparison. When applied to clinical reinforcement learning data, these approaches could reveal the computational mechanisms underlying psychiatric symptoms and guide the development of more targeted interventions. The key insight is that computational parameters are not just statistical estimates—they represent hypotheses about the cognitive processes that generate behavior. Validating these hypotheses through posterior predictive checking, model comparison, and clinical correlation analysis is essential for ensuring that computational psychiatry delivers on its promise of mechanistic insight into mental health. As the field matures, the focus should shift from demonstrating that computational models can be fit to clinical data toward establishing which models provide reliable, validated, and clinically actionable insights into psychiatric conditions. This requires the kind of rigorous Bayesian parameter recovery approaches demonstrated here, applied at scale to diverse clinical populations performing validated behavioral tasks.

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
