---
layout: post
categories: posts
title: Bayesian Ordinal and Multinomial Regression Models
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: May 2024
---

### Bayesian Ordinal and Multinomial Regression Models

Bayesian modeling offers a powerful framework for handling ordered categorical and multinomial outcomes in a variety of contexts. When dealing with ordered categorical outcomes, such as survey responses or Likert scale ratings, Bayesian methods can be applied to fit ordinal logistic regression models. In this approach, the cumulative probabilities of each ordinal category are modeled relative to the predictor variables. By incorporating prior information about these relationships, Bayesian ordinal logistic regression provides a flexible and robust approach for modeling ordered categorical outcomes. Similarly, Bayesian modeling with Stan can also be applied to multinomial outcomes, where the outcome variable has more than two categories. Multinomial logistic regression models can be fitted using Stan, wherein the probabilities of each category relative to a reference category are modeled as a function of the predictor variables. This approach is particularly useful in settings where the outcome variable represents multiple mutually exclusive categories, such as different types of diseases or customer preferences. With Stan, researchers can specify complex multinomial logistic regression models that account for uncertainty in the parameter estimates and incorporate prior beliefs about the relationships between predictors and the outcome categories.

Bayesian methods allow for the incorporation of uncertainty quantification and model comparison techniques. Uncertainty quantification is essential in Bayesian modeling as it provides estimates of uncertainty in model parameters, allowing researchers to make more informed decisions and interpretations. Stan facilitates the calculation of credible intervals for model parameters, providing insights into the range of plausible values. Additionally, model comparison techniques such as Bayesian Information Criterion (BIC) or leave-one-out cross-validation (LOO-CV) can be used to compare the fit of different models and aid in model selection. This enables researchers to identify the most appropriate model for their data, considering both goodness-of-fit and model complexity. Here we present two examples of Stan code defines multinomial and ordinal logistic regression models, where a predictor matrix `x` is used to predict the categorical outcome variable `y`. The model estimates a matrix of coefficients `beta`, and the likelihood function relates the predictor variables to the outcome categories.

#### multinomial logistic regression example

```r
library(rstan)

stan_code <- '
data {
  int K;
  int N;
  int D;
  int y[N];
  matrix[N, D] x;
}
parameters {
  matrix[D, K] beta;
}
model {
  matrix[N, K] x_beta = x * beta;

  to_vector(beta) ~ normal(0, 5);

  for (n in 1:N)
    y[n] ~ categorical_logit(x_beta[n]');
}'

stan_model <- stan_model(model_code = stan_code)

# Generate simulated data
set.seed(123)
N <- 100
D <- 3
K <- 5
x <- matrix(rnorm(N * D), ncol = D)
beta_true <- matrix(rnorm(D * K), ncol = K)
eta <- x %*% beta_true
y <- apply(eta, 1, function(eta_i) sample(1:K, 1, prob = exp(eta_i) / sum(exp(eta_i))))

# Prepare data for Stan
stan_data <- list(
  N = N,
  D = D,
  K = K,
  x = x,
  y = y
)

fit <- sampling(stan_model, data = stan_data)

print(fit)

```

**Data Block:**
```stan
data {
  int K;            // Number of categories or classes
  int N;            // Number of observations
  int D;            // Number of predictors or features
  int y[N];         // Outcome variable, an array of length N containing the category indices
  matrix[N, D] x;   // Predictor matrix, containing the predictor values for each observation
}
```
In the data block, we declare the variables used in the model and specify their dimensions and types. Here, `K` represents the number of categories or classes, `N` is the number of observations, `D` is the number of predictors, `y` is an array of length `N` containing the category indices (each entry corresponds to the category of the respective observation), and `x` is a matrix of size `N`-by-`D` containing the predictor values for each observation.

**Parameters Block:**
```stan
parameters {
  matrix[D, K] beta;   // Coefficient matrix, where each column represents the coefficients for one category
}
```
In the parameters block, we declare the parameters to be estimated in the model. Here, `beta` is a matrix of size `D`-by-`K`, where each column represents the coefficients for one category. The elements of this matrix will be estimated during the modeling process.

**Model Block:**
```stan
model {
  matrix[N, K] x_beta = x * beta;   // Matrix multiplication to obtain linear predictors

  to_vector(beta) ~ normal(0, 5);    // Prior distribution for the coefficients

  for (n in 1:N)
    y[n] ~ categorical_logit(x_beta[n]');   // Likelihood function for the categorical outcome
}
```
In the model block, we define the statistical model. 

1. **Matrix Multiplication**: We perform matrix multiplication between the predictor matrix `x` and the coefficient matrix `beta` to obtain the linear predictors for each category, stored in `x_beta`.

2. **Prior Distribution**: We specify a prior distribution for the coefficients `beta`. Here, we assume a normal prior distribution with mean 0 and standard deviation 5 for all elements of `beta`.

