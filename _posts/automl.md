---
layout: post
categories: posts
title: H2O AutoML   
featured-image: /images/P1.jpg
tags: [AutoML, H2O, Machine Learning]
date-string: Octobre 2022
---


## Introduction: AutoML 

Over the past few years, demand for machine learning systems has skyrocketed. This is mostly because machine learning techniques have been effective in a variety of applications. By enabling users from different backgrounds to apply machine learning models to address complicated scenarios, AutoML is fundamentally altering the face of ML-based solutions today. Nevertheless, despite abundant evidence that machine learning can benefit several industries, many firms today still find it difficult to implement ML models. This is due to a lack of seasoned and competent data scientists in the field. Additionally, many machine learning procedures call for more experience than knowledge, particularly when determining which models to train and how to evaluate them. Today, there are many efforts being made to close these gaps, which are rather obvious. We will examine in this post if AutoML can be a solution to these obstacles. Automated machine learning ([AutoML](https://www.r-bloggers.com/2020/04/automl-frameworks-in-r-python/)) is the process of fully automating the machine learning application to practical issues. With the least amount of human effort, autoML aims to automate as many processes as possible in an ML pipeline without sacrificing the model's performance. The training, fine-tuning, and deployment of machine learning models are all automated using the automated machine learning technique known as AutoML. Without the need for human participation, AutoML can be used to automatically find the optimal model for a particular dataset and task.

Because it can automate the process of developing and deploying machine learning models, AutoML is a crucial tool for making machine learning approachable to non-experts. This can expedite machine learning research and save time and resources. The key innovation in AutoML is the hyperparameters search technique, which is used for preprocessing elements, choosing model types, and improving their hyperparameters. There are many different types of optimization algorithms, ranging from Bayesian and evolutionary algorithms to random and grid search. Various strategies can be used to develope an AutoML solution, depending on the precise issue that has to be resolved. For instance, some approaches concentrate on identifying the best model for a particular job, while others concentrate on optimising a model for a specific dataset. Whatever the strategy, AutoML can be a potent tool for improving the usability and effectiveness of machine learning. 

This post aims to introduce you to H2O as one of the top AutoML Tools and Platforms. 

**Pro’s**

- Time saving: It’s a quick prototyping tool, specially if you are not working on critical task, you could use AutoML to do the job for you while you focus on more critical tasks.

- Benchmarking: Building a ML/DL model is fun, but, how to know if the model is the best? One option is to use AutoML to benchmark yours.


**Con’s**

+ Most AI models that we come across are black box. Similar is the case with these AutoML frameworks. If you don’t understand what you are doing, it could be catastrophic.

+ Based on the previous point, AutoML is being marketed as a tool for non-data scientists. However, without understanding how a model works and blindly using it for making decisions could be disastrous.


## H2O AutoML

The AutoML component of the H2O packahe enables the automatic training and fine-tuning of several models within a user-specified time frame. Using all of the models, the current AutoML function can train and cross-validate a Random Forest, an Extremely-Randomized Forest, a random grid of Gradient Boosting Machines (GBMs), a random grid of Deep Neural Nets, and a Stacked Ensemble. In order for users to complete jobs with the least amount of misunderstanding, AutoML should take into account the issues of data preparation, model development, and ensembles while also offering as few parameters as feasible. With only a few user-supplied parameters, H2O AutoML is able to complete this work with simplicity. The data-related arguments x, y, training frame, and validation frame are used in both the R and Python APIs; y and training frame are required parameters, and the rest are optional. Max runtime sec is a necessary parameter, while max model is optional; if you don't supply any parameters, it defaults to taking NULL. You may also adjust values for these parameters here. If you don't want to use every predictor from the frame you gave, you can set it by supplying it to the x parameter, which is the vector of predictors from training frame. Now let's discuss a few optional and unrelated parameters; try to adjust the settings even if you are unaware of their purpose; doing so will help you learn about some complex subjects:

+ Enter a dataframe (df) and select the independent variable (y) that you want to forecast. If you want to ensure that your results can be replicated, you can set or modify the seed argument. 

+ The function determines whether the model is a classification (categorical) or regression (continuous) model by examining the class and number of distinct values of the independent variable (y), which can be adjusted using the thresh parameter. 

+ Test and train datasets will be separated from the dataframe. With the split argument, the split percentage can be managed. The msplit() function can duplicate this.

+ Before moving on, you could also scale and centre your numerical data, use the no outliers function to remove some outliers, and/or use MICE to impute missing values. The function can balance (under-sample) your training data if the model is a classification model. This behaviour is manageable using the balance argument. Up until this point, the model preprocess() function can be used to duplicate the entire procedure. 

+ Runs h2o::h2o.automl(...) to train several models and provide a leaderboard of the best (max models or max time) trained models, ranked by effectiveness. You can also modify certain extra arguments you want to provide to the mother function, such as nfolds for k-fold cross-validations, exclude algos and include algos to exclude or include particular algorithms, and any other extra argument you want.

+ The best model, given the default performance metric (which can be modified with the stopping metric option), will be chosen to proceed after being cross-validated and evaluated using nfolds. A different model can be chosen using the h2o selectmodel() method, and all calculations and plots can then be redone using this new model. 

+ The test predictions and test actual values will be used to create and render performance metrics and charts (which were NOT passed to the models as inputs to be trained with). Your model's performance metrics shouldn't be skewed in this way. The model metrics() method lets you repeat these calculations. 

+ A list containing all the inputs, performance metrics, graphs, the top-ranked model, and leaderboard results. The results can be exported by using the export results() function, or you can (play) see them on the console.


## Mapping H2O AutoML Functionalities


+ Validation_frame: This parameter is used for early stopping of individual models in the automl. It is a dataframe that you pass for validation of a model or can be a part of training data if not passed by you.

+ leaderboard_frame: If passed the models will be scored according to the values instead of using cross-validation metrics. Again the values are a part of training data if not passed by you.

+ nfolds: K-fold cross-validation by default 5, can be used to decrease the model performance.

+ fold_columns: Specifies the index for cross-validation.

  - when all three frames are passed - No splits. When we are not using cross-validation which will affect the leaderboard frame a lot(nfolds = 0): 

  - Only training frame is passed - The data is split into 80/10/10 training, validation, and leaderboard. 

  - Training and leaderboard frame is passed - Data split into 80-20 of training and validation frames. 

+ Weights_column: If you want to provide weights to specific columns you can use this parameter, assigning weight 0 means you are excluding the column.
ignored_columns: Only in python, it is converse of x.

+ Stopping_metric: Specifies a metric for early stopping of the grid searches and models default value is logloss for classification and deviation for regression.

+ Sort_metric: The parameter to sort the leaderboard models at the end. This defaults to AUC for binary classification, mean_per_class_error for multinomial classification, and deviance for regression.

+ The validation_frame and leaderboard_frame depend on the cross-validation parameter that is nfolds. 

H2O AutoML satisfies the need for machine learning experts by developing intuitive machine learning software. This AutoML application seeks to streamline machine learning by offering clear and uniform user interfaces for different machine learning methods. Within a user-specified time range, machine learning models are automatically developed and fine-tuned. The lares package contains several families of functions that enable data scientists and analysts to perform high-quality, reliable analyses without having to write a lot of code. H2O automl, which semi-automatically executes the entire pipeline of a Machine Learning model given a dataset and some adjustable parameters, is one of our more intricate yet valuable functions. You can speed up research and development by using AutoML to train high-quality models that are tailored to your needs.

Before getting to the code, I recommend checking h2o_automl's full documentation [here](https://docs.h2o.ai/h2o/latest-stable/h2o-r/docs/reference/h2o.automl.html) or within your R session by running ?lares::h2o_automl if you use the lares version. Documentation contains a brief explanation of each parameter that can be entered into the function to acquire the results you need and regulate how it operates.

first we load the necessay packages

```r
library(readr)
library(tidyverse)
library(tidymodels)
library(h2o)
library(gridExtra)
library(kableExtra)
```


we use the diabetes data from *pdp* package

```r
data(pima, package = "pdp")
out="diabetes"
preds=colnames(pima)[-c(9)]
df=pima%>%
  drop_na()

df_split <- initial_split(df)
train_data <- training(df_split)
test_data <- testing(df_split)
h2o.init()
train_data <- as.h2o(train_data)
```



here we train the model


```r
h2oAML <- h2o.automl(
  y = out,
  x = preds,
  training_frame = train_data,
  project_name = "ice_the_kicker_bakeoff",
  balance_classes = T,
  max_runtime_secs = 100,
  seed = 1234
)
```

a summary can be found in the *leaderboard_tbl* object


```r
leaderboard_tbl <- h2oAML@leaderboard %>% as_tibble()

leaderboard_tbl %>% head() %>% kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> model_id </th>
   <th style="text-align:right;"> auc </th>
   <th style="text-align:right;"> logloss </th>
   <th style="text-align:right;"> aucpr </th>
   <th style="text-align:right;"> mean_per_class_error </th>
   <th style="text-align:right;"> rmse </th>
   <th style="text-align:right;"> mse </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> GBM_grid_1_AutoML_1_20221024_112632_model_40 </td>
   <td style="text-align:right;"> 0.8475490 </td>
   <td style="text-align:right;"> 0.4392863 </td>
   <td style="text-align:right;"> 0.6840091 </td>
   <td style="text-align:right;"> 0.1936275 </td>
   <td style="text-align:right;"> 0.3764929 </td>
   <td style="text-align:right;"> 0.1417469 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> StackedEnsemble_BestOfFamily_7_AutoML_1_20221024_112632 </td>
   <td style="text-align:right;"> 0.8446623 </td>
   <td style="text-align:right;"> 0.4507552 </td>
   <td style="text-align:right;"> 0.6834712 </td>
   <td style="text-align:right;"> 0.1915033 </td>
   <td style="text-align:right;"> 0.3765024 </td>
   <td style="text-align:right;"> 0.1417541 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GBM_grid_1_AutoML_1_20221024_112632_model_30 </td>
   <td style="text-align:right;"> 0.8435185 </td>
   <td style="text-align:right;"> 0.4571160 </td>
   <td style="text-align:right;"> 0.7007188 </td>
   <td style="text-align:right;"> 0.1918301 </td>
   <td style="text-align:right;"> 0.3830612 </td>
   <td style="text-align:right;"> 0.1467359 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> DeepLearning_grid_1_AutoML_1_20221024_112632_model_3 </td>
   <td style="text-align:right;"> 0.8424837 </td>
   <td style="text-align:right;"> 0.4846210 </td>
   <td style="text-align:right;"> 0.6730490 </td>
   <td style="text-align:right;"> 0.2058824 </td>
   <td style="text-align:right;"> 0.3863806 </td>
   <td style="text-align:right;"> 0.1492899 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> GBM_grid_1_AutoML_1_20221024_112632_model_87 </td>
   <td style="text-align:right;"> 0.8423203 </td>
   <td style="text-align:right;"> 0.4560024 </td>
   <td style="text-align:right;"> 0.6421818 </td>
   <td style="text-align:right;"> 0.2081699 </td>
   <td style="text-align:right;"> 0.3858873 </td>
   <td style="text-align:right;"> 0.1489090 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> StackedEnsemble_AllModels_6_AutoML_1_20221024_112632 </td>
   <td style="text-align:right;"> 0.8414488 </td>
   <td style="text-align:right;"> 0.4586412 </td>
   <td style="text-align:right;"> 0.6550735 </td>
   <td style="text-align:right;"> 0.1942810 </td>
   <td style="text-align:right;"> 0.3806513 </td>
   <td style="text-align:right;"> 0.1448954 </td>
  </tr>
</tbody>
</table>

the *leaderboard_tbl* object also alows us to identify the best fitting model


```r
model_names <- leaderboard_tbl$model_id

top_model <- h2o.getModel(model_names[1])

top_model@model$model_summary %>%pivot_longer(cols = everything(),names_to = "Parameter", values_to = "Value") %>%kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> Parameter </th>
   <th style="text-align:right;"> Value </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> number_of_trees </td>
   <td style="text-align:right;"> 36.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> number_of_internal_trees </td>
   <td style="text-align:right;"> 36.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> model_size_in_bytes </td>
   <td style="text-align:right;"> 4499.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min_depth </td>
   <td style="text-align:right;"> 3.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max_depth </td>
   <td style="text-align:right;"> 5.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mean_depth </td>
   <td style="text-align:right;"> 3.638889 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> min_leaves </td>
   <td style="text-align:right;"> 4.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max_leaves </td>
   <td style="text-align:right;"> 6.000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mean_leaves </td>
   <td style="text-align:right;"> 5.305555 </td>
  </tr>
</tbody>
</table>

then we can measure the performance on the test data


```r
h2o_predictions <- h2o.predict(top_model, newdata = as.h2o(test_data)) %>%
  as_tibble() %>%
  bind_cols(test_data)
```

```r
h2o_metrics <- bind_rows(
  #Calculate Performance Metrics
  yardstick::f_meas(h2o_predictions, diabetes, predict),
  yardstick::precision(h2o_predictions, diabetes, predict),
  yardstick::recall(h2o_predictions, diabetes, predict)
) %>%
  mutate(label = "h2o", .before = 1) %>% 
  rename_with(~str_remove(.x, '\\.'))  %>% kable()
```

here is the code to make the confusion matrix on the test data


```r
h2o_cf <- h2o_predictions %>% 
  count(diabetes, pred= predict) %>% 
  mutate(label = "h2o", .before = 1)%>% kable()
```


Lares package provides an elegant wrapper for H2O AutoML functions



```r
library(lares)

r <- h2o_automl( train_data, y = diabetes, max_models = 10, impute = FALSE, target = 'pos')
```


you can extract feature importance


```r
head(r$importance)%>% kable()
```

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> variable </th>
   <th style="text-align:right;"> relative_importance </th>
   <th style="text-align:right;"> scaled_importance </th>
   <th style="text-align:right;"> importance </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> glucose </td>
   <td style="text-align:right;"> 46.2070580 </td>
   <td style="text-align:right;"> 1.0000000 </td>
   <td style="text-align:right;"> 0.4943360 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> age </td>
   <td style="text-align:right;"> 21.4305954 </td>
   <td style="text-align:right;"> 0.4637948 </td>
   <td style="text-align:right;"> 0.2292705 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> insulin </td>
   <td style="text-align:right;"> 14.2493601 </td>
   <td style="text-align:right;"> 0.3083806 </td>
   <td style="text-align:right;"> 0.1524436 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> triceps </td>
   <td style="text-align:right;"> 6.5016131 </td>
   <td style="text-align:right;"> 0.1407061 </td>
   <td style="text-align:right;"> 0.0695561 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pedigree </td>
   <td style="text-align:right;"> 5.0137486 </td>
   <td style="text-align:right;"> 0.1085061 </td>
   <td style="text-align:right;"> 0.0536385 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mass </td>
   <td style="text-align:right;"> 0.0706036 </td>
   <td style="text-align:right;"> 0.0015280 </td>
   <td style="text-align:right;"> 0.0007553 </td>
  </tr>
</tbody>
</table>


metrics for the perforamnce 


```r
r$metrics %>% kable()
```

<table class="kable_wrapper">
<tbody>
  <tr>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> x </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> AUC: Area Under the Curve </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ACC: Accuracy </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PRC: Precision = Positive Predictive Value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TPR: Sensitivity = Recall = Hit rate = True Positive Rate </td>
  </tr>
  <tr>
   <td style="text-align:left;"> TNR: Specificity = Selectivity = True Negative Rate </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Logloss (Error): Logarithmic loss [Neutral classification: 0.69315] </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Gain: When best n deciles selected, what % of the real target observations are picked? </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Lift: When best n deciles selected, how much better than random is? </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;">   </th>
   <th style="text-align:right;"> neg </th>
   <th style="text-align:right;"> pos </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> neg </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 47 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> percentile </th>
   <th style="text-align:left;"> value </th>
   <th style="text-align:right;"> random </th>
   <th style="text-align:right;"> target </th>
   <th style="text-align:right;"> total </th>
   <th style="text-align:right;"> gain </th>
   <th style="text-align:right;"> optimal </th>
   <th style="text-align:right;"> lift </th>
   <th style="text-align:right;"> response </th>
   <th style="text-align:right;"> score </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 1 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 13.48315 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 12 </td>
   <td style="text-align:right;"> 29.41176 </td>
   <td style="text-align:right;"> 35.29412 </td>
   <td style="text-align:right;"> 118.13725 </td>
   <td style="text-align:right;"> 29.411765 </td>
   <td style="text-align:right;"> 61.522961 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 2 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 21.34831 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 7 </td>
   <td style="text-align:right;"> 47.05882 </td>
   <td style="text-align:right;"> 55.88235 </td>
   <td style="text-align:right;"> 120.43344 </td>
   <td style="text-align:right;"> 17.647059 </td>
   <td style="text-align:right;"> 59.248090 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 30.33708 </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 55.88235 </td>
   <td style="text-align:right;"> 79.41176 </td>
   <td style="text-align:right;"> 84.20479 </td>
   <td style="text-align:right;"> 8.823529 </td>
   <td style="text-align:right;"> 51.900488 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 4 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 40.44944 </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 70.58824 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 74.50980 </td>
   <td style="text-align:right;"> 14.705882 </td>
   <td style="text-align:right;"> 33.315837 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 5 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 52.80899 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 11 </td>
   <td style="text-align:right;"> 82.35294 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 55.94493 </td>
   <td style="text-align:right;"> 11.764706 </td>
   <td style="text-align:right;"> 20.519447 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 6 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 59.55056 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 88.23529 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 48.16870 </td>
   <td style="text-align:right;"> 5.882353 </td>
   <td style="text-align:right;"> 16.922080 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 7 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 70.78652 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 10 </td>
   <td style="text-align:right;"> 94.11765 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 32.95985 </td>
   <td style="text-align:right;"> 5.882353 </td>
   <td style="text-align:right;"> 11.298031 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 8 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 79.77528 </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 25.35211 </td>
   <td style="text-align:right;"> 5.882353 </td>
   <td style="text-align:right;"> 7.915044 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 9 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 89.88764 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 11.25000 </td>
   <td style="text-align:right;"> 0.000000 </td>
   <td style="text-align:right;"> 6.623036 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 10 </td>
   <td style="text-align:left;"> pos </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 100.00000 </td>
   <td style="text-align:right;"> 0.00000 </td>
   <td style="text-align:right;"> 0.000000 </td>
   <td style="text-align:right;"> 5.608875 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:right;"> AUC </th>
   <th style="text-align:right;"> ACC </th>
   <th style="text-align:right;"> PRC </th>
   <th style="text-align:right;"> TPR </th>
   <th style="text-align:right;"> TNR </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 0.82834 </td>
   <td style="text-align:right;"> 0.24719 </td>
   <td style="text-align:right;"> 0.22951 </td>
   <td style="text-align:right;"> 0.41176 </td>
   <td style="text-align:right;"> 0.14545 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> metric </th>
   <th style="text-align:right;"> mean </th>
   <th style="text-align:right;"> sd </th>
   <th style="text-align:right;"> cv_1_valid </th>
   <th style="text-align:right;"> cv_2_valid </th>
   <th style="text-align:right;"> cv_3_valid </th>
   <th style="text-align:right;"> cv_4_valid </th>
   <th style="text-align:right;"> cv_5_valid </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> accuracy </td>
   <td style="text-align:right;"> 0.7951220 </td>
   <td style="text-align:right;"> 0.0612190 </td>
   <td style="text-align:right;"> 0.7804878 </td>
   <td style="text-align:right;"> 0.7073170 </td>
   <td style="text-align:right;"> 0.8536586 </td>
   <td style="text-align:right;"> 0.7804878 </td>
   <td style="text-align:right;"> 0.8536586 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> auc </td>
   <td style="text-align:right;"> 0.7998957 </td>
   <td style="text-align:right;"> 0.0351090 </td>
   <td style="text-align:right;"> 0.8269231 </td>
   <td style="text-align:right;"> 0.7746212 </td>
   <td style="text-align:right;"> 0.8333333 </td>
   <td style="text-align:right;"> 0.8125000 </td>
   <td style="text-align:right;"> 0.7521008 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> err </td>
   <td style="text-align:right;"> 0.2048780 </td>
   <td style="text-align:right;"> 0.0612190 </td>
   <td style="text-align:right;"> 0.2195122 </td>
   <td style="text-align:right;"> 0.2926829 </td>
   <td style="text-align:right;"> 0.1463415 </td>
   <td style="text-align:right;"> 0.2195122 </td>
   <td style="text-align:right;"> 0.1463415 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> err_count </td>
   <td style="text-align:right;"> 8.4000000 </td>
   <td style="text-align:right;"> 2.5099800 </td>
   <td style="text-align:right;"> 9.0000000 </td>
   <td style="text-align:right;"> 12.0000000 </td>
   <td style="text-align:right;"> 6.0000000 </td>
   <td style="text-align:right;"> 9.0000000 </td>
   <td style="text-align:right;"> 6.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> f0point5 </td>
   <td style="text-align:right;"> 0.6316909 </td>
   <td style="text-align:right;"> 0.1223794 </td>
   <td style="text-align:right;"> 0.6470588 </td>
   <td style="text-align:right;"> 0.4545455 </td>
   <td style="text-align:right;"> 0.7446808 </td>
   <td style="text-align:right;"> 0.7407407 </td>
   <td style="text-align:right;"> 0.5714286 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> f1 </td>
   <td style="text-align:right;"> 0.6559614 </td>
   <td style="text-align:right;"> 0.0777845 </td>
   <td style="text-align:right;"> 0.7096774 </td>
   <td style="text-align:right;"> 0.5714286 </td>
   <td style="text-align:right;"> 0.7000000 </td>
   <td style="text-align:right;"> 0.7272728 </td>
   <td style="text-align:right;"> 0.5714286 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> f2 </td>
   <td style="text-align:right;"> 0.7002074 </td>
   <td style="text-align:right;"> 0.0872414 </td>
   <td style="text-align:right;"> 0.7857143 </td>
   <td style="text-align:right;"> 0.7692308 </td>
   <td style="text-align:right;"> 0.6603774 </td>
   <td style="text-align:right;"> 0.7142857 </td>
   <td style="text-align:right;"> 0.5714286 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> lift_top_group </td>
   <td style="text-align:right;"> 1.7653105 </td>
   <td style="text-align:right;"> 1.0404958 </td>
   <td style="text-align:right;"> 2.5230770 </td>
   <td style="text-align:right;"> 1.7083334 </td>
   <td style="text-align:right;"> 2.4848485 </td>
   <td style="text-align:right;"> 2.1102940 </td>
   <td style="text-align:right;"> 0.0000000 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> logloss </td>
   <td style="text-align:right;"> 0.4915730 </td>
   <td style="text-align:right;"> 0.0841900 </td>
   <td style="text-align:right;"> 0.5208641 </td>
   <td style="text-align:right;"> 0.4600092 </td>
   <td style="text-align:right;"> 0.4427218 </td>
   <td style="text-align:right;"> 0.6239158 </td>
   <td style="text-align:right;"> 0.4103542 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max_per_class_error </td>
   <td style="text-align:right;"> 0.3399924 </td>
   <td style="text-align:right;"> 0.0692233 </td>
   <td style="text-align:right;"> 0.2500000 </td>
   <td style="text-align:right;"> 0.3636364 </td>
   <td style="text-align:right;"> 0.3636364 </td>
   <td style="text-align:right;"> 0.2941177 </td>
   <td style="text-align:right;"> 0.4285714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mcc </td>
   <td style="text-align:right;"> 0.5402240 </td>
   <td style="text-align:right;"> 0.0493520 </td>
   <td style="text-align:right;"> 0.5589962 </td>
   <td style="text-align:right;"> 0.5045250 </td>
   <td style="text-align:right;"> 0.6098242 </td>
   <td style="text-align:right;"> 0.5445812 </td>
   <td style="text-align:right;"> 0.4831933 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mean_per_class_accuracy </td>
   <td style="text-align:right;"> 0.7824624 </td>
   <td style="text-align:right;"> 0.0289855 </td>
   <td style="text-align:right;"> 0.7980769 </td>
   <td style="text-align:right;"> 0.8181818 </td>
   <td style="text-align:right;"> 0.7848485 </td>
   <td style="text-align:right;"> 0.7696078 </td>
   <td style="text-align:right;"> 0.7415966 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mean_per_class_error </td>
   <td style="text-align:right;"> 0.2175377 </td>
   <td style="text-align:right;"> 0.0289855 </td>
   <td style="text-align:right;"> 0.2019231 </td>
   <td style="text-align:right;"> 0.1818182 </td>
   <td style="text-align:right;"> 0.2151515 </td>
   <td style="text-align:right;"> 0.2303922 </td>
   <td style="text-align:right;"> 0.2584034 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> mse </td>
   <td style="text-align:right;"> 0.1628366 </td>
   <td style="text-align:right;"> 0.0366396 </td>
   <td style="text-align:right;"> 0.1757022 </td>
   <td style="text-align:right;"> 0.1505909 </td>
   <td style="text-align:right;"> 0.1425439 </td>
   <td style="text-align:right;"> 0.2198379 </td>
   <td style="text-align:right;"> 0.1255082 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> pr_auc </td>
   <td style="text-align:right;"> 0.5545080 </td>
   <td style="text-align:right;"> 0.1821300 </td>
   <td style="text-align:right;"> 0.6685007 </td>
   <td style="text-align:right;"> 0.3423082 </td>
   <td style="text-align:right;"> 0.6143393 </td>
   <td style="text-align:right;"> 0.7612409 </td>
   <td style="text-align:right;"> 0.3861512 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> precision </td>
   <td style="text-align:right;"> 0.6220635 </td>
   <td style="text-align:right;"> 0.1521601 </td>
   <td style="text-align:right;"> 0.6111111 </td>
   <td style="text-align:right;"> 0.4000000 </td>
   <td style="text-align:right;"> 0.7777778 </td>
   <td style="text-align:right;"> 0.7500000 </td>
   <td style="text-align:right;"> 0.5714286 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> r2 </td>
   <td style="text-align:right;"> 0.1422753 </td>
   <td style="text-align:right;"> 0.0905973 </td>
   <td style="text-align:right;"> 0.1885841 </td>
   <td style="text-align:right;"> 0.0411239 </td>
   <td style="text-align:right;"> 0.2738899 </td>
   <td style="text-align:right;"> 0.0942462 </td>
   <td style="text-align:right;"> 0.1135321 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> recall </td>
   <td style="text-align:right;"> 0.7519657 </td>
   <td style="text-align:right;"> 0.1721000 </td>
   <td style="text-align:right;"> 0.8461539 </td>
   <td style="text-align:right;"> 1.0000000 </td>
   <td style="text-align:right;"> 0.6363636 </td>
   <td style="text-align:right;"> 0.7058824 </td>
   <td style="text-align:right;"> 0.5714286 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> rmse </td>
   <td style="text-align:right;"> 0.4015838 </td>
   <td style="text-align:right;"> 0.0442591 </td>
   <td style="text-align:right;"> 0.4191685 </td>
   <td style="text-align:right;"> 0.3880604 </td>
   <td style="text-align:right;"> 0.3775499 </td>
   <td style="text-align:right;"> 0.4688688 </td>
   <td style="text-align:right;"> 0.3542714 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> specificity </td>
   <td style="text-align:right;"> 0.8129590 </td>
   <td style="text-align:right;"> 0.1222880 </td>
   <td style="text-align:right;"> 0.7500000 </td>
   <td style="text-align:right;"> 0.6363636 </td>
   <td style="text-align:right;"> 0.9333333 </td>
   <td style="text-align:right;"> 0.8333333 </td>
   <td style="text-align:right;"> 0.9117647 </td>
  </tr>
</tbody>
</table>

 </td>
   <td> 

<table>
 <thead>
  <tr>
   <th style="text-align:left;"> metric </th>
   <th style="text-align:right;"> threshold </th>
   <th style="text-align:right;"> value </th>
   <th style="text-align:right;"> idx </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> max f1 </td>
   <td style="text-align:right;"> 0.2783620 </td>
   <td style="text-align:right;"> 0.6285714 </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max f2 </td>
   <td style="text-align:right;"> 0.2049758 </td>
   <td style="text-align:right;"> 0.7558140 </td>
   <td style="text-align:right;"> 56 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max f0point5 </td>
   <td style="text-align:right;"> 0.3983419 </td>
   <td style="text-align:right;"> 0.5921053 </td>
   <td style="text-align:right;"> 16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max accuracy </td>
   <td style="text-align:right;"> 0.3983419 </td>
   <td style="text-align:right;"> 0.7804878 </td>
   <td style="text-align:right;"> 16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max precision </td>
   <td style="text-align:right;"> 0.3983419 </td>
   <td style="text-align:right;"> 0.6279070 </td>
   <td style="text-align:right;"> 16 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max recall </td>
   <td style="text-align:right;"> 0.1054178 </td>
   <td style="text-align:right;"> 1.0000000 </td>
   <td style="text-align:right;"> 86 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max specificity </td>
   <td style="text-align:right;"> 0.6115015 </td>
   <td style="text-align:right;"> 0.9731544 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max absolute_mcc </td>
   <td style="text-align:right;"> 0.2783620 </td>
   <td style="text-align:right;"> 0.4686644 </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max min_per_class_accuracy </td>
   <td style="text-align:right;"> 0.2950617 </td>
   <td style="text-align:right;"> 0.7382550 </td>
   <td style="text-align:right;"> 33 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max mean_per_class_accuracy </td>
   <td style="text-align:right;"> 0.2783620 </td>
   <td style="text-align:right;"> 0.7586290 </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max tns </td>
   <td style="text-align:right;"> 0.6115015 </td>
   <td style="text-align:right;"> 145.0000000 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max fns </td>
   <td style="text-align:right;"> 0.6115015 </td>
   <td style="text-align:right;"> 54.0000000 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max fps </td>
   <td style="text-align:right;"> 0.0867271 </td>
   <td style="text-align:right;"> 149.0000000 </td>
   <td style="text-align:right;"> 88 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max tps </td>
   <td style="text-align:right;"> 0.1054178 </td>
   <td style="text-align:right;"> 56.0000000 </td>
   <td style="text-align:right;"> 86 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max tnr </td>
   <td style="text-align:right;"> 0.6115015 </td>
   <td style="text-align:right;"> 0.9731544 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max fnr </td>
   <td style="text-align:right;"> 0.6115015 </td>
   <td style="text-align:right;"> 0.9642857 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max fpr </td>
   <td style="text-align:right;"> 0.0867271 </td>
   <td style="text-align:right;"> 1.0000000 </td>
   <td style="text-align:right;"> 88 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> max tpr </td>
   <td style="text-align:right;"> 0.1054178 </td>
   <td style="text-align:right;"> 1.0000000 </td>
   <td style="text-align:right;"> 86 </td>
  </tr>
</tbody>
</table>

 </td>
  </tr>
</tbody>
</table>


A general plot of the performance as follows :


```r
plot(r)
```

![](/images/AutoML4-1.png)


as well as specific plots.


```r
r$plots$metrics
```

```
## $gains
```

![](/images/AutoML5-1.png)

```
## 
## $response
```

![](/images/AutoML5-2.png)

```
## 
## $conf_matrix
```

![](/images/AutoML5-3.png)

```
## 
## $ROC
```

![](/images/AutoML5-4.png)




## References

+ [H2O AutoML Documentation](https://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html)

+ [lares AutoML Documentation](https://rdrr.io/github/laresbernardo/lares/man/h2o_automl.html)

