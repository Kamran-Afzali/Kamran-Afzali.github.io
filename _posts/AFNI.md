## AFNI Commands and Preprocessing

AFNI is an environment for processing and displaying functional MRI data. It was designed and written at MCW, largely by RW Cox, starting in 1994. AFNI runs under Unix+X11+Motif systems, including SGI and Linux. It now comprises over 100,000 lines of C source code, and its capabilities are continually being extended. In addition, a skilled C programmer can add interactive and batch functions to AFNI with relative ease.

AFNI refers both to the interactive program of that name, and to the entire software package. The basic unit of data storage is the "3D dataset", which consists of one or more 3D arrays of voxel values (bytes, shorts, floats, or complex numbers), plus some control information stored in a header file.

### AFNI Built-in Functions


Just the most obvious ones (much of the "fun" of AFNI comes from finding the unobvious functions):

+ Switch viewing/analysis between many different datasets.
+ Image display in axial, sagittal, and/or coronal views (including multi-image montages).
+ Display of graphs (line and surface) of data extracted from image viewers.
+ Time series graphing of square regions from image viewers.
+ Linked image/graph viewing of multiple 3D datasets (e.g., linked scrolling through multiple brains).
+ Transformation to Talairach coordinates (12 sub-volume piecewise linear method).
+ Computation of activation maps using the "correlation method".
+ Color overlay of activation maps onto higher-resolution anatomical images (resampling of lower-resolution functionals is handled on the fly).
+ Interactive thresholding of functional overlays.

Among all of the fMRI analysis packages, AFNI has the reputation of being the most difficult to learn. Although this may have been true in the past, the AFNI developers have worked hard over the last few years to make their software easier to learn and easier to use: in addition to the viewer, recent versions of AFNI contain other graphical user interfaces that can be accessed through the commands uber_subject.py and uber_ttest.py. These GUIs are used to create scripts which automate both the preprocessing and model setup for each subject.

Before we discuss those commands, however, we will review the basics of a typical AFNI command. The “uber” scripts, after all, simply compile large numbers of commands together in an order that processes the data. You will also be using individual AFNI commands to perform more advanced analyses, such as region of interest analysis.

The documentation and help files are some of AFNI’s greatest strengths. The usage of each command is clearly outlined, and the reasons for using different options are explained in detail. Sample commands are given to cover different scenarios - for example, if the skull-strip leaves too much skull in the output image, you are encouraged to use an option such as “-push_to_edge”.

## [Skull-Stripping](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dSkullStrip.html)

A program to extract the brain from surrounding.tissue from MRI T1-weighted images. 


The most basic usage of 3dSkullStrip is to use an “-input” flag to specify the anatomical dataset that will be stripped. For example,
  The simplest command would be:
  
        3dSkullStrip <-input DSET>
3dSkullStrip -input sub-08_T1w.nii.gz


Also consider the script @SSwarper, which combines the use of 3dSkullStrip and nonlinear warping to an MNI template to produce a skull-stripped dataset in MNI space, plus the nonlinear warp that can used to transform other datasets from the same subject (e.g., EPI) to MNI space. (This script only applies to human brain images.) 

After about a minute, a new file called skull_strip_out+orig will be generated. This is the skull-stripped anatomical image, which you can view by opening up the AFNI viewer. Look in all three viewing panes to see how well the skull-stripping worked; you will probably notice a few voxels of cortex being removed in the frontal lobes and some bits of dura mater left around the top and the back of the skull, but overall the skull-stripping did very well.

Although the skull-stripping worked reasonably well, and is probably fine for most purposes, let’s see if we can improve it by using any of the options specified in the help file. If you read it closely, you will notice an option, -push_to_edge, which helps avoid removing any parts of the cortex. In general, it is better to err on the side of including small bits of dura mater and other non-brain matter, as opposed to removing any parts of the cortex. It is also useful to add a -prefix option to label the output as something intelligible.

## [Slice-Timing Correction](https://afni.nimh.nih.gov/pub/dist/doc/program_help/3dTshift.html)

Unlike a photograph, in which the entire picture is taken in a single moment, an fMRI volume is acquired in slices. Each of these slices takes time to acquire - from tens to hundreds of milliseconds.

The two most commonly used methods for creating volumes are sequential and interleaved slice acquisition. Sequential slice acquisition acquires each adjacent slice consecutively, either bottom-to-top or top-to-bottom. Interleaved slice acquisition acquires every other slice, and then fills in the gaps on the second pass. Both of these methods are illustrated in the video below.


As you’ll see later on, when we model the data at each voxel we assume that all of the slices were acquired simultaneously. To make this assumption valid, the time-series for each slice needs to be shifted back in time by the duration it took to acquire that slice. Sladky et al. (2011) also demonstrated that slice-timing correction can lead to significant increases in statistical power for studies with longer TRs (e.g., 2s or longer), and especially in the dorsal regions of the brain.

