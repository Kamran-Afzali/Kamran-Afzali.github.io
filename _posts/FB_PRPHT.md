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
We use a decomposable time series model with three main model components: trend, seasonality, and holidays. They are combined in the following equation:

g(t): piecewise linear or logistic growth curve for modelling non-periodic changes in time series
s(t): periodic changes (e.g. weekly/yearly seasonality)
h(t): effects of holidays (user provided) with irregular schedules
εt: error term accounts for any unusual changes not accommodated by the model
Using time as a regressor, Prophet is trying to fit several linear and non linear functions of time as components. Modeling seasonality as an additive component is the same approach taken by exponential smoothing in Holt-Winters technique . We are, in effect, framing the forecasting problem as a curve-fitting exercise rather than looking explicitly at the time based dependence of each observation within a time series.

### Trend
Trend is modelled by fitting a piece wise linear curve over the trend or the non-periodic part of the time series. The linear fitting exercise ensures that it is least affected by spikes/missing data.

### Saturating growth

An important question to ask here is – Do we expect the target to keep growing/falling for the entire forecast interval?

More often than not, there are cases with non-linear growth with a running maximum capacity. I will illustrate this with an example below.

Let’s say we are trying to forecast number of downloads of an app in a region for the next 12 months. The maximum downloads is always capped by the total number of smartphone users in the region. The number of smartphone users will also, however, increase with time.

With domain knowledge at his/her disposal, an analyst can then define a varying capacity C(t) for the time series forecasts he/she is trying to make.

### Changepoints

Another question to answer is whether my time series encounters any underlying changes in the phenomena e.g. a new product launch, unforeseen calamity etc.  At such points, the growth rate is allowed to change. These changepoints are automatically selected. However, a user can also feed the changepoints manually if it is required. In the below plot, the dotted lines represent the changepoints for the given time series.

As the number of changepoints allowed is increased the fit becomes more flexible. There are basically 2 problems an analyst might face while working with the trend component:

 
### Seasonality
To fit and forecast the effects of seasonality, prophet relies on fourier series to provide a flexible model. Seasonal effects s(t) are approximated by the following function:
P is the period (365.25 for yearly data and 7 for weekly data)

The fourier order N that defines whether high frequency changes are allowed to be modelled is an important parameter to set here. For a time series, if the user believes the high frequency components are just noise and should not be considered for modelling, he/she could set the values of N from to a lower value. If not, N can be tuned to a higher value and set using the forecast accuracy.

 
### Holidays and events
Holidays and events incur predictable shocks to a time series. For instance, Diwali in India occurs on a different day each year and a large portion of the population buy a lot of new items during this period.

Prophet allows the analyst to provide a custom list of  past and future events. A window around such days are considered separately and additional parameters are fitted to model the effect of holidays and events.


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
