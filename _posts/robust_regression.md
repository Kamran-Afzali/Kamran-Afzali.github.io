---
layout: post
categories: posts
title: Bayesian Regression Models for Non-Normal Data
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: September 2022
---


## Robust t-regression 



Simple linear regression is a very popular technique for estimating the linear relationship between two variables based on matched pairs of observations, as well as for predicting the probable value of one variable (the response variable) according to the value of the other (the explanatory variable). When plotting the results of linear regression graphically, the explanatory variable is normally plotted on the x-axis, and the response variable on the y-axis.

The standard approach to linear regression is defining the equation for a straight line that represents the relationship between the variables as accurately as possible. The equation for the line defines y (the response variable) as a linear function of x (the explanatory variable):

𝑦 = 𝛼 + 𝛽𝑥 + 𝜀
In this equation, ε represents the error in the linear relationship: if no noise were allowed, then the paired x- and y-values would need to be arranged in a perfect straight line (for example, as in y = 2x + 1). Because we assume that the relationship between x and y is truly linear, any variation observed around the regression line must be random noise, and therefore normally distributed. From a probabilistic standpoint, such relationship between the variables could be formalised as

𝑦 ~ 𝓝(𝛼 + 𝛽𝑥, 𝜎)
That is, the response variable follows a normal distribution with mean equal to the regression line, and some standard deviation σ. Such a probability distribution of the regression line is illustrated in the figure below.

This formulation inherently captures the random error around the regression line — as long as this error is normally distributed. Just as with Pearson’s correlation coefficient, the normality assumption adopted by classical regression methods makes them very sensitive to noisy or non-normal data. This frequently results in an underestimation of the relationship between the variables, as the normal distribution needs to shift its location in the parameter space in order to accommodate the outliers in the data as well as possible. In a frequentist paradigm, implementing a linear regression model that is robust to outliers entails quite convoluted statistical approaches; but in Bayesian statistics, when we need robustness, we just reach for the t-distribution. This probability distribution has a parameter ν, known as the degrees of freedom, which dictates how close to normality the distribution is: large values of ν (roughly ν > 30) result in a distribution that is very similar to the normal distribution, whereas low small values of ν produce a distribution with heavier tails (that is, a larger spread around the mean) than the normal distribution. Thus, by replacing the normal distribution above by a t-distribution, and incorporating ν as an extra parameter in the model, we can allow the distribution of the regression line to be as normal or non-normal as the data imply, while still capturing the underlying relationship between the variables.

The formulation of the robust simple linear regression Bayesian model is given below. We define a t likelihood for the response variable, y, and suitable vague priors on all the model parameters: normal for α and β, half-normal for σ and gamma for ν.



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


https://baezortega.github.io/2018/08/06/robust_regression/

https://jrnold.github.io/bugs-examples-in-stan/resistant.html
