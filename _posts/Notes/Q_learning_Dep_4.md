

# Bayesian Model Comparison in Computational Psychiatry: Q-Learning vs. Win-Stay-Lose-Shift

Computational models provide powerful frameworks for understanding decision-making in mental health, but a critical question remains: which models best capture the mechanisms underlying psychiatric symptoms? Simply fitting a single model to behavioral data tells us little about whether that model reflects the true cognitive processes involved. Model comparison—particularly through Bayesian approaches—offers a principled method for evaluating competing hypotheses about how healthy and depressed individuals learn and choose.

In this post, we extend our Q-learning depression models by implementing Bayesian parameter estimation and formal model comparison. We contrast the mechanistic Q-learning framework with a simpler heuristic model: Win-Stay-Lose-Shift (WSLS). Through probabilistic programming in Stan, we demonstrate how to fit both models to simulated behavioral data, generate predictions, and use information criteria to determine which better explains observed choice patterns. This approach illustrates how computational psychiatry can move beyond parameter fitting toward rigorous theory testing.

## The Challenge of Model Selection

Computational models in psychiatry often involve multiple free parameters that can be adjusted to fit almost any behavioral pattern. A Q-learning model with flexible learning rates and inverse temperatures might explain data well simply because of its parameterization flexibility, not because it captures true cognitive mechanisms. This overfitting problem is particularly acute when comparing populations: apparent differences in Q-learning parameters between healthy and depressed groups might reflect model inadequacy rather than genuine psychological differences.

Model comparison addresses this challenge by explicitly penalizing complexity while rewarding predictive accuracy. The goal is not just to fit existing data, but to identify models that generalize to new observations. In psychiatric contexts, this means finding computational frameworks that capture stable individual differences rather than idiosyncratic behavioral noise.

Consider two competing hypotheses for how individuals approach two-armed bandit tasks. The **mechanistic hypothesis** posits that people maintain explicit value estimates that are updated through prediction error learning, then use these values probabilistically to guide choice. This maps onto Q-learning with learnable α (learning rate) and β (inverse temperature) parameters. The **heuristic hypothesis** suggests that people use simpler rules based on immediate outcome feedback: repeat rewarded actions and switch after unrewarded actions. This maps onto WSLS with parameters for stay probability after reward and shift probability after no reward.

Both models can account for basic learning phenomena, but they make different assumptions about the cognitive architecture underlying choice. Q-learning assumes integration of outcome history into stable value representations, while WSLS assumes direct stimulus-response conditioning based on the most recent outcome. These different assumptions lead to different predictions about how behavior should evolve across learning episodes.

## Bayesian Parameter Estimation

Rather than using maximum likelihood point estimates, Bayesian approaches provide full posterior distributions over parameters. This captures uncertainty in parameter estimates and enables more robust model comparison by accounting for the range of parameter values consistent with observed data.

Our Stan implementation for Q-learning follows the standard formulation but uses probabilistic programming to sample from the posterior:

```stan
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
```

The key insight is treating parameter estimation as inference rather than optimization. Instead of finding single "best" parameter values, we sample from the posterior distribution P(α,β|data). This provides several advantages: uncertainty quantification in parameter estimates, natural regularization through prior specifications, and proper accounting of parameter correlations.

For our WSLS implementation, we model two core parameters: p_stay (probability of repeating an action after reward) and p_shift (probability of switching action after no reward):

```stan
parameters {
  real<lower=0, upper=1> p_stay;
  real<lower=0, upper=1> p_shift;
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
```

This model assumes that each choice depends only on the immediately preceding outcome and action, without any integration across multiple trials. The simplicity is both a strength (fewer parameters, more interpretable) and potential weakness (inability to capture complex learning dynamics).

## Posterior Predictive Validation

Beyond parameter estimation, Bayesian approaches enable posterior predictive checking: generating new data from fitted models and comparing against observed behavioral patterns. This reveals whether models capture key features of the data beyond simple choice frequencies.

Our validation approach reconstructs trial-by-trial choice probabilities using posterior mean parameter estimates, then compares predicted vs. observed choice patterns across learning episodes. For Q-learning, this involves forward simulation:

```r
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
```

The resulting predictions reveal how well each model captures the temporal dynamics of learning. Q-learning should show gradual convergence toward optimal choices as value estimates accumulate evidence. WSLS should show more erratic patterns tied to recent outcomes rather than long-term learning trends.

When applied to simulated "healthy" agent data (α=0.4, β=5), both models show reasonable fits to binned choice probabilities. However, closer examination reveals systematic differences. Q-learning predictions show smooth learning curves that reflect accumulated experience, while WSLS predictions show more volatile patterns reflecting sensitivity to recent outcomes. The quality of fit depends on the underlying generative process: Q-learning better captures data generated by Q-learning agents, while WSLS may better explain truly heuristic behavior.

## Information Criteria and Model Selection

Formal model comparison requires metrics that balance goodness-of-fit against model complexity. The Leave-One-Out Cross-Validation (LOO) Information Criterion provides a principled approach by estimating each model's out-of-sample predictive accuracy.

LOO works by iteratively removing each data point, refitting the model to remaining data, and evaluating the held-out point's likelihood. Models with better generalization show higher LOO values. Unlike traditional information criteria (AIC, BIC), LOO accounts for parameter uncertainty by using the full posterior distribution rather than point estimates.

```r
library(loo)
log_lik_q <- extract_log_lik(fit_q)
log_lik_wsls <- extract_log_lik(fit_wsls)

loo_q <- loo(log_lik_q)
loo_wsls <- loo(log_lik_wsls)
loo_compare(loo_q, loo_wsls)
```

