---
title: "R Notebook"
output:
  html_document:
    df_print: paged
    keep_md: yes
---

In the context of healthcare data where governance dimensions such as ethics and security can be unclear and prone to interpretations concepts of privacy and anonymity (reffering to GDPR in the EU, HIPAA in the US, PIPEDA in Canada) has now become part of business-as-usual considerations. 


## General Data Protection Regulation (GDPR)

To protect users’ personally identifiable information (PII-name, emails, physical address, IP address, health information, income, etc) European Union  has pput in place GDPR regulation that hold businesses to a higher standard when it comes to how they collect, store, and use the data. The ultimate goal of GDPR is to challenge the data privacy approach of organizations across the world to give EU citizens control over their personal data . 

## Health Insurance Portability and Accountability Act (HIPAA)

HIPAA is specifically designed for healthcare purposes in 1996 with the perspective of reducing the cost of health care by creating a standardised process for financial transactions and admin. HIPAA also sets out requirements intended to protect different types if sensitive personal health information (PHI) by implementation of data governance procedures. It also specifies the circumstances where healthcare providers may disclose this information to third parties with or without patients’ consent.

## The Personal Information Protection and Electronic Documents Act (PIPEDA)

Under Canadian PIPEDA, personal information includes any type of subjective or objective information, about an identifiable person. This includes information in any form, such as:
+ Personally identifiable information (PII) including age, name, ID numbers, income, ethnic origin, or blood type
+ Subjective opinions, evaluations, as well as intentions (for example, to acquire goods or services, or change jobs), comments, social status, or disciplinary actions
+ Factual and background details such as employee files, credit records, loan records, medical records, existence of a dispute between a consumer and a merchant.
PIPEDA requires organizations to obtain the data owners’ consent when they collect, use or disclose the information. Personal information can only be used for the purposes for which it was collected in case an organization is going to use it for another purpose, they must obtain consent again. Personal information must be protected by appropriate safeguards. Data owners have the right to access their personal information held by an organization and challenge its accuracy. 


## Deidentification

Deidentification is the process of removing personally identifiable information (PII) from the raw data. This procedure ensures compliance to legal and ethical standards of data collection, storage, and analysis. PII can include items such as nominal information, social security numbers, health insurance number, and addresses. The procedures and methodology of deidentification is important as it protects the privacy of individuals and prevents any biased use or interpretation of the data.

## Risk of re-identification and K-anonymity
A shared database provides K-anonymity protection if the information about each person in the release cannot be distinguished from at least k-1 individuals whose information is also included in the release. 

## Automated De-Identification Tools

Several automated de-identification programs have been developed in recent years, which can be grouped into three categories:

+ Tools for efficiently handling direct identifiers in record-level data,
+ Tools for reducing the risk of re-identification from indirect identifiers in record-level data
+ Tools for handling aggregate data sets.

Here we are going to focus on some R packages for handling direct identifiers and reducing the risk of re-identification.

### Package ‘detector’
The detector package aimes to make identification of  data containing PIIs quick, easy, and scalable. It provides high-level functions that can take vectors and dataframes and return important summary statistics in a convenient dataframe foramt. The function detect() is  able to detect the different types of PII (e.g. name, social security number, etc.).


```r
if (packageVersion("devtools") < 1.6) {
  install.packages("devtools")
}

#devtools::install_github("paulhendricks/detector")
library(dplyr, warn.conflicts = FALSE)
library(generator)
library(detector)



n <- 10
set.seed(1)
nominal_data <- 
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
knitr::kable(nominal_data, format = "markdown")
```



