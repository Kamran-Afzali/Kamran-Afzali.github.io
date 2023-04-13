---
layout: post
categories: posts
title: Neuroimaging Data Preprocessing
featured-image: /images/machineLearning.png
tags: [Preprocessing, NeuroImaging, Nifti]
date-string: April 2022
---

## Neuroimaging Data Preprocessing

The process of improving our data and getting it ready for statistical analysis is referred to as preprocessing. Doing our best to reduce the noise is a crucial step before we can carry out any studies. Our pipeline for preparing neuroimaging data consists of a series of stages to eliminate noise. The process may adjust or correct our data for a number of factors inherent in the experimental setting, including head movement during scanning, time differences between image acquisitions, "artifacts" (anomalous measurements) that should be excluded from further analysis, alignment of the functional images with the reference structural image, and normalisation of the data into a standard space so that the data can be compared. Now, let's take a closer look at each of those actions. 

This post will cover following subjects:

+ Segmentation
+ Motion correction
+ Slice Timing Correction
+ Realignment
+ Coregistration
+ Spatial Normalization
+ Spatial Smoothing


#### Segmentation (sMRI)

The process of segmentation involves dividing the brain into its many neurological regions in accordance with a predetermined template specification. This can be quite general, like when the brain is divided into the cerebrospinal fluid, white matter, and grey matter using SPM's Segmentation, or quite detailed, like when the brain is divided into specific functional regions and their subregions using FreeSurfer's recon-all, as shown in the figure. Different purposes can be served by segmentation. By employing a particular segmentation as a mask or as the definition of a particular region of interest, you can utilise the segmentation to help the normalisation process or use it to help with additional analysis. (ROI).

#### Motion Correction or Realignment (fMRI)


In order to describe neurological processes, it is crucial to make sure that a given voxel maintains the same 3D coordinate over all time points. Naturally, this is made more challenging by the fact that participants move both during and in between scans. During the collection of functional data, head movement is compensated by using motion correction, also known as realignment. Your data's quality is decreased by unintentional voxel fluctuation, which can be caused by even the smallest head movements. Motion correction aims to lessen the effect of movement on your data by modifying your data to fit a reference time volume. This reference time volume is often the mean picture of all timepoints from the initial time point or another time point. There are six factors that can be used to describe head movement: There are three translation parameters that represent movement along the X, Y, or Z axes in three dimensions. While motion correction tries to account for lesser movements, there are occasions when it is preferable to just discard the photos that were taken during extremely rapid movement. We use Artifact Detection to identify the timepoints/images of the functional image that vary so much they should be excluded from further analysis and to label them so they are excluded from subsequent analyses. Motion correction usually uses an affine rigid body transformation to manipulate the data in those six parameters. That is, each image can be moved but not distorted to best align with all the other images. In the resting-state literature, where many analyses are based on functional connectivity, head motion can lead to spurious correlations. Some researchers choose to exclude any subject that moved more than certain amount. Other’s choose to remove the impact of these time points in their data through removing the volumes via scrubbing or modeling out the volume with a dummy code in the first level general linear models. 

#### Slice Timing Correction (fMRI)

Functional MRI measurement sequences don’t acquire every slice in a volume at the same time we have to account for the time differences among the slices. For example, if you acquire a volume with 37 slices in ascending order, and each slice is acquired every 50ms, there is a difference of 1.8s between the first and the last slice acquired. To apply the correct correction, you must be aware of the order in which the slices were acquired. Slices are commonly acquired using one of three techniques: interleaved (acquire every other slice in each direction), descending order (top-down), or ascending order (bottom-up). Slice Timing Correction compensates for the time intervals between slice acquisitions by temporally interpolating the slices, resulting in a volume that is very similar to recording the full brain image at a single time point. It is crucial to address this acquisition time temporal component in fMRI models where timing is a crucial factor. (For instance, in event-related designs where the stimulus type shifts from volume to volume).

#### Coregistration

The functional image and the reference structural image are aligned using coregistration. The functional picture is moved around on the reference image during coregistration until the alignment is optimal. Coregistration, in other words, aims to properly superimpose the functional image on the anatomical image. This makes it possible to immediately apply further anatomical image changes, like normalization, to the functional image.

#### Normalization

The brains of each individual differ slightly from one another. Size and shape of the brains vary. It is necessary to first normalise the brain images onto a standard shape and size in order to compare one person's brain images to another. Data from each subject-space where it was measured are mapped onto a reference-space during normalisation. A group analysis or data comparison can be done after this phase is finished. Data normalisation can be done in a variety of methods, but it always starts with a template and a source picture. To map your data onto, the template image represents the typical brain in reference space. The transformation matrix required to transfer the source image onto the template image is calculated using the source image, which is typically a higher resolution structural image. The remainder of your images (functional and structural) are then mapped into the reference-space using this transformation matrix. The primary preprocessing step is spatial normalization, which involves warping the brain data of each subject into a similar stereotactic space. There are other preprocessing processes as well. An older area called Talaraich has been absorbed by a number of standards created by the Montreal Neurological Institute. Many different algorithms can be used to warp subject data into stereotactic space. More complex nonlinear normalisations with hundreds to thousands of parameters are replacing simpler linear 12 parameter affine transformations. Diffeomorphic registration, a nonlinear technique that may also be inverted to change subject space into stereotactic space and back again, has demonstrated excellent performance across comparison studies. This is the main component of the ANTs algorithm used in fmriprep. 


#### Spatial Smoothing

The last step we will cover in the preprocessing pipeline is spatial smoothing. This step involves applying a filter to the image, which removes high frequency spatial information. This step is identical to convolving a kernel to a 1-D signal that we covered in the Signal Processing Basics lab, but the kernel here is a 3-D Gaussian kernel. The amount of smoothing is determined by specifying the width of the distribution (i.e., the standard deviation) using the Full Width at Half Maximum (FWHM) parameter. This step may help increase the signal to noise ratio by reducing the impact of partial volume effects, residual anatomical differences following normalization, and other aliasing from applying spatial transformation. Structural as well as functional images are smoothed by applying a filter to the image. Smoothing increases the signal to noise ratio of your data by filtering the highest frequencies from the frequency domain; that is, removing the smallest scale changes among voxels. That helps to make the larger scale changes more apparent. There is some inherent variability in functional location among individuals, and smoothing helps to reduce spatial differences between subjects and therefore aids comparing multiple subjects. The trade-off, of course, is that you lose resolution by smoothing. Keep in mind, though, that smoothing can cause regions that are functionally different to combine with each other. Smoothing is implemented by applying a 3D Gaussian kernel to the image, and the amount of smoothing is typically determined by its full width at half maximum (FWHM) parameter. As the name implies, FWHM is the width/diameter of the smoothing kernel at half of its height. Each voxel’s value is changed to the result of applying this smoothing kernel to its original value. Choosing the size of the smoothing kernel also depends on your reason for smoothing. If you want to study a small region, a large kernel might smooth your data too much. The filter shouldn’t generally be larger than the activation you’re trying to detect. Thus, the amount of smoothing that you should use is determined partly by the question you want to answer. Some authors suggest using twice the voxel dimensions as a reasonable starting point.



### References
+ https://dartbrains.org/content/Introduction_to_Neuroimaging_Data.html#
+ https://dartbrains.org/content/Signal_Processing.html
+ https://dartbrains.org/content/Preprocessing.html
+ http://neuroimaging-data-science.org/content/005-nipy/001-nipy.html
+ https://miykael.github.io/nipype-beginner-s-guide/neuroimaging.html
