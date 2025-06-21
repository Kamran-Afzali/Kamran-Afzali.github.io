set.seed(1)
n <- 100
alpha <- 0.3
sigma <- 1
l <- numeric(n)
y <- numeric(n)
l[1] <- 10
y[1] <- l[1] + rnorm(1, 0, sigma)
for (t in 2:n) {
  l[t] <- alpha * y[t - 1] + (1 - alpha) * l[t - 1]
  y[t] <- l[t] + rnorm(1, 0, sigma)
}
ts.plot(y, main = "Simulated SES Time Series")



stan_model_1='data {
  int<lower=2> N;
  vector[N] y;
}
parameters {
  real<lower=0, upper=1> alpha;
  real<lower=0> sigma;
  vector[N] l;  // local level
}
model {
  l[1] ~ normal(y[1], sigma);
  for (t in 2:N)
    l[t] ~ normal(alpha * y[t-1] + (1 - alpha) * l[t-1], sigma);
  y ~ normal(l, sigma);
}'


library(rstan)
data_list <- list(N = length(y), y = y)
fit <- stan(model_code = stan_model_1, data = data_list,
            chains = 4, iter = 2000, warmup = 1000)
print(fit, pars = c("alpha", "sigma"))

post <- rstan::extract(fit)

# Get posterior means of the latent level 'l'
l_hat_mean <- apply(post$l, 2, mean)  # Mean across samples for each time step

# Optional: Get 95% credible intervals for the latent levels
l_ci_lower <- apply(post$l, 2, quantile, probs = 0.025)
l_ci_upper <- apply(post$l, 2, quantile, probs = 0.975)


library(ggplot2)
df <- data.frame(
  time = 1:n,
  observed = y,
  true_level = l,
  posterior_mean = l_hat_mean,
  lower_95 = l_ci_lower,
  upper_95 = l_ci_upper
)

ggplot(df, aes(x = time)) +
  geom_line(aes(y = observed), color = "black", size = 0.6, linetype = "dashed") +
  geom_line(aes(y = true_level), color = "blue", size = 0.8, alpha = 0.5) +
  geom_line(aes(y = posterior_mean), color = "red", size = 0.9) +
  geom_ribbon(aes(ymin = lower_95, ymax = upper_95), fill = "red", alpha = 0.2) +
  labs(title = "Bayesian SES: Posterior Level Estimates vs True Level",
       y = "Value", x = "Time") +
  theme_minimal() +
  theme(legend.position = "none")










set.seed(2)
n <- 100
alpha <- 0.3
beta <- 0.1
sigma <- 1
l <- numeric(n)
b <- numeric(n)
y <- numeric(n)
l[1] <- 5
b[1] <- 0.5
y[1] <- l[1] + b[1] + rnorm(1, 0, sigma)
for (t in 2:n) {
  l[t] <- alpha * y[t - 1] + (1 - alpha) * (l[t - 1] + b[t - 1])
  b[t] <- beta * (l[t] - l[t - 1]) + (1 - beta) * b[t - 1]
  y[t] <- l[t] + b[t] + rnorm(1, 0, sigma)
}
ts.plot(y, main = "Simulated Holt-Winters Time Series")



stan_model_2='data {
  int<lower=2> N;
  vector[N] y;
}
parameters {
  real<lower=0, upper=1> alpha;
  real<lower=0, upper=1> beta;
  real<lower=0> sigma;
  vector[N] l;
  vector[N] b;
}
model {
  l[1] ~ normal(y[1], sigma);
  b[1] ~ normal(0, sigma);
  for (t in 2:N) {
    l[t] ~ normal(alpha * y[t-1] + (1 - alpha) * (l[t-1] + b[t-1]), sigma);
    b[t] ~ normal(beta * (l[t] - l[t-1]) + (1 - beta) * b[t-1], sigma);
  }
  y ~ normal(l + b, sigma);
}'


data_list <- list(N = length(y), y = y)
fit <- stan(model_code = stan_model_2, data = data_list,
            chains = 4, iter = 2000, warmup = 1000)
print(fit, pars = c("alpha", "beta", "sigma"))


# Extract posteriors from the fitted Stan model
post <- rstan::extract(fit)

# Get posterior means of the latent level 'l' and trend 'b'
l_hat_mean <- apply(post$l, 2, mean)  # level
b_hat_mean <- apply(post$b, 2, mean)  # trend

# Optional: 95% credible intervals
l_ci_lower <- apply(post$l, 2, quantile, probs = 0.025)
l_ci_upper <- apply(post$l, 2, quantile, probs = 0.975)

b_ci_lower <- apply(post$b, 2, quantile, probs = 0.025)
b_ci_upper <- apply(post$b, 2, quantile, probs = 0.975)

# Posterior predictive forecast (level + trend)
y_hat_mean <- l_hat_mean + b_hat_mean

