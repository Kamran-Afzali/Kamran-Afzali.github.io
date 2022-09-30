## AFNI Commands and Preprocessing


Among all of the fMRI analysis packages, AFNI has the reputation of being the most difficult to learn. Although this may have been true in the past, the AFNI developers have worked hard over the last few years to make their software easier to learn and easier to use: in addition to the viewer, recent versions of AFNI contain other graphical user interfaces that can be accessed through the commands uber_subject.py and uber_ttest.py. These GUIs are used to create scripts which automate both the preprocessing and model setup for each subject.

Before we discuss those commands, however, we will review the basics of a typical AFNI command. The “uber” scripts, after all, simply compile large numbers of commands together in an order that processes the data. You will also be using individual AFNI commands to perform more advanced analyses, such as region of interest analysis.


The documentation and help files are some of AFNI’s greatest strengths. The usage of each command is clearly outlined, and the reasons for using different options are explained in detail. Sample commands are given to cover different scenarios - for example, if the skull-strip leaves too much skull in the output image, you are encouraged to use an option such as “-push_to_edge”.


## skull-stripping

The most basic usage of 3dSkullStrip is to use an “-input” flag to specify the anatomical dataset that will be stripped. For example,

3dSkullStrip -input sub-08_T1w.nii.gz


After about a minute, a new file called skull_strip_out+orig will be generated. This is the skull-stripped anatomical image, which you can view by opening up the AFNI viewer. Look in all three viewing panes to see how well the skull-stripping worked; you will probably notice a few voxels of cortex being removed in the frontal lobes and some bits of dura mater left around the top and the back of the skull, but overall the skull-stripping did very well.

Although the skull-stripping worked reasonably well, and is probably fine for most purposes, let’s see if we can improve it by using any of the options specified in the help file. If you read it closely, you will notice an option, -push_to_edge, which helps avoid removing any parts of the cortex. In general, it is better to err on the side of including small bits of dura mater and other non-brain matter, as opposed to removing any parts of the cortex. It is also useful to add a -prefix option to label the output as something intelligible.

## slice-timing correction 

Unlike a photograph, in which the entire picture is taken in a single moment, an fMRI volume is acquired in slices. Each of these slices takes time to acquire - from tens to hundreds of milliseconds.

The two most commonly used methods for creating volumes are sequential and interleaved slice acquisition. Sequential slice acquisition acquires each adjacent slice consecutively, either bottom-to-top or top-to-bottom. Interleaved slice acquisition acquires every other slice, and then fills in the gaps on the second pass. Both of these methods are illustrated in the video below.


As you’ll see later on, when we model the data at each voxel we assume that all of the slices were acquired simultaneously. To make this assumption valid, the time-series for each slice needs to be shifted back in time by the duration it took to acquire that slice. Sladky et al. (2011) also demonstrated that slice-timing correction can lead to significant increases in statistical power for studies with longer TRs (e.g., 2s or longer), and especially in the dorsal regions of the brain.

Although slice-timing correction seems reasonable, there are some objections:

In general, it is best to not interpolate (i.e., edit) the data unless you need to;
For short TRs (e.g., around 1 second or less), slice-timing correction doesn’t appear to lead to any significant gains in statistical power; and
Many of the problems addressed by slice-timing correction can be resolved by using a temporal derivative in the statistical model (discussed later in the chapter on model fitting).
For now, we will do slice-timing correction, using the first slice as the reference. (This is specified by the -tzero 0 option of the 3dTshift command.) The code for running slice-timing correction will be found in lines 97-100 of your proc script:



  3dTshift -tzero 0 -quintic -prefix pb01.$subj.r$run.tshift \pb00.$subj.r$run.tcat+orig


This will slice-time correct each run with the first slice as a reference. (Keep in mind that in AFNI, everything is indexed starting at 0 - i.e., in this case 0 represents the first slice of the volume). The command also uses an option called -quintic, which resamples each slice using a 5th-degree polynomial. In other words, since we need to replace the values of the voxels within a slice, we can make it more accurate by using information from a larger number of other slices. This does introduce some degree of correlation between the slices, which we will attempt to correct for later by using 3dREMLfit to pre-whiten (i.e., de-correlate) the data.


## Registration and Normalization

Although most people’s brains are similar - everyone has a cingulate gyrus and a corpus callosum, for instance - there are also differences in brain size and shape. As a consequence, if we want to do a group analysis we need to ensure that each voxel for each subject corresponds to the same part of the brain. If we are measuring a voxel in the visual cortex, for example, we would want to make sure that every subject’s visual cortex is in alignment with each other.