|name             |snn         |dob        |email                     |ip             |phone      |credit_card         |        lat|        lon|
|:----------------|:-----------|:----------|:-------------------------|:--------------|:----------|:-------------------|----------:|----------:|
|Lindsay Ratke    |605-79-6521 |1944-01-20 |gsbjakowpl@gxuvhascky.nvf |93.181.209.199 |2433769745 |7524-4564-8980-7163 |   4.554991|  -30.48552|
|Deirdre Thompson |655-48-9213 |1943-01-01 |enqc@vcgnyslqi.rxv        |80.117.239.219 |5381921324 |1435-1569-6160-4254 |  30.194573| -152.31707|
|Nolan Paucek     |988-60-6837 |2015-04-02 |w@og.otx                  |44.86.82.235   |1397964825 |3136-7975-8559-5663 | -16.510003|   10.09760|
|Lynn Pouros      |442-51-6861 |1981-09-10 |psd@bpalg.imb             |202.217.97.178 |3267187613 |9136-2925-9472-6198 |  61.666183|  166.43999|
|Lela Bogan       |681-15-7336 |2017-06-24 |qb@kcy.nsm                |98.24.224.201  |7258248169 |1532-6665-5062-9705 |  42.714984|   75.14642|
|Gregory Torphy   |220-33-6490 |1948-06-30 |rxjoteug@elnftpoba.cxi    |26.37.72.148   |8159368397 |3751-2812-8917-7016 | -27.319608|   19.25125|
|Isreal Fay       |139-41-8493 |2013-09-02 |teiluh@d.qiu              |241.108.53.98  |1844591856 |6591-8680-5729-3015 |  80.808872|  -92.53562|
|Lane Stanton     |783-23-2790 |1923-03-21 |t@jnzuw.vfr               |33.15.56.101   |5243175341 |6190-3832-1723-1131 |  26.402254|  100.09531|
|Tawna Streich    |636-11-5938 |1964-01-05 |nd@zhueygtd.qjd           |252.14.234.93  |7384619634 |7458-8884-2353-7185 | -83.650002|   54.69874|
|Towanda Batz     |474-54-1464 |1926-08-07 |iofxdcumz@ygneztujh.anl   |132.239.231.75 |2474873715 |9410-6693-9683-6093 |  17.360722|  118.88845|

```r
nominal_data %>% 
  detect %>% 
  knitr::kable(format = "markdown")
```



|column_name |has_email_addresses |has_phone_numbers |has_national_identification_numbers |
|:-----------|:-------------------|:-----------------|:-----------------------------------|
|name        |FALSE               |FALSE             |FALSE                               |
|snn         |FALSE               |FALSE             |TRUE                                |
|dob         |FALSE               |FALSE             |FALSE                               |
|email       |TRUE                |FALSE             |FALSE                               |
|ip          |FALSE               |FALSE             |FALSE                               |
|phone       |FALSE               |TRUE              |FALSE                               |
|credit_card |FALSE               |FALSE             |FALSE                               |
|lat         |FALSE               |TRUE              |FALSE                               |
|lon         |FALSE               |TRUE              |FALSE                               |

### Package ‘anonymizer’
Package ‘anonymizer’ proposes several options for replacing PIIs with a random unique identifier (Hendricks, 2015). The package can be installed from CRAN or from GitHub depending on your version of R.


```r
#devtools::install_github("paulhendricks/anonymizer")
#install.packages("anonymizer")
library(anonymizer)

non_nominal_data=nominal_data

non_nominal_data[] <- lapply(nominal_data, anonymize, .algo = "crc32")
non_nominal_data %>% 
  knitr::kable(format = "markdown")
```



