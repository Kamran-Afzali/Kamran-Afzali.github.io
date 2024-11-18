---
layout: post
categories: posts
title: Dirichlet Distribution in R and Stan
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: November 2024
---


### Dirichlet Distribution in R and Stan

The Dirichlet distribution is a family of continuous multivariate probability distributions parameterized by a vector of positive numbers. It is often used as a prior distribution in Bayesian statistics, particularly in the context of categorical distributions. Named after _Johann Peter Gustav Lejeune Dirichlet_, this distribution is used in different fields.

#### Understanding the Dirichlet Distribution

The Dirichlet distribution is defined over a probability simplex,
meaning that it deals with vectors of probabilities that sum to 1. If we
have $K$ categories, then a Dirichlet distribution is defined over a
vector $\mathbf{p} = (p_1, p_2, \ldots, p_K)$, where each $p_i \geq 0$
and $\sum_{i=1}^{K} p_i = 1$. The distribution is governed by a
parameter vector
$\mathbf{\alpha} = (\alpha_1, \alpha_2, \ldots, \alpha_K)$, where each
$\alpha_i > 0$.

The density function of the Dirichlet distribution for a $K$-dimensional
vector $\mathbf{p}$ is given by:

$$
f(\mathbf{p} \mid \mathbf{\alpha}) = \frac{1}{B(\mathbf{\alpha})} \prod_{i=1}^{K} p_i^{\alpha_i - 1}
$$

where $B(\mathbf{\alpha})$ is the multinomial beta function, acting as a
normalization constant to ensure the distribution integrates to 1.

#### Properties and Characteristics

- **Support**: The Dirichlet distribution is defined over the simplex, meaning that the components of a random vector drawn from a Dirichlet distribution are positive and sum to one.
- **Parameters**: The parameter vector $$\alpha$$ influences the shape and concentration of the distribution. Each component of $$\alpha$$ can be thought of as a prior count or concentration parameter for the corresponding component of the probability vector.
- **Mean and Variance**: The mean of each component of a Dirichlet-distributed vector is given by the ratio of the corresponding $$\alpha$$ parameter to the sum of all $$\alpha$$ parameters. The variance and covariance of the components are also functions of the $$\alpha$$ parameters, reflecting the distribution's flexibility in modeling different levels of uncertainty and correlation among components.


#### Applications of the Dirichlet Distribution

The Dirichlet distribution is widely used in Bayesian inference, topic modeling, and clustering. In Bayesian inference, it acts as a conjugate prior for the multinomial distribution, meaning that updates based on new data produce another Dirichlet distribution. This property makes calculations simpler and is especially useful when working with categorical data. In natural language processing, the Dirichlet distribution is foundational for Latent Dirichlet Allocation (LDA), a method used to uncover hidden topics within a collection of texts. By modeling the distribution of topics in documents and the distribution of words within topics, LDA helps reveal the underlying thematic structure of large datasets. The Dirichlet distribution also plays a crucial role in clustering, particularly in Dirichlet Process Mixture Models (DPMMs). These models are powerful for cases where the number of clusters isn’t known in advance, allowing for adaptive and flexible grouping of data. Whether simplifying complex computations or uncovering patterns in diverse datasets, the Dirichlet distribution proves itself a cornerstone of modern statistical and machine learning methods.

### Dirichlet Distribution in R

Dirichlet distribution can be implemented in R using the `gtools` package and the `LaplacesDemon` package:

#### Generating Samples from a Dirichlet Distribution

```r

library(gtools)
alpha <- c(2, 3, 5)
n=1000
samples <- rdirichlet(n, alpha)
print(samples)
colMeans(samples)
print(posterior_mean)
```

Code generates 10 samples from a Dirichlet distribution with parameters \( $\alpha$ = (2, 3, 5) \). Each sample is a probability vector of three elements, and the rows of the output matrix represent different samples.

#### Using the Dirichlet Distribution as a Prior

```r
observed_data <- c(10, 15, 25)

prior_alpha <- c(2, 3, 5)

posterior_alpha <- prior_alpha + observed_data

posterior_samples <- rdirichlet(1000, posterior_alpha)

posterior_mean <- colMeans(posterior_samples)
print(posterior_mean)
```

Dirichlet distribution can be used as a prior in a Bayesian framework with the prior parameters are updated with observed data, and samples are drawn from the posterior distribution to estimate the mean probabilities of each category.

#### Visualizing the Dirichlet Distribution

```r
alpha <- c(2, 3, 5)
samples <- rdirichlet(10000, alpha)
library(ggtern)
data <- as.data.frame(samples)
colnames(data) <- c("X1", "X2", "X3")
ggtern(data = data, aes(x = X1, y = X2, z = X3)) +
  geom_point(alpha = 0.1) +
  labs(title = "Dirichlet Distribution Visualization")
```


### Dirichlet Distribution in Stan

To implement the Dirichlet distribution using Stan and RStan, you can follow the example below. This example demonstrates how to define a simple Stan model with a Dirichlet distribution and run it using RStan in R.

First, create a Stan model file (e.g., `dirichlet_model.stan`) with the following content:

```r
stan_model <-'data {
  int<lower=1> K; // Number of categories
  vector<lower=0>[K] alpha; // Dirichlet parameters
}

parameters {
  simplex[K] theta; // Probability vector
}

model {
  theta ~ dirichlet(alpha); // Dirichlet prior
}'
```

