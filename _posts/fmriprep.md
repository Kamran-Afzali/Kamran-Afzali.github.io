## Introduction


Preprocessing of functional magnetic resonance imaging (fMRI) involves numerous steps to clean and standardize the data before statistical analysis. Generally, researchers create ad hoc preprocessing workflows for each dataset, building upon a large inventory of available tools. The complexity of these workflows has snowballed with rapid advances in acquisition and processing. We introduce fMRIPrep, an analysis-agnostic tool that addresses the challenge of robust and reproducible preprocessing for fMRI data. fMRIPrep automatically adapts a best-in-breed workflow to the idiosyncrasies of virtually any dataset, ensuring high-quality preprocessing without manual intervention. By introducing visual assessment checkpoints into an iterative integration framework for software testing, we show that fMRIPrep robustly produces high-quality results on a diverse fMRI data collection. Additionally, fMRIPrep introduces less uncontrolled spatial smoothness than observed with commonly used preprocessing tools. fMRIPrep equips neuroscientists with an easy-to-use and transparent preprocessing workflow, which can help ensure the validity of inference and the interpretability of results.

The fMRIPrep workflow takes as principal input the path of the dataset that is to be processed. The input dataset is required to be in valid BIDS format, and it must include at least one T1w structural image and (unless disabled with a flag) a BOLD series. We highly recommend that you validate your dataset with the free, online BIDS Validator.

The exact command to run fMRIPRep depends on the Installation method. The common parts of the command follow the BIDS-Apps definition. 

Workflows for preprocessing of fMRI data produce two broad classes of outputs. First, preprocessed time series are derived from the original data after the application of retrospective signal corrections, spatiotemporal filtering, and resampling onto a target space
appropriate for analysis (e.g., a standardized anatomical reference).
Second, experimental confounds are additional time series such as physiological recordings and estimated noise sources that are useful
for analysis (e.g., to be modeled as nuisance regressors). Some commonly used confounds include motion parameters, framewise displacement9,
spatial s.d. of the data after temporal differencing8, and global signals, among others. Preprocessing may include further steps for denoising and estimation of confounds, such as dimensionalityreduction methods based on principal component analysis or independent component analysis. Two corresponding instances of these techniques are component-based noise correction (CompCor10) and automatic removal of motion artifacts (AROMA11).
The neuroimaging community is well equipped with tools that implement the majority of the individual steps of preprocessing
described so far (Table 1). These tools are readily available in software packages such as AFNI12, ANTs13, FreeSurfer14, FSL15, Nilearn16, and SPM17. Despite the wealth of accessible software and multiple attempts to outline best practices for preprocessing2,5,7,18, the large
variety of data-acquisition protocols has led to the use of ad hoc pipelines customized for nearly every study19. In practice, the neuroimaging community lacks a preprocessing workflow that reliably provides high-quality and consistent results from diverse datasets.


+ Anatomical T1-weighted brain extraction 
  - antsBrainExtraction.sh (ANTs) 
+ Anatomical surface reconstruction 
  - recon-all (FreeSurfer) 
+ Head-motion estimation (and correction)
  - MCFLIRT (FSL) 
+ Susceptibility-derived distortion estimation (and unwarping)
  - 3dqwarp (AFNI) 
+ Slice-timing correction 
  - 3dTshift (AFNI)
+ Intrasubject registration 
  - bbregister (FreeSurfer), FLIRT (FSL) 
+ Spatial normalization (intersubject co-registration) 
  - antsRegistration (ANTs) 
+ Surface sampling 
  - mri_vol2surf (FreeSurfer) 
+ Subspace projection denoising
  - MELODIC (FSL) 
+ Confounds 
  - In-house implementation fsl_motion_outliers (FSL), TAPAS PhysIO (SPM plug-in)
+ Detection of non-steady states 
  - In-house implementation Ad hoc implementations, manual setting


### Brain extraction, brain tissue segmentation and spatial normalization
Then, the T1w reference is skull-stripped using a Nipype implementation of the antsBrainExtraction.sh tool (ANTs), which is an atlas-based brain extraction workflow. Finally, spatial normalization to standard spaces is performed using ANTs’ antsRegistration in a multiscale, mutual-information based, nonlinear registration scheme. See Defining standard and nonstandard spaces where data will be resampled for information about how standard and nonstandard spaces can be set to resample the preprocessed data onto the final output spaces.

