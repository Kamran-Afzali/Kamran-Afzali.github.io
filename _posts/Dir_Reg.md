---
layout: post
categories: posts
title: Dirichlet Regression and Clustering in R
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: January 2025
---


## Dirichlet Regression and Clustering in R

The Dirichlet distribution can be used in both regression and clustering models, especially when analyzing compositional data—data that represents proportions summing to 1, such as percentages of burden or time allocations. In the R programming environment, two powerful packages, **`DirichletReg`** for regression and **`dirichletprocess`** for clustering, offer versatile tools for analyzing such data through Bayesian approaches.

#### Dirichlet Regression with the **`DirichletReg`** Package

Dirichlet regression provides a robust framework for modeling compositional data, which is frequently encountered in fields like ecology, economics, and social sciences. The **`DirichletReg`** package in R is specifically designed to perform regression analysis where the response variables are proportions. It allows for the estimation of the relationship between these proportions and various predictors, making it an essential tool for research involving data that reflects parts of a whole.

In practical terms, Dirichlet regression is useful when investigating how factors such as demographic information or environmental variables influence the distribution of proportions within a dataset. The package offers two key parametrizations for model specification: one using α (common parametrization) and another using μ/φ (alternative parametrization), providing flexibility in model interpretation. The package also includes a variety of diagnostic and visualization tools, such as residual plots and confidence intervals, allowing for a more comprehensive evaluation of model performance. To use the package, the dependent variable, which consists of compositional data, needs to be converted into a special format using the `DR_data()` function. This function ensures that the data is properly structured for Dirichlet regression analysis. The main function for fitting Dirichlet regression models is `DirichReg()`. It allows users to specify the model formula, choose the parametrization, and include various predictors. The formula syntax is similar to other regression functions in R, making it intuitive for users familiar with R's modeling framework. Once a model is fitted, the package provides several methods for analyzing and interpreting the results. These include `summary()` for model summaries, `predict()` for generating predictions, and various diagnostic tools such as residual plots and confidence intervals. The package also includes functions for model comparison, such as anova(), which enables researchers to compare nested models and assess the significance of additional predictors or more complex model structures. Likewise, the package provides plotting functions that allow users to create informative visualizations of their compositional data and model results. 

#### Dirichlet Process Clustering with the **`dirichletprocess`** Package

In contrast, Dirichlet process clustering focuses on unsupervised learning, offering a nonparametric Bayesian approach that automatically determines the number of clusters in the data. The **`dirichletprocess`** package in R implements Dirichlet process mixture models (DPMMs), which are particularly useful when the number of clusters is unknown or difficult to pre-specify. This method is advantageous for exploratory data analysis, as it adapts to the underlying structure of the data, making it highly flexible. The **`dirichletprocess`** package simplifies the implementation of Dirichlet process clustering by providing functions for creating mixture models using a variety of distributions, including Normal, Multivariate Normal, Beta, and Weibull distributions. These models can then be fitted using Markov Chain Monte Carlo (MCMC) methods to estimate cluster memberships. The package automatically handles complex tasks like tuning hyperparameters and selecting the number of clusters based on the data, relieving the user from manually specifying these parameters. The key advantage of Dirichlet processes is that they do not require specifying the number of clusters beforehand. Instead, the model adapts to the data, automatically determining the number of clusters based on the observed patterns.

To perform clustering using the 'dirichletprocess' package, users typically follow these steps, where the data should be scaled or normalized as appropriate for the chosen kernel distribution. Selecting a pre-built model or create a custom one. For clustering, the Multivariate Normal kernel is often used for continuous multivariate data. To run the Markov Chain Monte Carlo (MCMC) sampling algorithm, which estimates the posterior distribution of the model parameters.Finally after fitting, the package provides methods to extract cluster assignments and visualize the results.

Both the **`DirichletReg`** and **`dirichletprocess`** packages highlight the power and flexibility of the Dirichlet distribution in handling a variety of data structures, from compositional to clustered. These tools allow researchers to approach their analyses in a Bayesian framework, providing more natural inferences about uncertainty and the data-generating process. As such, they have become essential in domains where proportions and clustering play central roles.

### Dirichlet Regression in Practice

Here's the example of Arctic Lake Data as in package's vignette:

##### Load the Package and Dataset

