# Regression Discontinuity Design: Exploiting Arbitrary Cutoffs for Causal Inference

## Arbitrary Rules

Cutoffs are all around us Students with SAT scores of 1200 qualify for merit scholarships while those scoring 1199 don't. Patients with blood pressure readings above 140 mmHg receive hypertension treatment. Companies with fewer than 50 employees avoid certain regulatory requirements. These seemingly arbitrary thresholds create natural experiments—individuals just above and below the cutoff are likely similar in all respects except treatment assignment. Regression Discontinuity Design (RDD) exploits this logic. Unlike Instrumental Variables, which require finding exogenous variation that affects treatment, RDD uses the discontinuous assignment mechanism itself. The method appears deceptively simple: compare outcomes for units just above and below a threshold. Yet this simplicity masks sophisticated assumptions and estimation challenges that researchers often underestimate.

## Theoretical Foundation

### The Assignment Mechanism

RDD applies when treatment assignment follows a deterministic rule based on an observed running variable $X$:

$$
D_i = \begin{cases}
1 & \text{if } X_i \geq c \\
0 & \text{if } X_i < c
\end{cases}
$$

where $c$ represents the cutoff threshold. This sharp discontinuity contrasts with fuzzy RDD, where the assignment rule creates jumps in treatment probability rather than certainty.

The key insight: individuals near the cutoff are exchangeable. Someone scoring 1199 on the SAT likely resembles someone scoring 1201 more than they resemble someone scoring 1400. This local randomization assumption enables causal identification.

### Identification Strategy

The RDD estimand targets the treatment effect at the cutoff:

$$
\tau_{RDD} = \mathbb{E}[Y_i(1) - Y_i(0) | X_i = c]
$$

Since we observe only one potential outcome for each unit, identification requires continuity of the conditional expectation function at the cutoff. Formally:

$$
\mathbb{E}[Y_i(0) | X_i = x] \text{ and } \mathbb{E}[Y_i(1) | X_i = x] \text{ are continuous at } x = c
$$

When this holds, the treatment effect equals the discontinuous jump in the observed outcome:

$$
\tau_{RDD} = \lim_{x \to c^+} \mathbb{E}[Y_i | X_i = x] - \lim_{x \to c^-} \mathbb{E}[Y_i | X_i = x]
$$

### Assumptions and Threats

The continuity assumption appears innocuous but proves restrictive. It requires that all factors affecting the outcome—except treatment—vary smoothly through the cutoff. This fails when:

- Agents manipulate the running variable (students retaking SATs to cross merit thresholds)
- Other policies change at the same cutoff (multiple programs using identical eligibility criteria)
- The running variable directly affects outcomes independent of treatment

Testing these assumptions involves examining the density of the running variable for bunching and checking whether predetermined characteristics jump at the cutoff.

## Healthcare Application: Blood Pressure Treatment

### Clinical Context

We examine whether antihypertensive medication reduces cardiovascular events. The American Heart Association defines hypertension as sustained blood pressure ≥ 140/90 mmHg, with treatment typically initiated at this threshold. Patients just above 140 mmHg systematically receive medication while those just below don't, creating a sharp discontinuity.

This setting illustrates RDD's advantages over other causal methods. Randomized trials of hypertension treatment raise ethical concerns—withholding potentially beneficial treatment from high-risk patients. Observational studies suffer from confounding, as physicians may prescribe medication based on unobserved risk factors. The clinical guideline provides exogenous variation in treatment assignment.

### Estimation Approach

We implement both parametric and nonparametric estimation. The parametric approach fits polynomials on either side of the cutoff:

$$
Y_i = \alpha + \tau D_i + \beta_1 X_i + \beta_2 X_i^2 + \ldots + \beta_p X_i^p + \gamma_1 D_i X_i + \ldots + \gamma_p D_i X_i^p + \varepsilon_i
$$

The coefficient $\tau$ estimates the treatment effect. Higher-order polynomials capture nonlinear relationships but may overfit, while linear specifications risk misspecification bias.

