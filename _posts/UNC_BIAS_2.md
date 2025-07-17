# Uncertainty and Bias Analysis in Healthcare Machine Learning II

This second on the subject continues our exploration of uncertainty and bias in healthcare machine learning (ML), building on the the ideas discussed previously with more complex techniques. In clinical contexts with high-stakes decisions and major consequences, quantification of uncertainty and addressing algorithmic bias, is not only a technical matter—it is an ethical imperative. This essay introduces three advanced tools: **Gaussian Process Regression (GPR)** for modeling continuous outcomes with calibrated uncertainty, **conformal prediction** for constructing reliable prediction intervals, and **adversarial debiasing** as a framework for enforcing fairness across sensitive groups. 

## Modeling Predictive Uncertainty with Gaussian Processes

In many healthcare applications (e.g. predicting blood glucose levels or estimating hospital stay durations) we are concerned not only with the accuracy of point estimates but also with the confidence we can place in them. **Gaussian Process Regression (GPR)**, discussed earlier in our Bayesian statistics posts, can directly highlight predictive uncertainty.

A Gaussian process defines a distribution over functions such that any finite set of function values follows a multivariate normal distribution. Formally, a Gaussian process is defined by a mean function ![Equation](https://latex.codecogs.com/png.latex?m%28%5Cmathbf%7Bx%7D%29) (often set to zero) and a covariance function $k(\mathbf{x}, \mathbf{x}')$. A common choice for the kernel is the squared exponential:

$k(\mathbf{x}, \mathbf{x}') = \sigma_f^2 \exp\left(-\frac{\|\mathbf{x} - \mathbf{x}'\|^2}{2l^2}\right)$

where $\sigma_f^2$ is the signal variance and $l$ is the length scale. Given training data $\mathcal{D} = \{(\mathbf{x}_i, y_i)\}_{i=1}^n$ , the posterior predictive distribution for a new input $\mathbf{x}^*$ is Gaussian with mean $\mu^*$ and variance $\sigma^{*2}$:


$$
\mu^* = \mathbf{k}_*^\top (\mathbf{K} + \sigma_n^2 \mathbf{I})^{-1} \mathbf{y}, \quad
\sigma^{*2} = k(\mathbf{x}^*, \mathbf{x}^*) - \mathbf{k}_*^\top (\mathbf{K} + \sigma_n^2 \mathbf{I})^{-1} \mathbf{k}_*
$$


Here, $\mathbf{K}$ is the covariance matrix over the training inputs, $\mathbf{k}_*$ is the vector of covariances between the test point and training inputs, and $\sigma_n^2$ is the observation noise variance. Importantly, the predictive variance captures both **aleatoric uncertainty** (irreducible noise in data) and **epistemic uncertainty** (lack of knowledge due to limited data), offering a holistic view of model confidence.


### Implementation in R

```r
library(kernlab)
library(tidyverse)

# Simulate healthcare dataset
set.seed(123)
n <- 1000
data <- tibble(
  age = rnorm(n, 50, 10),
  bmi = rnorm(n, 27, 5),
  hba1c = rnorm(n, 5.5, 0.5),
  glucose = 80 + 2 * age + 3 * bmi + 10 * hba1c + rnorm(n, 0, 5)
)

# Fit GPR model
gp_model <- gausspr(glucose ~ age + bmi + hba1c, data = data, kernel = "rbfdot", var = 0.1)

# Predict for a new patient
new_patient <- data.frame(age = 55, bmi = 30, hba1c = 6.0)
pred <- predict(gp_model, newdata = new_patient, type = "response")
pred_var <- predict(gp_model, newdata = new_patient, type = "sdeviation")^2

cat("Predicted glucose:", pred, "\n")
cat("Predictive variance:", pred_var, "\n")
cat("95% CI:", pred + c(-1.96, 1.96) * sqrt(pred_var), "\n")
```

## Conformal Prediction for Model-Agnostic Intervals

Unlike Bayesian methods that rely on specifying a full probabilistic model of the data-generating process, **conformal prediction** provides a distribution-free, frequentist approach for constructing prediction intervals with rigorous finite-sample guarantees. Crucially, it does not require the specification or correctness of any underlying model. Instead, conformal prediction leverages the concept of **exchangeability**—a weaker assumption than independence and identical distribution (i.i.d.)—to ensure valid coverage rates for its predictive sets. This makes it particularly attractive in settings where model misspecification is a concern or where probabilistic modeling is infeasible.

In the context of regression, the most common implementation is **split conformal prediction**, which involves dividing the available data into two disjoint subsets: a training set and a calibration set. A predictive model (e.g., linear regression, random forest, neural network) is first trained on the training set to produce a point prediction function \$\hat{f}(\mathbf{x})\$. The calibration set is then used to empirically quantify the model's uncertainty by evaluating the distribution of residuals:

