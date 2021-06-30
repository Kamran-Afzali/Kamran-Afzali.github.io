---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

# Feature Importance

In new the era of machine learning and data science, there is an emerging challenge to build state-of-the-art predictive models that also provide an understanding of what's really going on under the hood and in the data. Therefore, it is often of interest to know which, of the predictors in a fitted model are relatively influential on the predicted outcome. There are many methodologies to interpret machine learning results (i.e., variable importance via permutation, partial dependence plots, local interpretable model-agnostic explanations), and many machine learning R packages implement their own versions of one or more methodologies. However, some recent R packages that focus purely on ML interpretability agnostic to any specific ML algorithm are gaining popularity. As a part of a larger framework referred to as interpretable machine learning (IML), VIP is an R package for constructing variable importance plots (VIPs).



here for our example we use the diabetes data from pdp package


```r
data(pima, package = "pdp")
out="diabetes"
preds=colnames(pima)[-c(9)]
df=pima%>%
  select(c(out,preds))%>% 
  drop_na()
```


```r
table(df$diabetes)
```

```
## 
## neg pos 
## 262 130
```

first data is divided to train and test sets and pre-processing is done with the Recipes package


```r
df_split <- initial_split(df)
train_data <- training(df_split)
test_data <- testing(df_split)
cv_train <- vfold_cv(train_data, v = 5, repeats = 2, strata = out)

standardized <- recipe(diabetes ~ ., data = train_data)%>%
  step_center(all_predictors())  %>%
  step_scale(all_predictors()) %>%
  themis::step_smote (diabetes)
```

```r
train_preped <- prep(standardized) %>%
  bake(new_data = NULL)

test_preped <-  prep(standardized) %>%
  bake(new_data = test_data)


require(doParallel)

cores <- parallel::detectCores(logical = FALSE)
registerDoParallel(cores = cores)
```

then we fine tune a random forest model using the tidymodels framework


```r
rf_mod <- 
  rand_forest(mtry = tune(), min_n = tune(), trees = tune()) %>% 
  set_engine("ranger", num.threads = cores) %>% 
  set_mode("classification")

rf_mod
```

```
## Random Forest Model Specification (classification)
## 
## Main Arguments:
##   mtry = tune()
##   trees = tune()
##   min_n = tune()
## 
## Engine-Specific Arguments:
##   num.threads = cores
## 
## Computational engine: ranger
```

```r
rf_workflow <- 
  workflow() %>% 
  add_model(rf_mod) %>% 
  add_recipe(standardized)

rf_workflow
```

```
## ══ Workflow ════════════════════════════════════════════════════════════════════
## Preprocessor: Recipe
## Model: rand_forest()
## 
## ── Preprocessor ────────────────────────────────────────────────────────────────
## 3 Recipe Steps
## 
## • step_center()
## • step_scale()
## • step_smote()
## 
## ── Model ───────────────────────────────────────────────────────────────────────
## Random Forest Model Specification (classification)
## 
## Main Arguments:
##   mtry = tune()
##   trees = tune()
##   min_n = tune()
## 
## Engine-Specific Arguments:
##   num.threads = cores
## 
## Computational engine: ranger
```

```r
set.seed(345)
rf_res <- 
  rf_workflow %>% 
  tune_grid(grid = 10,
            control = control_stack_grid(),
            metrics = metric_set(roc_auc,f_meas,sens,bal_accuracy), 
            resamples = cv_train)
```

