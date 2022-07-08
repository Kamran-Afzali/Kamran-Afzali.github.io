
# BIDS

1. Introduction

This document, Brain Imaging Data Structure (BIDS): Governance and Decision Making, intends to describe the BIDS mission, its principles, its scope, the leadership structure, governance over the standard development process, and to define the different groups and roles. BIDS is a community-built and maintained standard. The goal of this document is to clearly describe how BIDS is maintained and grown. BIDS (Brain Imaging Data Structure) is a standarized format for the organization and description of neuroimaging and corresponding behavioral data, which has been largely lacking within the neuroimaging community. More specifically, data that come off the scanner are converted to NIFTI and JSON files, organized into a specific directory schema, and labeled following a precise naming convention. The result is an organized dataset that can be easily shared and understood by other researchers.

2. Background


The Brain Imaging Data Structure (BIDS) is a standard specifying the description of neuroimaging data in a filesystem hierarchy and of the metadata associated with the imaging data. The current edition of the standard is available in HTML with all the previous editions available since October 2018 (listed in the Changelog). The pre-October 2018 specification editions can be found in this repository as PDFs. The development edition is available in HTML. The specification is based in a GitHub repository and rendered with ReadTheDocs.

We strive for community consensus in decision making. This governing model and decision making procedure was developed through the review of several governance models across the informatics and computing field.

The project is a community-driven effort. BIDS, originally OBIDS, was initiated during an INCF sponsored data sharing working group meeting (January 2015) at Stanford University. It was subsequently spearheaded and maintained by Chris Gorgolewski. The project is currently managed and maintained by Franklin Feingold, Stefan Appelhoff, and the Poldrack Lab at Stanford. BIDS has advanced under the direction and effort of contributors, the community of researchers that appreciate the value of standardizing neuroimaging data to facilitate sharing and analysis. The project is multifaceted, and depends on contributors for: specification development and maintenance, BIDS Extension Proposals (BEPs), software tools, starter kits, examples, and general discussions. The relevant discussions are located in our Google Group, GitHub organization, and public Google Documents (typically associated with an extension proposal).

A key component of the BIDS initiative is the collection of associated software tools and platforms that facilitate the validation and ease the use of BIDS-formatted datasets. BIDS converters (e.g., HeuDiConv) enable the streamlined conversion of raw imaging files (e.g., DICOMs) into a BIDS dataset, the BIDS validator allows users to confirm that a given dataset complies with the current edition of the standard, the PyBIDS Python and bids-matlab libraries allow querying and manipulating BIDS-compliant datasets, BIDS-Apps for running portable pipelines on validated BIDS datasets, and platforms like OpenNeuro store and serve BIDS datasets. Note that the associated software does not fall under the same governance structure as BIDS, although the contributor and user base may largely overlap.


Benefits of BIDS

Reproducibility and Data Sharing: One of the more common issues that can arise for imaging researchers is receiving data from a colleague and not being able to make heads or tails of it: how the data are named and organized do not make intuitive sense to you, finding pertinent information (e.g. Repetition Time) is time-consuming, etc. What transpires is time wasted trying to make sense of the data, leading to needless back and forth with colleague(s). Thanks to the standarized format of BIDS however, the hassles of data sharing are largely alleviated. By extension, improved data sharing allows researchers to better assess and reproduce others’ experimental findings.
Access to “BIDS-apps”: Once converted to BIDS format, data can be applied to software packages that take BIDS-formatted datasets as their input, colloquially referred to as “BIDS-apps”. Two of the most common and used apps are MRIQC (a quality control pipeline that generates metrics of your data), and fMRIPrep (a standarized pre-processing pipeline). Having access to fMRIPrep is incredibly useful, as labs (and even individuals within a single lab) typically have their own idiosyncratic pre-processing pipelines, which can influence findings in subsequent analyses, and create confusion for others when attempting to re-process the data. By having a standarized pipeline such as fMRIPrep, which incorporates different sofware packages (such as FSL, AFNI, ANTs, FreeSurfer, and nipype), datasets across labs/institutions can be pre-processed in a highly reproducible and transparent manner.
Share your own BIDS-app(s): It is not uncommon for researchers to develop a novel analysis tool or technique that languishes on their Github or some other repository, unable to gain exposure in the neuroimaging community. As BIDS becomes increasingly popular however, dataset organization and pre-processing is becoming more standardized, which can be used by various BIDS-apps. By developing a tool that accepts BIDS-formatted data, you have created a BIDS-app that is potentially applicable to a large range of users.


3. Motivation

Neuroimaging experiments result in complicated data that can be arranged in many different ways. So far there is no consensus how to organize and share data obtained in neuroimaging experiments. Even two researchers working in the same lab can opt to arrange their data in a different way. Lack of consensus (or a standard) leads to misunderstandings and time wasted on rearranging data or rewriting scripts expecting certain structure. Here we describe a simple and easy-to-adopt way of organising neuroimaging and behavioral data. By using this standard you will benefit in the following ways:

It will be easy for another researcher to work on your data. To understand the organisation of the files and their format you will only need to refer them to this document. This is especially important if you are running your own lab and anticipate more than one person working on the same data over time. By using BIDS you will save time trying to understand and reuse data acquired by a graduate student or postdoc that has already left the lab.
There are a growing number of data analysis software packages that can understand data organised according to BIDS (see the up to date list).
Databases such as OpenNeuro.org accept datasets organised according to BIDS. If you ever plan to share your data publicly (nowadays some journals require this) you can minimize the additional time and energy spent on publication, and speed up the curation process by using BIDS to structure and describe your data right after acquisition.

Validation tools such as the BIDS Validator can check your dataset integrity and help you easily spot missing values. BIDS was heavily inspired by the format used internally by the OpenfMRI repository that is now known as OpenNeuro.org, and has been supported by the International Neuroinformatics Coordinating Facility (INCF) and the INCF Neuroimaging Data Sharing (NIDASH) Task Force. While working on BIDS we consulted many neuroscientists to make sure it covers most common experiments, but at the same time is intuitive and easy to adopt. The specification is intentionally based on simple file formats and folder structures to reflect current lab practices and make it accessible to a wide range of scientists coming from different backgrounds.


4. Tools

# FMRIprep

# Visualization

## R Visualization

## Python Visualization

# References

[AFNI](https://www.youtube.com/watch?v=Pegz6kKiw6E&list=PL_CD549H9kgq-_HSwvH5KhFl8A15u6d71)

[FSL](https://www.youtube.com/watch?v=3ExL6J4BIeo&list=PLvgasosJnUVl_bt8VbERUyCLU93OG31h_)

[Andy's Brain Book](https://andysbrainbook.readthedocs.io/en/latest/)

[BIDS 1](https://bids-specification.readthedocs.io/en/latest/)

[BIDS 2](https://bids.neuroimaging.io/governance.html)

[ggseg](https://journals.sagepub.com/doi/10.1177/2515245920928009)

[ggseg 1](https://cran.r-project.org/web/packages/ggseg/vignettes/ggseg.html)

[ggseg 2](https://github.com/ggseg/ggseg)

[ggseg3d](https://www.researchgate.net/publication/347761880_Visualization_of_Brain_Statistics_With_R_Packages_ggseg_and_ggseg3d)

[Visualizing-brains-using-r](https://towardsdatascience.com/visualizing-brains-using-r-606fa0fb9fdf)

[fsbrain](https://cran.r-project.org/web/packages/fsbrain/vignettes/fsbrain.html)




