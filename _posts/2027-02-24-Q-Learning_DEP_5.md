# Addressing Individual Heterogeneity and Mixture Models in Computational Psychiatry

One of the main lessons from computational psychiatry is that a diagnosis rarely maps onto a single decision strategy. This follow-up post extends the earlier Bayesian recovery framework by treating each participant as potentially belonging to one of multiple latent strategy classes, and it uses a mixture model to infer who is learning values and who is following a simpler win–stay/lose–shift heuristic.

The code you provided is a strong example of this idea in practice: it simulates control and depressed groups with different strategy proportions, fits a Bayesian mixture of Q-learning and WSLS, and then checks whether the model can recover both individual strategies and group-level shifts in latent composition.

## Why mixture models matter

A standard hierarchical RL model assumes that all participants share the same generative form and differ only in parameter values. That assumption is often too strong for clinical data, where two people with the same symptom score may use different cognitive policies even on the same task. A mixture model relaxes that assumption by letting the data decide whether a subject is better explained by Q-learning or WSLS, while still estimating group-specific mixing weights.

Formally, if $z_s \in \{1,2\}$ is the latent strategy for subject $s$, the likelihood becomes a marginal mixture:

$$
p(\mathbf{y}_s \mid \theta) = \sum_{k=1}^{K} p(z_s = k \mid g_s)\, p(\mathbf{y}_s \mid z_s = k, \theta_k),
$$

where $g_s$ is group membership, $p(z_s = k \mid g_s)$ is the group-specific mixing probability, and $p(\mathbf{y}_s \mid z_s = k, \theta_k)$ is the strategy-specific likelihood.

## Simulating heterogeneous behavior

Your simulation section is doing something important conceptually: it makes heterogeneity explicit before inference. Controls are generated with a 60/40 split between Q-learning and WSLS, while depressed participants are generated with a 30/70 split, which creates a clinically plausible shift in strategy composition rather than only a shift in parameter magnitude.

That distinction matters because a group difference in mean learning rate can be misleading if half the depressed group is actually using a qualitatively different strategy. In that sense, the simulation is a stress test for whether a model can recover latent subtypes instead of averaging them away.

```r
simulate_subject <- function(strategy, N_trials, alpha = NULL, beta = NULL,
                             pstay = NULL, pshift = NULL,
                             reward_prob_good = 0.70,
                             reward_prob_bad = 0.30) {
  ...
}
```

This function cleanly separates the two generative processes. The Q-learning branch uses a softmax policy and prediction-error updating, while the WSLS branch uses only the previous trial’s reward and choice history.

## The mixture likelihood

The Stan model is the heart of the post. It computes two subject-level log-likelihoods, one under Q-learning and one under WSLS, and then combines them using a log-sum-exp mixture. This is the right probabilistic structure for latent class inference because it avoids hard assignment during sampling and preserves posterior uncertainty over strategies.

A useful way to read the model is:

$$
\log p(\mathbf{y}_s) = \log \left[ \pi_{g_s,1}\, p(\mathbf{y}_s \mid z_s=1) + \pi_{g_s,2}\, p(\mathbf{y}_s \mid z_s=2) \right],
$$

where $\pi_{g_s,k}$ is the strategy probability for group $g_s$. In your code, this is implemented via `strategy_prob[g] ~ dirichlet(...)` and `target += log_sum_exp(log_lik_s)`.

```stan
vector[N_strategies] log_lik_s;
log_lik_s = log(strategy_prob[g]) + ll_ql;
log_lik_s = log(strategy_prob[g]) + ll_wsls;
target += log_sum_exp(log_lik_s);
```

That block is the most consequential part of the model. It says that the observed sequence may have arisen from either strategy, and the posterior should weigh both explanations rather than forcing a premature decision.

## Parameterization and priors

The model uses non-centered parameterizations for subject-level parameters, which is particularly helpful in hierarchical Bayes because it improves geometry and reduces sampling pathologies. Q-learning parameters are mapped to constrained spaces with `Phi_approx` and `exp`, while WSLS parameters are transformed through `Phi_approx` to keep them in $(0,1)$.

The group-specific hyperparameters are given weakly informative priors:

$$
\mu_{\alpha,\text{ql}} \sim \mathcal{N}(0,1), \qquad \sigma_{\alpha,\text{ql}} \sim \mathcal{N}^+(0,0.5),
$$

with analogous priors for $\beta$, $p_{\text{stay}}$, and $p_{\text{shift}}$. This is sensible because the model needs regularization, but not so much that it erases the between-group differences the simulation was built to detect.