Nonparametric methods using local linear regression often prove more robust:

$$
\hat{\tau} = \hat{\mu}_+(c) - \hat{\mu}_-(c)
$$

where $\hat{\mu}_+(c)$ and $\hat{\mu}_-(c)$ represent local linear fits from above and below the cutoff using observations within bandwidth $h$.

### R Implementation

```r
# Load required packages
if (!requireNamespace("rdrobust", quietly = TRUE)) install.packages("rdrobust")
if (!requireNamespace("rddensity", quietly = TRUE)) install.packages("rddensity")
if (!requireNamespace("ggplot2", quietly = TRUE)) install.packages("ggplot2")
if (!requireNamespace("dplyr", quietly = TRUE)) install.packages("dplyr")

library(rdrobust)
library(rddensity)
library(ggplot2)
library(dplyr)

set.seed(456)

# Simulate patient data
n <- 2000
cutoff <- 140  # Hypertension threshold (mmHg)

# Running variable: systolic blood pressure
# Add some manipulation - patients bunch slightly below cutoff
X_base <- rnorm(n, mean = 140, sd = 15)
manipulation_prob <- pmax(0, pmin(1, (142 - X_base) / 10))
X <- ifelse(runif(n) < manipulation_prob & X_base > cutoff - 5 & X_base < cutoff + 2,
            X_base - runif(n, 1, 4), X_base)

# Treatment assignment
D <- as.numeric(X >= cutoff)

# Outcome: cardiovascular events (binary)
# True effect: medication reduces event probability by 0.15
true_effect <- -0.15
prob_event <- plogis(-2 + 0.01 * (X - cutoff) - 0.002 * (X - cutoff)^2 + 
                     true_effect * D + rnorm(n, sd = 0.1))
Y <- rbinom(n, 1, prob_event)

# Create dataset
data <- data.frame(
  bp = X,
  treatment = D,
  cv_event = Y,
  centered_bp = X - cutoff
)

# Density test for manipulation
density_test <- rddensity(data$bp, c = cutoff)
summary(density_test)

# Parametric RDD - polynomial approach
poly2_model <- lm(cv_event ~ treatment + centered_bp + I(centered_bp^2) + 
                  treatment:centered_bp + treatment:I(centered_bp^2), data = data)
poly2_effect <- coef(poly2_model)["treatment"]

# Linear RDD
linear_model <- lm(cv_event ~ treatment + centered_bp + treatment:centered_bp, data = data)
linear_effect <- coef(linear_model)["treatment"]

# Nonparametric RDD using optimal bandwidth
np_rdd <- rdrobust(data$cv_event, data$bp, c = cutoff)
np_effect <- np_rdd$coef["Robust", ]

# Alternative bandwidth (half of optimal)
np_rdd_half <- rdrobust(data$cv_event, data$bp, c = cutoff, h = np_rdd$bws[1,1]/2)
np_effect_half <- np_rdd_half$coef["Robust", ]

# Results summary
cat("Manipulation Test p-value:", round(density_test$test$p_jk, 4), "\n")
cat("Polynomial (order 2) effect:", round(poly2_effect, 4), "\n")
cat("Linear RDD effect:", round(linear_effect, 4), "\n")
cat("Nonparametric RDD effect:", round(np_effect, 4), "\n")
cat("Nonparametric RDD (half bandwidth):", round(np_effect_half, 4), "\n")
cat("True effect:", true_effect, "\n")

# Continuity checks for predetermined characteristics
# Age as predetermined characteristic
age <- 45 + 0.1 * (X - cutoff) + rnorm(n, sd = 8)
age_rdd <- rdrobust(age, data$bp, c = cutoff)
cat("Age discontinuity (should be ~0):", round(age_rdd$coef["Robust", ], 4), "\n")

# Visualization
# Create bins for plotting
data_plot <- data %>%
  mutate(
    bp_bin = round(bp / 2) * 2,
    treated = ifelse(bp >= cutoff, "Treated", "Control")
  ) %>%
  group_by(bp_bin, treated) %>%
  summarise(
    mean_outcome = mean(cv_event),
    n_patients = n(),
    .groups = 'drop'
  ) %>%
  filter(n_patients >= 5)  # Only show bins with sufficient observations

# Main RDD plot
p1 <- ggplot(data_plot, aes(x = bp_bin, y = mean_outcome, color = treated)) +
  geom_point(aes(size = n_patients), alpha = 0.7) +
  geom_smooth(method = "loess", se = TRUE) +
  geom_vline(xintercept = cutoff, linetype = "dashed", color = "red", alpha = 0.7) +
  scale_color_manual(values = c("Control" = "#2166ac", "Treated" = "#762a83")) +
  scale_size_continuous(name = "N patients", range = c(1, 4)) +
  labs(
    title = "Cardiovascular Events by Blood Pressure",
    subtitle = "Sharp discontinuity at hypertension threshold (140 mmHg)",
    x = "Systolic Blood Pressure (mmHg)",
    y = "Cardiovascular Event Rate",
    color = "Treatment Status"
  ) +
  theme_minimal() +
  theme(
    legend.position = "bottom",
    plot.title = element_text(size = 12),
    plot.subtitle = element_text(size = 10, color = "gray50")
  )

# Density plot to check for manipulation
p2 <- ggplot(data, aes(x = bp)) +
  geom_histogram(bins = 50, alpha = 0.7, fill = "steelblue") +
  geom_vline(xintercept = cutoff, linetype = "dashed", color = "red") +
  labs(
    title = "Distribution of Blood Pressure Measurements",
    subtitle = paste0("McCrary test p-value: ", round(density_test$test$p_jk, 4)),
    x = "Systolic Blood Pressure (mmHg)",
    y = "Number of Patients"
  ) +
  theme_minimal()

print(p1)
print(p2)

# Bandwidth sensitivity analysis
bandwidths <- seq(5, 25, by = 2.5)
sensitivity_results <- data.frame(
  bandwidth = numeric(),
  effect = numeric(),
  se = numeric(),
  n_obs = numeric()
)

for (bw in bandwidths) {
  result <- rdrobust(data$cv_event, data$bp, c = cutoff, h = bw)
  sensitivity_results <- rbind(sensitivity_results, data.frame(
    bandwidth = bw,
    effect = result$coef["Robust", ],
    se = result$se["Robust", ],
    n_obs = result$N_h[1] + result$N_h[2]
  ))
}

# Sensitivity plot
p3 <- ggplot(sensitivity_results, aes(x = bandwidth, y = effect)) +
  geom_point() +
  geom_errorbar(aes(ymin = effect - 1.96*se, ymax = effect + 1.96*se), width = 0.5) +
  geom_hline(yintercept = true_effect, linetype = "dashed", color = "red") +
  geom_hline(yintercept = 0, linetype = "solid", color = "gray50", alpha = 0.5) +
  labs(
    title = "RDD Effect Estimates Across Bandwidths",
    x = "Bandwidth (mmHg)",
    y = "Treatment Effect",
    subtitle = "Red line shows true effect (-0.15)"
  ) +
  theme_minimal()

print(p3)
```

