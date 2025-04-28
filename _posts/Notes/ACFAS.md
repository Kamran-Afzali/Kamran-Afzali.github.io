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

Meanwhile, the increased adoption of open-source software in healthcare settings, particularly R, has democratized access to sophisticated anonymization tools.


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










# Historical Development of Data Anonymization

A comprehensive analysis of the evolution of data anonymization techniques, regulatory frameworks, and future directions in privacy protection.

## Slide 1: Title and Introduction

- **Definition**: Data anonymization involves modifying datasets to prevent the identification of individuals, ensuring privacy while retaining data utility.
- **Importance**: Balancing data utility with privacy protection is crucial, especially in health data management.
- **Scope**: This presentation traces the historical trajectory of data anonymization, highlighting technological, regulatory, and methodological developments.
- The field of data anonymization has evolved dramatically over the past three decades, transitioning from simple identifier removal to sophisticated mathematical frameworks that provide formal privacy guarantees. This presentation traces this evolution and examines how technical innovations have intersected with regulatory developments to shape modern privacy protection approaches.


- **Notable Cases**:
  - 1997: Latanya Sweeney demonstrated re-identification of anonymized health records using voter registration data.
  - 2008: Narayanan and Shmatikov re-identified Netflix users by correlating anonymized data with IMDb ratings.
- **Implications**: These cases underscored the inadequacy of simple anonymization techniques and the need for more robust methods. 

## Slide 2: Early Approaches (Pre-2000s)

**Initial Anonymization Strategies**
- Simple removal of direct identifiers (names, SSNs, addresses)
- HIPAA Safe Harbor Method (1996): First formal approach requiring removal of 18 specific identifiers
- Growing recognition of insufficiency as re-identification attacks emerged
- Focus primarily on removing "obvious" identifiers

During this period, data holders operated under the assumption that removing explicit identifiers was sufficient to protect privacy. However, researchers soon demonstrated that combining remaining data fields with external datasets could lead to successful re-identification attacks. As one researcher noted, "it is not enough to remove personally identifying characteristics such as names or addresses". To ensure true anonymity.

## Slide 3: K-Anonymity Breakthrough (2000s)

**Formalizing Privacy Protection**
- Introduced by Latanya Sweeney in 2002
- Definition: "A release provides k-anonymity protection if the information for each person contained in the release cannot be distinguished from at least k-1 individuals"
- Demonstrated systematic vulnerabilities in naive approaches
- **Extensions**:
  - **L-Diversity**: Addresses homogeneity attacks by ensuring diversity in sensitive attributes.
  - **T-Closeness**: Ensures the distribution of sensitive attributes in any group is close to the overall distribution.
- **Datafly Algorithm**: Developed by Sweeney, it automates generalization and suppression to achieve k-anonymity. citeturn0search16

Sweeney's seminal work represented the first comprehensive mathematical framework for understanding privacy risks. K-anonymity addressed the fundamental problem that uniqueness within datasets creates vulnerability, establishing that each record should be indistinguishable from at least k-1 other records. This approach fundamentally changed how organizations conceptualized privacy protection in structured data.

## Slide 4: Differential Privacy (2006-2014)

**Mathematical Privacy Guarantees**
- Developed by cryptographer Cynthia Dwork and colleagues
- Goal: "To learn as much as possible about a specific group of people from an existing dataset, without learning anything about the individuals in that group"[5]
- Innovation: Adding calibrated "noise" to data responses
- Considered "The new gold standard of privacy protection"
- **Concept**: Proposed by Dwork et al. in 2006, differential privacy adds calibrated noise to data queries, providing strong privacy guarantees. citeturn0search15
- **Applications**:
  - U.S. Census Bureau (2020): Implemented differential privacy in data releases.
  - Apple (2016): Utilized differential privacy to collect user data while preserving privacy. 
- **Significance**: Offers a mathematically rigorous approach to privacy, balancing data utility and individual confidentiality. Differential privacy represented a paradigm shift by providing mathematical privacy guarantees rather than just practical techniques. By introducing controlled randomness or "noise" into query responses, differential privacy ensures that the presence or absence of any individual record doesn't significantly affect analysis results. This approach has proven particularly valuable for machine learning applications with sensitive data.

## Slide 5: Regulatory Evolution

**Key Privacy Milestones**
- 1996: HIPAA Safe Harbor established basic de-identification standards
- 2002: K-Anonymity formalization by Sweeney
- 2006-2014: Differential Privacy development by Dwork et al.
- 2018: General Data Protection Regulation (GDPR) Article 29 clarified pseudonymization vs anonymization thresholds
- 2023: European Health Data Space (EHDS) implementation mandated privacy-by-design
- **ICO Guidelines**: The UK's Information Commissioner's Office provides comprehensive guidance on effective anonymization practices.
- **Impact**: These frameworks have standardized anonymization practices and heightened awareness of privacy risks.

