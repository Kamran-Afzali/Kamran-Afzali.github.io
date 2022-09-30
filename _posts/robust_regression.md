---
layout: post
categories: posts
title: Bayesian Robust t-regression for Non-Normal residuals
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: September 2022
---


## Robust t-regression 




### Motivation

Simple linear regression is a widely used method for estimating the linear relation between two (or more) variables and for predicting the value of one variable (the response variable) based on the value of the other (the explanatory variable). The explanatory variable is typically represented on the x-axis and the response variable on the y-axis for visualising the results of linear regression.

The regression coefficients can be distorted by outlying data points. Due to the normality assumption used by traditional regression techniques, noisy or outlier data can greatly affect their accuracy. Since the normal distribution must move to a new place in the parameter space to best accommodate the outliers in the data, this frequently leads to an underestimate of the relationship between the variables. In a frequentist framework, creating a linear regression model that is resistant to outliers necessitates the use of very complex statistical techniques; however, in a Bayesian framework, we can achieve robustness by simply using the t-distribution. in this context, **Robust Regression** refers to regression methods which are less sensitive to outliers. Bayesian robust regression uses distributions with wider tails than the normal. This means that outliers will have less of an affect on the models and the regression line would need to move less incorporate those observations since the error distribution will not consider them as unusual.


Utilizing Student's t density with an unidentified degrees of freedom parameter is a well-liked substitution for normal errors in regression investigations. The Student's t distribution has heavier tails than the normal for low degrees of freedom, but it leans toward the normal as the degrees of freedom parameter rises. A check on the suitability of the normal is thus made possible by treating the degrees of freedom parameter as an unknown quantity that must be approximated. The degrees of freedom, or parameter ν, of this probability distribution determines how close to normal the distribution is: Low small values of produce a distribution with thicker tails (that is, a greater spread around the mean) than the normal distribution, but big values of (approximately > 30) give a distribution that is quite similar to the normal distribution. As a result, we can allow the distribution of the regression line to be as normal or non-normal as the data imply while still capturing the underlying relationship between the variables by substituting the normal distribution above with a t-distribution and adding as an extra parameter to the model.


### Concepts and code

The standard approach to linear regression is defining the equation for a straight line that represents the relationship between the variables as accurately as possible. The equation for the line defines y (the response variable) as a linear function of x (the explanatory variable):

<p align="center">  𝑦 = 𝛼 + 𝛽𝑥 + 𝜀</p>

In this equation, ε represents the error in the linear relationship: if no noise were allowed, then the paired x- and y-values would need to be arranged in a perfect straight line (for example, as in y = 2x + 1). Because we assume that the relationship between x and y is truly linear, any variation observed around the regression line must be random noise, and therefore normally distributed. From a probabilistic standpoint, such relationship between the variables could be formalised as

<p align="center"> 𝑦 ~ 𝓝(𝛼 + 𝛽𝑥, 𝜎)</p>

That is, the response variable follows a normal distribution with mean equal to the regression line, and some standard deviation σ. Such a probability distribution of the regression line is illustrated in the figure below.

The formulation of the robust simple linear regression Bayesian model is given below. We define a t likelihood for the response variable, y, and suitable vague priors on all the model parameters: normal for α and β, half-normal for σ and gamma for ν.

<p align="center"> 𝑦 ~ 𝓣(𝛼 + 𝛽𝑥, 𝜎, 𝜈) </p> 
<p align="center"> 𝛼, 𝛽 ~ 𝓝(0, 1000) </p> 
<p align="center"> 𝜎 ~ 𝓗𝓝(0, 1000) </p> 
<p align="center"> 𝜈 ~ 𝚪(2, 0.1) </p>

Below you can find R and Stan code for a simple Bayesian t-regression model with nu unknown.

First let's create data with and without ourliers

```r
library(readr)
library(tidyverse)
library(gridExtra)
library(kableExtra)
library(arm) 
library(emdbook) 
library(rstan)
library(rstanarm) 
library(brms) 
```

```r
s <- matrix(c(1, .8, 
              .8, 1), 
            nrow = 2, ncol = 2)
m <- c(3, 3)
set.seed(1234)

data_n <- MASS::mvrnorm(n = 100, mu = m, Sigma = s) %>%
  as_tibble() %>%
  rename(y = V1, x = V2)
```



```r
data_n <-
  data_n %>%
  arrange(x)

head(data_n)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> y </th>
   <th style="text-align:right;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.9335732 </td>
   <td style="text-align:right;"> 0.6157783 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.0317982 </td>
   <td style="text-align:right;"> 0.8318674 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.9763140 </td>
   <td style="text-align:right;"> 0.9326985 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.3439117 </td>
   <td style="text-align:right;"> 1.1117327 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.4059413 </td>
   <td style="text-align:right;"> 1.1673553 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.0360302 </td>
   <td style="text-align:right;"> 1.3253002 </td>
  </tr>
</tbody>
</table>

```r
data_o <- data_n
data_o[c(1:2), 1] <- c(7.5, 8.5)

head(data_o)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> y </th>
   <th style="text-align:right;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 7.500000 </td>
   <td style="text-align:right;"> 0.6157783 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 8.500000 </td>
   <td style="text-align:right;"> 0.8318674 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.976314 </td>
   <td style="text-align:right;"> 0.9326985 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.343912 </td>
   <td style="text-align:right;"> 1.1117327 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 1.405941 </td>
   <td style="text-align:right;"> 1.1673553 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2.036030 </td>
   <td style="text-align:right;"> 1.3253002 </td>
  </tr>
</tbody>
</table>

```r
ols_n <- lm(data = data_n, y ~ 1 + x)
ols_o <- lm(data = data_o, y ~ 1 + x)


p1 <-
  ggplot(data = data_n, aes(x = x, y = y)) +
  stat_smooth(method = "lm", color = "grey92", fill = "grey67", alpha = 1, fullrange = T) +
  geom_point(size = 1, alpha = 3/4) +
  scale_x_continuous(limits = c(0, 9)) +
  coord_cartesian(xlim = c(0, 9), 
                  ylim = c(0, 9)) +
  labs(title = "No Outliers") +
  theme(panel.grid = element_blank())

# the data with two outliers
p2 <-
  ggplot(data = data_o, aes(x = x, y = y, color = y > 7)) +
  stat_smooth(method = "lm", color = "grey92", fill = "grey67", alpha = 1, fullrange = T) +
  geom_point(size = 1, alpha = 3/4) +
  scale_color_viridis_d(option = "A", end = 4/7) +
  scale_x_continuous(limits = c(0, 9)) +
  coord_cartesian(xlim = c(0, 9), 
                  ylim = c(0, 9)) +
  labs(title = "Two Outliers") +
  theme(panel.grid = element_blank(),
        legend.position = "none")
grid.arrange(p1 ,p2)
```