First, we load the **DirichletReg** package, which is designed for modeling compositional data, and the built-in **ArcticLake** dataset. 

```r
# Load the DirichletReg package
library(DirichletReg)

# Load the ArcticLake dataset
data(ArcticLake)

# View the first few rows of the dataset
head(ArcticLake)
```

##### Prepare the Data for Dirichlet Regression

We use the `DR_data()` function to prepare the data for Dirichlet regression. This function processes the first three columns of **ArcticLake** (representing proportions of sand, silt, and clay) and ensures that each row sums to 1, a requirement for compositional data.

```r
# Prepare the data for Dirichlet regression
AL <- DR_data(ArcticLake[, 1:3])
```

##### Fit a Dirichlet Regression Model

Using the `DirichReg()` function, we fit a Dirichlet regression model. In the formula `AL ~ depth`, **depth** is specified as the predictor for the compositional outcome **AL** (sand, silt, and clay proportions).

```r
# Fit a Dirichlet regression model
model <- DirichReg(AL ~ depth, ArcticLake)
```

##### Display Model Summary

The `summary()` function provides a detailed overview of the fitted model, including coefficient estimates, significance levels, and diagnostics.

```r
# Display the model summary
summary(model)
```

##### Create New Data for Predictions

To make predictions across a range of depth values, we create a new dataset (`new_data`) with a sequence of depth values spanning the full range of depths in the original data.

```r
# Create a sequence of depth values for predictions
new_data <- data.frame(depth = seq(min(ArcticLake$depth), max(ArcticLake$depth), length.out = 100))
```

##### Make Predictions

Using the `predict()` function, we generate predictions from the model for the new depth values, allowing us to examine how the composition changes with depth.

```r
# Make predictions based on the fitted model
predictions <- predict(model, new_data)
```

##### Plot the Results

Finally, we visualize the results:
- We plot the original data points for sand, silt, and clay proportions in different colors.
- We add lines showing the predicted proportions for each sediment type over depth.
- A legend identifies each sediment component.

```r
# Plot the original data points and predictions
plot(rep(ArcticLake$depth, 3), as.numeric(AL), pch = 21, 
     bg = rep(c("#E495A5", "#86B875", "#7DB0DD"), each = nrow(ArcticLake)),
     xlab = "Depth (m)", ylab = "Proportion", ylim = 0:1,
     main = "Sediment Composition in Arctic Lake")

# Add lines for each component prediction
for (i in 1:3) {
  lines(new_data$depth, predictions[, i], col = c("#E495A5", "#86B875", "#7DB0DD")[i], lwd = 2)
}

# Add a legend
legend("topleft", legend = c("Sand", "Silt", "Clay"), lwd = 2, 
       col = c("#E495A5", "#86B875", "#7DB0DD"), pt.bg = c("#E495A5", "#86B875", "#7DB0DD"), 
       pch = 21, bty = "n")
```

### Dirichlet clustering in Practice

This example demonstrates how to perform Dirichlet process clustering on the **faithful** dataset, which contains two variables: eruption duration and waiting time for Old Faithful geyser eruptions. Here’s a breakdown of each step in the text-code-text-code format to help you understand the process.

##### Load the Dataset

The **faithful** dataset is built into R, so we start by loading it and viewing the first few rows.

```r
# Load the faithful dataset
data("faithful")
head(faithful)  # Display the first few rows
```

##### Standardize the Data

Since we're clustering with a multivariate approach, we scale the data to standardize the eruption and waiting times.

```r
# Standardize the data
faithfulTrans <- scale(faithful)
```

##### Create and Fit a Dirichlet Process Mixture Model

We create a **Dirichlet Process Mixture Model** with a multivariate normal kernel, well-suited for clustering continuous data. The Dirichlet process groups similar observations based on probabilistic clustering without requiring a fixed number of clusters.

```r
# Create a Dirichlet process object using multivariate normal distribution
dp <- DirichletProcessMvnormal(faithfulTrans)

# Fit the model using MCMC sampling for 1000 iterations
dp <- Fit(dp, 1000)
```

##### Visualize the Clustering Results

After fitting, we can visualize the clusters. Each color in the plot represents a different cluster assignment.

```r
# Plot the data points, colored by their cluster assignments
plot(dp)
```

##### Extract Cluster Assignments

