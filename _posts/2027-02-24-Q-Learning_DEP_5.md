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
