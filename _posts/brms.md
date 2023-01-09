
Multilevel models (MLMs) offer great flexibility for researchers across sciences. They allow modeling of data measured on different levels at the same time – for instance data of students nested within classes and schools – thus taking complex dependency structures into account.
It is not surprising that many packages for R (R Core Team 2015) have been developed to fit MLMs. Usually, however, the functionality of these implementations is limited insofar as it is only possible to predict the mean of the response distribution. Other parameters of the
response distribution, such as the residual standard deviation in linear models, are assumed constant across observations, which may be violated in many applications. Accordingly, it is desirable to allow for prediction of all response parameters at the same time. Models doing exactly that are often referred to as distributional models or more verbosely models for location, scale and shape.

Stan comes with its own programming language, allowing for great modeling flexibility (cf., Stan Development Team 2017b; Carpenter et al. 2017). Many researchers may still be hesitent to use Stan directly, as every model has to be written, debugged and possibly also optimized. This may be a time-consuming and error-prone process even for researchers familiar with Bayesian inference. The brms package Burkner ¨ (in press), presented in this paper, aims to remove these hurdles for a wide range of regression models by allowing the user to benefit from the merits of Stan by using extended lme4-like (Bates, M¨achler, Bolker, and Walker 2015) formula syntax, with which many R users are familiar with. It offers much more than writing efficient and human-readable Stan code: brms comes with many post-processing and visualization functions, for instance to perform posterior predictive checks, leave one-out cross-validation, visualization of estimated effects, and prediction of new data.


### Bayesian Method
This tutorial will first build towards a full multilevel model with random slopes and cross level interaction using uninformative priors and then will show the influence of using different (informative) priors on the final model. Of course, it is always possible to already specify the informative priors for the earlier models. We make use of the BRMS package, because this package gives us the actual posterior samples (in contrast to for example the BLME package), lets us specify a wide range of priors, and using the familiar input structure of the lme4 package. See here for a tutorial on how to use that package.
The key difference between Bayesian statistical inference and frequentist statistical methods concerns the nature of the unknown parameters that you are trying to estimate. In the frequentist framework, a parameter of interest is assumed to be unknown, but fixed. That is, it is assumed that in the population there is only one true population parameter, for example, one true mean or one true regression coefficient. In the Bayesian view of subjective probability, all unknown parameters are treated as uncertain and therefore are be described by a probability distribution. Every parameter is unknown, and everything unknown receives a distribution.

Since the brms package (via STAN) makes use of a Hamiltonian Monte Carlo sampler algorithm (MCMC) to approximate the posterior (distribution), we need to specify a few more parameters than in a frequentist analysis (using lme4).

+ First we need the specify how many iteration we want the MCMC to run.
+ We need to specify how many chains we want to run.
+ We need to specify how many iterations we want to discard per chain (warmup or burnin phase).
+ We need to specify what our initial values are for the different chains for the parameters of interest. or we can just tell brms that we want random values as initial values.

We need to specify all these values for replicability purposes. In addition, if the two chains would not converge we can specify more iterations, different starting values and a longer warmup period. Thankfully brms will tell us if the sampler is likely to be non-converged.
The first model that we replicate is the intercept only model. If we look at the different inputs for the brm() function we:

+  have “popular”, which indicates the dependent variable we want to predict.
+ a “~”, that we use to indicate that we now give the other variables of interest.
+  a “1” in the formula the function indicates the intercept.
+ since this is an intercept only model, we do not have any other independent variables here.
+ between brackets we have the random effects/slopes. Again the value 1 is to indicate the intercept and the variables right of the vertical “|” bar is used to indicate grouping variables. In this case the class ID. So the dependent variable ‘popular’ is predicted by an intercept and a random error term for the intercept.
+ Finally, we specify which dataset we want to use after the data= command.


```
interceptonlymodeltest <- brm(popular ~ 1 + (1 | class), 
                              data   = popular2data, 
                              warmup = 100, 
                              iter   = 200, 
                              chains = 2, 
                              inits  = "random",
                              cores  = 2)  #the cores function tells STAN to make use of 2 CPU cores simultaneously instead of just 1.
                              
summary(interceptonlymodel)    


model1 <- brm(popular ~ 1 + sex + extrav + (1|class),  
              data = popular2data, 
              warmup = 1000, iter = 3000, 
              cores = 2, chains = 2, 
              seed = 123)
              
model2 <- brm(popular ~ 1 + sex + extrav + texp + (1|class),  
              data = popular2data, 
              warmup = 1000, iter = 3000, 
              cores = 2, chains = 2, 
              seed = 123)      
              
model3 <- brm(popular ~ 1 + sex + extrav + (1 + sex + extrav | class),  
              data = popular2data, 
              warmup = 1000, iter = 3000, 
              cores = 2, chains = 2, 
              seed = 123)
              
model4 <- brm(popular ~ 1 + sex + extrav + texp + (1 + extrav | class),  
              data = popular2data, 
              warmup = 1000, iter = 3000, 
              cores = 2, chains = 2, 
              seed = 123) #to run the model              
              

```


## Refernces
https://bookdown.org/content/ef0b28f7-8bdf-4ba7-ae2c-bc2b1f012283/modeling-discontinuous-and-nonlinear-change.html#bonus-the-logistic-growth-model

https://www.rensvandeschoot.com/tutorials/brms/

https://www.rensvandeschoot.com/tutorials/brms-started/

https://mran.microsoft.com/snapshot/2017-05-14/web/packages/brms/vignettes/brms_multilevel.pdf

