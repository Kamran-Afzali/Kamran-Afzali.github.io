---
layout: post
categories: posts
title: Automatic Feature Engineering 
featured-image: /images/XAI2.png
tags: [Feature Engineering, Interpretability, Machine Learning]
date-string: 
---


## Introduction

The act of taking raw data and transforming it into features that are used to develop a predictive model using machine learning is referred to as feature engineering. The purpose of feature engineering is to improve the overall performance of machine learning models as well as to produce an input data set that is optimally suited for the algorithm that is being used for machine learning. Data scientists can benefit from feature engineering since it can speed up the time it takes to extract variables from data, which in turn makes it possible to extract a greater number of variables. When businesses and data scientists automate the process of feature engineering, the resulting models will have a higher degree of precision. The objective of feature engineering is to create new features (explantory variables or predictors) to represent as much information from an entire dataset in one table. Typically, this process is done by hand using pandas/dplyr operations such as groupby, agg, or merge and can be very tedious. The importance of creating the proper features cannot be overstated because a machine learning model can only learn from the data we give to it. Extracting as much information as possible from the available datasets is crucial to creating an effective solution. Automated feature engineering aims to help the data scientist with the problem of feature creation by automatically building hundreds or thousands of new features from a dataset. Libraries for automated feature engineering will not replace the data scientist, but it will allow them to focus on more valuable parts of the machine learning pipeline, such as delivering robust models into production. Here we will touch on the concepts of automated feature engineering and show how to implement it.

## Feature Engineering Basics

Feature Engineering is a basic term used to cover many operations that are performed on the features to fit them into the algorithm. It helps in increasing the accuracy of the model thereby enhances the results of the predictions. Feature engineering means building additional features out of existing data which is often spread across multiple related tables. Feature engineering requires extracting the relevant information from the data and getting it into a single table which can then be used to train a machine learning model. The process of constructing features is very time-consuming because each new feature usually requires several steps to build, especially when using information from more than one table. The importance of creating the proper features cannot be overstated because a machine learning model can only learn from the data we give to it. Extracting as much information as possible from the available datasets is crucial to creating an effective solution.


 The following aspects of feature engineering are as follows:

- Feature Scaling: It is done to get the features on the same scale.
- Feature Transformation: It is done to normalize the data by a function.
- Feature Construction: It is done to create new features based on original descriptors to improve the accuracy of the predictive model.
- Feature Reduction: It is done to improve the statistical distribution and accuracy of the predictive model.

Feature engineering is almost always carried out manually, with a reliance on prior domain knowledge, intuitive judgement, and the manipulation of data. This procedure can be quite time-consuming, and the end result will have traits that are constrained by human subjectivity as well as the passage of time. The objective of automated feature engineering is to assist the data scientist by automatically generating a large number of candidate features from a dataset. The most useful of these features can then be chosen for further training. Automated Feature Engineering is a technique that pulls out useful and meaningful features using a framework that can be applied to any problem. Automated feature engineering enables data scientists to be more productive by allowing them to spend more time on other components of machine learning. Automated feature engineering aims to help the data scientist with the problem of feature creation by automatically building hundreds or thousands of new features from a dataset. Here we will touch on the concepts of automated feature engineering with *featuretools* and show how to implement it, we'll look at the features themselves, as well as the results of modeling with different combinations of hand designed and automatically built features.


## Feature Tools
Featuretools is an open source library for performing automated feature engineering. that creates many features from a set of related tables. Featuretools is based on a method known as “Deep Feature Synthesis”. Deep feature synthesis stacks multiple transformation and aggregation operations to create features from data spread across many tables. Like most ideas in machine learning, it’s a complex method built on a foundation of simple concepts. By learning one building block at a time, we can form a good understanding of this powerful method. We need to be aware of the following three main parts of the package:

+ Entities
+ Feature primitives
+ Deep Feature Synthesis (DFS)

### Entities and Entitysets

An entity is simply a table or a dataframe. The observations are in the rows and the features in the columns. An entity in featuretools must have a unique index where none of the elements are duplicated. Entities can also have time indices where each entry is identified by a unique time (relative times, given in months or days, that we could consider treating as time variables). An EntitySet is a collection of tables and the relationships between them. This can be thought of a data structute with its own methods and attributes. Using an EntitySet allows us to group together multiple tables and manipulate them much quicker than individual tables.

### Deep Feature Synthesis

Deep Feature Synthesis (DFS) is the process featuretools uses to make new features. DFS stacks feature primitives to form features with a "depth" equal to the number of primitives. To perform DFS in featuretools, we use the dfs function passing it an entityset, the target_entity (where we want to make the features), the *agg_primitives* to use, the *trans_primitives* to use and the max_depth of the features. Because this process is computationally expensive, we can run the function using features_only = True to return only a list of the features and not calculate the features themselves. This can be useful to look at the resulting features before starting an extended computation.

### Feature Primitives

A feature primitive is an operation applied to a table or a set of tables to create a feature. These represent simple calculations that can be stacked on top of each other to create complex features. Feature primitives frequently used to manually generate features, falling into two categories:

+ Aggregation: function that groups together child datapoints for each parent and then calculates a statistic such as mean, min, max, or standard deviation. 

+ Transformation: an operation applied to one or more columns in a single table. An example would be taking the absolute value of a column, or finding the difference between two columns in one table.


## SAFE an alternative in R

Surrogate Assisted Feature Extraction for Model Learning (SAFE ML) uses a supervisor model to create an interpretable set of newly engineered features extracted from the data. This is an alternative available in R echosystem.

The method can be described in 5 steps:

+ Step 1: Provide a raw tabular data set.

+ Step 2: Train a supervisor machine learning model on a provided data. This model does not need to be interpretable and is treated as a black box.

+ Step 3: Use SAFE to find variable transformations. 

     + (A) For continuous variables use the Partial Dependence Profiles to find changepoints that allow the best binning for the variable of interest. 
     + (B) For categorical variables, use clustering to merge some of the levels.

+ Step 4: Optionally, perform a feature selection on the new set of features that includes original variables from the raw data and variables transformed with the SAFE method.

+ Step 5: Fit a fully interpretable model on selected features. Models that can be used are, for example, logistic regression for classification problems or linear models for regression problems.

## Conclusions

Like many topics in machine learning, automated feature engineering is a complicated concept built on simple ideas. Using simple concepts of entities and relationships, featuretools can perform deep feature synthesis to create new features. The features created by Featuretools are not just random features, they are valuable considering the interpretable nature of this solution. Moreover, automated feature engineering takes a fraction of the time spent manual feature engineering while delivering comparable results. Which makes Featuretools an added value included in a data scientist's toolbox. The next steps are to take advantage of the advanced functionality in featuretools combined with domain knowledge to create a more useful set of features. 


## References

+ [SAFE EXAMPLE](https://www.r-bloggers.com/2021/04/simplify-your-model-supervised-assisted-feature-extraction-for-machine-learning/)

+ [SAFE: Scalable Automatic Feature Engineering](https://rdrr.io/github/MrDomani/autofeat/man/SAFE.html)

+ [Automated Feature Engineering Basics](https://www.kaggle.com/code/willkoehrsen/automated-feature-engineering-basics/notebook)

+ [Feature Tools Quick Start](https://featuretools.alteryx.com/en/stable/)
