---
layout: post
categories: posts
title: Forecsting with FB prophet
featured-image: /images/ABS.png
tags: [Forecasting, R, Prophet]
date-string: February 2022
---

## Introduction

In this third tutorial about time series we explore the Facebook Prophet forecasting algorithm. Similarly to the previous tutorial about SARIMAX models we do so in a way that you can start applying it and go further exploring it with different use cases.

In this section we introduce Facebook Prophet. Here you get the basics for building your first model with Facebook’s advanced forecasting tool and go further exploring it.

To illustrate how Prophet works we apply it to forecast sales using the same dataset used in the tutorial where we introduced SARIMAX models.

Facebook Prophet  is open-source library released by Facebook’s Core Data Science team. It is available in R and Python.

Prophet is a procedure for univariate (one variable) time series forecasting data based on an additive model, and the implementation supports trends, seasonality, and holidays. It works best with time series that have strong seasonal effects and several seasons of historical data. Prophet is robust to missing data and shifts in the trend, and typically handles outliers well.

It is specially interesting for new users because of its easy use and capacity of find automatically a good set of hyperparameters for  the model. Therefore, it allows users without prior knowledge or experience of forecasting time series data start using it and get reasonably good results that are often equal or sometimes even better than the ones produced by the experts.

Prophet requires as input a dataframe with two columns:

ds: datetime column.
y: numeric column which represents the measurement we wish to forecast.
Our data is almost ready. We just need to rename columns date and sales, respectively, as ds and y.

To train a model in Prophet, first we create an instance of the model class and then we call the fit method.

In principle, you don’t need to specify any hyparameters. One important exception is seasonality_mode. It is important to set this parameter to multiplicative if your model is multiplicative since Prophet is based on an additive model. As we saw previously, the seasonality in our model follows an additive behavior. Therefore, there is no need to set seasonality_mode as multiplicative.

Although Prophet is able to find automatically a good set of hyperparameters, we will see later that some fine tuning can improve performance. Specially, applying your knowledge of the business case might make a huge difference even if Prophet has the power of handling many things by itself.

Just to exemplify, I’ll include the parameter interval_width that sets the confidence interval.

In order to forecast we first need to create a dataframe that will save our predictions. Method make_future_dataframe builds a dataframe that extends into the future a specified number of days. In our case, we will predict 90 days into the future.

By default the dataframe created includes the dates from the history, so we see the model fit as well.

To make predictions we apply method predict on the future dataframe that we have just generated.

Forecast Dataframe
The forecast dataframe contains Prophet’s prediction for sales. Because we’ve also passed historical dates, it provides an in-sample fit that we can use to evaluate our model.

As you can see, forecast includes a column yhat with the forecast, as well as columns for components and uncertainty intervals.

Forecast Plot
To plot the forecast you just need to call method .plot() on your forecast dataframe.

In the forecast plot above, deep blue line is forecast sales forecast[‘y_hat’], black dots are actual sales forecast[‘y’]. The light blue shade is 95% confidence interval around the forecast. The uncertainty interval in this region is bounded by forecast[‘yhat_lower’] and forecast[‘yhat_upper’] values.

Trend Changepoints
Real life time series such as this one, frequently have abrupt changes in their trajectories. These changepoints sign abrupt changes in the time series caused, for instances, by new product launch, unforeseen calamity. Prophet will automatically detect these changepoints and will allow the trend to adapt appropriately. At these points, the growth rate is allowed to change making the model more flexible. This may cause overfitting or underfitting.

A parameter called changepoint_prior_scale could be used to adjust the trend flexibility and tackle overfitting and underfitting. Higher value fits a more flexible curve to the time series.

By default changepoints are only inferred for the first 80% of the time series, but you can change it by making use of the changepoint_range argument of the model.

It is also possible to add your own changepoints manually, using the changepoints argument.

If you want to know more about changepoints and Prophet check this out.

In the plot below, the dotted lines represent the changepoints for the given time series.

We can observe the following on the forecast components plotted above:

Trend component: Trend upwards. 

Weekly seasonality component: The weekly seasonality shows that people buy more on weekends. In particular, we observe a drop on sales from Sunday to Monday. This might point to a holiday effect.

Yearly seasonality component: As observed previously the volume of sales is higher in July and lower in January. This peak in sales in July might mean seasonal sales with high discount prices.

Holidays, special events, as well as seasonality can be explored to improve your model. For more information on how to use this information check Prophet’s documentation section Seasonality, Holiday Effects, And Regressors.

Evaluate model
How this model is performing?

The forecast dataframe includes predictions made on the training data dates. Therefore, we can use this in-sample fit to evaluate our model.


#############################################


Using Open Source Prophet Package to Make Future Predictions in R
Almost every company wishes to answer where they will be one week/month/year from now.
The answers to those questions can be valuable when planning the company’s infrastructure, KPIs (key performance indicators) and worker goals.
Hence, using data forecasting tools are one of the common tasks data professionals are being asked to take on.
One tool which was recently released as an open source is Facebook’s time series forecasting package Prophet. Available both for R and Python, this is a relatively easy to implement model with some much needed customization options. 
In this post I’ll review Prophet and follow it by a simple R code example. This code flow is heavily inspired from the official package users guide.
We will use an open data set extracted from wikishark holding daily data entrances to LeBron James Wikipedia article page. Next, we will build daily predictions based on historical data.
* wikishark was closed after the release of the article. you can use another useful site to get the data.
Phase 1 — Install and import prophet



