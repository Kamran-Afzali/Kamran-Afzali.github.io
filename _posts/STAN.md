---
layout: post
categories: posts
title: Bayesian Modelin in R and Stan
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: April 2022
---


## Bayesian Modelin in R and Stan

### Prerequisites

The goal of this easy lesson is to provide a quick overview and introduction to fitting Bayesian models using STAN via R. 

I also strongly recommend downloading and installing Rstudio, an integrated development environment that allows a "user-friendly" interaction with R, which can be downloaded and installed for Windows, Mac, or Linux OS from the CRAN website (e.g. many drop-down menus, tabs, customisation options).

### What is STAN?

Stan uses Markov Chain Monte Carlo methods like the No-U-Turn sampler, an adaptive variant of Hamiltonian Monte Carlo sampling, to enable full Bayesian inference for continuous-variable models. 
STAN (Gelman, Lee, and Guo (2015)) is a tool for analysing Bayesian models using Markov Chain Monte Carlo (MCMC) methods. STAN is a probabilistic programming language and free software for specifying statistical models utilising Hamiltonian Monte Carlo methods, a type of MCMC algorithm (HMC). In this quick overview, I'll focus on the rstan package (Stan Development Team (2018)) and demonstrate how to fit STAN models with it. 
Stan is a computer language that allows you to create statistical models. It's most commonly employed as a Bayesian MCMC sampler. MCMC is a sampling method for estimating a probability distribution without knowing all of the features of the distribution. Because posterior distributions are frequently not represented as closed-form expressions, it is very useful in Bayesian inference. The user creates a Stan programme that depicts their statistical model in order to use Stan. The Stan code is compiled and run with the data, producing a collection of parameter posterior simulations. Stan works with the most widely used data analysis languages, including R and Python. The rstan and rstanarm packages will be used to demonstrate how to use Stan from within R.

Simulate data

For an example dataset, I simulate my own data in R. I create a continuous outcome variable y
as a function of one predictor x and a disturbance term ϵ. I simulate a dataset with 100 observations. Create the error term, the predictor and the outcome using a linear form with an intercept β0 and slope β1 coefficients, i.e.

### Model file

STAN models are written in an imperative programming language, which means the order in which you write the elements in your model file matters, i.e. you must first define your variables (e.g. integers, vectors, matrices, etc. ), then the constraints that define the range of values your variable can take (e.g. only positive values for standard deviations), and finally the relationship between the variables (e.g. one is a liner function of another). 

A Stan model is defined by six program blocks:
Data (required). The data block reads information from the outside world, such as data vectors, matrices, integers, and so on.
We also need to define the lengths and dimensions of objects, which may appear unusual to those who are used to R or Python.
The number of observations is first declared as an integer variable N: int N; (note the use of semicolon to denote the end of a line).
I'm also announcing the number of predictors in our model, which is K.
The intercept is included in this count, so we end up with two predictors (2 columns in the model matrix).
We are now providing accurate data.
To notify Stan that x is an NK matrix, we write matrix[N, K].
y is simpler: it's merely an N-dimensional vector.



Data that has been transformed (optional).
The converted data block enables data preprocessing, such as data transformation or rescaling.

Variables (required).
The parameters block specifies the parameters that must be assigned to earlier distributions.
These are the unobserved variables we're trying to figure out.
We have three parameters in this example: 0, 1, and 2.
We inform Stan the type of data this parameter will hold, just like we did before - in this example, 0 and 1 are included in a vector of length K that we'll call beta.
There will only be one real value (the term "real" refers to the fact that the integer can have a decimal point).
Because it is impossible to have a negative standard deviation, we used to confine it to be positive. 

Transformed parameters (optional).
Before computing the posterior, the changed parameters block provides for parameter processing, such as tranformation or rescaling of the parameters.


