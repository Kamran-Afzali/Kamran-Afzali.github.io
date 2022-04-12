---
layout: post
categories: posts
title: Bayesian Modelin in R and Stan
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: March 2022
---


## Bayesian Modelin in R and Stan

### Prerequisites

The focus of this simple tutorial is to provide a brief introduction and overview about how to fit Bayesian models using STAN via R.

The latest version of R, which can be downloaded and installed for Windows, Mac or Linux OS from the CRAN website I also strongly recommend to download and install Rstudio, an integrated development environment which provides an “user-friendly” interaction with R (e.g. many drop-down menus, tabs, customisation options)

### What is STAN?

Stan provides full Bayesian inference for continuous-variable models through Markov Chain Monte Carlo methods such as the No-U-Turn sampler, an adaptive form of Hamiltonian Monte Carlo sampling.


Stan is a programming language for specifying statistical models. It is most used as a MCMC sampler for Bayesian analyses. Markov chain Monte Carlo (MCMC) is a sampling method that allows you to estimate a probability distribution without knowing all of the distribution’s mathematical properties. It is particularly useful in Bayesian inference because posterior distributions often cannot be written as a closed-form expression. To use Stan, the user writes a Stan program that represents their statistical model. This program specifies the parameters in the model along with the target posterior density. The Stan code is compiled and run along with the data and outputs a set of posterior simulations of the parameters. Stan interfaces with the most popular data analysis languages, such as R, Python, shell, MATLAB, Julia and Stata. We will focus on using Stan from within R, using the rstan and rstanarm packages.

STAN is a program for analysis of Bayesian models using Markov Chain Monte Carlo (MCMC) methods (Gelman, Lee, and Guo (2015)). STAN is a free software and a probabilistic programming language for specifying statistical models using a specific class of MCMC algorithms known as Hamiltonian Monte Carlo methods (HMC). The latest version of STAN can be dowloaded from the web repository and is available for different OS. There are different R packages which function as frontends for STAN. These packages make it easy to process the output of Bayesian models and present it in publication-ready form. In this brief introduction, I will specifically focus on the rstan package (Stan Development Team (2018)) and show how to fit STAN models using this package.
Installing STAN and rstan

Unlike other Bayesian software, such as JAGS or OpenBUGS, it is not required to separately install the program and the corresponding frontend R package. Indeed, installing the R package rstan will automatically install STAN on your machine. However, you will also need to make sure to having installed on your pc a C++ compiler which is used by rstan to fit the models. Under a Windows OS, for example, this can be done by installing Rtools, a collection of resources for building packages for R, which is freely available from the web repository.

Next, install the package rstan from within R or Rstudio, via the package installer or by typing in the command line

The dependencies = TRUE option will automatically install all the packages on which the functions in the rstan package rely.
Basic model
Simulate data

For an example dataset, I simulate my own data in R. I create a continuous outcome variable y
as a function of one predictor x and a disturbance term ϵ. I simulate a dataset with 100 observations. Create the error term, the predictor and the outcome using a linear form with an intercept β0 and slope β1 coefficients, i.e.

### Model file

Now, I write the model for STAN and save it as a stan file named "basic.mod.stan" in the current working directory

STAN models are written using an imperative programming language, which means that the order in which you write the elements in your model file matters, i.e. you first need to define your variables (e.g. integers, vectors, matrices, etc.), the constraints which define the range of values your variable can take (e.g. only positive values for standard deviations), and finally define the relationship among the variables (e.g. one is a liner function of another).

A Stan model is defined by six program blocks:
Data (required). The data block reads external information – e.g. data vectors, matrices, integers, etc.
The data block is where we define our observed variables. We also need to define lengths/dimensions of stuff, which can seem strange if you’re used to R or Python. We first declare an integer variable N to be the number of observations: int N; (note the use of semicolon to denote the end of a line). I’m also declaring an integer K, which is the number of predictors in our model. Note that I’m including the intercept in this count, so we end up with 2 predictors (2 columns in the model matrix). Now we supply actual data. We write matrix[N, K] to tell Stan that x is a N×K matrix. y is easier - just a vector of length N.



Transformed data (optional). The transformed data block allows for preprocessing of the data – e.g. transformation or rescaling of the data.


Parameters (required). The parameters block defines the sampling space – e.g. parameters to which prior distributions must be assigned.
Now we tell Stan the parameters in our model. These are the unobserved variables that we want to estimate. In this example, we have 3 parameters: β0, β1 and σ. Like before, we first tell Stan the type of data this parameter will contain - in this case, β0 and β1 are contained in a vector of length K that we will sensibly call beta. σ will just be a single real value (“real” means that the number can have a decimal point). We use <lower=0> to constrain it to be positive because it is impossible to have negative standard deviation.