## Preprocessing of structural MRI 

### Cost function masking during spatial normalization
When processing images from patients with focal brain lesions (e.g., stroke, tumor resection), it is possible to provide a lesion mask to be used during spatial normalization to standard space [Brett2001]. ANTs will use this mask to minimize warping of healthy tissue into damaged areas (or vice-versa). Lesion masks should be binary NIfTI images (damaged areas = 1, everywhere else = 0) in the same space and resolution as the T1 image, and follow the naming convention specified in BIDS Extension Proposal 3: Common Derivatives (e.g., sub-001_T1w_label-lesion_roi.nii.gz). This file should be placed in the sub-*/anat directory of the BIDS dataset to be run through fMRIPrep. Because lesion masks are not currently part of the BIDS specification, it is also necessary to include a .bidsignore file in the root of your dataset directory.

### Surface preprocessing
fMRIPrep uses FreeSurfer to reconstruct surfaces from T1w/T2w structural images. If enabled, several steps in the fMRIPrep pipeline are added or replaced. All surface preprocessing may be disabled with the --fs-no-reconall flag. Surface reconstruction is performed in three phases. The first phase initializes the subject with T1w and T2w (if available) structural images and performs basic reconstruction (autorecon1) with the exception of skull-stripping. Skull-stripping is skipped since the brain mask calculated previously is injected into the appropriate location for FreeSurfer. 

### Refinement of the brain mask
Typically, the original brain mask calculated with antsBrainExtraction.sh will contain some innaccuracies including small amounts of MR signal from outside the brain. Based on the tissue segmentation of FreeSurfer (located in mri/aseg.mgz) and only when the Surface Processing step has been executed, fMRIPrep replaces the brain mask with a refined one that derives from the aseg.mgz file as described in RefineBrainMask.


## BOLD preprocessing 

BOLD reference image estimation workflow estimates a reference image for a BOLD series. If a single-band reference (“sbref”) image associated with the BOLD series is available, then it is used directly. If not, a reference image is estimated from the BOLD series as follows: When T1-saturation effects (“dummy scans” or non-steady state volumes) are detected, they are averaged and used as reference due to their superior tissue contrast. Otherwise, a median of motion corrected subset of volumes is used.

###  Head-motion estimation

Using the previously estimated reference scan, FSL mcflirt is used to estimate head-motion. As a result, one rigid-body transform with respect to the reference image is written for each BOLD time-step. Additionally, a list of 6-parameters (three rotations, three translations) per time-step is written and fed to the confounds workflow. For a more accurate estimation of head-motion, we calculate its parameters before any time-domain filtering (i.e., slice-timing correction), as recommended in [Power2017].

###  Slice time correction

If the SliceTiming field is available within the input dataset metadata, this workflow performs slice time correction prior to other signal resampling processes. Slice time correction is performed using AFNI 3dTShift. All slices are realigned in time to the middle of each TR.

Slice time correction can be disabled with the --ignore slicetiming command line argument. If a BOLD series has fewer than 5 usable (steady-state) volumes, slice time correction will be disabled for that run.

###  Resampling BOLD runs onto standard spaces

init_bold_std_trans_wf()

This sub-workflow concatenates the transforms calculated upstream (see Head-motion estimation, Susceptibility Distortion Correction (SDC) –if fieldmaps are available–, EPI to T1w registration, and an anatomical-to-standard transform from Preprocessing of structural MRI) to map the EPI image to the standard spaces given by the --output-spaces argument (see Defining standard and nonstandard spaces where data will be resampled). It also maps the T1w-based mask to each of those standard spaces.

Transforms are concatenated and applied all at once, with one interpolation (Lanczos) step, so as little information is lost as possible.

The output space grid can be specified using modifiers to the --output-spaces argument.

###  EPI to T1w registration

init_bold_reg_wf()

The alignment between the reference EPI image of each run and the reconstructed subject using the gray/white matter boundary (FreeSurfer’s ?h.white surfaces) is calculated by the bbregister routine. If FreeSurfer processing is disabled, FSL flirt is run with the BBR cost function, using the fast segmentation to establish the gray/white matter boundary. After BBR is run, the resulting affine transform will be compared to the initial transform found by FLIRT. Excessive deviation will result in rejecting the BBR refinement and accepting the original, affine registration.

###  EPI sampled to FreeSurfer surfaces

init_bold_surf_wf()


