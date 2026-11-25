---
layout: post
categories: posts
title: Multinomial Regression with Correlated Effects in R and Stan
featured-image: /images/stan.png
tags: [STAN, R, Bayes, Multinomial, Linear Algebra]
date-string: November 2027
---

### Multinomial Regression with Correlated Effects in R and Stan

The previous post introduced the Cholesky factor as a way to separate scales from correlations. Here the same pieces go into a multinomial logit model where group-level effects for different outcome categories are allowed to correlate. The setting is common: students choosing among programs, patients assigned to treatments, groups such as schools, clinics or hospitals tend to favour some categories together, and a model that treats those tendencies as independent discards that information.

#### The Model

Let $y_n \in \{1, \dots, K\}$ be the outcome for observation $n$ in group $j[n] \in \{1, \dots, J\}$, with covariate row vector $x_n \in \mathbb{R}^P$. The categorical logit model is

$$
\Pr(y_n = k) = \frac{\exp(\eta_{nk})}{\sum_{m=1}^{K} \exp(\eta_{nm})}, \qquad
\eta_{nk} = \alpha_k + x_n \beta_k + u_{j[n],k}.
$$

Adding a constant to every $\eta_{nm}$ leaves the probabilities unchanged, so the parameters are not identified as written. Stan's softmax regression function places no restrictions on the coefficient matrix, and the documentation leaves it to the user to supply a reference category, a suitable prior or some other means of identification. Rodríguez's multilevel course notes take the same route. They fix one category as the reference and note that the $k$-th linear predictor is then the log-relative probability of category $k$ against it. Here the last category is the reference, with $\alpha_K = 0$, $\beta_K = 0$ and $u_{j,K} = 0$, which leaves $K-1$ free linear predictors.

The group effects for the non-reference categories are drawn jointly:

$$
u_j \sim N\!\left(0, \Sigma_u\right), \qquad
\Sigma_u = \mathrm{diag}(\tau)\, \Omega\, \mathrm{diag}(\tau),
$$

where $\tau$ holds the standard deviations and $\Omega$ is a $(K-1)\times(K-1)$ correlation matrix. Each $u_{jk}$ can be read as a latent propensity of group $j$ to choose category $k$ over the reference, net of covariates. A positive $\Omega_{12}$ says that groups leaning towards category 1 also tend to lean towards category 2.

#### Cholesky Parameterisation

With $\Omega = L_\Omega L_\Omega^\top$, draw $z_j \sim N(0, I_{K-1})$ and set

$$
u_j = \mathrm{diag}(\tau)\, L_\Omega\, z_j .
$$

This is the non-centred form from the last post. The sampler works with independent standard normals, and the correlation structure enters through a deterministic transformation. For the prior on $L_\Omega$, Stan provides the LKJ density on the Cholesky factor, and its documentation says to use this implicit form rather than the explicit one on the correlation matrix . A lower-triangular $L$ is a Cholesky factor of a correlation matrix if and only if its diagonal is positive and each row has unit Euclidean length .

#### Two Caveats

The correlations in $\Omega$ are correlations between effects relative to the reference category. Change the reference and the quantities being correlated change, so $\Omega$ changes too, even though fitted choice probabilities should barely move. This follows from the differencing and is not a bug. It does mean that single entries of $\Omega$ shouldn't be read as category-to-category affinities in an absolute sense.

The second caveat concerns the logit itself. The multinomial logit keeps the independence of irrelevant alternatives property at the individual level, and group-level correlated effects relax it only partly, by letting groups differ. I would treat the model as a description of group heterogeneity. It is not a repair for substitution patterns.

#### A Real Example of the Same Structure

Rodríguez fits this class of model to the McKinney Homeless Study, which has 361 at-risk individuals followed over four waves. The outcome is housing status (street, community, independent), and each person gets two correlated random intercepts. His maximum likelihood fit gives a correlation of 0.66 between the community-versus-street and independent-versus-street effects, and the Bayesian posterior mean is 0.625 with a 95% interval of roughly 0.43 to 0.78. Two details are worth noting. He used the explicit `corr_matrix` with `lkj_corr(2)` and `multi_normal`, which is the older form that the current documentation discourages. He also reports that uniform priors on the scales worked better than half-Cauchy, so the prior on $\tau$ below is a choice that deserves a sensitivity check.

### Multinomial Regression in R

#### Simulating Data

``` r
library(rstan)
options(mc.cores = parallel::detectCores())

set.seed(2026)
K <- 4          # outcome categories (last is reference)
J <- 40         # groups
n_per <- 30     # observations per group
N <- J * n_per
P <- 1

alpha_true <- c(0.5, -0.3, 0.2)
beta_true  <- matrix(c(0.8, -0.5, 0.3), nrow = P)   # P x (K-1)
tau_true   <- c(0.7, 0.5, 0.9)
Omega_true <- matrix(c( 1.0,  0.6, -0.4,
                        0.6,  1.0,  0.1,
                       -0.4,  0.1,  1.0), 3, byrow = TRUE)

L_true <- t(chol(Omega_true))
Z <- matrix(rnorm(J * (K - 1)), J, K - 1)
U <- Z %*% t(diag(tau_true) %*% L_true)             # J x (K-1)

g <- rep(1:J, each = n_per)
X <- matrix(rnorm(N * P), N, P)

eta <- sweep(X %*% beta_true + U[g, ], 2, alpha_true, "+")
eta <- cbind(eta, 0)                                # reference category
prob <- exp(eta - apply(eta, 1, max))
prob <- prob / rowSums(prob)
y <- apply(prob, 1, function(p) sample.int(K, 1, prob = p))

table(y)
```

