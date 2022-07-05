
1. Introduction

This document, Brain Imaging Data Structure (BIDS): Governance and Decision Making, intends to describe the BIDS mission, its principles, its scope, the leadership structure, governance over the standard development process, and to define the different groups and roles. BIDS is a community-built and maintained standard. The goal of this document is to clearly describe how BIDS is maintained and grown.

2. Background


The Brain Imaging Data Structure (BIDS) is a standard specifying the description of neuroimaging data in a filesystem hierarchy and of the metadata associated with the imaging data. The current edition of the standard is available in HTML with all the previous editions available since October 2018 (listed in the Changelog). The pre-October 2018 specification editions can be found in this repository as PDFs. The development edition is available in HTML. The specification is based in a GitHub repository and rendered with ReadTheDocs.

We strive for community consensus in decision making. This governing model and decision making procedure was developed through the review of several governance models across the informatics and computing field.

The project is a community-driven effort. BIDS, originally OBIDS, was initiated during an INCF sponsored data sharing working group meeting (January 2015) at Stanford University. It was subsequently spearheaded and maintained by Chris Gorgolewski. The project is currently managed and maintained by Franklin Feingold, Stefan Appelhoff, and the Poldrack Lab at Stanford. BIDS has advanced under the direction and effort of contributors, the community of researchers that appreciate the value of standardizing neuroimaging data to facilitate sharing and analysis. The project is multifaceted, and depends on contributors for: specification development and maintenance, BIDS Extension Proposals (BEPs), software tools, starter kits, examples, and general discussions. The relevant discussions are located in our Google Group, GitHub organization, and public Google Documents (typically associated with an extension proposal).

A key component of the BIDS initiative is the collection of associated software tools and platforms that facilitate the validation and ease the use of BIDS-formatted datasets. BIDS converters (e.g., HeuDiConv) enable the streamlined conversion of raw imaging files (e.g., DICOMs) into a BIDS dataset, the BIDS validator allows users to confirm that a given dataset complies with the current edition of the standard, the PyBIDS Python and bids-matlab libraries allow querying and manipulating BIDS-compliant datasets, BIDS-Apps for running portable pipelines on validated BIDS datasets, and platforms like OpenNeuro store and serve BIDS datasets. Note that the associated software does not fall under the same governance structure as BIDS, although the contributor and user base may largely overlap.


3. Motivation

Neuroimaging experiments result in complicated data that can be arranged in many different ways. So far there is no consensus how to organize and share data obtained in neuroimaging experiments. Even two researchers working in the same lab can opt to arrange their data in a different way. Lack of consensus (or a standard) leads to misunderstandings and time wasted on rearranging data or rewriting scripts expecting certain structure. Here we describe a simple and easy-to-adopt way of organising neuroimaging and behavioral data. By using this standard you will benefit in the following ways:

It will be easy for another researcher to work on your data. To understand the organisation of the files and their format you will only need to refer them to this document. This is especially important if you are running your own lab and anticipate more than one person working on the same data over time. By using BIDS you will save time trying to understand and reuse data acquired by a graduate student or postdoc that has already left the lab.
There are a growing number of data analysis software packages that can understand data organised according to BIDS (see the up to date list).
Databases such as OpenNeuro.org accept datasets organised according to BIDS. If you ever plan to share your data publicly (nowadays some journals require this) you can minimize the additional time and energy spent on publication, and speed up the curation process by using BIDS to structure and describe your data right after acquisition.
Validation tools such as the BIDS Validator can check your dataset integrity and help you easily spot missing values.
BIDS was heavily inspired by the format used internally by the OpenfMRI repository that is now known as OpenNeuro.org, and has been supported by the International Neuroinformatics Coordinating Facility (INCF) and the INCF Neuroimaging Data Sharing (NIDASH) Task Force. While working on BIDS we consulted many neuroscientists to make sure it covers most common experiments, but at the same time is intuitive and easy to adopt. The specification is intentionally based on simple file formats and folder structures to reflect current lab practices and make it accessible to a wide range of scientists coming from different backgrounds.





[BIDS 1](https://bids-specification.readthedocs.io/en/latest/)

[BIDS 2](https://bids.neuroimaging.io/governance.html)


[ggseg 1](https://cran.r-project.org/web/packages/ggseg/vignettes/ggseg.html)

[ggseg 2](https://github.com/ggseg/ggseg)

[ggseg3d](https://www.researchgate.net/publication/347761880_Visualization_of_Brain_Statistics_With_R_Packages_ggseg_and_ggseg3d)

[towardsdatascience](https://towardsdatascience.com/visualizing-brains-using-r-606fa0fb9fdf)

[fsbrain](https://cran.r-project.org/web/packages/fsbrain/vignettes/fsbrain.html)

[link](https://journals.sagepub.com/doi/10.1177/2515245920928009)

[link](https://journals.sagepub.com/doi/10.1177/2515245920928009)