$$
r_i = |y_i - \hat{f}(\mathbf{x}_i)|, \quad i \in \text{calibration set}.
$$

Given a desired miscoverage level \$\alpha \in (0,1)\$, the \$(1 - \alpha)\$ quantile of the calibration residuals is computed:

$$
q_{1-\alpha} = \text{Quantile}_{1-\alpha}\left( \{r_i\}_{i \in \text{cal}} \right).
$$

This quantile serves as a tolerance radius around the point prediction for a new input \$\mathbf{x}^*\$. The resulting conformal prediction interval for the target value \$y^*\$ is:

$$
\left[\hat{f}(\mathbf{x}^*) - q_{1-\alpha},\ \hat{f}(\mathbf{x}^*) + q_{1-\alpha} \right].
$$

Under the assumption of exchangeability—which implies that the joint distribution of the data is invariant to permutations of the data points—this interval satisfies the marginal coverage property:

$$
\mathbb{P}\left( y^* \in \left[\hat{f}(\mathbf{x}^*) - q_{1-\alpha},\ \hat{f}(\mathbf{x}^*) + q_{1-\alpha} \right] \right) \geq 1 - \alpha.
$$

Importantly, this guarantee holds for any predictive model \$\hat{f}\$, regardless of whether it is probabilistic, deterministic, linear, nonlinear, or even poorly calibrated. As a result, conformal prediction serves as a robust wrapper method that transforms point predictions into valid uncertainty estimates without modifying the underlying model.

However, this robustness comes with certain trade-offs. The assumption of exchangeability, while weaker than full probabilistic assumptions, may still be violated in real-world settings involving covariate shift, temporal dependence, or structured data. Moreover, conformal prediction does not decompose uncertainty into distinct sources (e.g., epistemic vs. aleatoric), nor does it provide a full predictive distribution. It yields valid marginal coverage but not conditional coverage—meaning the intervals are calibrated on average, but not necessarily for specific subpopulations or regions of the input space.

Nonetheless, in situations where one seeks rigorous, model-agnostic prediction intervals with minimal assumptions, conformal prediction offers a principled and computationally tractable solution grounded in frequentist theory.


### Implementation in R

```r
library(tidyverse)

# Split data
set.seed(123)
train_idx <- sample(1:n, 0.8 * n)
train_data <- data[train_idx, ]
calib_data <- data[-train_idx, ]

# Fit a model
lm_model <- lm(glucose ~ age + bmi + hba1c, data = train_data)

# Calibration residuals
calib_pred <- predict(lm_model, newdata = calib_data)
calib_residuals <- abs(calib_data$glucose - calib_pred)

# Construct interval
alpha <- 0.05
q <- quantile(calib_residuals, 1 - alpha)
pred <- predict(lm_model, newdata = new_patient)
interval <- c(pred - q, pred + q)

cat("Prediction:", pred, "\n")
cat("95% conformal interval:", interval, "\n")
```


## Adversarial Debiasing for Fairness

Machine learning models trained on healthcare datasets often encode and even intensify structural inequalities present in the underlying data. These biases may arise from historical disparities, data collection procedures, or the underrepresentation of certain populations. To address such issues, **adversarial debiasing** introduces a secondary model—known as an adversary—that is trained to identify sensitive attributes such as gender, race, or socioeconomic status from the primary model’s output. The core idea is to train the predictive model in a way that preserves accuracy while obfuscating signals related to sensitive variables, thereby reducing potential bias.

This framework is formalized through a minimax optimization problem:

$$
\min_{f} \max_{g} \left[ \mathcal{L}_{\text{pred}}(f(\mathbf{x}), y) - \lambda \mathcal{L}_{\text{adv}}(g(f(\mathbf{x})), A) \right]
$$

Here, $f: \mathcal{X} \to \mathcal{Y}$ is the main prediction function mapping input features $\mathbf{x} \in \mathcal{X}$ to labels $y \in \mathcal{Y}$, while $g: \mathcal{Y} \to \mathcal{A}$ is the adversarial network attempting to recover the sensitive attribute $A \in \mathcal{A}$ from the predictions. The term $\mathcal{L}_{\text{pred}}$ denotes the primary prediction loss (e.g., cross-entropy), and $\mathcal{L}_{\text{adv}}$ measures the adversary's success (e.g., also cross-entropy). The hyperparameter $\lambda > 0$ modulates the trade-off between predictive accuracy and fairness enforcement.

Intuitively, the predictor is penalized when the adversary is able to extract sensitive information from its outputs. By minimizing this objective, the model learns representations that are both useful for prediction and invariant (or at least less informative) with respect to the sensitive attribute. This strategy encourages demographic parity or equalized odds, depending on the specific design and integration of the adversarial component.

