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

stan_model <-'data {
  int<lower=1> N;
  vector[N] y;
}
parameters {
  real alpha;
  real<lower=-1, upper=1> phi;
  real<lower=0> sigma;
}
model {
  phi ~ uniform(-1, 1); // or use a more informative prior if desired
  alpha ~ normal(0, 10);
  sigma ~ cauchy(0, 2.5);
  y[2:N] ~ normal(alpha + phi * y[1:N-1], sigma);
}'


library(rstan)
data_list <- list(N = length(y), y = y)

fit <- stan(
  model_code = stan_model,
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000
)
print(fit)

posterior <- extract(fit)
y_rep <- sapply(1:100, function(i) {
  alpha <- posterior$alpha[i]
  phi <- posterior$phi[i]
  sigma <- posterior$sigma[i]
  y_sim <- numeric(n)
  y_sim[1] <- rnorm(1, alpha / (1 - phi), sigma)
  for (t in 2:n) {
    y_sim[t] <- alpha + phi * y_sim[t - 1] + rnorm(1, 0, sigma)
  }
  y_sim
})
matplot(t(y_rep[1:10, ]), type = "l", col = rgb(0, 0, 1, 0.3))
lines(y, col = "black", lwd = 2)












set.seed(123)
n <- 200
phi <- 0.6   # AR coefficient
theta <- 0.5 # MA coefficient
sigma <- 1

y <- numeric(n)
e <- rnorm(n, 0, sigma)

y[1] <- e[1]
for (t in 2:n) {
  y[t] <- phi * y[t - 1] + e[t] + theta * e[t - 1]
}

ts.plot(y, main = "Simulated ARMA(1,1) Time Series")
acf(y, main = "ACF of Simulated ARMA(1,1)")
pacf(y, main = "PACF of Simulated ARMA(1,1)")



stan_model_2 <-'data {
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
  phi ~ uniform(-1, 1);   // Or use more informative priors if appropriate
  theta ~ uniform(-1, 1);
  sigma ~ normal(0, 2);
  alpha ~ normal(0, 10);
  eps[2:N] ~ normal(0, sigma);
}'


library(rstan)
options(mc.cores = parallel::detectCores())

data_list <- list(N = length(y), y = y)

fit <- stan(
  model_code = stan_model_2,
  data = data_list,
  iter = 2000,
  warmup = 1000,
  chains = 4
)

print(fit, pars = c("alpha", "phi", "theta", "sigma"))



posterior <- extract(fit)
n_draws <- 100
y_rep <- matrix(NA, nrow = n_draws, ncol = length(y))

for (i in 1:n_draws) {
  alpha <- posterior$alpha[i]
  phi <- posterior$phi[i]
  theta <- posterior$theta[i]
  sigma <- posterior$sigma[i]
  eps <- rnorm(n, 0, sigma)
  y_sim <- numeric(n)
  y_sim[1] <- alpha + eps[1]
  for (t in 2:n) {
    y_sim[t] <- alpha + phi * y_sim[t - 1] + theta * eps[t - 1] + eps[t]
  }
  y_rep[i, ] <- y_sim
}

matplot(t(y_rep[1:10, ]), type = "l", col = rgb(0, 0, 1, 0.3),
        ylab = "Simulated Y", main = "Posterior Predictive Simulations")
lines(y, col = "black", lwd = 2)









set.seed(42)
n <- 200
phi <- 0.6   # AR(1)
theta <- 0.5 # MA(1)
sigma <- 1

eps <- rnorm(n, 0, sigma)
y <- numeric(n)
dy <- numeric(n)  # Differenced series

dy[1] <- eps[1]
for (t in 2:n) {
  dy[t] <- phi * dy[t - 1] + eps[t] + theta * eps[t - 1]
}

# Integrate to get ARIMA
y <- cumsum(dy)

ts.plot(y, main = "Simulated ARIMA(1,1,1) Time Series")
ts.plot(dy, main = "Simulated ARIMA(1,1,1) Time Series")

acf(y, main = "ACF of Simulated ARMA(1,1)")
pacf(y, main = "PACF of Simulated ARMA(1,1)")


acf(dy, main = "ACF of Simulated ARMA(1,1)")
pacf(dy, main = "PACF of Simulated ARMA(1,1)")










stan_model_3 <-'data {
  int<lower=2> N;
  vector[N] y;  // Original (non-differenced) series
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
  phi ~ uniform(-1, 1);   // Or use more informative priors if appropriate
  theta ~ uniform(-1, 1);
  sigma ~ normal(0, 2);
  alpha ~ normal(0, 10);
  eps[2:(N - 1)] ~ normal(0, sigma);
}'


library(rstan)

data_list <- list(N = length(y), y = y)

fit <- stan(
  model_code = stan_model_3,
  data = data_list,
  chains = 4,
  iter = 2000,
  warmup = 1000
)

print(fit, pars = c("alpha", "phi", "theta", "sigma"))


posterior <- extract(fit)
n_draws <- 50
y_rep <- matrix(NA, nrow = n_draws, ncol = length(y))

for (i in 1:n_draws) {
  alpha <- posterior$alpha[i]
  phi <- posterior$phi[i]
  theta <- posterior$theta[i]
  sigma <- posterior$sigma[i]
  
  eps <- rnorm(n, 0, sigma)
  dy_sim <- numeric(n)
  dy_sim[1] <- alpha + eps[1]
  for (t in 2:n) {
    dy_sim[t] <- alpha + phi * dy_sim[t - 1] + theta * eps[t - 1] + eps[t]
  }
  
  y_rep[i, ] <- cumsum(dy_sim)
}

matplot(t(y_rep[1:10, ]), type = "l", col = rgb(0, 0, 1, 0.3),
        ylab = "Simulated Y", main = "Posterior Predictive Simulations")
lines(y, col = "black", lwd = 2)
