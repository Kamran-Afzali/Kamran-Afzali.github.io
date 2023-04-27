---
layout: post
categories: posts
title: Quantile regression
featured-image: /images/stan.png
tags: [STAN, R, Bayes]
date-string: May 2023
---
## Quantile regression and its postential for health services

### Introduction

Multivariate regression techniques are frequently used in health services research publications to assess the association between clinical characteristics, sociodemographic factors, and policy changes (which are typically considered as explanatory variables) and health service utilisation and outcomes. After adjusting for additional explanatory variables, common regression methods evaluate differences in outcome variables between populations at the mean (i.e., ordinary least squares regression), or a population average effect. These are frequently carried out on the presumption that the regression coefficients are constant across the population, meaning that the associations between the important outcomes and the explanatory variables hold true regardless of the values of the variables. However, rather than merely looking at group differences at the mean, researchers, decision-makers, and physicians could be more interested in group differences over the distribution of a given dependent variable.

Another major policy topic that can be evaluated using a method that gauges disparities across the distribution is health care expenditures. When compared to people at the bottom or in the centre of the distribution of health care utilisation, the relationship between health care and health outcomes may be quite different for those who use health care the most frequently.  In terms of health status, the average user of healthcare differs greatly from the heavy user, but what about other variables like race/ethnicity, gender, occupation, insurance status, and other variables. In a way that is not conceivable with commonly employed regression techniques, quantile regression enables investigation of these other variations that exist among heavy health care users.

In the US, differences in the distribution of health care spending between Blacks and Whites and between Hispanics and Whites are present at the top quantiles of spending. Even in the top income and educational categories, the same pattern of differences is still noticeable. The assessment of racial and ethnic differences in health care and mental health spending across various quantiles of spending has been done using quantile regression approaches. 

Ordinary least squares (OLS) regression and related methods, which typically assume that associations between independent and dependent variables are the same at all levels. Quantile regression is not a regression estimated on a quantile, or subsample of data as the name may suggest. Quantile methods allow the analyst to relax the common regression slope assumption. The objective of OLS regression is to reduce the gaps between the values predicted by the regression line and the values actually observed. In contrast, quantile regression attempts to minimise the weighted distances by differently weighing the distances between the values predicted by the regression line and the observed values. The regression technique known as quantile regression is used to estimate these conditional quantile functions. Quantile regression estimates the conditional quantile function as a linear combination of the predictors, just like linear regression does for the conditional mean function.

Quantile regression is a statistical method that is highly effective and resilient to outliers. Median regression (i.e. 50th quantile regression) is sometimes preferred to linear regression because it is “robust to outliers”. Quantile regression allows you to calculate any desired percentage or quantile for a particular value in the features variables. For instance, if you want to determine the 30th quantile for health expoenses, this means that there is a 30% probability that the actual health expoenses will be below the prediction, while there is a 70% chance that the price will be above it.








Quantile regression is a regression method for estimating these conditional quantile functions. Just as linear regression estimates the conditional mean function as a linear combination of the predictors, quantile regression estimates the conditional quantile function as a linear combination of the predictors.


R is a open source software project and can be freely downloaded from the CRAN website along with its associated documentation. For unix-based operating systems it is usual to download and build R from source, but binary versions are available for most computing platforms and can be easily installed. Once R is running the installation of additional packages is quite straightward. To install the quantile regression package from R one simply types. install.packages("quantreg") Provided that your machine has a proper internet connection and you have write permission in the appropriate system directories, the installation of the package should proceed automatically. 



Many opportunities for using quantile regression exist in the health services literature. We encourage a wider application of these statistical methods. As computing power has increased, the computational burden for estimating quantile regression has decreased substantially to the point where results for our sample of over 10,000 subjects were completed in less than a minute. As the costs in time and effort of computing have fallen, it is becoming more and more common to check the assumption that slopes are the same or differ by examining interaction terms with observed covariates. With the time barrier less of a concern, and with easy-to-use quantile regression commands available in commonly used statistical packages, these methods will be used in an increasing range of research projects.

The main advantage of quantile regression methodology is that the method allows for understanding relationships between variables outside of the mean of the data,making it useful in understanding outcomes that are non-normally distributed and that have nonlinear relationships with predictor variables. By in large, summaries from commonly used regression methods in health services and outcomes research provide information that is useful when thinking about the average patient. However, it is the complex patients with multiple comorbidities who account for most health care expenditures and present the most difficulty in providing high quality medical care. Quantile regression allows the analyst to drop the assumption that variables operate the same at the upper tails of the distribution as at the mean and to identify the factors that are important determinants of expenditures and quality of care for different subgroups of patients.

There are other methodological advantages to quantile regression when compared to other methods of segmenting data. One might argue that separate regressions could be run stratifying on different segments of the population according to its unconditional distribution of the dependent variable. For example, in the disparities analysis above, we could estimate regression models to estimate the mean expenditures for different sub-samples of the population that have low, moderate, and high spending. However, segmenting the population in this way results in smaller sample sizes for each regression and could have serious sample selection issues.[11] As opposed to such a truncated regression, the quantile regression method weights different portions of the sample to generate coefficient estimates, thus increasing the power to detect differences in the upper and lower tails.

## Reference

+ [Quantile regression in R](https://www.statology.org/quantile-regression-in-r/)

+ [Quantile regression on Cran](https://cran.r-project.org/web/packages/quantreg/vignettes/rq.pdf)

+ [Quantile regression in R 2](https://www.r-bloggers.com/2019/01/quantile-regression-in-r-2/)

+ [Quantile regression on Rpubs](https://rpubs.com/ibn_abdullah/rquantile)

+ [Quantile regression in R 3](https://www.geeksforgeeks.org/quantile-regression-in-r-programming/)

+ [Quantile regression on Cran 2](https://search.r-project.org/CRAN/refmans/lqr/html/loglqr.html)

+ [Thinking beyond the mean: a practical guide for using quantile regression methods for health services research](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4054530/)