```
## `geom_smooth()` using formula 'y ~ x'
```

```
## `geom_smooth()` using formula 'y ~ x'
```

![](/images/RobReg-1-1.png)



```r
model_stan = "
   data {
    int<lower=1> N;    
    int<lower=0> M;    
    int<lower=0> P;    
    vector[N] x;       
    vector[N] y;       
    vector[M] x_cred;  
    vector[P] x_pred;  
}

parameters {
    real alpha;           
    real beta;            
    real<lower=0> sigma;  
    real<lower=1> nu;     
}

transformed parameters {
    vector[N] mu = alpha + beta * x;            
    vector[M] mu_cred = alpha + beta * x_cred;  
    vector[P] mu_pred = alpha + beta * x_pred;  
}

model {
    y ~ student_t(nu, mu, sigma);
    alpha ~ normal(0, 1000);
    beta ~ normal(0, 1000);
    sigma ~ normal(0, 1000);
    nu ~ gamma(2, 0.1);
}

generated quantities {
    real y_pred[P];
    for (p in 1:P) {
        y_pred[p] = student_t_rng(nu, mu_pred[p], sigma);
    }
}
   "
writeLines(model_stan, con = "model_stan.stan")
   cat(model_stan)
```

```
## 
##    data {
##     int<lower=1> N;    
##     int<lower=0> M;    
##     int<lower=0> P;    
##     vector[N] x;       
##     vector[N] y;       
##     vector[M] x_cred;  
##     vector[P] x_pred;  
## }
## 
## parameters {
##     real alpha;           
##     real beta;            
##     real<lower=0> sigma;  
##     real<lower=1> nu;     
## }
## 
## transformed parameters {
##     vector[N] mu = alpha + beta * x;            
##     vector[M] mu_cred = alpha + beta * x_cred;  
##     vector[P] mu_pred = alpha + beta * x_pred;  
## }
## 
## model {
##     y ~ student_t(nu, mu, sigma);
##     alpha ~ normal(0, 1000);
##     beta ~ normal(0, 1000);
##     sigma ~ normal(0, 1000);
##     nu ~ gamma(2, 0.1);
## }
## 
## generated quantities {
##     real y_pred[P];
##     for (p in 1:P) {
##         y_pred[p] = student_t_rng(nu, mu_pred[p], sigma);
##     }
## }
## 
```



```r
stan_data <- list(x=data_o$x,
     y=data_o$y,
     N=length(data_o$y),
     M=0, P=0, x_cred=numeric(0), x_pred=numeric(0))



fit_rstan <- rstan::stan(
  file = "model_stan.stan",
  data = stan_data
)
```

```
## Trying to compile a simple C file
```

```
## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:88:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
## namespace Eigen {
## ^
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
## namespace Eigen {
##                ^
##                ;
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
## #include <complex>
##          ^~~~~~~~~
## 3 errors generated.
## make: *** [foo.o] Error 1
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 3.9e-05 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.39 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.114 seconds (Warm-up)
## Chain 1:                0.122 seconds (Sampling)
## Chain 1:                0.236 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 1.3e-05 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.13 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.126 seconds (Warm-up)
## Chain 2:                0.11 seconds (Sampling)
## Chain 2:                0.236 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 9e-06 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.09 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.122 seconds (Warm-up)
## Chain 3:                0.111 seconds (Sampling)
## Chain 3:                0.233 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 1.1e-05 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.11 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.134 seconds (Warm-up)
## Chain 4:                0.113 seconds (Sampling)
## Chain 4:                0.247 seconds (Total)
## Chain 4:
```


```r
trace <- stan_trace(fit_rstan, pars=c("alpha", "beta", "sigma", "nu"))
trace + scale_color_brewer(type = "div") + theme(legend.position = "none")
```

```
## Scale for 'colour' is already present. Adding another scale for 'colour',
## which will replace the existing scale.
```

![](/images/RobReg-4-1.png)


```r
stan_dens(fit_rstan, pars=c("alpha", "beta", "sigma", "nu"), fill = "skyblue")
```

![](/images/RobReg-5-1.png)


```r
stan_plot(fit_rstan, pars=c("alpha", "beta", "sigma", "nu"), show_density = TRUE, fill_color = "maroon")
```

```
## ci_level: 0.8 (80% intervals)
```

```
## outer_level: 0.95 (95% intervals)
```

![](/images/RobReg-6-1.png)

Bayesian regression models can be used to estimate highest posterior density  or credible intervals (intervals of the distribution of the regression linefor), and prediction values, through predictive posterior distributions. More specifically, the prediction intervals are obtained by first drawing samples of the mean response at specific x-values of interest and then, for each of these samples, randomly selecting a y-value from a t-distribution with location mu pred. In contrast, the credible intervals are obtained by drawing MCMC samples of the mean response at regularly spaced points along the x-axis. The distributions of mu cred and y pred are represented, respectively, by the credible and prediction intervals.



```r
x.cred = seq(from=min(data_o$x),
             to=max(data_o$x),
             length.out=50)


x.pred = c(0, 8)
```


```r
stan_data2 <- list(x=data_o$x,
                  y=data_o$y,
                  N=length(data_o$y),
                  x_cred=x.cred,
                  x_pred=x.pred,
                  M=length(x.cred),
                  P=length(x.pred))
```


```r
fit_rstan2 <- rstan::stan(
  file = "model_stan.stan",
  data = stan_data2
)
```

```
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 2.6e-05 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.26 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.157 seconds (Warm-up)
## Chain 1:                0.134 seconds (Sampling)
## Chain 1:                0.291 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 1e-05 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.1 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.148 seconds (Warm-up)
## Chain 2:                0.101 seconds (Sampling)
## Chain 2:                0.249 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 1.4e-05 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.14 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.165 seconds (Warm-up)
## Chain 3:                0.132 seconds (Sampling)
## Chain 3:                0.297 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 1.2e-05 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.12 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.151 seconds (Warm-up)
## Chain 4:                0.145 seconds (Sampling)
## Chain 4:                0.296 seconds (Total)
## Chain 4:
```

