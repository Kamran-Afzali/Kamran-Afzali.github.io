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

### Local suppression

It is common in surveys to encounter values for certain variables or combinations of quasi-identifiers (keys) that are shared by very few individuals. When this occurs, the risk of re-identification for those respondents is higher than the rest of the respondents (see the Section k-anonymity). Often local suppression is used after reducing the number of keys in the data by recoding the appropriate variables. Recoding reduces the number of necessary suppressions as well as the computation time needed for suppression. Suppression of values means that values of a variable are replaced by a missing value (NA in R). 

### Microaggregation

Microaggregation is most suitable for continuous variables, but can be extended in some cases to categorical variables. [14] It is most useful where confidentiality rules have been predetermined (e.g., a certain threshold for 𝑘
-anonymity has been set) that permit the release of data only if combinations of variables are shared by more than a predetermined threshold number of respondents (𝑘). The first step in microaggregation is the formation of small groups of individuals that are homogeneous with respect to the values of selected variables, such as groups with similar income or age. Subsequently, the values of the selected variables of all group members are replaced with a common value, e.g., the mean of that group. Microaggregation methods differ with respect to (i) how the homogeneity of groups is defined, (ii) the algorithms used to find homogeneous groups, and (iii) the determination of replacement values. In practice, microaggregation works best when the values of the variables in the groups are more homogeneous. When this is the case, then the information loss due to replacing values with common values for the group will be smaller than in cases where groups are less homogeneous.

### Noise addition
Noise addition, or noise masking, means adding or subtracting (small) values to the original values of a variable, and is most suited to protect continuous variables (see Bran02 for an overview). Noise addition can prevent exact matching of continuous variables. The advantages of noise addition are that the noise is typically continuous with mean zero, and exact matching with external files will not be possible. Depending on the magnitude of noise added, however, approximate interval matching might still be possible.

When using noise addition to protect data, it is important to consider the type of data, the intended use of the data and the properties of the data before and after noise addition, i.e., the distribution – particularly the mean – covariance and correlation between the perturbed and original datasets.



## Hands-on Exercises with R

Let's explore practical implementations of anonymization techniques using R packages.

### Exercise 1: Basic sdcMicro Usage

```R
# Install and load the sdcMicro package
# install.packages("sdcMicro")
library(sdcMicro)

# Create sample health dataset
set.seed(123)
health_data <- data.frame(
  patient_id = 1:10,
  age = sample(20:80, 10, replace = TRUE),
  gender = sample(c("M", "F"), 10, replace = TRUE),
  zipcode = sample(10000:99999, 10),
  diagnosis = sample(c("Diabetes", "Hypertension", "Asthma", "Arthritis"), 10, replace = TRUE),
  blood_pressure = sample(110:180, 10)
)

health_data %
  add_pseudonymize("patient_id") %>%
  add_blur_age("age", width = 10) %>%
  add_suppress("zipcode", start = 4) %>%
  add_perturb("blood_pressure", noise = 5, method = "additive") %>%
  add_shuffle("diagnosis")

# Apply the pipeline to the data
anonymized_data <- apply_deident(health_data, deident_pipeline)

# View the result
print(anonymized_data)

# Save the pipeline for reuse with similar datasets
# save_deident_plan(deident_pipeline, "health_anonymization_plan.yaml")
```

### Exercise 3: Using sdcMicro's GUI

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

**k-Anonymity**  
k-Anonymity is a privacy-preserving technique used in data anonymization to ensure that an individual's record cannot be distinguished from at least \( k-1 \) other records in a dataset. It achieves this by generalizing or suppressing identifying attributes so that each combination of quasi-identifiers appears in at least \( k \) instances. This reduces the risk of re-identification by making it difficult to single out any one individual based on available attributes. However, while k-anonymity protects against identity disclosure, it does not necessarily prevent attribute disclosure, as all individuals in the same group might share sensitive information.  

**l-Diversity**  
l-Diversity extends k-anonymity by addressing its vulnerability to attribute disclosure. It ensures that within each anonymized group, there are at least \( l \) distinct values for any sensitive attribute, reducing the risk of inferring private information. This technique prevents an adversary from confidently predicting an individual's sensitive attribute even if they identify the group. However, l-diversity may be ineffective in cases where the distribution of sensitive values lacks sufficient variation, leading to a risk of disclosure through semantic similarity.  


Here’s how you can implement **k-Anonymity and l-Diversity** in R using the `sdcMicro` package.  

---

### **1. k-Anonymity Implementation in R**
The `sdcMicro` package provides tools for applying **k-anonymity** by generalizing or suppressing quasi-identifiers.

#### **Code:**
```r
# Install and load the sdcMicro package
install.packages("sdcMicro")
library(sdcMicro)

# Sample dataset (example of microdata)
data <- data.frame(
  Age = c(25, 32, 40, 22, 35, 40, 29, 40),
  ZipCode = c("12345", "12345", "12346", "12346", "12347", "12345", "12346", "12347"),
  Income = c(50000, 60000, 55000, 62000, 58000, 55000, 53000, 60000),
  Disease = c("Diabetes", "Cancer", "Heart Disease", "Diabetes", "Cancer", "Diabetes", "Heart Disease", "Cancer")
)

# Define quasi-identifiers
quasi_identifiers <- c("Age", "ZipCode")

# Create an SDC object
sdc <- createSdcObj(dat = data, keyVars = quasi_identifiers)

# Apply k-anonymity (local suppression)
sdc <- localSuppression(sdc, k = 2)  # Ensures each group has at least 2 individuals

# Extract anonymized data
anon_data <- extractManipData(sdc)
print(anon_data)
```

---

### **2. l-Diversity Implementation in R**
**l-Diversity** ensures that each anonymized group has at least `l` distinct sensitive values (e.g., Disease).

#### **Code:**
```r
# Load necessary library
library(sdcMicro)

# Define sensitive attribute
sensitive_vars <- c("Disease")

# Apply l-diversity using microaggregation
sdc <- createSdcObj(dat = data, keyVars = quasi_identifiers, numVars = sensitive_vars)
sdc <- microaggregation(sdc, method = "mdav", aggr = 2) # Enforces diversity by aggregation

# Extract anonymized data
anon_data <- extractManipData(sdc)
print(anon_data)
```

