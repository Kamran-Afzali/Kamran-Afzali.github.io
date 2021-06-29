---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

# Feature Importance 

In new the era of machine learning and data science, there is an emerging challenge to build state-of-the-art predictive models that also provide an understanding of what’s really going on under the hood and in the data. Therefore, it is often of interest to know which, of the predictors in a fitted model are relatively influential on the predicted outcome. 
There are many methodologies to interpret machine learning results (i.e., variable importance via permutation, partial dependence plots, local interpretable model-agnostic explanations), and many machine learning R packages implement their own versions of one or more methodologies. However, some recent R packages that focus purely on ML interpretability agnostic to any specific ML algorithm are gaining popularity. As a part of a larger framework referred to as interpretable machine learning (IML), VIP is an R package for constructing variable importance plots (VIPs).

## Global Measures

### Model-Based Variable Importance 

Many supervised learning algorithms can naturally emit some measure of importance for the features used in the model, and these approaches are embedded in many different packages. For instance, like gradient boosted decision trees and random forests have a native way of quantifying the importance or relative influence of each feature. These measures compute variable importance specific to the particular model from the native functions of a wide range of packages. 

### Permutation Method

The permutation method exists in various forms the approach used in the VIP package is quite simple. The idea is as permuting the values of a feature affects the relationship between that feature and the target variable if we randomly permute the values of an important feature in the training data, the training performance would decrease. This approach uses the difference between the performance of the baseline full model and the performance obtained after permuting the values of a particular feature. 

### FIRM
FIRM-based variable importance - Compute variable importance by quantifying the variability in marginal effect plots like Partial Dependence Plots and Individual Conditional Expectations via the *pdp package*.

#### PDP Method

Partial Dependence Plots provide model-agnostic interpretations and can be constructed in the same way for any supervised learning algorithm. This approach is based on quantifying the “flatness” of the PDPs of each feature by visualizing the effect of cardinality of the subsets of the feature space on the estimated. 

#### ICE curve Method

The Individual Conditional Expectations curve method is similar to the PDP method, however, in this approach the “flatness” of each ICE curve and then aggregate the results (e.g., by averaging). Therefore, in absence of interaction effects, using method = "ice" will produce results similar to using method = "pdp". Some would argue that it is probably more reasonable to always use method = "ice".

## Local Measures
Global interpretations are based on the relationship between the features and the outcome in the entire model. However, global measures can be highly approximate in some cases. Local measures, in contrast, highlight model predictions for a single observation or a group of similar observations. Local interpretability measures like SHAP-based variable importance and LIME, which stands for Local Interpretable Model-agnostic Explanations, has the potential to facilitate the interpretation of black-box models.

### LIME

Local Interpretable Model-agnostic Explanations (LIME) is a model agnostic method that can be applied to any supervised regression or classification model, based on the the assumption that every complex model is linear on a local scale. In other words, it is possible to fit a simple model around a single observation that will mimic how the global model behaves at that locality. To attain this lime permute features for a given observation and computes similarity distance measure between original observation and permuted observations and then applies selected machine learning model to predict outcomes of permuted data.

### SHAP

Similar to LIME method, Lundberg et al. in their paper “A unified approach to interpreting model predictions” proposed the SHAP (SHapley Additive exPlanations). The SHAP values can provide global interpretability about how much each predictor contributes, either positively or negatively, to the target variable, as well as local interpretability measures where each observation gets its own set of SHAP values which increases its transparency of the model. In contrast to LIME method that creates a substitute model around the local unit to understand. 
Shapely values 'decompose' the final prediction into the contribution of each attribute in an additive way.

## References

+ [Vip: Variable Importance Plots](https://koalaverse.github.io/vip/)

+ [Variable importance plots: an introduction to vip](https://koalaverse.github.io/vip/articles/vip.html)

+ [Visualizing ML Models with LIME](https://uc-r.github.io/lime)

+ [Explain Any Models with the SHAP Values — Use the KernelExplainer](https://towardsdatascience.com/explain-any-models-with-the-shap-values-use-the-kernelexplainer-79de9464897a)

+ [Understanding lime](https://cran.r-project.org/web/packages/lime/vignettes/Understanding_lime.html)

+ [Understanding shapr](https://cran.r-project.org/web/packages/shapr/vignettes/understanding_shapr.html)

+ [Interpretable ML Book](https://github.com/christophM/interpretable-ml-book)