Although slice-timing correction seems reasonable, there are some objections:

In general, it is best to not interpolate (i.e., edit) the data unless you need to;
For short TRs (e.g., around 1 second or less), slice-timing correction doesn’t appear to lead to any significant gains in statistical power; and
Many of the problems addressed by slice-timing correction can be resolved by using a temporal derivative in the statistical model (discussed later in the chapter on model fitting).



For now, we will do slice-timing correction, using the first slice as the reference. (This is specified by the -tzero 0 option of the 3dTshift command.) The code for running slice-timing correction will be found in lines 97-100 of your proc script:

 3dTshift 

Shifts voxel time series from the input dataset so that the separate slices are aligned to the same temporal origin.  By default, uses the slicewise shifting information in the dataset header (from the 'tpattern'input to program to3d).

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

The concept is the same when we take three-dimensional pictures of the brain. If the subject is moving, the images will look blurry; if the subject is still, the images will look less blurry and more defined. But that’s not all: If the subject moves a lot, we also risk measuring signal from a voxel that moves. We are then in danger of measuring signal from the voxel for part of the experiment and, after the subject moves, from a different region or tissue type.

These motions can also introduce confounds into the imaging data because motion generates signal. If the subject moves every time in response to a stimulus - for example, if he jerks his head every time he feels an electrical shock - then it can become impossible to determine whether the signal we are measuring is in response to the stimulus, or because of the movement.

Rigid-Body Transformations

One way to “undo” these motions is through rigid-body transformations. To illustrate this, pick up a nearby object: a phone or a coffee cup, for example. Place it in front of you and mentally mark where it is. This is the reference point. Then move the object an inch to the left. This is called a translation, which means any movement to the left or right, forward or back, up or down. If you want the object to come back to where it started, you would simply move it an inch to the right.

Similarly, if you rotated the object to the left or right, you could undo that by rotating it an equal amount in the opposite direction. These are called rotations, and like translations, they have three degrees of freedom, or ways that they can move: around the x-axis (also called pitch, or tilting forwards and backwards), around the y-axis (also known as roll, or tilting to the left and right), and around the z-axis (or yaw, as when shaking your head “no”).

We do the same procedure with our volumes. Instead of the reference point we used in the example above, let’s call the first volume in our time-series the reference volume. If at some point during the scan our subject moves his head an inch to the right, we can detect that movement and undo it by moving that volume an inch to the left. The goal is to detect movements in any of the volumes and realign those volumes to the reference volume.

AFNI’s 3dvolreg

Motion correction in AFNI is done using the command 3dvolreg. In a typical analysis script generated by uber_subject.py, there will be a block of code highlighted with the header ======volreg======. There are several commands in this block, but the most important one for our present purposes is the line that begins with “3dvolreg”.

You will see several options used with this command. The -base option is the reference volume; in this case, the reference image is the volume that has the lowest amount of outliers in its voxels, as determined by an earlier command, 3dToutcount. The -1Dfile command writes the motion parameters into a text file with a “1D” appended to it, and -1Dmatrix_save saves an affine matrix which indicates how much each TR would need to be “unwarped” along each of the affine dimensions in order to match the reference image.

## Smoothing

Why Smooth?

It is common to smooth the functional data, or replace the signal at each voxel with a weighted average of that voxel’s neighbors. This may seem strange at first - why would we want to make the images blurrier than they already are?

It is true that smoothing does decrease the spatial resolution of your functional data, and we don’t want less resolution. But there are benefits to smoothing as well, and these benefits can outweigh the drawbacks. For example, we know that fMRI data contain a lot of noise, and that the noise is frequently greater than the signal. By averaging over nearby voxels we can cancel out the noise and enhance the signal.

Smoothing is done with AFNI’s 3dmerge command, which you will find under the “blur” header of the proc_Flanker script (lines 216-221). 

The -1blur_fwhm option specifies the amount to smooth the image, in millimeters - in this case, 4mm. -doall applies this smoothing kernel to each volume in the image, and the -prefix option, as always, specifies the name of the output dataset.

The last preprocessing steps will take these smoothed images and then scale them to have a mean signal intensity of 100 - so that deviations from the mean can be measured in percent signal change. Any non-brain voxels will then be removed by a mask, and these images will be ready for statistical analysis. To see how these last two preprocessing steps are done in AFNI, click the Next button.

## Masking and Scaling

Masking

As you saw in previous tutorials, a volume of fMRI data includes both the brain and the surrounding skull and neck - regions that we are not interested in analyzing with AFNI, even though they do contain voxels with time-series data just as the brain voxels do. And, although it may not be obvious at first glance, we have large numbers of voxels that comprise the air outside the head.

