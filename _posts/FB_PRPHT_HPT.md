---
layout: post
categories: posts
title: Forecsting with FB prophet
featured-image: /images/ABS.png
tags: [Forecasting, R, Prophet]
date-string: February 2022
---

## Introduction


Time series modeling
Time series is a big topic in machine learning space and exists in practically all the industries, and, all hands down, is a problem that every data scientist will face on their career..
Besides the basic of the task, there are a lot of ways of facing and finding models for describing the underlying dynamic of a time series. For example, there’s a lot of classical models, such as space state models (Arima, Armas, etc…), and the use of trees based algorithms as well. In this article, we are going to discuss the use of one tool which is one of the easiest and yet powerful ways of working with time series, prophet, a Facebook library which:
Prophet is a procedure for forecasting time series data based on an additive model where non-linear trends are fit with yearly, weekly, and daily seasonality, plus holiday effects. It works best with time series that have strong seasonal effects and several seasons of historical data. Prophet is robust to missing data and shifts in the trend, and typically handles outliers well.
For getting the best model that prophet can offer, we need to adjust the parameters of the model. The classic way of finding the best combination of parameters is doing a grid search(random search or a cartesian search), but this can be too time-expensive, specially when we are validating the models using a large number of folds during cross-validation.
An excellent alternative for saving some time and doing a smarter search in the parameters space is doing a bayesian search, which will focus on the areas of parameter’s space that have a better value in our objective function. There are some libraries which can do the bayesian search, but we will focus in optuna, a really good and easy-to-use library. Among the key features of optuna, these are the main ones:
Eager search space: Automated search for optimal hyperparameters using Python conditionals, loops, and syntax.
State-of-art algorithms: Efficiently search large spaces and prune unpromising trials for faster results.
Easy parallelization: Parallelize hyperparameter searches over multiple threads or processes without modifying code.


## References

+ [Implementing Facebook Prophet efficiently](https://towardsdatascience.com/implementing-facebook-prophet-efficiently-c241305405a3)

+ [Time series analysis using Prophet in Python — Part 2: Hyperparameter Tuning and Cross Validation](https://medium.com/analytics-vidhya/time-series-analysis-using-prophet-in-python-part-2-hyperparameter-tuning-and-cross-validation-88e7d831a067)

+ [Time series parameters finding using Prophet and Optuna bayesian optimization](https://medium.com/spikelab/time-series-parameters-finding-using-prophet-and-optuna-bayesian-optimization-e618614bd8b7)