```stan
alpha[s]  = Phi_approx(mu_alpha_ql[g] + sigma_alpha_ql[g] * alpha_raw[s]);
beta[s]   = exp(mu_beta_ql[g] + sigma_beta_ql[g] * beta_raw[s]);
pstay[s]  = Phi_approx(mu_pstay_wsls[g] + sigma_pstay_wsls[g] * pstay_raw[s]);
pshift[s] = Phi_approx(mu_pshift_wsls[g] + sigma_pshift_wsls[g] * pshift_raw[s]);
```

These transformations also make the model interpretable: the latent raw variables remain unconstrained, while the resulting parameters preserve their behavioral meaning.

## Strategy assignment

The strategy assignment output is one of the most clinically interesting parts of the workflow. Rather than producing a single label, the model yields a posterior probability that each subject used Q-learning versus WSLS. That lets you quantify uncertainty in classification and avoid overconfident subtype assignment.

```stan
strategy_assignment[s] = to_row_vector(softmax(log_post));
```

In effect, this creates a probabilistic phenotype for each participant. A subject with $P(\text{QL}\mid \mathbf{y})=0.55$ should not be treated the same way as one with $P(\text{QL}\mid \mathbf{y})=0.98$, even if both would be labeled “Q-learning” under a hard threshold.

## Recovery and Posterior predictive checks

The parameter recovery section is especially valuable because it checks whether the model can recover the true latent values used in simulation. For subjects who truly use Q-learning, the recovered $\alpha$ and $\beta$ should correlate with the generating values; for WSLS subjects, the recovered $p_{\text{stay}}$ and $p_{\text{shift}}$ should do the same.

The group-level posterior contrasts are the right way to summarize clinical differences:

$$
\Delta \alpha = \alpha_{\text{depressed}} - \alpha_{\text{control}}, \qquad
\Delta \pi_{\text{QL}} = \pi_{\text{depressed,QL}} - \pi_{\text{control,QL}}.
$$

These contrasts answer a more nuanced question than “is depression associated with lower learning rate?” They ask whether depression is associated with a shift in the *composition* of decision strategies, a shift in the *parameters* of one strategy, or both.

```r
group_diff_ql_prob = strategy_prob - strategy_prob
```

That quantity is especially important because it captures the core synthetic manipulation in your simulation: depressed participants are generated to be more WSLS-heavy, not just more noisy. 

The posterior predictive check in your code is appropriately subject-level. Instead of comparing only aggregate histograms, it simulates each subject’s choice rate from posterior draws and compares observed versus predicted proportions. That is useful because a mixture model can fit group averages well while still failing to reproduce individual trajectories.

```r
p_ppc <- ggplot(ppc_df, aes(x = observed, y = pred_mean, colour = group)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed")
```

If the points cluster near the diagonal and the posterior intervals cover the observed values, the model is capturing the data-generating process reasonably well. If not, the mismatch often reveals either a missing strategy class or a need for time-varying mixtures.

## Clinical interpretation and conclusion

The clinical payoff of this model is not just better fit; it is better theory. A depressed group that appears to have a lower mean $\alpha$ in a single-process model may instead be a heterogeneous mixture in which some patients learn normally but rely on habit-like decision rules, while others truly show reduced learning. Those are very different mechanistic stories, and they would imply different interventions.

Your simulated clinical correlation analysis pushes in the same direction by linking estimated parameters to depressive symptom measures such as BDI and SHAPS. That kind of analysis is most meaningful once the model has already separated strategy composition from within-strategy parameter variation.

This post advances the earlier Bayesian recovery framework by moving from “how well do we estimate parameters?” to “what if different people are generated by different decision processes?” That shift is essential in computational psychiatry, because heterogeneity is often the signal rather than the noise. The key idea is simple but powerful: when one model does not fit all, the right answer is not to average harder — it is to model the mixture. A natural next extension is a three-state model, for example Q-learning, WSLS, and random choice. That would make the story even more realistic in clinical data, where some participants may not fit either canonical strategy well.




[^1]: https://github.com/Brody-Lab/MixtureAgentsModels

[^2]: https://elifesciences.org/reviewed-preprints/97612v1

[^3]: https://discourse.mc-stan.org/t/bayesian-mixture-model/33788

[^4]: https://arxiv.org/html/2401.13929v1

[^5]: https://pmc.ncbi.nlm.nih.gov/articles/PMC12090054/

[^6]: https://www.biorxiv.org/content/10.1101/2020.10.19.345512.full

[^7]: https://pmc.ncbi.nlm.nih.gov/articles/PMC10522800/

[^8]: https://arxiv.org/abs/2603.27766

[^9]: https://www.reddit.com/r/AskStatistics/comments/e7n051/machine_learning_vs_bayesian_inference_stanpymc3/

[^10]: https://www.mit.edu/~paris/pubs/subakan-nips2014.pdf

[^11]: https://www.youtube.com/watch?v=Hfgj8V_b6EE


```r
# ==============================================================================
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