`Z %*% t(diag(tau) %*% L)` applies $u_j = \mathrm{diag}(\tau) L z_j$ to every row of `Z` at once, the same row-wise trick as in the previous post. Subtracting the row maximum before exponentiating guards against overflow. Check `table(y)` before fitting. If one category is nearly empty, the corresponding effects will be poorly identified whatever the model does.

### Multinomial Regression in Stan

#### The Stan Model

``` r
mnl_code <- "
data {
  int<lower=1> N;
  int<lower=2> K;
  int<lower=1> J;
  int<lower=1> P;
  array[N] int<lower=1, upper=K> y;
  array[N] int<lower=1, upper=J> g;
  matrix[N, P] X;
}
parameters {
  vector[K - 1] alpha;
  matrix[P, K - 1] beta;
  vector<lower=0>[K - 1] tau;
  cholesky_factor_corr[K - 1] L_Omega;
  matrix[K - 1, J] z;
}
transformed parameters {
  matrix[K - 1, J] u = diag_pre_multiply(tau, L_Omega) * z;
}
model {
  alpha ~ normal(0, 2);
  to_vector(beta) ~ normal(0, 1);
  tau ~ normal(0, 1);
  L_Omega ~ lkj_corr_cholesky(2);
  to_vector(z) ~ std_normal();

  for (n in 1:N) {
    vector[K] eta;
    eta[1:(K - 1)] = alpha + (X[n] * beta)' + u[, g[n]];
    eta[K] = 0;
    y[n] ~ categorical_logit(eta);
  }
}
generated quantities {
  corr_matrix[K - 1] Omega = multiply_lower_tri_self_transpose(L_Omega);
  vector[N] log_lik;
  for (n in 1:N) {
    vector[K] eta;
    eta[1:(K - 1)] = alpha + (X[n] * beta)' + u[, g[n]];
    eta[K] = 0;
    log_lik[n] = categorical_logit_lpmf(y[n] | eta);
  }
}
"
```

The pieces carry over from the previous post. `cholesky_factor_corr[K - 1]` constrains `L_Omega`. `diag_pre_multiply(tau, L_Omega)` gives the Cholesky factor of the covariance without building a diagonal matrix, and `multiply_lower_tri_self_transpose` returns $\Omega$ for reporting. The new parts are `categorical_logit`, which applies the softmax internally, and the explicit zero in `eta[K]` that fixes the reference category. The `log_lik` vector is only there for model comparison and can be dropped otherwise.

The priors are judgement calls. On the logit scale, `normal(0, 2)` for intercepts and `normal(0, 1)` for slopes are weakly informative for most applied problems. The `<lower=0>` constraint turns the `normal(0, 1)` on `tau` into a half-normal, which avoids the heavy tails of a half-Cauchy. An LKJ shape of 2 mildly favours weaker correlations. With only $J = 40$ groups, I would expect the posterior of $\Omega$ to lean on that prior more than the point estimates suggest.

#### Fitting and Checking

``` r
fit <- stan(model_code = mnl_code,
            data = list(N = N, K = K, J = J, P = P, y = y, g = g, X = X),
            iter = 2000, chains = 4, seed = 123,
            control = list(adapt_delta = 0.95))

print(fit, pars = c("alpha", "beta", "tau", "Omega"))
check_hmc_diagnostics(fit)
```

Compare the posterior means and intervals with `alpha_true`, `beta_true`, `tau_true` and `Omega_true`. I would expect the fixed effects to be recovered well and the correlations to be wide. The 0.1 correlation in particular is unlikely to be distinguishable from zero with 40 groups. Raising `adapt_delta` is a precaution and not a requirement. Check for divergences whichever value you use.

The loop over `n` is easy to read but not the quickest option. Stan's `categorical_logit_glm` is documented as a more efficient implementation of softmax regression than a hand-written categorical likelihood with matrix multiplication. Its signature takes a single intercept vector `alpha`, though, so observation-specific group offsets don't fit directly. They would need a loop over groups, with one GLM call per group using that group's offset as the intercept. For a model this size I would leave the loop alone and optimise only if timing becomes a problem.

To evluate if the correlation worth modelling, we could refit the model with independent group effects by replacing `L_Omega` with the identity, so that `u = diag_pre_multiply(tau, I) * z`, and compare the two fits with `loo`. If the correlated model gains nothing in expected predictive accuracy, the extra structure may not be earning its place. Two cautions apply. With this likelihood, `loo` as written leaves out single observations, which still borrows strength from the same group's other rows, so it says little about prediction for new groups. And a null result does not make the correlations meaningless. It may only mean the data carry little information about them.

The multinomial logit needs a reference category to be identified, and the correlations among group effects are defined relative to it. The Cholesky route keeps the sampler working with independent normals, separates scales from correlations, and uses the LKJ prior in the form Stan recommends . Read the entries of $\Omega$ cautiously, particularly with few groups.

### References

-   [Stan Functions Reference: Categorical logit generalized linear model (softmax regression)](https://mc-stan.org/docs/2_28/functions-reference/categorical-logit-glm.html)
-   [Stan Functions Reference: Cholesky LKJ correlation distribution](https://mc-stan.org/docs/2_27/functions-reference/cholesky-lkj-correlation-distribution.html)
-   [Rodríguez, G. Multilevel Models, Chapter 12: Models for Nominal Data (course slides)](https://grodri.github.io/multilevel/pop510slides12.pdf)
-   [grodri.github](https://grodri.github.io/multilevel/pop510slides12.pdf)
