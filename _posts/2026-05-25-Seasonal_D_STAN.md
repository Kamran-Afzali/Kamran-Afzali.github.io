---
layout: post
categories: posts
title: Bayesian Seasonal Decomposition in Stan
featured-image: /images/stan.png
tags: [STAN, Time seires, Bayes]
date-string: May 2026 
---

# Bayesian Seasonal Decomposition in Stan

Understanding what drives a time series is not straightforward, with most series you encounter in the real world are shaped by several overlapping forces at once: a slow-moving trend, a repeating seasonal rhythm, and a layer of noise on top of of that. Learning to pull these apart cleanly is one of the foundational skills in time series analysis. Classical decomposition methods like STL have been doing this job for decades, and they do it well. But they share a fundamental limitation of being deterministic. You get a single point estimate for each component, with no indication of how much you can trust it. When your data is short, noisy, or irregularly sampled, that hidden uncertainty can be enormous. Ignoring it tends to produce overconfident conclusions downstream — the kind that look precise on paper but quietly fall apart under scrutiny. Bayesian seasonal decomposition is an alternative that rather than treating each component as a fixed quantity to be estimated treats them as latent random variables, each with a full probability distribution. Instead of asking "what is the trend?", we ask "what does the posterior distribution over plausible trend trajectories look like, given the data?" In this post, we'll build a Bayesian structural time series model in Stan from scratch, fit it using RStan, and extract posterior estimates for each component. Before fitting anything, though, we need data. We'll start with a synthetic series where we already know the ground truth — the exact generating process — so we can actually verify whether the model is recovering what it should. The series combines a gentle linear trend, a sinusoidal seasonal pattern with a 12-period cycle, and Gaussian noise. Think of it as a rough analogue to monthly retail sales: slowly growing over time, with a familiar seasonal rhythm and some unexplained variation on top. With 120 observations spanning exactly 10 complete seasonal cycles, the model has enough structure to get a solid grip on both the trend and the seasonal shape. A noise standard deviation of 0.5 — meaningful relative to the signal — means this isn't a trivially easy decomposition problem. It's a realistic one.

```r
set.seed(123)
n <- 120
t <- 1:n
trend <- 0.05 * t
seasonal_period <- 12
seasonal <- rep(sin(2 * pi * (1:seasonal_period) / seasonal_period), length.out = n)
noise <- rnorm(n, 0, 0.5)
y <- trend + seasonal + noise

ts.plot(y, main = "Simulated Time Series with Trend and Seasonality")
```


## Seasonal Decomposition

The core idea is an additive decomposition: at each time point \(t\), the observed value is the sum of a trend component, a seasonal component, and residual noise.

$\[
y_t = \mu_t + \gamma_t + \epsilon_t, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
\]$

Each piece has its own dynamics. The trend \(\mu_t\) follows a **local level model** — a random walk that allows the trend to drift gradually over time rather than forcing it to follow a rigid parametric shape:

$\[
\mu_t = \mu_{t-1} + \eta_t, \quad \eta_t \sim \mathcal{N}(0, \sigma_{\mu}^2)
\]$

The parameter $\(\sigma_\mu\)$ controls how volatile the trend is. A small value keeps the trend smooth; a larger value allows it to change direction more rapidly. The posterior will learn a value that balances flexibility against overfitting. The seasonal component $\(\gamma_t\)$ is modeled as a set of $\(s\)$ free parameters — one per season — constrained to sum to zero over a full period. That zero-sum constraint is what makes the decomposition **identifiable**: without it, you could shift any constant between the trend and the seasonal component and produce an equally valid fit. By centering the seasonal effects, we pin down a unique solution.

```stan
stan_model_1 <-'data {
  int<lower=2> N;
  int<lower=2> s;           // seasonal period
  vector[N] y;
}
parameters {
  vector[N] mu;             // trend
  vector[s] season_raw;     // raw seasonal effects
  real<lower=0> sigma;
  real<lower=0> sigma_mu;
  real<lower=0> sigma_season;
}
transformed parameters {
  vector[N] season;
  vector[s] season_clean;
  
  // Center seasonal component to sum to zero
  season_clean = season_raw - mean(season_raw);
  
  for (t in 1:N)
    season[t] = season_clean[1 + ((t - 1) % s)];
}
model {
  mu[2:N] ~ normal(mu[1:(N - 1)], sigma_mu);
  season_raw ~ normal(0, sigma_season);
  y ~ normal(mu + season, sigma);
}'
```