For each value in x.cred, the mu cred parameter's MCMC samples are contained in a separate column of mu.cred. In a similar manner, the columns of y.pred include the MCMC samples of the posterior expected response values (y pred values) for the x-values in x.pred. 



```r
summary(extract(fit_rstan2, "mu_cred")[[1]])%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;">       V1 </th>
   <th style="text-align:left;">       V2 </th>
   <th style="text-align:left;">       V3 </th>
   <th style="text-align:left;">       V4 </th>
   <th style="text-align:left;">       V5 </th>
   <th style="text-align:left;">       V6 </th>
   <th style="text-align:left;">       V7 </th>
   <th style="text-align:left;">       V8 </th>
   <th style="text-align:left;">       V9 </th>
   <th style="text-align:left;">      V10 </th>
   <th style="text-align:left;">      V11 </th>
   <th style="text-align:left;">      V12 </th>
   <th style="text-align:left;">      V13 </th>
   <th style="text-align:left;">      V14 </th>
   <th style="text-align:left;">      V15 </th>
   <th style="text-align:left;">      V16 </th>
   <th style="text-align:left;">      V17 </th>
   <th style="text-align:left;">      V18 </th>
   <th style="text-align:left;">      V19 </th>
   <th style="text-align:left;">      V20 </th>
   <th style="text-align:left;">      V21 </th>
   <th style="text-align:left;">      V22 </th>
   <th style="text-align:left;">      V23 </th>
   <th style="text-align:left;">      V24 </th>
   <th style="text-align:left;">      V25 </th>
   <th style="text-align:left;">      V26 </th>
   <th style="text-align:left;">      V27 </th>
   <th style="text-align:left;">      V28 </th>
   <th style="text-align:left;">      V29 </th>
   <th style="text-align:left;">      V30 </th>
   <th style="text-align:left;">      V31 </th>
   <th style="text-align:left;">      V32 </th>
   <th style="text-align:left;">      V33 </th>
   <th style="text-align:left;">      V34 </th>
   <th style="text-align:left;">      V35 </th>
   <th style="text-align:left;">      V36 </th>
   <th style="text-align:left;">      V37 </th>
   <th style="text-align:left;">      V38 </th>
   <th style="text-align:left;">      V39 </th>
   <th style="text-align:left;">      V40 </th>
   <th style="text-align:left;">      V41 </th>
   <th style="text-align:left;">      V42 </th>
   <th style="text-align:left;">      V43 </th>
   <th style="text-align:left;">      V44 </th>
   <th style="text-align:left;">      V45 </th>
   <th style="text-align:left;">      V46 </th>
   <th style="text-align:left;">      V47 </th>
   <th style="text-align:left;">      V48 </th>
   <th style="text-align:left;">      V49 </th>
   <th style="text-align:left;">      V50 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Min.   :0.4535 </td>
   <td style="text-align:left;"> Min.   :0.553 </td>
   <td style="text-align:left;"> Min.   :0.6525 </td>
   <td style="text-align:left;"> Min.   :0.752 </td>
   <td style="text-align:left;"> Min.   :0.8515 </td>
   <td style="text-align:left;"> Min.   :0.951 </td>
   <td style="text-align:left;"> Min.   :1.051 </td>
   <td style="text-align:left;"> Min.   :1.150 </td>
   <td style="text-align:left;"> Min.   :1.250 </td>
   <td style="text-align:left;"> Min.   :1.349 </td>
   <td style="text-align:left;"> Min.   :1.449 </td>
   <td style="text-align:left;"> Min.   :1.548 </td>
   <td style="text-align:left;"> Min.   :1.642 </td>
   <td style="text-align:left;"> Min.   :1.734 </td>
   <td style="text-align:left;"> Min.   :1.826 </td>
   <td style="text-align:left;"> Min.   :1.918 </td>
   <td style="text-align:left;"> Min.   :2.010 </td>
   <td style="text-align:left;"> Min.   :2.102 </td>
   <td style="text-align:left;"> Min.   :2.194 </td>
   <td style="text-align:left;"> Min.   :2.285 </td>
   <td style="text-align:left;"> Min.   :2.377 </td>
   <td style="text-align:left;"> Min.   :2.458 </td>
   <td style="text-align:left;"> Min.   :2.531 </td>
   <td style="text-align:left;"> Min.   :2.603 </td>
   <td style="text-align:left;"> Min.   :2.675 </td>
   <td style="text-align:left;"> Min.   :2.747 </td>
   <td style="text-align:left;"> Min.   :2.820 </td>
   <td style="text-align:left;"> Min.   :2.892 </td>
   <td style="text-align:left;"> Min.   :2.964 </td>
   <td style="text-align:left;"> Min.   :3.037 </td>
   <td style="text-align:left;"> Min.   :3.109 </td>
   <td style="text-align:left;"> Min.   :3.181 </td>
   <td style="text-align:left;"> Min.   :3.245 </td>
   <td style="text-align:left;"> Min.   :3.297 </td>
   <td style="text-align:left;"> Min.   :3.349 </td>
   <td style="text-align:left;"> Min.   :3.401 </td>
   <td style="text-align:left;"> Min.   :3.453 </td>
   <td style="text-align:left;"> Min.   :3.505 </td>
   <td style="text-align:left;"> Min.   :3.557 </td>
   <td style="text-align:left;"> Min.   :3.609 </td>
   <td style="text-align:left;"> Min.   :3.661 </td>
   <td style="text-align:left;"> Min.   :3.713 </td>
   <td style="text-align:left;"> Min.   :3.765 </td>
   <td style="text-align:left;"> Min.   :3.817 </td>
   <td style="text-align:left;"> Min.   :3.869 </td>
   <td style="text-align:left;"> Min.   :3.921 </td>
   <td style="text-align:left;"> Min.   :3.973 </td>
   <td style="text-align:left;"> Min.   :4.025 </td>
   <td style="text-align:left;"> Min.   :4.077 </td>
   <td style="text-align:left;"> Min.   :4.129 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1st Qu.:0.9464 </td>
   <td style="text-align:left;"> 1st Qu.:1.029 </td>
   <td style="text-align:left;"> 1st Qu.:1.1113 </td>
   <td style="text-align:left;"> 1st Qu.:1.193 </td>
   <td style="text-align:left;"> 1st Qu.:1.2762 </td>
   <td style="text-align:left;"> 1st Qu.:1.359 </td>
   <td style="text-align:left;"> 1st Qu.:1.441 </td>
   <td style="text-align:left;"> 1st Qu.:1.524 </td>
   <td style="text-align:left;"> 1st Qu.:1.605 </td>
   <td style="text-align:left;"> 1st Qu.:1.688 </td>
   <td style="text-align:left;"> 1st Qu.:1.769 </td>
   <td style="text-align:left;"> 1st Qu.:1.851 </td>
   <td style="text-align:left;"> 1st Qu.:1.931 </td>
   <td style="text-align:left;"> 1st Qu.:2.012 </td>
   <td style="text-align:left;"> 1st Qu.:2.093 </td>
   <td style="text-align:left;"> 1st Qu.:2.174 </td>
   <td style="text-align:left;"> 1st Qu.:2.254 </td>
   <td style="text-align:left;"> 1st Qu.:2.335 </td>
   <td style="text-align:left;"> 1st Qu.:2.415 </td>
   <td style="text-align:left;"> 1st Qu.:2.495 </td>
   <td style="text-align:left;"> 1st Qu.:2.574 </td>
   <td style="text-align:left;"> 1st Qu.:2.654 </td>
   <td style="text-align:left;"> 1st Qu.:2.733 </td>
   <td style="text-align:left;"> 1st Qu.:2.810 </td>
   <td style="text-align:left;"> 1st Qu.:2.888 </td>
   <td style="text-align:left;"> 1st Qu.:2.966 </td>
   <td style="text-align:left;"> 1st Qu.:3.043 </td>
   <td style="text-align:left;"> 1st Qu.:3.119 </td>
   <td style="text-align:left;"> 1st Qu.:3.195 </td>
   <td style="text-align:left;"> 1st Qu.:3.270 </td>
   <td style="text-align:left;"> 1st Qu.:3.344 </td>
   <td style="text-align:left;"> 1st Qu.:3.419 </td>
   <td style="text-align:left;"> 1st Qu.:3.493 </td>
   <td style="text-align:left;"> 1st Qu.:3.569 </td>
   <td style="text-align:left;"> 1st Qu.:3.644 </td>
   <td style="text-align:left;"> 1st Qu.:3.717 </td>
   <td style="text-align:left;"> 1st Qu.:3.792 </td>
   <td style="text-align:left;"> 1st Qu.:3.867 </td>
   <td style="text-align:left;"> 1st Qu.:3.942 </td>
   <td style="text-align:left;"> 1st Qu.:4.015 </td>
   <td style="text-align:left;"> 1st Qu.:4.089 </td>
   <td style="text-align:left;"> 1st Qu.:4.163 </td>
   <td style="text-align:left;"> 1st Qu.:4.237 </td>
   <td style="text-align:left;"> 1st Qu.:4.311 </td>
   <td style="text-align:left;"> 1st Qu.:4.386 </td>
   <td style="text-align:left;"> 1st Qu.:4.460 </td>
   <td style="text-align:left;"> 1st Qu.:4.534 </td>
   <td style="text-align:left;"> 1st Qu.:4.608 </td>
   <td style="text-align:left;"> 1st Qu.:4.681 </td>
   <td style="text-align:left;"> 1st Qu.:4.753 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Median :1.0605 </td>
   <td style="text-align:left;"> Median :1.138 </td>
   <td style="text-align:left;"> Median :1.2165 </td>
   <td style="text-align:left;"> Median :1.295 </td>
   <td style="text-align:left;"> Median :1.3724 </td>
   <td style="text-align:left;"> Median :1.450 </td>
   <td style="text-align:left;"> Median :1.528 </td>
   <td style="text-align:left;"> Median :1.606 </td>
   <td style="text-align:left;"> Median :1.684 </td>
   <td style="text-align:left;"> Median :1.762 </td>
   <td style="text-align:left;"> Median :1.840 </td>
   <td style="text-align:left;"> Median :1.918 </td>
   <td style="text-align:left;"> Median :1.996 </td>
   <td style="text-align:left;"> Median :2.074 </td>
   <td style="text-align:left;"> Median :2.152 </td>
   <td style="text-align:left;"> Median :2.230 </td>
   <td style="text-align:left;"> Median :2.308 </td>
   <td style="text-align:left;"> Median :2.386 </td>
   <td style="text-align:left;"> Median :2.463 </td>
   <td style="text-align:left;"> Median :2.542 </td>
   <td style="text-align:left;"> Median :2.619 </td>
   <td style="text-align:left;"> Median :2.698 </td>
   <td style="text-align:left;"> Median :2.775 </td>
   <td style="text-align:left;"> Median :2.853 </td>
   <td style="text-align:left;"> Median :2.931 </td>
   <td style="text-align:left;"> Median :3.010 </td>
   <td style="text-align:left;"> Median :3.087 </td>
   <td style="text-align:left;"> Median :3.165 </td>
   <td style="text-align:left;"> Median :3.243 </td>
   <td style="text-align:left;"> Median :3.322 </td>
   <td style="text-align:left;"> Median :3.400 </td>
   <td style="text-align:left;"> Median :3.478 </td>
   <td style="text-align:left;"> Median :3.557 </td>
   <td style="text-align:left;"> Median :3.634 </td>
   <td style="text-align:left;"> Median :3.713 </td>
   <td style="text-align:left;"> Median :3.790 </td>
   <td style="text-align:left;"> Median :3.868 </td>
   <td style="text-align:left;"> Median :3.947 </td>
   <td style="text-align:left;"> Median :4.024 </td>
   <td style="text-align:left;"> Median :4.102 </td>
   <td style="text-align:left;"> Median :4.180 </td>
   <td style="text-align:left;"> Median :4.257 </td>
   <td style="text-align:left;"> Median :4.335 </td>
   <td style="text-align:left;"> Median :4.413 </td>
   <td style="text-align:left;"> Median :4.491 </td>
   <td style="text-align:left;"> Median :4.569 </td>
   <td style="text-align:left;"> Median :4.647 </td>
   <td style="text-align:left;"> Median :4.726 </td>
   <td style="text-align:left;"> Median :4.803 </td>
   <td style="text-align:left;"> Median :4.881 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Mean   :1.0605 </td>
   <td style="text-align:left;"> Mean   :1.138 </td>
   <td style="text-align:left;"> Mean   :1.2164 </td>
   <td style="text-align:left;"> Mean   :1.294 </td>
   <td style="text-align:left;"> Mean   :1.3723 </td>
   <td style="text-align:left;"> Mean   :1.450 </td>
   <td style="text-align:left;"> Mean   :1.528 </td>
   <td style="text-align:left;"> Mean   :1.606 </td>
   <td style="text-align:left;"> Mean   :1.684 </td>
   <td style="text-align:left;"> Mean   :1.762 </td>
   <td style="text-align:left;"> Mean   :1.840 </td>
   <td style="text-align:left;"> Mean   :1.918 </td>
   <td style="text-align:left;"> Mean   :1.996 </td>
   <td style="text-align:left;"> Mean   :2.074 </td>
   <td style="text-align:left;"> Mean   :2.152 </td>
   <td style="text-align:left;"> Mean   :2.230 </td>
   <td style="text-align:left;"> Mean   :2.308 </td>
   <td style="text-align:left;"> Mean   :2.386 </td>
   <td style="text-align:left;"> Mean   :2.464 </td>
   <td style="text-align:left;"> Mean   :2.542 </td>
   <td style="text-align:left;"> Mean   :2.619 </td>
   <td style="text-align:left;"> Mean   :2.697 </td>
   <td style="text-align:left;"> Mean   :2.775 </td>
   <td style="text-align:left;"> Mean   :2.853 </td>
   <td style="text-align:left;"> Mean   :2.931 </td>
   <td style="text-align:left;"> Mean   :3.009 </td>
   <td style="text-align:left;"> Mean   :3.087 </td>
   <td style="text-align:left;"> Mean   :3.165 </td>
   <td style="text-align:left;"> Mean   :3.243 </td>
   <td style="text-align:left;"> Mean   :3.321 </td>
   <td style="text-align:left;"> Mean   :3.399 </td>
   <td style="text-align:left;"> Mean   :3.477 </td>
   <td style="text-align:left;"> Mean   :3.555 </td>
   <td style="text-align:left;"> Mean   :3.633 </td>
   <td style="text-align:left;"> Mean   :3.711 </td>
   <td style="text-align:left;"> Mean   :3.789 </td>
   <td style="text-align:left;"> Mean   :3.867 </td>
   <td style="text-align:left;"> Mean   :3.945 </td>
   <td style="text-align:left;"> Mean   :4.023 </td>
   <td style="text-align:left;"> Mean   :4.101 </td>
   <td style="text-align:left;"> Mean   :4.178 </td>
   <td style="text-align:left;"> Mean   :4.256 </td>
   <td style="text-align:left;"> Mean   :4.334 </td>
   <td style="text-align:left;"> Mean   :4.412 </td>
   <td style="text-align:left;"> Mean   :4.490 </td>
   <td style="text-align:left;"> Mean   :4.568 </td>
   <td style="text-align:left;"> Mean   :4.646 </td>
   <td style="text-align:left;"> Mean   :4.724 </td>
   <td style="text-align:left;"> Mean   :4.802 </td>
   <td style="text-align:left;"> Mean   :4.880 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3rd Qu.:1.1739 </td>
   <td style="text-align:left;"> 3rd Qu.:1.247 </td>
   <td style="text-align:left;"> 3rd Qu.:1.3213 </td>
   <td style="text-align:left;"> 3rd Qu.:1.394 </td>
   <td style="text-align:left;"> 3rd Qu.:1.4688 </td>
   <td style="text-align:left;"> 3rd Qu.:1.543 </td>
   <td style="text-align:left;"> 3rd Qu.:1.616 </td>
   <td style="text-align:left;"> 3rd Qu.:1.691 </td>
   <td style="text-align:left;"> 3rd Qu.:1.766 </td>
   <td style="text-align:left;"> 3rd Qu.:1.840 </td>
   <td style="text-align:left;"> 3rd Qu.:1.915 </td>
   <td style="text-align:left;"> 3rd Qu.:1.989 </td>
   <td style="text-align:left;"> 3rd Qu.:2.063 </td>
   <td style="text-align:left;"> 3rd Qu.:2.137 </td>
   <td style="text-align:left;"> 3rd Qu.:2.212 </td>
   <td style="text-align:left;"> 3rd Qu.:2.286 </td>
   <td style="text-align:left;"> 3rd Qu.:2.362 </td>
   <td style="text-align:left;"> 3rd Qu.:2.436 </td>
   <td style="text-align:left;"> 3rd Qu.:2.512 </td>
   <td style="text-align:left;"> 3rd Qu.:2.587 </td>
   <td style="text-align:left;"> 3rd Qu.:2.663 </td>
   <td style="text-align:left;"> 3rd Qu.:2.740 </td>
   <td style="text-align:left;"> 3rd Qu.:2.817 </td>
   <td style="text-align:left;"> 3rd Qu.:2.895 </td>
   <td style="text-align:left;"> 3rd Qu.:2.973 </td>
   <td style="text-align:left;"> 3rd Qu.:3.052 </td>
   <td style="text-align:left;"> 3rd Qu.:3.132 </td>
   <td style="text-align:left;"> 3rd Qu.:3.212 </td>
   <td style="text-align:left;"> 3rd Qu.:3.292 </td>
   <td style="text-align:left;"> 3rd Qu.:3.372 </td>
   <td style="text-align:left;"> 3rd Qu.:3.453 </td>
   <td style="text-align:left;"> 3rd Qu.:3.535 </td>
   <td style="text-align:left;"> 3rd Qu.:3.616 </td>
   <td style="text-align:left;"> 3rd Qu.:3.698 </td>
   <td style="text-align:left;"> 3rd Qu.:3.779 </td>
   <td style="text-align:left;"> 3rd Qu.:3.861 </td>
   <td style="text-align:left;"> 3rd Qu.:3.943 </td>
   <td style="text-align:left;"> 3rd Qu.:4.025 </td>
   <td style="text-align:left;"> 3rd Qu.:4.107 </td>
   <td style="text-align:left;"> 3rd Qu.:4.189 </td>
   <td style="text-align:left;"> 3rd Qu.:4.271 </td>
   <td style="text-align:left;"> 3rd Qu.:4.353 </td>
   <td style="text-align:left;"> 3rd Qu.:4.436 </td>
   <td style="text-align:left;"> 3rd Qu.:4.518 </td>
   <td style="text-align:left;"> 3rd Qu.:4.600 </td>
   <td style="text-align:left;"> 3rd Qu.:4.682 </td>
   <td style="text-align:left;"> 3rd Qu.:4.765 </td>
   <td style="text-align:left;"> 3rd Qu.:4.847 </td>
   <td style="text-align:left;"> 3rd Qu.:4.929 </td>
   <td style="text-align:left;"> 3rd Qu.:5.012 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Max.   :1.6368 </td>
   <td style="text-align:left;"> Max.   :1.697 </td>
   <td style="text-align:left;"> Max.   :1.7566 </td>
   <td style="text-align:left;"> Max.   :1.817 </td>
   <td style="text-align:left;"> Max.   :1.8764 </td>
   <td style="text-align:left;"> Max.   :1.936 </td>
   <td style="text-align:left;"> Max.   :1.996 </td>
   <td style="text-align:left;"> Max.   :2.056 </td>
   <td style="text-align:left;"> Max.   :2.116 </td>
   <td style="text-align:left;"> Max.   :2.176 </td>
   <td style="text-align:left;"> Max.   :2.236 </td>
   <td style="text-align:left;"> Max.   :2.296 </td>
   <td style="text-align:left;"> Max.   :2.356 </td>
   <td style="text-align:left;"> Max.   :2.416 </td>
   <td style="text-align:left;"> Max.   :2.475 </td>
   <td style="text-align:left;"> Max.   :2.535 </td>
   <td style="text-align:left;"> Max.   :2.595 </td>
   <td style="text-align:left;"> Max.   :2.655 </td>
   <td style="text-align:left;"> Max.   :2.729 </td>
   <td style="text-align:left;"> Max.   :2.811 </td>
   <td style="text-align:left;"> Max.   :2.893 </td>
   <td style="text-align:left;"> Max.   :2.974 </td>
   <td style="text-align:left;"> Max.   :3.056 </td>
   <td style="text-align:left;"> Max.   :3.138 </td>
   <td style="text-align:left;"> Max.   :3.220 </td>
   <td style="text-align:left;"> Max.   :3.301 </td>
   <td style="text-align:left;"> Max.   :3.383 </td>
   <td style="text-align:left;"> Max.   :3.465 </td>
   <td style="text-align:left;"> Max.   :3.547 </td>
   <td style="text-align:left;"> Max.   :3.628 </td>
   <td style="text-align:left;"> Max.   :3.710 </td>
   <td style="text-align:left;"> Max.   :3.792 </td>
   <td style="text-align:left;"> Max.   :3.874 </td>
   <td style="text-align:left;"> Max.   :3.955 </td>
   <td style="text-align:left;"> Max.   :4.037 </td>
   <td style="text-align:left;"> Max.   :4.123 </td>
   <td style="text-align:left;"> Max.   :4.222 </td>
   <td style="text-align:left;"> Max.   :4.321 </td>
   <td style="text-align:left;"> Max.   :4.420 </td>
   <td style="text-align:left;"> Max.   :4.520 </td>
   <td style="text-align:left;"> Max.   :4.619 </td>
   <td style="text-align:left;"> Max.   :4.718 </td>
   <td style="text-align:left;"> Max.   :4.818 </td>
   <td style="text-align:left;"> Max.   :4.917 </td>
   <td style="text-align:left;"> Max.   :5.016 </td>
   <td style="text-align:left;"> Max.   :5.116 </td>
   <td style="text-align:left;"> Max.   :5.215 </td>
   <td style="text-align:left;"> Max.   :5.314 </td>
   <td style="text-align:left;"> Max.   :5.414 </td>
   <td style="text-align:left;"> Max.   :5.513 </td>
  </tr>
</tbody>
</table>


```r
summary(extract(fit_rstan2, "y_pred")[[1]])%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:left;">       V1 </th>
   <th style="text-align:left;">       V2 </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Min.   :-36.0432 </td>
   <td style="text-align:left;"> Min.   :-7.818 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 1st Qu.:  0.1482 </td>
   <td style="text-align:left;"> 1st Qu.: 6.466 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Median :  0.5704 </td>
   <td style="text-align:left;"> Median : 6.954 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Mean   :  0.5951 </td>
   <td style="text-align:left;"> Mean   : 6.946 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> 3rd Qu.:  1.0130 </td>
   <td style="text-align:left;"> 3rd Qu.: 7.431 </td>
  </tr>
  <tr>
   <td style="text-align:left;">  </td>
   <td style="text-align:left;"> Max.   : 19.3150 </td>
   <td style="text-align:left;"> Max.   :23.107 </td>
  </tr>
