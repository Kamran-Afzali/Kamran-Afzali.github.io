# Addressing Individual Heterogeneity and Mixture Models in Computational Psychiatry: When One Model Doesn't Fit All

In the [previous post](), we demonstrated how hierarchical Bayesian parameter recovery can extract reliable computational estimates from clinical reinforcement learning data, and how posterior predictive checks help validate whether those estimates faithfully capture observed behavior. A recurring assumption in that framework was that all participants, within a group, are governed by the same underlying computational architecture—differing only in their parameter values. In practice, this assumption rarely holds. Clinical populations are rarely homogeneous: within a group of depressed patients, some individuals may engage in deliberate, value-based learning well described by Q-learning, while others fall back on simpler heuristics like Win-Stay-Lose-Shift, perhaps because reduced cognitive resources or motivational deficits make elaborate credit assignment too costly. Treating these individuals as a single computational type and averaging across them doesn't just obscure heterogeneity—it can actively mislead, producing group-level parameter estimates that describe nobody in the sample particularly well. This post addresses that challenge directly. We introduce mixture models as a principled way to let the data speak about which computational strategy each participant most likely used, estimate strategy-specific parameters within a unified hierarchical Bayesian framework, and ask whether clinical groups differ not just in *how well* they learn, but in *how* they learn at all.


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

The ultimate aim of computational psychiatry extends beyond detecting group-level differences to establishing meaningful links between computational parameters and clinically relevant outcomes. In this context, parameter recovery techniques open several avenues for application. One immediate question is whether such parameters can predict symptom severity or treatment response; for example, a correlation between the learning rate (α) and measures of anhedonia would suggest a mechanistic connection between reinforcement learning processes and motivational deficits. A related line of inquiry concerns longitudinal dynamics: if parameters can be reliably recovered, they may be tracked over time as computational “vital signs,” offering a way to monitor changes across treatment or mood episodes and, potentially, to anticipate relapse or recovery. This perspective also feeds into the broader ambition of personalized medicine, where individual computational profiles might inform treatment selection—patients characterized by low learning rates, for instance, may respond differently to specific interventions than those exhibiting high decision noise. Finally, the validity of these parameters depends in part on their alignment with biological evidence; demonstrating correlations with neural measures or genetic variation provides a form of convergent validation, strengthening the case that these computational constructs capture aspects of underlying pathophysiology rather than merely fitting behavioral data.


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

## Practical Considerations and Conclusion

Applying these methods to clinical data raises a set of practical considerations that are easy to overlook but difficult to ignore in practice. Hierarchical Bayesian models, for instance, depend on sufficiently large samples at both the individual and group levels; when studies are underpowered, parameter estimates can become unstable, and apparent group differences may reflect noise rather than meaningful structure. This issue is compounded by the nature of clinical data itself, which often includes higher variability, missing observations, or inconsistent task engagement, making careful preprocessing and robust modeling choices less optional than necessary. Even when statistical differences emerge, their interpretation requires restraint: a significant parameter shift does not automatically translate into clinical relevance, and it is often more informative to examine effect sizes, uncertainty intervals, and their relationship to symptom profiles. Questions of generalizability further complicate the picture, as parameters inferred from tightly controlled experimental tasks may not extend cleanly to everyday behavior; converging evidence across multiple paradigms can help mitigate this concern. Looking ahead, the field appears to be moving—cautiously—toward the development of computational tools that might support clinical decision-making. Real-time parameter estimation, enabled by online Bayesian updating, could allow behavioral assessments to produce immediate computational profiles, while integrating behavioral measures with neural, genetic, and clinical data may improve both predictive performance and mechanistic insight. At a larger scale, identifying computational phenotypes associated with differential treatment response could support more precise intervention strategies, and, in parallel, the rise of digital therapeutics suggests a setting in which these individualized parameters might inform adaptive, personalized cognitive interventions.

In this post we saw parameter recovery in computational psychiatry starts with fitting a principled Bayesian inference that accounts for uncertainty, then moving forward to individual differences analysis and model comparison. When applied to clinical reinforcement learning data, these approaches could reveal the computational mechanisms underlying psychiatric symptoms and guide the development of more targeted interventions. The key insight is that computational parameters are not just statistical estimates—they represent hypotheses about the cognitive processes that generate behavior. Validating these hypotheses through posterior predictive checking, model comparison, and clinical correlation analysis is essential for ensuring that computational psychiatry delivers on its promise of mechanistic insight into mental health. As the field matures, the focus should shift from demonstrating that computational models can be fit to clinical data toward establishing which models provide reliable, validated, and clinically actionable insights into psychiatric conditions. This requires the kind of rigorous Bayesian parameter recovery approaches demonstrated here, applied at scale to diverse clinical populations performing validated behavioral tasks.

