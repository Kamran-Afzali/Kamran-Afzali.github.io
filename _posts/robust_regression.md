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


The means or regression coefficients can be distorted by outlying data points. Utilizing Student's t density with an unidentified degrees of freedom parameter is a well-liked substitution for normal errors in regression investigations. The Student's t distribution has heavier tails than the normal for low degrees of freedom, but it leans toward the normal as the degrees of freedom parameter rises. A check on the suitability of the normal is thus made possible by treating the degrees of freedom parameter as an unknown quantity that must be approximated.


Robust regression refers to regression methods which are less sensitive to outliers. Bayesian robust regression uses distributions with wider tails than the normal instead of the normal. This plots the normal, Double Exponential (Laplace), and Student-t  distributions all with mean 0 and scale 1, and the surprise  at each point. Both the Student- t and Double Exponential distributions have surprise values well below the normal in the ranges (-6, 6).11 This means that outliers will have less of an affect on the log-posterior of models using these distributions. The regression line would need to move less incorporate those observations since the error distribution will not consider them as unusual.

The most commonly used Bayesian model for robust regression is a linear regression with independent Student-t errors it’s only slightly more difficult to make a Bayesian version of the model. I’ve included R and Stan code in the Downloads section for a simple Bayesian t-regression model with nu unknown (Stan’s sampler has no problem estimating nu along with everything else).

Due to the normalcy assumption used by traditional regression techniques, noisy or abnormal data can greatly affect their accuracy. Since the normal distribution must move to a new place in the parameter space to best accommodate the outliers in the data, this frequently leads to an underestimate of the relationship between the variables. In a frequentist framework, creating a linear regression model that is resistant to outliers necessitates the use of very complex statistical techniques; however, in a Bayesian framework, we can achieve robustness by simply using the t-distribution. The degrees of freedom, or parameter ν, of this probability distribution determines how close to normal the distribution is: Low small values of produce a distribution with thicker tails (that is, a greater spread around the mean) than the normal distribution, but big values of (approximately > 30) give a distribution that is quite similar to the normal distribution. As a result, we can allow the distribution of the regression line to be as normal or non-normal as the data imply while still capturing the underlying relationship between the variables by substituting the normal distribution above with a t-distribution and adding as an extra parameter to the model.








Number two is problematic for several reasons: The first is that it’s usually done haphazardly, either by eyeballing it (the intra-ocular trauma test) or by using some cutoff that is, itself, not robust to outliers (e.g. “more than 3 standard deviation from the mean”). Second, it assumes that the extreme values are erroneous, and are not legitimate measurements. This is especially bad when it comes to response time data, which are never normal, even in theory, and yet people will still cut off the upper tail of the RT distribution and call it data cleanup.

In general, if you have a major problem with outliers that isn’t due to measurement error, you’re probably not defining “outlier” properly. Outliers are only outliers under some particular model (e.g. if you’re modelling the data as being normal, you’ll tend to interpret extreme values as being outliers, but those values might not be “extreme” under some other distribution). A better way to deal with outliers is to use a model that accomodates them. 

Simple linear regression is a very popular technique for estimating the linear relationship between two variables based on matched pairs of observations, as well as for predicting the probable value of one variable (the response variable) according to the value of the other (the explanatory variable). When plotting the results of linear regression graphically, the explanatory variable is normally plotted on the x-axis, and the response variable on the y-axis.

### Concepts and code

The standard approach to linear regression is defining the equation for a straight line that represents the relationship between the variables as accurately as possible. The equation for the line defines y (the response variable) as a linear function of x (the explanatory variable):

𝑦 = 𝛼 + 𝛽𝑥 + 𝜀
In this equation, ε represents the error in the linear relationship: if no noise were allowed, then the paired x- and y-values would need to be arranged in a perfect straight line (for example, as in y = 2x + 1). Because we assume that the relationship between x and y is truly linear, any variation observed around the regression line must be random noise, and therefore normally distributed. From a probabilistic standpoint, such relationship between the variables could be formalised as

𝑦 ~ 𝓝(𝛼 + 𝛽𝑥, 𝜎)
That is, the response variable follows a normal distribution with mean equal to the regression line, and some standard deviation σ. Such a probability distribution of the regression line is illustrated in the figure below.



The formulation of the robust simple linear regression Bayesian model is given below. We define a t likelihood for the response variable, y, and suitable vague priors on all the model parameters: normal for α and β, half-normal for σ and gamma for ν.



### Conclusion

In this post, we have provided a simple Bayesian approach to robustly estimate both parameters β and σ of a simple linear regression where the estiamtes are robust to the variance of the error term. The specificity of this approach is to replace the traditional normal assumption on the dependant variable by a heavy-tailed t-distribution assumption. Robusness against outliers comes at a price of a loss of efficiency, especially when the observations are normally distributed. This is a low premium that comes with the robust alternatives that offers a large protection against over-fiting. 

```r
s <- matrix(c(1, .6, 
              .6, 1), 
             nrow = 2, ncol = 2)
m <- c(0, 0)
set.seed(3)

d <- MASS::mvrnorm(n = 100, mu = m, Sigma = s) %>%
  as_tibble() %>%
  rename(y = V1, x = V2)
d <-
  d %>%
  arrange(x)

head(d)

o <- d
o[c(1:2), 1] <- c(5, 4.5)

head(o)


ols0 <- lm(data = d, y ~ 1 + x)
ols1 <- lm(data = o, y ~ 1 + x)


p1 <-
  ggplot(data = d, aes(x = x, y = y)) +
  stat_smooth(method = "lm", color = "grey92", fill = "grey67", alpha = 1, fullrange = T) +
  geom_point(size = 1, alpha = 3/4) +
  scale_x_continuous(limits = c(-4, 4)) +
  coord_cartesian(xlim = c(-3, 3), 
                  ylim = c(-3, 5)) +
  labs(title = "No Outliers") +
  theme(panel.grid = element_blank())

# the data with two outliers
p2 <-
  ggplot(data = o, aes(x = x, y = y, color = y > 3)) +
  stat_smooth(method = "lm", color = "grey92", fill = "grey67", alpha = 1, fullrange = T) +
  geom_point(size = 1, alpha = 3/4) +
  scale_color_viridis_d(option = "A", end = 4/7) +
  scale_x_continuous(limits = c(-4, 4)) +
  coord_cartesian(xlim = c(-3, 3), 
                  ylim = c(-3, 5)) +
  labs(title = "Two Outliers") +
  theme(panel.grid = element_blank(),
        legend.position = "none")

# combine the ggplots with patchwork syntax
library(patchwork)

p1 + p2
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