This model specifies a Bayesian structural time series with additive trend and seasonal components, where the observed series $( y_t )$ is decomposed into a latent level $( \mu_t )$, a periodic seasonal effect, and Gaussian observation noise. The trend component $( \mu_t )$ evolves as a first-order random walk, formalized by the prior $( \mu_t \sim \mathcal{N}(\mu_{t-1}, \sigma_\mu) )$ for $( t = 2, \dots, N )$, which encodes local smoothness while allowing gradual, stochastic shifts over time. Seasonality is introduced through a vector of raw seasonal effects of length $( s )$, corresponding to the known period (e.g., 12 for monthly data), which are subsequently centered to enforce a sum-to-zero constraint; this transformation addresses identifiability by preventing confounding between the overall level and seasonal offsets. The centered seasonal vector is then recycled across time via modular indexing, so that each observation inherits the appropriate seasonal adjustment according to its position within the cycle. Both the observation noise $( \sigma )$, the trend innovation scale $( \sigma_\mu )$, and the seasonal variability $( \sigma_{\text{season}} )$ are assigned implicit priors through their role as scale parameters in normal distributions. Finally, the likelihood is specified as $( y_t \sim \mathcal{N}(\mu_t + \text{season}_t, \sigma) )$, implying that deviations from the combined latent structure are independently and normally distributed. Taken together, the model can be understood as a relatively flexible decomposition that captures smooth underlying dynamics and recurring seasonal patterns, while maintaining identifiability through centering constraints and borrowing strength across time via hierarchical structure. With the model defined, fitting it in R is straightforward. We package the data into a list and pass it to `stan()`, running 4 chains with 2000 iterations each (the first 1000 are warmup).

## Model Fitting and Extracting the Components


```r
library(rstan)

data_list <- list(
  N = length(y),
  s = seasonal_period,
  y = y
)

fit <- stan(
  model_code = stan_model_1,
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000,
  seed = 123
)

print(fit, pars = c("sigma", "sigma_mu", "sigma_season"))
```

Once the model fit is done, take note of the $\(\hat{R}\)$ values and effective sample sizes printed by `print(fit)`. For a model of this complexity, you want $\(\hat{R} < 1.01\)$ for all parameters, which indicates the chains have converged to the same distribution. If the trend parameters are mixing slowly — which can happen when the noise level is high — you may need to increase iterations or consider reparameterizing. The posterior estimates for `sigma`, `sigma_mu`, and `sigma_season` are particularly informative. If `sigma_mu` comes back near zero, it's telling you the trend is essentially linear and doesn't need the flexibility of a random walk. If `sigma_season` is large relative to `sigma`, the seasonal component is being estimated with relatively high uncertainty — which might prompt you to question whether your chosen period is correct.

Once the model has run, we extract the posterior samples and summarize them with posterior means. Because we're working with full distributions, we could just as easily compute credible intervals or a visualization with posterior samples.

```r
posterior <- extract(fit)
mu_hat <- apply(posterior$mu, 2, mean)
season_hat <- apply(posterior$season, 2, mean)

par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))
plot(y, type = 'l', main = "Observed Time Series", ylab = "y")
plot(mu_hat, type = 'l', col = "blue", main = "Estimated Trend (mu)", ylab = "mu_t")
plot(season_hat, type = 'l', col = "darkgreen", main = "Estimated Seasonal Component", ylab = "season_t")
```

One of the most useful things you can do here is to go beyond point estimates and shade credible intervals around each component. Something like `apply(posterior$mu, 2, quantile, probs = c(0.05, 0.95))` gives you the 5th and 95th percentiles of the trend at each time point, which you can plot as a ribbon. In practice, these intervals tend to widen at the edges of the observed data and in periods where the trend is changing direction quickly — exactly where you'd want to know your uncertainty is high.

## What comes next?

The model above is simple but it serves as a foundation for a range of more complex models. A natural first extension is to introduce a **local linear trend**, which adds a time-varying slope $\(\nu_t\)$ alongside the level:

$\[
\mu_t = \mu_{t-1} + \nu_{t-1} + \eta_t, \quad \nu_t = \nu_{t-1} + \zeta_t
\]$

Another useful direction is adding **regression components** — external predictors that explain some of the variation in $\(y_t\)$. Holiday indicators, weather variables, or economic covariates can all be incorporated by adding a linear predictor $\(\mathbf{x}_t^\top \boldsymbol{\beta}\)$ to the observation equation. The Bayesian framework handles this because the of uncertainty in the regression coefficients being integrated into uncertainty about the decomposed components. Finally, if you're working with multiple related time series **hierarchical seasonal decomposition** lets you share information across series. Individual series can have their own trend and seasonal parameters, but those parameters are drawn from a common prior, which regularizes the estimates and borrows strength where data is sparse. Bayesian seasonal decomposition is one of those techniques that has much more work upfront than just running a frequentist `stl()` you should, write a Stan model, wait for MCMC to run, and diagnose the convergence. But as a payoff you get uncertainty estimates that are statistically coherent, a model structure that can be extended in principled ways, and a decomposition that reflects what the data actually supports rather than what a deterministic algorithm happens to produce. For exploratory work, the posterior means alone are often enough to get a clean visual decomposition. For anything that feeds into a downstream decision — a forecast, an anomaly detection system, a causal analysis the full posterior matters, and the Bayesian approach is the right tool for the job.

## **References**

- [mc-stan time series](https://mc-stan.org/docs/stan-users-guide/time-series.html)
- [minimizeregret time series](https://minimizeregret.com/short-time-series-prior-knowledge)
- [bayesiancomputationbook](https://bayesiancomputationbook.com/markdown/chp_06.html)
- [guillaume.baudart](https://guillaume.baudart.eu/papers/pldi21.pdf)
- [cran.r-project](https://cran.r-project.org/web/packages/bayesforecast/bayesforecast.pdf)
