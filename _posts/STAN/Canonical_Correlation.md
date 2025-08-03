
# Bayesian Canonical Correlation Analysis in Stan

## Introduction
Canonical Correlation Analysis (CCA) is a multivariate statistical method that identifies and quantifies the relationships between two sets of variables by finding linear combinations (canonical variates) that maximize their correlation. Unlike standard correlation analysis, which examines relationships between individual variables, CCA explores the joint structure of two variable sets, such as psychological test scores and academic performance metrics. In a Bayesian framework, CCA incorporates priors on the canonical coefficients, allowing for uncertainty quantification and regularization, which can improve estimation in small or noisy datasets. In this post, we will implement a Bayesian CCA model in Stan, focusing on estimating canonical coefficients and their correlations, and compare it to frequentist CCA. We will use synthetic data to illustrate the approach and highlight the benefits of Bayesian inference, such as full posterior distributions for uncertainty quantification.

### Canonical Correlation Analysis
CCA seeks pairs of linear combinations (canonical variates) from two sets of variables, \(X\) (with \(p\) variables) and \(Y\) (with \(q\) variables), such that the correlation between the variates is maximized. Mathematically, for variables \(X\) and \(Y\), CCA finds vectors \(a_i\) and \(b_i\) such that the canonical variates \(U_i = X a_i\) and \(V_i = Y b_i\) have maximum correlation, subject to the constraints that the variates are uncorrelated with previous pairs and have unit variance. In a Bayesian framework, we place priors on the canonical coefficients (\(a_i\), \(b_i\)) and model the joint distribution of \(X\) and \(Y\), allowing for flexible regularization and uncertainty estimation.

In the Bayesian CCA model, we assume that the observed variables \(X\) and \(Y\) are generated from latent canonical variates with a shared structure. We place normal priors on the canonical coefficients and use a multivariate normal likelihood to model the joint distribution of \(X\) and \(Y\). The model estimates the canonical coefficients and their correlations, with hyperpriors to regularize the variance parameters.

We start by generating synthetic data to demonstrate the Bayesian CCA model.

```R
# Improved Bayesian Canonical Correlation Analysis
# Load required libraries
library(tidyverse)
library(rstan)
library(rsample)
library(bayesplot)
library(ggplot2)

# Set Stan options for better performance
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Data Generation with more realistic structure
set.seed(123)
n <- 1000  # number of observations
p <- 4     # number of X variables (increased for more complexity)
q <- 3     # number of Y variables (increased for more complexity)

# Generate multiple latent canonical variates for richer structure
u1 <- rnorm(n, 0, 1)
u2 <- rnorm(n, 0, 0.5)  # Secondary canonical variate

# Create correlated canonical variates for Y
v1 <- 0.8 * u1 + rnorm(n, 0, sqrt(1 - 0.8^2))  # Strong correlation
v2 <- 0.5 * u2 + rnorm(n, 0, sqrt(1 - 0.5^2))  # Moderate correlation

# Generate X variables with varying loadings on canonical variates
X1 <- 0.9 * u1 + 0.3 * u2 + rnorm(n, 0, 0.5)
X2 <- 0.7 * u1 + 0.5 * u2 + rnorm(n, 0, 0.6)
X3 <- 0.5 * u1 + 0.8 * u2 + rnorm(n, 0, 0.4)
X4 <- 0.3 * u1 + 0.2 * u2 + rnorm(n, 0, 0.8)

# Generate Y variables with varying loadings
Y1 <- 0.8 * v1 + 0.2 * v2 + rnorm(n, 0, 0.4)
Y2 <- 0.6 * v1 + 0.7 * v2 + rnorm(n, 0, 0.5)
Y3 <- 0.4 * v1 + 0.9 * v2 + rnorm(n, 0, 0.3)

# Create properly structured data frame
X_matrix <- cbind(X1, X2, X3, X4)
Y_matrix <- cbind(Y1, Y2, Y3)

data <- data.frame(
  X_matrix,
  Y_matrix
)

# Rename columns for clarity
colnames(data) <- c(paste0("X", 1:p), paste0("Y", 1:q))

cat("Data structure:\n")
str(data)
cat("\nFirst few rows:\n")
head(data)

# Data splitting
set.seed(42)
data_split <- initial_split(data, prop = 0.7)
train_data <- training(data_split)
test_data <- testing(data_split)

# Extract X and Y matrices correctly
X_train <- as.matrix(train_data[, 1:p])
Y_train <- as.matrix(train_data[, (p+1):(p+q)])

X_test <- as.matrix(test_data[, 1:p])
Y_test <- as.matrix(test_data[, (p+1):(p+q)])
```