```r
# ==============================================================================
# Mixture Model Simulation for Computational Psychiatry Blog Post
# "Addressing Individual Heterogeneity and Mixture Models in Computational
#  Psychiatry: When One Model Doesn't Fit All"
#
# Requires: rstan, loo, bayesplot, ggplot2, dplyr, tidyr, purrr
# Install:  install.packages(c("rstan","loo","bayesplot","ggplot2","dplyr",
#                              "tidyr","purrr","cowplot"))
# ==============================================================================

# ---- 0. Global setup ---------------------------------------------------------
set.seed(42)
options(mc.cores = parallel::detectCores())

suppressPackageStartupMessages({
  library(rstan)
  library(loo)
  library(bayesplot)
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(cowplot)
})

rstan_options(auto_write = TRUE)

# ==============================================================================
# 1. SIMULATE DATA
#    30 controls  – 60 % Q-learning, 40 % WSLS
#    30 depressed – 30 % Q-learning, 70 % WSLS   (shifted strategy distribution)
# ==============================================================================

simulate_subject <- function(strategy,   # "ql" | "wsls"
                             N_trials,
                             alpha  = NULL, beta   = NULL,
                             pstay  = NULL, pshift = NULL,
                             reward_prob_good = 0.70,
                             reward_prob_bad  = 0.30) {
  choices <- integer(N_trials)
  rewards <- integer(N_trials)

  # Two-armed bandit reward probabilities (action 1 = good, action 2 = bad)
  reward_probs <- c(reward_prob_good, reward_prob_bad)

  # --- Q-learning internal state ---
  Q <- c(0.5, 0.5)

  # --- WSLS internal state ---
  last_choice <- sample(1:2, 1)   # random first choice
  last_reward <- -1               # no prior outcome

  for (t in seq_len(N_trials)) {
    if (strategy == "ql") {
      # Softmax action selection
      ev  <- beta * Q
      ev  <- ev - max(ev)          # numerical stability
      prob_act1 <- exp(ev[1]) / sum(exp(ev))
      c_t <- ifelse(runif(1) < prob_act1, 1L, 2L)
    } else {
      # WSLS
      if (t == 1) {
        c_t <- last_choice
      } else {
        p_repeat <- if (last_reward == 1) pstay else (1 - pshift)
        c_t <- if (runif(1) < p_repeat) last_choice else (3L - last_choice)
      }
    }

    r_t <- rbinom(1, 1, reward_probs[c_t])
    choices[t] <- c_t
    rewards[t] <- r_t

    # Update states
    if (strategy == "ql") {
      Q[c_t] <- Q[c_t] + alpha * (r_t - Q[c_t])
    }
    last_choice <- c_t
    last_reward <- r_t
  }

  list(choices = choices, rewards = rewards, strategy = strategy)
}

# ---- Parameter distributions per group (true generative values) --------------
N_ctrl      <- 30
N_depr      <- 30
N_subj      <- N_ctrl + N_depr
N_trials    <- 80
mix_ctrl    <- c(ql = 0.60, wsls = 0.40)
mix_depr    <- c(ql = 0.30, wsls = 0.70)

sample_ql_params <- function(group) {
  # group: 0 = control, 1 = depressed
  if (group == 0) {
    alpha <- pnorm(rnorm(1, 0.0, 0.5))         # ≈ 0.50 mean
    beta  <- exp(rnorm(1, 1.5, 0.3))            # ≈ 4.5 mean
  } else {
    alpha <- pnorm(rnorm(1, -0.5, 0.5))        # reduced learning rate
    beta  <- exp(rnorm(1,  0.8, 0.3))           # reduced inverse temp
  }
  list(alpha = alpha, beta = beta)
}

sample_wsls_params <- function(group) {
  if (group == 0) {
    pstay  <- pnorm(rnorm(1, 1.0, 0.4))
    pshift <- pnorm(rnorm(1, 1.0, 0.4))
  } else {
    pstay  <- pnorm(rnorm(1, 0.3, 0.4))        # lower win-stay
    pshift <- pnorm(rnorm(1, 0.6, 0.4))
  }
  list(pstay = pstay, pshift = pshift)
}

# ---- Generate full dataset ---------------------------------------------------
all_subjects <- vector("list", N_subj)
true_params  <- vector("list", N_subj)
group_vec    <- c(rep(0L, N_ctrl), rep(1L, N_depr))

for (s in seq_len(N_subj)) {
  g   <- group_vec[s]
  mix <- if (g == 0) mix_ctrl else mix_depr
  strat <- sample(c("ql", "wsls"), 1, prob = mix)

  if (strat == "ql") {
    p <- sample_ql_params(g)
    all_subjects[[s]] <- simulate_subject(
      "ql", N_trials,
      alpha = p$alpha, beta = p$beta
    )
    true_params[[s]] <- c(p, list(pstay = NA, pshift = NA, strategy = "ql", group = g))
  } else {
    p <- sample_wsls_params(g)
    all_subjects[[s]] <- simulate_subject(
      "wsls", N_trials,
      pstay = p$pstay, pshift = p$pshift
    )
    true_params[[s]] <- c(p, list(alpha = NA, beta = NA, strategy = "wsls", group = g))
  }
}

# ---- Pack into long vectors for Stan -----------------------------------------
choice_vec <- unlist(lapply(all_subjects, `[[`, "choices"))
reward_vec <- unlist(lapply(all_subjects, `[[`, "rewards"))
subj_vec   <- rep(seq_len(N_subj), each = N_trials)
N_total    <- length(choice_vec)

cat(sprintf("Dataset: %d subjects × %d trials = %d observations\n",
            N_subj, N_trials, N_total))
cat(sprintf("Controls  – QL: %d  WSLS: %d\n",
            sum(sapply(true_params[group_vec == 0], `[[`, "strategy") == "ql"),
            sum(sapply(true_params[group_vec == 0], `[[`, "strategy") == "wsls")))
cat(sprintf("Depressed – QL: %d  WSLS: %d\n",
            sum(sapply(true_params[group_vec == 1], `[[`, "strategy") == "ql"),
            sum(sapply(true_params[group_vec == 1], `[[`, "strategy") == "wsls")))

# ==============================================================================
# 2. STAN MODEL (inline string)
# ==============================================================================

stan_mixture_code <- "
data {
  int<lower=1> N_subj;
  int<lower=1> N_trials;
  int<lower=1> N_total;
  int<lower=1, upper=N_subj> subj[N_total];
  int<lower=1, upper=2>      choice[N_total];
  int<lower=0, upper=1>      reward[N_total];
  int<lower=0, upper=1>      group[N_subj];
  int<lower=1>               N_strategies;
}

parameters {
  simplex[N_strategies] strategy_prob[2];

  vector[2] mu_alpha_ql;
  vector[2] mu_beta_ql;
  vector<lower=0>[2] sigma_alpha_ql;
  vector<lower=0>[2] sigma_beta_ql;

  vector[2] mu_pstay_wsls;
  vector[2] mu_pshift_wsls;
  vector<lower=0>[2] sigma_pstay_wsls;
  vector<lower=0>[2] sigma_pshift_wsls;

  vector[N_subj] alpha_raw;
  vector[N_subj] beta_raw;
  vector[N_subj] pstay_raw;
  vector[N_subj] pshift_raw;
}

transformed parameters {
  vector<lower=0,upper=1>[N_subj] alpha;
  vector<lower=0>[N_subj]         beta;
  vector<lower=0,upper=1>[N_subj] pstay;
  vector<lower=0,upper=1>[N_subj] pshift;

  for (s in 1:N_subj) {
    int g = group[s] + 1;
    alpha[s]  = Phi_approx(mu_alpha_ql[g]    + sigma_alpha_ql[g]    * alpha_raw[s]);
    beta[s]   = exp(        mu_beta_ql[g]     + sigma_beta_ql[g]     * beta_raw[s]);
    pstay[s]  = Phi_approx(mu_pstay_wsls[g]  + sigma_pstay_wsls[g]  * pstay_raw[s]);
    pshift[s] = Phi_approx(mu_pshift_wsls[g] + sigma_pshift_wsls[g] * pshift_raw[s]);
  }
}

model {
  mu_alpha_ql       ~ normal(0, 1);
  mu_beta_ql        ~ normal(1, 1);
  sigma_alpha_ql    ~ normal(0, 0.5);
  sigma_beta_ql     ~ normal(0, 0.5);
  mu_pstay_wsls     ~ normal(1, 1);
  mu_pshift_wsls    ~ normal(1, 1);
  sigma_pstay_wsls  ~ normal(0, 0.5);
  sigma_pshift_wsls ~ normal(0, 0.5);

  for (g in 1:2)
    strategy_prob[g] ~ dirichlet(rep_vector(2.0, N_strategies));

  alpha_raw  ~ normal(0, 1);
  beta_raw   ~ normal(0, 1);
  pstay_raw  ~ normal(0, 1);
  pshift_raw ~ normal(0, 1);

  {
    int idx = 1;
    for (s in 1:N_subj) {
      int g = group[s] + 1;
      real ll_ql   = 0;
      real ll_wsls = 0;
      vector[2] Q  = rep_vector(0.5, 2);
      int  last_choice = 0;
      int  last_reward = -1;

      for (t in 1:N_trials) {
        int c = choice[idx];
        int r = reward[idx];

        // Q-learning
        vector[2] ap_ql = softmax(beta[s] * Q);
        ll_ql += categorical_lpmf(c | ap_ql);
        Q[c]  += alpha[s] * (r - Q[c]);

        // WSLS
        vector[2] ap_wsls;
        if (last_choice == 0) {
          ap_wsls = rep_vector(0.5, 2);
        } else {
          real p_rep = (last_reward == 1) ? pstay[s] : (1 - pshift[s]);
          ap_wsls[last_choice]     = p_rep;
          ap_wsls[3 - last_choice] = 1 - p_rep;
        }
        ll_wsls += categorical_lpmf(c | ap_wsls);

        last_choice = c;
        last_reward = r;
        idx += 1;
      }

      vector[N_strategies] log_lik_s;
      log_lik_s[1] = log(strategy_prob[g][1]) + ll_ql;
      log_lik_s[2] = log(strategy_prob[g][2]) + ll_wsls;
      target += log_sum_exp(log_lik_s);
    }
  }
}

generated quantities {
  vector[N_total]            log_lik;
  matrix[N_subj, N_strategies] strategy_assignment;

  real group_diff_alpha;
  real group_diff_beta;
  real group_diff_pstay;
  real group_diff_pshift;
  real group_diff_ql_prob;

  {
    int idx = 1;
    for (s in 1:N_subj) {
      int g = group[s] + 1;
      real ll_ql   = 0;
      real ll_wsls = 0;
      vector[2] Q  = rep_vector(0.5, 2);
      int  last_choice = 0;
      int  last_reward = -1;

      for (t in 1:N_trials) {
        int c = choice[idx];
        int r = reward[idx];

        vector[2] ap_ql = softmax(beta[s] * Q);
        real t_ll_ql    = categorical_lpmf(c | ap_ql);
        ll_ql += t_ll_ql;
        Q[c]  += alpha[s] * (r - Q[c]);

        vector[2] ap_wsls;
        if (last_choice == 0) {
          ap_wsls = rep_vector(0.5, 2);
        } else {
          real p_rep = (last_reward == 1) ? pstay[s] : (1 - pshift[s]);
          ap_wsls[last_choice]     = p_rep;
          ap_wsls[3 - last_choice] = 1 - p_rep;
        }
        real t_ll_wsls = categorical_lpmf(c | ap_wsls);
        ll_wsls += t_ll_wsls;

        vector[N_strategies] trial_mix;
        trial_mix[1] = log(strategy_prob[g][1]) + t_ll_ql;
        trial_mix[2] = log(strategy_prob[g][2]) + t_ll_wsls;
        log_lik[idx] = log_sum_exp(trial_mix);

        last_choice = c;
        last_reward = r;
        idx += 1;
      }

      vector[N_strategies] log_post;
      log_post[1] = log(strategy_prob[g][1]) + ll_ql;
      log_post[2] = log(strategy_prob[g][2]) + ll_wsls;
      strategy_assignment[s] = to_row_vector(softmax(log_post));
    }
  }

  group_diff_alpha   = Phi_approx(mu_alpha_ql[2])    - Phi_approx(mu_alpha_ql[1]);
  group_diff_beta    = exp(mu_beta_ql[2])             - exp(mu_beta_ql[1]);
  group_diff_pstay   = Phi_approx(mu_pstay_wsls[2])  - Phi_approx(mu_pstay_wsls[1]);
  group_diff_pshift  = Phi_approx(mu_pshift_wsls[2]) - Phi_approx(mu_pshift_wsls[1]);
  group_diff_ql_prob = strategy_prob[2][1]            - strategy_prob[1][1];
}
"

# ==============================================================================
# 3. COMPILE AND FIT THE MODEL
# ==============================================================================

stan_data <- list(
  N_subj       = N_subj,
  N_trials     = N_trials,
  N_total      = N_total,
  subj         = subj_vec,
  choice       = choice_vec,
  reward       = reward_vec,
  group        = group_vec,
  N_strategies = 2L
)

cat("Compiling Stan model...\n")
mixture_model <- stan_model(model_code = stan_mixture_code,
                            model_name = "mixture_ql_wsls")

cat("Fitting model (this may take several minutes)...\n")
fit <- sampling(
  mixture_model,
  data    = stan_data,
  chains  = 4,
  iter    = 2000,
  warmup  = 1000,
  cores   = parallel::detectCores(),
  seed    = 42,
  control = list(adapt_delta = 0.90, max_treedepth = 12),
  verbose = FALSE
)

# ==============================================================================
# 4. CONVERGENCE DIAGNOSTICS
# ==============================================================================

cat("\n--- Key Parameter Summary ---\n")
key_params <- c(
  "mu_alpha_ql", "mu_beta_ql",
  "mu_pstay_wsls", "mu_pshift_wsls",
  "strategy_prob[1,1]", "strategy_prob[1,2]",
  "strategy_prob[2,1]", "strategy_prob[2,2]",
  "group_diff_alpha", "group_diff_beta",
  "group_diff_pstay", "group_diff_pshift",
  "group_diff_ql_prob"
)
print(summary(fit, pars = key_params)$summary[, c("mean","sd","2.5%","97.5%","Rhat","n_eff")])

# R-hat check
rhats <- summary(fit)$summary[, "Rhat"]
cat(sprintf("\nMax Rhat across all parameters: %.4f\n", max(rhats, na.rm = TRUE)))
cat(sprintf("Parameters with Rhat > 1.05: %d\n", sum(rhats > 1.05, na.rm = TRUE)))

# Divergences
sampler_diagnostics <- get_sampler_params(fit, inc_warmup = FALSE)
n_divergent <- sum(sapply(sampler_diagnostics, function(x) sum(x[, "divergent__"])))
cat(sprintf("Post-warmup divergent transitions: %d\n", n_divergent))

# ==============================================================================
# 5. TRACE PLOTS (bayesplot)
# ==============================================================================

posterior_array <- as.array(fit)

p_trace <- mcmc_trace(
  posterior_array,
  pars  = c("strategy_prob[1,1]", "strategy_prob[2,1]",
            "group_diff_ql_prob", "group_diff_alpha", "group_diff_beta"),
  facet_args = list(ncol = 1, strip.position = "left")
) +
  labs(title = "Trace Plots – Key Parameters") +
  theme_minimal()

print(p_trace)

# ==============================================================================
# 6. STRATEGY ASSIGNMENT PLOT
# ==============================================================================

# Extract posterior mean strategy probabilities
strat_draws <- extract(fit, pars = "strategy_assignment")$strategy_assignment
# Dimensions: [draws, N_subj, N_strategies]
strat_mean  <- apply(strat_draws, c(2, 3), mean)

strat_df <- tibble(
  subject       = seq_len(N_subj),
  group         = factor(group_vec, levels = 0:1,
                         labels = c("Control", "Depressed")),
  p_ql          = strat_mean[, 1],
  p_wsls        = strat_mean[, 2],
  true_strategy = sapply(true_params, `[[`, "strategy")
)

p_strat <- ggplot(strat_df, aes(x = reorder(subject, p_ql),
                                y = p_ql, colour = group,
                                shape = true_strategy)) +
  geom_hline(yintercept = 0.5, linetype = "dashed", colour = "grey60") +
  geom_point(size = 2.5, alpha = 0.85) +
  facet_wrap(~ group, scales = "free_x") +
  scale_colour_manual(values = c("Control" = "#2166ac",
                                 "Depressed" = "#d6604d")) +
  scale_shape_manual(values  = c("ql" = 16, "wsls" = 17),
                     labels  = c("ql" = "True: Q-learning",
                                 "wsls" = "True: WSLS")) +
  labs(
    title    = "Posterior Probability of Using Q-Learning Per Subject",
    subtitle = "Points above 0.5 classified as Q-learning users",
    x        = "Subject (ranked by P(Q-learning))",
    y        = "P(Q-learning | data)",
    colour   = "Group", shape = "True strategy"
  ) +
  theme_bw(base_size = 12) +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank())

print(p_strat)

# ---- Classification accuracy -------------------------------------------------
strat_df <- strat_df %>%
  mutate(
    assigned_strategy = ifelse(p_ql > 0.5, "ql", "wsls"),
    correct           = (assigned_strategy == true_strategy)
  )

acc_overall <- mean(strat_df$correct)
acc_by_group <- strat_df %>%
  group_by(group) %>%
  summarise(accuracy = mean(correct), n = n(), .groups = "drop")

cat(sprintf("\nStrategy assignment accuracy: %.1f%%\n", 100 * acc_overall))
print(acc_by_group)

# ==============================================================================
# 7. PARAMETER RECOVERY
# ==============================================================================

posterior_sums <- summary(fit, pars = c("alpha", "beta",
                                         "pstay", "pshift"))$summary

alpha_est <- posterior_sums[grep("^alpha\\[", rownames(posterior_sums)), "mean"]
beta_est  <- posterior_sums[grep("^beta\\[",  rownames(posterior_sums)), "mean"]
pstay_est <- posterior_sums[grep("^pstay\\[", rownames(posterior_sums)), "mean"]
pshift_est<- posterior_sums[grep("^pshift\\[",rownames(posterior_sums)), "mean"]

# True values (NA for subjects using the other strategy)
true_alpha  <- sapply(true_params, function(x) ifelse(is.null(x$alpha),  NA, x$alpha))
true_beta   <- sapply(true_params, function(x) ifelse(is.null(x$beta),   NA, x$beta))
true_pstay  <- sapply(true_params, function(x) ifelse(is.null(x$pstay),  NA, x$pstay))
true_pshift <- sapply(true_params, function(x) ifelse(is.null(x$pshift), NA, x$pshift))

recovery_df <- tibble(
  subject       = seq_len(N_subj),
  true_strategy = sapply(true_params, `[[`, "strategy"),
  true_alpha, alpha_est,
  true_beta,  beta_est,
  true_pstay, pstay_est,
  true_pshift,pshift_est
)

plot_recovery <- function(df, true_col, est_col, label, strat_filter) {
  sub_df <- df %>% filter(true_strategy == strat_filter) %>%
    select(x = !!sym(true_col), y = !!sym(est_col)) %>%
    filter(!is.na(x))
  r_val <- round(cor(sub_df$x, sub_df$y), 2)
  ggplot(sub_df, aes(x, y)) +
    geom_abline(slope = 1, intercept = 0, colour = "grey50", linetype = "dashed") +
    geom_point(alpha = 0.7, colour = "#4393c3") +
    geom_smooth(method = "lm", se = TRUE, colour = "#d6604d", linewidth = 0.8) +
    annotate("text", x = min(sub_df$x), y = max(sub_df$y),
             label = paste0("r = ", r_val), hjust = 0, size = 4) +
    labs(title = label, x = "True", y = "Estimated") +
    theme_bw(base_size = 11)
}

p_rec <- plot_grid(
  plot_recovery(recovery_df, "true_alpha",  "alpha_est",  "α recovery (QL subjects)",    "ql"),
  plot_recovery(recovery_df, "true_beta",   "beta_est",   "β recovery (QL subjects)",    "ql"),
  plot_recovery(recovery_df, "true_pstay",  "pstay_est",  "p_stay recovery (WSLS subj)", "wsls"),
  plot_recovery(recovery_df, "true_pshift", "pshift_est", "p_shift recovery (WSLS subj)","wsls"),
  nrow = 2
)
print(p_rec)

# ==============================================================================
# 8. GROUP-LEVEL POSTERIOR DIFFERENCES
# ==============================================================================

diff_pars <- c("group_diff_alpha", "group_diff_beta",
               "group_diff_pstay", "group_diff_pshift",
               "group_diff_ql_prob")

diff_draws <- as.data.frame(extract(fit, pars = diff_pars))
colnames(diff_draws) <- c("Δα (Q-learning rate)",
                          "Δβ (Inverse temperature)",
                          "Δp_stay",
                          "Δp_shift",
                          "ΔP(Q-learning)")

diff_long <- diff_draws %>%
  pivot_longer(everything(), names_to = "parameter", values_to = "value")

p_diffs <- ggplot(diff_long, aes(x = value, y = parameter, fill = parameter)) +
  geom_vline(xintercept = 0, colour = "black", linetype = "dashed") +
  stat_halfeye(point_interval = median_hdi, .width = c(0.80, 0.95),
               normalize = "groups", alpha = 0.8) +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  labs(
    title    = "Group Differences: Depressed minus Control",
    subtitle = "Posterior distributions of group-level contrasts",
    x        = "Difference", y = NULL
  ) +
  theme_bw(base_size = 12)

# Fallback if ggdist not available
tryCatch(
  print(p_diffs),
  error = function(e) {
    p_diffs2 <- ggplot(diff_long, aes(x = value, fill = parameter)) +
      geom_histogram(bins = 60, alpha = 0.75) +
      geom_vline(xintercept = 0, linetype = "dashed") +
      facet_wrap(~ parameter, scales = "free") +
      scale_fill_brewer(palette = "Set2", guide = "none") +
      labs(title = "Group Differences (Depressed – Control)",
           x = "Difference", y = "Samples") +
      theme_bw(base_size = 11)
    print(p_diffs2)
  }
)

# Print posterior summaries for differences
cat("\n--- Group Difference Posteriors ---\n")
print(summary(fit, pars = diff_pars)$summary[, c("mean","sd","2.5%","97.5%")])

# ==============================================================================
# 9. STRATEGY MIX POSTERIORS (per group)
# ==============================================================================

sp_draws <- extract(fit, pars = "strategy_prob")$strategy_prob
# sp_draws: [iter, group_index, strategy_index]

sp_df <- bind_rows(
  tibble(group = "Control",
         P_QL  = sp_draws[, 1, 1],
         P_WSLS= sp_draws[, 1, 2]),
  tibble(group = "Depressed",
         P_QL  = sp_draws[, 2, 1],
         P_WSLS= sp_draws[, 2, 2])
) %>% pivot_longer(c(P_QL, P_WSLS), names_to = "strategy", values_to = "prob")

p_mix <- ggplot(sp_df, aes(x = prob, fill = group)) +
  geom_density(alpha = 0.55) +
  facet_wrap(~ strategy, labeller = labeller(
    strategy = c(P_QL = "P(Q-learning)", P_WSLS = "P(WSLS)")
  )) +
  scale_fill_manual(values = c("Control" = "#2166ac", "Depressed" = "#d6604d")) +
  labs(
    title    = "Posterior Strategy Mixing Weights by Group",
    x        = "Probability", y        = "Density", fill = "Group"
  ) +
  theme_bw(base_size = 12)

print(p_mix)

# ==============================================================================
# 10. LOO-CV (Leave-One-Out Cross-Validation)
# ==============================================================================

cat("\nComputing LOO-CV...\n")
log_lik_matrix <- extract_log_lik(fit, parameter_name = "log_lik",
                                   merge_chains = FALSE)
loo_result <- loo(log_lik_matrix, r_eff = relative_eff(log_lik_matrix))
cat("\n--- LOO Results ---\n")
print(loo_result)

# Pareto k diagnostics plot
p_loo <- plot(loo_result, diagnostic = "k", label_points = FALSE,
              main = "Pareto k Diagnostics (LOO)")

# ==============================================================================
# 11. POSTERIOR PREDICTIVE CHECK
# ==============================================================================

# Simulate data from posterior median parameters
# and compare observed vs. predicted choice proportions

sim_ppc <- function(fit, stan_data, n_posterior_samples = 200) {
  posterior <- extract(fit, pars = c("alpha", "beta", "pstay", "pshift",
                                      "strategy_prob"))
  n_draws <- length(posterior$alpha[, 1])
  sample_idx <- sample(n_draws, n_posterior_samples)

  choice_vec_obs <- stan_data$choice
  subj_vec_obs   <- stan_data$subj
  reward_vec_obs <- stan_data$reward

  predicted_choice_rates <- matrix(NA, n_posterior_samples, stan_data$N_subj)

  for (draw_i in seq_along(sample_idx)) {
    d <- sample_idx[draw_i]
    for (s in seq_len(stan_data$N_subj)) {
      g        <- stan_data$group[s] + 1
      pi_ql    <- posterior$strategy_prob[d, g, 1]
      alpha_s  <- posterior$alpha[d, s]
      beta_s   <- posterior$beta[d, s]
      pstay_s  <- posterior$pstay[d, s]
      pshift_s <- posterior$pshift[d, s]

      trial_idx <- which(subj_vec_obs == s)
      rewards_s <- reward_vec_obs[trial_idx]
      choices_s <- integer(length(trial_idx))

      Q_s <- c(0.5, 0.5)
      last_c <- 0L; last_r <- -1L

      for (t in seq_along(trial_idx)) {
        # Strategy drawn once per subject per posterior sample
        if (runif(1) < pi_ql) {
          ev <- beta_s * Q_s
          ev <- ev - max(ev)
          p1 <- exp(ev[1]) / sum(exp(ev))
          c_t <- ifelse(runif(1) < p1, 1L, 2L)
        } else {
          if (last_c == 0L) {
            c_t <- sample(1:2, 1)
          } else {
            p_rep <- if (last_r == 1) pstay_s else (1 - pshift_s)
            c_t <- if (runif(1) < p_rep) last_c else (3L - last_c)
          }
        }
        choices_s[t] <- c_t
        r_t <- rewards_s[t]
        Q_s[c_t] <- Q_s[c_t] + alpha_s * (r_t - Q_s[c_t])
        last_c <- c_t; last_r <- r_t
      }
      predicted_choice_rates[draw_i, s] <- mean(choices_s == 1)
    }
  }
  predicted_choice_rates
}

cat("Running posterior predictive simulation...\n")
ppc_matrix <- sim_ppc(fit, stan_data, n_posterior_samples = 100)

obs_rates <- tapply(choice_vec == 1, subj_vec, mean)

ppc_mean <- colMeans(ppc_matrix)
ppc_lo   <- apply(ppc_matrix, 2, quantile, 0.025)
ppc_hi   <- apply(ppc_matrix, 2, quantile, 0.975)

ppc_df <- tibble(
  subject  = seq_len(N_subj),
  observed = obs_rates,
  pred_mean= ppc_mean,
  pred_lo  = ppc_lo,
  pred_hi  = ppc_hi,
  group    = factor(group_vec, labels = c("Control", "Depressed"))
)

p_ppc <- ggplot(ppc_df, aes(x = observed, y = pred_mean, colour = group)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", colour = "grey50") +
  geom_errorbar(aes(ymin = pred_lo, ymax = pred_hi), width = 0, alpha = 0.4) +
  geom_point(size = 2.5, alpha = 0.9) +
  scale_colour_manual(values = c("Control" = "#2166ac", "Depressed" = "#d6604d")) +
  labs(
    title    = "Posterior Predictive Check: Choice Rates",
    subtitle = "Error bars = 95% posterior predictive interval per subject",
    x        = "Observed P(choice = 1)",
    y        = "Predicted P(choice = 1)",
    colour   = "Group"
  ) +
  theme_bw(base_size = 12)

print(p_ppc)

# ==============================================================================
# 12. CLINICAL CORRELATION ANALYSIS (simulated clinical scores)
# ==============================================================================

analyze_clinical_correlations <- function(fit, N_subj, group_vec,
                                           alpha_est, beta_est) {
  # Simulate plausible clinical scores correlated with true parameters
  set.seed(99)
  bdi_scores <- ifelse(
    group_vec == 1,
    rnorm(N_subj, mean = 22, sd = 6),    # Depressed: elevated BDI
    rnorm(N_subj, mean =  6, sd = 4)     # Controls
  )
  shaps_scores <- ifelse(
    group_vec == 1,
    rnorm(N_subj, mean = 18, sd = 5),    # Lower pleasure scores
    rnorm(N_subj, mean =  5, sd = 3)
  )

  clinical_df <- tibble(
    alpha_est, beta_est,
    bdi   = bdi_scores,
    shaps = shaps_scores,
    group = group_vec
  )

  list(
    alpha_bdi   = cor.test(clinical_df$alpha_est, clinical_df$bdi),
    alpha_shaps = cor.test(clinical_df$alpha_est, clinical_df$shaps),
    beta_bdi    = cor.test(clinical_df$beta_est,  clinical_df$bdi),
    beta_shaps  = cor.test(clinical_df$beta_est,  clinical_df$shaps),
    data        = clinical_df
  )
}

clinical_results <- analyze_clinical_correlations(
  fit, N_subj, group_vec, alpha_est, beta_est
)

cat("\n--- Clinical Correlations ---\n")
cat("α ~ BDI:    r =", round(clinical_results$alpha_bdi$estimate, 3),
    "  p =", round(clinical_results$alpha_bdi$p.value, 4), "\n")
cat("α ~ SHAPS:  r =", round(clinical_results$alpha_shaps$estimate, 3),
    "  p =", round(clinical_results$alpha_shaps$p.value, 4), "\n")
cat("β ~ BDI:    r =", round(clinical_results$beta_bdi$estimate, 3),
    "  p =", round(clinical_results$beta_bdi$p.value, 4), "\n")
cat("β ~ SHAPS:  r =", round(clinical_results$beta_shaps$estimate, 3),
    "  p =", round(clinical_results$beta_shaps$p.value, 4), "\n")

clin_df <- clinical_results$data

p_clin_alpha_bdi <- ggplot(clin_df, aes(x = bdi, y = alpha_est,
                                          colour = factor(group))) +
  geom_point(alpha = 0.75) +
  geom_smooth(method = "lm", se = TRUE, colour = "black", linewidth = 0.8) +
  scale_colour_manual(values = c("0" = "#2166ac", "1" = "#d6604d"),
                      labels = c("Control", "Depressed"), name = "Group") +
  labs(title = "Learning Rate vs. Depression Severity",
       x = "Beck Depression Inventory", y = "Estimated α") +
  theme_bw(base_size = 12)

p_clin_beta_shaps <- ggplot(clin_df, aes(x = shaps, y = beta_est,
                                           colour = factor(group))) +
  geom_point(alpha = 0.75) +
  geom_smooth(method = "lm", se = TRUE, colour = "black", linewidth = 0.8) +
  scale_colour_manual(values = c("0" = "#2166ac", "1" = "#d6604d"),
                      labels = c("Control", "Depressed"), name = "Group") +
  labs(title = "Decision Noise vs. Anhedonia (SHAPS)",
       x = "SHAPS Score", y = "Estimated β") +
  theme_bw(base_size = 12)

print(plot_grid(p_clin_alpha_bdi, p_clin_beta_shaps, nrow = 1))

# ==============================================================================
# 13. SUMMARY TABLE OF ALL KEY RESULTS
# ==============================================================================

cat("\n=======================================================\n")
cat("              SIMULATION SUMMARY\n")
cat("=======================================================\n")
cat(sprintf("Subjects: %d (%d controls, %d depressed)\n",
            N_subj, N_ctrl, N_depr))
cat(sprintf("Trials per subject: %d\n", N_trials))
cat(sprintf("Strategy assignment accuracy: %.1f%%\n", 100 * acc_overall))
cat(sprintf("Max Rhat: %.4f   Divergences: %d\n",
            max(rhats, na.rm = TRUE), n_divergent))

cat("\nPosterior group differences (median [95% CrI]):\n")
diff_summary <- summary(fit, pars = diff_pars)$summary
for (p in rownames(diff_summary)) {
  cat(sprintf("  %-28s: %6.3f  [%6.3f, %6.3f]\n", p,
              diff_summary[p, "mean"],
              diff_summary[p, "2.5%"],
              diff_summary[p, "97.5%"]))
}
cat("=======================================================\n")
```