Regulatory frameworks have evolved alongside technical innovations, with each new generation of regulations incorporating lessons from privacy research. The progression from HIPAA's prescriptive approach to GDPR's risk-based framework reflects growing recognition that privacy protection requires both technical and governance solutions working in tandem.


### **Slide 6: European Health Data Space (EHDS) Regulation**

- **Overview**: Adopted in March 2025, EHDS aims to facilitate secure and standardized sharing of health data across EU member states.
- **Key Provisions**:
  - Patients can restrict access to their electronic health data.
  - Secondary use of health data requires permits and is limited to specific purposes.
  - Data processing must occur in secure environments, with strict prohibitions on re-identification. 
- **Timeline**: Full implementation is phased, with significant milestones set for 2027, 2029, 2031, and 2034.

## Slide 7: Pseudonymization vs. Anonymization

**Distinguishing Privacy Approaches**
- GDPR explicitly introduced pseudonymization in EU data protection laws
- Pseudonymization: "A technique used to reduce the chance that personal data records and identifiers lead to identification"
- Unlike anonymization, pseudonymized data remains subject to GDPR protections
- GDPR Recital 29: Offers incentives to controllers to use pseudonymization
- GDPR Recital 75: Warns about "unauthorized reversal of pseudonymization"

The GDPR made a crucial distinction between anonymization (irreversible de-identification) and pseudonymization (potentially reversible de-identification). This distinction has significant legal implications as pseudonymized data still falls under GDPR's scope, while properly anonymized data does not. Understanding this distinction has become essential for organizations managing sensitive data.

---

### **Slide 8: Open-Source Tools and Democratization**

- **R Programming Language**: Widely adopted in healthcare for statistical analysis and data anonymization.
- **Tools**:
  - **sdcMicro**: Provides methods for statistical disclosure control.
  - **ARX**: Offers a comprehensive suite for anonymizing sensitive personal data.
- **Impact**: These tools have made advanced anonymization techniques accessible to a broader audience, promoting best practices in data privacy.

---

### **Slide 9: Ongoing Challenges and Considerations**

- **Privacy vs. Utility**: Achieving a balance between data utility and privacy remains a central challenge.
- **Technological Advances**: Emerging technologies, such as AI, pose new risks for re-identification.
- **Regulatory Evolution**: Continuous updates to legal frameworks are necessary to address evolving privacy concerns.
- **Ethical Implications**: Ensuring ethical use of anonymized data is paramount, particularly in sensitive sectors like healthcare.

---



## Slide 10: EHDS and Future Directions

**Looking Forward**
- European Health Data Space (2023): Represents "a sea change in how health data is managed and shared"
- Growing recognition that effective anonymization requires:
  - Technical solutions (differential privacy, k-anonymity)
  - Governance frameworks and policies
- Democratization of tools: Increased adoption of open-source software (R) in healthcare
- Emerging approaches: Privacy-preserving machine learning, federated learning

The European Health Data Space exemplifies the future direction of health data management, emphasizing both technical privacy protections and governance frameworks. Meanwhile, the democratization of anonymization tools through open-source software has made sophisticated techniques more accessible. These developments point toward an integrated approach where privacy is built into systems from inception.
- **Future Outlook**:
  - Integration of privacy-preserving technologies in data analysis workflows.
  - Development of standardized metrics to assess anonymization effectiveness.
  - Ongoing collaboration between technologists, policymakers, and ethicists to navigate the complexities of data privacy.
- **Final Thought**: As data continues to drive innovation, robust anonymization practices are essential to protect individual privacy and maintain public trust.
---  
## Slide 11: Best Practices and Conclusion

**Key Takeaways**
- Anonymization as a continuous process, not a one-time action
- Multi-layered approach combining multiple techniques
- Early planning essential (ideally in data management plan)
- Assessment of both direct and indirect identifiers
- Recognition that no method removes all re-identification risk
- Goal: Reduce risk to "low and acceptable level"

The field of data anonymization has evolved from simplistic approaches to sophisticated frameworks that balance utility and privacy. Both HHS's Office for Civil Rights and privacy researchers acknowledge that while perfect anonymization may be unattainable, well-implemented techniques can reduce re-identification risk to acceptably low levels. The future lies in privacy-preserving techniques that enable analysis without compromising individual privacy.

Of course! Here’s a clear, **7-slide** breakdown for your academic presentation on the **Main Techniques of Data Anonymization** based on the information you gave, structured to suit a professional, academic audience.


