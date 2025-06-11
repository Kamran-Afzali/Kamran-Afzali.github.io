

# Main Stan Functions Cheatsheet

Stan is a robust platform for Bayesian statistical modeling, renowned for its Hamiltonian Monte Carlo (HMC) engine and flexible modeling language. While probability distributions like `normal_lpdf` or `poisson_lpmf` define priors and likelihoods, Stan’s non-distribution functions—spanning mathematical operations, matrix algebra, utility tools, and specialized solvers—are equally critical for building efficient and expressive models. These functions enable data transformations, efficient computations, and post-processing in the `generated quantities` block.

This cheatsheet organizes Stan’s most commonly used non-distribution functions into categories, providing their purpose, example usage, and the model types where they’re most applicable. Whether you’re crafting linear regressions, hierarchical models, or dynamic systems, this guide will help you leverage Stan’s toolkit effectively. We’ll wrap up with an example model to bring these functions to life.

## Why Non-Distribution Functions?
Stan’s non-distribution functions serve several key purposes:
- **Transformations**: Functions like `log`, `exp`, and `inv_logit` map parameters to constrained spaces or perform nonlinear calculations.
- **Matrix Operations**: Functions like `dot_product` and `cholesky_decompose` enable efficient linear algebra for multivariate models.
- **Utilities**: Functions like `to_vector` and `mean` simplify data manipulation and posterior summaries.
- **Specialized Tools**: Solvers like `ode_rk45` and `integrate_1d` tackle complex systems, such as differential equations or custom likelihoods.
- **Posterior Processing**: Functions in the `generated quantities` block, like `sum` or `sd`, compute diagnostics or predictions.

This cheatsheet focuses on these functions to help you streamline model specification and analysis.

## Stan Functions Cheatsheet

### 1. Mathematical Functions
These functions perform scalar operations, often used in `transformed parameters` or `model` blocks.

| **Function**      | **Purpose**                     | **Example Usage**              | **Model Type(s)**                     |
|-------------------|---------------------------------|-------------------------------|---------------------------------------|
| `abs(x)`          | Absolute value                  | `real z = abs(x);`            | General computations, robust stats    |
| `exp(x)`          | Exponential (e^x)              | `lambda = exp(alpha);`        | Rate models, transformations          |
| `log(x)`          | Natural logarithm              | `real l = log(y);`            | Log-likelihoods, transformations     |
| `sqrt(x)`         | Square root                    | `sigma = sqrt(variance);`     | Variance computations, scaling       |
| `lgamma(x)`       | Log gamma function             | `lp += lgamma(alpha);`        | Mixture models, custom likelihoods   |
| `log_sum_exp(x)`  | Log-sum-exp for numerical stability | `lp = log_sum_exp(log_theta);` | Mixture models, marginal likelihoods |

### 2. Transformation Functions
These map parameters to constrained spaces, often in `transformed parameters`.

| **Function**      | **Purpose**                       | **Example Usage**                     | **Model Type(s)**                     |
|-------------------|-----------------------------------|--------------------------------------|---------------------------------------|
| `inv_logit(x)`    | Logistic sigmoid (ℝ → (0,1))      | `theta = inv_logit(alpha + beta*x);` | Logistic regression, probability models |
| `logit(p)`        | Log-odds ((0,1) → ℝ)              | `eta = logit(p);`                    | Logistic regression, probit models    |
| `softmax(x)`      | Normalize vector to simplex        | `theta = softmax(alpha);`            | Multinomial regression, LDA           |
| `inv(x)`          | Reciprocal (1/x)                  | `inv_sigma = inv(sigma);`            | Variance transformations             |

### 3. Matrix and Vector Operations
These enable efficient linear algebra, critical for multivariate and hierarchical models.

| **Function**                           | **Purpose**                               | **Example Usage**                                     | **Model Type(s)**                     |
|----------------------------------------|-------------------------------------------|----------------------------------------------|---------------------------------------|
| `dot_product(a, b)`                    | Inner product of two vectors              | `real z = dot_product(a, b);`                | Linear regression, similarity measures |
| `matrix_times_vector(A, v)`            | Matrix-vector multiplication              | `eta = matrix_times_vector(X, beta);`        | Multivariate regression, GLMs         |
| `cholesky_decompose(S)`                 | Cholesky factorization                    | `L = cholesky_decompose(Sigma);`             | Hierarchical models, multivariate normals |
| `multiply_lower_tri_self_transpose(L)` | Covariance from Cholesky factor           | `Sigma = multiply_lower_tri_self_transpose(L);` | Multivariate normals, hierarchical models |
| `diag_matrix(v)`                       | Diagonal matrix from vector               | `M = diag_matrix(v);`                        | Covariance priors, scaling            |
| `determinant(A)`                       | Matrix determinant                        | `det = determinant(Sigma);`                  | Model diagnostics, multivariate priors |

