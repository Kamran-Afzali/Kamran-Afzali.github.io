# Health Data Anonymization for Researchers: Protecting Privacy While Advancing Science

Data anonymization is a critical component of responsible health research, allowing valuable insights to be gained while protecting individual privacy. This presentation explores why anonymization matters, its historical development, key techniques, and practical implementation using R packages.

## Why Data Anonymization?

Health data anonymization serves multiple crucial purposes in today's research landscape

Data-intensive and needs-driven research can deliver substantial health benefits, but concerns with privacy loss are rising due to posibility of data breaches.

These concerns can undermine the trustworthiness of data processing institutions and reduce people's willingness to share their data, creating barriers to important research.

Especially in biomedical research, individual-level data must be protected due to the sensitivity of patient information. 

The [European Health Data Space ](https://cifs.dk/focus-areas/health/european-health-data-space-explained/?gad_source=1&gclid=CjwKCAjw47i_BhBTEiwAaJfPprkEAsXM1mmq2R0T9nb9mtRPuiW2OysPQAKND8UGRih0hhSEsl9a2hoCl-0QAvD_BwE) (EHDS) initiative exemplifies how institutions are addressing these challenges by empowering individuals to access and control their health data while offering a harmonized framework for the reuse of health data for research, innovation, and policymaking. 

Proper anonymization also helps overcome information governance risks enabling more collaborative and comprehensive research.

## Historical Development of Data Anonymization

The field of data anonymization has evolved significantly over time, responding to changing technology, regulations, and understanding of privacy risks.

Initially, simple removal of direct identifiers (like names and social security numbers) was considered sufficient protection.  However, as re-identification attacks demonstrated the inadequacy of this approach, more sophisticated techniques emerged.

Regulatory frameworks have played a crucial role in this evolution. For instance, guidelines from organizations like the UK's Information Commissioner's Office (ICO) have helped standardize approaches to anonymization. 

Recent developments include the European Health Data Space regulation, which represents a sea change in how health data is managed and shared across Europe. This evolution reflects growing recognition that effective anonymization requires both technical solutions and governance frameworks.

Meanwhile, the increased adoption of open-source software in healthcare settings, particularly R, has democratized access to sophisticated anonymization tools[7].


### Historical Milestones
- **1996 HIPAA Safe Harbor**: Established basic de-identification standards (removal of 18 identifiers)
- **2006 k-Anonymity Formalization**: Sweeney's work demonstrated vulnerabilities in naive approaches
- **2014 Differential Privacy Breakthroughs**: Dwork et al. introduced formal privacy guarantees
- **2018 GDPR Article 29**: Clarified pseudonymization vs anonymization thresholds
- **2023 EHDS Implementation**: Mandated privacy-by-design for EU health data spaces


## Main Techniques of Data Anonymization


### Data Masking

Data masking is one of the most frequently used anonymization techniques. It involves obscuring or altering the values in the original dataset by replacing them with artificial data that appears genuine but has no real connection to the original. This method allows organizations to retain access to the original dataset while making it highly resistant to detection or reverse engineering.

Data masking can be applied statically or dynamically. Static data masking applies masking rules to data prior to storage or sharing, making it ideal for protecting sensitive data that is unlikely to change over time. Dynamic data masking, on the other hand, applies masking rules when the data is queried or transferred.

### Pseudonymization

Pseudonymization replaces private identifiers such as names or email addresses with fictitious ones. This technique preserves data integrity and ensures that data remains statistically accurate, which is particularly important when using data for model training, testing, and analytics. It's worth noting that pseudonymization doesn't address indirect identifiers such as age or geographic location, which can potentially be used to identify specific individuals when combined with other information. As a result, data protected using this approach may still be subject to certain data privacy regulations.

### Data Swapping

Data swapping, also known as data shuffling or permutation, reorders the attribute values within a dataset so they no longer correspond to the original data. By rearranging data within database rows, this method preserves the statistical relevance of the data while minimizing re-identification risks.

### Generalization

Generalization involves purposely removing parts of a dataset to make it less identifiable. Using this technique, data is modified into a set of ranges with appropriate boundaries, thus removing identifiers while retaining data accuracy. For example, in an address, the house numbers could be removed, but not the street names.

### Data Perturbation

Perturbation changes the original dataset slightly by rounding numbers and adding random noise. An example of this would be using a base of 5 for rounding values like house numbers or ages, which leaves the data proportional to its original value while making it less precise.

### Synthetic Data Generation

Synthetic data generation is perhaps the most advanced data anonymization technique. This method algorithmically creates data that has no connection to real data. It creates artificial datasets rather than altering or using an original dataset, which could risk privacy and security. For example, synthetic test data can be created using statistical models based on patterns in the original dataset – via standard deviations, medians, linear regression, or other statistical techniques.

## R Packages for Data Anonymization

R programming language, used for data analysis and statistics, offers several packages that can assist in implementing data anonymization techniques. Let's explore some of these packages and their functionalities:

### `anonymizer`

The `anonymizer` package provides a set of functions for quickly and easily anonymizing data containing Personally Identifiable Information (PII). It uses a combination of salting and hashing to protect sensitive information.

Key functions in the anonymizer package include:

- `salt`: Adds a random string to the input data before hashing.
- `unsalt`: Removes the salt from salted data.
- `hash`: Applies a hashing algorithm to the input data.
- `anonymize`: Combines salting and hashing to anonymize the input data.


### `deident`

The `deident` package in R provides a comprehensive tool for the replicable removal of personally identifiable data from datasets. It offers several methods tailored to different data types.  

Key features of the `deident` package include:

- **Pseudonymization**: Consistent replacement of a string with a random string.
- **Encryption**: Consistent replacement of a string with an alphanumeric hash using an encryption key and salt.
- **Shuffling**: Replacement of columns by a random sample without replacement.
- **Blurring**: Aggregation of numeric or categorical data according to specified rules.
- **Perturbation**: Addition of user-defined random noise to a numeric variable. 


### `sdcMicro`

The `sdcMicro` package is a comprehensive tool for statistical disclosure control in R. It offers a wide range of methods for anonymizing microdata, including various risk assessment and anonymization techniques.

Some of the key features of sdcMicro include:

- Risk assessment for categorical and continuous key variables
- Local suppression and global recoding
- Microaggregation for continuous variables
- PRAM (Post Randomization Method) for categorical variables


### SDC methods can be classified as non-perturbative and perturbative 

- Non-perturbative methods reduce the detail in the data by generalization or suppression of certain values (i.e., masking) without distorting the data structure.

- Perturbative methods do not suppress values in the dataset but perturb (i.e., alter) values to limit disclosure risk by creating uncertainty around the true values.

- Both non-perturbative and perturbative methods can be used for categorical and continuous variables.

### Probabilistic and deterministic SDC methods

- Probabilistic methods depend on a probability mechanism or a random number-generating mechanism. Every time a probabilistic method is used, a different outcome is generated. For these methods it is often recommended that a seed be set for the random number generator if you want to produce replicable results.

- Deterministic methods follow a certain algorithm and produce the same results if applied repeatedly to the same data with the same set of parameters.


### Global recoding

Global recoding combines several categories of a categorical variable or constructs intervals for continuous variables. This reduces the number of categories available in the data and potentially the disclosure risk, especially for categories with few observations, but also, importantly, it reduces the level of detail of information available to the analyst. 


### Top and bottom coding

Top and bottom coding are similar to global recoding, but instead of recoding all values, only the top and/or bottom values of the distribution or categories are recoded. This can be applied only to ordinal categorical variables and (semi-)continuous variables, since the values have to be at least ordered. Top and bottom coding is especially useful if the bulk of the values lies in the center of the distribution with the peripheral categories having only few observations (outliers).


### Local suppression

It is common in surveys to encounter values for certain variables or combinations of quasi-identifiers (keys) that are shared by very few individuals. When this occurs, the risk of re-identification for those respondents is higher than the rest of the respondents (see the Section k-anonymity). Often local suppression is used after reducing the number of keys in the data by recoding the appropriate variables. Recoding reduces the number of necessary suppressions as well as the computation time needed for suppression. Suppression of values means that values of a variable are replaced by a missing value (NA in R). 

### Microaggregation

Microaggregation is most suitable for continuous variables, but can be extended in some cases to categorical variables. [14] It is most useful where confidentiality rules have been predetermined (e.g., a certain threshold for 𝑘
-anonymity has been set) that permit the release of data only if combinations of variables are shared by more than a predetermined threshold number of respondents (𝑘). The first step in microaggregation is the formation of small groups of individuals that are homogeneous with respect to the values of selected variables, such as groups with similar income or age. Subsequently, the values of the selected variables of all group members are replaced with a common value, e.g., the mean of that group. Microaggregation methods differ with respect to (i) how the homogeneity of groups is defined, (ii) the algorithms used to find homogeneous groups, and (iii) the determination of replacement values. In practice, microaggregation works best when the values of the variables in the groups are more homogeneous. When this is the case, then the information loss due to replacing values with common values for the group will be smaller than in cases where groups are less homogeneous.

### Noise addition
Noise addition, or noise masking, means adding or subtracting (small) values to the original values of a variable, and is most suited to protect continuous variables (see Bran02 for an overview). Noise addition can prevent exact matching of continuous variables. The advantages of noise addition are that the noise is typically continuous with mean zero, and exact matching with external files will not be possible. Depending on the magnitude of noise added, however, approximate interval matching might still be possible.

When using noise addition to protect data, it is important to consider the type of data, the intended use of the data and the properties of the data before and after noise addition, i.e., the distribution – particularly the mean – covariance and correlation between the perturbed and original datasets.

### k-Anonymity  
k-Anonymity is a privacy-preserving technique used in data anonymization to ensure that an individual's record cannot be distinguished from at least \( k-1 \) other records in a dataset. It achieves this by generalizing or suppressing identifying attributes so that each combination of quasi-identifiers appears in at least \( k \) instances. This reduces the risk of re-identification by making it difficult to single out any one individual based on available attributes. However, while k-anonymity protects against identity disclosure, it does not necessarily prevent attribute disclosure, as all individuals in the same group might share sensitive information.  

### l-Diversity  
l-Diversity extends k-anonymity by addressing its vulnerability to attribute disclosure. It ensures that within each anonymized group, there are at least \( l \) distinct values for any sensitive attribute, reducing the risk of inferring private information. This technique prevents an adversary from confidently predicting an individual's sensitive attribute even if they identify the group. However, l-diversity may be ineffective in cases where the distribution of sensitive values lacks sufficient variation, leading to a risk of disclosure through semantic similarity.  



## Hands-on Exercises with R : Basic sdcMicro Usage

Let's explore practical implementations of anonymization techniques using R packages.

###  Data Generation

```R
# Install and load the sdcMicro package
# install.packages("sdcMicro")
library(sdcMicro)

# Create sample health dataset
set.seed(123)
n <- 10000
health_data <- data.frame(
  id = 1:n,
  age = sample(18:90, n, replace = TRUE),
  gender = sample(c("M","F","NB","QR","FLD"), n, replace = TRUE,prob=c(0.49, 0.49, 0.01, 0.005, 0.005)),
  postal_code = sample(paste0("PC-",100:130), n, replace = TRUE),
  income = rlnorm(n, meanlog = 10, sdlog = 0.5),
  health_score = rnorm(n, mean = 50, sd = 10),
  hiv_status = rbinom(n, 1, 0.03)
)

```

###  Sdc Object

```
sdc <- createSdcObj(
  dat = health_data,
  keyVars = c("age","gender", "postal_code"),  # Quasi-identifiers
  numVars = c( "income", "health_score"),        # Sensitive numericals
  weightVar = NULL,
  hhId = NULL,                       
  sensibleVar = "hiv_status"                  
)

print(sdc, "risk") 
```

###  Group And Rename

```
sdc <- groupAndRename(sdc, var="gender", before=c("NB","QR","FLD"), after=c("Other"))


print(sdc, "risk") 
data_modified_1=extractManipData(sdc)
```
### Global Recodeing
```
sdc <- globalRecode(sdc, column = 'age', breaks = 10 * c(1:9))
print(sdc, "risk") 

data_modified_2=extractManipData(sdc)
```
### Top Bottom Coding
```
hist(health_data$health_score)

sdc <- topBotCoding(obj = sdc, value = 70, replacement = 70,kind = 'top', column = 'health_score')

sdc <- topBotCoding(obj = sdc, value = 30, replacement = 30, kind = 'bottom', column = 'health_score')

print(sdc, "risk") 
```


### Local Suppression

```
sdc <- localSuppression(sdc,k = 5)                # 5% risk threshold
print(sdc, "risk") 
data_modified_3=extractManipData(sdc)


table(health_data$gender,health_data$postal_code)
table(data2$gender,data2$postal_code)
```

### Microaggregation
```
sdc <-microaggregation(sdc, method = "mdav", variables=c("income","health_score"), aggr = 3)
#data2=extractManipData(sdc)
print(sdc, "risk") 

data_modified_4=extractManipData(sdc)
```


### Add Noise


```
sdc <- addNoise(sdc, noise = 0.1)  

print(sdc, "risk") 

measure_risk(sdc)
data_modified_5=extractManipData(sdc)

```


### Using sdcMicro's GUI

```R
# Launch the interactive GUI for sdcMicro
library(sdcMicro)
sdcApp()

# In the GUI you can:
# 1. Upload your health dataset
# 2. Select variables to anonymize
# 3. Apply various methods interactively
# 4. Visualize risk before and after
# 5. Export anonymized data
```



### Utility Analysis

```
# Visualize impact of noise addition
original <- health_data$income
anonymized <- extractManipData(sdc)$income
correlation <- cor(original, anonymized)




ggplot() +
  geom_density(aes(x = original), fill = "blue", alpha = 0.5) +
  geom_density(aes(x = anonymized), fill = "red", alpha = 0.5) +
  labs(title = "Income Distribution Before/After Anonymization")
```


```
# Visualize impact of local suppression 
PlotXTabs2(data_modified_4, hiv_status, gender, plottype = "percent")
PlotXTabs2(health_data, hiv_status, gender, plottype = "percent") 

table(health_data$hiv_status,health_data$gender)

table(data_modified_4$hiv_status, data_modified_4$postal_code)


PlotXTabs2(data_modified_4, postal_code, hiv_status, plottype = "percent",x.axis.orientation="vertical")


table(health_data$hiv_status,health_data$postal_code)
PlotXTabs2(health_data, postal_code, hiv_status, plottype = "percent",x.axis.orientation="vertical")
```


```
# Visualize impact microagression
data_modified_4 %>% group_by(hiv_status) %>% 
  summarise(mean_age=mean(age, na.rm = T)*10, .groups = 'drop') %>% ggplot( aes(x = hiv_status, y = mean_age, fill = hiv_status)) + geom_bar(stat = "identity") 
  
health_data %>% group_by(hiv_status) %>%  summarise(mean_age=mean(age, na.rm = T)*10, .groups = 'drop')  %>% ggplot( aes(x = hiv_status, y = mean_age, fill = hiv_status)) + geom_bar(stat = "identity")

data_modified_4 %>% group_by(hiv_status) %>% 
  summarise(mean_income=mean(income, na.rm = T)*10, .groups = 'drop') %>% ggplot( aes(x = hiv_status, y = mean_income, fill = hiv_status)) + geom_bar(stat = "identity")

health_data %>% group_by(hiv_status) %>% 
  summarise(mean_income=mean(income, na.rm = T)*10, .groups = 'drop') %>% ggplot( aes(x = hiv_status, y = mean_income, fill = hiv_status)) + geom_bar(stat = "identity")

data_modified_4 %>% group_by(hiv_status) %>% 
  summarise(mean_health_score=mean(health_score, na.rm = T)*10, .groups = 'drop') %>% ggplot( aes(x = hiv_status, y = mean_health_score, fill = hiv_status)) + geom_bar(stat = "identity")


health_data %>% group_by(hiv_status) %>% 
  summarise(mean_health_score=mean(health_score, na.rm = T)*10, .groups = 'drop') %>% ggplot( aes(x = hiv_status, y = mean_health_score, fill = hiv_status)) + geom_bar(stat = "identity")
```

This R code provides a comprehensive hands-on example of how to anonymize sensitive data using the `sdcMicro` package in R. Here's a **step-by-step breakdown** of what each part does:

---

### ✅ **1. Data Generation**

```r
set.seed(123)
n <- 10000
health_data <- data.frame(
  ...
)
```

- **Purpose:** Simulate a synthetic health dataset with 10,000 records.
- **Variables created:**
  - `id`: Unique identifier.
  - `age`: Random age between 18 and 90.
  - `gender`: Multiclass gender distribution with rare categories (`NB`, `QR`, `FLD`).
  - `postal_code`: Simulated postal codes.
  - `income`: Log-normal distributed income.
  - `health_score`: Normally distributed health metric.
  - `hiv_status`: Binary sensitive variable (1 = positive, 3% prevalence).

---

### ✅ **2. Creating an SDC Object**

```r
sdc <- createSdcObj(...)
```

- **Purpose:** Wrap the dataset in an `sdcMicro` object to perform anonymization.
- **Key parameters:**
  - `keyVars`: Quasi-identifiers (can lead to re-identification).
  - `numVars`: Numerical sensitive data.
  - `sensibleVar`: Truly sensitive data (`hiv_status`).

---

### ✅ **3. Group and Rename**

```r
sdc <- groupAndRename(...)
```

- **Purpose:** Combine rare gender categories into a single "Other" category to reduce re-identification risk.

---

### ✅ **4. Global Recoding**

```r
sdc <- globalRecode(...)
```

- **Purpose:** Bucket `age` into broader 10-year intervals to reduce identifiability.

---

### ✅ **5. Top and Bottom Coding**

```r
sdc <- topBotCoding(...)
```

- **Purpose:** Limit extreme values in `health_score` to reduce outlier disclosure risk.
  - Top code: All values >70 set to 70.
  - Bottom code: All values <30 set to 30.

---

### ✅ **6. Local Suppression**

```r
sdc <- localSuppression(sdc, k = 5)
```

- **Purpose:** Suppresses values in quasi-identifiers to ensure **k-anonymity** (k=5).
- **Example:** If fewer than 5 records share the same quasi-identifier values, suppress some of them.

---

### ✅ **7. Microaggregation**

```r
sdc <- microaggregation(...)
```

- **Purpose:** Group and average sensitive numerical data (e.g., income, health_score) to prevent re-identification.
- **Method:** `mdav` (Maximum Distance to Average Vector).
- **Group size:** Minimum 3 records per group (`aggr = 3`).

---

### ✅ **8. Add Noise**

```r
sdc <- addNoise(sdc, noise = 0.1)
```

- **Purpose:** Add small random noise (10%) to numerical variables to protect individual data points further.

---

### ✅ **9. Utility Analysis**

#### 🔹 **Correlation & Distribution Plot**

```r
cor(original, anonymized)
```

- **Measures** the correlation between original and anonymized `income`.

```r
ggplot(...) + geom_density(...)
```

- **Visualizes** how the income distribution changed due to anonymization.

#### 🔹 **Cross-tabulation and Bar Charts**

```r
PlotXTabs2(...)
```

- **Visualizes** relationships between variables (e.g., gender vs HIV status) before and after anonymization.

```r
table(...)
```

- Compares frequency tables pre- and post-anonymization.

#### 🔹 **Microaggregation Impact on Means**

```r
summarise(mean_income=..., ...)
```

- Compares **mean values** for age, income, and health score across HIV status before/after anonymization.

---

