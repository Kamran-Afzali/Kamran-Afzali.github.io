
# BIDS

1. Introduction

This post intends to describe the Brain Imaging Data Structure (BIDS) format for neuro imaging data its principles and its scope. BIDS is a community-built and maintained standarized format for the organization and description of neuroimaging and corresponding behavioral data, which has been largely lacking within the neuroimaging community. More specifically, data that come off the scanner are converted to NIFTI and JSON files, organized into a specific directory schema, and labeled following a precise naming convention. The result is an organized dataset that can be easily shared and understood by other researchers. More specifically it is a standard specifying the description of neuroimaging data in a filesystem hierarchy and of the metadata associated with the imaging data. The current edition of the standard is available in HTML with all the previous editions available since October 2018 on the BIDS website. 

The project is a community-driven effort. BIDS, originally OBIDS, was initiated during an INCF sponsored data sharing working group meeting (January 2015) at Stanford University. BIDS has advanced under the direction and effort the community of researchers that appreciate the value of standardizing neuroimaging data to facilitate sharing and analysis. The project is multifaceted, and depends on contributors for: specification development and maintenance, BIDS Extension Proposals (BEPs), software tools, starter kits, examples, and general discussions. 

A key component of the BIDS initiative is the collection of associated software tools and platforms that facilitate the validation and ease the use of BIDS-formatted datasets. BIDS converters (e.g., DCM2BIDS) enable the streamlined conversion of raw imaging files into a BIDS dataset, the BIDS validator allows users to confirm that a given dataset complies with the current edition of the standard.


2. Benefits of BIDS

As mentioned above, complex data from neuroimaging research can be structured in a variety of ways. There is currently no agreement on how to distribute and organise the data gathered from neuroimaging studies. It is possible for two researchers working in the same lab to choose to organise their data differently. Lack of agreement (or a standard) causes misunderstandings, which wastes time rearranging data or rewriting scripts that were written with a specific structure in mind. Here, we outline a straightforward and practical method for organising behavioural and neuroimaging data. You will gain by applying this standard in the following ways:

Reproducibility and Data Sharing: For imaging researchers, one of the most frequent problems that can occur is receiving data from a colleague and not being able to understand it. Other problems include finding the right information (such as repetition time) quickly enough. What happens is that time is wasted trying to interpret the data, which causes unnecessary back and forth with the colleague (s). However, BIDS' standard format helps to significantly reduce the difficulties associated with data sharing. Additionally, enhanced data sharing enables researchers to evaluate and replicate the results of other people's experiments.

Access to "BIDS-apps": After being converted to BIDS format, data can be used with software programmes called "BIDS-apps" that accept BIDS-formatted datasets as input. MRIQC (a quality control pipeline that outputs metrics of your data) and fMRIPrep are two of the most popular and used apps (a standarized pre-processing pipeline). It is extremely helpful to have access to fMRIPrep since different labs (and even individuals within a single lab) frequently have their own peculiar pre-processing pipelines, which can affect the results of future studies and befuddle people who are trying to reprocess the data. Datasets from various labs and institutions can be pre-processed in a way that is highly reproducible and transparent by using a standard pipeline like fMRIPrep, which combines several software packages (ex. FSL, AFNI, ANTs, FreeSurfer, and nipype).

Share your personal BIDS app: Researchers frequently create innovative analysis tools or techniques but are unable to share them with the neuroimaging community because they are simply just stored on Github or some other repository. However, as BIDS grows in popularity, dataset organisation and pre-processing are becoming more standardised, making them more accessible to BIDS-apps. You've made a BIDS-app that may be useful to a wide range of consumers by creating a tool that accepts BIDS-formatted data.


Neuroimaging experiments result in complicated data that can be arranged in many different ways. So far there is no consensus how to organize and share data obtained in neuroimaging experiments. Even two researchers working in the same lab can opt to arrange their data in a different way. Lack of consensus (or a standard) leads to misunderstandings and time wasted on rearranging data or rewriting scripts expecting certain structure. Here we describe a simple and easy-to-adopt way of organising neuroimaging and behavioral data. By using this standard you will benefit in the following ways:

Your data will be simple for another researcher to work with. You simply need to refer to this document to understand how the files are organised and formatted. Additionally, employing BIDS will reduce the time needed to comprehend and reuse data collected by individuals who have already left the lab. A growing variety of data analysis software programmes are available that can comprehend data arranged using BIDS (see the up to date list). 
Datasets organised using BIDS are accepted by databases like OpenNeuro.org. By utilising BIDS to structure and characterise your data as soon as it is acquired, you may reduce the extra time and effort required for publication and hasten the curation process if you ever intend to release your data publicly.

You may quickly identify missing values by using validation tools like the BIDS Validator to evaluate the consistency of your dataset. The International Neuroinformatics Coordinating Facility (INCF) and the INCF Neuroimaging Data Sharing (NIDASH) Task Force have supported BIDS, which was largely influenced by the internal format used by the OpenfMRI repository that is now known as OpenNeuro.org. In order to ensure that BIDS covers the majority of frequent experiments while still being understandable and simple to use, we consulted numerous neuroscientists while developing it. To reflect current lab procedures and make it accessible to a wide range of scientists with diverse backgrounds, the standard is purposefully built on the foundation of straightforward file formats and folder structures.


4. Tools

[Dcm2Bids](https://unfmontreal.github.io/Dcm2Bids/) is a package for reorganising NIfTI files from dcm2niix into the BIDS format.

here is an outline of the code used for a basic [tutorial](https://unfmontreal.github.io/Dcm2Bids/docs/tutorial/first-steps/) of the package


```{bash}
 -  conda install -c conda-forge dcm2niix \n
 -  conda install -c conda-forge dcm2bids
 -  mkdir dcm2bids-tutorial\n
 -  cd dcm2bids-tutorial\n
 -  dcm2bids_scaffold -o bids_project
 -  cd bids_project
 -  wget -O dcm_qa_[nih-master.zip](https://github.com/neurolabusc/dcm_qa_nih/archive/refs/heads/master.zip)
 -  mv sourcedata/dcm_qa_nih-master sourcedata/dcm_qa_nih
 -  ls sourcedata/dcm_qa_nih
 -  dcm2bids_helper --help
 -  dcm2bids_helper -d sourcedata/dcm_qa_nih/In/
 -  ls tmp_dcm2bids/helper
 -  nano code/dcm2bids_config.json
 -  dcm2bids -d sourcedata/dcm_qa_nih/In/ -p ID01 -c code/dcm2bids_config.json
```


for details on how to setup your config file check [here](https://unfmontreal.github.io/Dcm2Bids/docs/how-to/create-config-file/) and [here](https://andysbrainbook.readthedocs.io/en/latest/OpenScience/OS/BIDS_Overview.html?highlight=bids#understanding-dcm2bidss-configuration-file)


# References


[BIDS 1](https://bids-specification.readthedocs.io/en/latest/)

[BIDS 2](https://bids.neuroimaging.io/governance.html)

[Dcm2Bids](https://unfmontreal.github.io/Dcm2Bids/docs/tutorial/first-steps/)



