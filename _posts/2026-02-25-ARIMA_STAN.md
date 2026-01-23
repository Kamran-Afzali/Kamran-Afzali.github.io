
# **Bayesian AR, ARMA, and ARIMA Models in Stan and RStan**

Bayesian methods for time series modeling offer something frequentist approaches struggle with: full posterior inference that lets us quantify uncertainty and weave prior knowledge directly into our analysis. This is the first post in our series on Bayesian time series analysis, where we'll work through three foundational models—autoregressive (AR), autoregressive moving average (ARMA), and autoregressive integrated moving average (ARIMA). Each model builds on the previous one, though the jump in complexity isn't always straightforward. We'll implement everything using **Stan** and **RStan**, which gives us an R interface. The goal here isn't just to show you code that runs, but to walk through how these models are actually constructed and what the Stan syntax is doing under the hood. 

## **Bayesian AR(1) Model**

The simplest place to start is the **AR(1)** process. The idea is that today's value depends linearly on yesterday's value, plus some random noise. We can write this as:

\[
y_t = \alpha + \phi y_{t-1} + \epsilon_t, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
\]

Here, \(\alpha\) represents a constant drift term, \(\phi\) controls how much yesterday's value influences today (often called the autocorrelation parameter), and \(\epsilon_t\) is our white noise. When \(|\phi| < 1\), the process is stationary, meaning it won't wander off to infinity. If \(\phi\) gets too close to 1, though, the series develops a long memory and small shocks persist for a long time.

Let's simulate an AR(1) process in R to see what this looks like:

```r
set.seed(123)
n <- 100
phi <- 0.7
sigma <- 1
y <- numeric(n)
y [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) <- rnorm(1, 0, sigma / sqrt(1 - phi^2))
for (t in 2:n) {
  y[t] <- phi * y[t - 1] + rnorm(1, 0, sigma)
}
ts.plot(y, main = "Simulated AR(1) Time Series")
```

Notice that we initialize `y` using the stationary distribution of the AR(1) process. This isn't strictly necessary for simulation, but it helps avoid transient startup effects. The denominator `sqrt(1 - phi^2)` comes from the variance of a stationary AR(1), which you can derive by taking variances on both sides of the model equation. Now for the Stan model. Stan's syntax may look unfamiliar if you're coming from BUGS or JAGS, but it's designed to be more explicit about data types and constraints:

```stan
data {
  int<lower=1> N;
  vector[N] y;
}
parameters {
  real alpha;
  real<lower=-1, upper=1> phi;
  real<lower=0> sigma;
}
model {
  y[2:N] ~ normal(alpha + phi * y[1:N-1], sigma);
}
```

The `data` block declares what we're passing in from R. The `parameters` block defines what Stan will sample: `alpha` can be any real number, `phi` is constrained between -1 and 1 to ensure stationarity, and `sigma` must be positive. The `model` block specifies the likelihood. Stan uses vectorized notation here—`y[2:N]` represents all observations from time 2 onward, and `y[1:N-1]` is the lagged series. 

One thing to note: we're not explicitly setting priors for `alpha`, `phi`, or `sigma`. Stan uses improper flat priors by default, which is fine for simple models but can cause problems with more complex hierarchical structures. 

We fit the model in R like this:

```r
library(rstan)
data_list <- list(N = length(y), y = y)
fit <- stan(
  file = "ar1_model.stan",
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000
)
print(fit)
```

This runs four parallel chains, each with 2000 iterations (1000 for warmup, which Stan discards). The warmup phase tunes the sampler's step size and mass matrix—think of it as the sampler learning the geometry of the posterior. [guillaume.baudart](https://guillaume.baudart.eu/papers/pldi21.pdf)

## **Bayesian ARMA(1,1) Model**

The AR(1) model captures persistence, but it assumes shocks decay exponentially at a fixed rate. Real data often shows more complex behavior. Some shocks die out quickly, while the series still has long-term memory. The **ARMA(1,1)** model adds a moving average term to handle this:

\[
y_t = \alpha + \phi y_{t-1} + \epsilon_t + \theta \epsilon_{t-1}, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
\]

The new parameter \(\theta\) controls how much yesterday's forecast error affects today's value. This gives the model more flexibility in shaping the autocorrelation function. When \(\phi\) and \(\theta\) have opposite signs, you can get patterns that pure AR models can't replicate. [bayesiancomputationbook](https://bayesiancomputationbook.com/markdown/chp_06.html)

Simulating this in R requires us to track the error terms explicitly:

```r
set.seed(123)
n <- 200
phi <- 0.6
theta <- 0.5
sigma <- 1
y <- numeric(n)
e <- rnorm(n, 0, sigma)
y [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) <- e [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html)
for (t in 2:n) {
  y[t] <- phi * y[t - 1] + e[t] + theta * e[t - 1]
}
ts.plot(y, main = "Simulated ARMA(1,1) Time Series")
```

Here's where things get tricky with Stan. We can't directly write a recursion over parameters (like `eps[t] = y[t] - mu[t]`) inside the `model` block because Stan's automatic differentiation system needs to know the full dependency graph upfront. Instead, we compute the residuals in a `transformed parameters` block: [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html)

```stan
data {
  int<lower=2> N;
  vector[N] y;
}
parameters {
  real alpha;
  real<lower=-1, upper=1> phi;
  real<lower=-1, upper=1> theta;
  real<lower=0> sigma;
}
transformed parameters {
  vector[N] mu;
  vector[N] eps;
  mu [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) = alpha;
  eps [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) = y [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) - mu [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html);
  for (t in 2:N) {
    mu[t] = alpha + phi * y[t - 1] + theta * eps[t - 1];
    eps[t] = y[t] - mu[t];
  }
}
model {
  eps[2:N] ~ normal(0, sigma);
}
```

