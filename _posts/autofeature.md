




## Introduction
The act of taking raw data and transforming it into features that are used to develop a predictive model using machine learning is referred to as feature engineering. It uses the raw data as its starting point.
The purpose of feature engineering is to improve the overall performance of machine learning models as well as to produce an input data set that is optimally suited for the algorithm that is being used for machine learning.
Data scientists can benefit from feature engineering since it can speed up the time it takes to extract variables from data, which in turn makes it possible to extract a greater number of variables. When businesses and data scientists automate the process of feature engineering, the resulting models will have a higher degree of precision.
Automated Feature Engineering
Feature engineering is almost always carried out manually, with a reliance on prior domain knowledge, intuitive judgement, and the manipulation of data. This procedure can be quite time-consuming, and the end result will have traits that are constrained by human subjectivity as well as the passage of time. The objective of automated feature engineering is to assist the data scientist by automatically generating a large number of candidate features from a dataset. The most useful of these features can then be chosen for further training.
Automated Feature Engineering is a technique that pulls out useful and meaningful features using a framework that can be applied to any problem. Automated feature engineering enables data scientists to be more productive by allowing them to spend more time on other components of machine learning. This technique also allows citizen data scientists to do feature engineering using a framework-based approach.
In this article we will review the most popular Automated Feature Engineering frameworks in Python that data scientists must know about in 2022.
Feature Tools
TSFresh
Featurewiz
PyCaret



In this post, we present a framework for Surrogate Assisted Feature Extraction for Model Learning (SAFE ML). SAFE ML uses the elastic black box as a supervisor model to create an interpretable, yet still accurate glass box model. The main idea is to train a new interpretable model on newly engineered features extracted from the supervisor model.

The objective of feature engineering is to create new features (alos called explantory variables or predictors) to represent as much information from an entire dataset in one table. Typically, this process is done by hand using pandas operations such as groupby, agg, or merge and can be very tedious. Moreover, manual feature engineering is limited both by human time constraints and imagination: we simply cannot conceive of every possible feature that will be useful. (For an example of using manual feature engineering, check out part one and part two applied to this competition). The importance of creating the proper features cannot be overstated because a machine learning model can only learn from the data we give to it. Extracting as much information as possible from the available datasets is crucial to creating an effective solution.

Automated feature engineering aims to help the data scientist with the problem of feature creation by automatically building hundreds or thousands of new features from a dataset. Featuretools - the only library for automated feature engineering at the moment - will not replace the data scientist, but it will allow her to focus on more valuable parts of the machine learning pipeline, such as delivering robust models into production.

Here we will touch on the concepts of automated feature engineering with featuretools and show how to implement it for the Home Credit Default Risk competition. We will stick to the basics so we can get the ideas down and then build upon this foundation in later work when we customize featuretools. We will work with a subset of the data because this is a computationally intensive job that is outside the capabilities of the Kaggle kernels. I took the work done in this notebook and ran the methods on the entire dataset with the results available here. At the end of this notebook, we'll look at the features themselves, as well as the results of modeling with different combinations of hand designed and automatically built features.


## Feature Engineering Basics
Feature engineering means building additional features out of existing data which is often spread across multiple related tables. Feature engineering requires extracting the relevant information from the data and getting it into a single table which can then be used to train a machine learning model.
The process of constructing features is very time-consuming because each new feature usually requires several steps to build, especially when using information from more than one table. We can group the operations of feature creation into two categories: transformations and aggregations. Let’s look at a few examples to see these concepts in action.

## Feature Tools

Featuretools is an open source library for performing automated feature engineering. It is a fantastic tool made to expedite the feature creation process so that more time can be spent on other parts of creating machine learning models. In other words, it makes your data machine learning ready.
We need to be aware of the following three main parts of the package:

+ Entities
+ Deep Feature Synthesis (DFS)
+ Feature primitives

A Pandas DataFrame can be thought of as being represented by an Entity. An EntitySet is a group of various entities.
The core of Featuretools is Deep Feature Synthesis (DFS), which is actually a Feature Engineering method. It makes it possible to build new features out of both single and multiple DataFrames.
By using Feature primitives on the Entity-relationships in an EntitySet, DFS creates features. These primitives are frequently used to manually generate features. The original “mean” function, for instance, would determine the mean of a variable at the aggregate level.
Example reproduced from Official [Feature Tools Quick Start](https://featuretools.alteryx.com/en/stable/).

## Conclusions
Like many topics in machine learning, automated feature engineering with featuretools is a complicated concept built on simple ideas. Using concepts of entitysets, entities, and relationships, featuretools can perform deep feature synthesis to create new features. Deep feature synthesis in turn stacks feature primitives — aggregations, which act across a one-to-many relationship between tables, and transformations, functions applied to one or more columns in a single table — to build new features from multiple tables.




+ [link](https://www.r-bloggers.com/2021/04/simplify-your-model-supervised-assisted-feature-extraction-for-machine-learning/)

+ [link](https://rdrr.io/github/MrDomani/autofeat/man/SAFE.html)

+ [link](https://www.geeksforgeeks.org/feature-engineering-in-r-programming/)

+ [link](https://www.kaggle.com/code/willkoehrsen/automated-feature-engineering-basics/notebook)

+ [link](https://moez-62905.medium.com/top-automated-feature-engineering-frameworks-in-python-in-2022-9899d7b18f7e)

+ [link](https://towardsdatascience.com/automated-feature-engineering-in-python-99baf11cc219)

+ [Feature Tools Quick Start](https://featuretools.alteryx.com/en/stable/)
