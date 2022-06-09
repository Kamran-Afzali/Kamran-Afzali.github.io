---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

In a previous post we saw how to perform bayesian regression in R using STAN for normally distributed data. In this post we will look at how to fit non-normal model in STAN using three example distributions commonly found in empirical data: negative-binomial (overdispersed poisson data), gamma (right-skewed continuous data) and beta-binomial (overdispersed binomial data).

The STAN code for the different models is at the end of this posts together with some explanations.

Logistic regression is a popular machine learning model. One application of it in an engineering context is quantifying the effectiveness of inspection technologies at detecting damage. This post describes the additional information provided by a Bayesian application of logistic regression (and how it can be implemented using the Stan probabilistic programming language). Finally, I’ve also included some recommendations for making sense of priors.

Introductions
So there are a couple of key topics discussed here: Logistic Regression, and Bayesian Statistics. Before jumping straight into the example application, I’ve provided some very brief introductions below.

Bayesian Inference

At a very high level, Bayesian models quantify (aleatory and epistemic) uncertainty, so that our predictions and decisions take into account the ways in which our knowledge is limited or imperfect. We specify a statistical model, and identify probabilistic estimates for the parameters using a family of sampling algorithms known as Markov Chain Monte Carlo (MCMC). My preferred software for writing a fitting Bayesian models is Stan. If you are not yet familiar with Bayesian statistics, then I imagine you won’t be fully satisfied with that 3 sentence summary, so I will put together a separate post on the merits and challenges of applied Bayesian inference, which will include much more detail.

Logistic Regression

Logistic regression is used to estimate the probability of a binary outcome, such as Pass or Fail (though it can be extended for > 2 outcomes). This is achieved by transforming a standard regression using the logit function, shown below. The term in the brackets may be familiar to gamblers as it is how odds are calculated from probabilities. You may see logit and log-odds used exchangeably for this reason.


Since the logit function transformed data from a probability scale, the inverse logit function transforms data to a probability scale. Therefore, as shown in the below plot, it’s values range from 0 to 1, and this feature is very useful when we are interested the probability of Pass/Fail type outcomes.

Before moving on, some terminology that you may find when reading about logistic regression elsewhere:

When a linear regression is combined with a re-scaling function such as this, it is known as a Generalised Linear Model (GLM).
The re-scaling (in this case, the logit) function is known as a link function in this context.
Logistic regression is a Bernoulli-Logit GLM.




For binary outcomes, either of the closely related logistic or probit regression models may be used. These generalized linear models vary only in the l
A logistic regression model with one predictor and an intercept is coded as follows.

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


The noise parameter is built into the Bernoulli formulation here rather than specified directly.

Logistic regression is a kind of generalized linear model with binary outcomes and the log odds (logit) link function, defined by






The Poisson distribution is a common choice to model count data, it assumes that the variance is equal to the mean. When the variance is larger than the mean, the data are said to be overdispersed and the Negative Binomial distribution can be used. Say we have measured a response variable y that follow a negative binomial distribution and depends on a set of k explanatory variables X, in equation this gives us.

The negative binomial distribution is a probability distribution that is used with discrete random variables. This type of distribution concerns the number of trials that must occur in order to have a predetermined number of successes.  As we will see, the negative binomial distribution is related to the binomial distribution.  In addition, this distribution generalizes the geometric distribution.

The negative binomial distribution has two parameters: 
is the expected value that need to be positive, therefore a log link function can be used to map the linear predictor (the explanatory variables times the regression parameters) to μ (see the 4th equation); and ϕ is the overdispersion parameter, a small value means a large deviation from a Poisson distribution, while as ϕ gets larger the negative binomial looks more and more like a Poisson distribution.

Let’s simulate some data and fit a STAN model to them:

```
#load the libraries
library(arm) #for the invlogit function
library(emdbook) #for the rbetabinom function
library(rstan)
library(rstanarm) #for the launch_shinystan function

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

#fit the model
m_nb<-stan(file = "neg_bin.stan",data = list(N=N,K=K,X=X,y=y_nb),pars=c("beta","phi","y_rep"))

#diagnose and explore the model using shinystan
launch_shinystan(m_nb)
```

http://blackwell.math.yorku.ca/MATH6635/files/Stan_first_examples.html
https://datascienceplus.com/bayesian-regression-with-stan-beyond-normality/
https://jrnold.github.io/bugs-examples-in-stan/judges.html
