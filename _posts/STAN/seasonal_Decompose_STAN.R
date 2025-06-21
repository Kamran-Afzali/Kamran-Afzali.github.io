set.seed(123)
n <- 120
t <- 1:n
trend <- 0.05 * t
seasonal_period <- 12
seasonal <- rep(sin(2 * pi * (1:seasonal_period) / seasonal_period), length.out = n)
noise <- rnorm(n, 0, 0.5)
y <- trend + seasonal + noise

ts.plot(y, main = "Simulated Time Series with Trend and Seasonality")



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

posterior <- extract(fit)
mu_hat <- apply(posterior$mu, 2, mean)
season_hat <- apply(posterior$season, 2, mean)

par(mfrow = c(3, 1), mar = c(4, 4, 2, 1))
plot(y, type = 'l', main = "Observed Time Series", ylab = "y")
plot(mu_hat, type = 'l', col = "blue", main = "Estimated Trend (mu)", ylab = "mu_t")
plot(season_hat, type = 'l', col = "darkgreen", main = "Estimated Seasonal Component", ylab = "season_t")