</tbody>
</table>



These models can be also etimated through *brms* package's API for Stan as follows


```r
M_gaussian <- 
  brm(data = data_o, 
      family = gaussian,
      y ~ 1 + x,
      prior = c(prior(normal(0, 10), class = Intercept),
                prior(normal(0, 10), class = b),
                prior(cauchy(0, 1),  class = sigma)),
      seed = 1)
```



```
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 2.3e-05 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 0.23 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.02 seconds (Warm-up)
## Chain 1:                0.019 seconds (Sampling)
## Chain 1:                0.039 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 5e-06 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.05 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.019 seconds (Warm-up)
## Chain 2:                0.016 seconds (Sampling)
## Chain 2:                0.035 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 5e-06 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.05 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.019 seconds (Warm-up)
## Chain 3:                0.016 seconds (Sampling)
## Chain 3:                0.035 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 4e-06 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.04 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.019 seconds (Warm-up)
## Chain 4:                0.018 seconds (Sampling)
## Chain 4:                0.037 seconds (Total)
## Chain 4:
```




```r
summary(M_gaussian)
```

```
##  Family: gaussian 
##   Links: mu = identity; sigma = identity 
## Formula: y ~ 1 + x 
##    Data: data_o (Number of observations: 100) 
##   Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
##          total post-warmup draws = 4000
## 
## Population-Level Effects: 
##           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
## Intercept     1.56      0.34     0.88     2.22 1.00     3889     2871
## x             0.50      0.11     0.28     0.72 1.00     3941     2995
## 
## Family Specific Parameters: 
##       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
## sigma     1.13      0.08     0.98     1.30 1.00     3719     2831
## 
## Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
## and Tail_ESS are effective sample size measures, and Rhat is the potential
## scale reduction factor on split chains (at convergence, Rhat = 1).
```




