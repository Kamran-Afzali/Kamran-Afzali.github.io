---
layout: post
categories: posts
title: Bayesian Regression Models for Non-Normal Data
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: June 2022
---


## Introduction
In this post, we will explore frequentist and Bayesian analogues of regularized/penalized linear regression models (e.g., LASSO [L1 penalty], Ridge regression [L2 penalty]), which are an extention of traditional linear regression models of the form:

 
where  is the error, which is normally distributed as:

 
Unlike these traditional linear regression models, regularized linear regression models produce biased estimates for the  weights. Specifically, both frequentist and Bayesian regularized linear regression models pool information across  weights, resulting in regression toward a common mean. When the common mean is centered at 0, this pooling of information produces more conservative estimates for each  weight (they are biased toward 0). In contrast, traditional linear regression models assume that  weights share no group-level information (i.e. they are independent), which leads to so-called unbiased estimates.




## References

[Ref1](http://haines-lab.com/post/2019-05-06-on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/on-the-equivalency-between-the-lasso-ridge-regression-and-specific-bayesian-priors/)

https://jrnold.github.io/bayesian_notes/shrinkage-and-regularized-regression.html

http://ccgilroy.com/csss564-labs-2019/08-regularization/08-regularization.html