# Build data frame for plotting
df <- data.frame(
  time = 1:n,
  observed = y,
  true_level = l,
  true_trend = b,
  predicted = y_hat_mean,
  level_mean = l_hat_mean,
  level_lower = l_ci_lower,
  level_upper = l_ci_upper
)





library(ggplot2)

ggplot(df, aes(x = time)) +
  geom_line(aes(y = observed), color = "black", size = 0.6, linetype = "dashed") +
  geom_line(aes(y = true_level), color = "blue", size = 0.8, alpha = 0.5) +
  geom_line(aes(y = predicted), color = "red", size = 1) +
  geom_ribbon(aes(ymin = level_lower, ymax = level_upper), fill = "red", alpha = 0.2) +
  labs(title = "Bayesian Holt-Winters: Posterior Level & Trend Estimates",
       y = "Value", x = "Time") +
  theme_minimal()










set.seed(3)
n <- 120
m <- 12  # seasonal period (e.g., months in a year)
alpha <- 0.3
beta <- 0.1
gamma <- 0.2
sigma <- 1

l <- numeric(n)
b <- numeric(n)
s <- numeric(n)
y <- numeric(n)

# Initialize components
l[1] <- 10
b[1] <- 0.5
s[1:m] <- sin(2 * pi * (1:m) / m)  # true seasonal pattern
plot(s)
# Generate data
y[1] <- l[1] + b[1] + s[1] + rnorm(1, 0, sigma)
for (t in 2:n) {
  if (t > m) {
    l[t] <- alpha * (y[t - 1] - s[t - m]) + (1 - alpha) * (l[t - 1] + b[t - 1])
    b[t] <- beta * (l[t] - l[t - 1]) + (1 - beta) * b[t - 1]
    s[t] <- gamma * (y[t - 1] - l[t - 1] - b[t - 1]) + (1 - gamma) * s[t - m]
  } else {
    l[t] <- l[t - 1]
    b[t] <- b[t - 1]
    s[t] <- s[t - 1]
  }
  y[t] <- l[t] + b[t] + s[t %% m + 1] + rnorm(1, 0, sigma)
}
ts.plot(y, main = "Simulated Seasonal Holt-Winters Time Series")



stan_model_3='data {
  int<lower=2> N;         // number of observations
  int<lower=1> m;         // seasonal period
  vector[N] y;
}
parameters {
  real<lower=0, upper=1> alpha;
  real<lower=0, upper=1> beta;
  real<lower=0, upper=1> gamma;
  real<lower=0> sigma;
  
  vector[N] l;            // level
  vector[N] b;            // trend
  vector[N] s;            // seasonal
}
model {
  l[1] ~ normal(y[1], sigma);
  b[1] ~ normal(0, sigma);
  for (i in 1:m)
    s[i] ~ normal(0, 1);
  
  for (t in 2:N) {
    if (t > m) {
      l[t] ~ normal(alpha * (y[t - 1] - s[t - m]) + (1 - alpha) * (l[t - 1] + b[t - 1]), sigma);
      b[t] ~ normal(beta * (l[t] - l[t - 1]) + (1 - beta) * b[t - 1], sigma);
      s[t] ~ normal(gamma * (y[t - 1] - l[t - 1] - b[t - 1]) + (1 - gamma) * s[t - m], sigma);
    } else {
      l[t] ~ normal(l[t - 1], 1);
      b[t] ~ normal(b[t - 1], 1);
      s[t] ~ normal(s[t - 1], 1);
    }
  }
  
  for (t in 1:N) {
    if (t > m)
      y[t] ~ normal(l[t] + b[t] + s[t - m], sigma);
    else
      y[t] ~ normal(l[t] + b[t] + s[t], sigma);
  }
}'


library(rstan)

data_list <- list(N = length(y), y = y, m = m)
fit <- stan(model_code = stan_model_3, data = data_list,
            chains = 4, iter = 2000, warmup = 1000)

print(fit, pars = c("alpha", "beta", "gamma", "sigma"))

post <- rstan::extract(fit)

l_hat <- apply(post$l, 2, mean)
l_ci_lower <- apply(post$l, 2, quantile, probs = 0.025)
l_ci_upper <- apply(post$l, 2, quantile, probs = 0.975)

df <- data.frame(
  time = 1:n,
  observed = y,
  level_mean = l_hat,
  level_lower = l_ci_lower,
  level_upper = l_ci_upper
)

library(ggplot2)
ggplot(df, aes(x = time)) +
  geom_line(aes(y = observed), color = "black", linetype = "dashed") +
  geom_line(aes(y = level_mean), color = "red") +
  geom_ribbon(aes(ymin = level_lower, ymax = level_upper), fill = "red", alpha = 0.2) +
  labs(title = "Bayesian Seasonal Holt-Winters: Posterior Level Estimates",
       x = "Time", y = "Value") +
  theme_minimal()
