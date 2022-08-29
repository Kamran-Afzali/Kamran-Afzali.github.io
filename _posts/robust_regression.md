---
layout: post
categories: posts
title: Time series clustering
featured-image: /images/FPR.png
tags: [Time series, DTW, R]
date-string: August 2022
---


## ROBUST T-REGRESSION
I’ve been experimenting with techniques for robust regression, and I thought that it would be a fun excercise to implement a robust variant of the simple linear regression model based on the t-distribution.

Motivation
The term “outlier” is used very loosely by most people. Usually, a field has a set of popular statistical models (e.g. I have two continuous variables, so I “do regression”), and these models make some kind normality assumption that has to be reluctantly glanced at before the model can be published. Invariably, the data don’t look quite normal, and one of two things tends to happen:

We trust in the central limit theorem to somehow “take care of it”.
We start prunning outliers.
Number two is problematic for several reasons: The first is that it’s usually done haphazardly, either by eyeballing it (the intra-ocular trauma test) or by using some cutoff that is, itself, not robust to outliers (e.g. “more than 3 standard deviation from the mean”). Second, it assumes that the extreme values are erroneous, and are not legitimate measurements. This is especially bad when it comes to response time data, which are never normal, even in theory, and yet people will still cut off the upper tail of the RT distribution and call it data cleanup.

In general, if you have a major problem with outliers that isn’t due to measurement error, you’re probably not defining “outlier” properly. Outliers are only outliers under some particular model (e.g. if you’re modelling the data as being normal, you’ll tend to interpret extreme values as being outliers, but those values might not be “extreme” under some other distribution). A better way to deal with outliers is to use a model that accomodates them. Example:



Like OLS, Bayesian linear regression with normally distributed errors is sensitive to outliers. This is because the normal distribution has narrow tail probabilities, with approximately 99.8% of the probability within three standard deviations.

Robust regression refers to regression methods which are less sensitive to outliers. Bayesian robust regression uses distributions with wider tails than the normal instead of the normal. This plots the normal, Double Exponential (Laplace), and Student-t  distributions all with mean 0 and scale 1, and the surprise  at each point. Both the Student- t and Double Exponential distributions have surprise values well below the normal in the ranges (-6, 6).11 This means that outliers will have less of an affect on the log-posterior of models using these distributions. The regression line would need to move less incorporate those observations since the error distribution will not consider them as unusual.

The most commonly used Bayesian model for robust regression is a linear regression with independent Student- 
t errors (Geweke 1993; A. Gelman, Carlin, et al. 2013, Ch. 17)  f you prefer distributions to points, it’s only slightly more difficult to make a Bayesian version of the model. I’ve included R and Stan code in the Downloads section for a simple Bayesian t-regression model with \nu unknown (Stan’s sampler has no problem estimating \nu along with everything else). The folder includes the .stan model file, an R function which fits the model and outputs a neat summary and some diagnostics (I haven’t really put any effort into error handling — sorry), and a short example file fitting the model to some simulated data. The priors are pretty uninformative, but you might need to change the uniform prior on \sigma depending on your data.



Outlying data points can distort estimates of location, such as means or regression coefficients.9 Location estimates obtained via maximizing a iid normal likelihood over heavy tailed data will be sensitive to data in the tails (outliers). A popular alternative to normal errors in regression analyses is the Student’s \(t\) density, with an unknown degrees of freedom parameter. For low degrees of freedom, the Student’s \(t\) distribution has heavier tails than the normal, but tends to the normal as the degrees of freedom parameter increases. Treating the degrees of freedom parameter as an unknown parameter to be estimated thus provides a check on the appropriateness of the normal. By embedding a model with location parameters in the Student’s \(t\) density, we obtain outlier-resistant estimates of location parameters.



https://jrnold.github.io/bugs-examples-in-stan/resistant.html


https://rpubs.com/jpn3to/outliers