#############################################

Introduction
Understanding time based patterns is critical for any business. Questions like how much inventory to maintain, how much footfall do you expect in your store to how many people will travel by an airline – all of these are important time series problems to solve.

This is why time series forecasting is one of the must-know techniques for any data scientist. From predicting the weather to the sales of a product, it is integrated into the data science ecosystem and that makes it a mandatory addition to a data scientist’s skillset.

If you are a beginner, time series also provides a good way to start working on real life projects. You can relate to time series very easily and they help you enter the larger world of machine learning.

Prophet is an open source library published by Facebook that is based on decomposable (trend+seasonality+holidays) models. It provides us with the ability to make time series predictions with good accuracy using simple intuitive parameters and has support for including impact of custom seasonality and holidays!

In this article, we shall cover some background on how Prophet fills the existing gaps in generating fast reliable forecasts followed by a demonstration using Python. The final results will surprise you!

What’s new in Prophet?
When a forecasting model doesn’t run as planned, we want to be able to tune the parameters of the method with regards to the specific problem at hand. Tuning these methods requires a thorough understanding of how the underlying time series models work. The first input parameters to automated ARIMA, for instance, are the maximum orders of the differencing, the auto-regressive components, and the moving average components. A typical analyst will not know how to adjust these orders to avoid the behaviour and this is the type of expertise that is hard to acquire and scale.

The Prophet package provides intuitive parameters which are easy to tune. Even someone who lacks expertise in forecasting models can use this to make meaningful predictions for a variety of problems in a business scenario.

The Prophet Forecasting Model
We use a decomposable time series model with three main model components: trend, seasonality, and holidays. They are combined in the following equation:

g(t): piecewise linear or logistic growth curve for modelling non-periodic changes in time series
s(t): periodic changes (e.g. weekly/yearly seasonality)
h(t): effects of holidays (user provided) with irregular schedules
εt: error term accounts for any unusual changes not accommodated by the model
Using time as a regressor, Prophet is trying to fit several linear and non linear functions of time as components. Modeling seasonality as an additive component is the same approach taken by exponential smoothing in Holt-Winters technique . We are, in effect, framing the forecasting problem as a curve-fitting exercise rather than looking explicitly at the time based dependence of each observation within a time series.

Trend
Trend is modelled by fitting a piece wise linear curve over the trend or the non-periodic part of the time series. The linear fitting exercise ensures that it is least affected by spikes/missing data.

Saturating growth

An important question to ask here is – Do we expect the target to keep growing/falling for the entire forecast interval?

More often than not, there are cases with non-linear growth with a running maximum capacity. I will illustrate this with an example below.

Let’s say we are trying to forecast number of downloads of an app in a region for the next 12 months. The maximum downloads is always capped by the total number of smartphone users in the region. The number of smartphone users will also, however, increase with time.

With domain knowledge at his/her disposal, an analyst can then define a varying capacity C(t) for the time series forecasts he/she is trying to make.

 

Changepoints

Another question to answer is whether my time series encounters any underlying changes in the phenomena e.g. a new product launch, unforeseen calamity etc.  At such points, the growth rate is allowed to change. These changepoints are automatically selected. However, a user can also feed the changepoints manually if it is required. In the below plot, the dotted lines represent the changepoints for the given time series.

As the number of changepoints allowed is increased the fit becomes more flexible. There are basically 2 problems an analyst might face while working with the trend component:

Overfitting
Underfitting
A parameter called changepoint_prior_scale could be used to adjust the trend flexibility and tackle the above 2 problems. Higher value will fit a more flexible curve to the time series.

 

Seasonality
To fit and forecast the effects of seasonality, prophet relies on fourier series to provide a flexible model. Seasonal effects s(t) are approximated by the following function:
P is the period (365.25 for yearly data and 7 for weekly data)

The fourier order N that defines whether high frequency changes are allowed to be modelled is an important parameter to set here. For a time series, if the user believes the high frequency components are just noise and should not be considered for modelling, he/she could set the values of N from to a lower value. If not, N can be tuned to a higher value and set using the forecast accuracy.

 
Holidays and events
Holidays and events incur predictable shocks to a time series. For instance, Diwali in India occurs on a different day each year and a large portion of the population buy a lot of new items during this period.

Prophet allows the analyst to provide a custom list of  past and future events. A window around such days are considered separately and additional parameters are fitted to model the effect of holidays and events.

## References

+ [Forecasting with Facebook Prophet: An Intro](https://jadsmkbdatalab.nl/forecasting-with-facebook-prophet-models-an-intro/)

+ [Using Open Source Prophet Package to Make Future Predictions in R](https://towardsdatascience.com/using-open-source-prophet-package-to-make-future-predictions-in-r-ece585b73687)

+ [A Quick Start of Time Series Forecasting with a Practical Example using FB Prophet](https://towardsdatascience.com/a-quick-start-of-time-series-forecasting-with-a-practical-example-using-fb-prophet-31c4447a2274)

+ [Generate Quick and Accurate Time Series Forecasts using Facebook’s Prophet (with Python & R codes)](https://www.analyticsvidhya.com/blog/2018/05/generate-accurate-forecasts-facebook-prophet-python-r/)

+ [Tutorial: Time Series Forecasting with Prophet](https://www.kaggle.com/prashant111/tutorial-time-series-forecasting-with-prophet)