---  
## Slide 12: R Packages for Data Anonymization

R programming language, used for data analysis and statistics, offers several packages that can assist in implementing data anonymization techniques. Let's explore some of these packages and their functionalities:

### `anonymizer`

The `anonymizer` package provides a set of functions for quickly and easily anonymizing data containing Personally Identifiable Information (PII). It uses a combination of salting and hashing to protect sensitive information.

Key functions in the anonymizer package include:

- `salt`: Adds a random string to the input data before hashing.
- `unsalt`: Removes the salt from salted data.
- `hash`: Applies a hashing algorithm to the input data.
- `anonymize`: Combines salting and hashing to anonymize the input data.

---  
## Slide 13: `deident`

The `deident` package in R provides a comprehensive tool for the replicable removal of personally identifiable data from datasets. It offers several methods tailored to different data types.  

Key features of the `deident` package include:

- **Pseudonymization**: Consistent replacement of a string with a random string.
- **Encryption**: Consistent replacement of a string with an alphanumeric hash using an encryption key and salt.
- **Shuffling**: Replacement of columns by a random sample without replacement.
- **Blurring**: Aggregation of numeric or categorical data according to specified rules.
- **Perturbation**: Addition of user-defined random noise to a numeric variable. 

---  
## Slide 14: `sdcMicro`

The `sdcMicro` package is a comprehensive tool for statistical disclosure control in R. It offers a wide range of methods for anonymizing microdata, including various risk assessment and anonymization techniques.

Some of the key features of sdcMicro include:

- Risk assessment for categorical and continuous key variables
- Local suppression and global recoding
- Microaggregation for continuous variables
- PRAM (Post Randomization Method) for categorical variables


---  
## Slide 15: SDC methods 


### non-perturbative and perturbative 

- Non-perturbative methods reduce the detail in the data by generalization or suppression of certain values (i.e., masking) without distorting the data structure.

- Perturbative methods do not suppress values in the dataset but perturb (i.e., alter) values to limit disclosure risk by creating uncertainty around the true values.

- Both non-perturbative and perturbative methods can be used for categorical and continuous variables.

### Probabilistic and deterministic SDC methods

- Probabilistic methods depend on a probability mechanism or a random number-generating mechanism. Every time a probabilistic method is used, a different outcome is generated. For these methods it is often recommended that a seed be set for the random number generator if you want to produce replicable results.

- Deterministic methods follow a certain algorithm and produce the same results if applied repeatedly to the same data with the same set of parameters.

---  
## Slide 16: Recoding


### Global recoding

Global recoding combines several categories of a categorical variable or constructs intervals for continuous variables. This reduces the number of categories available in the data and potentially the disclosure risk, especially for categories with few observations, but also, importantly, it reduces the level of detail of information available to the analyst. 


### Top and bottom coding

Top and bottom coding are similar to global recoding, but instead of recoding all values, only the top and/or bottom values of the distribution or categories are recoded. This can be applied only to ordinal categorical variables and (semi-)continuous variables, since the values have to be at least ordered. Top and bottom coding is especially useful if the bulk of the values lies in the center of the distribution with the peripheral categories having only few observations (outliers).

---  
## Slide 17: More advanced techniques

### Local suppression

It is common in surveys to encounter values for certain variables or combinations of quasi-identifiers (keys) that are shared by very few individuals. When this occurs, the risk of re-identification for those respondents is higher than the rest of the respondents (see the Section k-anonymity). Often local suppression is used after reducing the number of keys in the data by recoding the appropriate variables. Recoding reduces the number of necessary suppressions as well as the computation time needed for suppression. Suppression of values means that values of a variable are replaced by a missing value (NA in R). 

### Microaggregation

Microaggregation is most suitable for continuous variables, but can be extended in some cases to categorical variables. [14] It is most useful where confidentiality rules have been predetermined (e.g., a certain threshold for 𝑘
-anonymity has been set) that permit the release of data only if combinations of variables are shared by more than a predetermined threshold number of respondents (𝑘). The first step in microaggregation is the formation of small groups of individuals that are homogeneous with respect to the values of selected variables, such as groups with similar income or age. Subsequently, the values of the selected variables of all group members are replaced with a common value, e.g., the mean of that group. Microaggregation methods differ with respect to (i) how the homogeneity of groups is defined, (ii) the algorithms used to find homogeneous groups, and (iii) the determination of replacement values. In practice, microaggregation works best when the values of the variables in the groups are more homogeneous. When this is the case, then the information loss due to replacing values with common values for the group will be smaller than in cases where groups are less homogeneous.

---  
## Slide 18: Noise addition