If FreeSurfer processing is enabled, the motion-corrected functional series (after single shot resampling to T1w space) is sampled to the surface by averaging across the cortical ribbon. Specifically, at each vertex, the segment normal to the white-matter surface, extending to the pial surface, is sampled at 6 intervals and averaged.

Surfaces are generated for the “subject native” surface, as well as transformed to the fsaverage template space. All surface outputs are in GIFTI format.

###  Confounds estimation

init_bold_confs_wf()

Given a motion-corrected fMRI, a brain mask, mcflirt movement parameters and a segmentation, the discover_wf sub-workflow calculates potential confounds per volume.

Calculated confounds include the mean global signal, mean tissue class signal, tCompCor, aCompCor, Frame-wise Displacement, 6 motion parameters, DVARS, spike regressors, and, if the --use-aroma flag is enabled, the noise components identified by ICA-AROMA (those to be removed by the “aggressive” denoising strategy). Particular details about ICA-AROMA are given below.

###  ICA-AROMA

ICA-AROMA denoising is performed in MNI152NLin6Asym space, which is automatically added to the list of --output-spaces if it was not already requested by the user. The number of ICA-AROMA components depends on a dimensionality estimate made by FSL MELODIC. For datasets with a very short TR and a large number of timepoints, this may result in an unusually high number of components. By default, dimensionality is limited to a maximum of 200 components. To override this upper limit one may specify the number of components to be extracted with --aroma-melodic-dimensionality. Further details on the implementation are given within the workflow generation function (init_ica_aroma_wf()).

Note: non-aggressive AROMA denoising is a fundamentally different procedure from its “aggressive” counterpart and cannot be performed only by using a set of noise regressors (a separate GLM with both noise and signal regressors needs to be used). Therefore instead of regressors, fMRIPrep produces non-aggressive denoised 4D NIFTI files in the MNI space

## Technical points

### Running fMRIPrep 
Timing 2–15 h of computing time per subject, depending on the number and resolution of BOLD runs, T1w reference quality, data acquisition parameters (e.g., longer for multiband fMRI data) and the workflow configuration 10 Run fMRIPrep. Figure 2 describes an example of batch prescription file $STUDY/fmriprep. sbatch and the elements that may be customized for the particular execution environment.

### Inspection of all visual reports generated by fMRIPrep
Timing 5–20 min per subject, depending on the number of BOLD runs Alongside the corresponding preprocessed data (Box 3, Outcomes), fMRIPrep will generate one HTML (hypertext markup language) report per subject. Screen these reports to ensure sufficient quality of preprocessed data (e.g., accuracy of image registration processes, correctness of artifact correction techniques, etc.). Checking the visual reports from fMRIPrep ensures that the T1w reference brain was accurately extracted, adequate susceptibility distortion correction was correctly applied, an acceptable brain mask was calculated from the BOLD signal, the alignment of BOLD and T1w data was accurate, etc. If the report is satisfactory, proceed to the next step.

### Running first-level analysis on a preprocessed dataset 
Timing 5–60 min of computing time, depending on the number of BOLD runs and the workflow configuration 13 Determine an appropriate workflow and model design to be used for computing voxelwise activation contrasts. For this purpose, we provide reference Nipype workflows36 that execute first- and secondlevel analysis on the example dataset using tools from FSL (principally FEAT, FMRIB’s improved linear model (FILM), and FMRIB’s local analysis of mixed effects (FLAME)). To make use of these workflows with a new dataset, the code should be modified so that the statistical analysis is performed using the most appropriate contrasts. Create a batch prescription file $STUDY/analysis.sbatch akin to the script proposed in Fig. 2, replace the Singularity image with the one packing the analysis workflow36 and finally submit the job to the scheduler: sbatch $STUDY/analysis.sbatch.

### Visualization of results 
Timing 5–20 min 14 Visualize results with Nilearn’s plotting functions. Here, we list examples of figures that can beenerated, although most neuroimaging toolboxes include alternative utilities as well.

## References

+ https://fmriprep.org/en/stable/usage.html

+ https://github.com/poldracklab/ds003-post-fMRIPrep-analysis

+ https://github.com/nipreps/fmriprep

+ Analysis of task-based functional MRI data preprocessed with fMRIPrep

+ fMRIPrep: a robust preprocessing pipeline for functional MRI
+ https://github.com/nipreps/fmriprep