|name     |snn      |dob      |email    |ip       |phone    |credit_card |lat      |lon      |
|:--------|:--------|:--------|:--------|:--------|:--------|:-----------|:--------|:--------|
|f057ecc4 |af429f4f |537f4b33 |e58444a5 |4ed2ca90 |d8ea79bc |d31ff3ae    |f0356e76 |b875afeb |
|1861927c |838951aa |7b246030 |e0c00f2c |d984e4f6 |e1573c5b |a4252767    |e76dc4be |a14e9a62 |
|ba183ba4 |5218cb3b |fa1ed41b |ccc49859 |88a4d3ab |8cca0f9b |84a3aba1    |75c4729d |5b01ffdf |
|5de95b08 |fee13b97 |db563d5d |1eccc0ae |474ff3c1 |f18f8cc8 |65f5aef8    |8097921a |18ef073f |
|4cdeb6ed |f626cd3c |79159036 |a5832098 |1f661be7 |863347bb |887b9ea4    |981432b6 |c76533d7 |
|978c9b5c |b30ee80e |946360cf |3263a481 |5ed07ddd |7e63f48b |4f53569b    |1601f541 |72769401 |
|c0b887d8 |efc98126 |e46c96ac |dc930c1c |b1a4ebda |01f546dd |9ea6c5f6    |192ac290 |0ceb1823 |
|71207b6b |9aff7755 |62a88642 |43ecafc2 |a0da760e |38c225cd |9581f39f    |379adeda |89ea2f87 |
|d43e1a57 |78fae7be |f4717ee2 |d77b1e73 |9b020da0 |fcf212d7 |21bb4eff    |0326a6c5 |62b54aa4 |
|af5cdcde |050a5f2f |39989dbb |4d0bf0df |55a1fad0 |d7e7c064 |aa90f82a    |f5a02b03 |e5856780 |
### Package ‘deidentifyr’
Another package that can be used for data deidentification is ‘deidentifyr.’ This package aims to avoid the potential recovery of hashed PIIs by using a longer SHA-256 hash to generate a unique ID code (Wilcox, 2019). This package is not yet on CRAN, but can be installed from the author's GitHub. The functtion 'deidentify()' will generate a unique ID from personally identifying information. Because the IDs are generated with the SHA-256 algorithm, they are a) very unlikely to be the same for people with different identifying information, and b) nearly impossible to recover the identifying information from.


```r
#devtools::install_github('wilkox/deidentifyr')
library(deidentifyr)
set.seed(1234)
n <- 10
SSNs <- sample(10000000:99999999, n)
DOBs <- lubridate::today() - lubridate::dyears(sample(18:99, n, replace = T))

days_in_hospitals <- sample(1:100, n, replace = T)

nominal_patient_data <- data.frame(SSN = SSNs, DOB = DOBs, 
                           days_in_hospital = days_in_hospitals)
nominal_patient_data%>% 
  knitr::kable(format = "markdown")
```



|      SSN|DOB                 | days_in_hospital|
|--------:|:-------------------|----------------:|
| 95696335|1948-02-12 18:00:00 |               47|
| 76690965|1942-02-12 06:00:00 |               40|
| 83704427|2000-02-12 18:00:00 |               84|
| 50778632|2000-02-12 18:00:00 |               48|
| 52238885|1983-02-12 12:00:00 |                3|
| 36184579|1964-02-12 18:00:00 |               87|
| 16417510|1948-02-12 18:00:00 |               41|
| 57568473|1937-02-12 00:00:00 |              100|
| 31316686|1999-02-12 12:00:00 |               72|
| 27649021|1938-02-12 06:00:00 |               32|

```r
masked_patient_data <- deidentify(nominal_patient_data, SSN, DOB)

masked_patient_data%>% 
  knitr::kable(format = "markdown")
```



|id         | days_in_hospital|
|:----------|----------------:|
|f6d3f0fb34 |               47|
|66f976f163 |               40|
|660fa9c913 |               84|
|e76ac9ba6b |               48|
|43aec46872 |                3|
|c5b21e95d4 |               87|
|e74eb297ea |               41|
|731dd9d3a1 |              100|
|553d9e69a5 |               72|
|7b842cfa83 |               32|

```r
sexes <- sample(c("F", "M"), n, replace = T)
nominal_patient_data2 <- data.frame(SSN = SSNs, DOB = DOBs, sex = sexes)

nominal_patient_data2%>% 
  knitr::kable(format = "markdown")
```



|      SSN|DOB                 |sex |
|--------:|:-------------------|:---|
| 95696335|1948-02-12 18:00:00 |M   |
| 76690965|1942-02-12 06:00:00 |F   |
| 83704427|2000-02-12 18:00:00 |M   |
| 50778632|2000-02-12 18:00:00 |F   |
| 52238885|1983-02-12 12:00:00 |F   |
| 36184579|1964-02-12 18:00:00 |M   |
| 16417510|1948-02-12 18:00:00 |F   |
| 57568473|1937-02-12 00:00:00 |M   |
| 31316686|1999-02-12 12:00:00 |M   |
| 27649021|1938-02-12 06:00:00 |F   |

