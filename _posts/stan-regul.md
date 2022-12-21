---
layout: post
categories: posts
title: Bayesian Regularized Regression
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: June 2022
---

## Introduction

In this post, we will explore Bayesian analogues of regularized/penalized linear regression models (e.g., LASSO, Ridge regression), which are an extention of traditional linear regression models of the form. First we will discuss shrinkage and regularization in regression problems. These methods are useful for improving prediction, estimating regression models with many variables, and as an alternative to model selection methods. Our goal is to
understand shrinkage/regularization of coefficients as an alternative/complement to variable selection. Use three specific approaches to regularization—ridge, LASSO, hierarchical shrinkage—which regularize through different priors, with different consequences for sparsity, and to recognize connections between Bayesian regularized regression and regularized regression in a machine learning/penalized maximum likelihood estimation (MLE) framework. Traditional linear regression models assume that  weights share no group-level information (i.e. they are independent), which leads to so-called unbiased estimates. Unlike traditional linear regression models, regularized linear regression models produce biased estimates for the  weights. Specifically, Bayesian regularized linear regression models pool information across weights, resulting in regression toward a common mean. When the common mean is centered at 0, this pooling of information produces more conservative estimates for each  weight (they are biased toward 0). Shrinkage estimation deliberately increases the bias of the model in order to reduce variance and improve overall model performance, often at the cost of individual estimates. In other words, by adding bias to the model, shrinkage estimators provide a means to adjust the bias-variance in the model in order to achieve lower generalization error. Bayesian models with non-informative priors will produce similar to the MLE. However, parameters are modeled as exchangeable and given a proper prior, it induces some amount of shrinkage. But stronger priors can produce estimate much different estimtes than MLE.

## Regularized Regression
As described above, regularized linear regression models aim to estimate more conservative values for the  weights in a model, and this is true for both frequentist and Bayesian versions of regularization. While there are many methods that can be used to regularize your estimation procedure, we will focus specifically on two popular forms—namely, ridge and LASSO regression. We start below by describing each regression generally, and then proceed to implement both the frequentist and Bayesian versions.

### Bayesian Ridge Regression

Ridge regression modifies the loss function to include a penalty term for model complexity, where model complexity is operationalized as the sum of squared  weights. Bayesian Ridge regression differs from the frequentist variant in only one way, and it is with how we think of the penalty term. In the frequentist perspective, we showed that effectively tells our model how much it is allowed to learn from the data. Bayesian models view estimation as a problem of integrating prior information with information gained from data, which we formalize using probability distributions. The Bayesian estimation captures this in the form of a prior distribution over our  weights the choice of prior distribution on is what determines how much information we learn from the data, analagous to the penalty term used for MLE regularization.

```stan
data{
    int N_train;             // "# training observations"
    int N_test;              // "# test observations"
    int N_pred;              // "# predictor variables"
    vector[N_train] y_train; // "training outcomes"
    matrix[N_train, N_pred] X_train; // "training data"
    matrix[N_test, N_pred] X_test;   // "testing data"
}
parameters{
    real<lower=0> sigma;   // "error SD"
    real<lower=0> sigma_B; // "hierarchical SD across betas"
    vector[N_pred] beta;   // "regression beta weights"
}
model{
  // "group-level (hierarchical) SD across betas"
  sigma_B ~ cauchy(0, 1);
  
  // "model error SD"
  sigma ~ normal(0, 1);
  
  // "beta prior (provides 'ridge' regularization)"
  beta ~ normal(0, sigma_B);
    
  // "model likelihood"
    y_train ~ normal(X_train*beta, sigma);
}
generated quantities{ 
    real y_test[N_test]; // "test data predictions"
    for(i in 1:N_test){
        y_test[i] = normal_rng(X_test[i,] * beta, sigma);
    }
}
```

### Bayesian LASSO Regression

LASSO regression only involves a minor change to the loss function compared to ridge regression. Specifically, as opposed to penalizing the model based on the sum of squared  weights, it will penalize the model by the sum of the absolute value of  weights. As for Bayesian ridge regression, we only needed to specifiy a normal prior distribution to the weights that we were aiming to regularize, for Bayesian LASSO regression, the only difference is in the form of the prior distribution by setting it to a double-exponential prior on the  weights is mathematically equivalent in expectation to the frequentist LASSO penalty. Laplace distribiution places much more probability mass directly on 0, which produces the variable selection effect specific to LASSO regression. 

