# Model Comparison in Bayesian Analysis, Part 1: Why Compare Models, and What Posterior Predictive Checks Can (and Cannot) Tell You

*Series: Bayesian model comparison and selection. Part 1 of 3. Part 2 covers WAIC and LOO-CV; Part 3 covers Bayes factors.*

## Introduction

Once you can fit a regression, a hierarchical model and perhaps a Gaussian process, an awkward question follows: which of these should you believe? The question is less simple than it looks, because "best model" can mean at least four different things. A model can reproduce the features of the data (fit), predict new observations well (prediction), receive the most support from the data relative to alternatives given our prior beliefs (evidence), or carry a causal or mechanistic interpretation we trust (explanation). The tools in this series answer different versions of that question, and much of the confusion in applied work comes from using one tool to answer another tool's question.

This first post sets the stage. It describes the three families of tools, introduces a running example used throughout the series, and then develops posterior predictive checks (PPCs), which are best understood as tests of *adequacy* rather than tools for *ranking*. Parts 2 and 3 add the ranking tools.

## Three questions, three families of tools

| Question | Typical tool | Post |
|----|----|----|
| Does this model reproduce key features of the data? | Posterior predictive checks | 1 |
| Which model will predict new data better? | WAIC, PSIS-LOO, stacking | 2 |
| How strongly do the data support one model over another, given the priors? | Bayes factors, posterior model probabilities | 3 |

A useful background distinction, from Bernardo and Smith (1994), is between the M-closed, M-complete and M-open settings. In M-closed, the true data-generating process is among the candidate models. In M-complete it exists but is not in the candidate set. In M-open it cannot even be specified. Most applied work lives in M-open or M-complete, and that matters: Bayes factors are most natural in M-closed, whereas cross-validation-based tools do not need the assumption that any candidate is true (Vehtari & Ojanen, 2012; Yao et al., 2018). I will return to this in Part 3.

These tools also sit inside a larger iterative process. Gelman et al. (2020) describe a Bayesian workflow in which models are built, checked, expanded and compared repeatedly, and where a single final "winner" is often not the goal. I find this framing more honest than a one-shot model selection step.

## Running example

All three posts use the same data so the methods can be compared directly. We simulate counts from a negative binomial distribution, then fit a Poisson model and a negative binomial model. The Poisson model is wrong in a specific and common way: it forces the variance to equal the mean, while the data are overdispersed.

``` r
library(cmdstanr)
library(posterior)
library(bayesplot)
library(loo)
library(ggplot2)

set.seed(2026)
N <- 200
x <- rnorm(N)
mu <- exp(1 + 0.5 * x)
y <- rnbinom(N, mu = mu, size = 2)      # overdispersed truth
stan_data <- list(N = N, x = x, y = y, prior_sd = 1)
```

I chose this example over a clean linear-versus-quadratic comparison because the failure is realistic (overdispersed counts are everywhere in ecology, epidemiology and neuroscience), and because a diagnostic tool should be tested on a case where something is actually wrong.

## Posterior predictive distribution

Let $y$ be the observed data, $\theta$ the parameters, and $\tilde{y}$ a replicate of the data that could have been observed under the same model. The posterior predictive distribution is

$$
p(\tilde{y}\mid y) = \int p(\tilde{y}\mid\theta)\,p(\theta\mid y)\,d\theta .
$$

It averages the sampling distribution over posterior uncertainty in $\theta$. In practice, for each posterior draw $\theta^{(s)}$, $s = 1,\dots,S$, we simulate $y^{\text{rep}(s)} \sim p(\cdot\mid\theta^{(s)})$. The collection of replicated datasets approximates $p(\tilde{y}\mid y)$.

The core idea of a PPC (Rubin, 1984; Gelman et al., 1996) is simple. If the model is adequate, replicated data should look like the observed data. Systematic differences point to features the model fails to capture.

### Test quantities and posterior predictive p-values

To make "look like" precise, pick a test quantity $T(y,\theta)$, which may depend on parameters or only on data. Examples are the maximum, the proportion of zeros, the variance-to-mean ratio, or a residual-based discrepancy. The posterior predictive p-value is

$$
p_B = \Pr\!\big(T(y^{\text{rep}},\theta) \ge T(y,\theta)\mid y\big),
$$