```r
M_student <- 
  brm(data = data_o, family = student,
      y ~ 1 + x,
      prior = c(prior(normal(0, 10), class = Intercept),
                prior(normal(0, 10), class = b),
                prior(gamma(4, 1), class = nu),
                prior(cauchy(0, 1),  class = sigma)),
      seed = 1)
```

```
## Compiling Stan program...
```

```
## Trying to compile a simple C file
```

```
## Running /Library/Frameworks/R.framework/Resources/bin/R CMD SHLIB foo.c
## clang -mmacosx-version-min=10.13 -I"/Library/Frameworks/R.framework/Resources/include" -DNDEBUG   -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/Rcpp/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/unsupported"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/BH/include" -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/src/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppParallel/include/"  -I"/Library/Frameworks/R.framework/Versions/4.0/Resources/library/rstan/include" -DEIGEN_NO_DEBUG  -DBOOST_DISABLE_ASSERTS  -DBOOST_PENDING_INTEGER_LOG2_HPP  -DSTAN_THREADS  -DUSE_STANC3 -DSTRICT_R_HEADERS  -DBOOST_PHOENIX_NO_VARIADIC_EXPRESSION  -DBOOST_NO_AUTO_PTR  -include '/Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp'  -D_REENTRANT -DRCPP_PARALLEL_USE_TBB=1   -I/usr/local/include   -fPIC  -Wall -g -O2  -c foo.c -o foo.o
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:88:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:1: error: unknown type name 'namespace'
## namespace Eigen {
## ^
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/src/Core/util/Macros.h:628:16: error: expected ';' after top level declarator
## namespace Eigen {
##                ^
##                ;
## In file included from <built-in>:1:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/StanHeaders/include/stan/math/prim/fun/Eigen.hpp:22:
## In file included from /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Dense:1:
## /Library/Frameworks/R.framework/Versions/4.0/Resources/library/RcppEigen/include/Eigen/Core:96:10: fatal error: 'complex' file not found
## #include <complex>
##          ^~~~~~~~~
## 3 errors generated.
## make: *** [foo.o] Error 1
```