This is done by Registering and Normalizing the images. Just as you would fold clothes to fit them inside of a suitcase, each brain needs to be transformed to have the same size, shape, and dimensions. We do this by normalizing (or warping) to a template. A template is a brain that has standard dimensions and coordinates - standard, because most researchers have agreed to use them when reporting their results. That way, if you normalize your data to that template and find an effect at coordinates X=3, Y=20, Z=42, someone else who has warped their data to the same template can check their results against yours. The dimensions and coordinates of the template brain are also referred to as standardized space.

An example of a commonly used template, the MNI152 brain. This is an average of 152 healthy adult brains, which represent the population that most studies draw from. If you are studying another population - such as children or the elderly, for example - consider using a template created from representatives of that population. (Question: Why is the template blurry?)
Affine Transformations

To warp the images to a template, we will use an affine transformation. This is similar to the rigid-body transformation described above in Motion Correction, but it adds two more transformations: zooms and shears. Whereas translations and rotations are easy enough to do with an everyday object such as a pen, zooms and shears are more unusual - zooms either shrink or enlarge the image, while shears take the diagonally opposite corners of the image and stretch them away from each other. The animation below summarizes these four types of linear transformations.

Registration and Normalization

Recall that we have both anatomical and functional images in our dataset. Our goal is to warp the functional images to the template so that we can do a group-level analysis across all of our subjects. Although it may seem reasonable to simply warp the functional images directly to the template, in practice that doesn’t work very well - the images are low-resolution, and therefore less likely to match up with the anatomical details of the template. The anatomical image is a better candidate.

Although this may not seem to help us towards our goal, in fact warping the anatomical image can assist with bringing the functional images into standardized space. Remember that the anatomical and functional scans are typically acquired in the same session, and that the subject’s head moves little, if at all, between the scans. If we have already normalized our anatomical image to a template and recorded what transformations were done, we can apply the same transformations to the functional images - provided they start in the same place as the anatomical image.

This alignment between the functional and anatomical images is called Registration. Most registration algorithms use the following steps:

Assume that the functional and anatomical images are in roughly the same location. If they are not, align the outlines of the images.
Take advantage of the fact that the anatomical and functional images have different contrast weightings - that is, areas where the image is dark on the anatomical image (such as cerebrospinal fluid) will appear bright on the functional image, and vice versa. This is called mutual information. The registration algorithm moves the images around to test different overlays of the anatomical and functional images, matching the bright voxels on one image with the dark voxels of another image, and the dark with the bright, until it finds a match that cannot be improved upon. (AFNI’s preferred approach is a method called LPC, or Local Pearson Correlation, which gives greater weight to those regions of the functional image that are brighter: see this paper for more details.)
Once the best match has been found, then the same transformations that were used to warp the anatomical image to the template are applied to the functional images.


Registration with AFNI’s align_epi_anat.py

The command align_epi_anat.py can do several preprocessing steps at once - registration, aligning the volumes of the functional images together, and slice-timing correction. In this example, however, we will just use it for registration. 

Normalization with AFNI’s @auto_tlrc

Once we have aligned the anatomical and functional images, we will first normalize the anatomical image to a template. These warps, as you will see in the next chapter, will be applied to the functional images as well. To normalize the anatomical image, we will use the @auto_tlrc command;


## Alignment and Motion Correction

https://andysbrainbook.readthedocs.io/en/latest/AFNI/AFNI_Short_Course/AFNI_Preprocessing/04_AFNI_Alignment.html


## Smoothing

Why Smooth?

It is common to smooth the functional data, or replace the signal at each voxel with a weighted average of that voxel’s neighbors. This may seem strange at first - why would we want to make the images blurrier than they already are?

It is true that smoothing does decrease the spatial resolution of your functional data, and we don’t want less resolution. But there are benefits to smoothing as well, and these benefits can outweigh the drawbacks. For example, we know that fMRI data contain a lot of noise, and that the noise is frequently greater than the signal. By averaging over nearby voxels we can cancel out the noise and enhance the signal.

Smoothing is done with AFNI’s 3dmerge command, which you will find under the “blur” header of the proc_Flanker script (lines 216-221). 

The -1blur_fwhm option specifies the amount to smooth the image, in millimeters - in this case, 4mm. -doall applies this smoothing kernel to each volume in the image, and the -prefix option, as always, specifies the name of the output dataset.

The last preprocessing steps will take these smoothed images and then scale them to have a mean signal intensity of 100 - so that deviations from the mean can be measured in percent signal change. Any non-brain voxels will then be removed by a mask, and these images will be ready for statistical analysis. To see how these last two preprocessing steps are done in AFNI, click the Next button.


