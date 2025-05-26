Certainly. Here's a full blog post in a clear, academic tone, suitable for readers with a strong interest in Bayesian modeling and time series analysis.

---

# **Bayesian AR, ARMA, and ARIMA Models in Stan and RStan**

Bayesian methods for time series modeling have gained widespread appeal for their ability to provide full posterior inference, quantify uncertainty, and incorporate prior knowledge into the analysis of temporal data. In this post, we walk through the foundational Bayesian time series models: the autoregressive (AR), autoregressive moving average (ARMA), and autoregressive integrated moving average (ARIMA) models. Each builds upon the previous, offering increased flexibility for real-world applications.

We implement each model using **Stan**, a powerful probabilistic programming language, and **RStan**, its R interface. Through these examples, we aim to offer a practical understanding of how Bayesian time series models are constructed, estimated, and interpreted.

---

## **Bayesian AR(1) Model**

We begin with the simplest dynamic model: the **AR(1)** process. This model assumes that the current value of the time series depends linearly on its previous value plus a noise term. Formally,

$$
y_t = \alpha + \phi y_{t-1} + \epsilon_t, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
$$

To simulate such a process in R:

```r
set.seed(123)
n <- 100
phi <- 0.7
sigma <- 1
y <- numeric(n)
y[1] <- rnorm(1, 0, sigma / sqrt(1 - phi^2))
for (t in 2:n) {
  y[t] <- phi * y[t - 1] + rnorm(1, 0, sigma)
}
ts.plot(y, main = "Simulated AR(1) Time Series")
```

We fit this model in Stan using the following code:

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

And we call the model in R as follows:

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

---

## **Bayesian ARMA(1,1) Model**

While the AR model captures persistence in the series, it cannot account for short-term shocks that decay quickly. The **ARMA(1,1)** model addresses this by including a moving average component:

$$
y_t = \alpha + \phi y_{t-1} + \epsilon_t + \theta \epsilon_{t-1}, \quad \epsilon_t \sim \mathcal{N}(0, \sigma^2)
$$

To simulate an ARMA(1,1) process in R:

```r
set.seed(123)
n <- 200
phi <- 0.6
theta <- 0.5
sigma <- 1
y <- numeric(n)
e <- rnorm(n, 0, sigma)
y[1] <- e[1]
for (t in 2:n) {
  y[t] <- phi * y[t - 1] + e[t] + theta * e[t - 1]
}
ts.plot(y, main = "Simulated ARMA(1,1) Time Series")
```

The Stan model computes residuals explicitly in a transformed parameters block, as recursion over parameters is not allowed:

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
  mu[1] = alpha;
  eps[1] = y[1] - mu[1];
  for (t in 2:N) {
    mu[t] = alpha + phi * y[t - 1] + theta * eps[t - 1];
    eps[t] = y[t] - mu[t];
  }
}
model {
  eps[2:N] ~ normal(0, sigma);
}
```

Model fitting proceeds in R with:

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

---

## **Bayesian ARIMA(1,1,1) Model**

Many time series exhibit non-stationary behavior, such as trends, that must be differenced away before modeling. The **ARIMA(1,1,1)** model applies a first-order difference to the series and models the differenced data as ARMA(1,1):

$$
\Delta y_t = y_t - y_{t-1} = \alpha + \phi \Delta y_{t-1} + \epsilon_t + \theta \epsilon_{t-1}
$$

We first simulate an ARIMA(1,1,1) process in R:

```r
set.seed(42)
n <- 200
phi <- 0.6
theta <- 0.5
sigma <- 1
eps <- rnorm(n, 0, sigma)
dy <- numeric(n)
dy[1] <- eps[1]
for (t in 2:n) {
  dy[t] <- phi * dy[t - 1] + eps[t] + theta * eps[t - 1]
}
y <- cumsum(dy)
ts.plot(y, main = "Simulated ARIMA(1,1,1) Time Series")
```

The Stan model computes the first difference internally and fits the resulting ARMA process:

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
  mu[1] = alpha;
  eps[1] = dy[1] - mu[1];
  for (t in 2:(N - 1)) {
    mu[t] = alpha + phi * dy[t - 1] + theta * eps[t - 1];
    eps[t] = dy[t] - mu[t];
  }
}
model {
  eps[2:(N - 1)] ~ normal(0, sigma);
}
```

We estimate the model with RStan using:

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

---

## **Conclusion**

Bayesian time series modeling provides a flexible, interpretable framework for analyzing temporal data. Beginning with the autoregressive model, we can successively build toward more complex structures like ARMA and ARIMA. Each model expands our capacity to handle persistence, shocks, and non-stationarity in a principled probabilistic way. While Bayesian inference comes with computational cost, it also brings the benefits of full uncertainty quantification, model extensibility, and coherent predictions under uncertainty.

Using Stan and RStan, we can translate classical time series models into a Bayesian framework and apply them to real-world data with transparency and rigor. Future work may involve extending these models to accommodate seasonality, hierarchical structure, or time-varying parameters.

If you'd like to explore these extensions or need help interpreting your own results, feel free to reach out or comment below.

