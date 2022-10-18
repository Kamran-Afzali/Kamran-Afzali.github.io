---
layout: post
categories: posts
title: H2O AutoML   
featured-image: /images/dbplyr.png
tags: [AutoML, H2O, Machine Learning]
date-string: Octobre 2022
---

## Introduction: AutoML 

Over the past few years, demand for machine learning systems has skyrocketed. This is mostly because machine learning techniques have been effective in a variety of applications. By enabling users from a variety of backgrounds to apply machine learning models to address complicated scenarios, AutoML is fundamentally altering the face of ML-based solutions today. Nevertheless, despite abundant evidence that machine learning can benefit several industries, many firms today still find it difficult to implement ML models.

This is due to a lack of seasoned and competent data scientists in the field. The demand for machine learning specialists has, in some ways, exceeded the supply. Second, many machine learning procedures call for more experience than knowledge, particularly when determining which models to train and how to evaluate them. Today, there are many efforts being made to close these gaps, which are rather obvious. We will examine in-depth how automated machine learning can be accomplished in this post in order to see if it can be a solution to these obstacles. 

Automated machine learning (AutoML) is the process of fully automating the machine learning application to practical issues. With the least amount of human effort, autoML aims to automate as many processes as possible in an ML pipeline without sacrificing the model's performance. 

The training, fine-tuning, and deployment of machine learning models are all automated using the automated machine learning technique known as AutoML. Without the need for human participation, AutoML can be used to automatically find the optimal model for a particular dataset and task.

Because it can automate the process of developing and deploying machine learning models, AutoML is a crucial tool for making machine learning approachable to non-experts. This can expedite machine learning research and save time and resources. The key innovation in AutoML is the hyperparameters search technique, which is used for preprocessing elements, choosing model types, and improving their hyperparameters. There are many different types of optimization algorithms, ranging from Bayesian and evolutionary algorithms to random and grid search.

The performance of current autoML frameworks is enhanced by experience as well. AutoML encourages the data scientist to keep a strategic distance from the technical labour involved in the model building but cannot replace the data scientist's knowledge and understanding of the project. 

Various strategies can be used to approach AutoML, depending on the precise issue that has to be resolved. For instance, some approaches concentrate on identifying the best model for a particular job, while others concentrate on optimising a model for a specific dataset. 

Whatever the strategy, AutoML can be a potent tool for improving the usability and effectiveness of machine learning. AutoML will likely be used more and more in the future in both business and academia.

This post aims to introduce you to H2O as one of the top AutoML Tools and Platforms. 

Pro’s

- Time saving: It’s a quick and dirty prototyping tool. If you are not working on critical task, you could use AutoML to do the job for you while you focus on more critical tasks.

- Benchmarking: Building an ML/DL model is fun. But, how do you know the model you have is the best? You either have to spend a lot of time in building iterative models or ask your colleague to build one and compare it. The other option is to use AutoML to benchmark yours.


Con’s

- Most AI models that we come across are black box. Similar is the case with these AutoML frameworks. If you don’t understand what you are doing, it could be catastrophic.

- Based on my previous point, AutoML is being marketed as a tool for non-data scientists. This is a bad move. Without understanding how a model works and blindly using it for making decisions could be disastrous.




## H2O AutoML

Now talking about AutoML part of H2O, AutoML helps in automatic training and tuning of many models within a user-specified time limit. The current version of AutoML function can train and cross-validate a Random Forest, an Extremely-Randomized Forest, a random grid of Gradient Boosting Machines (GBMs), a random grid of Deep Neural Nets, and then trains a Stacked Ensemble using all of the models. When we say AutoML, it should cater to the aspects of data preparation, Model generation, and Ensembles and also provide few parameters as possible so that users can perform tasks with much less confusion. H2o AutoML does perform this task with ease and the minimal parameter passed by the user. In both R and Python API, it uses the same data related arguments x, y, training_frame, validation frame out of which y and training_frame are required parameter and rest are optional. You can also configure values for max_runtime_sec and max_models here max_runtime_sec parameter is required, and max_model is optional if you don’t pass any parameter it takes NULL by default. The x parameter is the vector of predictors from training_frame if you don’t want to use all predictors from the frame you passed you can set it by passing it to x. Now let's talk about some optional and miscellaneous parameters, try to tweak the parameters even if you don’t know about it, it will lead you to gain knowledge over some advanced topics:

+ Input a dataframe df and choose which one is the independent variable (y) you’d like to predict. You may set/change the seed argument to guarantee reproducibility of your results.

+ The function decides if it’s a classification (categorical) or regression (continuous) model looking at the independent variable’s (y) class and number of unique values, which can be control with the thresh parameter.

+ The dataframe will be split in two: test and train datasets. The proportion of this split can be control with the split argument. This can be replicated with the msplit() function.

+ You could also center and scale your numerical values before you continue, use the no_outliers to exclude some outliers, and/or impute missing values with MICE. If it’s a classification model, the function can balance (under-sample) your training data. You can control this behavior with the balance argument. Until here, you can replicate the whole process with the model_preprocess() function.

+ Runs h2o::h2o.automl(...) to train multiple models and generate a leaderboard with the top (max_models or max_time) models trained, sorted by their performance. You can also customize some additional arguments such as nfolds for k-fold cross-validations, exclude_algos and include_algos to exclude or include some algorithms, and any other additional argument you wish to pass to the mother function.

+ The best model given the default performance metric (which can be changed with stopping_metric parameter) evaluated with cross-validation (customize it with nfolds), will be selected to continue. You can also use the function h2o_selectmodel() to select another model and recalculate/plot everything again using this alternate model.

