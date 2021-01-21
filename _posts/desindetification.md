

Privacy (GDPR in the EU, HIPAA in the US, PIPEDA in Canada) has now become part of business-as-usual considerations whereas the other dimensions of ethics, being less clear and more prone to interpretations, as far less watched out


## General Data Protection Regulation (GDPR)

GDPR is an EU regulation put in place to protect user’s personally identifiable information (PII) and hold businesses to a higher standard when it comes to how they collect, store, and use this data.
The ultimate goal of GDPR?
It’s to give EU citizens control over their personal data and change the data privacy approach of organizations across the world. PII includes name, emails, physical address, IP address, health information, income, etc. You can read the full text of the regulation.

## Health Insurance Portability and Accountability Act (HIPAA)

HIPAA came into force in 1996. It was designed to make health insurance coverage fairer for employees moving between jobs. It also sought to reduce the cost of health care by bringing in a more standardised process for financial transactions and admin. Through the “Privacy Rule” contained within the legislation, HIPAA also sets out requirements designed to protect sensitive personal health information (PHI). As well as setting out data governance procedures in areas such as billing and admin, this Rule sets out the right of patients to receive copies of PHI from organisations. It also stipulates the circumstances under which healthcare providers may disclose this information to third parties – and when express patient permission is needed for this.

## The Personal Information Protection and Electronic Documents Act (PIPEDA)

Organizations covered by PIPEDA must generally obtain an individual's consent when they collect, use or disclose that individual's personal information. People have the right to access their personal information held by an organization. They also have the right to challenge its accuracy. Personal information can only be used for the purposes for which it was collected. If an organization is going to use it for another purpose, they must obtain consent again. Personal information must be protected by appropriate safeguards. Under PIPEDA, personal information includes any factual or subjective information, recorded or not, about an identifiable individual. This includes information in any form, such as:

+	age, name, ID numbers, income, ethnic origin, or blood type
+	opinions, evaluations, comments, social status, or disciplinary actions
+	employee files, credit records, loan records, medical records, existence of a dispute between a consumer and a merchant, intentions (for example, to acquire goods or services, or change jobs).

## Deidentification

Deidentification is the process of removing personally identifiable information (PII) from data. PII can include items such as banking information, Social Security numbers, and addresses. This topic is valuable because data deidentification protects the privacy of individuals and is important in many industries, including but not limited to health care, banking, pharmaceuticals, and education. Deidentification ensures compliance to ethical and legal standards of data collection and analysis.

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

```
ashley_madison[] <- lapply(ashley_madison, anonymize, .algo = "crc32")
ashley_madison %>% 
  knitr::kable(format = "markdown")
```
### Package ‘deidentifyr’
Another package that can be used for data deidentification is ‘deidentifyr.’ Using a slightly longer SHA-256 hash to generate a unique ID code, this package aims to avoid the potential recovery of hashed PII (Wilcox, 2019). This package is not yet on CRAN, but can be installed from GitHub. 'deidentify()' will generate a unique ID from personally identifying information. Because the IDs are generated with the SHA-256 algorithm, they are a) very unlikely to be the same for people with different identifying information, and b) nearly impossible to recover the identifying information from.

### Package ‘digest’
A third package that can be used is ‘digest.’ This package generates a hashed character string and a variety of algorithms can be used depending on your need (Eddelbuettel et al., 2020). The digest package provides a principal function digest() for the creation of hash digests of arbitrary R objects (using the md5, sha-1, sha-256, crc32, xxhash, murmurhash, spookyhash and blake3 algorithms) permitting easy comparison of R language objects.

### Package ‘duawranglr’
This package offers a set of functions to help users create shareable data sets from raw data files that contain protected elements. Relying on master crosswalk files that list restricted variables, package functions warn users about possible violations of data usage agreement and prevent writing protected elements.


+	Paul Hendricks (2015). [“Package ‘detector’.”](https://cran.r-project.org/web/packages/detector/index.html)
+	Paul Hendricks (2015). [“anonymizer: Anonymize Data Containing Personally Identifiable Information.”](https://github.com/paulhendricks/anonymizer)
+	Wilcox (2019). [“deidentify: Deidentify a dataset.”](https://rdrr.io/github/wilkox/deidentifyr/man/deidentify.html)
+	Eddelbuettel , et. al (2020). [“Package ‘digest’.”](https://cran.r-project.org/web/packages/digest/digest.pdf)
+	Benjamin Skinner (2020) [“Package ‘duawranglr’.”](https://cran.r-project.org/web/packages/duawranglr/index.html)
+ https://rpubs.com/ckantoris2/642533
+ https://www.povertyactionlab.org/sites/default/files/research-resources/J-PAL-guide-to-deidentifying-data.pdf