### Noise addition
Noise addition, or noise masking, means adding or subtracting (small) values to the original values of a variable, and is most suited to protect continuous variables (see Bran02 for an overview). Noise addition can prevent exact matching of continuous variables. The advantages of noise addition are that the noise is typically continuous with mean zero, and exact matching with external files will not be possible. Depending on the magnitude of noise added, however, approximate interval matching might still be possible.

When using noise addition to protect data, it is important to consider the type of data, the intended use of the data and the properties of the data before and after noise addition, i.e., the distribution – particularly the mean – covariance and correlation between the perturbed and original datasets.

---  
## Slide 19: k-Anonymity and l-Diversity

### k-Anonymity  
k-Anonymity is a privacy-preserving technique used in data anonymization to ensure that an individual's record cannot be distinguished from at least \( k-1 \) other records in a dataset. It achieves this by generalizing or suppressing identifying attributes so that each combination of quasi-identifiers appears in at least \( k \) instances. This reduces the risk of re-identification by making it difficult to single out any one individual based on available attributes. However, while k-anonymity protects against identity disclosure, it does not necessarily prevent attribute disclosure, as all individuals in the same group might share sensitive information.  

### l-Diversity  
l-Diversity extends k-anonymity by addressing its vulnerability to attribute disclosure. It ensures that within each anonymized group, there are at least \( l \) distinct values for any sensitive attribute, reducing the risk of inferring private information. This technique prevents an adversary from confidently predicting an individual's sensitive attribute even if they identify the group. However, l-diversity may be ineffective in cases where the distribution of sensitive values lacks sufficient variation, leading to a risk of disclosure through semantic similarity.  

---

## Hands-on Exercises with R : Basic sdcMicro Usage

---
### Slide 20: **1. Data Generation**



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

### Slide 21: **2. Creating an SDC Object**

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


- **Purpose:** Wrap the dataset in an `sdcMicro` object to perform anonymization.
- **Key parameters:**
  - `keyVars`: Quasi-identifiers (can lead to re-identification).
  - `numVars`: Numerical sensitive data.
  - `sensibleVar`: Truly sensitive data (`hiv_status`).

---

### Slide 22: **3. Group and Rename**

```
sdc <- groupAndRename(sdc, var="gender", before=c("NB","QR","FLD"), after=c("Other"))


print(sdc, "risk") 
data_modified_1=extractManipData(sdc)
```
- **Purpose:** Combine rare gender categories into a single "Other" category to reduce re-identification risk.

---

### Slide 23: **4. Global Recoding**

```
sdc <- globalRecode(sdc, column = 'age', breaks = 10 * c(1:9))
print(sdc, "risk") 

data_modified_2=extractManipData(sdc)
```

- **Purpose:** Bucket `age` into broader 10-year intervals to reduce identifiability.

---

### Slide 24: **5. Top and Bottom Coding**

```
hist(health_data$health_score)

sdc <- topBotCoding(obj = sdc, value = 70, replacement = 70,kind = 'top', column = 'health_score')

sdc <- topBotCoding(obj = sdc, value = 30, replacement = 30, kind = 'bottom', column = 'health_score')

print(sdc, "risk") 
```
---

### Slide 25: **6. Local Suppression**

```r
sdc <- localSuppression(sdc, k = 5)
```

- **Purpose:** Suppresses values in quasi-identifiers to ensure **k-anonymity** (k=5).
- **Example:** If fewer than 5 records share the same quasi-identifier values, suppress some of them.

---

### Slide 26: **7. Microaggregation**

```r
sdc <- microaggregation(...)
```

- **Purpose:** Group and average sensitive numerical data (e.g., income, health_score) to prevent re-identification.
- **Method:** `mdav` (Maximum Distance to Average Vector).
- **Group size:** Minimum 3 records per group (`aggr = 3`).

---

### Slide 27: **8. Add Noise**

```r
sdc <- addNoise(sdc, noise = 0.1)
```

- **Purpose:** Add small random noise (10%) to numerical variables to protect individual data points further.

---

###  **9. Utility Analysis**

---
####  Slide 28: **Correlation & Distribution Plot**

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

- **Measures** the correlation between original and anonymized `income`.
- **Visualizes** how the income distribution changed due to anonymization.

#### Slide 29: **Cross-tabulation and Bar Charts**




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

- **Visualizes** relationships between variables (e.g., gender vs HIV status) before and after anonymization.
- Compares frequency tables pre- and post-anonymization.

#### Slide 30:  **Microaggregation Impact on Means**

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


- Compares **mean values** for age, income, and health score across HIV status before/after anonymization.

---









https://sdcpractice.readthedocs.io/en/latest/anon_methods.html#top-and-bottom-coding