### Interpretation and Validation

The density test examines whether patients manipulate blood pressure readings to avoid treatment. A significant p-value suggests bunching below the cutoff, violating the continuity assumption. In practice, manipulation may occur through multiple measurements or strategic timing of clinic visits.

Bandwidth selection involves the classic bias-variance tradeoff. Narrow bandwidths reduce bias from functional form misspecification but increase variance due to smaller sample sizes. The `rdrobust` package implements data-driven bandwidth selection, though sensitivity analysis across multiple bandwidths provides valuable robustness checks.

Predetermined characteristics should not jump at the cutoff. Testing variables like age, gender, or previous medical history helps validate the design. Significant discontinuities in these variables suggest confounding or manipulation, undermining causal identification.

## Comparing RDD with Other Methods

RDD occupies a unique position in the causal inference toolkit. Unlike IV, which requires finding exogenous instruments, RDD exploits existing administrative rules. This makes it particularly attractive for policy evaluation—eligibility thresholds create natural experiments without researcher intervention.

The method's internal validity often exceeds that of matching or regression approaches. Local randomization near the cutoff eliminates selection bias more convincingly than assuming conditional ignorability across the entire covariate distribution. However, external validity remains limited. RDD identifies effects only at the cutoff, potentially missing heterogeneous effects across the running variable's range.