### Stan Model
Below is the Stan code for a Bayesian CCA model, which estimates the canonical coefficients for one pair of canonical variates.

```stan
stan_model <- "
data {
  int<lower=0> N;               // number of observations
  int<lower=0> p;               // number of X variables
  int<lower=0> q;               // number of Y variables
  matrix[N, p] X;               // X variables (standardized)
  matrix[N, q] Y;               // Y variables (standardized)
}

parameters {
  vector[p] a;                  // canonical coefficients for X
  vector[q] b;                  // canonical coefficients for Y
  real<lower=0> sigma_u;        // SD for canonical variate u
  real<lower=0> sigma_v;        // SD for canonical variate v
  real<lower=-1, upper=1> rho;  // canonical correlation
  
  // Hierarchical priors for better regularization
  real<lower=0> tau_a;          // hierarchical scale for a
  real<lower=0> tau_b;          // hierarchical scale for b
}

transformed parameters {
  vector[N] u;                  // canonical variate for X
  vector[N] v;                  // canonical variate for Y
  
  // Compute canonical variates
  u = X * a;
  v = Y * b;
  
  // Standardize canonical variates for identifiability
  real u_mean = mean(u);
  real v_mean = mean(v);
  real u_sd = sd(u);
  real v_sd = sd(v);
}

model {
  // Hierarchical priors
  tau_a ~ cauchy(0, 1);
  tau_b ~ cauchy(0, 1);
  
  // Priors for canonical coefficients with hierarchical regularization
  a ~ normal(0, tau_a);
  b ~ normal(0, tau_b);
  
  // Priors for variance parameters
  sigma_u ~ cauchy(0, 1);
  sigma_v ~ cauchy(0, 1);
  
  // Prior for canonical correlation
  rho ~ beta(2, 2);  // Slightly informative prior favoring moderate correlations
  
  // Likelihood for canonical variates
  u ~ normal(0, sigma_u);
  v ~ normal(rho * u, sigma_v * sqrt(1 - rho^2));
  
  // Constraint for identifiability (optional - can help with convergence)
  target += -0.5 * dot_self(a) - 0.5 * dot_self(b);
}

generated quantities {
  // Posterior predictions
  vector[N] u_pred;
  vector[N] v_pred;
  matrix[N, p] X_pred;
  matrix[N, q] Y_pred;
  
  // Log likelihood for model comparison
  real log_lik = 0;
  
  // Generate predictions
  for (n in 1:N) {
    u_pred[n] = normal_rng(0, sigma_u);
    v_pred[n] = normal_rng(rho * u_pred[n], sigma_v * sqrt(1 - rho^2));
  }
  
  // Predicted X and Y based on canonical variates
  X_pred = rep_matrix(u_pred, p);
  Y_pred = rep_matrix(v_pred, q);
  
  // Calculate log likelihood
  for (n in 1:N) {
    log_lik += normal_lpdf(u[n] | 0, sigma_u);
    log_lik += normal_lpdf(v[n] | rho * u[n], sigma_v * sqrt(1 - rho^2));
  }
}
"
```
This Stan model implements Bayesian Canonical Correlation Analysis by first defining the data structure with `N` observations, `p` X variables, and `q` Y variables stored in matrices `X` and `Y`. The parameters section declares the key unknowns: canonical coefficient vectors `a` and `b` that will create linear combinations of the original variables, standard deviations `sigma_u` and `sigma_v` for the canonical variates, the canonical correlation `rho` (constrained between -1 and 1), and hierarchical regularization parameters `tau_a` and `tau_b`. In the transformed parameters block, the model computes the canonical variates `u = X * a` and `v = Y * b`, which are the linear combinations that maximize correlation between the two sets of variables, along with their means and standard deviations for standardization purposes.

