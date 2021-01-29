

In the context of healthcare data where governance dimensions such as ethics and security can be unclear and prone to interpretations concepts of privacy and anonymity (reffering to GDPR in the EU, HIPAA in the US, PIPEDA in Canada) has now become part of business-as-usual considerations. 


## General Data Protection Regulation (GDPR)

To protect users’ personally identifiable information (PII-name, emails, physical address, IP address, health information, income, etc) European Union  has pput in place GDPR regulation that hold businesses to a higher standard when it comes to how they collect, store, and use the data. The ultimate goal of GDPR is to challenge the data privacy approach of organizations across the world to give EU citizens control over their personal data . 

## Health Insurance Portability and Accountability Act (HIPAA)

HIPAA came into force in 1996. It was designed to make health insurance coverage fairer for employees moving between jobs. It also sought to reduce the cost of health care by bringing in a more standardised process for financial transactions and admin. Through the “Privacy Rule” contained within the legislation, HIPAA also sets out requirements designed to protect sensitive personal health information (PHI). As well as setting out data governance procedures in areas such as billing and admin, this Rule sets out the right of patients to receive copies of PHI from organisations. It also stipulates the circumstances under which healthcare providers may disclose this information to third parties – and when express patient permission is needed for this.

## The Personal Information Protection and Electronic Documents Act (PIPEDA)

Organizations covered by PIPEDA must generally obtain an individual's consent when they collect, use or disclose that individual's personal information. People have the right to access their personal information held by an organization. They also have the right to challenge its accuracy. Personal information can only be used for the purposes for which it was collected. If an organization is going to use it for another purpose, they must obtain consent again. Personal information must be protected by appropriate safeguards. Under PIPEDA, personal information includes any factual or subjective information, recorded or not, about an identifiable individual. This includes information in any form, such as:

+	age, name, ID numbers, income, ethnic origin, or blood type
+	opinions, evaluations, comments, social status, or disciplinary actions
+	employee files, credit records, loan records, medical records, existence of a dispute between a consumer and a merchant, intentions (for example, to acquire goods or services, or change jobs).

## Deidentification

Deidentification is the process of removing personally identifiable information (PII) from data. PII can include items such as banking information, Social Security numbers, and addresses. This topic is valuable because data deidentification protects the privacy of individuals and is important in many industries, including but not limited to health care, banking, pharmaceuticals, and education. Deidentification ensures compliance to ethical and legal standards of data collection and analysis.

## Risk of re-identification and K-anonymity
A shared database provides K-anonymity protection if the information about each person in the release cannot be distinguished from at least k-1 individuals whose information is also included in the release. 

## Automated De-Identification Tools

Several automated de-identification programs have been developed in recent years, which can be grouped into three categories:

+ Tools for efficiently handling direct identifiers in record-level data,
+ Tools for reducing the risk of re-identification from indirect identifiers in record-level data
+ Tools for handling aggregate data sets.


### Package ‘detector’
detector makes detecting data containing Personally Identifiable Information (PII) quick, easy, and scalable. It provides high-level functions that can take vectors and data.frames and return important summary statistics in a convenient data.frame. Once complete, detector will be able to detect the following types of PII.

```r
if (packageVersion("devtools") < 1.6) {
  install.packages("devtools")
}
devtools::install_github("paulhendricks/detector")


library(dplyr, warn.conflicts = FALSE)
library(generator)
n <- 6
set.seed(1)
ashley_madison <- 
  data.frame(name = r_full_names(n), 
             snn = r_national_identification_numbers(n), 
             dob = r_date_of_births(n), 
             email = r_email_addresses(n), 
             ip = r_ipv4_addresses(n), 
             phone = r_phone_numbers(n), 
             credit_card = r_credit_card_numbers(n), 
             lat = r_latitudes(n), 
             lon = r_longitudes(n), 
             stringsAsFactors = FALSE)
knitr::kable(ashley_madison, format = "markdown")

library(detector)
ashley_madison %>% 
  detect %>% 
  knitr::kable(format = "markdown")
```

### Package ‘anonymizer’
Package ‘anonymizer’ uses a mix of methods to replace PII with a random unique identifier (Hendricks, 2015). The package can be installed from CRAN or from GitHub depending on your version of R.

```r
ashley_madison[] <- lapply(ashley_madison, anonymize, .algo = "crc32")
ashley_madison %>% 
  knitr::kable(format = "markdown")
```
### Package ‘deidentifyr’
Another package that can be used for data deidentification is ‘deidentifyr.’ Using a slightly longer SHA-256 hash to generate a unique ID code, this package aims to avoid the potential recovery of hashed PII (Wilcox, 2019). This package is not yet on CRAN, but can be installed from GitHub. 'deidentify()' will generate a unique ID from personally identifying information. Because the IDs are generated with the SHA-256 algorithm, they are a) very unlikely to be the same for people with different identifying information, and b) nearly impossible to recover the identifying information from.

```{r, eval = FALSE}
devtools::install_github('wilkox/deidentifyr')
```

