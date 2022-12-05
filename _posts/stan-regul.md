---
layout: post
categories: posts
title: Bayesian Regression Models for Non-Normal Data
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: June 2022
---


## Introduction
In this post, we will explore frequentist and Bayesian analogues of regularized/penalized linear regression models (e.g., LASSO [L1 penalty], Ridge regression [L2 penalty]), which are an extention of traditional linear regression models of the form.
In this chapter, we will discuss shrinkage and regularization in regression problems. These methods are useful for improving prediction, estimating regression models with many variables, and as an alternative to model selection methods.

 
Unlike these traditional linear regression models, regularized linear regression models produce biased estimates for the  weights. Specifically, both frequentist and Bayesian regularized linear regression models pool information across  weights, resulting in regression toward a common mean. When the common mean is centered at 0, this pooling of information produces more conservative estimates for each  weight (they are biased toward 0). In contrast, traditional linear regression models assume that  weights share no group-level information (i.e. they are independent), which leads to so-called unbiased estimates.


Shrinkage estimation deliberately increases the bias of the model in order to reduce variance and improve overall model performance, often at the cost of individual estimates (Efron and Hastie 2016, 91). Maximum likelihood estimation will produce asymptotically unbiased (consistent) estimates, given certain regularity conditions. However, the bias-variance tradeoff implies that generalization error can be decreased with a non-zero amount of bias. By adding bias to the model, shrinkage estimators provide a means to adjust the bias-variance in the model in order to achieve lower generalization error.

In the Bayesian estimation, shrinkage occurs as a result of hierarchical models. When parameters are modeled as exchangeable and given a proper prior, it induces some amount of shrinkage. Likewise, Bayesian models with non- or weakly-informative priors will produce similar to the MLE. But stronger priors can produce estimate much different estimtes than MLE.

Regularization describes any method that reduces variability in high dimensional estimation or prediction problems to allow estimation of unidentified or ill-posed questions or decrease overfitting or generalization error (Efron and Hastie 2016). Regularization can be thought of as the why and what of these methods, and shrinkage can be thought of as the how.


What do you do when you have a bunch of potential predictor variables or covariates? Do you experiment with different combinations, or throw them all into the same model?

If you do the latter, but impose some skepticism (i.e. regularization), you can wind up with better predictive models. One way of thinking about this is that you’re deliberately adding bias in order to reduce variance. Regularization helps avoid overfitting to your data, even as you include many variables.

You can think about regularized models from a penalized MLE approach or a Bayesian approach. The first perspective is common in machine learning. Instead of picking the coefficient values that minimize the residual sum of squares (RSS), you add a penalty for large coefficients:

From a Bayesian perspective, this turns out to be the same as putting a prior that encourages coefficients to shrink toward zero:

Because Bayesians care about posterior distributions, models that are mathematically the same don’t always have the same consequences (see the lasso section below). Remember that MLE values correspond to posterior modes, aka MAP estimates.






## References

[Ref1](http://haines-lab.com/post/2019-05-06-on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/)

https://jrnold.github.io/bayesian_notes/shrinkage-and-regularized-regression.html

http://ccgilroy.com/csss564-labs-2019/08-regularization/08-regularization.html
