---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---


# Feature Importance 

In the era of “big data”, it is becoming more of a challenge to not only build state-of-the-art predictive models, but also gain an understanding of what’s really going on in the data. For example, it is often of interest to know which, if any, of the predictors in a fitted model are relatively influential on the predicted outcome. Some modern algorithms—like random forests and gradient boosted decision trees—have a natural way of quantifying the importance or relative influence of each feature.

vip is an R package for constructing variable importance plots (VIPs). VIPs are part of a larger framework referred to as interpretable machine learning (IML), which includes (but not limited to): partial dependence plots (PDPs) and individual conditional expectation (ICE) curves. While PDPs and ICE curves (available in the R package pdp) help visualize feature effects, VIPs help visualize feature impact (either locally or globally). 

There are many methodologies to interpret machine learning results (i.e. variable importance via permutation, partial dependence plots, local interpretable model-agnostic explanations), and many machine learning R packages implement their own versions of one or more methodologies. However, some recent R packages that focus purely on ML interpretability agnostic to any specific ML algorithm are gaining popularity. One such package is DALEX and this post covers what this package does (and does not do) so that you can determine if it should become part of your preferred machine learning toolbox.


## Global Measures

### Model-Based Variable Importance 

These mesures compute variable importance specific to a particular model (like a random forest, gradient boosted decision trees, or multivariate adaptive regression splines) from a wide range of package (e.g., randomForest, ranger, xgboost, and many more). Also supports the caret and parsnip (starting with version 0.0.4) packages. Many supervised learning algorithms can naturally emit some measure of importance for the features used in the model, and these approaches are embedded in many different packages. 

### Permutation Method

The permutation method exists in various forms and was made popular in Breiman (2001) for random forests. A more general approach to the permutation method is described in Assessing Variable Importance for Predictive Models of Arbitrary Type, an R package vignette by DataRobot. The permutation approach used in vip is quite simple. The idea is that if we randomly permute the values of an important feature in the training data, the training performance would degrade (since permuting the values of a feature effectively destroys any relationship between that feature and the target variable). This of course assumes that the model has been properly tuned (e.g., using cross-validation) and is not over fitting. The permutation approach uses the difference between some baseline performance measure  and the same performance measure obtained after permuting the values of a particular feature in the training data (Note: the model is NOT refit to the training data after randomly permuting the values of a feature). To use the permutation approach, specify method = "permute" in the call to vi() or vip(). Note that using method = "permute" requires specifying a few additional arguments; see ?vi_permute for details. Permutation-based variable importance - An efficient implementation of the permutation feature importance algorithm discussed in this chapter from Christoph Molnar’s Interpretable Machine Learning book.

### FIRM
FIRM-based variable importance - Compute variable importance by quantifying the variability in marginal effect plots like Partial Dependence Plots and Individual Conditional Expectations via the *pdp package*.


#### PDP Method

Our first model-agnostic approach is based on quantifying the “flatness” of the PDPs of each feature. PDPs help visualize the effect of low cardinality subsets of the feature space on the estimated prediction surface (e.g., main effects and two/three-way interaction effects.). PDPs provide model-agnostic interpretations and can be constructed in the same way for any supervised learning algorithm. Below, we fit a projection pursuit regression (PPR) model and construct PDPs for each feature using the pdp package (Greenwell 2017).

#### ICE curve Method

The ICE curve method is similar to the PDP method. The only difference is that we measure the “flatness” of each ICE curve and then aggregate the results (e.g., by averaging)2. If there are no (substantial) interaction effects, using method = "ice" will produce results similar to using method = "pdp". However, if strong interaction effects are present, they can obfuscate the main effects and render the PDP-based approach less useful (since the PDPs for important features can be relatively flat when certain interactions are present; see Goldstein et al. (2015) for details). In fact, it is probably safest to always use method = "ice".

## Local Measures
Global interpretations help us understand the inputs and their entire modeled relationship with the prediction target, but global interpretations can be highly approximate in some cases. Local interpretations help us understand model predictions for a single row of data or a group of similar rows.This post demonstrates how to use the lime package to perform local interpretations of ML models. This will not focus on the theoretical and mathematical underpinnings but, rather, on the practical application of using lime.

SHAP-based variable importance - An efficient implementation of feature importance based on the popular SHAP values via the fastshap package.  LIME, which stands for Local Interpretable Model-agnostic Explanations, has opened the doors to black-box (complex, high-performance, but unexplainable) models in health usecases! 


### LIME


Local Interpretable Model-agnostic Explanations (LIME) is a visualization technique that helps explain individual predictions. As the name implies, it is model agnostic so it can be applied to any supervised regression or classification model. Behind the workings of LIME lies the assumption that every complex model is linear on a local scale and asserting that it is possible to fit a simple model around a single observation that will mimic how the global model behaves at that locality. The simple model can then be used to explain the predictions of the more complex model locally.

The generalized algorithm LIME applies is as follows:

Given an observation, permute it to create replicated feature data with slight value modifications.
Compute similarity distance measure between original observation and permuted observations.
Apply selected machine learning model to predict outcomes of permuted data.

Select m number of features to best describe predicted outcomes, fit a simple model to the permuted data, explaining the complex model outcome with m features from the permuted data weighted by its similarity to the original observation and to use the resulting feature weights to explain local behavior.

### SHAP

Use the SHAP Values to Interpret Your Sophisticated Model Consider this question: “Is your sophisticated machine learning model easy to understand?” That means your model can be understood by input variables that make business sense. Your variables will fit the expectations of users that they have learned from prior knowledge.

Lundberg et al. in their brilliant paper “A unified approach to interpreting model predictions” proposed the SHAP (SHapley Additive exPlanations) values which offer a high level of interpretability for a model. The SHAP values provide two great advantages:
Global interpretability — the SHAP values can show how much each predictor contributes, either positively or negatively, to the target variable. This is like the variable importance plot but it is able to show the positive or negative relationship for each variable with the target (see the summary plots below).

Local interpretability — each observation gets its own set of SHAP values (see the individual force plots below). This greatly increases its transparency. We can explain why a case receives its prediction and the contributions of the predictors. Traditional variable importance algorithms only show the results across the entire population but not on each individual case. The local interpretability enables us to pinpoint and contrast the impacts of the factors.

In other words, given a certain prediction, like having a likelihood of buying= 90%, what was the influence of each input variable in order to get that score? Shapley values calculate the importance of a feature by comparing what a model predicts with and without the feature. However, since the order in which a model sees features can affect its predictions, this is done in every possible order, so that the features are fairly compared.SHAP measures the impact of variables taking into account the interaction with other variables.



## Refrences

+ [vip: Variable Importance Plots](https://koalaverse.github.io/vip/)

+ [Variable importance plots: an introduction to vip](https://koalaverse.github.io/vip/articles/vip.html)

+ [Visualizing ML Models with LIME](https://uc-r.github.io/lime)

+ [Explain Any Models with the SHAP Values — Use the KernelExplainer](https://towardsdatascience.com/explain-any-models-with-the-shap-values-use-the-kernelexplainer-79de9464897a)

+ [Understanding lime](https://cran.r-project.org/web/packages/lime/vignettes/Understanding_lime.html)

+ [Understanding shapr](https://cran.r-project.org/web/packages/shapr/vignettes/understanding_shapr.html)

+ [Interpretable ML Book](https://github.com/christophM/interpretable-ml-book)
