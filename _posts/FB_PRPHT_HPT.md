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

### Hyperparameter tuning
The grid search process can take a long time to run. We can also use dask to distribute the task to multiple workers and speed up the process. Here is a notebook showing how to do the hyperparameter tuning in task.

How can we measure the performance of our model?
One of the many hidden secrets that is not so obvious when first using Prophet is that it has a built-in cross validation function. This function will take your data and train the model on a period you specify. It will then predict a period that you also specify. Prophet will then train your data on a bigger period, then predict again and this will repeat until the end point is reached.
As an example, let’s take the data shown above and fit the out of the box Prophet model to it. In the example, I have written my own mean absolute percentage error (MAPE) function and applied it to the test results to get the model performance to be represented in one number.

As you can see from the code above, we import the cross validation function from Prophet and apply it to our data. This returns a dataframe of the predicted and true values for all our predicted points, which can then be used to calculate the error.
So after running the code above, we get a MAPE of 15.32%. This indicates that over all the points predicted, we are out with an average of 15.32% from the true value.
For the rest of the blog, I will discuss each hyper parameter and what you should keep an eye on when deciding their values.
Optimizing the model
Don’t do anything blindly
The first tip with optimizing a model is not to go crazy and change values and create huge for loops or throw your model into a gridsearch to optimize hyper parameters. This is especially true when looking at time series models as hyper parameters have a great effect on the predictions, but the values of those parameters don’t have to be perfect. Rather, getting them into the correct zone is what will bring the greatest reward. You accomplish this by looking at the data and understanding what your model will do with that data when you change each parameter.
Growth
This parameter is the easiest to understand and implement as you only have to plot your data to know what it should be. If you plot your data and you see a trend that keeps on growing with no real saturation insight (or if your domain expert tells you there is no saturation to worry about) you will set this parameter to “linear”.
If you plot it and you see a curve that is showing promise of saturation (or if you are working with values that you know must saturate, for example CPU usage) then you will set it to “logistic”.
The difficult part of this parameter comes when you choose logistic growth as you then have to provide the cap (maximum value your data will reach)and floor (minimum value your data will reach) of your predictions as well as historic data. These cap and floor values can change over time or be a set value that you put in for all time.
This is one of those cases where talking with a domain expert will help you the most. They have a very good idea of what can be expected for the following year and what would be impossible values for a time period. After speaking with them you can provide much more accurate caps and floors over time. However, if you have no domain experts nearby, I have found that 65% of your first value works well for a floor value. You can then make your cap be a relatively high amount, but within common sense. Thus if you are predicting the number of visits to a site and at the moment it sits at 100 000, then don’t make your cap 200 000 000 as you most likely will not reach that limit within the time you are predicting. Rather make it something more reasonable like 500 000 and let the cap grow slowly over time.
Holidays
Holidays are periods of time where the days have the same sort of effect each year. For example, if you want to model the number of subscribers in a city where people migrate over the festive periods, you can put in the dates of the festive period in your model using the holidays parameter.
The tricky part comes when you are modelling non-daily data. A mistake I made was to put in my holidays as daily data when I tried to model hourly data. This caused my model to perform worse as it struggled to adapt the holiday data to the correct form. It is important to ensure that your holiday data has the same form as your target data. You should also be able to provide the holiday dates of the period you are predicting. This means that holidays can only be times/dates/days that you know beforehand.
The other parameter that deals with holidays is holidays_prior_scale. This parameter determines how much of an effect holidays should have on your predictions. So for instance when you are dealing with population predictions and you know holidays will have a big effect, try big values. Normally values between 20 and 40 will work, otherwise the default value of 10 usually works quite well. As a last resort, you can lower it to see the effect, but I have not ever found that to increase my MAPE.
Changepoints
Changepoints are the points in your data where there are sudden and abrupt changes in the trend. An example of this would be if you had a campaign and suddenly you got 50 000 more constant visitors to your website. The changepoint will be the timeslot where this big change occurred.
There are four hyperparameters for changepoints: changepoints, n_changepoints, changepoint_range and changepoint_prior_scale.
The changepoints parameter is used when you supply the changepoint dates instead of having Prophet determine them. Once you have provided your own changepoints, Prophet will not estimate any more changepoints. Therefore, it is important that you know what you are doing. From my experience, I have found that letting Prophet discover them on its own and me changing the number of changepoints (with n_changepoints) gave the best results. In terms of how many changepoints should be chosen, I recommend that if you have hourly data at least one changepoint a month will give good results. However, it will change depending on each use case, but this can be a good start.
The changepoint_range usually does not have that much of an effect on the performance. I have had the best results by just keeping it at the default value, but I would love to hear in the comments if someone has found a case where there was a difference when changing it from 0,8. The other parameter, changepoint_prior_scale, is there to indicate how flexible the changepoints are allowed to be. In other words, how much can the changepoints fit to the data. If you make it high it will be more flexible, but you can end up overfitting. I have found that values between 10 and 30 work for me, depending on how volatile the data is.
Seasonalities
These parameters are where Prophet shines as you can make big improvements and gain great insights by changing only a few values.
The first big parameter is seasonality_mode. This parameter indicates how your seasonality components should be integrated with the predictions. The default value here is additive with multiplicative being the other option. At first I struggled with this parameter, but after working with it for a bit, it began to make sense to me. You will use additive when your seasonality trend should be “constant” over the entire period. For example, when you want your yearly trend growth impact to be the same as in 2010 as it is in 2018. This is applicable in data where the trend change seems to stay constant, for example the number of people living in a small town. This is because we don’t expect the growth to suddenly increase in millions because there is no infrastructure for that.
On the other hand, when we want to predict the amount of people living in a growing city, the yearly trend number might be much more important in the final years as the infrastructure is there. The rate of population growth can then be much quicker than what it would have been in the early years. In a case like that, you will use multiplicative to increase the importance of the seasonalities over time.
As is the case everywhere, there is also a seasonality_prior_scale parameter. This parameter will again allow your seasonalities to be more flexible. I have found values between 10 and 25 to work well here, depending on how much seasonality you notice in the components plot.
A trick I found to work best for me (and I am open to discussion about this) is to set yearly_seasonality, weekly_seasonality and daily_seasonality all to false and then add in my own seasonalities, as shown in the code snippet below.

By doing this you get more power and control over seasonality. You can specify the exact periods of each season which means you can create “new” seasons. For example, by making the period 93.3125 you can add in quarterly seasonality to your model. You can also add for each seasonality what the prior scale should be instead of them all sharing one scale. Now I wish I could tell you what seasonalities to add and what period they should be, but each use case is completely different and a domain expert should be contacted to get recommendations and insights.
Just for clarity, if the period is set to 35 then you tell the model that what happened at a certain point is likely to happen again in 35 days.
The other parameter you can tweak using this technique is the number of Fourier components (fourier_order) each seasonality is composed of. Now for those that know a bit of mathematics, any signal can be represented by a sum of sine and cosine waves. This is inherently how Prophet generates its seasonality signals. With this, you can change how accurately it should start representing the curve or how many more curves can be present in the curve. Shown below is the daily seasonality of some data using a fourier_order of 5 and 20 respectfully.


As you can see the curve outline stays the same in both trends, but there are more bumps in the trend with 20 components. These bumps could either be picking up noise or can be more accurate values. It should come down to your own interpretation and the input of a domain expert. I have found that higher values do give better results and I highly recommend investigating the effect of using higher values. You can try values that range from 10 to 25.

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
