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



# Model Comparison in Bayesian Analysis, Part 3: Bayes Factors and Marginal Likelihoods

*Series: Bayesian model comparison and selection. Part 3 of 3. Part 1 covered posterior predictive checks; Part 2 covered WAIC, LOO-CV and stacking.*

## Introduction

Bayes factors answer a different question from the tools in Part 2. Instead of asking which model predicts new data better, they ask how much the observed data shift belief from one model to another, given what each model said about plausible parameter values before seeing the data. That makes them natural for hypothesis testing and for M-closed settings, and it makes them sensitive to prior choices in a way that WAIC and LOO largely are not. This post defines the marginal likelihood, shows how to compute it with bridge sampling in Stan, gives the Savage–Dickey shortcut for nested models, demonstrates prior sensitivity on the running example, and offers some guidance on when to use (and avoid) Bayes factors.

## Marginal likelihood and the Bayes factor

For a model $M_k$ with parameters $\theta_k$, the marginal likelihood (or model evidence) is

$$
p(y\mid M_k) = \int p(y\mid\theta_k, M_k)\,p(\theta_k\mid M_k)\,d\theta_k .
$$

It is the likelihood averaged over the prior. Applying Bayes' theorem at the model level gives posterior model probabilities,

$$
p(M_k\mid y) = \frac{p(y\mid M_k)\,p(M_k)}{\sum_j p(y\mid M_j)\,p(M_j)},
$$

and the ratio of two models' posterior odds factorizes as

$$
\underbrace{\frac{p(M_1\mid y)}{p(M_2\mid y)}}_{\text{posterior odds}}
= \underbrace{\frac{p(y\mid M_1)}{p(y\mid M_2)}}_{BF_{12}}
\times \underbrace{\frac{p(M_1)}{p(M_2)}}_{\text{prior odds}} .
$$

So the Bayes factor $BF_{12}$ is the factor by which the data update the prior odds, and it is the posterior odds when the two models are equally probable a priori. Note that the Bayes factor itself does *not* contain prior model probabilities; it is the part of the update that comes from the data (and from the within-model priors).

### Occam's razor built in, and where it comes from

The marginal likelihood penalizes complexity automatically. A model with a wide prior spreads its predictive mass over many possible datasets; unless the observed data fall where that mass is concentrated, it is penalized relative to a model that predicted them more sharply. This is conceptually attractive, but it also reveals the weakness: the penalty depends directly on the prior's width, including for parameters that are not scientifically interesting.

### Interpretation scales

Two scales appear in the literature, and they are easy to confuse. Jeffreys (1961) and later Lee and Wagenmakers (2013) use categories on the Bayes factor scale (for example, 1–3 anecdotal, 3–10 moderate, 10–30 strong, 30–100 very strong, \>100 extreme). Kass and Raftery (1995) define categories on the $2\log BF$ scale, which corresponds roughly to the deviance scale: 0–2 "not worth more than a bare mention," 2–6 positive, 6–10 strong, and above 10 very strong. On the Bayes factor scale those cutoffs are approximately 1–3, 3–20, 20–150 and above 150. Always state which convention you use. These labels are conventions, not decision rules, and the same Bayes factor can warrant different action depending on the costs involved.

## The prior sensitivity problem

Consider a regression coefficient $\beta$ with prior $\beta\sim N(0,\tau^2)$. As $\tau$ grows, the marginal likelihood of a model that includes $\beta$ falls, because probability is spread over implausibly large effects, and the Bayes factor in favor of the simpler model rises without bound. This is the Bartlett–Lindley paradox (Lindley, 1957; Bartlett, 1957): with a sufficiently diffuse prior, a Bayes factor will favor the null even when a frequentist test or posterior interval would clearly indicate an effect. The posterior of $\beta$ hardly changes with $\tau$ once $\tau$ is large, but the marginal likelihood keeps falling.

Two practical consequences follow. First, "weakly informative" or "vague" priors, which are fine for estimation and for LOO, can be inappropriate for Bayes factors. Priors must be chosen to represent a genuine hypothesis about effect sizes. Second, any reported Bayes factor should be accompanied by a sensitivity analysis over a defensible range of priors (Kass & Raftery, 1995; Gronau et al., 2019), which we do below.

## Computing marginal likelihoods with bridge sampling

