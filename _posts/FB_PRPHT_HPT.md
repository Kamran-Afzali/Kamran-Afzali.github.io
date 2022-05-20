---
layout: post
categories: posts
title: Forecsting with FB prophet
featured-image: /images/ABS.png
tags: [Forecasting, R, Prophet]
date-string: February 2022
---

## Introduction

Time series is a huge topic in machine learning, and it appears in almost every industry. It is, without a doubt, a problem that every data scientist will face at some point in their career. Aside from the fundamentals of the work, there are other approaches and models for characterising the underlying dynamic of a time series. There are several traditional models, such as space state models (Arima, Armas, etc.) and the usage of tree-based algorithms, for example. In this article, we'll look at how to use one tool that's one of the simplest and most powerful ways to work with time series:Prophet is a Facebook library that is used to forecast time series data using an additive model that fits non-linear trends with yearly, monthly, and daily seasonality, as well as holiday effects. It works best with time series with substantial seasonal effects and historical data from multiple seasons. Prophet is forgiving of missing data and trend alterations, and it usually handles outliers well.


We must tweak the model's parameters in order to acquire the greatest model Prophet has to offer. A grid search (random search or cartesian search) is the traditional approach of determining the optimal combination of parameters, although this can be time-consuming, especially when cross-validating models with a large number of folds. 
A bayesian search, which focuses on the areas of parameter space that have a higher value in our objective function, is a great way to save time and execute a smarter search in the parameters space. There are a few libraries that can perform bayesian searches, but we'll focus on optuna, which is a fantastic and simple to use library. These are the most important characteristics of optuna: 
Space for eager search: Python conditionals, loops, and syntax are used to automate the search for ideal hyperparameters. 
Cutting-edge algorithms: For speedier results, efficiently explore wide areas and prune unpromising trials. 
Parallelize hyperparameter searches across several threads or processes without changing the code.


### Basic Prophet model
Prophet may now be used to analyse our data. To begin, we must guarantee that our date is in datetime format by using pd.to datetime. Second, the columns must be renamed to the Prophet-required names of ds and y. 
We can then build a Prophet object m, fit our data into the model, generate future predictions, visualise the forecast, and perform cross validation to check how well the model fits.

### Hyperparameter tuning
The previous model used all of the default parameters because no parameters were specified. Check out my earlier article to learn about Prophet's default parameters. 
We create a param grid with all of the parameters and values we wish to cycle over, calculate the mean value of the performance matrix, and find the optimum parameter combination in terms of MAPE. The following syntax is based on this notebook, with minor changes.


### Parallel computing
Dask can be used in the backend of the cross validation process to perform parallel computation. Following are some examples: 1st example, 2nd example When calling the cross validation method, we only need to include parallel="dask."
The grid search can take a long time to complete.
Dask can also be used to distribute the task to numerous workers and accelerate the process.
This notebook demonstrates how to perform hyperparameter tuning in task.
### Hyperparameter tuning


#### How can we measure the performance of our model?



Prophet includes a built-in cross validation feature, which is one of the numerous hidden mysteries that is not immediately apparent when first using it.
This function will take your data and train the model over the specified time period.
It will then forecast a time frame that you specify.
Prophet will then train your data over a longer period of time, then predict, and so on until the end point is reached. 
Let's use the data from the last example to fit the Prophet model out of the box.
In the example, I wrote my own mean absolute percentage error (MAPE) function and used it on the test data to describe the model performance in a single value.

We import the cross validation function from Prophet and apply it to our data, as you can see in the code above.
This gives us a dataframe with the predicted and true values for all of our predicted points, which we can use to determine the error. 

We receive a MAPE of 15.32 percent after running the code above.
This means that we are 15.32 percent off from the true value on average across all forecasted points.
For the rest of this article, I'll go over each hyper parameter and what you should consider while setting its value.


#### Optimizing the model

