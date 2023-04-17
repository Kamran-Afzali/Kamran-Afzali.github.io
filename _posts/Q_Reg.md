Health services and health economics research articles commonly use multivariate regression techniques to measure the relationship of health service utilization and health outcomes (the outcomes of interest) with clinical characteristics, sociodemographic factors, and policy changes (usually treated as explanatory variables). Common regression methods measure differences in outcome variables between populations at the mean (i.e., ordinary least squares regression), or a population average effect (i.e., logistic regression models), after adjustment for other explanatory variables of interest. These are often done assuming that the regression coefficients are constant across the population – in other words, the relationships between the outcomes of interest and the explanatory variables remain the same across different values of the variables. There are times, however, when researchers, policymakers, and clinicians may be interested in group differences across the distribution of a given dependent variable rather than only at the mean.


Quantile regression is a regression method for estimating these conditional quantile functions. Just as linear regression estimates the conditional mean function as a linear combination of the predictors, quantile regression estimates the conditional quantile function as a linear combination of the predictors.

Quantile regression is more effective and robust to outliers. In Quantile regression, you’re not limited to just finding the median i.e you can calculate any percentage(quantile) for a particular value in features variables. For example, if one wants to find the 30th quantile for the price of a particular building, that means that there is a 30% chance the actual price of the building is below the prediction, while there is a 70% chance that the price is above.

R is a open source software project and can be freely downloaded from the CRAN website along with its associated documentation. For unix-based operating systems it is usual to download and build R from source, but binary versions are available for most computing platforms and can be easily installed. Once R is running the installation of additional packages is quite straightward. To install the quantile regression package from R one simply types, 

install.packages("quantreg") Provided that your machine has a proper internet connection and you have write permission in the appropriate system directories, the installation of the package should proceed automatically. Once the quantreg package is installed, it needs to be made accessible to the current R session by the command,

Quantile regression is a regression method for estimating these conditional quantile functions. Just as linear regression estimates the conditional mean function as a linear combination of the predictors, quantile regression estimates the conditional quantile function as a linear combination of the predictors.

Median regression (i.e. 50th quantile regression) is sometimes preferred to linear regression because it is “robust to outliers”. The next plot illustrates this. We add two outliers to the data (colored in orange) and see how it affects our regressions. The dotted lines are the fits for the original data, while the solid lines are for the data with outliers. As before, red is for linear regression while blue is for quantile regression. See how the linear regression fit shifts a fair amount compared to the median regression fit (which barely moves!)?

Quantile regression is more effective and robust to outliers. In Quantile regression, you’re not limited to just finding the median i.e you can calculate any percentage(quantile) for a particular value in features variables. For example, if one wants to find the 30th quantile for the price of a particular building, that means that there is a 30% chance the actual price of the building is below the prediction, while there is a 70% chance that the price is above.


Many opportunities for using quantile regression exist in the health services literature. We encourage a wider application of these statistical methods. As computing power has increased, the computational burden for estimating quantile regression has decreased substantially to the point where results for our sample of over 10,000 subjects were completed in less than a minute. As the costs in time and effort of computing have fallen, it is becoming more and more common to check the assumption that slopes are the same or differ by examining interaction terms with observed covariates. With the time barrier less of a concern, and with easy-to-use quantile regression commands available in commonly used statistical packages, these methods will be used in an increasing range of research projects.

The main advantage of quantile regression methodology is that the method allows for understanding relationships between variables outside of the mean of the data,making it useful in understanding outcomes that are non-normally distributed and that have nonlinear relationships with predictor variables. By in large, summaries from commonly used regression methods in health services and outcomes research provide information that is useful when thinking about the average patient. However, it is the complex patients with multiple comorbidities who account for most health care expenditures and present the most difficulty in providing high quality medical care. Quantile regression allows the analyst to drop the assumption that variables operate the same at the upper tails of the distribution as at the mean and to identify the factors that are important determinants of expenditures and quality of care for different subgroups of patients.

There are other methodological advantages to quantile regression when compared to other methods of segmenting data. One might argue that separate regressions could be run stratifying on different segments of the population according to its unconditional distribution of the dependent variable. For example, in the disparities analysis above, we could estimate regression models to estimate the mean expenditures for different sub-samples of the population that have low, moderate, and high spending. However, segmenting the population in this way results in smaller sample sizes for each regression and could have serious sample selection issues.[11] As opposed to such a truncated regression, the quantile regression method weights different portions of the sample to generate coefficient estimates, thus increasing the power to detect differences in the upper and lower tails.

## Reference

https://www.statology.org/quantile-regression-in-r/

https://cran.r-project.org/web/packages/quantreg/vignettes/rq.pdf

https://www.r-bloggers.com/2019/01/quantile-regression-in-r-2/

https://rpubs.com/ibn_abdullah/rquantile

https://www.geeksforgeeks.org/quantile-regression-in-r-programming/

https://search.r-project.org/CRAN/refmans/lqr/html/loglqr.html

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4054530/
