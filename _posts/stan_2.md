---
layout: post
categories: posts
title: Bayesian Regression Models for Non-Normal Data
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: June 2022
---



### Bayesian Regression Models for Non-Normal Data


We covered how to do normally distributed data bayesian regression in R using STAN in a previous post. In this post, we'll examine at how to fit a non-normal model in STAN using three common distributions seen in empirical data: binomial, negative-binomial, and log-normal (overdispersed poisson data). Bayesian models quantify (aleatory and epistemic) uncertainty at a high level, allowing us to account for the ways in which our knowledge is limited or faulty in our predictions and decisions. Using a set of sampling methods known as Markov Chain Monte Carlo, we define a statistical model and find probabilistic estimates for the parameters (MCMC). Stan is my go-to tool for creating Bayesian models that fit. If you are unfamiliar with Bayesian statistics, I expect that a three-sentence summary will not suffice, so I will write a separate essay about the benefits and challenges of applied Bayesian inference.


### Logistic Regression

The likelihood of a binary outcome, such as Pass or Fail, is estimated using logistic regression (but it can be extended to include more than two possibilities). This is accomplished by using the logit function to convert a standard regression, as demonstrated below. Gamblers may be familiar with the term in brackets, as it describes how odds are derived from probabilities. For this reason, logit and log-odds are frequently interchanged. The inverse logit function transfers data from a probability scale to a probability scale, as the logit function did. As a result, its values vary from 0 to 1, and this characteristic is particularly important when considering the likelihood of Pass/Fail results.

A Generalised Linear Model is created when a linear regression is supplemented with a re-scaling function like this (GLM). In this context, the re-scaling (in this case, the logit) function is referred to as a link function. A Bernoulli-Logit GLM is used to model logistic regression. For binary outcomes, either the logistic or probit regression models, which are closely related, might be utilised.  The following is the code for a logistic regression model with one predictor and an intercept.


```
#load the libraries
library(arm) #for the invlogit function
library(emdbook) #for the rbetabinom function
library(rstan)
library(rstanarm) #for the launch_shinystan function

```

```
 set.seed(1234)
 x1 = rnorm(1000)           # some continuous variables 
 x2 = rnorm(1000)
 x3 = rnorm(1000)
 z = 1 + 2*x1 + 3*x2        # linear combination with a bias
 pr = 1/(1+exp(-z))         # pass through an inv-logit function
 y = rbinom(1000,1,pr)      # bernoulli response variable

 df = data.frame(y=y,x1=x1,x2=x2)
 glm( y~x1+x2,data=df,family="binomial")
```


```
data {
  int<lower=0> N;
  vector[N] x;
  int<lower=0,upper=1> y[N];
}
parameters {
  real alpha;
  real beta;
}
model {
  y ~ bernoulli_logit(alpha + beta * x);
}
```

This also can be expanded to several predictors. Below you can find the code as well as some recommendations for making sense of priors.


```
 data {
  // response
  int N;
  int y[N];
  // covariates
  int K;
  matrix[N, K] X;
  // priors
  real alpha_loc;
  real alpha_scale;
  vector[K] beta_loc;
  vector[K] beta_scale;
}
parameters {
  real alpha;
  vector[K] beta;
}
transformed parameters {
  // linear predictor
  vector[N] eta;
  eta = alpha + X * beta;
}
model {
  alpha ~ normal(alpha_loc, alpha_scale);
  beta ~ normal(beta_loc, beta_scale);
  // y ~ bernoulli(inv_logit(eta));
  // this is faster and more numerically stable
  y ~ bernoulli_logit(eta);
}
generated quantities {
  // log-likelihood of each obs
  vector[N] log_lik;
  // probability
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = inv_logit(eta[i]);
    log_lik[i] = bernoulli_logit_lpmf(y[i] | eta[i]);
  }
}
```



### Negative Binomial 



The Poisson distribution, which posits that the variance is equal to the mean, is a popular choice for modelling count data. The data are said to be overdispersed when the variance exceeds the mean, and the Negative Binomial distribution can be utilised. Let's say we have a response variable y that has a negative binomial distribution and is influenced by a collection of k explanatory variables X, as shown in equation.

With discrete random variables, the negative binomial distribution is a probability distribution. This sort of distribution refers to the number of trials required to achieve a specific number of successes. The negative binomial distribution is related to the binomial distribution, as we will demonstrate. Furthermore, the geometric distribution is generalised by this distribution.

The negative binomial distribution has two parameters: 
The expected value that need to be positive, therefore a log link function can be used to map the linear predictor (the explanatory variables times the regression parameters) to μ and ϕ is the overdispersion parameter, a small value means a large deviation from a Poisson distribution, while as ϕ gets larger the negative binomial looks more and more like a Poisson distribution.

Let’s simulate some data and fit a STAN model to them:

```
#simulate some negative binomial data
#the explanatory variables
N<-100 #sample size
dat<-data.frame(x1=runif(N,-2,2),x2=runif(N,-2,2))
#the model
X<-model.matrix(~x1*x2,dat)
K<-dim(X)[2] #number of regression params
#the regression slopes
betas<-runif(K,-1,1)
#the overdispersion for the simulated data
phi<-5
#simulate the response
y_nb<-rnbinom(100,size=phi,mu=exp(X%*%betas))

```



```
data {
  int N; //the number of observations
  int K; //the number of columns in the model matrix
  int y[N]; //the response
  matrix[N,K] X; //the model matrix
}
parameters {
  vector[K] beta; //the regression parameters
  real phi; //the overdispersion parameters
}
transformed parameters {
  vector[N] mu;//the linear predictor
  mu <- exp(X*beta); //using the log link 
}
model {  
  beta[1] ~ cauchy(0,10); //prior for the intercept following Gelman 2008

  for(i in 2:K)
   beta[i] ~ cauchy(0,2.5);//prior for the slopes following Gelman 2008
  
  y ~ neg_binomial_2(mu,phi);
}
generated quantities {
 vector[N] y_rep;
 for(n in 1:N){
  y_rep[n] <- neg_binomial_2_rng(mu[n],phi); //posterior draws to get posterior predictive checks
 }
}

```

### Conclusion

This tutorial provided only a quick overview of how to fit logistic and negative binomial regression models with the Bayesian software STAN using the rstan library/API and to extract a collection of useful summaries from the models. Future postings will address the question of outliers and the use of robust linear models.


## References

+ [Stan Functions Reference](https://mc-stan.org/docs/2_18/functions-reference/)

+ [Stan Users Guide](https://mc-stan.org/docs/2_29/stan-users-guide/index.html#overview)

+ [Some things i've learned about stan](https://www.alexpghayes.com/blog/some-things-ive-learned-about-stan/)

+ [Stan (+R) Workshop](https://rpruim.github.io/StanWorkshop/)


+ (R Stan: First Examples)[http://blackwell.math.yorku.ca/MATH6635/files/Stan_first_examples.html]
+ https://datascienceplus.com/bayesian-regression-with-stan-beyond-normality/
+ (Simon Jackman’s Bayesian Model Examples in Stan)[https://jrnold.github.io/bugs-examples-in-stan/judges.html]
