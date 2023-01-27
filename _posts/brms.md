---
layout: post
categories: posts
title: Bayesian Multilevel models in brms
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: January 2022
---
## Bayesian Multilevel models in *brms*

### Multilevel models (MLMs)

Multilevel models (MLMs) offer great flexibility for researchers allow modeling of data measured on different levels (e.g. data of students nested within classes and schools) thus taking complex dependency structures into account. This is done by fitting models that include both constant and varying effects (sometimes referred to as fixed and random effects). The multilevel strategy can be especially useful when dealing with repeated measurements (e.g., when measurements are nested within participants) or when handling complex dependency structures in the data such as unequal sample sizes. Many R packages are developed to fit MLMs with their functionality of limited to the mean of the response distribution while other parameters of the response distribution, such as the residual standard deviation in linear models, are assumed constant across observations. However, when one tries to include the maximal varying effect structure, this kind of model tends either not to converge, or to give aberrant estimations of the correlation between varying effects, however, the maximal varying effect structure can generally be fitted in a Bayesian framework. Another advantage of Bayesian statistical modelling is that it fits the way researchers intuitively understand statistical results. Widespread misinterpretations of frequentist statistics (like p-values and confidence intervals) are often attributable to the wrong interpretation of these statistics as resulting from a Bayesian analysis. The intuitive nature of the Bayesian approach might arguably be hidden by the predominance of frequentist teaching in undergraduate statistical courses. Moreover, the Bayesian approach offers a natural solution to the problem of multiple comparisons, when the situation is adequately modelled in a multilevel framework, and allows a priori knowledge to be incorporated in data analysis via the prior distribution. In this post, we will briefly introduce the Bayesian approach to data analysis and the multilevel modelling strategy. Second, we will illustrate how Bayesian MLMs can be implemented in R by using the *brms* package.

### Bayesian Method

The key difference between Bayesian statistical inference and frequentist statistical methods concerns the nature of the unknown parameters to be estimated. In the frequentist framework, a parameter of interest is assumed to be unknown, but fixed. That is, it is assumed that in the population there is only one true population parameter, for example, one true mean or one true regression coefficient. In the Bayesian view of subjective probability, all unknown parameters are treated as uncertain and therefore are be described by a probability distribution. Every parameter is unknown, and everything unknown receives a distribution. This post first build towards a full multilevel using uninformative priors and then will discuss the influence of using different priors on the final model. If you’re just starting out with Bayesian statistics in R and you have some familiarity with running Frequentist models using packages like lme4 or the base lm function, you may prefer starting out with more user-friendly packages that use Stan as a backend, but hide a lot of the complicated details. brms package gives us the actual posterior samples, lets us specify a wide range of priors, and using the familiar input structure of the lme4 package. As presented in previous posts Stan is the way to go if you want more control and a deeper understanding of your models. Stan comes with its own programming language, allowing for great modeling flexibility. Many researchers may still be hesitent to use Stan directly, as every model has to be written, debugged and possibly also optimized. This may be a time-consuming and error-prone process even for researchers familiar with Bayesian inference. The brms package, presented here,  allows the user to benefit from the merits of Stan by using extended lme4-like formula syntax, with which many R users are familiar with. It offers much more than writing efficient and human-readable Stan code. brms comes with many post-processing and visualization functions, for instance to perform posterior predictive checks, leave one-out cross-validation, visualization of estimated effects, and prediction of new data. Since the brms package (via STAN) makes use of a Hamiltonian Monte Carlo sampler algorithm (MCMC) to approximate the posterior (distribution), we need to specify a few more parameters than in a frequentist analysis (using lme4).

+ First we need the specify the number of iterations.
+ We need to specify the number of chains.
+ We need to specify the number of iterations per chain (warmup or burnin phase).
+ We need to specify initial values are for the different chains for the parameters of interest.

We need to specify all these values for replicability purposes. In addition, if the two chains would not converge we can specify more iterations, different starting values and a longer warmup period. 

The brm() function requires:

+  the dependent variable to predict.
+  a “~”, to indicate that we now give the other variables of interest.
+  a “1” in the formula the function indicates the intercept.
+  the random effects/slopes between brackets. Again the value 1 is to indicate the intercept and the variables right of the vertical “|” bar is used to indicate grouping variables.
+ Finally, we specify which *dataset* we want to use after the data = *dataset*.

Here is an example:

```
model1 <- brm(extro ~ open + agree + social + (1|school),  
              data = lmm.data, 
              warmup = 1000, iter = 5000, 
              cores = 4, chains = 4, 
              seed = 123) #to run the model
summary(model1)


model2 <- brm(extro ~ open + agree + social + (1 + social |school),  
              data = lmm.data, 
              warmup = 1000, iter = 5000, 
              cores = 4, chains = 4, 
              seed = 123) #to run the model
summary(model2)


get_prior(extro ~ open + agree + social + (1 + social |school),  data = lmm.data)

prior1 <- c(set_prior("normal(-10,100)", class = "b", coef = "extrav"),
            set_prior("normal(10,100)", class = "b", coef = "extrav:texp"),
            set_prior("normal(-5,100)", class = "b", coef = "sex"),
            set_prior("normal(-5,100)", class = "b", coef = "texp"),
            set_prior("normal(10,100)", class = "b", coef = "intercept" ))
      
```



### Priors

As stated in the brms manual: “Prior specifications are flexible and explicitly encourage users to apply prior distributions that actually reflect their beliefs.” Here we will only focus on priors for the regression coefficients and not on the error and variance terms, since we are most likely to actually have information on the size and direction of a certain effect and less (but not completely) unlikely to have prior knowledge on the unexplained variances. 

```
get_prior(popular ~ 0 + intercept + sex + extrav + texp + extrav:texp + (1 + extrav | class), data = popular2data)
prior1 <- c(set_prior("normal(-10,100)", class = "b", coef = "extrav"),
            set_prior("normal(10,100)", class = "b", coef = "extrav:texp"),
            set_prior("normal(-5,100)", class = "b", coef = "sex"),
            set_prior("normal(-5,100)", class = "b", coef = "texp"),
            set_prior("normal(10,100)", class = "b", coef = "intercept" ))
```


### Trace-plots and convergence dianostics

Before interpreting results, we should inspect the convergence of the chains that form the posterior distribution of the model parameters. A straightforward and common way to visualize convergence is the trace plot that illustrates the iterations of the chains from start to end.

```

mcmc_plot(model1, type = "trace")
mcmc_plot(model1, type = "hist")

plot(hypothesis(model1, "open = 0"))

```

### Conclusion
This post is meant to introduce users to the flexibility of the distributional regression approach and corresponding formula syntax as implemented in brms and fitted with Stan behind the scenes. Only a subset of modeling options were discussed in detail. Many more examples can be found in the growing number of vignettes accompanying the package (see vignette(package = "brms") for an overview). To date, brms is already one of the most flexible R packages when it comes to regression modeling.


## Refernces
+ [Tutorials brms 1](https://bookdown.org/content/ef0b28f7-8bdf-4ba7-ae2c-bc2b1f012283/modeling-discontinuous-and-nonlinear-change.html#bonus-the-logistic-growth-model)

+ [Tutorials brms 2](https://www.rensvandeschoot.com/tutorials/brms/)

+ [Vignettes brms](https://mran.microsoft.com/snapshot/2017-05-14/web/packages/brms/vignettes/brms_multilevel.pdf)

