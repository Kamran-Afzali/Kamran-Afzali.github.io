---
layout: post
categories: posts
title: FAIR Principles    
featured-image: /images/FAIR.png
tags: [FAIR, Findability, Accessibility, Interoperability, Reusability]
date-string: MARCH 2021
---

# FAIR Principles

## Factors Affecting Value of Healthcare Data 

Utility and use cases of healthcare data may vary from ongoing daily operating decisions of a hospital to the develpement of new treatments and enhancment of patients' adherence to therapy. Once the data has utility for multiple stake holders, it's use impliese risky and impactful decisions affecting long-term strategy and operations, and hence, make it more valuable. The value of data is also a function of the **risk and effort associated with data collection** as well as **granularity** of data. In general, the increased granularity or specificity of a data set increases its value by allowing the user to extract additional insights absent from aggregated data sets. In health care context, granularity translates into patient-and transaction-level data (e.g., medical product dispense, patient encounters, change in status, etc.). An example of value evident in granularity the application of predictive analytics on patient-level genome sequencing data that enables identification of individual patients that are at high risk for certain conditions. In terms of risk and effort associated with data collection, auto captured data which is a by-product of everyday business processes would generally be perceived as less valuable compared to the data that is collected using other incremental resources involved in the process such as human intervention. These two concepts (i.e. granularity and effort) are related ot the concept of **data maturity** reffering to the progression of a data set along the data analytics process. Several initiatives are underway to support the seemless sharing, exchange, and reuse of healthcare data whether stored in electronic health records or measurment devices. The goal of these initiatives is  to improve the healthcare data in a way that it can be exchanged electronically and analyzed digitally. To attain this goal and to improve the management and organization of health care data, it needs to be structured based on operational electronic standards such as FAIR principles that insures clinicians and professionals use suitable data for critical decision making. The ultimate determinant of healthcare data value is its power to inform decisions. 

## FAIR Principles

A publication by a consortium of scientists and organizations back in March 2016 specified the details of *"FAIR Guiding Principles for scientific data management and stewardship"* in scientific data, using the term FAIR as an acronym and making the concept easier to discuss. The authors of this document intended to promote general guidelines that improve the **Findability**, **Accessibility**, **Interoperability**, and **Reuse** of digital assets such as electronic health records. The FAIR principles emphasize that computerized systems should Find, Access, Interoperate, and Reuse the data with none or minimal human intervention (i.e., the capacity of machine-actionability) because humans increasingly rely on digital support to handel big data as a result of the increase in velocity, volume, variety, and complexity of data. The FAIR principles apply to data and supporting infrastructure but also to metadata, with most of the requirements for Accessibility and Findability is achievable through the metadata. In contrast, Interoperability and Reuse require more efforts at the data level. 

The FAIR Data Principles make data more valuable as it is easier to find through unique identifiers and easier to combine and integrate thanks to the formal shared knowledge representation. Such data is easier to reuse, repurpose and share because machines have the means to understand where data comes from and what it is about. It also accelerates research, boosts cooperation and facilitates reuse in scientific research. Policymakers and stakeholders have seen its value in driving innovation and many have embraced these principles.

Focusing on the research based on open science, the FAIR principles received the support of  G20 leaders during their 2016 summit. In the United States, the Office of Science at the Department of Energy announced in April 2020 a total of US$8.5 million for new research aimed at advancing the FAIR Data Principles in Artificial Intelligence (AI) research and development. The European Union has also embraced them and had an expert group report on how to turn FAIR into reality.


## Findable

The first step in FAIRification of data is to facilitate finding them. Both data and metadata should be easy to find for computers and humans. Machine-readable metadata are essential for automatic discovery of datasets and services.

+ F1. (Meta)data are assigned a globally unique and persistent identifier

+ F2. Data are described with rich metadata (defined by R1 below)

+ F3. Metadata clearly and explicitly include the identifier of the data they describe

+ F4. (Meta)data are registered or indexed in a searchable resource

## Accessible

After finding the required data, the next step is to accesse the data possibly including authentication and authorisation procedures. In the case that data is only available from a single source and there are some projected disruption caused by losing access to such data, the party holding the data acquires monopoly over the data. Access to data can be limited via physical barriers, expense of the collection process, business strategy or contractual restrictions.  In the G20 countries, open-sourced data is estimated to be valued between US$700bn and US$950bn per annum. For example, government data, such as census results, allows for ready resource allocation, capital investment planning, policy-making and monitoring numerous other benefits.

+ A1. (Meta)data are retrievable by their identifier using a standardised communications protocol

  + A1.1 The protocol is open, free, and universally implementable

  + A1.2 The protocol allows for an authentication and authorisation procedure, where necessary

+ A2. Metadata are accessible, even when the data are no longer available

## Interoperable

The data usually need to be integrated with other data. In addition, data need to interoperate with various applications or workflows for analysis, storage, and processing.

+ I1. (Meta)data use a formal, accessible, shared, and broadly applicable language for knowledge representation.

+ I2. (Meta)data use vocabularies that follow FAIR principles

+ I3. (Meta)data include qualified references to other (meta)data

## Reusable

The ultimate goal of FAIR is to optimise the reuse of data. To achieve this, metadata and data should be well-described so that they can be replicated and/or combined in different settings.

+ R1. (Meta)data are richly described with a plurality of accurate and relevant attributes

  + R1.1. (Meta)data are released with a clear and accessible data usage license

  + R1.2. (Meta)data are associated with detailed provenance

  + R1.3. (Meta)data meet domain-relevant community standards


## References

+ [The FAIR Guiding Principles for scientific data management and stewardship](https://www.go-fair.org/fair-principles/)

+ [The Portage Network](https://portagenetwork.ca/)

+ Wise, J., de Barron, A. G., Splendiani, A., Balali-Mood, B., Vasant, D., Little, E., ... & Hedley, V. (2019). [Implementation and relevance of FAIR data principles in biopharmaceutical R&D](https://www.sciencedirect.com/science/article/pii/S1359644618303039). Drug discovery today, 24(4), 933-938.  

+ Jansen, P., van den Berg, L., van Overveld, P., & Boiten, J. W. (2019). [Research data stewardship for healthcare professionals](https://www.ncbi.nlm.nih.gov/books/NBK543528/). Fundamentals of Clinical Data Science, 37-53.