In practice, this minimax training is implemented via alternating updates to the predictor $f$ and the adversary $g$ using deep learning libraries such as TensorFlow or PyTorch. However, adversarial training is not natively supported in R, and approximations must be used instead.

One such approximation involves reweighting training samples to ensure balanced influence across demographic subgroups. For example, if one gender is underrepresented among positive outcomes, instance weights can be adjusted to equalize expected contributions to the loss function. While this approach may improve parity in metrics such as predicted positive rates or false discovery rates, it lacks the expressive power of adversarial methods to shape latent representations.

Moreover, rigorous fairness assessments require attention to intersectionality—how multiple sensitive attributes jointly affect outcomes—as well as causal reasoning to distinguish between appropriate and inappropriate uses of sensitive information. Without such considerations, apparent improvements in fairness may mask deeper inequities encoded in the model’s behavior.


### Conceptual Implementation in R

```r
library(tidyverse)

# Simulated dataset with sensitive attribute
data <- tibble(
  age = rnorm(n, 50, 10),
  bmi = rnorm(n, 27, 5),
  glucose = rnorm(n, 100, 20),
  gender = sample(c("male", "female"), n, replace = TRUE),
  diabetes = rbinom(n, 1, plogis(0.04 * age + 0.06 * bmi + 0.03 * glucose - 8))
)

# Fit baseline model
model <- glm(diabetes ~ age + bmi + glucose, family = binomial(), data = data)
data$pred_prob <- predict(model, type = "response")

# Evaluate demographic parity
data <- data %>%
  mutate(pred_class = ifelse(pred_prob > 0.5, 1, 0))
dem_parity <- data %>%
  group_by(gender) %>%
  summarise(rate = mean(pred_class))

# Reweight samples
gender_ratio <- table(data$gender)
weights <- ifelse(data$gender == "male",
                  gender_ratio["female"] / sum(gender_ratio),
                  gender_ratio["male"] / sum(gender_ratio))
model_fair <- glm(diabetes ~ age + bmi + glucose, family = binomial(), data = data, weights = weights)
data$pred_prob_fair <- predict(model_fair, type = "response")

# Evaluate fairness again
data <- data %>%
  mutate(pred_class_fair = ifelse(pred_prob_fair > 0.5, 1, 0))
dem_parity_fair <- data %>%
  group_by(gender) %>%
  summarise(rate = mean(pred_class_fair))
```


## Discussion and future direction

As machine learning systems increasingly inform clinical decision-making, there is a growing need to ensure that their behavior reflects not only statistical efficiency but also ethical and clinical standards. Methods such as Gaussian Process Regression and conformal prediction provide formal mechanisms for quantifying and calibrating predictive uncertainty. These approaches contribute to the transparency and reliability of model outputs—properties that are critical in high-stakes medical contexts where uncertainty must be explicitly acknowledged and communicated.

Adversarial debiasing, including simplified implementations through sample reweighting or fairness-aware loss functions, illustrates a broader shift in emphasis: model development must account for both predictive accuracy and equity. This reflects an emerging consensus that fairness constraints are not optional additions but integral components of responsible algorithm design.

Ongoing research should deepen this integration by exploring scalable Bayesian inference methods, such as variational inference and Hamiltonian Monte Carlo, which allow for principled representation of uncertainty in complex, high-dimensional settings. There is also a need to refine fairness metrics that consider intersectional attributes, capturing the joint impact of race, gender, age, and other social variables on model outcomes. Empirical validation on large and diverse clinical datasets remains essential for assessing the real-world implications of these techniques.

Rather than treating uncertainty and bias as secondary concerns, future work should approach them as foundational to the development of machine learning systems in healthcare. This orientation supports the design of models that are not only technically sound but also responsive to the ethical demands of clinical practice.

## References

- Angelopoulos, A. N., & Bates, S. (2021). A gentle introduction to conformal prediction and distribution-free uncertainty quantification. arXiv. https://arxiv.org/abs/2107.07511

- Beutel, A., Chen, J., Zhao, Z., & Chi, E. H. (2017). Data decisions and theoretical implications when adversarially learning fair representations. arXiv. https://arxiv.org/abs/1707.00075

- Rasmussen, C. E., & Williams, C. K. I. (2006). Gaussian processes for machine learning. MIT Press. http://www.gaussianprocess.org/gpml/chapters/RW.pdf

- Shafer, G., & Vovk, V. (2008). A tutorial on conformal prediction. Journal of Machine Learning Research, 9(3), 371–421. http://jmlr.csail.mit.edu/papers/v9/shafer08a.html
