---
layout: post
categories: posts
title: Neuroimaging Data Preprocessing
featured-image: /images/machineLearning.png
tags: [Preprocessing, NeuroImaging, Nifti]
date-string: April 2022
---

## Neuroimaging Data Preprocessing

The process of improving the neuro imaging data and getting it ready for statistical analysis is referred to as preprocessing. The goal is to reduce the noise before we can carry out any analyses. The pipeline for preparing neuroimaging data consists of a series of steps to eliminate noise. The process may adjust or correct the data for a number of factors inherent in the experimental setting, including head movement during scanning, time differences between image acquisitions, "artifacts" (anomalous measurements) that should be excluded from further analysis, alignment of the functional images with the reference structural image, and normalisation of the data into a standard space so that the data can be compared. Now, let's take a closer look at each of those actions. 

This post will cover following subjects:

+ Segmentation
+ Motion correction
+ Slice Timing Correction
+ Realignment
+ Coregistration
+ Spatial Normalization
+ Spatial Smoothing


#### Segmentation (sMRI)

The process of segmentation involves dividing the brain into its many neurological *types* in accordance with a predetermined template specification. This can be quite general, like when the brain is divided into the cerebrospinal fluid, white matter, and grey matter using SPM's Segmentation, or quite detailed, like when the brain is divided into specific functional regions and their subregions using FreeSurfer's recon-all function. Different purposes can be achieved by segmentation, a particular segmentation  can be used as a mask or as the definition of a particular region of interest, to help the normalisation process, or additional ROI analysis.

#### Motion Correction or Realignment (fMRI)


In order to understand underlying neurological processes, it is crucial to make sure that a given voxel maintains the same 3D coordinate over all time points. This is made more challenging by the fact that participants move both during and in between scans. In the resting-state literature, where many analyses are based on functional connectivity, head motion can lead to spurious correlations. Some researchers choose to exclude any subject that moved more than certain amount. Other’s choose to remove the impact of these time points in their data through removing the volumes via scrubbing or modeling out the volume with a dummy code in the first level general linear models. Head movement is corrected by using *motion correction*. Data's quality is decreased by unintentional fluctuation in voxel position, which can be caused by even the smallest head movements. Motion correction aims to lessen the effect of movement on the data by modifying your data to fit a reference time volume. This reference time volume is often the mean (average) image of all timepoints, or the initial time point. There are six factors that can be used to describe head movement: There are three translation parameters that represent movement along the X, Y, or Z axes in three dimensions. While motion correction tries to account for lesser movements, there are occasions when it is preferable to just discard the slices that were taken during extreme  movement. Artifact detection is used to identify the timepoints/images of the functional image that vary so much they should be excluded from further analysis and to label them so they are excluded from subsequent analyses. Motion correction usually uses an affine rigid body transformation to manipulate the data in those six parameters. That is, each image can be moved but not distorted to best align with all the other images.  

#### Slice Timing Correction (fMRI)

Functional MRI measurement sequences don’t acquire every slice in a volume at the same time, hence we have to account for the time differences among the slices. For example, if you acquire a volume with 37 slices in ascending order, and each slice is acquired every 50ms, there is a difference of 1.8s between the first and the last slice acquired. Slices are commonly acquired using one of three techniques: interleaved (acquire every other slice in each direction), descending order (top-down), or ascending order (bottom-up). Slice Timing Correction compensates for the time intervals between slice acquisitions by temporally interpolating the slices, resulting in a volume that is very similar to recording the full brain image at a single time point. It is crucial to address this acquisition time temporal component in fMRI models where timing is a crucial factor (For instance, in event-related designs where the stimulus type shifts from volume to volume).

#### Coregistration

Coregistration, aims to properly superimpose the functional image on the anatomical image. This makes it possible to immediately apply further anatomical image changes, like normalization, to the functional image.

#### Normalization

The brains of each individual differ slightly from one another. Size and shape of the brains vary. It is necessary to first normalise the brain images onto a standard shape and size in order to compare one person's brain images to another. Data from each subject-space where it was measured are mapped onto a reference-space during normalisation. A group analysis or data comparison can be done after this phase is finished. Data normalisation can be done in a variety of methods, but it always starts with a template and a source picture. To map your data onto, the template image represents the typical brain in reference space. The transformation matrix required to transfer the source image onto the template image is calculated using the source image, which is typically a higher resolution structural image. The remainder of your images (functional and structural) are then mapped into the reference-space using this transformation matrix. The primary preprocessing step is spatial normalization, which involves warping the brain data of each subject into a similar stereotactic space. There are other preprocessing processes as well. An older area called Talaraich has been absorbed by a number of standards created by the Montreal Neurological Institute. Many different algorithms can be used to warp subject data into stereotactic space. More complex nonlinear normalisations with hundreds to thousands of parameters are replacing simpler linear 12 parameter affine transformations. Diffeomorphic registration, a nonlinear technique that may also be inverted to change subject space into stereotactic space and back again, has demonstrated excellent performance across comparison studies. This is the main component of the ANTs algorithm used in fmriprep. 


#### Spatial Smoothing

Spatial smoothing is the last procedure we'll go through in the preprocessing pipeline. In this step, the image is filtered to remove high frequency spatial information. This phase is the same as when we convolve a kernel to a 1-D signal in the lab for signal processing fundamentals, but in this case, the kernel is a 3-D Gaussian kernel. Using the Full Width at Half Maximum (FWHM) parameter, the width of the distribution (i.e., the standard deviation) is specified to define the degree of smoothing. By lessening the effects of partial volume effects, lingering anatomical variations after normalisation, and other aliasing from performing spatial transformation, this step may assist improve the signal to noise ratio. Applying a filter to the image smooths out both functional and structural images. Through the removal of the highest frequencies from the frequency domain, smoothing improves the signal to noise ratio of your data. Individuals' functional locations vary somewhat naturally, and smoothing reduces spatial disparities between subjects to make it easier to compare several participants. Naturally, smoothing has a trade-off in that you lose resolution. But keep in mind that smoothing can lead to the combination of functionally distinct parts. A 3D Gaussian kernel is used to smooth the image; the amount of smoothing is commonly controlled by the kernel's full width at half maximum (FWHM) parameter. The smoothing kernel's width/diameter at half its height, or FWHM, is what the name suggests. The value of each voxel is altered to reflect the outcome of applying this smoothing kernel to its initial value. Your purpose for smoothing will also influence the smoothing kernel size that you choose. A huge kernel could smooth your data too much if you only want to analyse a tiny area. Generally speaking, the filter shouldn't be bigger than the activation you're seeking to find. Thus, the question you're trying to answer influences how much smoothing you should apply. Some writers advise starting with voxel dimensions that are twice as large.

### References
+ https://dartbrains.org/content/Introduction_to_Neuroimaging_Data.html#
+ https://dartbrains.org/content/Signal_Processing.html
+ https://dartbrains.org/content/Preprocessing.html
+ http://neuroimaging-data-science.org/content/005-nipy/001-nipy.html
+ https://miykael.github.io/nipype-beginner-s-guide/neuroimaging.html
