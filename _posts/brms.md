### Multilevel models (MLMs)

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
              
plot(hypothesis(model8, "sex = 0"))

```
### priors

As stated in the BRMS manual: “Prior specifications are flexible and explicitly encourage users to apply prior distributions that actually reflect their beliefs.”
We will set 4 types of extra priors here (in addition to the uninformative prior we have used thus far) 1. With an estimate far off the value we found in the data with uninformative priors with a wide variance 2. With an estimate close to the value we found in the data with uninformative priors with a small variance 3. With an estimate far off the value we found in the data with uninformative priors with a small variance (1). 4. With an estimate far off the value we found in the data with uninformative priors with a small variance (2).
In this tutorial we will only focus on priors for the regression coefficients and not on the error and variance terms, since we are most likely to actually have information on the size and direction of a certain effect and less (but not completely) unlikely to have prior knowledge on the unexplained variances. You might have to play around a little bit with the controls of the brm() function and specifically the adapt_delta and max_treedepth. Thankfully BRMS will tell you when to do so.


```
get_prior(popular ~ 0 + intercept + sex + extrav + texp + extrav:texp + (1 + extrav | class), data = popular2data)
prior1 <- c(set_prior("normal(-10,100)", class = "b", coef = "extrav"),
            set_prior("normal(10,100)", class = "b", coef = "extrav:texp"),
            set_prior("normal(-5,100)", class = "b", coef = "sex"),
            set_prior("normal(-5,100)", class = "b", coef = "texp"),
            set_prior("normal(10,100)", class = "b", coef = "intercept" ))
```


### Does the trace-plot exhibit convergence?
Before interpreting results, one should inspect the convergence of the chains that form the posterior distribution of the model parameters. A straightforward and common way to visualize convergence is the trace plot that illustrates the iterations of the chains from start to end.

```
modeltranformed <- ggs(model) # the ggs function transforms the BRMS output into a longformat tibble, that we can use to make different types of plots.
stanplot(model, type = "trace")
stanplot(model, type = "hist")

```

### Conclusion
The present paper is meant to introduce users to the flexibility of the distributional regression approach and corresponding formula syntax as implemented in brms and fitted with Stan behind the scenes. Only a subset of modeling options were discussed in detail, which ensured the paper was not too broad. For some of the more basic models that brms can fit, see Burkner ¨ (in press). Many more examples can be found in the growing number of vignettes accompanying the package (see vignette(package = "brms") for an overview). To date, brms is already one of the most flexible R packages when it comes to regression modeling. However, for the future, there are quite a few more features that I am planning to implement (see https://github.com/paul-buerkner/brms/issues for the current list of issues). In addition to smaller, incremental updates, I have four specific features in mind: mixture models, extended multivariate models, extended autocorrelation structures, and missing value imputation (in order of current importance). I receive ideas and suggestions from users almost every day – for which I am always grateful – and so the list of features that will be implemented in the proceeding versions of brms will continue to grow.

## Refernces
+ [Refernces 0](https://bookdown.org/content/ef0b28f7-8bdf-4ba7-ae2c-bc2b1f012283/modeling-discontinuous-and-nonlinear-change.html#bonus-the-logistic-growth-model)

+ [Refernces 1](https://www.rensvandeschoot.com/tutorials/brms/)

+ [Refernces 2](https://mran.microsoft.com/snapshot/2017-05-14/web/packages/brms/vignettes/brms_multilevel.pdf)

