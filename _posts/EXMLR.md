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

SHAP-based variable importance - An efficient implementation of feature importance based on the popular SHAP values via the fastshap package.

PDP/ICE-based variable importance - Compute variable importance by quantifying the variability in marginal effect plots like partial dependence plots and individual conditional expectations via the pdp package.