```
## Start sampling
```

```
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 1).
## Chain 1: 
## Chain 1: Gradient evaluation took 0.000456 seconds
## Chain 1: 1000 transitions using 10 leapfrog steps per transition would take 4.56 seconds.
## Chain 1: Adjust your expectations accordingly!
## Chain 1: 
## Chain 1: 
## Chain 1: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 1: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 1: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 1: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 1: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 1: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 1: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 1: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 1: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 1: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 1: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 1: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 1: 
## Chain 1:  Elapsed Time: 0.07 seconds (Warm-up)
## Chain 1:                0.063 seconds (Sampling)
## Chain 1:                0.133 seconds (Total)
## Chain 1: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 2).
## Chain 2: 
## Chain 2: Gradient evaluation took 1.8e-05 seconds
## Chain 2: 1000 transitions using 10 leapfrog steps per transition would take 0.18 seconds.
## Chain 2: Adjust your expectations accordingly!
## Chain 2: 
## Chain 2: 
## Chain 2: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 2: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 2: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 2: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 2: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 2: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 2: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 2: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 2: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 2: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 2: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 2: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 2: 
## Chain 2:  Elapsed Time: 0.069 seconds (Warm-up)
## Chain 2:                0.066 seconds (Sampling)
## Chain 2:                0.135 seconds (Total)
## Chain 2: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 3).
## Chain 3: 
## Chain 3: Gradient evaluation took 1.3e-05 seconds
## Chain 3: 1000 transitions using 10 leapfrog steps per transition would take 0.13 seconds.
## Chain 3: Adjust your expectations accordingly!
## Chain 3: 
## Chain 3: 
## Chain 3: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 3: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 3: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 3: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 3: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 3: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 3: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 3: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 3: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 3: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 3: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 3: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 3: 
## Chain 3:  Elapsed Time: 0.071 seconds (Warm-up)
## Chain 3:                0.063 seconds (Sampling)
## Chain 3:                0.134 seconds (Total)
## Chain 3: 
## 
## SAMPLING FOR MODEL 'anon_model' NOW (CHAIN 4).
## Chain 4: 
## Chain 4: Gradient evaluation took 2.5e-05 seconds
## Chain 4: 1000 transitions using 10 leapfrog steps per transition would take 0.25 seconds.
## Chain 4: Adjust your expectations accordingly!
## Chain 4: 
## Chain 4: 
## Chain 4: Iteration:    1 / 2000 [  0%]  (Warmup)
## Chain 4: Iteration:  200 / 2000 [ 10%]  (Warmup)
## Chain 4: Iteration:  400 / 2000 [ 20%]  (Warmup)
## Chain 4: Iteration:  600 / 2000 [ 30%]  (Warmup)
## Chain 4: Iteration:  800 / 2000 [ 40%]  (Warmup)
## Chain 4: Iteration: 1000 / 2000 [ 50%]  (Warmup)
## Chain 4: Iteration: 1001 / 2000 [ 50%]  (Sampling)
## Chain 4: Iteration: 1200 / 2000 [ 60%]  (Sampling)
## Chain 4: Iteration: 1400 / 2000 [ 70%]  (Sampling)
## Chain 4: Iteration: 1600 / 2000 [ 80%]  (Sampling)
## Chain 4: Iteration: 1800 / 2000 [ 90%]  (Sampling)
## Chain 4: Iteration: 2000 / 2000 [100%]  (Sampling)
## Chain 4: 
## Chain 4:  Elapsed Time: 0.07 seconds (Warm-up)
## Chain 4:                0.065 seconds (Sampling)
## Chain 4:                0.135 seconds (Total)
## Chain 4:
```




