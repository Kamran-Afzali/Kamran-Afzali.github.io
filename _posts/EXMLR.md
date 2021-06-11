---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

<https://koalaverse.github.io/vip/>

<https://koalaverse.github.io/vip/articles/vip.html>

<https://cran.r-project.org/web/packages/vip/vignettes/vip-introduction.pdf>

<https://uc-r.github.io/lime>

<https://www.business-science.io/business/2018/06/25/lime-local-feature-interpretation.html>

<https://juliasilge.com/blog/mario-kart/>


vip is an R package for constructing variable importance plots (VIPs). VIPs are part of a larger framework referred to as interpretable machine learning (IML), which includes (but not limited to): partial dependence plots (PDPs) and individual conditional expectation (ICE) curves. While PDPs and ICE curves (available in the R package pdp) help visualize feature effects, VIPs help visualize feature impact (either locally or globally). An in-progress, but comprehensive, overview of IML can be found here: https://github.com/christophM/interpretable-ml-book.

Many supervised learning algorithms can naturally emit some measure of importance for the features used in the model, and these approaches are embedded in many different packages. 


In the era of “big data”, it is becoming more of a challenge to not only build state-of-the-art predictive models, but also gain an understanding of what’s really going on in the data. For example, it is often of interest to know which, if any, of the predictors in a fitted model are relatively influential on the predicted outcome. Some modern algorithms—like random forests and gradient boosted decision trees—have a natural way of quantifying the importance or relative influence of each feature.


Features
Model-based variable importance - Compute variable importance specific to a particular model (like a random forest, gradient boosted decision trees, or multivariate adaptive regression splines) from a wide range of package (e.g., randomForest, ranger, xgboost, and many more). Also supports the caret and parsnip (starting with version 0.0.4) packages.

Permutation-based variable importance - An efficient implementation of the permutation feature importance algorithm discussed in this chapter from Christoph Molnar’s Interpretable Machine Learning book.


Global interpretations help us understand the inputs and their entire modeled relationship with the prediction target, but global interpretations can be highly approximate in some cases. Local interpretations help us understand model predictions for a single row of data or a group of similar rows.This post demonstrates how to use the lime package to perform local interpretations of ML models. This will not focus on the theoretical and mathematical underpinnings but, rather, on the practical application of using lime.
SHAP-based variable importance - An efficient implementation of feature importance based on the popular SHAP values via the fastshap package.  LIME, which stands for Local Interpretable Model-agnostic Explanations, has opened the doors to black-box (complex, high-performance, but unexplainable) models in business applications! 


There are many methodologies to interpret machine learning results (i.e. variable importance via permutation, partial dependence plots, local interpretable model-agnostic explanations), and many machine learning R packages implement their own versions of one or more methodologies. However, some recent R packages that focus purely on ML interpretability agnostic to any specific ML algorithm are gaining popularity. One such package is DALEX and this post covers what this package does (and does not do) so that you can determine if it should become part of your preferred machine learning toolbox.

PDP/ICE-based variable importance - Compute variable importance by quantifying the variability in marginal effect plots like partial dependence plots and individual conditional expectations via the pdp package.


PDP method

Our first model-agnostic approach is based on quantifying the “flatness” of the PDPs of each feature. PDPs help visualize the effect of low cardinality subsets of the feature space on the estimated prediction surface (e.g., main effects and two/three-way interaction effects.). PDPs provide model-agnostic interpretations and can be constructed in the same way for any supervised learning algorithm. Below, we fit a projection pursuit regression (PPR) model and construct PDPs for each feature using the pdp package (Greenwell 2017).

ICE curve method

The ICE curve method is similar to the PDP method. The only difference is that we measure the “flatness” of each ICE curve and then aggregate the results (e.g., by averaging)2. If there are no (substantial) interaction effects, using method = "ice" will produce results similar to using method = "pdp". However, if strong interaction effects are present, they can obfuscate the main effects and render the PDP-based approach less useful (since the PDPs for important features can be relatively flat when certain interactions are present; see Goldstein et al. (2015) for details). In fact, it is probably safest to always use method = "ice".