+ Performance metrics and plots will be calculated and rendered given the test predictions and test actual values (which were NOT passed to the models as inputs to be trained with). That way, your model’s performance metrics shouldn’t be biased. You can replicate these calculations with the model_metrics() function.

+ A list with all the inputs, leaderboard results, best selected model, performance metrics, and plots. You can either (play) see the results on console or export them using the export_results() function.


## Mapping H2O AutoML Functionalities


+ validation_frame: This parameter is used for early stopping of individual models in the automl. It is a dataframe that you pass for validation of a model or can be a part of training data if not passed by you.


+ leaderboard_frame: If passed the models will be scored according to the values instead of using cross-validation metrics. Again the values are a part of training data if not passed by you.


+ nfolds: K-fold cross-validation by default 5, can be used to decrease the model performance.
fold_columns: Specifies the index for cross-validation.


+ weights_column: If you want to provide weights to specific columns you can use this parameter, assigning weight 0 means you are excluding the column.
ignored_columns: Only in python, it is converse of x.


+ stopping_metric: Specifies a metric for early stopping of the grid searches and models default value is logloss for classification and deviation for regression.

+ sort_metric: The parameter to sort the leaderboard models at the end. This defaults to AUC for binary classification, mean_per_class_error for multinomial classification, and deviance for regression.

+ The validation_frame and leaderboard_frame depend on the cross-validation parameter that is nfolds. The following scenarios can generate in two cases: when we are using cross-validation in the automl: * Only training frame is passed - Then data will split into 80-20 of training and validation frame.


+ training and leaderboard frame is passed - No change in the 80-20 split of data in training and validation frame. * When training and validation frame is passed - No split. 

+ when all three frames are passed - No splits. When we are not using cross-validation which will affect the leaderboard frame a lot(nfolds = 0): 

+ Only training frame is passed - The data is split into 80/10/10 training, validation, and leaderboard. 

+ training and leaderboard frame is passed - Data split into 80-20 of training and validation frames. 

+ When training and validation frame is passed - The validation_frame data is split into 50-50 validation and leaderboard. 

+ when all three frames are passed - No splits.

By creating user-friendly machine learning software, H2O AutoML meets the demand for machine learning specialists. This AutoML tool aims to provide straightforward and consistent user interfaces for various machine learning algorithms while streamlining machine learning. Machine learning models are automatically trained and tuned within a user-specified time frame. The lares package has multiple families of functions to help the analyst or data scientist achieve quality robust analysis without the need of much coding. One of the most complex but valuable functions we have is h2o_automl, which semi-automatically runs the whole pipeline of a Machine Learning model given a dataset and some customizable parameters. AutoML enables you to train high-quality models specific to your needs and accelerate the research and development process.

Before getting to the code, I recommend checking h2o_automl's full documentation [here](https://docs.h2o.ai/h2o/latest-stable/h2o-r/docs/reference/h2o.automl.html) or within your R session by running ?lares::h2o_automl. In it you'll find a brief description of all the parameters you can set into the function to get exactly what you need and control how it behaves.


```
h2o.init()
train_data <- as.h2o(ice_train)

h2oAML <- h2o.automl(
  y = y,
  x = x,
  training_frame = train_data,
  project_name = "ice_the_kicker_bakeoff",
  balance_classes = T,
  max_runtime_secs = 600,
  seed = 20220425
)


leaderboard_tbl <- h2oAML@leaderboard %>% as_tibble()

leaderboard_tbl %>% head() %>% kable()

model_names <- leaderboard_tbl$model_id

top_model <- h2o.getModel(model_names[1])

top_model@model$model_summary %>%pivot_longer(cols = everything(),names_to = "Parameter", values_to = "Value") %>%kable(align = 'c')

h2o_predictions <- h2o.predict(top_model, newdata = as.h2o(ice_test)) %>%
  as_tibble() %>%
  bind_cols(ice_test)

h2o_metrics <- bind_rows(
  #Calculate Performance Metrics
  yardstick::f_meas(h2o_predictions, is_iced, predict),
  yardstick::precision(h2o_predictions, is_iced, predict),
  yardstick::recall(h2o_predictions, is_iced, predict)
) %>%
  mutate(label = "h2o", .before = 1) %>% 
  rename_with(~str_remove(.x, '\\.')) %>%
  select(-estimator)

kable(h2o_metrics)

h2o_cf <- h2o_predictions %>% 
  count(is_iced, pred= predict) %>% 
  mutate(label = "h2o", .before = 1)

```


```
library(lares)

r <- h2o_automl(df, y = Survived, max_models = 1, impute = FALSE, target = "TRUE")
r$plots$metrics
head(r$importance)
r$metrics

r <- h2o_automl(df, y = "Fare", ignore = "Pclass", exclude_algos = NULL, quiet = TRUE)
print(r)
plot(r)
```


## References

+ []https://datascienceplus.com/real-plug-and-play-supervised-learning-automl-using-r-and-lares/

+ [H2O AutoML Documentation](https://docs.h2o.ai/h2o/latest-stable/h2o-docs/automl.html)

+ []https://www.r-bloggers.com/2020/04/automl-frameworks-in-r-python/

+ []https://jlaw.netlify.app/2022/05/03/ml-for-the-lazy-can-automl-beat-my-model/

+ []https://www.datacamp.com/tutorial/h2o-automl

+ []https://rstudio-pubs-static.s3.amazonaws.com/577204_d3775b5bd4da4b1fba57cd8b0105db03.html
