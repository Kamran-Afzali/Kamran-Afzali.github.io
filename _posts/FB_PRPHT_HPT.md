---
layout: post
categories: posts
title: Forecsting with FB prophet
featured-image: /images/ABS.png
tags: [Forecasting, R, Prophet]
date-string: May 2022
editor_options: 
  markdown: 
    wrap: sentence
---

## Introduction

Time series is an important topic in machine learning, present in almost every industry and a problem that every data scientist will face at some point in their career.
Aside from the fundamentals of the working with dates and plotting, there are other approaches and models for characterising the underlying dynamic of a time series such as space state models (Arima, Armas, etc.).
This article builds on the previous post on Facebook Prophet library that is used to forecast time series data that fits non-linear trends with yearly, monthly, and daily seasonality, as well as holiday effects.
It works best with time series with substantial seasonal effects and historical data from multiple seasons.
Prophet is tolerant of missing data and trend alterations, and it usually handles outliers well.
However, the model has several parameters to tweak to acquire the best fit.
A grid search (random search or Cartesian search) is the traditional approach of determining the optimal combination of parameters, although this can be time-consuming, especially when cross-validating models with many folds.


### Basic Prophet model

Prophet may now be used to analyse our data.
To begin, we must make sure that our date is in datetime format, and the columns must be renamed to the Prophet-required names of ds and y.
We can then build a Prophet object to fit our data into the model, generate future predictions, visualize the forecast, and perform cross validation to check how well the model fits.


```r
df = read.csv("https://raw.githubusercontent.com/Kamran-Afzali/Statistical-Supplementary-Materials/master/DHS_Daily_Report.csv")

#Transform the Date Variable
df$Date = strptime(x = df$Date,
                   format = "%m/%d/%Y")
df$Date = as.Date(df$Date)
df = df %>% select(Date,
                   "Total.Individuals.in.Shelter",
                   Easter,
                   Thanksgiving,
                   Christmas)


#Change variable name
colnames(df)[1] = "ds"
colnames(df)[2] = "y"

head(df)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> ds </th>
   <th style="text-align:right;"> y </th>
   <th style="text-align:right;"> Easter </th>
   <th style="text-align:right;"> Thanksgiving </th>
   <th style="text-align:right;"> Christmas </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 2013-08-21 </td>
   <td style="text-align:right;"> 49673 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013-08-22 </td>
   <td style="text-align:right;"> 49690 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013-08-23 </td>
   <td style="text-align:right;"> 49548 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013-08-24 </td>
   <td style="text-align:right;"> 49617 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013-08-25 </td>
   <td style="text-align:right;"> 49858 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2013-08-26 </td>
   <td style="text-align:right;"> 49877 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table>




```r
easter_dates = subset(df, df$Easter == 1)
easter_dates = easter_dates$ds
easter = tibble(holiday = 'easter',
                ds = easter_dates,
                lower_window = -4,
                upper_window = +2)

#thanksgiving
thanksgiving_dates = subset(df, df$Thanksgiving == 1)
thanksgiving_dates = thanksgiving_dates$ds
thanksgiving = tibble(holiday = 'thanksgiving',
                      ds = thanksgiving_dates,
                      lower_window = -3,
                      upper_window = 1)

#merge holidays
holidays = bind_rows(easter, thanksgiving)
head(holidays)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> holiday </th>
   <th style="text-align:left;"> ds </th>
   <th style="text-align:right;"> lower_window </th>
   <th style="text-align:right;"> upper_window </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2014-04-20 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2015-04-05 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2016-03-27 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2017-04-16 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2018-04-01 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> easter </td>
   <td style="text-align:left;"> 2019-04-21 </td>
   <td style="text-align:right;"> -4 </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
</tbody>
</table>






### Cross-validation plan

A k-fold cross-validation divides the training data into k groups of roughly equal size (referred to as "folds") hence the number of resamples in simple k-fold cross-validation (i.e. no repeats) is equal to k.
The training data was resampled to include k-1 of the folds, while the assessment set included the final fold.
Prophet includes a built-in cross validation feature this function will take your data and train the model over the specified time period.
It will then forecast a time frame that you specify.


### Grid search specification

We use the expand grid function because it enables the employment a random procedure.
Remember to set the seed to fix the grid.
There will be k predictions per fold due to the k-fold cross-validation, and the mean of the performance metric (RMSE, R-squared, etc.) will be calculated.
Here are some parameters that you can take into consideration.

#### Growth

This parameter is easiest to understand and implement, linear growth assumes no upbound where exponential growth slows down.
The tricky part of this parameter is to specify the upper and lower bounds of the prediction when it comes to exponential growth, these upper and lower bounds can change over time or fixed values can be assigned.

#### Holidays

A holiday is a period during which the day has the same impact each year,the tricky part happens when you're not modeling daily data.
For instance, it is a mistakes to enter the holidays as a daily parameter when trying to model an hourly time-stamp.
Another parameter that handles holidays is holidays_prior_scale, this parameter determines how holidays affect forecasts.

#### Changepoints

