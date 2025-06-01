**Bayesian Structural Time Series (BSTS) in Stan and RStan: A Comprehensive Overview**

**Introduction**

Time series data are ubiquitous across scientific and applied domains, including economics, epidemiology, and environmental monitoring. Extracting meaningful patterns from such data requires statistical models that account for temporal dependencies, seasonality, trend, and potential structural breaks. Bayesian Structural Time Series (BSTS) models provide a principled framework for decomposing time series into interpretable components while incorporating prior information and quantifying uncertainty. Initially popularized by Google for causal impact analysis, BSTS models extend classical structural time series approaches by embedding them in a fully Bayesian inference framework. In this post, we describe the core structure of BSTS models, implement them in Stan and RStan, and illustrate how they facilitate inference on latent components and predictions.

**Model Specification**

A BSTS model represents an observed time series as the sum of latent components such as trend, seasonality, and regression effects. The canonical formulation of a BSTS model is as follows:

$y_t = \mu_t + \tau_t + \gamma_t + \varepsilon_t, \quad \varepsilon_t \sim \mathcal{N}(0, \sigma^2)$

where:

* $\mu_t$ is the local level or trend component
* $\tau_t$ is a stochastic trend (e.g., slope or drift)
* $\gamma_t$ represents seasonal components
* $\varepsilon_t$ is an observation error term

A simple local level plus trend model can be specified via:

$\mu_t = \mu_{t-1} + \tau_{t-1} + \eta_t, \quad \eta_t \sim \mathcal{N}(0, \sigma_\mu^2)$
$\tau_t = \tau_{t-1} + \zeta_t, \quad \zeta_t \sim \mathcal{N}(0, \sigma_\tau^2)$

If seasonality is present, a common seasonal component is modeled using periodic dummy variables or trigonometric terms.

**Simulating a Time Series with Trend and Seasonality**

```r
set.seed(42)
n <- 120  # number of time points
m <- 12   # seasonal period

level <- numeric(n)
trend <- numeric(n)
season <- numeric(n)
y <- numeric(n)

level[1] <- 10
trend[1] <- 0.5
seasonal_pattern <- sin(2 * pi * (1:m) / m)
season[1:m] <- seasonal_pattern

for (t in 2:n) {
  level[t] <- level[t-1] + trend[t-1] + rnorm(1, 0, 0.3)
  trend[t] <- trend[t-1] + rnorm(1, 0, 0.05)
  season[t] <- season[t %% m + 1]  # repeat seasonal pattern
  y[t] <- level[t] + season[t] + rnorm(1, 0, 1)
}

ts.plot(y, main = "Simulated BSTS Time Series")
```

This synthetic series incorporates a latent trend and periodic seasonal component, making it a suitable candidate for BSTS decomposition.

**Stan Model Code**

We now implement a basic BSTS model in Stan. The model includes a local level, local linear trend, and seasonal component.

```stan
// BSTS with trend and seasonal component

functions {
  vector seasonal_component(vector s, int N, int m) {
    vector[N] seasonal;
    for (t in 1:N) {
      if (t > m)
        seasonal[t] = s[t - m];
      else
        seasonal[t] = s[t];
    }
    return seasonal;
  }
}

data {
  int<lower=1> N;
  int<lower=1> m; // seasonal period
  vector[N] y;
}

parameters {
  real<lower=0> sigma_obs;
  real<lower=0> sigma_level;
  real<lower=0> sigma_trend;
  real<lower=0> sigma_seasonal;

  vector[N] level;
  vector[N] trend;
  vector[N] seasonal;
}

model {
  level[2:N] ~ normal(level[1:(N-1)] + trend[1:(N-1)], sigma_level);
  trend[2:N] ~ normal(trend[1:(N-1)], sigma_trend);
  seasonal[(m+1):N] ~ normal(seasonal[1:(N-m)], sigma_seasonal);

  y ~ normal(level + seasonal_component(seasonal, N, m), sigma_obs);

  // Priors
  sigma_obs ~ normal(0, 1);
  sigma_level ~ normal(0, 0.5);
  sigma_trend ~ normal(0, 0.1);
  sigma_seasonal ~ normal(0, 0.5);
}
```

This Stan code defines a BSTS model with latent states for level, trend, and seasonality. The seasonal component is updated recursively with a periodic lag.

**Fitting the Model in R with RStan**

```r
library(rstan)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

data_list <- list(N = length(y), m = m, y = y)

fit <- stan(model_code = stan_model_bsts, data = data_list,
            chains = 4, iter = 2000, warmup = 1000, seed = 42)

print(fit, pars = c("sigma_obs", "sigma_level", "sigma_trend", "sigma_seasonal"))
```

Posterior summaries provide insights into the scale of observation noise, level drift, trend volatility, and seasonal variability.

**Visualizing Posterior Estimates**

After extracting posterior samples, we can compute posterior means and credible intervals for the latent states:

```r
post <- extract(fit)

level_mean <- apply(post$level, 2, mean)
level_lower <- apply(post$level, 2, quantile, probs = 0.025)
level_upper <- apply(post$level, 2, quantile, probs = 0.975)

library(ggplot2)
df <- data.frame(
  time = 1:n,
  observed = y,
  level = level_mean,
  lower = level_lower,
  upper = level_upper
)

ggplot(df, aes(x = time)) +
  geom_line(aes(y = observed), color = "black", linetype = "dashed") +
  geom_line(aes(y = level), color = "blue") +
  geom_ribbon(aes(ymin = lower, ymax = upper), fill = "blue", alpha = 0.2) +
  labs(title = "Posterior Level Estimates in BSTS",
       x = "Time", y = "Value") +
  theme_minimal()
```

This visualization helps validate the recovery of latent components and highlights the uncertainty in level estimation.

**Applications and Extensions**

BSTS models are particularly useful for handling missing data, structural breaks, and causal impact evaluation. The state-space framework enables incorporating covariates through regression components. An extension includes the spike-and-slab prior on regression coefficients, enabling variable selection. For multiple time series, dynamic linear models with multivariate innovations can be specified.

Stan’s flexible language allows for hierarchical extensions, time-varying regression, and custom seasonal structures. However, modeling long series can be computationally intensive due to the non-Markovian dependence among parameters. Efficient variational inference or marginal likelihood approximations are active areas of development.

**Conclusion**

Bayesian Structural Time Series models provide a powerful and interpretable approach for analyzing complex temporal data. By decomposing a time series into level, trend, and seasonal components, BSTS offers both flexibility and insight. The Bayesian framework further enables coherent uncertainty quantification and prior incorporation. Implementing BSTS in Stan and RStan facilitates full control over model specification, promoting transparent and reproducible inference. As computational tools improve, the use of BSTS models is expected to expand in fields requiring rigorous time series decomposition and forecasting.