```r
rf_res %>%
  collect_metrics()
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["mtry"],"name":[1],"type":["int"],"align":["right"]},{"label":["trees"],"name":[2],"type":["int"],"align":["right"]},{"label":["min_n"],"name":[3],"type":["int"],"align":["right"]},{"label":[".metric"],"name":[4],"type":["chr"],"align":["left"]},{"label":[".estimator"],"name":[5],"type":["chr"],"align":["left"]},{"label":["mean"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["n"],"name":[7],"type":["int"],"align":["right"]},{"label":["std_err"],"name":[8],"type":["dbl"],"align":["right"]},{"label":[".config"],"name":[9],"type":["chr"],"align":["left"]}],"data":[{"1":"7","2":"79","3":"3","4":"bal_accuracy","5":"binary","6":"0.7262972","7":"10","8":"0.007542948","9":"Preprocessor1_Model01"},{"1":"7","2":"79","3":"3","4":"f_meas","5":"binary","6":"0.8046735","7":"10","8":"0.007467088","9":"Preprocessor1_Model01"},{"1":"7","2":"79","3":"3","4":"roc_auc","5":"binary","6":"0.8248448","7":"10","8":"0.007430446","9":"Preprocessor1_Model01"},{"1":"7","2":"79","3":"3","4":"sens","5":"binary","6":"0.7789103","7":"10","8":"0.014824949","9":"Preprocessor1_Model01"},{"1":"2","2":"1531","3":"35","4":"bal_accuracy","5":"binary","6":"0.7340283","7":"10","8":"0.011044573","9":"Preprocessor1_Model02"},{"1":"2","2":"1531","3":"35","4":"f_meas","5":"binary","6":"0.8094019","7":"10","8":"0.010608097","9":"Preprocessor1_Model02"},{"1":"2","2":"1531","3":"35","4":"roc_auc","5":"binary","6":"0.8391498","7":"10","8":"0.007440679","9":"Preprocessor1_Model02"},{"1":"2","2":"1531","3":"35","4":"sens","5":"binary","6":"0.7838462","7":"10","8":"0.019683141","9":"Preprocessor1_Model02"},{"1":"7","2":"899","3":"27","4":"bal_accuracy","5":"binary","6":"0.7315283","7":"10","8":"0.008668853","9":"Preprocessor1_Model03"},{"1":"7","2":"899","3":"27","4":"f_meas","5":"binary","6":"0.8066621","7":"10","8":"0.007903942","9":"Preprocessor1_Model03"},{"1":"7","2":"899","3":"27","4":"roc_auc","5":"binary","6":"0.8300843","7":"10","8":"0.008985996","9":"Preprocessor1_Model03"},{"1":"7","2":"899","3":"27","4":"sens","5":"binary","6":"0.7788462","7":"10","8":"0.015873926","9":"Preprocessor1_Model03"},{"1":"7","2":"370","3":"31","4":"bal_accuracy","5":"binary","6":"0.7329099","7":"10","8":"0.010476307","9":"Preprocessor1_Model04"},{"1":"7","2":"370","3":"31","4":"f_meas","5":"binary","6":"0.8064428","7":"10","8":"0.007026829","9":"Preprocessor1_Model04"},{"1":"7","2":"370","3":"31","4":"roc_auc","5":"binary","6":"0.8274426","7":"10","8":"0.009857086","9":"Preprocessor1_Model04"},{"1":"7","2":"370","3":"31","4":"sens","5":"binary","6":"0.7763462","7":"10","8":"0.013817519","9":"Preprocessor1_Model04"},{"1":"5","2":"1944","3":"36","4":"bal_accuracy","5":"binary","6":"0.7237652","7":"10","8":"0.008416858","9":"Preprocessor1_Model05"},{"1":"5","2":"1944","3":"36","4":"f_meas","5":"binary","6":"0.8015843","7":"10","8":"0.006947517","9":"Preprocessor1_Model05"},{"1":"5","2":"1944","3":"36","4":"roc_auc","5":"binary","6":"0.8331140","7":"10","8":"0.008947380","9":"Preprocessor1_Model05"},{"1":"5","2":"1944","3":"36","4":"sens","5":"binary","6":"0.7738462","7":"10","8":"0.015023297","9":"Preprocessor1_Model05"},{"1":"5","2":"594","3":"13","4":"bal_accuracy","5":"binary","6":"0.7288293","7":"10","8":"0.009666119","9":"Preprocessor1_Model06"},{"1":"5","2":"594","3":"13","4":"f_meas","5":"binary","6":"0.8077297","7":"10","8":"0.008466145","9":"Preprocessor1_Model06"},{"1":"5","2":"594","3":"13","4":"roc_auc","5":"binary","6":"0.8350709","7":"10","8":"0.008067185","9":"Preprocessor1_Model06"},{"1":"5","2":"594","3":"13","4":"sens","5":"binary","6":"0.7839744","7":"10","8":"0.015896919","9":"Preprocessor1_Model06"},{"1":"3","2":"1742","3":"16","4":"bal_accuracy","5":"binary","6":"0.7353104","7":"10","8":"0.007277794","9":"Preprocessor1_Model07"},{"1":"3","2":"1742","3":"16","4":"f_meas","5":"binary","6":"0.8111909","7":"10","8":"0.007977542","9":"Preprocessor1_Model07"},{"1":"3","2":"1742","3":"16","4":"roc_auc","5":"binary","6":"0.8375742","7":"10","8":"0.007962167","9":"Preprocessor1_Model07"},{"1":"3","2":"1742","3":"16","4":"sens","5":"binary","6":"0.7864103","7":"10","8":"0.016920001","9":"Preprocessor1_Model07"},{"1":"3","2":"1210","3":"18","4":"bal_accuracy","5":"binary","6":"0.7338293","7":"10","8":"0.009509038","9":"Preprocessor1_Model08"},{"1":"3","2":"1210","3":"18","4":"f_meas","5":"binary","6":"0.8136936","7":"10","8":"0.008964393","9":"Preprocessor1_Model08"},{"1":"3","2":"1210","3":"18","4":"roc_auc","5":"binary","6":"0.8375776","7":"10","8":"0.007998350","9":"Preprocessor1_Model08"},{"1":"3","2":"1210","3":"18","4":"sens","5":"binary","6":"0.7939744","7":"10","8":"0.017463998","9":"Preprocessor1_Model08"},{"1":"4","2":"1084","3":"24","4":"bal_accuracy","5":"binary","6":"0.7339288","7":"10","8":"0.008288612","9":"Preprocessor1_Model09"},{"1":"4","2":"1084","3":"24","4":"f_meas","5":"binary","6":"0.8116185","7":"10","8":"0.008852284","9":"Preprocessor1_Model09"},{"1":"4","2":"1084","3":"24","4":"roc_auc","5":"binary","6":"0.8350843","7":"10","8":"0.008558384","9":"Preprocessor1_Model09"},{"1":"4","2":"1084","3":"24","4":"sens","5":"binary","6":"0.7889103","7":"10","8":"0.017322999","9":"Preprocessor1_Model09"},{"1":"1","2":"798","3":"6","4":"bal_accuracy","5":"binary","6":"0.7362972","7":"10","8":"0.008891585","9":"Preprocessor1_Model10"},{"1":"1","2":"798","3":"6","4":"f_meas","5":"binary","6":"0.8169654","7":"10","8":"0.007153570","9":"Preprocessor1_Model10"},{"1":"1","2":"798","3":"6","4":"roc_auc","5":"binary","6":"0.8334211","7":"10","8":"0.004857967","9":"Preprocessor1_Model10"},{"1":"1","2":"798","3":"6","4":"sens","5":"binary","6":"0.7989103","7":"10","8":"0.014612026","9":"Preprocessor1_Model10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
rf_best <- 
  rf_res %>% 
  select_best(metric = "f_meas")

rf_best
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["mtry"],"name":[1],"type":["int"],"align":["right"]},{"label":["trees"],"name":[2],"type":["int"],"align":["right"]},{"label":["min_n"],"name":[3],"type":["int"],"align":["right"]},{"label":[".config"],"name":[4],"type":["chr"],"align":["left"]}],"data":[{"1":"1","2":"798","3":"6","4":"Preprocessor1_Model10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
rf_res %>% 
  show_best(metric = "f_meas")
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["mtry"],"name":[1],"type":["int"],"align":["right"]},{"label":["trees"],"name":[2],"type":["int"],"align":["right"]},{"label":["min_n"],"name":[3],"type":["int"],"align":["right"]},{"label":[".metric"],"name":[4],"type":["chr"],"align":["left"]},{"label":[".estimator"],"name":[5],"type":["chr"],"align":["left"]},{"label":["mean"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["n"],"name":[7],"type":["int"],"align":["right"]},{"label":["std_err"],"name":[8],"type":["dbl"],"align":["right"]},{"label":[".config"],"name":[9],"type":["chr"],"align":["left"]}],"data":[{"1":"1","2":"798","3":"6","4":"f_meas","5":"binary","6":"0.8169654","7":"10","8":"0.007153570","9":"Preprocessor1_Model10"},{"1":"3","2":"1210","3":"18","4":"f_meas","5":"binary","6":"0.8136936","7":"10","8":"0.008964393","9":"Preprocessor1_Model08"},{"1":"4","2":"1084","3":"24","4":"f_meas","5":"binary","6":"0.8116185","7":"10","8":"0.008852284","9":"Preprocessor1_Model09"},{"1":"3","2":"1742","3":"16","4":"f_meas","5":"binary","6":"0.8111909","7":"10","8":"0.007977542","9":"Preprocessor1_Model07"},{"1":"2","2":"1531","3":"35","4":"f_meas","5":"binary","6":"0.8094019","7":"10","8":"0.010608097","9":"Preprocessor1_Model02"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
autoplot(rf_res)
```