```r
summary(M_student)
```

```
##  Family: student 
##   Links: mu = identity; sigma = identity; nu = identity 
## Formula: y ~ 1 + x 
##    Data: data_o (Number of observations: 100) 
##   Draws: 4 chains, each with iter = 2000; warmup = 1000; thin = 1;
##          total post-warmup draws = 4000
## 
## Population-Level Effects: 
##           Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
## Intercept     0.56      0.20     0.17     0.96 1.00     3835     2836
## x             0.80      0.07     0.66     0.93 1.00     3836     3084
## 
## Family Specific Parameters: 
##       Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
## sigma     0.50      0.06     0.39     0.62 1.00     3183     2799
## nu        2.80      0.70     1.71     4.49 1.00     3564     2917
## 
## Draws were sampled using sampling(NUTS). For each parameter, Bulk_ESS
## and Tail_ESS are effective sample size measures, and Rhat is the potential
## scale reduction factor on split chains (at convergence, Rhat = 1).
```



### Conclusion

In this post, we have provided a simple Bayesian approach to robustly estimate both parameters β and σ of a simple linear regression where the estiamtes are robust to the variance of the error term. The specificity of this approach is to replace the traditional normal assumption on the dependant variable by a heavy-tailed t-distribution assumption. Robusness against outliers comes at a price of a loss of efficiency, especially when the observations are normally distributed. This is a low premium that comes with the robust alternatives that offers a large protection against over-fiting. 