The comparison typically reveals that Q-learning provides better LOO scores when applied to Q-learning-generated data, reflecting the model recovery expected when the generative model matches the fitted model. However, the margin of superiority matters: small differences suggest both models explain the data reasonably well, while large differences indicate clear model preference.

More importantly, these comparisons can reveal when simpler models (like WSLS) perform competitively with complex alternatives (like Q-learning). If a two-parameter heuristic explains behavior as well as a sophisticated reinforcement learning model, this suggests that the cognitive mechanisms might be simpler than initially assumed. Such findings have important implications for understanding individual differences and planning interventions.

## Clinical Applications and Individual Differences

The Bayesian model comparison framework extends naturally to clinical populations. Rather than simply fitting Q-learning parameters to healthy vs. depressed groups, we can ask which models better explain each population's behavior. This addresses fundamental questions about the nature of cognitive dysfunction in mental health conditions.

Several scenarios could emerge from such comparisons:

**Mechanism Preservation**: Both healthy and depressed groups are better explained by Q-learning, but with different parameter values. This suggests preserved reinforcement learning machinery with altered sensitivity or learning rate parameters—consistent with dopamine system dysfunction hypotheses.

**Mechanism Simplification**: Healthy individuals are better explained by Q-learning while depressed individuals are better explained by WSLS. This could indicate cognitive simplification under distress, where complex value integration gives way to simple heuristics based on immediate outcomes.

**Universal Heuristics**: Both groups are better explained by WSLS despite being generated by Q-learning simulations. This might reveal that bandit tasks don't engage complex learning mechanisms in either population, limiting their clinical utility.

**Individual Heterogeneity**: Model preferences vary within groups rather than between them. Some individuals in both populations might use sophisticated learning while others rely on simple heuristics, suggesting that cognitive strategy rather than group membership drives behavior.

Each outcome carries different implications for treatment. If depression involves parameter changes within preserved Q-learning, interventions might target specific computational components (e.g., learning rate through dopaminergic medications, inverse temperature through cognitive training). If depression involves strategy simplification, treatments might focus on restoring cognitive complexity or working within simplified frameworks.

## Extensions and Future Directions

The Q-learning vs. WSLS comparison represents just one example of computational model comparison in psychiatry. The Bayesian framework scales to more sophisticated model spaces and clinical questions:

**Hierarchical Models**: Rather than fitting individuals separately, hierarchical Bayesian models can simultaneously estimate individual parameters and group-level distributions. This provides more stable individual estimates while preserving information about population differences.

**Model Averaging**: When multiple models receive substantial support, Bayesian Model Averaging weights predictions by model probabilities rather than selecting a single best model. This approach acknowledges model uncertainty while making robust predictions.

**Dynamic Models**: Extensions could examine how model preferences change over time or treatment. Do individuals switch between Q-learning and heuristic strategies depending on mood, stress, or medication status?

**Task Generalization**: Comparing models across multiple behavioral tasks can reveal whether individual differences reflect stable cognitive traits or task-specific strategies. Do individuals who use Q-learning in bandits also show sophisticated learning in other paradigms?

**Neural Constraints**: Incorporating neural data (fMRI, EEG) into model comparison can adjudicate between behaviorally equivalent models by examining their neural plausibility. Models that better predict neural activity might be preferred even if behavioral fits are similar.

## Methodological Considerations

Several technical issues deserve attention when applying these methods clinically:

**Sample Sizes**: Reliable model comparison requires adequate data per individual and sufficient individuals per group. Underpowered studies may show spurious model differences or fail to detect genuine ones.

**Model Misspecification**: All models represent simplifications of true cognitive processes. Poor fits for all models might indicate fundamental misspecification rather than meaningful individual differences.

**Prior Sensitivity**: Bayesian results can depend on prior specifications, particularly with limited data. Sensitivity analyses examining robustness to different priors help establish the reliability of conclusions.

**Computational Considerations**: Stan sampling can be computationally intensive, particularly for hierarchical models with many individuals. Efficient coding and adequate computing resources become important practical constraints.

## Implications for Computational Psychiatry

Bayesian model comparison offers computational psychiatry a principled approach to theory testing that goes beyond parameter estimation. Rather than assuming particular models apply to clinical populations, we can empirically determine which computational frameworks best explain observed behavior.

This approach addresses several longstanding challenges in the field. First, it provides objective criteria for choosing between competing theoretical frameworks rather than relying on face validity or tradition. Second, it naturally accounts for model complexity, preventing overfitting that might obscure genuine individual differences. Third, it quantifies uncertainty in model selection, acknowledging when evidence is insufficient to strongly prefer one framework over alternatives.

Perhaps most importantly, rigorous model comparison can reveal when simple explanations suffice. The tendency in computational psychiatry has been toward increasingly sophisticated models that incorporate multiple cognitive systems and parameters. While such complexity may sometimes be necessary, Bayesian approaches can identify cases where simpler heuristic models provide adequate explanations. This parsimony principle not only aids scientific understanding but may also suggest more targeted and implementable interventions.

## Conclusion

The transition from model fitting to model comparison represents a crucial methodological advancement for computational psychiatry. By treating model selection as a formal inference problem, we can move beyond describing behavioral patterns toward understanding the cognitive mechanisms that generate them.

The Q-learning vs. WSLS comparison demonstrates how this approach works in practice: implementing competing models in probabilistic programming languages, estimating posterior distributions over parameters, generating predictions, and using information criteria to assess relative model support. When applied to clinical populations, this framework can reveal whether mental health conditions involve altered parameters within preserved cognitive architectures or fundamental changes in behavioral strategies.

As computational models become increasingly central to psychiatric research, such rigorous model comparison methods will be essential for ensuring that theoretical advances translate into improved understanding and treatment of mental health conditions. The goal is not simply to fit models to data, but to identify the computational principles that best explain human behavior in health and disease.

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