For this introduction, I'll use a very simple model in the STAN model that only involves the specification of four blocks.
In the data block, I declare the two variables y and x as reals (or vectors) with length equal to N and declare the sample size n sim as a positive integer number using the phrase int n sim.
I define the coefficients for the linear regression beta0 and beta1 (as two real values) and the standard deviation parameter sigma in the parameters block (as a positive real number).
I define the conditional mean mu (a real vector of length N) as a linear function of the intercept beta0, the slope beta1, and the covariate x in the converted parameters block.
Finally, in the model block, I give the regression coefficients and standard deviation parameters weakly informative priors, and I use a normal distribution indexed by the conditional mean mu and standard deviation sigma parameters to model the outcome data y.
STAN frequently employs sampling statements that can be vectorized, obviating the requirement for for loop expressions. 



For exposing me to this technique of writing statistical models, I give full thanks to McElreath's outstanding Statistical Rethinking (2020).
It's strange at first; I've become accustomed to model formulas being one-liners.
But if you get the hang of it, it's a really nice method to describe the model.


The parameters are then given priors.
Before we run the model, we use priors to represent our knowledge and uncertainty about the data.
We don't employ priors to achieve a specific goal; we use them because they make sense. Without priors, our model assumes that the data came from a normal distribution with a mean of 0 and sigma of 1 as it does from a distribution with a mean of 1 and sigma of 0. 

### Fit the model

We'll need to organise the information into a list for Stan.
This list should contain everything we defined in the data block of our Stan code.
We'll additionally normalise the variables to make sure they match our priors.
Finally, we run the model with the stan function.
We set chains and cores to four, allowing us to run four Markov chains simultaneously.


Now we can use the stan function in the rstan package to fit the model in STAN and save it in the object.



### MCMC diagnostics

For Bayesian analysis, it is required to investigate the properties of the MCMC chains and the sampler in general, in addition to the standard model diagnostic checks (such as residual plots). Remember that the goal of MCMC sampling is to reproduce the posterior distribution of the model likelihood and priors by randomly selecting a set of samples from it (thereby formulating a probability distribution). Only if the MCMC samples accurately reflect the posterior is this method reliable. Unfortunately, because we only know the posterior in the most rudimentary of situations, we must rely on indirect metrics of how well MCMC samples are likely to reflect the likelihood. I'll give a quick rundown of the most critical diagnoses. For each parameter, traceplots show the MCMC sample values after each iteration along the chain. Bad chain mixing (any pattern) indicates that the MCMC sample chains may not have spanned all aspects of the posterior distribution and that further iterations are needed to ensure that the distribution is accurately represented.

Each parameter's autocorrelation graphic shows the degree of correlation between MCMC samples separated by different lags. The degree of correlation between each MCMC sample and itself, for example, is represented by a lag of (obviously this will be a correlation of ). There is a lag of 

reflects the degree of correlation between each MCMC sample and the sample after that in the chain, and so on. The MCMC samples should be independent in order to obtain unbiased parameter estimations (uncorrelated).

For each parameter, the potential scale reduction factor (Rhat) statistic offers a measure of sampling efficiency/effectiveness. All values should, in theory, be less than. If the sampler has values of or greater, it is likely that it was not particularly efficient or effective. Not only does this imply that the sampler was maybe slower than it could have been, but it also implies that the sampler spent time sampling in a less informative section of the likelihood. A misspecified model or extremely unclear priors that allow sampling in otherwise nonscence parameter space might lead to this predicament.

We should have looked at the convergence diagnostics before looking at the summaries. For the effects model, we utilise the package mcmcplots to generate density and trace graphs. 


It's crucial to evaluate if the chains have converged when using MCMC to fit a model. To visually inspect MCMC diagnostics, we propose the bayesplot software. The bayesplot package includes routines for displaying MCMC diagnostics and supports model objects from both rstan and rstanarm. We'll show how to make a trace plot with the mcmc trace() function and a plot of Rhat values with the mcmc rhat() function.

Let's start by making trace graphs with mcmc trace (). Over the MCMC iterations, a trace plot depicts the sampled values of the parameters. The trace plot should look like a random scatter around a mean value if the model has converged. There is indication of a problem if the chains snake about the parameter space or converge to different values. 

By printing the model fit, we can examine the parameters in the console. For each parameter, we derive posterior means, standard errors, and quantiles. n eff and Rhat are two other terms we use. These are the results of Stan's engine's exploration of the parameter space. For the time being, it's enough to know that when Rhat is 1, everything is well.

