---
layout: post
categories: posts
title: Forecsting with FB prophet
featured-image: /images/ABS.png
tags: [Forecasting, R, Prophet]
date-string: March 2022
---

## Introduction

Any organisation must be able to recognise time-based patterns. Questions such as how much resources to keep on hand and how much traffic to expect are  crucial time series problems to address.  This is why time series forecasting is incorporated into the data science ecosystem, from weather prediction to product sales, making it a technique that every data scientist should be familiar with. It. If you're a beginner, time series is a great method to get started on real-world tasks. Time series are very easy to understand and relate to, and they assist you in entering the bigger world. Prophet is a Facebook-developed open source library based on decomposable (trend+seasonality+holidays) models. It allows us to construct accurate time series projections using simple understandable parameters, and it even allows us to factor in the influence of custom seasonality and holidays!  In this post, we'll go over some background on Prophet and how it fills in the gaps in making fast, credible forecasts, followed by a R example. 

## What is Prophet?

When a forecasting model fails to perform as expected, we want to be able to fine-tune the method's parameters to fit the unique scenario at hand. Tuning these strategies necessitates a detailed understanding of the time series models that underpin them. The maximum orders of the differencing, the auto-regressive components, and the moving average components, for example, are the first input parameters to automated ARIMA. A typical analyst would have no idea how to change these instructions to avoid the behaviour, and this is the kind of knowledge that is difficult to acquire and scale. 

The Prophet programme has intuitive parameters that are simple to tweak in order to create relevant predictions for a variety of business challenges.
Here you'll learn the fundamentals of using Facebook's sophisticated forecasting tool to develop your first model and then dive further into it. 
Prophet is a process for forecasting time series data using an additive model, with support for trends, seasonality, and holidays. It works best with time series with substantial seasonal influences and historical data from multiple seasons. Prophet is forgiving of missing data and trend shifts, and it usually handles outliers well. 

It appeals to novice users because of its ease of use and ability to identify an appropriate set of hyperparameters for the model automatically. As a result, even individuals with no prior knowledge or expertise forecasting time series data may use it and receive pretty decent results that are often on par with, if not better than, those provided by professionals.

Facebook Prophet is an open-source toolkit containing R and Python APIs developed by Facebook's Core Data Science team.


#############################################


## The Prophet Forecasting Model
Prophet employs a three-part decomposable time series model: trend, seasonality, and holidays. 

+ g(t): non-periodic changes in time series are modelled using a piecewise linear or logistic growth curve. 

+ s(t): regular changes (weekly/yearly seasonality, for example). 

+ h(t): the effects of holidays (given by the user) on irregular schedules. 

+ (t): error term accounts for any unexpected changes that the model does not account for.

Prophet is trying to fit numerous linear and non linear time functions as components using time as a regressor. Seasonality is modelled as an additive component in the same way that exponential smoothing is used in the Holt-Winters technique. Instead of directly looking at the time based dependence of each observation inside a time series, we are effectively framing the forecasting problem as a curve-fitting exercise.

### Trend

A piecewise linear curve is fitted over the trend or non-periodic section of the time series to model the trend. The linear fitting procedure ensures that spikes and missing data are minimised. 


### Saturating growth

Is it reasonable to expect the target to continue growing/falling throughout the duration of the prediction interval? There are frequently situations of non-linear development with a running maximum capacity.  An analyst can then define a variable capacity C(t) for the time series forecasts he or she is seeking to create using domain knowledge.

### Changepoints

Another point to address is whether my time series encounters any underlying changes in the phenomena, such as a new product launch, a natural disaster, or other unforeseen events. The growth rate is allowed to fluctuate at such times. These changepoints are chosen at random. However, if necessary, a user can manually feed the changepoints. The dotted lines in the plot below reflect the changepoints for the provided time series. 

The fit becomes more adjustable as the number of changepoints allowed increases. When working with the trend component, an analyst may encounter one of two issues.

### Seasonality

Prophet uses fourier series to fit and forecast the impacts of seasonality and give a flexible model. The following function approximates seasonal impacts s(t): 

The letter P stands for period (365.25 for yearly data and 7 for weekly data) 

An important parameter to choose here is the fourier order N, which determines whether high frequency variations can be represented. If the user considers the high frequency components in a time series are just noise and should not be included for modelling, he or she can reduce the amount of N. If not, N can be raised to a greater amount and the forecast accuracy used to set it.

 
### Holidays and events
Holidays and events cause predictable peaks and valleys in a time series. Diwali, for example, is celebrated on a different day each year in India, and a huge section of the population buys a lot of new products during this time. 

