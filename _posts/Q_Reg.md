
Quantile regression is a regression method for estimating these conditional quantile functions. Just as linear regression estimates the conditional mean function as a linear combination of the predictors, quantile regression estimates the conditional quantile function as a linear combination of the predictors.

Quantile regression is more effective and robust to outliers. In Quantile regression, you’re not limited to just finding the median i.e you can calculate any percentage(quantile) for a particular value in features variables. For example, if one wants to find the 30th quantile for the price of a particular building, that means that there is a 30% chance the actual price of the building is below the prediction, while there is a 70% chance that the price is above.

R is a open source software project and can be freely downloaded from the CRAN website along with its associated documentation. For unix-based operating systems it is usual to download and build R from source, but binary versions are available for most computing platforms and can be easily installed. Once R is running the installation of additional packages is quite straightward. To install the quantile regression package from R one simply types, 

install.packages("quantreg") Provided that your machine has a proper internet connection and you have write permission in the appropriate system directories, the installation of the package should proceed automatically. Once the quantreg package is installed, it needs to be made accessible to the current R session by the command,

Quantile regression is a regression method for estimating these conditional quantile functions. Just as linear regression estimates the conditional mean function as a linear combination of the predictors, quantile regression estimates the conditional quantile function as a linear combination of the predictors.

Median regression (i.e. 50th quantile regression) is sometimes preferred to linear regression because it is “robust to outliers”. The next plot illustrates this. We add two outliers to the data (colored in orange) and see how it affects our regressions. The dotted lines are the fits for the original data, while the solid lines are for the data with outliers. As before, red is for linear regression while blue is for quantile regression. See how the linear regression fit shifts a fair amount compared to the median regression fit (which barely moves!)?

Quantile regression is more effective and robust to outliers. In Quantile regression, you’re not limited to just finding the median i.e you can calculate any percentage(quantile) for a particular value in features variables. For example, if one wants to find the 30th quantile for the price of a particular building, that means that there is a 30% chance the actual price of the building is below the prediction, while there is a 70% chance that the price is above.

## Reference

https://www.statology.org/quantile-regression-in-r/

https://cran.r-project.org/web/packages/quantreg/vignettes/rq.pdf

https://www.r-bloggers.com/2019/01/quantile-regression-in-r-2/

https://rpubs.com/ibn_abdullah/rquantile

https://www.geeksforgeeks.org/quantile-regression-in-r-programming/

https://search.r-project.org/CRAN/refmans/lqr/html/loglqr.html

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4054530/
