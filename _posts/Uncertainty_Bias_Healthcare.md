# Uncertainty and Bias in Healthcare Machine Learning

## Introduction

Machine learning (ML) models in healthcare are increasingly used to support diagnosis, treatment planning, and risk stratification. However, the reliability and fairness of such systems are compromised if uncertainty and bias are not explicitly addressed. This essay provides a formal and practical overview of how these issues arise and how they can be mitigated using Bayesian methods for uncertainty quantification and fairness metrics for bias evaluation.



## Uncertainty in Healthcare ML

Uncertainty in healthcare ML models emerges from multiple sources and can significantly impact clinical decision-making. **Aleatoric uncertainty** refers to the intrinsic variability in the data-generating process, such as biological variation in patient outcomes or imprecision in diagnostic measurements (e.g., variability in blood glucose levels due to diurnal effects). **Epistemic uncertainty**, by contrast, arises from limited knowledge—often due to insufficient or unrepresentative data, such as when a model trained on adults is applied to pediatric patients. Finally, **predictive uncertainty** reflects the model’s confidence in its outputs and encapsulates both aleatoric and epistemic components.

For instance, a model predicting 10-year diabetes risk might yield high uncertainty for patients with borderline BMI and glucose levels or for patients from populations underrepresented in the training data (e.g., certain Indigenous communities). In such cases, misleading predictions can result in delayed diagnoses or unnecessary referrals.

### Bayesian Methods for Quantifying Uncertainty

Bayesian models provide a principled way to incorporate and express uncertainty by estimating posterior distributions over model parameters and predictions. For binary classification tasks, **Bayesian logistic regression** is particularly useful because it yields not only point predictions but also **credible intervals**, allowing for an explicit expression of predictive uncertainty.

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
cred_interval <- quantile(pred_samples, c(0.025, 0.975))

cat("Predicted probability of diabetes:", pred_prob, "\n")
cat("95% credible interval:", cred_interval, "\n")
```



## Bias in Healthcare ML

Bias in ML systems can exacerbate health disparities if not properly addressed. Three common forms of bias are:

* **Selection bias**: Training data omits or underrepresents certain groups (e.g., rural patients, Indigenous communities).
* **Measurement bias**: Systematic errors in variable definitions across groups (e.g., different blood pressure thresholds).
* **Representation bias**: The dataset fails to capture the diversity of clinical presentations (e.g., atypical symptoms of heart disease in women).

A more nuanced example involves gestational diabetes prediction: a model trained primarily on data from European ancestry patients may not generalize to populations with higher baseline risk (e.g., South Asian or Indigenous women), leading to underdiagnosis and poor maternal-fetal outcomes.



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

These fairness audits reveal whether the model disproportionately favors one group in terms of positive predictions or true positive rates. If disparities are large, they may indicate structural inequities in the training data or modeling assumptions.



## Implications for Responsible Healthcare AI

When machine learning systems are used in clinical contexts, addressing uncertainty and bias is not just a technical requirement but an **ethical imperative**. Unchecked uncertainty in underrepresented populations (e.g., rare diseases, Indigenous patients) may lead to avoidable harm. Biased predictions can reinforce historical inequities and erode trust in healthcare institutions.

### Best Practices

* **Uncertainty-Aware Models**: Use Bayesian or ensemble methods to quantify uncertainty and flag high-risk cases.
* **Bias Detection**: Regularly audit models for fairness across demographic strata.
* **Transparent Design**: Ensure interpretability to enable scrutiny by clinicians and patients.
* **Diverse Data**: Expand data collection to include historically underserved populations.
* **Multidisciplinary Review**: Include stakeholders (clinicians, ethicists, patients) in the model development lifecycle.



## Conclusion

In high-stakes domains like healthcare, the stakes of uncertainty and bias are magnified. By employing Bayesian approaches to quantify uncertainty and fairness metrics to detect bias, ML practitioners can design systems that are both scientifically sound and ethically aligned. These efforts are foundational to building **trustworthy AI** that supports equitable and effective patient care.



## References

* Gelman, A., & Hill, J. (2020). *Data Analysis Using Regression and Multilevel/Hierarchical Models*. Cambridge University Press.
* Hardt, M., Price, E., & Srebro, N. (2016). Equality of Opportunity in Supervised Learning. *NeurIPS*, 29.
* Ghahramani, Z. (2015). Probabilistic machine learning and artificial intelligence. *Nature*, 521(7553), 452–459.
* Obermeyer, Z., & Mullainathan, S. (2019). Dissecting racial bias in an algorithm used to manage the health of populations. *Science*, 366(6464), 447–453.




### Quantifying Uncertainty in Random Forests

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

---

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
  probs <- votes$individual[,,2]  # probabilities for class "1"
  list(mean_prob = rowMeans(probs), sd_prob = apply(probs, 1, sd))
}

# Predict for a new patient
new_patient <- data.frame(age = 55, bmi = 30, glucose = 110)
pred_info <- predict_proba_rf(rf_model, new_patient)

cat("Predicted diabetes risk:", pred_info$mean_prob, "\n")
cat("Uncertainty (SD across trees):", pred_info$sd_prob, "\n")
```

This approach to uncertainty is not Bayesian but still informative, especially when used to flag low-confidence predictions for further review.


## Bias in Healthcare ML

Bias in ML systems can magnify existing health inequities. Key types of bias include:

* **Selection bias**: Underrepresentation of key subgroups, such as patients from remote communities.
* **Measurement bias**: Inconsistent or skewed measurements, like using Eurocentric thresholds for metabolic syndrome.
* **Representation bias**: A dataset that fails to reflect clinical heterogeneity, e.g., atypical cardiovascular symptoms in women.

Random forests, although flexible, **learn from the biases in the data** and can perpetuate them unless fairness is explicitly evaluated and enforced.


### Fairness Metrics for Evaluating Bias

Let $\hat{y}$ be the predicted label, and $A$ the sensitive attribute (e.g., gender, ethnicity).

#### Demographic Parity:

$$
P(\hat{y} = 1 \mid A = a_1) = P(\hat{y} = 1 \mid A = a_2)
$$

#### Equal Opportunity:

$$
P(\hat{y} = 1 \mid y = 1, A = a_1) = P(\hat{y} = 1 \mid y = 1, A = a_2)
$$

These criteria ensure, respectively, equal treatment and equal benefit for subgroups.


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

These metrics quantify disparities in model behavior across demographic groups. If differences are substantial, remedial action is needed—such as stratified modeling, reweighting, or adversarial debiasing.

