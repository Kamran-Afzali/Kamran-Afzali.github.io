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


```{r}
library(tidyverse)
library(kableExtra)
library(arm) 
library(emdbook) 
library(rstan)
library(rstanarm) 

set.seed(1234)
 x1 = rnorm(10000)           

 z = 1 + 2*x1       
 pr = 1/(1+exp(-z))         
 y = rbinom(10000,1,pr)     

 df = data.frame(y=y,x1=x1)
 

 
head(df)%>%kableExtra::kable()

   
```


```{r}
 glm( y~x1,data=df,family="binomial")%>%summary()%>%pluck(coefficients)%>%kableExtra::kable()
```





```{r}
   model_stan = "
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
   "
writeLines(model_stan, con = "model_stan.stan")
   cat(model_stan)
```

```{r}


stan_data <- list(
  N = 10000,
  x = df$x1,
  y = df$y
)

fit_rstan <- rstan::stan(
  file = "model_stan.stan",
  data = stan_data
)
```


```{r}
fit_rstan
```

This also can be expanded to several predictors. Below you can find the code as well as some recommendations for making sense of priors.



```{r}

set.seed(1234)
 x1 = rnorm(10000)           
 x2 = rnorm(10000)
 x3 = rnorm(10000)
 z = 1 + 2*x1 + 3*x2 - 1*x3       
 pr = 1/(1+exp(-z))         
 y = rbinom(10000,1,pr)     

 df2 = data.frame(y=y,x1=x1,x2=x2,x3=x3)
 

 
head(df2)%>%kableExtra::kable()

   
```



```{r}
 glm( y~x1+x2+x3,data=df2,family="binomial")%>%summary()%>%pluck(coefficients)%>%kableExtra::kable()
```



```{r}
model_stan2 ="


data {
  int<lower=0> N;   // number of observations
  int<lower=0> K;   // number of predictors
  matrix[N, K] X;   // predictor matrix
  int<lower=0,upper=1> y[N];      // outcome vector
}
parameters {
  real alpha;           // intercept
  vector[K] beta;       // coefficients for predictors
}
model {
  y ~ bernoulli_logit(alpha + X * beta); 
}

"

writeLines(model_stan2, con = "model_stan2.stan")
cat(model_stan2)
```



```{r}

predictors <- df2[,2:4]

stan_data2 <- list(
  N = 10000,
  K = 3,
  X = predictors,
  y = df2$y
)


fit_rstan2 <- rstan::stan(
  file = "model_stan2.stan",
  data = stan_data2
)

```


```{r}
fit_rstan2
```



### Negative Binomial 



The Poisson distribution, which posits that the variance is equal to the mean, is a popular choice for modelling count data. The data are said to be overdispersed when the variance exceeds the mean, and the Negative Binomial distribution can be utilised. Let's say we have a response variable y that has a negative binomial distribution and is influenced by a collection of k explanatory variables X, as shown in equation.

With discrete random variables, the negative binomial distribution is a probability distribution. This sort of distribution refers to the number of trials required to achieve a specific number of successes. The negative binomial distribution is related to the binomial distribution, as we will demonstrate. Furthermore, the geometric distribution is generalised by this distribution.

The negative binomial distribution has two parameters: 
The expected value that need to be positive, therefore a log link function can be used to map the linear predictor (the explanatory variables times the regression parameters) to μ and ϕ is the overdispersion parameter, a small value means a large deviation from a Poisson distribution, while as ϕ gets larger the negative binomial looks more and more like a Poisson distribution.

Let’s simulate some data and fit a STAN model to them:


```{r}

N<-100000
df3 <-data.frame(x1=runif(N,-2,2),x2=runif(N,-2,2))
#the model
X<-model.matrix(~x1*x2,df3)
K<-dim(X)[2] #number of regression params
#the regression slopes
betas<-runif(K,-1,1)
#the overdispersion for the simulated data
phi<-5
#simulate the response
y_nb<-rnbinom(N,size=phi,mu=exp(X%*%betas))
hist(y_nb)
```

```{r}
MASS::glm.nb(y_nb ~ X[,2:K])%>%summary()%>%pluck(coefficients)%>%kableExtra::kable()

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

```{r}
stan_mod = "data {
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
"
writeLines(stan_mod, con = "stan_mod.stan")

cat(stan_mod)
```

```{r}

stan_data3 <- list(
  N = N,
  K = K,
  X = X,
  y = y_nb
)


```

```{r}


fit_rstan3 <- rstan::stan(
  file = "stan_mod.stan",
  data = stan_data3
)

```
```{r}
fit_rstan3%>%summary()
```



### Conclusion

This tutorial provided only a quick overview of how to fit logistic and negative binomial regression models with the Bayesian software STAN using the rstan library/API and to extract a collection of useful summaries from the models. Future postings will address the question of outliers and the use of robust linear models.


## References

+ [Stan Functions Reference](https://mc-stan.org/docs/2_18/functions-reference/)

+ [Stan Users Guide](https://mc-stan.org/docs/2_29/stan-users-guide/index.html#overview)

+ [Some things i've learned about stan](https://www.alexpghayes.com/blog/some-things-ive-learned-about-stan/)

+ [Stan (+R) Workshop](https://rpruim.github.io/StanWorkshop/)


+ [R Stan: First Examples](http://blackwell.math.yorku.ca/MATH6635/files/Stan_first_examples.html)
+ https://datascienceplus.com/bayesian-regression-with-stan-beyond-normality/
+ [Simon Jackman’s Bayesian Model Examples in Stan](https://jrnold.github.io/bugs-examples-in-stan/judges.html)
