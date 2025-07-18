# Uncertainty and Bias in Healthcare Machine Learning

## Introduction

Machine learning (ML) models in healthcare are increasingly used to support diagnosis, treatment planning, and risk stratification. However, as we mntioned in an earlier [post](https://kamran-afzali.github.io/posts/2023-12-22/Uncertainty_bias.html) the reliability and fairness of ML systems are compromised if uncertainty and bias are not explicitly addressed. This post provides a practical overview of how these issues arise and how they can be mitigated using different methods for uncertainty quantification and fairness metrics for bias evaluation.


## Uncertainty

Uncertainty in healthcare ML models emerges from multiple sources and can significantly impact clinical decision-making. **Aleatoric uncertainty** refers to the intrinsic variability in the data-generating process, such as biological variation in patient outcomes or imprecision in diagnostic measurements (e.g., variability in blood glucose levels due to diurnal effects). **Epistemic uncertainty**, by contrast, arises from limited knowledge—often due to insufficient or unrepresentative data, such as when a model trained on adults is applied to pediatric patients. Finally, **predictive uncertainty** reflects the model’s confidence in its outputs and encapsulates both aleatoric and epistemic components. For instance, a model predicting 10-year diabetes risk give predictions with high uncertainty for patients with borderline BMI and glucose levels or for patients from populations underrepresented in the training data (e.g. Indigenous communities). In such cases, misleading predictions can result in delayed diagnoses or unnecessary referrals.

### Bayesian Methods for Quantifying Uncertainty

[Bayesian models](https://kamran-afzali.github.io/Bookdown_Stan/) provide a statistical way to formalize uncertainty by estimating posterior distributions over model parameters and predictions. For binary classification tasks, **Bayesian logistic regression** is particularly useful because it yields not only point predictions but also **credible intervals**, allowing for an explicit expression of predictive uncertainty.

### Mathematical Formalism: Bayesian Logistic Regression

Consider a binary classification task such as predicting whether a patient has diabetes:

$$
p(y = 1 \mid \mathbf{x}, \mathbf{w}) = \sigma(\mathbf{w}^\top \mathbf{x}) = \frac{1}{1 + e^{-\mathbf{w}^\top \mathbf{x}}}
$$

Here, $\mathbf{x} \in \mathbb{R}^d$ is the vector of input features, $\mathbf{w} \in \mathbb{R}^d$ is the weight vector, and $\sigma$ is the sigmoid function. In the Bayesian framework, we place a prior on the weights:

$$
p(\mathbf{w}) = \mathcal{N}(0, \sigma^2 \mathbf{I})
$$

Given data $\mathcal{D} = \{ (\mathbf{x}_i, y_i) \}_{i=1}^n$, the posterior is:

$$
p(\mathbf{w} \mid \mathcal{D}) \propto p(\mathcal{D} \mid \mathbf{w}) \cdot p(\mathbf{w})
$$

To make predictions for a new patient $\mathbf{x}^*$, we compute the **posterior predictive distribution**:

$$
p(y^* = 1 \mid \mathbf{x}^*, \mathcal{D}) = \int \sigma(\mathbf{w}^\top \mathbf{x}^*) \cdot p(\mathbf{w} \mid \mathcal{D}) \, d\mathbf{w}
$$

This integral is typically intractable and is approximated using **Markov Chain Monte Carlo (MCMC)** or **variational inference**.



### R Code: Bayesian Logistic Regression with Uncertainty

```r
# Load required libraries
library(rstanarm)
library(tidyverse)

# Simulate a realistic healthcare dataset
set.seed(123)
n <- 1000
data <- tibble(
  age = rnorm(n, 50, 10),
  bmi = rnorm(n, 27, 5),
  glucose = rnorm(n, 100, 20),
  diabetes = rbinom(n, 1, prob = plogis(0.04 * age + 0.06 * bmi + 0.03 * glucose - 8))
)

# Fit Bayesian logistic regression
model <- stan_glm(diabetes ~ age + bmi + glucose, 
                  family = binomial(link = "logit"), 
                  data = data, 
                  chains = 4, iter = 2000, warmup = 1000)

# Predict diabetes risk for a new patient
new_patient <- data.frame(age = 55, bmi = 30, glucose = 110)
pred_samples <- posterior_predict(model, newdata = new_patient, draws = 1000)
pred_prob <- mean(pred_samples)
cred_interval <- cred_interval <- sqrt(pred_prob*(1-pred_prob))

cat("Predicted probability of diabetes:", pred_prob, "\n")
cat("95% credible interval:", cred_interval, "\n")
```

### Uncertainty in Random Forests

Random forests allow for a form of **non-Bayesian predictive uncertainty quantification** using the **variation across trees** in the ensemble. Because each tree is trained on a bootstrap sample, the **distribution of predictions across the ensemble** provides a measure of uncertainty.

Let the prediction of the $t$-th tree for input $\mathbf{x}^*$ be $\hat{y}_t(\mathbf{x}^*)$, and let there be $T$ trees. Then:

$$
\hat{y}_{RF}(\mathbf{x}^*) = \frac{1}{T} \sum_{t=1}^T \hat{y}_t(\mathbf{x}^*)
$$

The **standard deviation** across tree predictions approximates uncertainty:

$$
\text{Uncertainty}(\mathbf{x}^*) = \sqrt{\frac{1}{T} \sum_{t=1}^T \left( \hat{y}_t(\mathbf{x}^*) - \hat{y}_{RF}(\mathbf{x}^*) \right)^2}
$$

This captures how “certain” the forest is about a prediction—wider disagreement among trees signals higher uncertainty.


### R Code: Random Forest with Uncertainty Estimation

```r
# Load libraries
library(randomForest)
library(tidyverse)

# Simulate healthcare dataset
set.seed(123)
n <- 1000
data <- tibble(
  age = rnorm(n, 50, 10),
  bmi = rnorm(n, 27, 5),
  glucose = rnorm(n, 100, 20),
  diabetes = rbinom(n, 1, prob = plogis(0.04 * age + 0.06 * bmi + 0.03 * glucose - 8))
)

# Fit random forest model
rf_model <- randomForest(as.factor(diabetes) ~ age + bmi + glucose, data = data, ntree = 500, keep.forest = TRUE)

# Function to get prediction distribution
predict_proba_rf <- function(model, newdata) {
  votes <- predict(model, newdata, type = "prob", predict.all = TRUE)
  probs <- as.numeric(as.character(votes$individual)) # probabilities for class "1"
  list(mean_prob = mean(probs), sd_prob = sd(probs))
}

# Predict for a new patient
new_patient <- data.frame(age = 55, bmi = 30, glucose = 110)
pred_info <- predict_proba_rf(rf_model, new_patient)

cat("Predicted diabetes risk:", pred_info$mean_prob, "\n")
cat("Uncertainty (SD across trees):", pred_info$sd_prob, "\n")
```

Although this approach to uncertainty is not Bayesian but still informative, especially when used to flag low-confidence predictions for further review.


## Bias 

Bias in ML systems can exacerbate health disparities if not properly addressed. As we mentioned in the first  [post](https://kamran-afzali.github.io/posts/2023-12-22/Uncertainty_bias.html) three common forms of bias are:

* **Selection bias**: Training data omits or underrepresents certain groups (e.g., rural patients, Indigenous communities).
* **Measurement bias**: Systematic errors in variable definitions across groups (e.g., different blood pressure thresholds).
* **Representation bias**: The dataset fails to capture the diversity of clinical presentations (e.g., atypical symptoms of heart disease in women).

For instance a nuanced example can be the gestational diabetes prediction: a model trained primarily on data from European ancestry patients may not generalize to populations with higher baseline risk (e.g., South Asian or Indigenous women), leading to underdiagnosis and poor maternal-fetal outcomes.

### Mathematical Formalism: Fairness Metrics

Let $\hat{y} \in \{0, 1\}$ denote the model’s prediction and $A$ be a sensitive attribute (e.g., gender, ethnicity). Two widely used fairness metrics are:

#### **Demographic Parity**:

$$
P(\hat{y} = 1 \mid A = a_1) = P(\hat{y} = 1 \mid A = a_2)
$$

This requires equal rates of positive predictions across groups, regardless of ground truth.

#### **Equal Opportunity**:

$$
P(\hat{y} = 1 \mid y = 1, A = a_1) = P(\hat{y} = 1 \mid y = 1, A = a_2)
$$

This ensures equal **true positive rates** for patients who actually have the condition.



### R Code: Evaluating Bias in Model Predictions

```r
# Add gender to dataset
set.seed(321)
data$gender <- sample(c("male", "female"), size = n, replace = TRUE)

# Predict probabilities
data$pred_prob <- predict(model, type = "response")

# Demographic parity: compare prediction rates by gender
dem_parity <- data %>%
  mutate(pred = pred_prob > 0.5) %>%
  group_by(gender) %>%
  summarise(rate = mean(pred)) %>%
  summarise(diff = abs(diff(rate)))

# Equal opportunity: restrict to actual positive cases
equal_opp <- data %>%
  filter(diabetes == 1) %>%
  mutate(pred = pred_prob > 0.5) %>%
  group_by(gender) %>%
  summarise(tpr = mean(pred)) %>%
  summarise(diff = abs(diff(tpr)))

cat("Demographic parity difference:", dem_parity$diff, "\n")
cat("Equal opportunity difference:", equal_opp$diff, "\n")
```



### R Code: Fairness Evaluation for Random Forest

```r
# Add gender to data
set.seed(321)
data$gender <- sample(c("male", "female"), size = n, replace = TRUE)

# Predict probabilities
data$pred_prob <- predict(rf_model, type = "prob")[,2]

# Binarize predictions using threshold
data$pred <- data$pred_prob > 0.5

# Demographic Parity
dem_parity <- data %>%
  group_by(gender) %>%
  summarise(rate = mean(pred)) %>%
  summarise(diff = abs(diff(rate)))

# Equal Opportunity
equal_opp <- data %>%
  filter(diabetes == 1) %>%
  group_by(gender) %>%
  summarise(tpr = mean(pred)) %>%
  summarise(diff = abs(diff(tpr)))

cat("Demographic parity difference:", dem_parity$diff, "\n")
cat("Equal opportunity difference:", equal_opp$diff, "\n")
```

These fairness metrics highlight whether the model disproportionately favors one group in terms of positive predictions or true positive rates. If disparities are large, they may indicate structural inequities in the training data or modeling assumptions that can be adressed through stratified modeling, reweighting, or adversarial debiasing.

## Implications for Responsible Healthcare AI

Integration of machine learning systems into clinical settings requires addressing uncertainty and bias as ethical priorities. When operating without necessary checks and balances these systems risk perpetuating harm, particularly among underrepresented groups. Biased predictions not only worsen inequalities but also undermine confidence in healthcare institutions. Regular audits for fairness across diverse demographic groups are necessary to detect and reduce the bias, potentially aiming towards equitable performance of these systems. Transparency in design is also critical with interpretable models allowing clinicians and patients to better undersatnd outputs and improve accountability. Furthermore, expanding data collection to encompass historically underserved populations is vital to reducing gaps in representation that fuel inequitable outcomes. Finally, the development process should incorporate multidisciplinary perspectives, engaging clinicians, ethicists, and patients to ensure that models align with the values and needs of those they serve. By putting these practices, healthcare AI can uphold the principles of fairness, accountability, and trust, advancing both patient outcomes and societal well-being.

## References

* Gelman, A., & Hill, J. (2020). *Data Analysis Using Regression and Multilevel/Hierarchical Models*. Cambridge University Press.
* Hardt, M., Price, E., & Srebro, N. (2016). Equality of Opportunity in Supervised Learning. *NeurIPS*, 29.
* Ghahramani, Z. (2015). Probabilistic machine learning and artificial intelligence. *Nature*, 521(7553), 452–459.
* Obermeyer, Z., & Mullainathan, S. (2019). Dissecting racial bias in an algorithm used to manage the health of populations. *Science*, 366(6464), 447–453.