```r
masked_patient_data2 <- deidentify(nominal_patient_data2, DOB, SSN)

masked_patient_data2%>% 
  knitr::kable(format = "markdown")
```



|id         |sex |
|:----------|:---|
|f6d3f0fb34 |M   |
|66f976f163 |F   |
|660fa9c913 |M   |
|e76ac9ba6b |F   |
|43aec46872 |F   |
|c5b21e95d4 |M   |
|e74eb297ea |F   |
|731dd9d3a1 |M   |
|553d9e69a5 |M   |
|7b842cfa83 |F   |

```r
combined_data <- merge(masked_patient_data, masked_patient_data2, by = "id")
combined_data%>% 
  knitr::kable(format = "markdown")
```



|id         | days_in_hospital|sex |
|:----------|----------------:|:---|
|43aec46872 |                3|F   |
|553d9e69a5 |               72|M   |
|660fa9c913 |               84|M   |
|66f976f163 |               40|F   |
|731dd9d3a1 |              100|M   |
|7b842cfa83 |               32|F   |
|c5b21e95d4 |               87|M   |
|e74eb297ea |               41|F   |
|e76ac9ba6b |               48|F   |
|f6d3f0fb34 |               47|M   |

### Package ‘digest’

The third package that can be used in the context of deidentification is ‘digest.’ This package generates hashed character strings based on a variety of algorithms (e.g. md5, sha-1, sha-256, crc32, xxhash, murmurhash, spookyhash and blake3 algorithms). The digest package provides a principal function digest() that creats hash digests of arbitrary R objects permitting easy deidentification of R language objects not limited to vectors and dataframes (Eddelbuettel et al., 2020).



```r
#install.packages("digest")
#install.packages("rbenchmark")
library(digest)
library(rbenchmark)

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
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["test"],"name":[1],"type":["chr"],"align":["left"]},{"label":["replications"],"name":[2],"type":["int"],"align":["right"]},{"label":["elapsed"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["relative"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"vapply","2":"5","3":"1.083","4":"5.415","_rn_":"3"},{"1":"vdigest","2":"5","3":"0.200","4":"1.000","_rn_":"1"},{"1":"Vectorize","2":"5","3":"1.325","4":"6.625","_rn_":"2"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

```r
set.seed(1234)
n <- 10
SSNs <- sample(10000000:99999999, n)
DOBs <- lubridate::today() - lubridate::dyears(sample(18:99, n, replace = T))

days_in_hospitals <- sample(1:100, n, replace = T)

nominal_patient_data <- data.frame(SSN = SSNs, DOB = DOBs, 
                                   days_in_hospital = days_in_hospitals)
nominal_patient_data%>% 
  knitr::kable(format = "markdown")
```



|      SSN|DOB                 | days_in_hospital|
|--------:|:-------------------|----------------:|
| 95696335|1948-02-12 18:00:00 |               47|
| 76690965|1942-02-12 06:00:00 |               40|
| 83704427|2000-02-12 18:00:00 |               84|
| 50778632|2000-02-12 18:00:00 |               48|
| 52238885|1983-02-12 12:00:00 |                3|
| 36184579|1964-02-12 18:00:00 |               87|
| 16417510|1948-02-12 18:00:00 |               41|
| 57568473|1937-02-12 00:00:00 |              100|
| 31316686|1999-02-12 12:00:00 |               72|
| 27649021|1938-02-12 06:00:00 |               32|

```r
masked_patient_data=nominal_patient_data

masked_patient_data$SSN=md5(as.vector(masked_patient_data$SSN))
masked_patient_data$DOB=md5(as.vector(masked_patient_data$DOB))
masked_patient_data%>% 
  knitr::kable(format = "markdown")