```stan
data{
    int N_train;             // "# training observations"
    int N_test;              // "# test observations"
    int N_pred;              // "# predictor variables"
    vector[N_train] y_train; // "training outcomes"
    matrix[N_train, N_pred] X_train; // "training data"
    matrix[N_test, N_pred] X_test;   // "testing data"
}
parameters{
    real<lower=0> sigma;   // "error SD"
    real<lower=0> sigma_B; // "(hierarchical) SD across betas"
    vector[N_pred] beta;   // "regression beta weights"
}
model{
  // "group-level (hierarchical) SD across betas"
  sigma_B ~ cauchy(0, 1);
  
  // "Prior on SD"
  sigma ~ normal(0, 1);
  
  // "beta prior (Note this is the only change!)"
  beta ~ double_exponential(0, sigma_B); 
    
  // "model likelihood"
    y_train ~ normal(X_train*beta, sigma);
}
generated quantities{ 
    real y_test[N_test]; // "test data predictions"
    for(i in 1:N_test){
        y_test[i] = normal_rng(X_test[i,] * beta, sigma);
    }
}

```

### Hierarchical shrinkage

IF The Bayesian LASSO doesn’t get us sparsity with a few relatively large coefficients, and many coefficients very close to zero it is possible to use different global-local scale mixtures of normal distributions as our priors to encourage more sparsity. In that case it is possible to combine the global scale for all coefficient priors along with a local scale for each coefficient. 

```stan
data {
  
  int N; //  observations
  
  vector[N] y; // outcome
  int K;   // number of columns in the design matrix X
  matrix [N, K] X;  // design matrix X
  real<lower = 0> tau;   // global scale prior scale
}
transformed data {
  real<lower = 0> y_sd;
  real a_pr_scale;
  real sigma_pr_scale;
  y_sd = sd(y);
  sigma_pr_scale = y_sd * 5;
  a_pr_scale = 10;
}
parameters {
  real a;   // regression coefficient vector
  vector[K] b_raw;   // scale of the regression errors
  real<lower = 0> sigma;   // local scales of coefficients
  vector<lower = 0>[K] lambda;
}
transformed parameters {
  vector[N] mu;   // mu is the observation fitted/predicted value
  vector[K] b;   // b is the transformed beta
  b = b_raw * tau .* lambda;
  mu = a + X * b;
}
model {
  lambda ~ cauchy(0, 1);   // priors
  a ~ normal(0, a_pr_scale);
  b_raw ~ normal(0, 1);
  sigma ~ cauchy(0, sigma_pr_scale);
  y ~ normal(mu, sigma);   // likelihood
}
generated quantities {
  vector[N] y_rep;   // simulate data from the posterior
  vector[N] log_lik;   // log-likelihood posterior
  for (n in 1:N) {
    y_rep[n] = normal_rng(mu[n], sigma);
    log_lik[n] = normal_lpdf(y[n] | mu[n], sigma);
  }
}

```

## Conclusion 

In this post, we learned about the benefits of using regularized/penalized regression models over traditional regression. We determined that in low and/or noisy data settings, the so-called unbiased estimates given by non-regularized regression modeling actually lead to worse-off model performance. Importantly, we learned that this occurs because being ubiased allows a model to learn a lot from the data, including learning patterns of noise. Then, we learned that biased methods such as ridge and LASSO regression restrict the amount of learning that we get from data, which leads to better estimates in low and/or noisy data settings. Finally, hierarchical Bayesian models can choose a prior distribution across the  weights that gives us a solution that is equivalent to that of the frequentist ridge or LASSO methods, with a full posterior distribution for each parameter, thus circumventing problems with frequentist regularization that require the use of bootstrapping to estimate confidence intervals.

## References

+ [Blogpost on the equivalency between frequentist Ridge (and LASSO) regression and hierarchial Bayesian regression](http://haines-lab.com/post/2019-05-06-on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/)

+ [Blogpost on Bayesian regularization 1](https://jrnold.github.io/bayesian_notes/shrinkage-and-regularized-regression.html)

+ [Blogpost on Bayesian regularization 2](http://ccgilroy.com/csss564-labs-2019/08-regularization/08-regularization.html)

+ [Github code examples](https://github.com/ccgilroy/csss564-labs-2019)


