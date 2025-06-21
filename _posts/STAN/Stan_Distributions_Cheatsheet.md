# Main Stan Distributions Cheatsheet

Statistical modeling in **Stan** is powered by a flexible and expressive probabilistic language grounded in **log-density functions**. While the modeling blocks (`model`, `data`, `parameters`, etc.) help structure a model, the core statistical logic is defined through **distributions**. This cheatsheet offers a practical summary of the most important distributions used in Stan, their syntax, required parameters, typical use cases, and examples of where they show up in statistical modeling.

---

| **Distribution**      | **Function**                  | **Parameters** | **Use Case**                            | **Model Type(s)**                      |                                                         |
| --------------------- | ----------------------------- | -------------- | --------------------------------------- | -------------------------------------- | ------------------------------------------------------- |
| **Bernoulli**         | \`bernoulli\_lpmf(y           | θ)\`           | `θ ∈ (0, 1)`                            | Binary outcome (0/1)                   | Logistic regression, classification                     |
| **Binomial**          | \`binomial\_lpmf(y            | n, θ)\`        | `n ∈ ℕ⁺`, `θ ∈ (0, 1)`                  | # of successes in `n` trials           | Logistic GLMs, grouped binomial models                  |
| **Categorical**       | \`categorical\_lpmf(y         | θ)\`           | `θ`: simplex vector (length K)          | Single draw from K categories          | Multinomial regression                                  |
| **Multinomial**       | \`multinomial\_lpmf(y         | θ)\`           | `y`: int vector of counts, `θ`: simplex | Category count data                    | Count models with category splits                       |
| **Normal**            | \`normal\_lpdf(y              | μ, σ)\`        | `μ ∈ ℝ`, `σ > 0`                        | Gaussian noise, residuals              | Linear regression, priors for real parameters           |
| **Student's t**       | \`student\_t\_lpdf(y          | ν, μ, σ)\`     | `ν > 0`, `μ ∈ ℝ`, `σ > 0`               | Heavy-tailed data, robust models       | Robust regression, hierarchical priors                  |
| **Cauchy**            | \`cauchy\_lpdf(y              | μ, σ)\`        | `μ ∈ ℝ`, `σ > 0`                        | Weakly informative, heavy-tailed prior | Priors on scale parameters (e.g., `τ ~ cauchy(0, 2.5)`) |
| **Exponential**       | \`exponential\_lpdf(y         | λ)\`           | `λ > 0`                                 | Time to event, memoryless processes    | Survival models, Poisson process modeling               |
| **Gamma**             | \`gamma\_lpdf(y               | α, β)\`        | `α > 0`, `β > 0`                        | Positive skewed data                   | Priors on rates or shape parameters                     |
| **Inverse Gamma**     | \`inv\_gamma\_lpdf(y          | α, β)\`        | `α > 0`, `β > 0`                        | Prior for variances                    | Priors on `σ²`, `τ²`, especially in hierarchies         |
| **Lognormal**         | \`lognormal\_lpdf(y           | μ, σ)\`        | `μ ∈ ℝ`, `σ > 0`                        | Positive, right-skewed data            | Income, durations, reliability                          |
| **Beta**              | \`beta\_lpdf(y                | α, β)\`        | `α > 0`, `β > 0`                        | Probabilities or proportions           | Priors on probabilities (`θ ∈ (0, 1)`)                  |
| **Dirichlet**         | \`dirichlet\_lpdf(θ           | α)\`           | `θ`: simplex, `α > 0` vector            | Probabilities summing to 1             | Priors for category proportions, LDA                    |
| **Poisson**           | \`poisson\_lpmf(y             | λ)\`           | `λ > 0`                                 | Count data, rare event modeling        | GLMs for count data                                     |
| **Negative Binomial** | \`neg\_binomial\_2\_lpmf(y    | μ, φ)\`        | `μ > 0`, `φ > 0`                        | Overdispersed count data               | GLMs with extra-Poisson variation                       |
| **Ordered Logistic**  | \`ordered\_logistic\_lpmf(y   | η, c)\`        | `η ∈ ℝ`, `c`: ordered cut-points        | Ordinal outcomes                       | Ordinal regression                                      |
| **Uniform**           | \`uniform\_lpdf(y             | a, b)\`        | `a < b`                                 | Flat prior within range                | Non-informative priors                                  |
| **Pareto**            | \`pareto\_lpdf(y              | y\_min, α)\`   | `y_min > 0`, `α > 0`                    | Heavy-tail data, power-law phenomena   | Extremes, outlier modeling                              |
| **Von Mises**         | \`von\_mises\_lpdf(y          | μ, κ)\`        | `μ ∈ [0, 2π)`, `κ ≥ 0`                  | Circular data (angles, wind direction) | Directional models                                      |
| **Weibull**           | \`weibull\_lpdf(y             | α, σ)\`        | `α, σ > 0`                              | Survival times, failure rates          | Survival models, reliability analysis                   |
| **LKJ Correlation**   | \`lkj\_corr\_cholesky\_lpdf(L | η)\`           | `η > 0`, `L`: Cholesky factor           | Prior for correlation matrices         | Hierarchical models with random slopes                  |
| **Wishart**           | \`wishart\_lpdf(S             | ν, Σ)\`        | `ν > dim-1`, `Σ`: scale matrix          | Prior on covariance matrices           | Multivariate Gaussian models (rarely used)              |