A changing point is a point in the data where a sudden and abrupt change in the trend occurs, or the point of change is the time frame in which this major change occurred.
There are four changepoint hyperparameters: changepoints, n_changepoints, changepoint_range, and changepoint_prior_scale.
Changepoint parameters are used to specify the date of the changepoint rather than letting the Prophet determine the date of the changepoint.
If you specify your own changes, Prophet will not estimate any further changes.

#### Seasonalities

It is these parameters that make the Prophet standout, as changing a few values can make a considerable improvement and give great insights.
The first major parameter is seasonity_mode, which can be additive or multiplicative, there is also a parameter seasonity_prior_scale to make the seasonality more flexible.
The other parameter you can tweak is the number of Fourier components (fourier_order) of each seasonality


```r
prophetGrid = expand.grid(changepoint_prior_scale = c(0.05, 0.1),
                          seasonality_prior_scale = c(5, 10, 15),
                          holidays_prior_scale = c(5,10),
                          seasonality.mode = c('multiplicative', 'additive'))


head(prophetGrid)%>%kableExtra::kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> changepoint_prior_scale </th>
   <th style="text-align:right;"> seasonality_prior_scale </th>
   <th style="text-align:right;"> holidays_prior_scale </th>
   <th style="text-align:left;"> seasonality.mode </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
  </tr>
</tbody>
</table>


```r
results = vector(mode = 'numeric',
                 length = nrow(prophetGrid))

```


### Hyperparameter Tuning end-to-end process

The bare-bone model used all the default parameters because no parameters were specified.
Check out my earlier article to learn about Prophet's default parameters.
We create a parameter grid with all of the parameters and values we wish to cycle over, calculate the mean value of the performance matrix, and find the optimum parameter combination in terms of MAPE.

-   We'll use k-fold cross-validation to generate a cross-validation plan.

-   Define the tunable model specification: specify the tunable parameters clearly.

-   Create a parameter grid workflow in which we add model specification from the grid.

-   Check that the grid has all selected tunable parameters and ranges set correctly.

-   Define the search grid: the type of grid and its size must be specified.

-   Choose the best model: the one with the lowest RMSE or the highest R-squared, which may or may not be the same model.

-   Provide the tuned methodology to refit the best model(s) using the test data.




```r
#Parameter tuning
for (i in 1:nrow(prophetGrid)) {
  
  #Fetch parameters
  parameters = prophetGrid[i, ]
  
  #Build the model
  m = prophet(yearly.seasonality = TRUE,
              weekly.seasonality = TRUE,
              daily.seasonality = FALSE,
              holidays = holidays,
              seasonality.mode = parameters$seasonality.mode,
              seasonality.prior.scale = parameters$seasonality_prior_scale,
              holidays.prior.scale =  parameters$holidays_prior_scale,
              changepoint.prior.scale = parameters$changepoint_prior_scale)
  m = add_regressor(m, 'Christmas')
  m = fit.prophet(m, df)
  
  #Cross-validation
  df.cv = cross_validation(model = m,
                           horizon = 31,
                           units = 'days',
                           period = 14,
                           initial = 2400)
  
  #store the results
  results[i] = accuracy(df.cv$yhat, df.cv$y)[1, 2]
  print(i)
  
  
}
```

```r
prophetGrid = cbind(prophetGrid, results)

prophetGrid%>%kableExtra::kable()

```

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> changepoint_prior_scale </th>
   <th style="text-align:right;"> seasonality_prior_scale </th>
   <th style="text-align:right;"> holidays_prior_scale </th>
   <th style="text-align:left;"> seasonality.mode </th>
   <th style="text-align:right;"> results </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1551.764 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1554.646 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1553.507 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1557.264 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1551.514 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 15 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1556.042 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1550.701 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1557.542 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1552.467 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 0.10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1557.381 </td>
  </tr>
</tbody>
</table>



```r
best_params = prophetGrid[prophetGrid$results == min(results), ]
best_params
```
<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> changepoint_prior_scale </th>
   <th style="text-align:right;"> seasonality_prior_scale </th>
   <th style="text-align:right;"> holidays_prior_scale </th>
   <th style="text-align:left;"> seasonality.mode </th>
   <th style="text-align:right;"> results </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:left;"> multiplicative </td>
   <td style="text-align:right;"> 1550.701 </td>
  </tr>
</tbody>
</table>




## References

-   [Implementing Facebook Prophet efficiently](https://towardsdatascience.com/implementing-facebook-prophet-efficiently-c241305405a3)

-   [Time series analysis using Prophet in Python --- Part 2: Hyperparameter Tuning and Cross Validation](https://medium.com/analytics-vidhya/time-series-analysis-using-prophet-in-python-part-2-hyperparameter-tuning-and-cross-validation-88e7d831a067)

-   [Time series parameters finding using Prophet and Optuna bayesian optimization](https://medium.com/spikelab/time-series-parameters-finding-using-prophet-and-optuna-bayesian-optimization-e618614bd8b7)

-   [Time Series Forecasting Lab -- Hyperparameter Tuning](https://www.r-bloggers.com/2022/01/time-series-forecasting-lab-part-4-hyperparameter-tuning/)