The analyst can create a custom list of past and future occurrences using Prophet. Additional parameters are fitted to model the effect of vacations and events in a window surrounding such days.


## Data 

Prophet requires as input a dataframe with two columns:

ds: datetime column.
y: numeric column which represents the measurement we wish to forecast.
Our data is almost ready. We just need to rename columns date and sales, respectively, as ds and y.

## Fit
To train a model in Prophet, first we create an instance of the model class and then we call the fit method.

In principle, you don’t need to specify any hyparameters. One important exception is seasonality_mode. It is important to set this parameter to multiplicative if your model is multiplicative since Prophet is based on an additive model. As we saw previously, the seasonality in our model follows an additive behavior. Therefore, there is no need to set seasonality_mode as multiplicative.

Although Prophet is able to find automatically a good set of hyperparameters, we will see later that some fine tuning can improve performance. Specially, applying your knowledge of the business case might make a huge difference even if Prophet has the power of handling many things by itself.

Just to exemplify, I’ll include the parameter interval_width that sets the confidence interval.

In order to forecast we first need to create a dataframe that will save our predictions. Method make_future_dataframe builds a dataframe that extends into the future a specified number of days. In our case, we will predict 90 days into the future.

By default the dataframe created includes the dates from the history, so we see the model fit as well.

To make predictions we apply method predict on the future dataframe that we have just generated.

## Forecast Dataframe

The forecast dataframe contains Prophet’s prediction for sales. Because we’ve also passed historical dates, it provides an in-sample fit that we can use to evaluate our model.

As you can see, forecast includes a column yhat with the forecast, as well as columns for components and uncertainty intervals.

## Forecast Plot

To plot the forecast you just need to call method .plot() on your forecast dataframe.

In the forecast plot above, deep blue line is forecast sales forecast[‘y_hat’], black dots are actual sales forecast[‘y’]. The light blue shade is 95% confidence interval around the forecast. The uncertainty interval in this region is bounded by forecast[‘yhat_lower’] and forecast[‘yhat_upper’] values.

## Trend Changepoints

Real life time series such as this one, frequently have abrupt changes in their trajectories. These changepoints sign abrupt changes in the time series caused, for instances, by new product launch, unforeseen calamity. Prophet will automatically detect these changepoints and will allow the trend to adapt appropriately. At these points, the growth rate is allowed to change making the model more flexible. This may cause overfitting or underfitting.

A parameter called changepoint_prior_scale could be used to adjust the trend flexibility and tackle overfitting and underfitting. Higher value fits a more flexible curve to the time series.

By default changepoints are only inferred for the first 80% of the time series, but you can change it by making use of the changepoint_range argument of the model.

It is also possible to add your own changepoints manually, using the changepoints argument.


In the plot below, the dotted lines represent the changepoints for the given time series.

We can observe the following on the forecast components plotted above:

## Seasonality

Weekly seasonality component: The weekly seasonality shows that people buy more on weekends. In particular, we observe a drop on sales from Sunday to Monday. This might point to a holiday effect.

Yearly seasonality component: As observed previously the volume of sales is higher in July and lower in January. This peak in sales in July might mean seasonal sales with high discount prices.

Holidays, special events, as well as seasonality can be explored to improve your model. For more information on how to use this information check Prophet’s documentation section Seasonality, Holiday Effects, And Regressors.

## Evaluate model
How this model is performing?

The forecast dataframe includes predictions made on the training data dates. Therefore, we can use this in-sample fit to evaluate our model.






## References

+ [Forecasting with Facebook Prophet: An Intro](https://jadsmkbdatalab.nl/forecasting-with-facebook-prophet-models-an-intro/)

+ [Using Open Source Prophet Package to Make Future Predictions in R](https://towardsdatascience.com/using-open-source-prophet-package-to-make-future-predictions-in-r-ece585b73687)

+ [A Quick Start of Time Series Forecasting with a Practical Example using FB Prophet](https://towardsdatascience.com/a-quick-start-of-time-series-forecasting-with-a-practical-example-using-fb-prophet-31c4447a2274)

+ [Generate Quick and Accurate Time Series Forecasts using Facebook’s Prophet (with Python & R codes)](https://www.analyticsvidhya.com/blog/2018/05/generate-accurate-forecasts-facebook-prophet-python-r/)

+ [Tutorial: Time Series Forecasting with Prophet](https://www.kaggle.com/prashant111/tutorial-time-series-forecasting-with-prophet)