The first rule of model optimization is to avoid changing values and creating large for loops, or putting your model into a gridsearch to optimise hyper parameters.
Rather, bringing them into the proper zone will yield the greatest benefit.
This is done by looking at the data and understanding what your model will do with it as each parameter is changed. 
#### Growth
This parameter is  easiest to understand and implement because you can know what the data should be just by plotting the data. If you are graphing your data and you see a tendency to continue to grow without real insight into saturation  (or if  domain experts say there is no saturation to worry about), then this parameter should be linear. Set. If you draw it and  see a curve that promises to saturate (or if you're working on a value that you know needs to be saturated, such as CPU utilization), set it to Logistics. The tricky part of this parameter happens when you decide to use logistic growth. Then specify the upper and lower bounds of the prediction (the maximum that the data can reach), the lower bound (the minimum that the data can reach), and the historical data. It is better to do it. These upper and lower limits can change over time or be fixed values that you always enter. This is one of the most useful cases when talking to a domain expert. You have a very good idea of what to expect a year ahead and what will be impossible in a given period of time. After talking to them, you can over time provide much more accurate upper and lower limits. However, without a domain expert, we found that 65% of the initial values worked well with the minimum values. You can then set the cap to a relatively high price, but it's still within common sense. Therefore, if you are predicting the number of visits to your website and are currently 100,000, do not set the limit to 200,000,000 as it is likely that you  will not reach the limit within the predicted time. Do something smarter like 500,000 and let the cap grow slowly over time.
#### Holidays
A holiday is a period during which the day has the same impact each year. For example, if you want to model the number of subscribers in a city where people move during vacation, you can use the holiday parameter to enter the vacation date in the model. The tricky part happens when you're not modeling your daily data. One of the mistakes I made was to enter the vacation as a daily date when trying to model an hourly date. This slowed down the model's performance as it struggled to get the holiday dates to the correct shape. It is important to make sure that the vacation date is in the same format as the target date. You  also need to be able to provide  holiday dates for the expected period. That is, holidays can only be hours / dates / days that you know in advance. Another parameter that handles holidays is holidays_prior_scale. This parameter determines how  holidays affect forecasts. For example, if you're dealing with population forecasts and you know that holidays  have a big impact, try big values. Values ​​between 20 and 40 usually work. Otherwise, the default value of 10 usually works very well. As a last resort, you can lower it to see the effect, but I've never found this to increase  MAPE.
#### Changepoints
A changing point is a point in the  data where a sudden and abrupt change in the trend occurs. An example of this is a campaign that suddenly increases the number of visitors to your website by 50,000. The point of change is the time frame in which this major change occurred.  There are four changepoint hyperparameters: changepoints, n_changepoints, changepoint_range, and changepoint_prior_scale. Changepoint parameters are used to specify the date of the changepoint rather than letting the Prophet determine the date of the changepoint. If you specify your own changes, Prophet will not estimate any further changes. Therefore, it is important to know what you are doing. From my experience, I've found that having Prophet detect them myself and  changing the number of changepoints (using n_changepoints) gives the best results. As for the number of switching points to choose, it is recommended that you have good results with at least one switching point per month if you have hourly data. However,  depending on your use case,  this can be a good start.  changepoint_range usually does not have a significant impact on performance. Leaving the default values ​​gave the best results, but  if anyone finds a case that makes a difference when changing  from 0.8, I'd love to hear from you in the comments. Another parameter, changepoint_prior_scale, specifies the flexibility of the changes. That is, it shows how well the change point fits the data. Higher levels give you  more flexibility, but  can lead to overfitting. We have found that values ​​between 10 and 30 work, depending on  the volatility of the data.
#### Seasonalities
It is these parameters that make the Prophet shine, as  changing  a few values ​​can make a big improvement and give great insights. The first major parameter is seasonity_mode. This parameter specifies how to integrate the seasonal component into the forecast. The default  here is addition, and productive is another option.  I struggled with this parameter at first, but after a bit of work it became meaningful to me. Use additives if you want the seasonal trend to be "constant" over the entire period. For example, if you want the growth of the annual trend  to have the same impact as in 2010 and 2018. This applies to data where the  change in tendency appears to be constant. B. The number of people living in a small town. I don't think growth will suddenly increase to millions because of the lack of infrastructure. On the other hand, if you want to predict the number of people living in a growing city, the numbers for recent annual trends can be much more important due to the well-developed infrastructure. In that case, population growth can  be much faster than  in the early days. In such cases, use product to increase the importance of seasonality over time.  As with everywhere, there is also a  parameter seasonity_prior_scale. You can use this parameter to make the seasonality more flexible. Here we find that values ​​between 10 and 25  work well, depending on the seasonality you notice in the component graph. The most effective trick  for me (and I can discuss this freely) is to set annual_seasonality, week_seasonality, daily_seasonality to all  false and then add your own seasonality as shown in the code snippet below. is. 
 This provides greater leverage and control over seasonality. You can specify the exact duration of each season. In other words, you can create a "new" season. For example,  you can set the time period to 93.3125 to add  quarterly seasonality to your model. Instead of everyone sharing one scale, you can also add previous scales for each season. Now I wish I could tell you what seasonalities to add and what period they should be, but each use case is completely different and a domain expert should be contacted to get recommendations and insights.  Just for clarity, if the period is set to 35 then you tell the model that what happened at a certain point is likely to happen again in 35 days.  The other parameter you can tweak using this technique is the number of Fourier components (fourier_order) each seasonality is composed of. Now for those that know a bit of mathematics, any signal can be represented by a sum of sine and cosine waves. This is inherently how Prophet generates its seasonality signals. This allows you to change the exact way to get started.As you can see, the contour of the curve remains the same for both trends, but the 20 component trend has more bumps. These bumps can pick up noise or give more accurate readings. It should come down to your own interpretation and  input from domain experts. We have found that higher values give better results, so it is highly recommended to investigate the impact of using higher values. You can try values ​​between 10 and 25.
### Hyperparameter Tuning end-to-end process


+ Download the resamples. We'll use k-fold cross-validation to generate a cross-validation plan that we can plot to view "within the folds." 

+ Get the number of vCores for the parallel process by registering to the future. 

+ Define the tunable model specification: specify the tunable parameters clearly. 

+ Create a tunable workflow in which we add the tunable model specification and the existing recipe; if necessary, alter the recipe. 

+ Check that the system has all tunable parameters' ranges set correctly; some parameters, such as mtry, do not have their values ranges set correctly. 
+ Define the search grid: the type of grid (random or latin hypercube sampling) and its size must be specified. 


+ Provide the adjustable procedure, resamples, and grid specification to do the hyperparameter tuning. 

+ If you have the time and resources and/or are able to adjust some parameter ranges, run many tweaking routines. 

+ After numerous tweaking cycles, choose the best model: the one with the lowest RMSE or the highest R-squared, which may or may not be the same model. 

+ Provide the tuned methodology to refit the best model(s) using the training data. 


### Cross-validation plan

A k-fold cross-validation divides the training data into k groups of roughly equal size (referred to as "folds"). The analytical data was resampled to include k-1 of the folds, while the assessment set included the final fold. The number of resamples in simple k-fold cross-validation (i.e. no repeats) is equal to k.

### Grid search specification

It is possible to establish specifications for either Random Grid or Latin Hypercube Sampling using the dials package (LHS). 

We create a 20-by-20- Because it employs a random procedure, you may have different values. Remember to set the seed to fix the grid. 

There will be 20 predictions per fold due to the 10-fold cross-validation, and the mean of the performance metric (RMSE, R-squared, etc.) will be calculated. 




### Select and fit the best model(s)

Please keep in mind that we work with workflows (not models) that combine a model with a preprocessing recipe.

### Conclusion

You learnt how to do Prophet hyperparameter tuning in this post. 
You have gained knowledge. 

+ for each machine learning algorithm, how to define customizable specifications 

+ how to build up parallel processing using a vCores cluster 

+ way to check the range of parameter values before tuning 

+ how to create each algorithm's grid search specification 

+ how to use the plot versus RMSE to analyse the effects of hyperparameter tuning 

+ how to fine-tune a specific parameter using many hyperparameter tuning rounds 

+ how to choose a model and retrain a model 

+ how to combine all tuned and untuned models into a modeltime and calibration table 

+ how to plot forecast against test dataset and present all model accuracy results

## References

+ [Implementing Facebook Prophet efficiently](https://towardsdatascience.com/implementing-facebook-prophet-efficiently-c241305405a3)

+ [Time series analysis using Prophet in Python — Part 2: Hyperparameter Tuning and Cross Validation](https://medium.com/analytics-vidhya/time-series-analysis-using-prophet-in-python-part-2-hyperparameter-tuning-and-cross-validation-88e7d831a067)

+ [Time series parameters finding using Prophet and Optuna bayesian optimization](https://medium.com/spikelab/time-series-parameters-finding-using-prophet-and-optuna-bayesian-optimization-e618614bd8b7)
+ [Time Series Forecasting Lab – Hyperparameter Tuning](https://www.r-bloggers.com/2022/01/time-series-forecasting-lab-part-4-hyperparameter-tuning/)
