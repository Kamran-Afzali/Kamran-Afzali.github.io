---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---


### Bayesian Regression Models for Non-Normal Data


In a previous post we saw how to perform bayesian regression in R using STAN for normally distributed data. In this post we will look at how to fit non-normal model in STAN using three example distributions commonly found in empirical data, namely binomial and negative-binomial (overdispersed poisson data). At a very high level, Bayesian models quantify (aleatory and epistemic) uncertainty, so that our predictions and decisions take into account the ways in which our knowledge is limited or imperfect. We specify a statistical model, and identify probabilistic estimates for the parameters using a family of sampling algorithms known as Markov Chain Monte Carlo (MCMC). My preferred software for writing a fitting Bayesian models is Stan. If you are not yet familiar with Bayesian statistics, then I imagine you won’t be fully satisfied with that 3 sentence summary, so I will put together a separate post on the merits and challenges of applied Bayesian inference.


### Logistic Regression

Logistic regression is used to estimate the probability of a binary outcome, such as Pass or Fail (though it can be extended for > 2 outcomes). This is achieved by transforming a standard regression using the logit function, shown below. The term in the brackets may be familiar to gamblers as it is how odds are calculated from probabilities. You may see logit and log-odds used exchangeably for this reason. Since the logit function transformed data from a probability scale, the inverse logit function transforms data to a probability scale. Therefore, it’s values range from 0 to 1, and this feature is very useful when we are interested the probability of Pass/Fail type outcomes.

Before moving on, some terminology that you may find when reading about logistic regression elsewhere:

When a linear regression is combined with a re-scaling function such as this, it is known as a Generalised Linear Model (GLM).
The re-scaling (in this case, the logit) function is known as a link function in this context.
Logistic regression is a Bernoulli-Logit GLM.

For binary outcomes, either of the closely related logistic or probit regression models may be used. 
A logistic regression model with one predictor and an intercept is coded as follows.


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



The Poisson distribution is a common choice to model count data, it assumes that the variance is equal to the mean. When the variance is larger than the mean, the data are said to be overdispersed and the Negative Binomial distribution can be used. Say we have measured a response variable y that follow a negative binomial distribution and depends on a set of k explanatory variables X, in equation this gives us.

The negative binomial distribution is a probability distribution that is used with discrete random variables. This type of distribution concerns the number of trials that must occur in order to have a predetermined number of successes.  As we will see, the negative binomial distribution is related to the binomial distribution.  In addition, this distribution generalizes the geometric distribution.

The negative binomial distribution has two parameters: 
is the expected value that need to be positive, therefore a log link function can be used to map the linear predictor (the explanatory variables times the regression parameters) to μ (see the 4th equation); and ϕ is the overdispersion parameter, a small value means a large deviation from a Poisson distribution, while as ϕ gets larger the negative binomial looks more and more like a Poisson distribution.

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