```{r, include = FALSE}
set.seed(1)
n <- 10
MRNs <- sample(10000000:99999999, n)
DOBs <- lubridate::today() - lubridate::dyears(sample(18:99, n, replace = T))
days_in_hospitals <- sample(1:100, n, replace = T)
patient_data <- data.frame(MRN = MRNs, DOB = DOBs, 
                           days_in_hospital = days_in_hospitals)
patient_data
```

```{r}
library(deidentifyr)
patient_data <- deidentify(patient_data, MRN, DOB)
patient_data
```

```{r, include = FALSE}
sexes <- sample(c("F", "M"), n, replace = T)
patient_data2 <- data.frame(MRN = MRNs, DOB = DOBs, 
                           sex = sexes)
```

```{r}
patient_data2
patient_data2 <- deidentify(patient_data2, DOB, MRN)
patient_data2
```

```r
combined_data <- merge(patient_data, patient_data2, by = "id")
combined_data
```

### Package ‘digest’
A third package that can be used is ‘digest.’ This package generates a hashed character string and a variety of algorithms can be used depending on your need (Eddelbuettel et al., 2020). The digest package provides a principal function digest() for the creation of hash digests of arbitrary R objects (using the md5, sha-1, sha-256, crc32, xxhash, murmurhash, spookyhash and blake3 algorithms) permitting easy comparison of R language objects.

```r
library(digest)

#vectorisation
md5 <- getVDigest()
digest2 <- base::Vectorize(digest)
x <- rep(letters, 1e3)
rbenchmark::benchmark(
    vdigest = md5(x, serialize = FALSE),
    Vectorize = digest2(x, serialize = FALSE),
    vapply = vapply(x, digest, character(1), serialize = FALSE),
    replications = 5
)[,1:4]
all(md5(x, serialize=FALSE) == digest2(x, serialize=FALSE))
all(md5(x, serialize=FALSE) == vapply(x, digest, character(1), serialize = FALSE))

#repeated calls
stretch_key <- function(d, n) {
    md5 <- getVDigest()
    for (i in seq_len(n))
        d <- md5(d, serialize = FALSE)
    d
}

stretch_key2 <- function(d, n) {
    for (i in seq_len(n))
        d <- digest(d, serialize = FALSE)
    d
}
rbenchmark::benchmark(
    vdigest = stretch_key('abc123', 65e3),
    plaindigest = stretch_key2('abc123', 65e3),
    replications = 10
)[,1:4]
stretch_key('abc123', 65e3) == stretch_key2('abc123', 65e3)
```

### Package ‘duawranglr’
This package offers a set of functions to help users create shareable data sets from raw data files that contain protected elements. Relying on master crosswalk files that list restricted variables, package functions warn users about possible violations of data usage agreement and prevent writing protected elements.

```{r, echo = FALSE}
## deidentify data
tmpdir <- tempdir()
df <- deid_dua(df, write_crosswalk = TRUE, id_length = 20,
               crosswalk_filename = file.path(tmpdir, 'tmp.csv'))
```
```{r, eval = FALSE}
## deidentify data
df <- deid_dua(df, write_crosswalk = TRUE, id_length = 20)
```

### Package ‘easySdcTable’

This package provides functions to create shareable datasets based on K-anonymity. The main function, ProtectTable (), performs row deletion according to a frequency rule predefined by K-anonymity on a dataset. The functions, protectLinkedTables () or runArgusBatchFile () for linked tables (relational databases) or batch tables that generalize the same structure. 

```r
ex2w <- ProtectTable(z2w,1,4:7) 
ex2wHITAS <- ProtectTable(z2w,dimVar = c("region"),freqVar = c("annet", "arbeid", "soshjelp", "trygd"), method="HITAS") 
```

+	Paul Hendricks (2015). [“Package ‘detector’.”](https://cran.r-project.org/web/packages/detector/index.html)
+	Paul Hendricks (2015). [“anonymizer: Anonymize Data Containing Personally Identifiable Information.”](https://github.com/paulhendricks/anonymizer)
+	Wilcox (2019). [“deidentify: Deidentify a dataset.”](https://rdrr.io/github/wilkox/deidentifyr/man/deidentify.html)
+	Eddelbuettel , et. al (2020). [“Package ‘digest’.”](https://cran.r-project.org/web/packages/digest/digest.pdf)
+	Benjamin Skinner (2020) [“Package ‘duawranglr’.”](https://cran.r-project.org/web/packages/duawranglr/index.html)
+ Cassidy Kantoris (2020) [Deidentifying Data](https://rpubs.com/ckantoris2/642533)
+ Sarah Kooper, Anja Sautmann, and James Turrito(2020) [J-PAL Guide to De-Identifying Data](https://www.povertyactionlab.org/sites/default/files/research-resources/J-PAL-guide-to-deidentifying-data.pdf)
+ Øyvind Langsrud (2020) [“Package ‘easySdcTable’.”](https://cran.r-project.org/web/packages/easySdcTable/vignettes/easySdcTableVignette.html)
+ Martin Monkman(2020) [Data Science with R: A Resource Compendium](https://bookdown.org/martin_monkman/DataScienceResources_book/anonymity-and-confidentiality.html#k-anonymity)
