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

https://andysbrainbook.readthedocs.io/en/latest/AFNI/AFNI_Short_Course/AFNI_Preprocessing/03_AFNI_Registration_Normalization.html