estimated by the fraction of draws for which the replicated statistic is at least as large as the observed one. Values near 0 or 1 signal a problem.

A caveat deserves emphasis. Because the data are used twice (once to fit the model and once to check it), $p_B$ is not uniformly distributed under a correct model. It tends to concentrate near 0.5, so it is conservative, and it should be read as a descriptive diagnostic rather than a formal hypothesis test (Gelman et al., 2013, ch. 6; Gelman, 2003). Choosing statistics that are *not* strongly determined by the fitted parameters (for instance the maximum or the proportion of zeros, rather than the mean in a model that fits the mean directly) improves the power of the check.

## Implementation in Stan

The Stan programs below draw $y^{\text{rep}}$ in `generated quantities` and also store pointwise `log_lik`, which Part 2 needs. The `prior_sd` argument is used in Part 3 for prior sensitivity; here it is fixed at 1.

``` stan
// poisson.stan
data {
  int<lower=1> N;
  vector[N] x;
  array[N] int<lower=0> y;
  real<lower=0> prior_sd;
}
parameters {
  real alpha;
  real beta;
}
model {
  alpha ~ normal(0, 2);
  beta  ~ normal(0, prior_sd);
  y ~ poisson_log(alpha + beta * x);
}
generated quantities {
  array[N] int y_rep;
  vector[N] log_lik;
  for (n in 1:N) {
    real eta = alpha + beta * x[n];
    y_rep[n]   = poisson_log_rng(eta);
    log_lik[n] = poisson_log_lpmf(y[n] | eta);
  }
}
```

``` stan
// negbin.stan
data {
  int<lower=1> N;
  vector[N] x;
  array[N] int<lower=0> y;
  real<lower=0> prior_sd;
}
parameters {
  real alpha;
  real beta;
  real<lower=0> phi;
}
model {
  alpha ~ normal(0, 2);
  beta  ~ normal(0, prior_sd);
  phi   ~ gamma(2, 0.1);
  y ~ neg_binomial_2_log(alpha + beta * x, phi);
}
generated quantities {
  array[N] int y_rep;
  vector[N] log_lik;
  for (n in 1:N) {
    real eta = alpha + beta * x[n];
    y_rep[n]   = neg_binomial_2_log_rng(eta, phi);
    log_lik[n] = neg_binomial_2_log_lpmf(y[n] | eta, phi);
  }
}
```

Fit both with `cmdstanr`:

``` r
mod_pois <- cmdstan_model("poisson.stan")
mod_nb   <- cmdstan_model("negbin.stan")

fit_pois <- mod_pois$sample(data = stan_data, seed = 1, chains = 4,
                            parallel_chains = 4, refresh = 0)
fit_nb   <- mod_nb$sample(data = stan_data, seed = 1, chains = 4,
                          parallel_chains = 4, refresh = 0)

fit_pois$summary(c("alpha", "beta"))
fit_nb$summary(c("alpha", "beta", "phi"))
```

Always check convergence ($\hat{R}$, effective sample size, divergences) before interpreting a PPC. A PPC on a chain that has not converged mixes two problems.

## Graphical and numerical checks with bayesplot

``` r
yrep_pois <- fit_pois$draws("y_rep", format = "matrix")
yrep_nb   <- fit_nb$draws("y_rep",   format = "matrix")

# 1. Overall distribution
ppc_dens_overlay(y, yrep_pois[1:100, ]) + ggtitle("Poisson")
ppc_dens_overlay(y, yrep_nb[1:100, ])   + ggtitle("Negative binomial")

# 2. Discrete-data friendly: rootogram
ppc_rootogram(y, yrep_pois, style = "hanging") + ggtitle("Poisson")
ppc_rootogram(y, yrep_nb,   style = "hanging") + ggtitle("Negative binomial")

# 3. Targeted test statistics
ppc_stat(y, yrep_pois, stat = "max")
ppc_stat(y, yrep_nb,   stat = "max")

prop_zero <- function(v) mean(v == 0)
ppc_stat(y, yrep_pois, stat = "prop_zero")
ppc_stat(y, yrep_nb,   stat = "prop_zero")

# 4. Variance-to-mean ratio
vmr <- function(v) var(v) / mean(v)
ppc_stat(y, yrep_pois, stat = "vmr")
ppc_stat(y, yrep_nb,   stat = "vmr")

# Numerical posterior predictive p-values
ppp <- function(yrep, stat) mean(apply(yrep, 1, stat) >= stat(y))
c(max_pois = ppp(yrep_pois, max), max_nb = ppp(yrep_nb, max),
  vmr_pois = ppp(yrep_pois, vmr), vmr_nb = ppp(yrep_nb, vmr))
```