### 4. Utility Functions
These simplify data manipulation and posterior summaries, often in `generated quantities`.

| **Function**      | **Purpose**                     | **Example Usage**                     | **Model Type(s)**                     |
|-------------------|---------------------------------|------------------------------|---------------------------------------|
| `to_vector(x)`    | Convert matrix/array to vector   | `vec = to_vector(matrix);`           | Posterior summaries, data reshaping   |
| `to_array_1d(x)`  | Convert to 1D array             | `arr = to_array_1d(matrix);`         | Data preprocessing, summaries         |
| `sum(x)`          | Sum of elements                 | `total = sum(y);`                    | Aggregations, diagnostics            |
| `mean(x)`         | Mean of elements                | `avg = mean(y_rep);`                 | Posterior summaries, diagnostics      |
| `sd(x)`           | Standard deviation              | `std = sd(y_rep);`                   | Posterior summaries, diagnostics      |
| `int_step(x)`     | Indicator (x ≥ 0 → 1, else 0)   | `flag = int_step(x - 1);`            | Conditional logic, model diagnostics  |

### 5. Specialized Solvers
These handle advanced computations like differential equations or parallel processing.

| **Function**                     | **Purpose**                          | **Example Usage**                                    | **Model Type(s)**                     |
|----------------------------------|--------------------------------------|---------------------------------------------|---------------------------------------|
| `ode_rk45(fun, y0, t0, ts, ...)`| Solve ODEs (Runge-Kutta 45)         | `y = ode_rk45(ode_sys, y0, t0, ts, params);` | Dynamic systems, pharmacokinetics     |
| `integrate_1d(f, a, b, ...)`    | Numerical integration                | `val = integrate_1d(f, a, b, params);`       | Custom likelihoods, marginalization   |
| `map_rect(f, phi, ...)`          | Parallel computation over data shards | `results = map_rect(f, phi, theta, data);`   | Large-scale hierarchical models       |

## Example: Hierarchical Linear Regression
Here’s a Stan model for a hierarchical linear regression, using `matrix_times_vector`, `to_vector`, and `mean` to demonstrate practical function usage:

```stan
data {
  int<lower=0> N; // Number of observations
  int<lower=0> J; // Number of groups
  array[N] int<lower=1,upper=J> group; // Group indicators
  matrix[N, 2] X; // Design matrix (intercept + predictor)
  vector[N] y; // Outcome
}
parameters {
  vector[2] beta; // Fixed effects
  vector[J] alpha; // Group-level intercepts
  real<lower=0> sigma; // Residual standard deviation
  real<lower=0> tau; // Standard deviation of group intercepts
}
model {
  beta ~ normal(0, 5); // Prior on fixed effects
  tau ~ cauchy(0, 2.5); // Prior on group SD
  alpha ~ normal(0, tau); // Group-level priors
  sigma ~ cauchy(0, 2.5); // Prior on residual SD
  vector[N] mu = matrix_times_vector(X, beta) + to_vector(alpha[group]);
  y ~ normal(mu, sigma); // Likelihood
}
generated quantities {
  vector[N] y_rep; // Posterior predictive
  real mean_y_rep; // Mean of predictions
  for (n in 1:N) {
    y_rep[n] = normal_rng(matrix_times_vector(X[n], beta) + alpha[group[n]], sigma);
  }
  mean_y_rep = mean(to_vector(y_rep)); // Summary statistic
}
```

This model:
- Uses `matrix_times_vector` to compute the linear predictor efficiently.
- Employs `to_vector` to align group-level intercepts with observations.
- Computes `mean_y_rep` in `generated quantities` using `mean` and `to_vector` for posterior diagnostics.
- Generates predictions with `normal_rng` for posterior predictive checks.

## Tips for Using Stan Functions
1. **Efficiency**: Prefer vectorized operations like `matrix_times_vector` over loops for speed.
2. **Numerical Stability**: Use `log_sum_exp` for summing exponentials to avoid overflow.
3. **Posterior Analysis**: Leverage `mean`, `sd`, and `to_vector` in `generated quantities` for summaries and diagnostics.
4. **Constraints**: Ensure inputs meet requirements (e.g., `x > 0` for `log`, positive-definite matrices for `cholesky_decompose`).
5. **Advanced Modeling**: Use `ode_rk45` for dynamic systems or `map_rect` for parallelized large-scale models.
6. **Documentation**: The [Stan Reference Manual](https://mc-stan.org/docs/) (e.g., version 2.33) and Stan’s GitHub examples provide detailed guidance.