![](VIP_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

```r
final_rf <- finalize_model(
  rf_mod,
  rf_best
)

final_rf
```

```
## Random Forest Model Specification (classification)
## 
## Main Arguments:
##   mtry = 1
##   trees = 798
##   min_n = 6
## 
## Engine-Specific Arguments:
##   num.threads = cores
## 
## Computational engine: ranger
```

## Global Measures

### Model-Based Variable Importance

Many supervised learning algorithms can naturally emit some measure of importance for the features used in the model, and these approaches are embedded in many different packages. For instance, like gradient boosted decision trees and random forests have a native way of quantifying the importance or relative influence of each feature. These measures compute variable importance specific to the particular model from the native functions of a wide range of packages.


```r
final_rf %>%
  set_engine("ranger", importance = "impurity") %>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>%
  vi()%>%mutate(rank = dense_rank(desc(Importance)),
                mod="rf")%>% select(Variable,rank,mod)
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Variable"],"name":[1],"type":["chr"],"align":["left"]},{"label":["rank"],"name":[2],"type":["int"],"align":["right"]},{"label":["mod"],"name":[3],"type":["chr"],"align":["left"]}],"data":[{"1":"glucose","2":"1","3":"rf"},{"1":"age","2":"2","3":"rf"},{"1":"insulin","2":"3","3":"rf"},{"1":"mass","2":"4","3":"rf"},{"1":"pedigree","2":"5","3":"rf"},{"1":"pregnant","2":"6","3":"rf"},{"1":"triceps","2":"7","3":"rf"},{"1":"pressure","2":"8","3":"rf"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Permutation Method

The permutation method exists in various forms the approach used in the VIP package is quite simple. The idea is as permuting the values of a feature affects the relationship between that feature and the target variable if we randomly permute the values of an important feature in the training data, the training performance would decrease. This approach uses the difference between the performance of the baseline full model and the performance obtained after permuting the values of a particular feature.


```r
pfun <- function(object, newdata) predict(object, data = newdata)$predictions
vips=final_rf %>%
 set_engine("ranger", importance = "impurity") %>%
 fit(diabetes ~ .,
     data = train_preped
 ) %>%
 vi(method = "permute", nsim = 100, target = "diabetes",
    pred_wrapper = pfun, metric = "accuracy",
    all_permutations = TRUE, train = train_preped)
```

### FIRM

FIRM-based variable importance - Compute variable importance by quantifying the variability in marginal effect plots like Partial Dependence Plots and Individual Conditional Expectations via the *pdp package*.


```r
final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>%vip( method = "firm",feature_names = setdiff(names(train_preped), "outcome"), train = train_preped)
```

![](VIP_files/figure-html/unnamed-chunk-7-1.png)<!-- -->



#### PDP Method

Partial Dependence Plots provide model-agnostic interpretations and can be constructed in the same way for any supervised learning algorithm. This approach is based on quantifying the "flatness" of the PDPs of each feature by visualizing the effect of cardinality of the subsets of the feature space on the estimated.


```r
pdp_DBT<- model_profile(
  rf_explainer,
  variables = "mass",
  N = NULL
)
# pdp_DBT
# 
# 
# as_tibble(pdp_DBT$agr_profiles) %>%
#   mutate(`_label_` = str_remove(`_label_`, "workflow_")) %>%
#   ggplot(aes(`_x_`, `_yhat_`, color = `_label_`)) +
#   geom_line(size = 1.2, alpha = 0.8)

pp=final_rf %>%
  set_engine("ranger", importance = "permutation") %>%
  fit(diabetes ~ .,
      data = train_preped
  )

features <- setdiff(names(train_preped), "diabetes")
pdps <- lapply(features, FUN = function(feature) {
  pd <- partial(pp$fit, pred.var = feature,train=train_preped)
  autoplot(pd) + 
    theme_light()
})
grid.arrange(grobs = pdps, ncol = 5)
```

![](VIP_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

#### ICE curve Method

The Individual Conditional Expectations curve method is similar to the PDP method, however, in this approach the "flatness" of each ICE curve and then aggregate the results (e.g., by averaging). Therefore, in absence of interaction effects, using method = "ice" will produce results similar to using method = "pdp". Some would argue that it is probably more reasonable to always use method = "ice".


```r
features <- setdiff(names(train_preped), "diabetes")
ices <- lapply(features, FUN = function(feature) {
  ice <- partial(pp$fit, pred.var = feature,train=train_preped, ice = TRUE)
  autoplot(ice) + 
    theme_light()
})

grid.arrange(grobs = ices, ncol = 5)
```



![](VIP_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

## Local Measures

Global interpretations are based on the relationship between the features and the outcome in the entire model. However, global measures can be highly approximate in some cases. Local measures, in contrast, highlight model predictions for a single observation or a group of similar observations. Local interpretability measures like SHAP-based variable importance and LIME, which stands for Local Interpretable Model-agnostic Explanations, has the potential to facilitate the interpretation of black-box models.

### SHAP

Similar to LIME method, Lundberg et al. in their paper "A unified approach to interpreting model predictions" proposed the SHAP (SHapley Additive exPlanations). The SHAP values can provide global interpretability about how much each predictor contributes, either positively or negatively, to the target variable, as well as local interpretability measures where each observation gets its own set of SHAP values which increases its transparency of the model. In contrast to LIME method that creates a substitute model around the local unit to understand. Shapely values 'decompose' the final prediction into the contribution of each attribute in an additive way.


```r
x_train <- as.matrix(train_preped[-1:-6, 1:8])
y_train <- as.matrix(train_preped[-1:-6, 9])
x_test <- as.matrix(train_preped[1:6, 1:8])
explainer <- shapr(x_train, pp$fit)
```

```
## The specified model provides feature classes that are NA. The classes of data are taken as the truth.
```

```r
p <- mean(as.numeric(as.factor(y_train))-1)
explanation <- explain(
  x_test,
  approach = "empirical",
  explainer = explainer,
  prediction_zero = p
)

plot(explanation, plot_phi0 = FALSE, index_x_test = c(1, 6))
```

![](VIP_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

### LIME

Local Interpretable Model-agnostic Explanations (LIME) is a model agnostic method that can be applied to any supervised regression or classification model, based on the the assumption that every complex model is linear on a local scale. In other words, it is possible to fit a simple model around a single observation that will mimic how the global model behaves at that locality. To attain this lime permute features for a given observation and computes similarity distance measure between original observation and permuted observations and then applies selected machine learning model to predict outcomes of permuted data.


```r
explainer <- lime(as.data.frame(x_train), pp$fit, bin_continuous = TRUE, quantile_bins = FALSE)
explanation <- lime::explain(as.data.frame(x_test), explainer, n_labels = 1, n_features = 4)
plot_features(explanation, ncol = 3)
```

![](VIP_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

## References

+ [Vip: Variable Importance Plots](https://koalaverse.github.io/vip/)

+ [Variable importance plots: an introduction to vip](https://koalaverse.github.io/vip/articles/vip.html)

+ [Visualizing ML Models with LIME](https://uc-r.github.io/lime)

+ [Explain Any Models with the SHAP Values — Use the KernelExplainer](https://towardsdatascience.com/explain-any-models-with-the-shap-values-use-the-kernelexplainer-79de9464897a)

+ [Understanding lime](https://cran.r-project.org/web/packages/lime/vignettes/Understanding_lime.html)

+ [Understanding shapr](https://cran.r-project.org/web/packages/shapr/vignettes/understanding_shapr.html)

+ [Interpretable ML Book](https://github.com/christophM/interpretable-ml-book)
