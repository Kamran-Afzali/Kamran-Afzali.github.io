# Bayesian Seasonal Decomposition in Stan and RStan

Understanding what's driving a time series is complex with most series you encounter in the real are shaped by several overlapping forces at once: a slow-moving trend, a repeating seasonal rhythm, and a layer of noise that obscures both. Pulling these apart cleanly is one of the foundational aspects of time series analysis. Classical decomposition methods like STL have been doing this job for decades, but they share a fundamental limitation of being deterministic. You get point estimates for each component, with no sense of how confident you should be in them. When your data is short, noisy, or irregularly sampled, that uncertainty can be enormous — and ignoring it leads to overconfident conclusions downstream. Bayesian seasonal decomposition bypass this by treating each component as a latent random quantity with a full probability distribution. Rather than asking "what is the trend?", we ask "what does the posterior distribution over plausible trend trajectories look like given the data?" That's a much richer and more honest answer. In this post, we'll build a Bayesian structural time series model in Stan from scratch, fit it using RStan, and extract posterior estimates for each component.


## Simulating data

Before fitting anything, we need data to work wit and we could start with a synthetic series where we know the ground truth (i.e. generating process). That way, we can actually check whether our model is recovering what it should. The series below combines a gentle linear trend, a sinusoidal seasonal pattern with a 12-period cycle, and Gaussian noise. Think of it as a rough analogue to something like monthly retail sales: slowly growing over time, with a recurring seasonal pattern and some unexplained variation on top. With 120 observations and a period of 12, we have exactly 10 complete seasonal cycles — enough for the model to get a solid grip on both the trend and the seasonal shape. The noise standard deviation of 0.5 is meaningful relative to the signal, so this isn't a trivially easy decomposition problem.

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


## The Bayesian Model

The core idea is an additive decomposition: at each time point \(t\), the observed value is the sum of a trend component, a seasonal component, and residual noise.

$\[
y_t = \mu_t + \gamma_t + \epsilon_t, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
\]$

Each piece has its own dynamics. The trend \(\mu_t\) follows a **local level model** — a random walk that allows the trend to drift gradually over time rather than forcing it to follow a rigid parametric shape:

$\[
\mu_t = \mu_{t-1} + \eta_t, \quad \eta_t \sim \mathcal{N}(0, \sigma_{\mu}^2)
\]$

The parameter \(\sigma_\mu\) controls how volatile the trend is. A small value keeps the trend smooth; a larger value allows it to change direction more rapidly. The posterior will learn a value that balances flexibility against overfitting. The seasonal component \(\gamma_t\) is modeled as a set of \(s\) free parameters — one per season — constrained to sum to zero over a full period. That zero-sum constraint is what makes the decomposition **identifiable**: without it, you could shift any constant between the trend and the seasonal component and produce an equally valid fit. By centering the seasonal effects, we pin down a unique solution.

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

In this model the `season_raw` vector holds the unconstrained seasonal effects, and we shift them in `transformed parameters` by subtracting their mean. This centering happens before the likelihood is evaluated, so every posterior sample automatically satisfies the identifiability constraint. The `%` operator handles the cyclic indexing — it wraps the time index back around to position 1 after every \(s\) steps, so the same 12 seasonal effects repeat across all 10 cycles.

## Fitting the Model

With the model defined, fitting it in R is straightforward. We package the data into a list and pass it to `stan()`, running 4 chains with 2000 iterations each (the first 1000 are warmup).

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

Once the model fit is done, take note of the \(\hat{R}\) values and effective sample sizes printed by `print(fit)`. For a model of this complexity, you want \(\hat{R} < 1.01\) for all parameters, which indicates the chains have converged to the same distribution. If the trend parameters are mixing slowly — which can happen when the noise level is high — you may need to increase iterations or consider reparameterizing. The posterior estimates for `sigma`, `sigma_mu`, and `sigma_season` are particularly informative. If `sigma_mu` comes back near zero, it's telling you the trend is essentially linear and doesn't need the flexibility of a random walk. If `sigma_season` is large relative to `sigma`, the seasonal component is being estimated with relatively high uncertainty — which might prompt you to question whether your chosen period is correct.


## Extracting and Visualizing the Components

Once the model has run, we extract the posterior samples and summarize them with posterior means. Because we're working with full distributions, we could just as easily compute credible intervals or plot entire ensembles of trend trajectories — but posterior means give a clean starting point for visualization.

```r
posterior <- extract(fit)
mu_hat <- apply(posterior$mu, 2, mean)
season_hat <- apply(posterior$season, 2, mean)

par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))
plot(y, type = 'l', main = "Observed Time Series", ylab = "y")
plot(mu_hat, type = 'l', col = "blue", main = "Estimated Trend (mu)", ylab = "mu_t")
plot(season_hat, type = 'l', col = "darkgreen", main = "Estimated Seasonal Component", ylab = "season_t")
```

Looking at these three panels together tells a clear story. The observed series looks messy — trend and seasonality are tangled together and the noise makes both hard to see cleanly. The estimated trend panel reveals the smooth underlying growth, freed from the seasonal oscillations. And the seasonal panel shows the repeating 12-period wave, now separated from both the trend and the noise.

One of the most useful things you can do here is to go beyond point estimates and shade credible intervals around each component. Something like `apply(posterior$mu, 2, quantile, probs = c(0.05, 0.95))` gives you the 5th and 95th percentiles of the trend at each time point, which you can plot as a ribbon. In practice, these intervals tend to widen at the edges of the observed data and in periods where the trend is changing direction quickly — exactly where you'd want to know your uncertainty is high.


## Conclusion and Extensions

The model above is deliberately simple, but it serves as a foundation for a range of more realistic applications. A natural first extension is to introduce a **local linear trend**, which adds a time-varying slope \(\nu_t\) alongside the level:

\[
\mu_t = \mu_{t-1} + \nu_{t-1} + \eta_t, \quad \nu_t = \nu_{t-1} + \zeta_t
\]

This allows the trend to accelerate or decelerate over time, which is often more realistic than assuming a constant growth rate. Google's BSTS package (and the related CausalImpact framework) uses exactly this kind of local linear trend as its backbone.

Another useful direction is adding **regression components** — external predictors that explain some of the variation in \(y_t\). Holiday indicators, weather variables, or economic covariates can all be incorporated by adding a linear predictor \(\mathbf{x}_t^\top \boldsymbol{\beta}\) to the observation equation. The Bayesian framework handles this gracefully, because the uncertainty in the regression coefficients propagates naturally into uncertainty about the decomposed components.

Finally, if you're working with multiple related time series — say, sales across different product categories or web traffic across different regions — **hierarchical seasonal decomposition** lets you share information across series. Individual series can have their own trend and seasonal parameters, but those parameters are drawn from a common prior, which regularizes the estimates and borrows strength where data is sparse.


Bayesian seasonal decomposition is one of those techniques that feels like more work upfront than just running `stl()` — and honestly, it is. Writing a Stan model, waiting for MCMC to run, and diagnosing convergence takes real effort. But the payoff is substantial. You get uncertainty estimates that are statistically coherent, a model structure that can be extended in principled ways, and a decomposition that reflects what the data actually supports rather than what a deterministic algorithm happens to produce.

For exploratory work, the posterior means alone are often enough to get a clean visual decomposition. For anything that feeds into a downstream decision — a forecast, an anomaly detection system, a causal analysis the full posterior matters, and the Bayesian approach is the right tool for the job.