Transformed parameters (optional). The transformed parameters block allows for parameter processing before the posterior is computed – e.g. tranformation or rescaling of the parameters.Model (required). In the model block we define our posterior distributions – e.g. choice of distributions for all variables.
enerated quantities (optional). The generated quantities block allows for postprocessing – e.g. backtranformation of the parameters using the posterior samples.

For this introduction I consider a very simple model which only requires the specification of four blocks in the STAN model. In the data block, I first define the size of the sample n_sim as a positive integer number using the expression int<lower=0> n_sim; then I declare the two variables y and x as reals (or vectors) with length equal to N. In the parameters block, I define the coefficients for the linear regression beta0 and beta1 (as two real numbers) and the standard deviation parameter sigma (as a positive real number). In the transformed parameters block, I define the conditional mean mu (a real vector of length N) as a linear function of the intercept beta0, the slope beta1, and the covariate x. Finally, in the model block, I assign weakly informative priors to the regression coefficients and the standard deviation parameters, and I model the outcome data y using a normal distribution indexed by the conditional mean mu and the standard deviation sigma parameters. In many cases, STAN uses sampling statements which can be vectorised, i.e. you do not need to use for loop statements.


It’s been said that linear regression is the ‘Hello World’ of statistics. To see the Bayesian workflow in action and get comfortable, we’ll start with a simple (albeit inappropriate) model for this data - one in which we completely ignore the grouping of the data within participants and instead treat each observation as completely independent from the others. This is not the way to analyze this data, but I use it as a simple demonstration of how to construct Stan code.

I give full credit to McElreath’s brilliant Statistical Rethinking (2020) for introducing me to this way of writing out models. It’s a bit jarring at first; myself having become accustomed to model formulas as one-liners. But once you understand it it’s a really elegant way of expressing the model.

We then assign priors to the parameters. Priors encode our knowledge and uncertainty about the data before we run the model. We don’t use priors to get a desired result, we use priors because it makes sense. Without priors, our model initially ‘thinks’ that the data is just as likely to come from a normal distribution with a mean of 0 and sigma of 1 as it is to come from a distribution with a mean of 1,000 and a sigma of 400. True, the likelihood function (i.e., the probability of the data given the model) will sort things out when we have sufficient data, but we’ll see that priors play a particularly important role when we move on to varying effects models.

### Fit the model

We need to put the data in a list for Stan. Everything that we declared in the data block of our Stan code should be entered into this list. We’ll also standardize the variables, so that they match up with our priors. Finally, we use the function stan to run the model. We set chains and cores to 4, which will allow us to run 4 Markov chains in parallel.

Now, we can fit the model in STAN using the stan function in the rstan package and save it in the object basic.mod


### MCMC diagnostics

In addition to the regular model diagnostic checks (such as residual plots), for Bayesian analyses, it is necessary to explore the characteristics of the MCMC chains and the sampler in general. Recall that the purpose of MCMC sampling is to replicate the posterior distribution of the model likelihood and priors by drawing a known number of samples from this posterior (thereby formulating a probability distribution). This is only reliable if the MCMC samples accurately reflect the posterior. Unfortunately, since we only know the posterior in the most trivial of circumstances, it is necessary to rely on indirect measures of how accurately the MCMC samples are likely to reflect the likelihood. I will briefly outline the most important diagnostics. Traceplots for each parameter illustrate the MCMC sample values after each successive iteration along the chain. Bad chain mixing (characterised by any sort of pattern) suggests that the MCMC sampling chains may not have completely traversed all features of the posterior distribution and that more iterations are required to ensure the distribution has been accurately represented.


Autocorrelation plot for each parameter illustrate the degree of correlation between MCMC samples separated by different lags. For example, a lag of represents the degree of correlation between each MCMC sample and itself (obviously this will be a correlation of ). A lag of

represents the degree of correlation between each MCMC sample and the next sample along the chain and so on. In order to be able to generate unbiased estimates of parameters, the MCMC samples should be independent (uncorrelated).

Potential scale reduction factor (Rhat) statistic for each parameter provides a measure of sampling efficiency/effectiveness. Ideally, all values should be less than
. If there are values of or greater it suggests that the sampler was not very efficient or effective. Not only does this mean that the sampler was potentially slower than it could have been but, more importantly, it could indicate that the sampler spent time sampling in a region of the likelihood that is less informative. Such a situation can arise from either a misspecified model or overly vague priors that permit sampling in otherwise nonscence parameter space.

Prior to examining the summaries, we should have explored the convergence diagnostics. We use the package mcmcplots to obtain density and trace plots for the effects model as an example.