The `transformed parameters` block lets us compute derived quantities that depend on parameters, and these quantities are saved in the posterior samples. The loop explicitly builds up the conditional mean `mu[t]` and residuals `eps[t]` at each time step. We then model `eps[2:N]` as normal with mean zero and standard deviation `sigma`. We skip `eps [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html)` because its distribution depends on initial conditions, which we're treating as fixed here. 

Fitting this model works the same way:

```r
data_list <- list(N = length(y), y = y)
fit <- stan(
  file = "arma11.stan",
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000
)
print(fit, pars = c("alpha", "phi", "theta", "sigma"))
```

You might notice the model runs slower than AR(1). That's because the loop in `transformed parameters` can't be vectorized, and Stan has to evaluate it at every iteration. For longer series, this becomes a bottleneck.

## **Bayesian ARIMA(1,1,1) Model**

Many real-world time series aren't stationary. Stock prices, GDP, temperature records—they all tend to wander. If you try to fit an ARMA model to trending data, you'll get nonsensical parameter estimates because the model assumes the mean is constant. The **ARIMA** framework addresses this by differencing the series first. 

In an ARIMA(1,1,1) model, the middle "1" means we take one difference: \(\Delta y_t = y_t - y_{t-1}\). We then fit an ARMA(1,1) to the differenced series:

\[
\Delta y_t = \alpha + \phi \Delta y_{t-1} + \epsilon_t + \theta \epsilon_{t-1}
\]

This removes linear trends (and sometimes more complex nonstationarity, depending on what's driving the trend). After differencing, the series may appear stationary, which satisfies the ARMA assumptions.

Let's simulate an ARIMA(1,1,1) process. We generate the differenced series `dy`, then integrate it by taking the cumulative sum:

```r
set.seed(42)
n <- 200
phi <- 0.6
theta <- 0.5
sigma <- 1
eps <- rnorm(n, 0, sigma)
dy <- numeric(n)
dy [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html) <- eps [mc-stan](https://mc-stan.org/docs/stan-users-guide/time-series.html)
for (t in 2:n) {
  dy[t] <- phi * dy[t - 1] + eps[t] + theta * eps[t - 1]
}
y <- cumsum(dy)
ts.plot(y, main = "Simulated ARIMA(1,1,1) Time Series")
```

The resulting plot should show something that looks like it's wandering around—this is the integrated part of ARIMA at work.

In Stan, we handle differencing in a `transformed data` block, which runs once before sampling starts. This is efficient because differencing doesn't depend on parameters:

```stan
data {
  int<lower=2> N;
  vector[N] y;
}
transformed data {
  vector[N - 1] dy;
  for (t in 2:N) dy[t - 1] = y[t] - y[t - 1];
}
parameters {
  real alpha;
  real<lower=-1, upper=1> phi;
  real<lower=-1, upper=1> theta;
  real<lower=0> sigma;
}
transformed parameters {
  vector[N - 1] mu;
  vector[N - 1] eps;
  mu  = alpha;
  eps = dy - mu ;
  for (t in 2:(N - 1)) {
    mu[t] = alpha + phi * dy[t - 1] + theta * eps[t - 1];
    eps[t] = dy[t] - mu[t];
  }
}
model {
  eps[2:(N - 1)] ~ normal(0, sigma);
}
```

The `transformed data` block creates `dy`, a differenced version of `y` with length `N - 1`. Everything else looks similar to the ARMA(1,1) model, except now we're working with the differenced series. 

Fitting the model in RStan:

```r
data_list <- list(N = length(y), y = y)
fit <- stan(
  file = "arima11.stan",
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000
)
print(fit, pars = c("alpha", "phi", "theta", "sigma"))
```

One subtle point: the parameter `alpha` in this model represents the mean of the differenced series, not the original series. If `alpha` is positive, it implies a linear upward trend in the original data. Interpreting parameters after differencing takes a bit of care.

## **Conclusion**

These three models—AR, ARMA, and ARIMA—form the backbone of classical time series analysis, and their Bayesian versions inherit both the strengths and quirks of their frequentist counterparts. The advantage of going Bayesian is that we get full uncertainty quantification without relying on asymptotic approximations. We can also extend these models more naturally: adding hierarchical structure, incorporating external predictors, or letting parameters vary over time all fit comfortably within the Bayesian framework. 

That said, Bayesian inference isn't free. These models can be slow, especially for long time series or when loops can't be vectorized. ARMA and ARIMA models also assume certain invertibility and stationarity conditions, which aren't always guaranteed just because we put bounds on parameters. And while Stan's HMC sampler is generally more efficient than Gibbs sampling, it can still struggle with highly correlated posteriors or poorly identified parameters. 

Future extensions might involve seasonal ARIMA models (SARIMA), state space formulations that handle missing data more gracefully, or time-varying parameter models that relax the assumption of constant \(\phi\) and \(\theta\). The framework we've built here should give you a foundation for exploring those directions. 

## **References**

- [mc-stan time series](https://mc-stan.org/docs/stan-users-guide/time-series.html)
- [minimizeregret time series](https://minimizeregret.com/short-time-series-prior-knowledge)
- [bayesiancomputationbook](https://bayesiancomputationbook.com/markdown/chp_06.html)
- [guillaume.baudart](https://guillaume.baudart.eu/papers/pldi21.pdf)
- [cran.r-project](https://cran.r-project.org/web/packages/bayesforecast/bayesforecast.pdf)