What to expect, qualitatively: because the data are overdispersed, the Poisson replicates should generate too few extreme counts and a variance-to-mean ratio that sits well below the observed one, so the observed statistic should fall in the tail of the replicated distribution. The negative binomial model should reproduce these features. Run the code and inspect the plots rather than relying on my description; the point of a PPC is the look at the data.

### The same check with rstanarm

For readers who prefer formula syntax, `rstanarm` produces the equivalent models and `pp_check()` wraps `bayesplot`:

``` r
library(rstanarm)
dat <- data.frame(x = x, y = y)

rs_pois <- stan_glm(y ~ x, family = poisson(), data = dat,
                    prior = normal(0, 1), refresh = 0, seed = 1)
rs_nb   <- stan_glm(y ~ x, family = neg_binomial_2(), data = dat,
                    prior = normal(0, 1), refresh = 0, seed = 1)

pp_check(rs_pois, plotfun = "stat", stat = "max")
pp_check(rs_nb,   plotfun = "stat", stat = "max")
pp_check(rs_pois, plotfun = "ecdf_overlay")
```

Priors are not identical to the hand-written Stan models (rstanarm's default intercept prior and the dispersion prior differ), so small numerical differences are expected.

## What PPCs cannot do

Three limitations are worth stating plainly.

First, a PPC checks *absolute* adequacy against chosen features. A model can pass every check you think to run and still be worse at prediction than a competitor. Second, a PPC has no built-in penalty for complexity; a flexible model will usually reproduce the observed data well because it has been fitted to those same data. Third, the checks are only as informative as the statistics chosen, and choosing them requires some idea of what could go wrong. Overfitted models in particular can look excellent under PPC, which is why PPC is a diagnostic complement to, not a substitute for, the predictive tools in Part 2.

A practical approach is to run PPCs for each plausible model, discard those with clear failures on substantively important features, and then rank the survivors by predictive or evidential criteria.

## Looking ahead

Part 2 introduces expected log predictive density, WAIC and PSIS-LOO, and uses the `log_lik` quantity already stored above to compare the Poisson and negative binomial models. Part 3 turns to marginal likelihoods and Bayes factors, where the prior matters in a way it does not for the tools above.

## References

Bernardo, J. M., & Smith, A. F. M. (1994). *Bayesian theory*. Wiley.

Gabry, J., Simpson, D., Vehtari, A., Betancourt, M., & Gelman, A. (2019). Visualization in Bayesian workflow. *Journal of the Royal Statistical Society: Series A, 182*(2), 389–402.

Gelman, A. (2003). A Bayesian formulation of exploratory data analysis and goodness-of-fit testing. *International Statistical Review, 71*(2), 369–382.

Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013). *Bayesian data analysis* (3rd ed.). Chapman & Hall/CRC.

Gelman, A., Meng, X.-L., & Stern, H. (1996). Posterior predictive assessment of model fitness via realized discrepancies. *Statistica Sinica, 6*(4), 733–760.

Gelman, A., Vehtari, A., Simpson, D., Margossian, C. C., Carpenter, B., Yao, Y., Kennedy, L., Gabry, J., Bürkner, P.-C., & Modrák, M. (2020). Bayesian workflow. *arXiv:2011.01808*.

Rubin, D. B. (1984). Bayesianly justifiable and relevant frequency calculations for the applied statistician. *The Annals of Statistics, 12*(4), 1151–1172.

Vehtari, A., & Ojanen, J. (2012). A survey of Bayesian predictive methods for model assessment, selection and comparison. *Statistics Surveys, 6*, 142–228.

Yao, Y., Vehtari, A., Simpson, D., & Gelman, A. (2018). Using stacking to average Bayesian predictive distributions. *Bayesian Analysis, 13*(3), 917–1007.

