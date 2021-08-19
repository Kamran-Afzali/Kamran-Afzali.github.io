
# New Features In TidyModels 

In new the era of machine learning and data science, there is an emerging challenge to build state-of-the-art predictive models that also provide an understanding of what's really going on under the hood and in the data. Therefore, it is often of interest to know which, of the predictors in a fitted model are relatively influential on the predicted outcome. There are many methodologies to interpret machine learning results (i.e., variable importance via permutation, partial dependence plots, local interpretable model-agnostic explanations), and many machine learning R packages implement their own versions of one or more methodologies. However, some recent R packages that focus purely on ML interpretability agnostic to any specific ML algorithm are gaining popularity. As a part of a larger framework referred to as interpretable machine learning (IML), VIP is an R package for constructing variable importance plots (VIPs).

```{r, include=FALSE}
library(tidyverse)
library(tidymodels)
library(stacks)
library(vip)
library(pdp)
library(sparkline)
library(plotly)
library(readr)
library(DALEX)
library(DALEXtra)
library(lime)
library(shapr)
library(PerformanceAnalytics)
 library(quantmod)
 library(tidyverse)
 library(modeldata)
 library(forecast)
 library(finreportr)
 library(tidymodels)
 library(stacks)
 library(finetune)
 library(vip)
 library(tidyposterior)
 library(modeldata)
 library(workflowsets)
 library(timetk)
 library(dials)
```

here for our example we use the diabetes data from pdp package

```{r}
data(pima, package = "pdp")
out="diabetes"
preds=colnames(pima)[-c(9)]
df=pima%>%
  select(c(out,preds))%>% 
  drop_na()


table(df$diabetes)



```

first data is divided to train and test sets and pre-processing is done with the Recipes package

```{r}
df_split <- initial_split(df)
train_data <- training(df_split)
test_data <- testing(df_split)
cv_train <- vfold_cv(train_data, v = 5, repeats = 2, strata = out)

class_rec <- recipe(diabetes ~ ., data = train_data)%>%
  step_center(all_predictors())  %>%
  step_scale(all_predictors()) %>%
  themis::step_smote (diabetes)

train_preped <- prep(class_rec) %>%
  bake(new_data = NULL)

test_preped <-  prep(class_rec) %>%
  bake(new_data = test_data)


require(doParallel)
cores <- parallel::detectCores(logical = FALSE)
registerDoParallel(cores = cores)
```

## Hyper-parameter tuning with racing methods

```{r}


library(finetune)
doParallel::registerDoParallel()

xgboost_class <- boost_tree(learn_rate = tune(), trees = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost")


xgboost_workflow <- 
  workflow() %>% 
  add_model(xgboost_class) %>% 
  add_recipe(class_rec)

xgboost_workflow

set.seed(345)
xgboost_res_race <- tune_race_anova(
  xgboost_workflow,
  resamples = cv_train,
  grid = 15,
  metrics = metric_set(roc_auc,f_meas,sens,bal_accuracy),
  control = control_race(verbose_elim = TRUE)
)
plot_race(xgboost_res_race)



xgb_best=xgboost_res_race %>% 
  show_best("roc_auc", n = 1)

final_xgb <- finalize_model(
  xgboost_class,
  xgb_best
)

final_xgb

final_xgb %>%
  set_mode("classification") %>% 
  set_engine("xgboost")%>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>%
  vip()

mod_pred=final_xgb %>%
  set_mode("classification") %>% 
  set_engine("xgboost")%>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>% predict(test_preped)%>% 
  bind_cols(test_preped %>% select(diabetes))

mod_pred%>% yardstick::accuracy(truth = diabetes, .pred_class)%>%bind_rows(mod_pred%>% yardstick::sens(truth = diabetes, .pred_class))%>%
  bind_rows(mod_pred%>% yardstick::spec(truth = diabetes, .pred_class))%>%bind_rows(mod_pred%>% yardstick::f_meas(truth = diabetes, .pred_class))



```