```



|SSN                              |DOB                              | days_in_hospital|
|:--------------------------------|:--------------------------------|----------------:|
|a72d770abc6b5716d1fa20d8104fdac0 |238d9741d30574082d56c7440105aa9f |               47|
|c1bd67f8d51a94b531049d34464a8997 |9f79752094e5adbf509f594cf950937f |               40|
|bbef3a64f11961836b1160a9fc138971 |ca41ac47e2136ed95a313457424f89e1 |               84|
|2ecc69893690daa89766288458d66e7d |ca41ac47e2136ed95a313457424f89e1 |               48|
|7abbb72d31a6cfa5f5604f86fa1cfefe |906fba3b14dbac8ba45677e26c366115 |                3|
|df953d8e7a0f6371267856d3522162f3 |df10e3923c3592d30befac743c732a0b |               87|
|e22f9098c278b7f0999c2f9e3fe0c43f |238d9741d30574082d56c7440105aa9f |               41|
|0dfce6ab3d3a15b67243e2dc6de0f23b |3113d02dc1ce57a6d7b7456022ecaf10 |              100|
|cd07e5d3b96f425b6150ac7a5eb894f5 |add6641430eac2366c4f7d819c9fa53d |               72|
|29ef3133c12937977c7602ddcde7a845 |a6f806c02fe64e153aeadc5204ce5378 |               32|

### Package ‘duawranglr’
Similar to above this package offers a set of functions to help users create shareable data sets from raw data files with protected elements. Relying on a master crosswalk files that lists variables to be restricted, package functions (e.g. deid_dua) warn users about possible violations of data usage agreement and prevent writing protected elements.


```r
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(readr))
library(duawranglr)
dua_cw_file <- system.file('extdata', 'dua_cw.csv', package = 'duawranglr')
admin_file <- system.file('extdata', 'admin_data.csv', package = 'duawranglr')
set_dua_cw(dua_cw_file)
```

```r
see_dua_options(level = c('level_ii', 'level_iii'))

set_dua_level('level_ii', deidentify_required = TRUE, id_column = 'sid')
```

```r
see_dua_level(show_restrictions = TRUE)
```

```r
see_dua_level(show_restrictions = TRUE)
```

```r
df <- read_dua_file(admin_file)
df%>% 
  knitr::kable(format = "markdown")
```



|sid         |sname    |dob      |gender |raceeth |tid |tname |zip   |mathscr |readscr |
|:-----------|:--------|:--------|:------|:-------|:---|:-----|:-----|:-------|:-------|
|000-00-0001 |Schaefer |19900114 |0      |2       |1   |Smith |22906 |515     |496     |
|000-00-0002 |Hodges   |19900225 |0      |1       |1   |Smith |22906 |488     |489     |
|000-00-0003 |Kirby    |19900305 |0      |4       |1   |Smith |22906 |522     |498     |
|000-00-0004 |Estrada  |19900419 |0      |3       |1   |Smith |22906 |516     |524     |
|000-00-0005 |Nielsen  |19900530 |1      |2       |1   |Smith |22906 |483     |509     |
|000-00-0006 |Dean     |19900621 |1      |1       |2   |Brown |22906 |503     |523     |
|000-00-0007 |Hickman  |19900712 |1      |1       |2   |Brown |22906 |539     |509     |
|000-00-0008 |Bryant   |19900826 |0      |2       |2   |Brown |22906 |499     |490     |
|000-00-0009 |Lynch    |19900902 |1      |3       |2   |Brown |22906 |499     |493     |

```r
tmpdir <- tempdir()
df <- deid_dua(df, write_crosswalk = TRUE, id_length = 20, crosswalk_filename = file.path(tmpdir, 'tmp.csv'))
df%>% 
  knitr::kable(format = "markdown")