To reduce the size of our datasets and consequently speed up our analyses, we can apply a mask to our data. A mask simply indicates which voxels are to be analyzed - any voxels within the mask retain their original values (or can be assigne a value of 1), whereas any voxels outside mask are assigned a value of zero. It is analogous to tracing an outline of a drawing with tracing paper, and then cutting along the lines and keeping whatever falls inside the lines, discarding the rest. Applied to fMRI data, anything outside the mask we assume to be noise or something of no interest.

Masks are created with AFNI’s 3dAutomask command, which only requires arguments for input and output datasets (lines 223-260 of the proc_Flanker script).
The rest of the code within the “mask” block creates a union of masks that represents the extent of all of the individual fMRI datasets in the experiment.

Scaling

One problem with fMRI data is that we collect data with units that are arbitrary, and of themselves meaningless. The intensity of the signal that we collect can vary from run to run, and from subject to subject. The only way to create a useful comparison within or between subjects is to take the contrast of the signal intensity between conditions, as represented by a beta weight (which will be discussed later in the chapter on statistics).

In order to make the comparison of signal intensity meaningful between studies as well, AFNI scales the timeseries in each voxel individually to a mean of 100.

These changes will be reflected in the time-series; the first image below represents the time-series before scaling, and the next image shows the time-series after scaling. Note that the values in the first image are relatively high - in the 800s - and that they are arbitrary; they could just as easily be around 500 or 900 in another subject. By scaling each subject’s data to the same mean, as in the second image, we can place each run of each subject’s data on the same scale.

## First-Level Analysis

https://andysbrainbook.readthedocs.io/en/latest/AFNI/AFNI_Short_Course/AFNI_Statistics/AFNI_06_Stats_Running_1stLevel_Analysis.html

## Group Analysis

Our goal in analyzing this dataset is to generalize the results to the population that the sample was drawn from. In other words, if we see changes in brain activity in our sample, can we say that these changes would likely be seen in the population as well?

To test this, we will run a group-level analysis (also known as a second-level analysis). In AFNI, this means that we calculate the standard error and the mean for a contrast estimate, and then test whether the average estimate is statistically significant. We will be doing this group-level analysis in two ways: Using 3dttest, which uses only the contrast estimates in testing for statistical significance; and using 3dMEMA, which accounts for both the difference between the parameter estimates, and the variability of that contrast.

The first field, “program”, allows you to choose between 3dttest and 3dMEMA. As noted above, 3dMEMA allows you to account for the variability of the estimate as well, in order to give more weight to those subjects who have lower variability in their estimates. For now, leave it as “3dttest”.

In both the “script name” and “dset prefix” fields, enter Flanker_Inc-Con_ttest. For the “mask dset”, you can choose any one of the subject’s mask_group+tlrc images located in their results directories, as they should be similar. If you want to be more rigorous, you can calculate an intersection of the masks using AFNI’s 3dmask_tool command. The command would look something like this:

3dmask_tool -input <path/to/masks/> -prefix mask_intersection+tlrc -union


We will now select each of the subject statistical datasets, using wildcards. If you click on the button “get subj dsets” in the “datasets A” section, you will be prompted to select a representative stats dataset. Select any of the subjects’ statistical datasets, and replace the last two numbers of the subject ID with two question marks (i.e., ??). Then click on “apply pattern”. If all of the subjects were analyzed the same way and have the same directory structure, you should see 26 entries in the field below. Review them to make sure they are all there, and then click “OK”.


At the bottom of the “datasets A” section, you will see a few additional fields. In “set name (group of class), write Inc-Con, and in “data index/label” type 7.

Why 7? If you open a Terminal and navigate to any of the subjects’ results directories (for example, sub-08), type

3dinfo -verb stats.sub-08+tlrc


This will show all of the sub-briks in that dataset, along with their labels. In our current example, we are looking for the contrast estimates for incongruent-congruent. The output of 3dinfo shows that this is located in sub-brik 7. Any sub-brik that contains the label “Coef” means that it is a parameter (or contrast) estimate; the label “Tstat” indicates that it is a t-statistic. (Likewise, “Fstat” means that it is an F-statistic.)


Generating the Results

As with the uber_subject.py script, there are buttons at the top of the GUI for both generating the script and then running the script. First click on the icon that looks like a sheet of paper with lines on it, which will show you the command that has been generated. Review it to see how it has inserted all of your inputs into a command called 3dttest++, which will run the actual group-level analysis. Then click on the green “Go” icon to run the test. (It should take only a second.)

