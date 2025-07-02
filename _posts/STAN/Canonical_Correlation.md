
# Bayesian Canonical Correlation Analysis in Stan

## Introduction
Canonical Correlation Analysis (CCA) is a multivariate statistical method that identifies and quantifies the relationships between two sets of variables by finding linear combinations (canonical variates) that maximize their correlation. Unlike standard correlation analysis, which examines relationships between individual variables, CCA explores the joint structure of two variable sets, such as psychological test scores and academic performance metrics. In a Bayesian framework, CCA incorporates priors on the canonical coefficients, allowing for uncertainty quantification and regularization, which can improve estimation in small or noisy datasets. In this post, we will implement a Bayesian CCA model in Stan, focusing on estimating canonical coefficients and their correlations, and compare it to frequentist CCA. We will use synthetic data to illustrate the approach and highlight the benefits of Bayesian inference, such as full posterior distributions for uncertainty quantification.

### Canonical Correlation Analysis
CCA seeks pairs of linear combinations (canonical variates) from two sets of variables, \(X\) (with \(p\) variables) and \(Y\) (with \(q\) variables), such that the correlation between the variates is maximized. Mathematically, for variables \(X\) and \(Y\), CCA finds vectors \(a_i\) and \(b_i\) such that the canonical variates \(U_i = X a_i\) and \(V_i = Y b_i\) have maximum correlation, subject to the constraints that the variates are uncorrelated with previous pairs and have unit variance. In a Bayesian framework, we place priors on the canonical coefficients (\(a_i\), \(b_i\)) and model the joint distribution of \(X\) and \(Y\), allowing for flexible regularization and uncertainty estimation.

In the Bayesian CCA model, we assume that the observed variables \(X\) and \(Y\) are generated from latent canonical variates with a shared structure. We place normal priors on the canonical coefficients and use a multivariate normal likelihood to model the joint distribution of \(X\) and \(Y\). The model estimates the canonical coefficients and their correlations, with hyperpriors to regularize the variance parameters.

We start by generating synthetic data to demonstrate the Bayesian CCA model.

```R
library(tidyverse)

set.seed(123)
n <- 1000  # number of observations
p <- 3     # number of X variables
q <- 2     # number of Y variables
# Latent canonical variates
u <- rnorm(n, 0, 1)
v <- 0.8 * u + rnorm(n, 0, sqrt(1 - 0.8^2))  # Correlated with u
# Generate X and Y
X <- matrix(rnorm(n * p, mean = u, sd = 1), nrow = n, ncol = p)
Y <- matrix(rnorm(n * q, mean = v, sd = 1), nrow = n, ncol = q)
data <- data.frame(X = X, Y = Y)
head(data)

set.seed(42)
data_split <- initial_split(data, prop = 0.7)
train_data <- training(data_split)
test_data <- testing(data_split)
```

### Stan Model
Below is the Stan code for a Bayesian CCA model, which estimates the canonical coefficients for one pair of canonical variates.

```stan
data {
  int<lower=0> N;               // number of observations
  int<lower=0> p;               // number of X variables
  int<lower=0> q;               // number of Y variables
  matrix[N, p] X;               // X variables
  matrix[N, q] Y;               // Y variables
}
parameters {
  vector[p] a;                  // canonical coefficients for X
  vector[q] b;                  // canonical coefficients for Y
  real<lower=0> sigma_x;        // residual SD for X
  real<lower=0> sigma_y;        // residual SD for Y
  real<lower=-1, upper=1> rho;  // canonical correlation
}
transformed parameters {
  vector[N] u = X * a;          // canonical variate for X
  vector[N] v = Y * b;          // canonical variate for Y
}
model {
  // Priors
  a ~ normal(0, 1);             // prior for X coefficients
  b ~ normal(0, 1);             // prior for Y coefficients
  sigma_x ~ cauchy(0, 2);       // hyperprior for X residual SD
  sigma_y ~ cauchy(0, 2);       // hyperprior for Y residual SD
  rho ~ uniform(-1, 1);         // prior for canonical correlation

  // Likelihood
  for (n in 1:N) {
    u[n] ~ normal(0, 1);        // standardized canonical variate
    v[n] ~ normal(rho * u[n], sqrt(1 - rho^2));  // correlated with u
    X[n] ~ normal(u[n], sigma_x);  // X variables
    Y[n] ~ normal(v[n], sigma_y);  // Y variables
  }
}
generated quantities {
  vector[N] u_pred;             // predicted canonical variate for X
  vector[N] v_pred;             // predicted canonical variate for Y
  for (n in 1:N) {
    u_pred[n] = normal_rng(0, 1);
    v_pred[n] = normal_rng(rho * u_pred[n], sqrt(1 - rho^2));
  }
}
```

Save the Stan model to a file:

```R
writeLines(stan_mod_cca, con = "cca.stan")
```

#### Fitting the Model
Prepare the data and fit the model using `rstan`.

```R
stan_data <- list(
  N = nrow(train_data),
  p = ncol(train_data$X),
  q = ncol(train_data$Y),
  X = train_data$X,
  Y = train_data$Y
)

library(rstan)
fit_cca <- rstan::stan(
  file = "cca.stan",
  data = stan_data,
  iter = 2000,
  chains = 4
)
```
## Conclusion
In this post, we explored Bayesian Canonical Correlation Analysis, a method to uncover relationships between two sets of variables through maximally correlated linear combinations. By implementing a Bayesian CCA model in Stan, we demonstrated how priors on canonical coefficients and hyperpriors on variance parameters enable robust estimation and uncertainty quantification. Compared to frequentist CCA, the Bayesian approach provides full posterior distributions, eliminating the need for bootstrapping to estimate uncertainty. This makes it particularly useful for small or noisy datasets. The Stan implementation allows for flexible extensions, such as modeling multiple canonical pairs or incorporating hierarchical structures.

## References
- Stan User’s Guide on Multivariate Models
- Gelman, A., & Hill, J. (2006). *Data Analysis Using Regression and Multilevel/Hierarchical Models*
- Krzanowski, W. J. (2000). *Principles of Multivariate Analysis*

