---
layout: post
categories: posts
title: Cholesky Factor in R and Stan
featured-image: /images/stan.png
tags: [STAN, R, Bayes, Linear Algebra]
date-string: November 2027
---

### Cholesky Factor in R and Stan

The Cholesky factor is a lower-triangular matrix $L$ such that a symmetric, positive-definite matrix $\Sigma$ can be written as $\Sigma = LL^\top$. It is often described as a "matrix square root". In Bayesian modelling it matters for two reasons: it makes multivariate normal computations cheaper and more stable, and it gives a convenient way to parameterise covariance and correlation matrices.

#### Understanding the Cholesky Factor

Take a $K \times K$ covariance matrix $\Sigma$. If $\Sigma$ is symmetric and positive definite, a unique lower-triangular matrix $L$ with a strictly positive diagonal exists such that

$$
\Sigma = L L^\top .
$$

The factor can be built row by row. For the diagonal and off-diagonal entries:

$$
L_{jj} = \sqrt{\Sigma_{jj} - \sum_{k=1}^{j-1} L_{jk}^2}, \qquad
L_{ij} = \frac{1}{L_{jj}}\left(\Sigma_{ij} - \sum_{k=1}^{j-1} L_{ik}L_{jk}\right), \; i > j .
$$

The algorithm fails if $\Sigma$ is not positive definite, because a square root of a negative number appears on the diagonal. Practitioners sometimes use this as a cheap test of positive definiteness.

#### Why It Is Useful

Three properties explain most of its uses.

-   **Sampling.** If $z \sim N(0, I)$, then $\mu + Lz \sim N(\mu, \Sigma)$. Correlated draws therefore need only independent standard normals and one matrix multiplication.
-   **Density evaluation.** The log determinant is $\log|\Sigma| = 2\sum_j \log L_{jj}$, and $\Sigma^{-1}$ never needs to be formed explicitly. Solving $Lx = b$ by forward substitution is cheaper and more stable than inverting a full matrix.
-   **Parameterisation.** A correlation matrix has a Cholesky factor with unit-length rows. Stan exploits this with a dedicated type and prior.

A caveat: the factor depends on the ordering of the variables. Permuting them changes $L$, though not $\Sigma$. This rarely matters for modelling, but it is worth knowing when you interpret individual entries.

### Cholesky Factor in R

Base R provides `chol()`, which returns the **upper**-triangular factor $R$ with $\Sigma = R^\top R$. The lower factor is therefore `t(chol(Sigma))`. This convention difference is a common source of bugs when moving code between R and Stan.

#### Computing and Checking the Factor

``` r
Sigma <- matrix(c(4, 2, 0.6,
                  2, 3, 0.5,
                  0.6, 0.5, 2), nrow = 3, byrow = TRUE)

R_upper <- chol(Sigma)
L <- t(R_upper)

L
all.equal(L %*% t(L), Sigma)
```

The final line should return `TRUE`. A matrix that is not positive definite makes `chol()` stop with an error.

#### Generating Correlated Samples

``` r
set.seed(123)
n <- 10000
mu <- c(1, 2, 3)

Z <- matrix(rnorm(n * 3), nrow = n, ncol = 3)
X <- sweep(Z %*% t(L), 2, mu, "+")

colMeans(X)
cov(X)
```

Each row of `Z` is a draw from $N(0, I)$. Multiplying by $L^\top$ on the right (equivalent to $Lz$ for each row) induces the target covariance. The sample covariance should be close to `Sigma`, and the discrepancy shrinks as `n` grows.

#### Splitting Scale and Correlation

``` r
sds <- sqrt(diag(Sigma))
Omega <- cov2cor(Sigma)
L_Omega <- t(chol(Omega))

all.equal(diag(sds) %*% L_Omega, L)
```

The Cholesky factor of the covariance is the diagonal matrix of standard deviations times the Cholesky factor of the correlation matrix. Stan's multivariate models use exactly this decomposition.

#### Visualising the Effect

``` r
library(ggplot2)

Z2 <- matrix(rnorm(2000), ncol = 2)
L2 <- t(chol(matrix(c(1, 0.8, 0.8, 1), 2)))
Y2 <- Z2 %*% t(L2)

df <- rbind(
  data.frame(x = Z2[, 1], y = Z2[, 2], type = "Independent (z)"),
  data.frame(x = Y2[, 1], y = Y2[, 2], type = "Correlated (Lz)")
)

ggplot(df, aes(x, y)) +
  geom_point(alpha = 0.3) +
  facet_wrap(~type) +
  coord_equal() +
  labs(title = "Cholesky factor as a linear transformation")
```

The left panel shows a round cloud, and the right panel shows the same points stretched into an ellipse with correlation near 0.8.

### Cholesky Factor in Stan