When it has finished, go back to your Terminal and type ls. You will see a new directory called group_results, and within that a folder called test.001.3dttest++. Navigate into that folder, which contains the script that was used to generate the results (“Flanker_Inc-Con_ttest”), and another folder called test.results, which contains the group-level output “Flanker_Inc-Con_ttest+tlrc”. Load this in the afni viewer, and overlay it on top of the MNI152 template. Threshold the images to an uncorrected p-value of 0.001 (by right-clicking on the “p=” underneath the slider bar) and clusterize the data to only show clusters with an extent of 40 voxels or more; this will create an image like the one below. Does the location of the activation make sense, given the task and the paper this experiment was based on?

## ROI Analysis

Overview

You’ve just completed a group-level analysis, and identified which regions of the brain show a significant difference between the Incongruent and Congruent conditions of the experiment. For some researchers, this may be all that they want to do.

This kind of analysis is called a whole-brain or exploratory analysis. These types of analyses are useful when the experimenter doesn’t have a hypothesis about where the difference may be located; the result will be used as the basis for future research.

When a large number of studies have been run about a specific topic, however, we can begin to make more specific hypotheses about where we should find our results in the brain images. For example, cognitive control has been studied for many years, and many fMRI studies have been published about it using different paradigms that compare more cognitively demanding tasks to less cognitively demanding tasks. Often, significant increases in the BOLD signal during cognitively demanding conditions are seen in a region of the brain known as the dorsal medial prefrontal cortex, or dmPFC for short. For the Flanker study, then, we could restrict our analysis to this region and only extract data from voxels within that region. This is known as a region of interest (ROI) analysis. A general name for an analysis in which you choose to analyze a region selected before you look at whole-brain results is called a confirmatory analysis.

Whole-brain maps can hide important details about the effects that we’re studying. We may find a significant effect of incongruent-congruent, but the reason the effect is significant could be because incongruent is greater than congruent, or because congruent is much more negative than congruent, or some combination of the two. The only way to determine what is driving the effect is with ROI analysis, and this is especially important when dealing with interactions and more sophisticated designs.

Using Atlases

One way to create a region for our ROI analysis is to use an atlas, or a map that partitions the brain into anatomically distinct regions.

AFNI comes with several atlases in both Talairach and MNI space, which can be accessed through the AFNI GUI. Finding the atlases can be difficult - you must first click on Define Datamode, and then click on Plugins, and from the dropdown menu select Draw Dataset. The figure below shows the Draw Dataset window.

Once you have opened the Draw Dataset window, you will first need to click on the button Choose dataset for copying. Since all of our data has been normalized to the MNI_avg152T1 template, we have two options:

Select the MNI_avg152T1+tlrc template from the abin directory; or
Select one of the normalized anatomical images from the Flanker dataset.
In both cases, the images will be in MNI space and will have the same dimensions and voxel resolution. The purpose of making a copy of that dataset is to create a “clean” dataset with the same dimensions as the other images, but which we can write on by marking whichever voxels we want to belong to our ROI. In this case, navigate to the sub-01/sub-01.results directory, open the AFNI GUI, and open the Draw Dataset window. For the image to copy, select the file anat_file.sub-01.

Once you have done that, you have several different atlases to select from. For the current tutorial, select the atlas DD_Desai_MPM, and then click on the dropdown menu below it. You have many different regions to choose from, and the voxels represented by each label can be guessed at by the name; for example, ctx_lh_G_and_S_frontomargin probably refers to the cortical voxels of the gyrus and sulcus of the frontomarginal region of the left hemisphere.

Select ctx_lh_G_and_S_cingul_-Mid_Ant, and then click on the button Load: InFill. This will highlight in red all of the voxels belonging to that region of the atlas. You can undo this by clicking on the Undo button, which keeps several steps in memory. Now right-click the area to the left of the label dropdown menu to open a more compact view of the atlas regions, and select ctx_rh_G_and_S_cingul-Mid-Ant. Click on Load: InFill to add that region to the current mask, and then click SaveAs. Call the output midACC. This will create a new file that contains values of “1” in the voxels that belong to the region, and zeros everywhere else; this is also known as a mask. When you are finished, click Done.

Extracting Data from the Anatomical Mask

Once you’ve created the mask, you can then extract each subject’s contrast estimates from it. There are two ways that we could extract our contrast of interest Incongruent-Congurent:

Extract the contrast estimate Incongruent-Congruent from our stats file; or
Extract the individual beta weights for Incongruent and Congruent separately, and then take the difference between the two.
As we will see, option #2 allows you to determine what is driving the effect; in other words, whether a significant effect is due to both beta weights being positive but the Incongruent beta weights being more positive, both weights being negative but the Congruent betas more negative, or a combination of the two. It is only by extracting both sets of beta weights that we can determine this.

## References

https://afni.nimh.nih.gov/