The marginal likelihood is an integral over the whole parameter space, so MCMC output alone does not give it directly. Bridge sampling (Meng & Wong, 1996) estimates it from posterior draws using an auxiliary "proposal" density, and it handles the models Stan users typically fit (Gronau et al., 2017). The `bridgesampling` package takes a `stanfit` object from `rstan` and extracts what it needs from the Stan model; it needs a model that defines the *full* joint density, with all constants retained. In Stan, that means using `~` statements with care: dropped constants are fine for sampling but wrong for marginal likelihoods in some formulations. Writing priors and likelihoods with `~` is typically safe in current Stan because `bridgesampling` evaluates `log_prob` with `jacobian = FALSE`-aware routines, but confirm this against the package vignettes for your versions. If in doubt, rewrite using `target +=` statements with full `_lpdf`/`_lpmf` functions.

Because `bridgesampling` works with `rstan` objects, this post switches from `cmdstanr` to `rstan` for the Bayes factor step. Use more iterations than you would for estimation (the estimate's Monte Carlo error depends on the number of draws), and check the error with `error_measures()`.

``` stan
// poisson_bf.stan  -- no generated quantities needed
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
  target += normal_lpdf(alpha | 0, 2);
  target += normal_lpdf(beta  | 0, prior_sd);
  target += poisson_log_lpmf(y | alpha + beta * x);
}
```

``` stan
// negbin_bf.stan
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
  target += normal_lpdf(alpha | 0, 2);
  target += normal_lpdf(beta  | 0, prior_sd);
  target += gamma_lpdf(phi   | 2, 0.1);
  target += neg_binomial_2_log_lpmf(y | alpha + beta * x, phi);
}
```

``` r
library(rstan)
library(bridgesampling)

# Same simulated data as Parts 1 and 2
set.seed(2026)
N <- 200
x <- rnorm(N)
y <- rnbinom(N, mu = exp(1 + 0.5 * x), size = 2)
stan_data <- list(N = N, x = x, y = y, prior_sd = 1)

fit_p  <- stan("poisson_bf.stan", data = stan_data,
               iter = 10000, warmup = 2000, chains = 4, seed = 1, refresh = 0)
fit_nb <- stan("negbin_bf.stan",  data = stan_data,
               iter = 10000, warmup = 2000, chains = 4, seed = 1, refresh = 0)

bs_p  <- bridge_sampler(fit_p,  silent = TRUE)
bs_nb <- bridge_sampler(fit_nb, silent = TRUE)

print(bs_nb)                              # log marginal likelihood
error_measures(bs_nb)                     # approximate relative error
bf(bs_nb, bs_p)                           # BF of NB over Poisson
post_prob(bs_nb, bs_p, prior_prob = c(0.5, 0.5))
```

Repeat `bridge_sampler()` a few times with different seeds (`set.seed()` before each call) to check that the log marginal likelihood is stable to at least the precision you intend to report. When bridge sampling is unstable, the usual causes are a posterior that is far from normal in the unconstrained space, a very high-dimensional parameter space, or too few draws.

## Prior sensitivity analysis

We now vary the prior standard deviation on $\beta$, holding everything else fixed, and recompute the Bayes factor. Here the comparison is between the negative binomial model and a Poisson model, which differ in the likelihood; but the effect of $\tau$ is easiest to see when comparing models with and without $\beta$. We do both.

``` r
fit_nb_null <- stan_model("negbin_null_bf.stan")   # same as negbin_bf.stan but without beta
```

``` stan
// negbin_null_bf.stan : H0, beta = 0
data {
  int<lower=1> N;
  vector[N] x;
  array[N] int<lower=0> y;
  real<lower=0> prior_sd;   // unused, kept for a common data list
}
parameters {
  real alpha;
  real<lower=0> phi;
}
model {
  target += normal_lpdf(alpha | 0, 2);
  target += gamma_lpdf(phi   | 2, 0.1);
  target += neg_binomial_2_log_lpmf(y | alpha, phi);
}
```

``` r
mod_nb   <- stan_model("negbin_bf.stan")
mod_null <- stan_model("negbin_null_bf.stan")

log_ml <- function(model, tau) {
  d <- modifyList(stan_data, list(prior_sd = tau))
  f <- sampling(model, data = d, iter = 10000, warmup = 2000,
                chains = 4, seed = 1, refresh = 0)
  bridge_sampler(f, silent = TRUE)$logml
}

taus <- c(0.1, 0.5, 1, 5, 20, 100)
res <- data.frame(
  tau    = taus,
  logml1 = sapply(taus, function(t) log_ml(mod_nb, t)),
  logml0 = sapply(taus, function(t) log_ml(mod_null, t))
)
res$log10_BF10 <- (res$logml1 - res$logml0) / log(10)
res
```

Reading the results: as $\tau$ increases, the log marginal likelihood of the model containing $\beta$ should fall steadily, and the Bayes factor for $\beta \neq 0$ should shrink, even though the data are generated with a clearly nonzero slope and the posterior for $\beta$ is essentially unchanged across these priors. Very small $\tau$ may also hurt, if the prior rules out the true slope. If your table shows the Bayes factor changing by orders of magnitude across a range of priors you consider plausible, that is the finding to report. Run the same loop with LOO (using the `negbin.stan` program from Part 1 with `prior_sd = tau`) to see that elpd differences are much more stable.

## The Savage–Dickey density ratio

For nested models, where the null fixes a parameter at a value, there is a shortcut that needs only one fit. Let $M_1$ have parameters $(\delta,\psi)$ and let $M_0$ be the restriction $\delta=\delta_0$. If the prior on $\psi$ under $M_1$ at $\delta=\delta_0$ equals the prior on $\psi$ under $M_0$, i.e. $p(\psi\mid\delta_0,M_1)=p(\psi\mid M_0)$, then

$$
BF_{01} = \frac{p(y\mid M_0)}{p(y\mid M_1)} = \frac{p(\delta=\delta_0\mid y, M_1)}{p(\delta=\delta_0\mid M_1)} .
$$

The derivation follows from writing $p(\delta_0\mid y,M_1)=p(y\mid\delta_0,M_1)\,p(\delta_0\mid M_1)/p(y\mid M_1)$ and noting that $p(y\mid\delta_0,M_1)=p(y\mid M_0)$ under the condition above (Dickey & Lientz, 1970; Wagenmakers et al., 2010). In words: if the posterior density at the null value is higher than the prior density there, the data support the null.

``` r
# Savage-Dickey for H0: beta = 0 in the negative binomial model
post_beta <- extract(fit_nb, "beta")$beta         # from fit_nb above, tau = 1

# Posterior density at 0 via kernel density estimate
dens <- density(post_beta, from = -1, to = 1, n = 2048)
post0  <- approx(dens$x, dens$y, xout = 0)$y
prior0 <- dnorm(0, mean = 0, sd = 1)               # tau = 1

BF01 <- post0 / prior0
BF10 <- 1 / BF01
c(BF01 = BF01, BF10 = BF10)
```

Compare `BF10` with the bridge sampling result at $\tau=1$ from the sensitivity loop; they should agree approximately. Two caveats. The ratio depends on estimating a posterior density at a point that is typically far in the tail when the evidence against the null is strong, so the kernel estimate can be very noisy; a logspline estimator or a parametric approximation (e.g., a normal fit to the draws) is often more stable. And the condition on the conditional priors is easy to violate with reparameterized or correlated models, so check it explicitly.

## The BayesFactor package and rstanarm

For standard designs (t-tests, ANOVA, linear regression), the `BayesFactor` package uses default priors with closed-form or fast numerical marginal likelihoods (Morey & Rouder, 2018):

``` r
library(BayesFactor)
set.seed(1)
d <- data.frame(x = x, ly = log1p(y))
lmBF(ly ~ x, data = d)                 # BF against the intercept-only model
regressionBF(ly ~ x, data = d)
```

This transforms the response to fit a Gaussian linear model, so it does not directly address the count-model comparison above, but it illustrates the workflow for the models it supports. For `rstanarm`, `bridge_sampler()` works on fitted objects if the model was fit with `diagnostic_file` set or, in current versions of `bridgesampling`, via the stanfit stored in the object. Because this route has changed across package versions, check the documentation for your installed versions before relying on it, and prefer the explicit Stan route above when reproducibility matters.

## Bayes factors and cross-validation: a conceptual link

The log marginal likelihood can be decomposed as a sum of sequential one-step-ahead predictions,

$$
\log p(y\mid M) = \sum_{i=1}^{n}\log p(y_i\mid y_{<i}, M),
$$

so it evaluates predictive performance of a model that starts from the prior and learns as data arrive, including the early observations when the prior dominates. LOO instead scores each point given all the others. The difference explains the sensitivity: the early terms in the sum are heavily influenced by prior width, and diffuse priors predict badly in the first few observations. This is a conceptual rather than a numerical equivalence, but it gives a useful reading of why the two approaches can disagree (Gelman et al., 2013, ch. 7; Vehtari & Ojanen, 2012).

## Choosing among the three families

| Situation | Reasonable default |
|----|----|
| Checking whether a model reproduces features of the data | Posterior predictive checks (Part 1) |
| Choosing among models for prediction | PSIS-LOO, with stacking if no model dominates (Part 2) |
| Testing a precise hypothesis with a prior you can defend | Bayes factor, with sensitivity analysis (Part 3) |
| Weak or exploratory priors | Avoid Bayes factors; use LOO and report posterior estimates |
| Many candidate predictors | Projection predictive methods or regularized priors, not pairwise Bayes factors |

Bayes factors and LOO can legitimately disagree. In the sensitivity table above, a Bayes factor may flip from supporting to undermining a coefficient as the prior widens, while the elpd difference stays put. Which is "right" depends on what is being asked: the former evaluates the hypothesis *together with the prior used to express it*, the latter evaluates predictive accuracy of the fitted model. Mixing them up is the most common error I see in applied papers.

An alternative to a point-null Bayes factor is to estimate the effect and report a posterior interval relative to a region of practical equivalence (Kruschke, 2018), which avoids the need to commit to a spike-and-slab prior but answers a slightly different question.

## Limitations and reporting checklist

Bayes factors depend on the priors, on the estimator, and on the model set; none of these is eliminated by a larger sample. A sensible report states the priors in full, the estimation method and its Monte Carlo error, the convention used to describe strength of evidence, and the results across a prior sensitivity range. If the conclusion changes within that range, say so. Because this series is a tutorial and the code was written without being run for this write-up, please run it on your own installation and check the outputs, particularly the bridge sampling steps, whose interface depends on package versions.

## References

Bartlett, M. S. (1957). A comment on D. V. Lindley's statistical paradox. *Biometrika, 44*(3–4), 533–534.

Dickey, J. M., & Lientz, B. P. (1970). The weighted likelihood ratio, sharp hypotheses about chances, the order of a Markov chain. *The Annals of Mathematical Statistics, 41*(1), 214–226.

Gelman, A., Carlin, J. B., Stern, H. S., Dunson, D. B., Vehtari, A., & Rubin, D. B. (2013). *Bayesian data analysis* (3rd ed.). Chapman & Hall/CRC.

Gronau, Q. F., Sarafoglou, A., Matzke, D., Ly, A., Boehm, U., Marsman, M., Leslie, D. S., Forster, J. J., Wagenmakers, E.-J., & Steingroever, H. (2017). A tutorial on bridge sampling. *Journal of Mathematical Psychology, 81*, 80–97.

Gronau, Q. F., Singmann, H., & Wagenmakers, E.-J. (2020). bridgesampling: An R package for estimating normalizing constants. *Journal of Statistical Software, 92*(10), 1–29.

Gronau, Q. F., Ly, A., & Wagenmakers, E.-J. (2019). Informed Bayesian t-tests. *The American Statistician, 74*(2), 137–143.

Jeffreys, H. (1961). *Theory of probability* (3rd ed.). Oxford University Press.

Kass, R. E., & Raftery, A. E. (1995). Bayes factors. *Journal of the American Statistical Association, 90*(430), 773–795.

Kruschke, J. K. (2018). Rejecting or accepting parameter values in Bayesian estimation. *Advances in Methods and Practices in Psychological Science, 1*(2), 270–280.

Lee, M. D., & Wagenmakers, E.-J. (2013). *Bayesian cognitive modeling: A practical course*. Cambridge University Press.

Lindley, D. V. (1957). A statistical paradox. *Biometrika, 44*(1–2), 187–192.

Meng, X.-L., & Wong, W. H. (1996). Simulating ratios of normalizing constants via a simple identity: A theoretical exploration. *Statistica Sinica, 6*(4), 831–860.

Morey, R. D., & Rouder, J. N. (2018). *BayesFactor: Computation of Bayes factors for common designs* (R package). <https://CRAN.R-project.org/package=BayesFactor>

Vehtari, A., & Ojanen, J. (2012). A survey of Bayesian predictive methods for model assessment, selection and comparison. *Statistics Surveys, 6*, 142–228.

Wagenmakers, E.-J., Lodewyckx, T., Kuriyal, H., & Grasman, R. (2010). Bayesian hypothesis testing for psychologists: A tutorial on the Savage–Dickey method. *Cognitive Psychology, 60*(3), 158–189.