Next, use RStan to compile and run the Stan model. Here is an example of how to do this in R:

```r
library(rstan)
K <- 3
alpha <- c(2, 3, 5) # Dirichlet parameters
data_list <- list(K = K, alpha = alpha)
fit <- stan(model_code=stan_model, data = data_list, iter = 2000, chains = 4)
print(fit)

```

- **Data Block**: The data block in the Stan model specifies the number of categories `K` and the Dirichlet parameters `alpha`. These are provided as inputs to the model.
- **Parameters Block**: The parameters block defines `theta` as a simplex, which ensures that the elements of `theta` are non-negative and sum to one, making it suitable for modeling probabilities.
- **Model Block**: The model block specifies that `theta` follows a Dirichlet distribution with parameters `alpha`.

- **RStan**: The R code uses the `rstan` package to compile the Stan model and perform sampling. The `sampling` function runs the Markov Chain Monte Carlo (MCMC) to generate samples from the posterior distribution of `theta`.
- **Output**: The `print` function outputs the summary of the posterior samples, including estimates for the components of `theta`.


### Bayesian Model with Dirichlet Prior in Stan 


```r
library(rstan)
library(ggplot2)

dirichlet_model_code <- "
data {
  int<lower=1> K;            // Number of categories
  int<lower=0> N;            // Number of observations
  int<lower=1, upper=K> y[N]; // Observations (categorical data)
  vector<lower=0>[K] alpha;  // Dirichlet prior parameters
}
parameters {
  simplex[K] theta;          // Probabilities for each category
}
model {
  theta ~ dirichlet(alpha);  // Dirichlet prior
  y ~ categorical(theta);    // Likelihood
}
generated quantities {
  vector[K] p_hat;           // Posterior mean of theta
  p_hat = theta;
}
"
```

- **Data Block**: Specifies the number of categories `K`, the number of observations `N`, the observed data `y`, and the Dirichlet prior parameters `alpha`.
- **Parameters Block**: Defines `theta`, a vector representing the probabilities for each category, which is constrained to be a simplex (i.e., sums to 1).
- **Model Block**: Applies the Dirichlet prior to `theta` and models the observed data `y` using a categorical distribution.
- **Generated Quantities Block**: Computes the posterior mean of `theta`.

Now, prepare some synthetic data to fit the model:

```r
# Number of categories
K <- 3

# Observed data (e.g., 1, 2, 3 corresponds to categories)
y <- c(rep(1,20),rep(2,30),rep(3,50))

# Number of observations
N <- length(y)

# Dirichlet prior parameters (e.g., prior beliefs about category probabilities)
alpha <- c(2, 2, 2)

# Data list to pass to Stan
data_list <- list(K = K, N = N, y = y, alpha = alpha)
```

Compile and run the Stan model using the `stan` function:

```r
dirichlet_model <- stan_model(model_code = dirichlet_model_code)

fit <- sampling(dirichlet_model, data = data_list, iter = 2000, chains = 4, seed = 123)

print(fit)
```

Extract the posterior distributions:

```r
# Extract the posterior samples
posterior_samples <- extract(fit)

posterior_mean <- apply(posterior_samples$p_hat, 2, mean)
print(posterior_mean)

theta_samples <- as.data.frame(posterior_samples$theta)
colnames(theta_samples) <- paste0("theta_", 1:K)

```

The Dirichlet distribution is used in Bayesian statistics and machine learning for modeling probabilities over multiple categories. More specifically, it has utility as a conjugate prior for multinomial distributions in applications such as topic modeling, clustering, and Bayesian inference. It is possbile to implement and explore Dirichlet models, both for simulation and for real-world data analysis in R and Stan . The examples in this blog demonstrate how to generate samples from the Dirichlet distribution, use it as a prior in Bayesian modeling, and apply it using RStan for more complex models. 

### References

- [The multinomial model in stan - fit dirichlet distribution parameters](https://stackoverflow.com/questions/45700667/the-multinomial-model-in-stan-how-to-fit-dirichlet-distribution-parameters)
- [Dirichlet distribution example stan](https://discourse.mc-stan.org/t/dirichlet-distribution-example-not-working/27968)
- [Guide to understanding the intuition behind the Dirichlet distribution](https://www.andrewheiss.com/blog/2023/09/18/understanding-dirichlet-beta-intuition/)
- [Introduction to the Dirichlet Distribution and Related Processes](http://mayagupta.org/publications/FrigyikKapilaGuptaIntroToDirichlet.pdf)
- [LDA Model: Simulated Data Generation in R & Parameter Recovery Study in RStan](https://www.mithilaguha.com/post/lda-model-simulated-data-generation-in-r-parameter-recovery-study-in-rstan)
- [Dirichlet distribution in Stan](https://mc-stan.org/docs/2_27/functions-reference/dirichlet-distribution.html)
- [Dirichlet Distribution R LaplacesDemon](https://search.r-project.org/CRAN/refmans/LaplacesDemon/html/dist.Dirichlet.html)
- [The Dirichlet Distribution: What Is It and Why Is It Useful?](https://builtin.com/data-science/dirichlet-distribution)
- [Dirichlet Distribution Example](https://rpubs.com/JanpuHou/295096)
- [Bayesian Regression for a Dirichlet Distributed Response using Stan](https://arxiv.org/pdf/1808.06399)




