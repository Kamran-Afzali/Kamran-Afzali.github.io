
# Three New Features In TidyModels 

Based on tidyverse principles, TidyModels framework provides a collection of R packages adapted for modeling and machine learning. As there are regular updates and developments in the ecosystem, summarizing recent developments in the tidymodels ecosystem can be of interest. This is the first part of a series of blog posts intented to keep you informed about any releases you may have missed and useful new functionalities. You can check out the *tidymodels* tag to find all tidymodels blog posts here, including those that focus on a the use of a single model or more major releases and developments. Here we discuss three new features in TidyModels, namely race anova for model tuning, workflowsets for model comparison, and stacking for ensemble learning.  


first we load the required packgaes

```{r, include=FALSE}
library(tidyverse)
library(tidymodels)
library(stacks)
library(vip)
library(pdp)
library(tidyposterior)
library(modeldata)
library(workflowsets)
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

tune_race_anova() computes a set of performance metrics (e.g. accuracy or RMSE) for a pre-defined set of tuning parameters that correspond to a model or recipe across one or more resamples of the data. After an initial number of resamples have been evaluated, the process eliminates tuning parameter combinations that are unlikely to be the best results using a repeated measure ANOVA model.
The performance statistics from these resamples are analyzed to determine which tuning parameters are not statistically different from the current best setting. If a parameter is statistically different, it is excluded from further resampling.

The next resample is used with the remaining parameter combinations and the statistical analysis is updated. More candidate parameters may be excluded with each new resample that is processed.

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

The goal of workflowsets is to allow users to create and easily fit a large number of models. workflowsets can create a workflow set that holds multiple workflow objects. These objects can be created by crossing all combinations of preprocessors (e.g., formula, recipe, etc) and model specifications. This set can be easier tuned or resampled using a set of simple commands.

It is often a good idea to try different types of models and preprocessing methods on a specific data set. tidymodels provides tools for this purpose: recipes for preprocessing/feature engineering and model specifications. workflowsets has functions for creating and evaluating combinations of modeling elements.

For example, the Chicago train ridership data has many numeric predictors that are highly correlated. There are a few approaches to compensating for this issue during modeling:

Use a feature filter to remove redundant predictors.

Apply principal component analysis to decorrelate the data.

Use a regularized model to make the estimation process insensitive to correlated predictors.

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

Model stacking is an ensembling technique that involves training a model to combine the outputs of many diverse statistical models. The stacks package implements a grammar for tidymodels-aligned model stacking.

At a high level, the workflow looks something like this:

+ Define candidate ensemble members using functionality from rsample, parsnip, workflows, recipes, and tune
+ Initialize a data_stack object with stacks()
+ Iteratively add candidate ensemble members to the data_stack with add_candidates()
+ Evaluate how to combine their predictions with blend_predictions()
+ Fit candidate ensemble members with non-zero stacking coefficients with fit_members()
+ Predict on new data with predict()!



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

+ [Efficient grid search via racing with ANOVA models](https://finetune.tidymodels.org/reference/tune_race_anova.html)

+ [Create a Collection of tidymodels Workflows](https://workflowsets.tidymodels.org)

+ [Getting Started With stacks](https://stacks.tidymodels.org/articles/basics.html)