```



|id                   |sname    |dob      |gender |raceeth |tid |tname |zip   |mathscr |readscr |
|:--------------------|:--------|:--------|:------|:-------|:---|:-----|:-----|:-------|:-------|
|003762c1fefe770c73e5 |Schaefer |19900114 |0      |2       |1   |Smith |22906 |515     |496     |
|61e5153161415d683d31 |Hodges   |19900225 |0      |1       |1   |Smith |22906 |488     |489     |
|7ae5033b8b8fb5bf6269 |Kirby    |19900305 |0      |4       |1   |Smith |22906 |522     |498     |
|088e7b35d003938906de |Estrada  |19900419 |0      |3       |1   |Smith |22906 |516     |524     |
|a5be0ece2d6b09b45a47 |Nielsen  |19900530 |1      |2       |1   |Smith |22906 |483     |509     |
|225a7238ffb5a24d52d8 |Dean     |19900621 |1      |1       |2   |Brown |22906 |503     |523     |
|1f3a1db8ce241256b3fd |Hickman  |19900712 |1      |1       |2   |Brown |22906 |539     |509     |
|f43b5214e18471c95b69 |Bryant   |19900826 |0      |2       |2   |Brown |22906 |499     |490     |
|95d70c99c5bc8d3e3360 |Lynch    |19900902 |1      |3       |2   |Brown |22906 |499     |493     |

### Package ‘easySdcTable’

This package provides functions to create shareable datasets based on K-anonymity. The main function, ProtectTable(), performs row deletion according to a frequency rule predefined by K-anonymity on a dataset. The functions, protectLinkedTables () or runArgusBatchFile () for linked tables (relational databases) or batch tables that generalize the same structure. 


```r
library(easySdcTable)
```

```
## Loading required package: SSBtools
```

```
## Loading required package: Matrix
```

```r
set.seed(1234)
n <- 1000
SSNs <- sample(10000000:99999999, n)
DOBs <- lubridate::today() - lubridate::dyears(sample(1:100, n, replace = T))
Region <- sample(c("a","b","c", "d","e","f","g"), n, replace = T)
Sex <- sample(c("m","w"), n, replace = T)
days_in_hospitals <- sample(1:100, n, replace = T)
nominal_patient_data <- data.frame(SSN = SSNs, DOB = DOBs, days_in_hospital = days_in_hospitals, Region=Region, Sex=Sex)
K_ano_patient_data=ProtectTable(nominal_patient_data,dimVar = c("Region","Sex"), freqVar = c("days_in_hospital"), method="HITAS") 
```

```
## .....
```

```r
head(K_ano_patient_data$data)%>% 
  knitr::kable(format = "markdown")
```



|Region |Sex | freq|sdcStatus | suppressed|
|:------|:---|----:|:---------|----------:|
|d      |m   | 3603|s         |       3603|
|c      |w   | 2914|s         |       2914|
|f      |m   | 3412|s         |       3412|
|b      |m   | 3447|s         |       3447|
|a      |m   | 3871|s         |       3871|
|c      |m   | 3878|s         |       3878|

+	Paul Hendricks (2015). [“Package ‘detector’.”](https://cran.r-project.org/web/packages/detector/index.html)
+	Paul Hendricks (2015). [“anonymizer: Anonymize Data Containing Personally Identifiable Information.”](https://github.com/paulhendricks/anonymizer)
+	Wilcox (2019). [“deidentify: Deidentify a dataset.”](https://rdrr.io/github/wilkox/deidentifyr/man/deidentify.html)
+	Eddelbuettel , et. al (2020). [“Package ‘digest’.”](https://cran.r-project.org/web/packages/digest/digest.pdf)
+	Benjamin Skinner (2020) [“Package ‘duawranglr’.”](https://cran.r-project.org/web/packages/duawranglr/index.html)
+ Cassidy Kantoris (2020) [Deidentifying Data](https://rpubs.com/ckantoris2/642533)
+ Sarah Kooper, Anja Sautmann, and James Turrito(2020) [J-PAL Guide to De-Identifying Data](https://www.povertyactionlab.org/sites/default/files/research-resources/J-PAL-guide-to-deidentifying-data.pdf)
+ Øyvind Langsrud (2020) [“Package ‘easySdcTable’.”](https://cran.r-project.org/web/packages/easySdcTable/vignettes/easySdcTableVignette.html)
+ Martin Monkman(2020) [Data Science with R: A Resource Compendium](https://bookdown.org/martin_monkman/DataScienceResources_book/anonymity-and-confidentiality.html#k-anonymity)



