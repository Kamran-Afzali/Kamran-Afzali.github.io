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
