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


### Basic Prophet model
Now we can run Prophet on our data. First, we need to make sure that our date is in the datetime format by running pd.to_datetime. Second, we need to rename the columns to ds and y , which are the required names by Prophet.
Then, we can instantiating a Prophet object m, fit the our data into the model, make future predictions, plot the prediction, and run cross validation to inspect the model fit.


### Hyperparameter tuning
The previous model did not specify any parameters in the model and uses all the default parameters. If you would like to know what are the default parameters in Prophet, check out my previous article.
Here we define a param_grid of all the parameters and values we want to loop through, and then calculated the mean value of the performance matrix, and get the best parameter combination in terms of MAPE. The syntax below is based on this notebook with few revisions.


### Parallel computing
Cross-validation
The cross validation process can use dask in the backend to do parralell computing. Here are some examples: example 1, example 2. Basically, we just need to add parallel="dask" when we call the cross_validation function.

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



The end-to-end process is as follows:

+ Get the resamples. Here we will perform a k-fold cross-validation and obtain a cross-validation plan that we can plot to see “inside the folds”.

+ Prepare for parallel process: register to future and get the number of vCores.

+ Define the tunable model specification: explicitly indicate the tunable parameters.

+ Define a tunable workflow into which we add the tunable model specification and the existing recipe; update the recipe if necessary.

+ Verify that the system has all tunable parameters’ range, some parameter such as mtry
    do not have its values range correctly initialized.
+ Define the search grid specification: you must provide type of grid (random or latin hypercube sampling) and its size.

+ Toggle on the parallel processing

+ Run the hyperparameter tuning by provding the tunable workflow, the resamples, and the grid specification.

+ Run several tuning rouds if you can e.g., if you have the time and resources and/or you are able to fix some parameter ranges.

+ After several tuning rounds, select the best model: with the lowest RMSE or with the higest R-squared, it may be same model or they can be different models.
  
+ Refit the best model(s) with the training data by provding the tuned workflow.


## References

+ [Implementing Facebook Prophet efficiently](https://towardsdatascience.com/implementing-facebook-prophet-efficiently-c241305405a3)

+ [Time series analysis using Prophet in Python — Part 2: Hyperparameter Tuning and Cross Validation](https://medium.com/analytics-vidhya/time-series-analysis-using-prophet-in-python-part-2-hyperparameter-tuning-and-cross-validation-88e7d831a067)

+ [Time series parameters finding using Prophet and Optuna bayesian optimization](https://medium.com/spikelab/time-series-parameters-finding-using-prophet-and-optuna-bayesian-optimization-e618614bd8b7)
+ [Time Series Forecasting Lab – Hyperparameter Tuning](https://www.r-bloggers.com/2022/01/time-series-forecasting-lab-part-4-hyperparameter-tuning/)