The approach also faces practical limitations. Sharp cutoffs are less common than fuzzy ones, where assignment rules affect treatment probability rather than certainty. Fuzzy RDD requires additional assumptions and instrumental variable techniques, complicating interpretation. Multiple cutoffs or multidimensional assignment rules further challenge standard methods.

## Extensions and Practical Considerations

Recent methodological advances address several RDD limitations. Geographic RDD exploits spatial discontinuities in policies, such as school district boundaries or electoral district borders. Kink designs examine changes in policy slopes rather than levels, expanding the method's applicability.

Practitioners increasingly recognize the importance of graphical analysis alongside formal statistical tests. Plotting outcomes against the running variable reveals functional form assumptions and potential violations. Binned scatter plots, as implemented above, provide intuitive visualizations while local polynomial fits offer flexible functional forms.

The choice between parametric and nonparametric approaches remains contentious. Parametric methods provide precise estimates when functional forms are correctly specified but risk substantial bias otherwise. Nonparametric approaches sacrifice precision for robustness, though bandwidth selection introduces its own uncertainties.

## Limitations and Future Directions

RDD's reliance on arbitrary cutoffs both enables and constrains its application. While administrative thresholds are common, they may not align with research questions of primary interest. The method identifies effects at specific points rather than population parameters, limiting generalizability.

Contemporary research explores machine learning applications to RDD. Random forests and neural networks may better capture complex nonlinear relationships, though interpretability concerns arise. Causal machine learning techniques attempt to combine RDD's identification strategy with flexible modeling approaches.

The method also faces challenges in settings with strategic behavior. When agents understand assignment rules, they may manipulate running variables or time their interactions with institutions. Detecting and accounting for such manipulation requires sophisticated empirical strategies.

## Conclusion

Regression Discontinuity Design transforms administrative convenience into scientific opportunity. By exploiting arbitrary cutoffs, researchers can estimate causal effects in settings where experiments prove infeasible or unethical. The blood pressure example demonstrates the method's practical application while highlighting key assumptions and diagnostic tests.

The approach's strength lies in its transparency—the assignment mechanism is observed and understood. Unlike black-box instruments or unverifiable ignorability assumptions, RDD's identification strategy can be visualized and tested. This makes it particularly valuable for policy evaluation and regulatory analysis.

Yet RDD is not a panacea. Its local nature limits external validity, while manipulation and confounding threats require careful attention. Successful applications combine substantive knowledge of institutional contexts with rigorous empirical testing. When these conditions align, RDD provides credible causal estimates that inform both academic understanding and policy decisions.

The method continues evolving as researchers encounter new applications and develop improved techniques. Geographic discontinuities, kink designs, and machine learning extensions expand its reach while maintaining its core appeal: exploiting arbitrary rules to reveal causal relationships.

## References

- Imbens, G. W., & Lemieux, T. (2008). Regression discontinuity designs: A guide to practice. *Journal of Econometrics*, 142(2), 615-635.
- Lee, D. S., & Lemieux, T. (2010). Regression discontinuity designs in economics. *Journal of Economic Literature*, 48(2), 281-355.
- Cattaneo, M. D., Idrobo, N., & Titiunik, R. (2019). *A practical introduction to regression discontinuity designs: Foundations*. Cambridge University Press.
- Hahn, J., Todd, P., & Van der Klaauw, W. (2001). Identification and estimation of treatment effects with a regression-discontinuity design. *Econometrica*, 69(1), 201-209.