The model block establishes the probabilistic relationships through priors and likelihood functions. Hierarchical priors are set with `tau_a ~ cauchy(0, 1)` and `tau_b ~ cauchy(0, 1)`, which then inform the canonical coefficients `a ~ normal(0, tau_a)` and `b ~ normal(0, tau_b)`, providing adaptive regularization. The variance parameters `sigma_u` and `sigma_v` receive Cauchy priors, while `rho` gets a Beta(2,2) prior favoring moderate correlations. The core likelihood assumes `u ~ normal(0, sigma_u)` and `v ~ normal(rho * u, sigma_v * sqrt(1 - rho^2))`, establishing that the canonical variates follow a bivariate normal distribution with correlation `rho`. The model adds an identifiability constraint `target += -0.5 * dot_self(a) - 0.5 * dot_self(b)` to prevent scaling issues. Finally, the generated quantities block creates posterior predictions by sampling new canonical variates `u_pred` and `v_pred` from their respective distributions, generates predicted data matrices `X_pred` and `Y_pred`, and computes the log-likelihood `log_lik` for model comparison purposes.

#### Fitting the Model
Prepare the data and fit the model using `rstan`.

```R
X_scaled <- scale(X_train)
Y_scaled <- scale(Y_train)

stan_data <- list(
  N = nrow(X_scaled),
  p = ncol(X_scaled),
  q = ncol(Y_scaled),
  X = X_scaled,
  Y = Y_scaled
)

cat("Stan data structure:\n")
str(stan_data)

# Compile and fit the model
cat("\nCompiling and fitting Stan model...\n")
fit_cca <- stan(
  model_code = stan_model,
  data = stan_data,
  iter = 2000,
  warmup = 1000,
  chains = 4,
  cores = 4,
  control = list(adapt_delta = 0.95, max_treedepth = 12),
  verbose = TRUE
)

# Model diagnostics
cat("\nModel Summary:\n")
print(fit_cca, pars = c("rho", "sigma_u", "sigma_v", "tau_a", "tau_b"))

# Check convergence diagnostics
cat("\nConvergence Diagnostics:\n")
cat("R-hat values:\n")
rhat_values <- rhat(fit_cca)
print(rhat_values[rhat_values > 1.1])

cat("\nEffective sample sizes:\n")
eff_samples <- neff_ratio(fit_cca)
print(eff_samples[eff_samples < 0.1])

# Extract posterior samples
posterior_samples <- extract(fit_cca)

# Visualization of results
if (require(bayesplot)) {
  # Trace plots for key parameters
  mcmc_trace(fit_cca, pars = c("rho", "sigma_u", "sigma_v"))
  
  # Posterior density plots
  mcmc_dens(fit_cca, pars = c("rho", "sigma_u", "sigma_v"))
  
  # Posterior intervals for canonical coefficients
  mcmc_intervals(fit_cca, pars = paste0("a[", 1:p, "]"))
  mcmc_intervals(fit_cca, pars = paste0("b[", 1:q, "]"))
}

# Summary statistics
cat("\nPosterior Summary for Key Parameters:\n")
cat("Canonical Correlation (rho):\n")
cat("Mean:", mean(posterior_samples$rho), "\n")
cat("95% CI:", quantile(posterior_samples$rho, c(0.025, 0.975)), "\n")

cat("\nCanonical Coefficients for X (a):\n")
print(colMeans(posterior_samples$a))

cat("\nCanonical Coefficients for Y (b):\n")
print(colMeans(posterior_samples$b))
```

### Model validation on test set

```r
X_test_scaled <- scale(X_test, center = attr(X_scaled, "scaled:center"), 
                       scale = attr(X_scaled, "scaled:scale"))
Y_test_scaled <- scale(Y_test, center = attr(Y_scaled, "scaled:center"), 
                       scale = attr(Y_scaled, "scaled:scale"))

# Calculate canonical variates for test set
a_mean <- colMeans(posterior_samples$a)
b_mean <- colMeans(posterior_samples$b)

u_test <- X_test_scaled %*% a_mean
v_test <- Y_test_scaled %*% b_mean

test_correlation <- cor(u_test, v_test)
```

## Conclusion
In this post, we explored Bayesian Canonical Correlation Analysis, a method to uncover relationships between two sets of variables through maximally correlated linear combinations. By implementing a Bayesian CCA model in Stan, we demonstrated how priors on canonical coefficients and hyperpriors on variance parameters enable robust estimation and uncertainty quantification. Compared to frequentist CCA, the Bayesian approach provides full posterior distributions, eliminating the need for bootstrapping to estimate uncertainty. This makes it particularly useful for small or noisy datasets. The Stan implementation allows for flexible extensions, such as modeling multiple canonical pairs or incorporating hierarchical structures.

## References
- Stan User’s Guide on Multivariate Models
- Gelman, A., & Hill, J. (2006). *Data Analysis Using Regression and Multilevel/Hierarchical Models*
- Krzanowski, W. J. (2000). *Principles of Multivariate Analysis*

