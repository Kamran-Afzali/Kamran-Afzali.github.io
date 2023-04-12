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


In order to describe neurological processes, it is crucial to make sure that a given voxel maintains the same 3D coordinate over all time points. Naturally, this is made more challenging by the fact that participants move both during and in between scans. During the collection of functional data, head movement is compensated by using motion correction, also known as realignment. Even slight head motions cause unintended voxel fluctuation, which lowers the quality of your data. By adjusting your data to match a reference time volume, motion correction attempts to reduce the impact of movement on your data. Typically, the first time point or another time point's mean picture of all timepoints makes up this reference time volume. Head movement can be characterized by six parameters: Three translation parameters which code movement in the directions of the three dimensional axes, movement along the X, Y, or Z axes; and three rotation parameters which code rotation about those axes, rotation centered on each of the X, Y, and Z axes). Motion correction tries to correct for smaller movements, but sometimes it’s best to just remove the images acquired during extreme rapid movement. We use Artifact Detection to identify the timepoints/images of the functional image that vary so much they should be excluded from further analysis and to label them so they are excluded from subsequent analyses. Motion correction usually uses an affine rigid body transformation to manipulate the data in those six parameters. That is, each image can be moved but not distorted to best align with all the other images. In the resting-state literature, where many analyses are based on functional connectivity, head motion can lead to spurious correlations. Some researchers choose to exclude any subject that moved more than certain amount. Other’s choose to remove the impact of these time points in their data through removing the volumes via scrubbing or modeling out the volume with a dummy code in the first level general linear models. 

#### Slice Timing Correction (fMRI)

Functional MRI measurement sequences don’t acquire every slice in a volume at the same time we have to account for the time differences among the slices. For example, if you acquire a volume with 37 slices in ascending order, and each slice is acquired every 50ms, there is a difference of 1.8s between the first and the last slice acquired. To apply the correct correction, you must be aware of the order in which the slices were acquired. Slices are commonly acquired using one of three techniques: interleaved (acquire every other slice in each direction), descending order (top-down), or ascending order (bottom-up). Slice Timing Correction compensates for the time intervals between slice acquisitions by temporally interpolating the slices, resulting in a volume that is very similar to recording the full brain image at a single time point. It is crucial to address this acquisition time temporal component in fMRI models where timing is a crucial factor. (For instance, in event-related designs where the stimulus type shifts from volume to volume).

#### Coregistration

The functional image and the reference structural image are aligned using coregistration. The functional picture is moved around on the reference image during coregistration until the alignment is optimal. Coregistration, in other words, aims to properly superimpose the functional image on the anatomical image. This makes it possible to immediately apply further anatomical image changes, like normalization, to the functional image.

#### Normalization

Every person’s brain is slightly different from every other’s. Brains differ in size and shape. To compare the images of one person’s brain to another’s, the images must first be translated onto a common shape and size, which is called normalization. Normalization maps data from the individual subject-space it was measured in onto a reference-space. Once this step is completed, a group analysis or comparison among data can be performed. There are different ways to normalize data but it always includes a template and a source image. The template image is the standard brain in reference-space onto which you want to map your data. This can be a Talairach-, MNI-, or SPM-template, or some other reference image you choose to use. The source image (normally a higher resolution structural image) is used to calculate the transformation matrix necessary to map the source image onto the template image. This transformation matrix is then used to map the rest of your images (functional and structural) into the reference-space. There are several other preprocessing steps with the main one  being spatial normalization, in which each subject’s brain data is warped into a common stereotactic space. Talaraich is an older space, that has been subsumed by various standards developed by the Montreal Neurological Institute. There are a variety of algorithms to warp subject data into stereotactic space. Linear 12 parameter affine transformation have been increasingly been replaced by more complicated nonlinear normalizations that have hundreds to thousands of parameters. One nonlinear algorithm that has performed very well across comparison studies is diffeomorphic registration, which can also be inverted so that subject space can be transformed into stereotactic space and back to subject space. This is the core of the ANTs algorithm that is implemented in fmriprep. 


#### Spatial Smoothing

The last step we will cover in the preprocessing pipeline is spatial smoothing. This step involves applying a filter to the image, which removes high frequency spatial information. This step is identical to convolving a kernel to a 1-D signal that we covered in the Signal Processing Basics lab, but the kernel here is a 3-D Gaussian kernel. The amount of smoothing is determined by specifying the width of the distribution (i.e., the standard deviation) using the Full Width at Half Maximum (FWHM) parameter. This step may help increase the signal to noise ratio by reducing the impact of partial volume effects, residual anatomical differences following normalization, and other aliasing from applying spatial transformation. Structural as well as functional images are smoothed by applying a filter to the image. Smoothing increases the signal to noise ratio of your data by filtering the highest frequencies from the frequency domain; that is, removing the smallest scale changes among voxels. That helps to make the larger scale changes more apparent. There is some inherent variability in functional location among individuals, and smoothing helps to reduce spatial differences between subjects and therefore aids comparing multiple subjects. The trade-off, of course, is that you lose resolution by smoothing. Keep in mind, though, that smoothing can cause regions that are functionally different to combine with each other. Smoothing is implemented by applying a 3D Gaussian kernel to the image, and the amount of smoothing is typically determined by its full width at half maximum (FWHM) parameter. As the name implies, FWHM is the width/diameter of the smoothing kernel at half of its height. Each voxel’s value is changed to the result of applying this smoothing kernel to its original value. Choosing the size of the smoothing kernel also depends on your reason for smoothing. If you want to study a small region, a large kernel might smooth your data too much. The filter shouldn’t generally be larger than the activation you’re trying to detect. Thus, the amount of smoothing that you should use is determined partly by the question you want to answer. Some authors suggest using twice the voxel dimensions as a reasonable starting point.



### References
+ https://dartbrains.org/content/Introduction_to_Neuroimaging_Data.html#
+ https://dartbrains.org/content/Signal_Processing.html
+ https://dartbrains.org/content/Preprocessing.html
+ http://neuroimaging-data-science.org/content/005-nipy/001-nipy.html
+ https://miykael.github.io/nipype-beginner-s-guide/neuroimaging.html