## Workflowsets
```{r}
elastic_class <- logistic_reg(mixture = tune(), penalty = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("glmnet")
xgboost_class <- boost_tree(learn_rate = tune(), trees = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost")
randomForest_class <- rand_forest(trees = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")


classification_metrics <- metric_set(roc_auc)
model_control <- control_stack_grid()

classification_set <- workflow_set(
  preproc = list(regular = class_rec),
  models = list(elastic = elastic_class, xgboost = xgboost_class, randomForest = randomForest_class),
  cross = TRUE )


classification_set <- classification_set %>% 
  workflow_map("tune_sim_anneal", resamples = cv_train, metrics = classification_metrics)
autoplot(classification_set)


autoplot(classification_set, rank_metric = "roc_auc", id = "regular_elastic")
rank_results(classification_set, rank_metric = "roc_auc") %>% 
  filter(.metric == "roc_auc")
classification_set %>% 
  extract_workflow_set_result("regular_elastic") %>% 
  show_best("roc_auc", n = 1)
classification_set %>% 
  extract_workflow_set_result("regular_randomForest") %>% 
  show_best("roc_auc", n = 1)


classification_set %>% 
  extract_workflow_set_result("regular_xgboost") %>% 
  show_best("roc_auc", n = 1)

rf_best=classification_set %>% 
  extract_workflow_set_result("regular_randomForest") %>% 
  show_best("roc_auc", n = 1)

final_rf <- finalize_model(
  randomForest_class,
  rf_best
)

final_rf

final_rf %>%
  set_mode("classification") %>% 
  set_engine("ranger", importance = "impurity")%>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>%
  vip()

mod_pred=final_rf %>%
  set_mode("classification") %>% 
  set_engine("ranger")%>%
  fit(diabetes ~ .,
      data = train_preped
  ) %>% predict(test_preped)%>% 
  bind_cols(test_preped %>% select(diabetes))

mod_pred%>% yardstick::accuracy(truth = diabetes, .pred_class)%>%bind_rows(mod_pred%>% yardstick::sens(truth = diabetes, .pred_class))%>%
  bind_rows(mod_pred%>% yardstick::spec(truth = diabetes, .pred_class))%>%bind_rows(mod_pred%>% yardstick::f_meas(truth = diabetes, .pred_class))
```


## Stacks


```{r}
a=classification_set %>% 
  extract_workflow_set_result("regular_elastic") 

b=classification_set %>% 
  extract_workflow_set_result("regular_randomForest") 

c=classification_set %>% 
  extract_workflow_set_result("regular_xgboost")


model_ensemble <- 
  stacks() %>%
  add_candidates(a) %>%
  add_candidates(b) %>%
  add_candidates(c) %>%
  blend_predictions() %>%
  fit_members()




elastic_class <- logistic_reg(mixture = tune(), penalty = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("glmnet")
xgboost_class <- boost_tree(learn_rate = tune(), trees = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("xgboost")
randomForest_class <- rand_forest(trees = tune()) %>% 
  set_mode("classification") %>% 
  set_engine("ranger")



lr_workflow <- 
  workflow() %>% 
  add_model(elastic_class) %>% 
  add_recipe(class_rec)

lr_workflow

set.seed(345)
lr_res <- 
  lr_workflow %>% 
  tune_grid(grid = 100,
            control = control_stack_grid(),
            metrics = metric_set(roc_auc,f_meas,sens,bal_accuracy), 
            resamples = cv_train)



xgboost_workflow <- 
  workflow() %>% 
  add_model(xgboost_class) %>% 
  add_recipe(class_rec)

xgboost_workflow

set.seed(345)
xgboost_res <- 
  xgboost_workflow %>% 
  tune_grid(grid = 100,
            control = control_stack_grid(),
            metrics = metric_set(roc_auc,f_meas,sens,bal_accuracy), 
            resamples = cv_train)

rf_workflow <- 
  workflow() %>% 
  add_model(randomForest_class) %>% 
  add_recipe(class_rec)

rf_workflow

set.seed(345)
rf_res <- 
  rf_workflow %>% 
  tune_grid(grid = 100,
            control = control_stack_grid(),
            metrics = metric_set(roc_auc,f_meas,sens,bal_accuracy), 
            resamples = cv_train)



ensemble_model <- stacks() %>% 
  add_candidates(lr_res) %>% 
  add_candidates(xgboost_res) %>% 
  add_candidates(rf_res) %>% 
  blend_predictions()
autoplot(ensemble_model)
autoplot(ensemble_model, type = "members")
autoplot(ensemble_model, type = "weights")

ensemble_model <- stacks() %>% 
  add_candidates(lr_res) %>% 
  add_candidates(xgboost_res) %>% 
  add_candidates(rf_res) %>% 
  blend_predictions() %>%
  fit_members()


ens_mod_pred <-
  test_preped%>%
  bind_cols(predict(ensemble_model, test_preped, type = "prob"))
```

## References

+ [Twitter Sentiment Analysis and Visualization using R](https://towardsdatascience.com/twitter-sentiment-analysis-and-visualization-using-r-22e1f70f6967)

+ [Twitter Data in R Using Rtweet: Analyze and Download Twitter Data](https://www.earthdatascience.org/courses/earth-analytics/get-data-using-apis/use-twitter-api-r/)

+ [A Guide to Mining and Analysing Tweets with R](https://towardsdatascience.com/a-guide-to-mining-and-analysing-tweets-with-r-2f56818fdd16)

+ [Collecting and Analyzing Twitter Data](https://mkearney.github.io/nicar_tworkshop/#47)