```stan
 data {
  int N;
  vector[N] y;
  int K;
  matrix[N, K] X;
  int Y;
  int year[N];
  real sigma_scale;
  vector[K] beta_loc;
  vector[K] beta_scale;
  real alpha_loc;
  real alpha_scale;
}
parameters {
  vector[Y] alpha;
  vector[K] beta;
  real nu;
  real sigma;
  real tau;
}
transformed parameters {
  vector[N] mu;
  for (i in 1:N) {
    mu[i] = alpha[year[i]] + X[i] * beta;
  }
}
model{
  sigma ~ cauchy(0., sigma_scale);
  alpha ~ normal(alpha_loc, alpha_scale);
    beta ~ normal(beta_loc, beta_scale);
    nu ~ gamma(2, 0.1);
    y ~ student_t(nu, mu, sigma);
}
generated quantities {
  real delta;
  delta = beta[3] + beta[4];
}
```



```stan
  data {
  int N;
  vector[N] y;
  int K;
  matrix[N, K] X;
  int Y;
  int year[N];
  real sigma_scale;
  vector[K] beta_loc;
  vector[K] beta_scale;
  real alpha_loc;
  real alpha_scale;
}
parameters {
  vector[Y] alpha;
  vector[K] beta;
  real nu;
  real sigma_raw;
  real tau;
}
transformed parameters {
  vector[N] mu;
  real sigma;
  for (i in 1:N) {
    mu[i] = alpha[year[i]] + X[i] * beta;
  }
  sigma = sigma_raw * sqrt((nu - 2) / nu);
}
model{
  sigma_raw ~ cauchy(0., sigma_scale);
  alpha ~ normal(alpha_loc, alpha_scale);
    beta ~ normal(beta_loc, beta_scale);
    nu ~ gamma(2, 0.1);
    y ~ student_t(nu, mu, sigma);
}
generated quantities {
  real delta;
  delta = beta[3] + beta[4];
}
```

```stan
data {
    int<lower=1> N;    
    int<lower=0> M;    
    int<lower=0> P;    
    vector[N] x;       
    vector[N] y;       
    vector[M] x_cred;  
    vector[P] x_pred;  
}

parameters {
    real alpha;           
    real beta;            
    real<lower=0> sigma;  
    real<lower=1> nu;     
}

transformed parameters {
    vector[N] mu = alpha + beta * x;            
    vector[M] mu_cred = alpha + beta * x_cred;  
    vector[P] mu_pred = alpha + beta * x_pred;  
}

model {
    y ~ student_t(nu, mu, sigma);
    alpha ~ normal(0, 1000);
    beta ~ normal(0, 1000);
    sigma ~ normal(0, 1000);
    nu ~ gamma(2, 0.1);
}

generated quantities {
    real y_pred[P];
    for (p in 1:P) {
        y_pred[p] = student_t_rng(nu, mu_pred[p], sigma);
    }
}
```


```r
b0 <- 
  brm(data = d, 
      family = gaussian,
      y ~ 1 + x,
      prior = c(prior(normal(0, 10), class = Intercept),
                prior(normal(0, 10), class = b),
                prior(cauchy(0, 1),  class = sigma)),
      seed = 1)
```

```r    
b1 <- 
  update(b0, 
         newdata = o,
         seed = 1)
```
```r
b2 <- 
  brm(data = o, family = student,
      y ~ 1 + x,
      prior = c(prior(normal(0, 10), class = Intercept),
                prior(normal(0, 10), class = b),
                prior(gamma(2, 0.1), class = nu),
                prior(cauchy(0, 1),  class = sigma)),
      seed = 1)
```

```r
b3 <- 
  update(b2,
         prior = c(prior(normal(0, 10), class = Intercept),
                   prior(normal(0, 10), class = b),
                   prior(gamma(4, 1),   class = nu),
                   prior(cauchy(0, 1),  class = sigma)),
         seed = 1)
```

```r
b4 <-
  brm(data = o, family = student,
      bf(y ~ 1 + x, nu = 4),
      prior = c(prior(normal(0, 100), class = Intercept),
                prior(normal(0, 10),  class = b),
                prior(cauchy(0, 1),   class = sigma)),
         seed = 1)
```         

## References


+ [] https://jrnold.github.io/bugs-examples-in-stan/resistant.html

+ [] https://rpubs.com/jpn3to/outliers

+ [] https://baezortega.github.io/2018/08/06/robust_regression/

+ https://solomonkurz.netlify.app/post/2019-02-02-robust-linear-regression-with-student-s-t-distribution/

+ [Bayesian Robustness to Outliers in Linear Regression](https://arxiv.org/pdf/1612.05307.pdf)

+ [A New Bayesian Approach to Robustness Against Outliers in Linear Regression](https://dms.umontreal.ca/~bedard/Robustness.pdf)

+ [Robust Noise Models from stan manual](https://mc-stan.org/docs/2_18/stan-users-guide/robust-noise-models.html)