### Parting thoughts


In this post, we learned how to adapt our models to non-normal data, which is rather common. STAN is quite flexible, allowing many alternative parametrization for many different distributions (see the reference book), and the possibilities are only limited by your hypothesis (and perhaps a little bit by your mathematical ability...). I'd like to point out that the rstanarm package makes it possible to fit STAN models without having to write them down. Instead of utilising standard R syntax, such as that found in a glm call (see this post).So, what's the point of learning all this STAN jargon? It depends: if you're merely fitting "classical" models to your data with no fanfare, just use rstanarm; it'll save you time and the models in this package are unquestionably better parametrized (i.e. faster) than the one I presented here. Learning STAN, on the other hand, is a good approach to get into a very flexible and strong language that will continue to evolve if you believe you will need to fit your own bespoke models one day.rstanarm is a package that acts as a user interface for Stan on the front end. It enables R users to create Bayesian models without needing to learn how to code in Stan. Using the standard formula and data, you can fit a model in rstanarm. frame syntax (similar to lm()) This shorter syntax is achieved via rstanarm, which provides pre-compiled Stan code for commonly used model types. It's simple to use, although it's limited to a few "popular" model kinds. If you want to use rstan to fit a different model type, you'll have to code it yourself.


The prefix stan_ precedes the model fitting functions and is followed by the model type. stan glm() and stan glmer() are two instances (). A complete list of rstanarm functions can be found here. Two arguments are required for the modelling functions: 
- formula: (y x1 + x2) is a formula that identifies the dependent and independent variables. 
- data: A data-frame containing the formula's variables. 

There is also an optional prior argument that can be used to modify the default prior distributions.

### Conclusions Summary

We learned how to fit normal regression using STAN and how to get a collection of useful summaries from the models in this post.
The STAN model provided here should be quite adaptable, and it should be able to accommodate datasets of various sizes.
Before fitting the models, remember to normalise the explanatory variables.
This is just a taste of the many models that STAN can fit; in future postings, we'll look at generalised linear models, as well as non-normal models with various link functions and hierarchical models.

This tutorial provided only a quick overview of how to fit simple linear regression models with the Bayesian software STAN and the rstan library.
Although this may appear to be a more difficult technique than just fitting a linear model in a frequentist framework, the real benefits of Bayesian methods become apparent as the analysis becomes more sophisticated (which is often the case in real applications).
Indeed, the flexibility of Bayesian modelling makes it very simple to account for increasingly complicated models.
Furthermore, Bayesian approaches are suitable for taking into consideration the potential impact of many sources of uncertainty on the final conclusions, as they allow for natural uncertainty propagation throughout each paramether. 


## References

+ [Stan Functions Reference](https://mc-stan.org/docs/2_18/functions-reference/)

+ [Stan Users Guide](https://mc-stan.org/docs/2_29/stan-users-guide/index.html#overview)

+ [Some things i've learned about stan](https://www.alexpghayes.com/blog/some-things-ive-learned-about-stan/)

+ [Introduction to STAN](https://agabrioblog.onrender.com/stan/page/2/)

+ [Simple Linear Regression in STAN](https://agabrioblog.onrender.com/tutorial/simple-linear-regression-stan/simple-linear-regression-stan/)

+ [Multiple linear regression in Stant](http://webpages.math.luc.edu/~ebalderama/bayes_resources/code/mlr_stan.html)

+ [Hernan Book Liner Regression in Stan](https://rpubs.com/kaz_yos/stan-lm1)

+ [Bayesian regression with STAN: Part 1 normal regression](https://datascienceplus.com/bayesian-regression-with-stan-part-1-normal-regression/)

+ [Bayesian regression with STAN: Part 2 beyond normality](https://datascienceplus.com/bayesian-regression-with-stan-beyond-normality/)

+ [Bayesian Varying Effects Models in R and Stan](https://willhipson.netlify.app/post/stan-random-slopes/varying_effects_stan/)

+ [Introduction to rstan and rstanarm](https://blog.methodsconsultants.com/posts/introduction-to-stan-in-r/)

+ [Stan (+R) Workshop](https://rpruim.github.io/StanWorkshop/)