Stan offers several pieces that fit together: the `cholesky_factor_corr` type, the LKJ prior on its Cholesky form, and `multi_normal_cholesky`. The Stan documentation notes that if you need more than one multivariate normal draw, it is much more efficient to factor the covariance matrix and call `multi_normal_cholesky_rng`. The same documentation recommends the Cholesky form of the LKJ distribution over the explicit parameterisation. [mc-stan](https://mc-stan.org/docs/functions-reference/distributions_over_unbounded_vectors.html)

#### Simulating Data

``` r
library(rstan)

set.seed(42)
N <- 500
K <- 3
mu_true <- c(1, -1, 0.5)
sigma_true <- c(1, 2, 0.5)
Omega_true <- matrix(c(1, 0.6, -0.3,
                       0.6, 1, 0.2,
                       -0.3, 0.2, 1), 3, byrow = TRUE)
Sigma_true <- diag(sigma_true) %*% Omega_true %*% diag(sigma_true)

L_true <- t(chol(Sigma_true))
y <- matrix(rnorm(N * K), N, K) %*% t(L_true)
y <- sweep(y, 2, mu_true, "+")
```

#### The Stan Model

``` r
mvn_code <- "
data {
  int<lower=1> N;
  int<lower=1> K;
  array[N] vector[K] y;
}
parameters {
  vector[K] mu;
  vector<lower=0>[K] sigma;
  cholesky_factor_corr[K] L_Omega;
}
model {
  mu ~ normal(0, 5);
  sigma ~ cauchy(0, 2.5);
  L_Omega ~ lkj_corr_cholesky(2);
  y ~ multi_normal_cholesky(mu, diag_pre_multiply(sigma, L_Omega));
}
generated quantities {
  corr_matrix[K] Omega = multiply_lower_tri_self_transpose(L_Omega);
}
"
```

The structure follows the multivariate outcome example in the Stan User's Guide: a weakly informative prior on locations, an LKJ prior on correlations, a half-Cauchy prior on scales, and the covariance factor built by scaling the correlation factor. The older array syntax in some of those examples (`vector[K] y[N]`) is replaced here by `array[N] vector[K] y`, which current Stan requires. [mc-stan](https://mc-stan.org/docs/2_26/stan-users-guide/multivariate-outcomes.html)

-   **Data block.** `y` is an array of $N$ vectors, each of length $K$.
-   **Parameters block.** `cholesky_factor_corr[K]` constrains `L_Omega` to be lower triangular with a positive diagonal and unit-norm rows, so that $L_\Omega L_\Omega^\top$ is a valid correlation matrix.
-   **Model block.** `lkj_corr_cholesky(2)` is a mild prior favouring weaker correlations. With $\eta = 1$ the prior is uniform over correlation matrices, and larger values pull toward the identity. `diag_pre_multiply(sigma, L_Omega)` computes $\mathrm{diag}(\sigma) L_\Omega$ without building the diagonal matrix.
-   **Generated quantities.** `multiply_lower_tri_self_transpose` returns the correlation matrix, which is easier to read than its factor.

#### Fitting and Checking

``` r
fit <- stan(model_code = mvn_code,
            data = list(N = N, K = K, y = y),
            iter = 2000, chains = 4, seed = 123)

print(fit, pars = c("mu", "sigma", "Omega"))
```

Compare the posterior means with `mu_true`, `sigma_true` and `Omega_true`. With $N = 500$ they should be close, but individual correlations such as $-0.3$ will carry visible uncertainty. Checking that the 95% intervals cover the true values is a reasonable, if informal, recovery test.

#### Why Not Use a Full Covariance Matrix?

Declaring `cov_matrix[K] Sigma` and using `multi_normal` works, and many tutorials do this. One such example builds `R` and `Sigma` as transformed parameters from `Lcorr`, then calls `multi_normal(mu, Sigma)`. A Stan forum reply to a similar model suggests simplifying with `multi_normal_cholesky`, which takes the Cholesky factor directly. The Cholesky route avoids repeated factorisation inside the likelihood, which is usually the main cost. [jakejing.github](https://jakejing.github.io/posts/2021/02/blog-post-1/)

#### Non-Centred Parameterisation

For hierarchical models, a related trick is to draw standard normal `z` and set `theta = mu + L * z`. This is the non-centred parameterisation of a multivariate normal, as a Stan forum answer puts it. It often helps when group-level variation is small relative to the data, a regime in which the centred form tends to produce divergences. [discourse.mc-stan](https://discourse.mc-stan.org/t/non-centred-parameterisation-for-multivatiate-normal/8081)

``` stan
parameters {
  vector[K] mu;
  vector<lower=0>[K] tau;
  cholesky_factor_corr[K] L_Omega;
  array[J] vector[K] z;
}
transformed parameters {
  array[J] vector[K] theta;
  for (j in 1:J)
    theta[j] = mu + diag_pre_multiply(tau, L_Omega) * z[j];
}
model {
  for (j in 1:J) z[j] ~ std_normal();
  L_Omega ~ lkj_corr_cholesky(2);
  tau ~ normal(0, 1);
}
```

### Summary

The Cholesky factor turns a constrained matrix problem into a triangular one. It supports efficient sampling, stable density evaluation and a clean split between scales and correlations. In R, remember that `chol()` returns the upper factor. In Stan, prefer `cholesky_factor_corr`, `lkj_corr_cholesky` and `multi_normal_cholesky` over their full-matrix counterparts. The next post will use these pieces for multinomial regression with correlated effects, where they connect back to the Dirichlet material.

### References

-   [Stan Functions Reference: Distributions over unbounded vectors](https://mc-stan.org/docs/functions-reference/distributions_over_unbounded_vectors.html)
-   [Stan Functions Reference: Cholesky LKJ correlation distribution](https://mc-stan.org/docs/2_27/functions-reference/cholesky-lkj-correlation-distribution.html)
-   [Stan User's Guide: Multivariate outcomes](https://mc-stan.org/docs/2_26/stan-users-guide/multivariate-outcomes.html)
-   [Stan Reference Manual: Data types and declarations](https://mc-stan.org/docs/reference-manual/types.html)
-   [Stan Forums: Non-centred parameterisation for multivariate normal](https://discourse.mc-stan.org/t/non-centred-parameterisation-for-multivatiate-normal/8081)
-   [Stan Forums: Non-centered parameterization of the multivariate normal distribution](https://discourse.mc-stan.org/t/non-centered-parameterization-of-the-multivariate-normal-distribution/8756)
-   [Multivariate Normal distribution and Cholesky decomposition in Stan](https://jakejing.github.io/posts/2021/02/blog-post-1/)
