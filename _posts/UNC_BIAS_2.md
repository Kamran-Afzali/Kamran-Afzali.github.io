# Uncertainty and Bias Analysis in Healthcare Machine Learning II

This second on the subject continues our exploration of uncertainty and bias in healthcare machine learning (ML), building on the the ideas discussed previously with more complex techniques. In clinical contexts with high-stakes decisions and major consequences, quantification of uncertainty and addressing algorithmic bias, is not only a technical matter—it is an ethical imperative. This essay introduces three advanced tools: **Gaussian Process Regression (GPR)** for modeling continuous outcomes with calibrated uncertainty, **conformal prediction** for constructing reliable prediction intervals, and **adversarial debiasing** as a framework for enforcing fairness across sensitive groups. 

## Modeling Predictive Uncertainty with Gaussian Processes

In many healthcare applications (e.g. predicting blood glucose levels or estimating hospital stay durations) we are concerned not only with the accuracy of point estimates but also with the confidence we can place in them. **Gaussian Process Regression (GPR)**, discussed earlier in our Bayesian statistics posts, can directly highlight predictive uncertainty.

A Gaussian process defines a distribution over functions such that any finite set of function values follows a multivariate normal distribution. Formally, a Gaussian process is defined by a mean function ![Equation](https://latex.codecogs.com/png.latex?m%28%5Cmathbf%7Bx%7D%29) (often set to zero) and a covariance function ![Equation](https://latex.codecogs.com/png.latex?k%28%5Cmathbf%7Bx%7D%2C%20%5Cmathbf%7Bx%7D%27%29). A common choice for the kernel is the squared exponential:

![Equation](https://latex.codecogs.com/png.latex?k%28%5Cmathbf%7Bx%7D%2C%20%5Cmathbf%7Bx%7D%27%29%20%3D%20%5Csigma_f%5E2%20%5Cexp%5Cleft%28-%5Cfrac%7B%7C%7C%5Cmathbf%7Bx%7D%20-%20%5Cmathbf%7Bx%7D%27%7C%7C%5E2%7D%7B2l%5E2%7D%5Cright%29)

where ![Equation](https://latex.codecogs.com/png.latex?%5Csigma_f%5E2) is the signal variance and ![Equation](https://latex.codecogs.com/png.latex?l) is the length scale. Given training data ![Equation](https://latex.codecogs.com/png.latex?%5Cmathcal%7BD%7D%20%3D%20%5C%7B%28%5Cmathbf%7Bx%7D_i%2C%20y_i%29%5C%7D_%7Bi%3D1%7D%5En), the posterior predictive distribution for a new input ![Equation](https://latex.codecogs.com/png.latex?%5Cmathbf%7Bx%7D%5E*) is Gaussian with mean ![Equation](https://latex.codecogs.com/png.latex?%5Cmu%5E*) and variance ![Equation](https://latex.codecogs.com/png.latex?%5Csigma%5E%7B*2%7D):

![Equation](https://latex.codecogs.com/png.latex?%5Cmu%5E*%20%3D%20%5Cmathbf%7Bk%7D_*%5E%5Ctop%20%28%5Cmathbf%7BK%7D%20%2B%20%5Csigma_n%5E2%20%5Cmathbf%7BI%7D%29%5E%7B-1%7D%20%5Cmathbf%7By%7D%2C%20%5Cquad%20%5Csigma%5E%7B*2%7D%20%3D%20k%28%5Cmathbf%7Bx%7D%5E*%2C%20%5Cmathbf%7Bx%7D%5E*%29%20-%20%5Cmathbf%7Bk%7D_*%5E%5Ctop%20%28%5Cmathbf%7BK%7D%20%2B%20%5Csigma_n%5E2%20%5Cmathbf%7BI%7D%29%5E%7B-1%7D%20%5Cmathbf%7Bk%7D_*)

Here, ![Equation](https://latex.codecogs.com/png.latex?%5Cmathbf%7BK%7D) is the covariance matrix over the training inputs, ![Equation](https://latex.codecogs.com/png.latex?%5Cmathbf%7Bk%7D_*) is the vector of covariances between the test point and training inputs, and ![Equation](https://latex.codecogs.com/png.latex?%5Csigma_n%5E2) is the observation noise variance. Importantly, the predictive variance captures both **aleatoric uncertainty** (irreducible noise in data) and **epistemic uncertainty** (lack of knowledge due to limited data), offering a holistic view of model confidence.


### Implementation in R

```r
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

new_patient <- data.frame(age = 55, bmi = 30, hba1c = 6.0)

X_train <- as.matrix(data[, c("age", "bmi", "hba1c")])
y_train <- data$glucose
X_new <- as.matrix(new_patient)


# Using mgcv package with Gaussian Process smooth
library(mgcv)

# Fit GAM with GP smooth (approximation to full GP)
gam_model <- gam(glucose ~ s(age, bs="gp") + s(bmi, bs="gp") + s(hba1c, bs="gp"), 
                 data = data, method = "REML")

# Predict with standard errors
pred_gam <- predict(gam_model, newdata = new_patient, se.fit = TRUE)

cat("mgcv GAM Results:\n")
cat("Mean prediction:", round(pred_gam$fit, 2), "\n")
cat("Standard error:", round(pred_gam$se.fit, 2), "\n")
cat("95% CI: [", round(pred_gam$fit - 1.96*pred_gam$se.fit, 2), ", ", 
    round(pred_gam$fit + 1.96*pred_gam$se.fit, 2), "]\n\n")

# Using laGP package for large-scale GP
library(laGP)

# Fit local approximate GP
X_train_lagp <- as.matrix(data[, c("age", "bmi", "hba1c")])
y_train_lagp <- data$glucose

# Predict with uncertainty using laGP
pred_lagp <- aGP(X_train_lagp, y_train_lagp, X_new, verb = 0)

cat("laGP Results:\n")
cat("Mean prediction:", round(pred_lagp$mean, 2), "\n")
cat("Standard deviation:", round(sqrt(pred_lagp$var), 2), "\n")
cat("95% CI: [", round(pred_lagp$mean - 1.96*sqrt(pred_lagp$var), 2), ", ", 
    round(pred_lagp$mean + 1.96*sqrt(pred_lagp$var), 2), "]\n\n")

```

## Conformal Prediction for Model-Agnostic Intervals

Unlike Bayesian methods that rely on specifying a full probabilistic model of the data-generating process, **conformal prediction** provides a distribution-free, frequentist approach for constructing prediction intervals.It does not require the specification or correctness of any underlying model. Instead, conformal prediction leverages the concept of **exchangeability**—a weaker assumption than independence and identical distribution (i.i.d.)—to ensure valid coverage rates for its predictive sets. This makes it particularly attractive in settings where model misspecification is a concern or where probabilistic modeling is infeasible.

In the context of regression, the most common implementation is **split conformal prediction**, which involves dividing the available data into two disjoint subsets: a training set and a calibration set. A predictive model (e.g., linear regression, random forest, neural network) is first trained on the training set to produce a point prediction function ![Equation](https://latex.codecogs.com/png.latex?%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D%29). The calibration set is then used to empirically quantify the model's uncertainty by evaluating the distribution of residuals:

![Equation](https://latex.codecogs.com/png.latex?r_i%20%3D%20%7Cy_i%20-%20%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D_i%29%7C%2C%20%5Cquad%20i%20%5Cin%20%5Ctext%7Bcalibration%20set%7D.)

Given a desired miscoverage level ![Equation](https://latex.codecogs.com/png.latex?%5Calpha%20%5Cin%20%280%2C1%29), the ![Equation](https://latex.codecogs.com/png.latex?%281%20-%20%5Calpha%29) quantile of the calibration residuals is computed:

![Equation](https://latex.codecogs.com/png.latex?q_%7B1-%5Calpha%7D%20%3D%20%5Ctext%7BQuantile%7D_%7B1-%5Calpha%7D%5Cleft%28%20%5C%7Br_i%5C%7D_%7Bi%20%5Cin%20%5Ctext%7Bcal%7D%7D%20%5Cright%29.)

This quantile serves as a tolerance radius around the point prediction for a new input ![Equation](https://latex.codecogs.com/png.latex?%5Cmathbf%7Bx%7D%5E*). The resulting conformal prediction interval for the target value ![Equation](https://latex.codecogs.com/png.latex?y%5E*) is:

![Equation](https://latex.codecogs.com/png.latex?%5Cleft%5B%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D%5E*%29%20-%20q_%7B1-%5Calpha%7D%2C%5C%20%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D%5E*%29%20%2B%20q_%7B1-%5Calpha%7D%20%5Cright%5D.)

Under the assumption of exchangeability—which implies that the joint distribution of the data is invariant to permutations of the data points—this interval satisfies the marginal coverage property:

![Equation](https://latex.codecogs.com/png.latex?%5Cmathbb%7BP%7D%5Cleft%28%20y%5E*%20%5Cin%20%5Cleft%5B%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D%5E*%29%20-%20q_%7B1-%5Calpha%7D%2C%5C%20%5Chat%7Bf%7D%28%5Cmathbf%7Bx%7D%5E*%29%20%2B%20q_%7B1-%5Calpha%7D%20%5Cright%5D%20%5Cright%29%20%5Cgeq%20%281%20-%20%5Calpha%29.)

Importantly, this guarantee holds for any predictive model ![Equation](https://latex.codecogs.com/png.latex?%5Chat%7Bf%7D), regardless of whether it is probabilistic, deterministic, linear, nonlinear, or even poorly calibrated. As a result, conformal prediction serves as a robust wrapper method that transforms point predictions into valid uncertainty estimates without modifying the underlying model.


However, this robustness comes with certain trade-offs. The assumption of exchangeability, while weaker than full probabilistic assumptions, may still be violated in real-world settings involving covariate shift, temporal dependence, or structured data. Moreover, conformal prediction does not decompose uncertainty into distinct sources (e.g., epistemic vs. aleatoric), nor does it provide a full predictive distribution. It yields valid marginal coverage but not conditional coverage—meaning the intervals are calibrated on average, but not necessarily for specific subpopulations or regions of the input space.

Nonetheless, in situations where one seeks rigorous, model-agnostic prediction intervals with minimal assumptions, conformal prediction offers a principled and computationally tractable solution grounded in frequentist theory.


### Implementation in R

```r
library(tidyverse)

# Split data
# Split Conformal Prediction Implementation in R
# This demonstrates model-agnostic prediction intervals using exchangeability

library(ggplot2)
library(dplyr)
library(randomForest)

set.seed(123)

# ============================================================================
# 1. DATA GENERATION
# ============================================================================

# Generate synthetic regression data with heteroscedastic noise
n_total <- 1000
x <- runif(n_total, 0, 10)

# True function: quadratic with some complexity
true_function <- function(x) {
  2 * sin(x) + 0.5 * x^2 - 3 * cos(x/2)
}

# Heteroscedastic noise (variance increases with x)
noise_std <- 0.5 + 0.3 * x
y <- true_function(x) + rnorm(n_total, 0, noise_std)

# Create data frame
data <- data.frame(x = x, y = y)

# ============================================================================
# 2. DATA SPLITTING
# ============================================================================

# Split into train, calibration, and test sets
n_train <- floor(0.5 * n_total)
n_cal <- floor(0.3 * n_total)
n_test <- n_total - n_train - n_cal

# Random split
indices <- sample(1:n_total)
train_idx <- indices[1:n_train]
cal_idx <- indices[(n_train + 1):(n_train + n_cal)]
test_idx <- indices[(n_train + n_cal + 1):n_total]

train_data <- data[train_idx, ]
cal_data <- data[cal_idx, ]
test_data <- data[test_idx, ]

cat("Data split:\n")
cat("Training:", nrow(train_data), "observations\n")
cat("Calibration:", nrow(cal_data), "observations\n")
cat("Test:", nrow(test_data), "observations\n\n")

# ============================================================================
# 3. MODEL TRAINING (Model-Agnostic)
# ============================================================================

# We'll demonstrate with multiple models to show model-agnostic nature

# Model 1: Linear Regression
linear_model <- lm(y ~ poly(x, 3), data = train_data)

# Model 2: Random Forest
rf_model <- randomForest(y ~ x, data = train_data, ntree = 100)

# Model 3: Simple polynomial regression
poly_model <- lm(y ~ poly(x, 5), data = train_data)

# Prediction functions
predict_linear <- function(newdata) predict(linear_model, newdata)
predict_rf <- function(newdata) predict(rf_model, newdata)
predict_poly <- function(newdata) predict(poly_model, newdata)

# ============================================================================
# 4. SPLIT CONFORMAL PREDICTION FUNCTION
# ============================================================================

split_conformal_prediction <- function(predict_fn, cal_data, test_data, alpha = 0.1) {
  # Step 1: Compute residuals on calibration set
  cal_predictions <- predict_fn(cal_data)
  residuals <- abs(cal_data$y - cal_predictions)
  
  # Step 2: Compute quantile of absolute residuals
  # Use (n+1)(1-alpha)/n quantile for finite sample correction
  n_cal <- length(residuals)
  q_level <- ceiling((n_cal + 1) * (1 - alpha)) / n_cal
  q_hat <- quantile(residuals, q_level, na.rm = TRUE)
  
  # Step 3: Generate predictions on test set
  test_predictions <- predict_fn(test_data)
  
  # Step 4: Construct prediction intervals
  lower <- test_predictions - q_hat
  upper <- test_predictions + q_hat
  
  # Calculate empirical coverage
  coverage <- mean(test_data$y >= lower & test_data$y <= upper)
  avg_width <- mean(upper - lower)
  
  return(list(
    predictions = test_predictions,
    lower = lower,
    upper = upper,
    coverage = coverage,
    avg_width = avg_width,
    quantile = q_hat
  ))
}

# ============================================================================
# 5. APPLY CONFORMAL PREDICTION
# ============================================================================

alpha <- 0.1  # For 90% prediction intervals
target_coverage <- 1 - alpha

# Apply to different models
results_linear <- split_conformal_prediction(predict_linear, cal_data, test_data, alpha)
results_rf <- split_conformal_prediction(predict_rf, cal_data, test_data, alpha)
results_poly <- split_conformal_prediction(predict_poly, cal_data, test_data, alpha)

# Print results
cat("CONFORMAL PREDICTION RESULTS (", (1-alpha)*100, "% intervals)\n", sep="")
cat("=================================================\n")
cat("Target Coverage:", target_coverage, "\n\n")

cat("Linear Model:\n")
cat("  Empirical Coverage:", round(results_linear$coverage, 3), "\n")
cat("  Average Width:", round(results_linear$avg_width, 3), "\n")
cat("  Quantile (q̂):", round(results_linear$quantile, 3), "\n\n")

cat("Random Forest:\n")
cat("  Empirical Coverage:", round(results_rf$coverage, 3), "\n")
cat("  Average Width:", round(results_rf$avg_width, 3), "\n")
cat("  Quantile (q̂):", round(results_rf$quantile, 3), "\n\n")

cat("Polynomial Model:\n")
cat("  Empirical Coverage:", round(results_poly$coverage, 3), "\n")
cat("  Average Width:", round(results_poly$avg_width, 3), "\n")
cat("  Quantile (q̂):", round(results_poly$quantile, 3), "\n\n")

# ============================================================================
# 6. VISUALIZATION
# ============================================================================

# Create comprehensive visualization
plot_data <- data.frame(
  x = test_data$x,
  y_true = test_data$y,
  pred_linear = results_linear$predictions,
  lower_linear = results_linear$lower,
  upper_linear = results_linear$upper,
  pred_rf = results_rf$predictions,
  lower_rf = results_rf$lower,
  upper_rf = results_rf$upper
)

# Plot 1: Linear model conformal intervals
p1 <- ggplot(plot_data) +
  geom_ribbon(aes(x = x, ymin = lower_linear, ymax = upper_linear), 
              alpha = 0.3, fill = "blue") +
  geom_point(aes(x = x, y = y_true), alpha = 0.6, size = 1) +
  geom_line(aes(x = x, y = pred_linear), color = "blue", size = 1) +
  labs(title = paste0("Linear Model - Conformal Prediction Intervals (", 
                      round(results_linear$coverage*100, 1), "% coverage)"),
       x = "x", y = "y") +
  theme_minimal()

# Plot 2: Random Forest conformal intervals  
p2 <- ggplot(plot_data) +
  geom_ribbon(aes(x = x, ymin = lower_rf, ymax = upper_rf), 
              alpha = 0.3, fill = "red") +
  geom_point(aes(x = x, y = y_true), alpha = 0.6, size = 1) +
  geom_line(aes(x = x, y = pred_rf), color = "red", size = 1) +
  labs(title = paste0("Random Forest - Conformal Prediction Intervals (", 
                      round(results_rf$coverage*100, 1), "% coverage)"),
       x = "x", y = "y") +
  theme_minimal()

print(p1)
print(p2)

# ============================================================================
# 7. COVERAGE ANALYSIS ACROSS DIFFERENT ALPHA VALUES
# ============================================================================

alpha_values <- seq(0.05, 0.3, by = 0.05)
coverage_results <- data.frame(
  alpha = alpha_values,
  target_coverage = 1 - alpha_values,
  linear_coverage = numeric(length(alpha_values)),
  rf_coverage = numeric(length(alpha_values)),
  linear_width = numeric(length(alpha_values)),
  rf_width = numeric(length(alpha_values))
)

for(i in seq_along(alpha_values)) {
  alpha_i <- alpha_values[i]
  
  # Linear model
  res_lin <- split_conformal_prediction(predict_linear, cal_data, test_data, alpha_i)
  coverage_results$linear_coverage[i] <- res_lin$coverage
  coverage_results$linear_width[i] <- res_lin$avg_width
  
  # Random Forest
  res_rf <- split_conformal_prediction(predict_rf, cal_data, test_data, alpha_i)
  coverage_results$rf_coverage[i] <- res_rf$coverage
  coverage_results$rf_width[i] <- res_rf$avg_width
}

# Plot coverage vs target
p3 <- ggplot(coverage_results) +
  geom_line(aes(x = target_coverage, y = linear_coverage, color = "Linear"), size = 1) +
  geom_line(aes(x = target_coverage, y = rf_coverage, color = "Random Forest"), size = 1) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "gray") +
  geom_point(aes(x = target_coverage, y = linear_coverage, color = "Linear")) +
  geom_point(aes(x = target_coverage, y = rf_coverage, color = "Random Forest")) +
  labs(title = "Conformal Prediction: Target vs Empirical Coverage",
       x = "Target Coverage", y = "Empirical Coverage",
       color = "Model") +
  theme_minimal() +
  coord_cartesian(xlim = c(0.7, 0.95), ylim = c(0.7, 0.95))

print(p3)

```


## Adversarial Debiasing for Fairness

Machine learning models trained on healthcare datasets often encode and even intensify structural inequalities present in the underlying data. These biases may arise from historical disparities, data collection procedures, or the underrepresentation of certain populations. To address such issues, **adversarial debiasing** introduces a secondary model—known as an adversary—that is trained to identify sensitive attributes such as gender, race, or socioeconomic status from the primary model’s output. The core idea is to train the predictive model in a way that preserves accuracy while obfuscating signals related to sensitive variables, thereby reducing potential bias.

This framework is formalized through a minimax optimization problem:

![Equation](https://latex.codecogs.com/png.latex?%5Cmin_%7Bf%7D%20%5Cmax_%7Bg%7D%20%5Cleft%5B%20%5Cmathcal%7BL%7D_%7B%5Ctext%7Bpred%7D%7D%28f%28%5Cmathbf%7Bx%7D%29%2C%20y%29%20-%20%5Clambda%20%5Cmathcal%7BL%7D_%7B%5Ctext%7Badv%7D%7D%28g%28f%28%5Cmathbf%7Bx%7D%29%29%2C%20A%29%20%5Cright%5D)

Here, ![Equation](https://latex.codecogs.com/png.latex?f%3A%20%5Cmathcal%7BX%7D%20%5Cto%20%5Cmathcal%7BY%7D) is the main prediction function mapping input features ![Equation](https://latex.codecogs.com/png.latex?%5Cmathbf%7Bx%7D%20%5Cin%20%5Cmathcal%7BX%7D) to labels ![Equation](https://latex.codecogs.com/png.latex?y%20%5Cin%20%5Cmathcal%7BY%7D), while ![Equation](https://latex.codecogs.com/png.latex?g%3A%20%5Cmathcal%7BY%7D%20%5Cto%20%5Cmathcal%7BA%7D) is the adversarial network attempting to recover the sensitive attribute ![Equation](https://latex.codecogs.com/png.latex?A%20%5Cin%20%5Cmathcal%7BA%7D) from the predictions. The term ![Equation](https://latex.codecogs.com/png.latex?%5Cmathcal%7BL%7D_%7B%5Ctext%7Bpred%7D%7D) denotes the primary prediction loss (e.g., cross-entropy), and ![Equation](https://latex.codecogs.com/png.latex?%5Cmathcal%7BL%7D_%7B%5Ctext%7Badv%7D%7D) measures the adversary's success (e.g., also cross-entropy). The hyperparameter ![Equation](https://latex.codecogs.com/png.latex?%5Clambda%20%3E%200) regulates the trade-off between predictive accuracy and fairness enforcement.


Intuitively, the predictor is penalized when the adversary is able to extract sensitive information from its outputs. By minimizing this objective, the model learns representations that are both useful for prediction and invariant (or at least less informative) with respect to the sensitive attribute. This strategy encourages demographic parity or equalized odds, depending on the specific design and integration of the adversarial component.

In practice, this minimax training is implemented via alternating updates to the predictor $f$ and the adversary $g$ using deep learning libraries such as TensorFlow or PyTorch. However, adversarial training is not natively supported in R, and approximations must be used instead.

One such approximation involves reweighting training samples to ensure balanced influence across demographic subgroups. For example, if one gender is underrepresented among positive outcomes, instance weights can be adjusted to equalize expected contributions to the loss function. While this approach may improve parity in metrics such as predicted positive rates or false discovery rates, it lacks the expressive power of adversarial methods to shape latent representations.

Moreover, rigorous fairness assessments require attention to intersectionality—how multiple sensitive attributes jointly affect outcomes—as well as causal reasoning to distinguish between appropriate and inappropriate uses of sensitive information. Without such considerations, apparent improvements in fairness may mask deeper inequities encoded in the model’s behavior.


### Conceptual Implementation in R

```r
# Adversarial Debiasing in R
# Simple example with synthetic data, no Torch or Keras

# Set seed for reproducibility
set.seed(123)

# Generate synthetic dataset
n <- 1000  # Number of samples
data <- data.frame(
  feature1 = rnorm(n),  # Continuous feature
  feature2 = rnorm(n),  # Continuous feature
  protected = sample(c(0, 1), n, replace = TRUE),  # Protected attribute
  label = rep(0, n)  # Binary outcome
)

# Simulate labels correlated with features and slightly with protected attribute
data$label <- as.integer(
  0.5 * data$feature1 + 0.3 * data$feature2 + 0.2 * data$protected + rnorm(n) > 0
)

# Initialize model parameters
w_pred <- c(0, 0, 0, 0)  # [w1, w2, w_protected, bias]
w_adv <- c(0, 0)  # [w_output, bias]

# Sigmoid function
sigmoid <- function(x) 1 / (1 + exp(-x))

# Predictor forward pass
predictor_logits <- function(X, w) {
  X %*% w[1:3] + w[4]  # Linear combination + bias
}

predictor_probs <- function(X, w) {
  sigmoid(predictor_logits(X, w))
}

# Adversary forward pass
adversary_logits <- function(pred_logits, w) {
  pred_logits * w[1] + w[2]  # Use logits, not probabilities
}

adversary_probs <- function(pred_logits, w) {
  sigmoid(adversary_logits(pred_logits, w))
}

# Loss functions
pred_loss <- function(y_true, y_pred) {
  -mean(y_true * log(pmax(y_pred, 1e-10)) + (1 - y_true) * log(pmax(1 - y_pred, 1e-10)))
}

adv_loss <- function(s_true, s_pred) {
  -mean(s_true * log(pmax(s_pred, 1e-10)) + (1 - s_true) * log(pmax(1 - s_pred, 1e-10)))
}

# Training parameters
alpha <- 0.1  # Learning rate for predictor
beta <- 0.1   # Learning rate for adversary
lambda <- 1.0  # Weight for adversarial loss
n_epochs <- 500

# Prepare data
X <- as.matrix(data[, c("feature1", "feature2", "protected")])
y <- data$label
s <- data$protected

# Training loop
for (epoch in 1:n_epochs) {
  # Forward pass: Predictor
  pred_logits <- predictor_logits(X, w_pred)
  y_pred_probs <- predictor_probs(X, w_pred)
  
  # Forward pass: Adversary
  s_pred_probs <- adversary_probs(pred_logits, w_adv)
  
  # Compute losses
  loss_pred <- pred_loss(y, y_pred_probs)
  loss_adv <- adv_loss(s, s_pred_probs)
  
  # Compute gradients for predictor (standard classification)
  grad_pred_wrt_logits <- y_pred_probs - y
  grad_w_pred_standard <- t(X) %*% grad_pred_wrt_logits / n
  grad_b_pred_standard <- mean(grad_pred_wrt_logits)
  
  # Compute gradients for adversary
  grad_adv_wrt_logits <- s_pred_probs - s
  grad_w_adv <- mean(grad_adv_wrt_logits * pred_logits)
  grad_b_adv <- mean(grad_adv_wrt_logits)
  
  # Compute adversarial gradients for predictor (gradient reversal)
  # This is the key part: gradients flow back from adversary to predictor
  adv_influence <- grad_adv_wrt_logits * w_adv[1] * y_pred_probs * (1 - y_pred_probs)
  grad_w_pred_adv <- t(X) %*% adv_influence / n
  grad_b_pred_adv <- mean(adv_influence)
  
  # Update predictor weights (minimize prediction loss, maximize adversarial loss)
  w_pred[1:3] <- w_pred[1:3] - alpha * (grad_w_pred_standard - lambda * grad_w_pred_adv)
  w_pred[4] <- w_pred[4] - alpha * (grad_b_pred_standard - lambda * grad_b_pred_adv)
  
  # Update adversary weights (maximize ability to predict protected attribute)
  w_adv[1] <- w_adv[1] + beta * grad_w_adv  # Note: + for maximization
  w_adv[2] <- w_adv[2] + beta * grad_b_adv  # Note: + for maximization
  
  # Print progress
  if (epoch %% 100 == 0) {
    cat(sprintf("Epoch %d: Predictor Loss = %.4f, Adversary Loss = %.4f\n", 
                epoch, loss_pred, loss_adv))
  }
}

# Evaluate results
y_pred_final <- predictor_probs(X, w_pred)
s_pred_final <- adversary_probs(predictor_logits(X, w_pred), w_adv)

cat("\n=== FINAL RESULTS ===\n")
cat("Correlation between predictions and protected attribute:", 
    cor(y_pred_final, s), "\n")

# Evaluate accuracy
accuracy <- mean((y_pred_final > 0.5) == y)
cat("Predictor accuracy:", accuracy, "\n")

# Check demographic parity
pred_by_group <- aggregate(y_pred_final ~ s, data = data.frame(y_pred_final, s), mean)
cat("\nDemographic Parity (mean predictions by group):\n")
print(pred_by_group)

# Adversary accuracy (should be around 0.5 for good debiasing)
adv_accuracy <- mean((s_pred_final > 0.5) == s)
cat("Adversary accuracy (lower is better):", adv_accuracy, "\n")```


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