When fitting a model using MCMC, it is important to check if the chains have converged. We recommend the bayesplot package to visually examine MCMC diagnostics. The bayesplot package supports model objects from both rstan and rstanarm and provides easy to use functions to display MCMC diagnostics. We will demonstrate the mcmc_trace() function to create a trace plot and the mcmc_rhat() function to create a plot of the Rhat values.

First, let us create trace plots using mcmc_trace(). A trace plot shows the sampled values of the parameters over the MCMC iterations. If the model has converged, then the trace plot should look like a random scatter around a mean value. If the chains are snaking around the parameter space or if the chains converge to different values, then that is evidence of a problem. We demonstrate the function using our model fits from both rstanarm and rstan.

We can take a look at the parameters in the console by printing the model fit. We get posterior means, standard errors, and quantiles for each parameter. We also get things called n_eff and Rhat. These are indicators of how well Stan’s engine explored the parameter space (if this is cryptic, that’s ok), It’s enough for now to know that when Rhat is 1, things are good.

### Parting thoughts

In this post we saw how to adapt our models to non-normal data that are pretty common out there. STAN is very flexible and allow many different parametrization for many different distributions (see the reference guide), the possibilities are only limited by your hypothesis (and maybe a bit your mathematical skills …). At this point I’d like you to note that the rstanarm package allows you to fit STAN model without you having to write down the model. Instead using the typical R syntax one would use in, for example, a glm call (see this post). So why bothering learning all this STAN stuff? It depends: if you are only fitting “classical” models to your data with little fanciness then just use rstanarm this will save you some time to do your science and the models in this package are certainly better parametrized (ie faster) than the one I presented here. On the other hand if you feel that one day you will have to fit your own customized models then learning STAN is a good way to tap into a highly flexible and powerful language that will keep growing.

rstanarm is a package that works as a front-end user interface for Stan. It allows R users to implement Bayesian models without having to learn how to write Stan code. You can fit a model in rstanarm using the familiar formula and data.frame syntax (like that of lm()). rstanarm achieves this simpler syntax by providing pre-compiled Stan code for commonly used model types. It is convenient to use but is limited to the specific “common” model types. If you need to fit a different model type, then you need to code it yourself with rstan.

The model fitting functions begin with the prefix stan_ and end with the the model type. Some examples include stan_glm() and stan_glmer(). See here for a full list of rstanarm functions. The modeling functions have two required arguments:
- formula: A formula that specifies the dependent and independent variables (y ~ x1 + x2).
- data: A data-frame containing the variables in the formula.

Additionally, there is an optional prior argument, which allows you to change the default prior distributions.

### Conclusions Summary

In this post we saw how to fit normal regression using STAN and how to get a set of important summaries from the models. The STAN model presented here should be rather flexible and could be fitted to dataset of varying sizes. Remember that the explanatory variables should be standardized before fitting the models. This is just a first glimpse into the many models that can fitted using STAN, in a later posts we will look at generalized linear models, extending to non-normal models with various link functions and also to hierarchical models.

This tutorial was simply a brief introduction on how simple linear regression models can be fitted using the Bayesian software STAN via the rstan package. Although this may seem a complex procedure compared with simply fitting a linear model under the frequentist framework, however, the real advantages of Bayesian methods become evident when the complexity of the analysis is increased (which is often the case in real applications). Indeed, the flexibility in Bayesian modelling allows to account for increasingly complex models in a relatively easy way. In addition, Bayesian methods are ideal when the interest is in taking into account the potential impact that different sources of uncertainty may have on the final results, as they allow the natural propagation of uncertainty throughout each quantity in the model.


## References

+ [Introduction to STAN](https://agabrioblog.onrender.com/stan/page/2/)

+ [Simple Linear Regression in STAN](https://agabrioblog.onrender.com/tutorial/simple-linear-regression-stan/simple-linear-regression-stan/)

+ [Multiple linear regression in Stant](http://webpages.math.luc.edu/~ebalderama/bayes_resources/code/mlr_stan.html)

+ [Hernan Book Liner Regression in Stan](https://rpubs.com/kaz_yos/stan-lm1)

+ [Bayesian regression with STAN: Part 1 normal regression](https://datascienceplus.com/bayesian-regression-with-stan-part-1-normal-regression/)

+ [Bayesian regression with STAN: Part 2 beyond normality](https://datascienceplus.com/bayesian-regression-with-stan-beyond-normality/)

+ [Bayesian Varying Effects Models in R and Stan](https://willhipson.netlify.app/post/stan-random-slopes/varying_effects_stan/)

+ [Introduction to rstan and rstanarm](https://blog.methodsconsultants.com/posts/introduction-to-stan-in-r/)

+ [Stan (+R) Workshop](https://rpruim.github.io/StanWorkshop/)
