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

Goals
Understand shrinkage/regularization of coefficients as an alternative/complement to variable selection
Use three specific approaches to regularization—ridge, lasso, hierarchical shrinkage—which regularize through different priors, with different consequences for sparsity
Recognize connections between Bayesian regularized regression and regularized regression in a machine learning / penalized MLE framework



## Regularized Regression
As described above, regularized linear regression models aim to estimate more conservative values for the  weights in a model, and this is true for both frequentist and Bayesian versions of regularization. While there are many methods that can be used to regularize your estimation procedure, we will focus specifically on two popular forms—namely, ridge and LASSO regression. We start below by describing each regression generally, and then proceed to implement both the frequentist and Bayesian versions.


### Bayesian Ridge Regression

The extention from traditional to ridge regression is actually very straightforward! Specifically, we modify the loss function (equation 3) to include a penalty term for model complexity, where model complexity is operationalized as the sum of squared  weights.

Bayesian Ridge regression differs from the frequentist variant in only one way, and it is with how we think of the  penalty term. In the frequentist perspective, we showed that  effectively tells our model how much it is allowed to learn from the data. In the Bayesian world, we can capture such an effect in the form of a prior distribution over our  weights. To reveal the extraordinary power hiding behind this simple idea, let’s first discuss Bayesian linear regression.

Bayesian models view estimation as a problem of integrating prior information with information gained from data, which we formalize using probability distributions. This differs from the frequntist view, which treats regression as an opimization problem that results in a point estimate (e.g., minimizing squared error). Importantly, Bayesian models require us to specify a prior distribution for each parameter we seek to estimate. Therefore, we need to specify a prior on the intercept (), slopes (), and error variance () in equation 5. Since we are standardizing all of our predictors and outcome variable(s), we will ignore the intercept term. Then, we are left with  and . Crucially, our choice of prior distribution on  is what determines how much information we learn from the data, analagous to the penalty term  used for frequentist regularization.

### Bayesian LASSO Regression

Now that we have covered ridge regression, LASSO regression only involves a minor revision to the loss function. Specifically, as opposed to penalizing the model based on the sum of squared  weights, we will penalize the model by the sum of the absolute value of  weights. 
Recall that for Bayesian ridge regression, we only needed to specifiy a normal prior distribution to the  weights that we were aiming to regularize. For Bayesian LASSO regression, the only difference is in the form of the prior distribution. Specifically, setting a Laplace (i.e. double-exponential) prior on the  weights is mathematically equivalent in expectation to the frequentist LASSO penalty.

Compared to the ridge prior, which is a normal distribution, it is clear that the Laplace distribiution places much more probability mass directly on 0, which produces the variable selection effect specific to LASSO regression. Note also that such peakedness explains why there are sharp corners in the frequentist penalty function (see the LASSO contour plot above).

Below is the Stan code that specifies this Bayesian variant of LASSO regression.


### Hierarchical shrinkage
The Bayesian lasso doesn’t get us sparsity, but can we get there? What kinds of prior shapes would encourage sparsity? (That is, a few relatively large coefficients, and many coefficients very close to zero.)

We can use different global-local scale mixtures of normal distributions as our priors to encourage more sparsity. (You’ve seen the Student-T distribution is one of these scale mixtures, and the lasso is actually one of them too.)

We combine the global scale for the coefficient priors, tau, with a local scale lambda. (Sorry, there aren’t enough Greek letters to go around…)

### Comparing the Models
Comparing the Models
So far, we have described and fit both the frequentist and Bayesian versions of ridge and LASSO regression to our training data, and we have shown that we can make pretty outstanding predictions on our held-out test set! However, we have not explored the parameters that each model has estimated. Here, we will begin to probe our models.


## Conclusion 
In this post, we learned about the benefits of using regularized/penalized regression models over traditional regression. We determined that in low and/or noisy data settings, the so-called unbiased estimates given by traditional regression modeling actually lead to worse-off model performance. Importantly, we learned that this occurs because being ubiased allows a model to learn a lot from the data, including learning patterns of noise. Then, we learned that biased methods such as ridge and LASSO regression restrict the amount of learning that we get from data, which leads to better estimates in low and/or noisy data settings.

Finally, we saw that hierarchical Bayesian models actually contain frequentist ridge and LASSO regression as a special case—namely, we can choose a prior distribution across the  weights that gives us a solution that is equivalent to that of the frequentist ridge or LASSO methods! Not only that, but Bayesian regression gives us a full posterior distribution for each parameter, thus circumventing problems with frequentist regularization that require the use of bootstrapping to estimate confidence intervals.

## References

[Ref1](http://haines-lab.com/post/2019-05-06-on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/)

https://jrnold.github.io/bayesian_notes/shrinkage-and-regularized-regression.html

http://ccgilroy.com/csss564-labs-2019/08-regularization/08-regularization.html

https://github.com/ccgilroy/csss564-labs-2019