You can obtain the cluster labels for each data point to see which observations belong to which clusters.

```r
# Get the cluster assignments
clusters <- ClusterLabels(dp)

# Display the cluster assignments
print(clusters)
```

##### Summary and Further Analysis

A summary of the Dirichlet process model provides details on the clustering results, while the posterior distribution shows the size of each cluster.

```r
# Summary of the Dirichlet process model
summary(dp)

# Posterior distribution of cluster sizes
posterior_sizes <- table(clusters)
print(posterior_sizes)
```



### Conclusion

The Dirichlet distribution is a useful tool for both regression and clustering applications. The **`DirichletReg`** package in R offers a robust framework for Dirichlet regression, which is ideal for modeling proportional data—data where the sum of components is constrained to one. By providing flexible parametrizations (using α or μ/φ), diagnostic tools, and functions for model comparison and visualization, the package simplifies the process of drawing meaningful inferences about relationships in compositional data. Likewise, the **`Dirichletprocess`** package supports unsupervised learning through **Dirichlet Process Mixture Models (DPMMs)**, a nonparametric Bayesian approach. This technique is especially useful when the number of clusters in a dataset is unknown or difficult to specify. Its flexibility, which allows the model to adapt based on data patterns, is useful for exploratory data analysis in domains such as bioinformatics or financial modeling. The package automates many of the challenging aspects of Bayesian inference, such as hyperparameter tuning and MCMC sampling, providing researchers with a user-friendly tool to uncover hidden structures in data. While these tools offer powerful capabilities, several questions remain for further exploration. How can Dirichlet regression models be further adapted to handle missing data or hierarchical structures in datasets? Can interaction terms or more complex non-linear relationships be better accommodated in the current framework? In what ways can we improve the interpretability of Dirichlet regression coefficients, particularly when dealing with complex, multi-component responses? How does Dirichlet process clustering perform when applied to extremely high-dimensional data, such as in genomics or image recognition? What strategies can enhance the scalability of Dirichlet process models for larger datasets? Exploring these questions could lead to new methodological advancements and applications for the Dirichlet distribution in both supervised and unsupervised learning contexts.

### References


- [Package DirichletReg: Regression Analysis with Dirichlet Distributions](https://cran.r-project.org/web/packages/DirichletReg/DirichletReg.pdf)
- [Dirichlet Regression With R](http://r-statistics.co/Dirichlet-Regression-With-R.html)
- [DirichletReg Vignette](http://cran.nexr.com/web/packages/DirichletReg/vignettes/DirichletReg-vig.pdf)
- [Austrian Research Report - Dirichlet Analysis](https://research.wu.ac.at/ws/portalfiles/portal/17761231/Report125.pdf)
- [CRAN R Package: DirichletReg](https://cran.r-project.org/package=DirichletReg)
- [Data Science Tutorials: Clustering](https://dm13450.github.io/2018/05/30/Clustering.html)
- [R Documentation: Dirichlet Process](https://www.rdocumentation.org/packages/dirichletprocess/versions/0.4.2)
- [Dirichlet Process: A CRAN Vignette](https://cran.r-project.org/web/packages/dirichletprocess/vignettes/dirichletprocess.pdf)
- [OhioLink Thesis - Dirichlet Regression](https://etd.ohiolink.edu/acprod/odb_etd/ws/send_file/send?accession=case155752396390554&disposition=inline)
- [Iieta Research Report - Dirichlet Processes](https://www.iieta.org/download/file/fid/12006)
- [Dirichlet Regression Discussion on Stan Forum](https://discourse.mc-stan.org/t/dirichlet-regression/2747/9)
- [R Package DirReg - Beta Discussion on Stan Forum](https://discourse.mc-stan.org/t/r-package-dirreg-beta-an-attempt-to-use-stan-for-improving-softmax-regression-inference-please-test-if-you-wish-for-feedback/2831)
- [ZOID R Package Documentation](https://cran.r-project.org/web/packages/zoid/zoid.pdf)
- [ArXiv Preprint: Dirichlet Regression Models](https://arxiv.org/pdf/1808.06399)
- [GitHub: Dirichlet Process](https://github.com/dm13450/dirichletprocess)
- [Dirichlet Process CRAN Documentation](https://cran.r-project.org/web/packages/dirichletprocess/dirichletprocess.pdf)