3. **Likelihood Function**: We define the likelihood function for the categorical outcome variable `y`. In this case, we use the `categorical_logit` distribution, which models the outcome as a categorical variable with probabilities proportional to the exponential of the linear predictors `x_beta`. The loop iterates over each observation `n` and assigns the corresponding likelihood of observing the category specified by `y[n]`.


#### Ordinal logistic regression example

```r
library(rstan)

stan_code <- '
data {
  int<lower=2> K;
  int<lower=0> N;
  int<lower=1> D;
  int<lower=1,upper=K> y[N];
  row_vector[D] x[N];
}
parameters {
  vector[D] beta;
  ordered[K-1] c;
}
model {
  for (n in 1:N)
    y[n] ~ ordered_logistic(x[n] * beta, c);
}'

stan_model <- stan_model(model_code = stan_code)

set.seed(123)
N <- 100
D <- 2
K <- 4
x <- matrix(rnorm(N * D), ncol = D)
beta_true <- c(1, -1)
c_true <- c(-1, 0, 1)
eta <- x %*% beta_true
y <- apply(eta, 1, function(eta_i) sum(eta_i > c_true))
y <- pmin(y + 1, K)

stan_data <- list(
  N = N,
  D = D,
  K = K,
  x = x,
  y = y
)

fit <- sampling(stan_model, data = stan_data)

print(fit)
```

 Let's break down the code:

**Data Block:**
```stan
data {
  int<lower=2> K;               // Number of categories for the ordered outcome variable
  int<lower=0> N;               // Number of observations
  int<lower=1> D;               // Number of predictors or features
  int<lower=1, upper=K> y[N];   // Array of length N containing the ordered outcome variable
  row_vector[D] x[N];           // Array of length N containing the predictor values for each observation
}
```
In the data block, we declare the variables used in the model. 
- `K` represents the number of categories for the ordered outcome variable.
- `N` represents the number of observations.
- `D` represents the number of predictors or features.
- `y` is an array of length `N` containing the ordered outcome variable.
- `x` is an array of length `N` containing the predictor values for each observation.

**Parameters Block:**
```stan
parameters {
  vector[D] beta;              // Coefficients for the predictor variables
  ordered[K-1] c;              // Cutpoints separating the categories
}
```
In the parameters block, we declare the parameters to be estimated in the model.
- `beta` is a vector of length `D`, representing the coefficients for the predictor variables.
- `c` is an ordered array of length `K-1`, representing the cutpoints that separate the categories of the ordered outcome variable.

**Model Block:**
```stan
model {
  for (n in 1:N)
    y[n] ~ ordered_logistic(x[n] * beta, c);   // Likelihood function
}
```
In the model block, we define the statistical model.

1. **Likelihood Function**: We specify the likelihood function for the ordered outcome variable `y`. The `ordered_logistic` distribution models the outcome as an ordered categorical variable with ordered cutpoints specified by `c`. For each observation `n`, we model the probability of observing the category specified by `y[n]` given the predictor values `x[n]` and the coefficients `beta`.



#### A premiere on Dirichlet distribution

The Dirichlet distribution is a family of continuous multivariate probability distributions, parameterized by a vector `α` of positive real numbers. It is commonly used as a prior distribution for categorical or multinomial variables in Bayesian statistics. The Dirichlet distribution can characterize the random variability of a multinomial distribution and is particularly useful for modeling actual measurements due to its ability to generate a wide variety of shapes based on the parameters `α`. Dirichlet distribution is useful for modeling categorical data in different applications, such as multinomial models, where Stan provides a categorical family specifically designed to address multinomial or categorical outcomes. This feature enables the fitting of Bayesian models with multinomial responses, facilitating the automatic generation of categorical contrasts (instead of comparing with one reference category). By utilizing the Dirichlet distribution as a prior distribution for categorical or multinomial variables in Bayesian regression, researchers can introduce prior knowledge or beliefs about the distribution of categorical data into their modeling process. 


### References

- [Multi-Logit Regression](https://mc-stan.org/docs/2_20/stan-users-guide/multi-logit-section.html)
- [Statistical Rethinking 2: Chapter 12](https://vincentarelbundock.github.io/rethinking2/12.html)
- [Ordered Logistic and Probit Regression](https://mc-stan.org/docs/2_18/stan-users-guide/ordered-logistic-section.html)
- [The Dirichlet Distribution: What Is It and Why Is It Useful?](https://builtin.com/data-science/dirichlet-distribution)
- [https://distribution-explorer.github.io/multivariate_continuous/dirichlet.html](https://distribution-explorer.github.io/multivariate_continuous/dirichlet.html)
- [Dirichlet Distribution: Simple Definition, PDF, Mean](https://www.statisticshowto.com/dirichlet-distribution/)
- [Guide to understanding the intuition behind the Dirichlet distribution](https://www.andrewheiss.com/blog/2023/09/18/understanding-dirichlet-beta-intuition/)

