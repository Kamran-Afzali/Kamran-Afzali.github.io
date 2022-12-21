## Introduction

Preprocessing of functional magnetic resonance imaging (fMRI) involves numerous steps to clean and standardize the data before statistical analysis. Generally, researchers create ad hoc preprocessing workflows for each dataset, building upon a large inventory of available tools. fMRIPrep is an analysis-agnostic tool that addresses the challenge of robust and reproducible preprocessing for fMRI data. fMRIPrep automatically adapts a best-in-breed workflow to the idiosyncrasies of virtually any dataset, ensuring high-quality preprocessing without manual intervention. The neuroimaging community is well equipped with tools that implement the majority of the individual steps of preprocessing described so far. These tools are readily available in software packages such as AFNI, ANTs, FreeSurfer, FSL, Nilearn, and SPM. Despite the wealth of accessible software and multiple attempts to outline best practices for preprocessing  the large variety of data-acquisition protocols has led to the use of ad hoc pipelines customized for nearly every study. In practice, the neuroimaging community lacks a preprocessing workflow that reliably provides high-quality and consistent results from diverse datasets. fMRIPrep equips neuroscientists with an easy-to-use and transparent preprocessing workflow, which can help ensure the validity of inference and the interpretability of results. The fMRIPrep workflow takes as principal input the path of the dataset in valid BIDS format, and it must include at least one T1w structural image and a BOLD series (unless disabled with a flag). Workflows for preprocessing of fMRI data produce two broad classes of outputs. First, preprocessed time series are derived from the original data after the application of retrospective signal corrections, spatiotemporal filtering, and resampling onto a target space appropriate for analysis (e.g., a standardized anatomical reference). Second, experimental confounds are additional time series such as commonly used confounds include motion parameters, framewise displacement, spatial s.d. of the data after temporal differencing, and global signals, among others. Preprocessing may include further steps for denoising and estimation of confounds, such as dimensionalityreduction methods based on principal component analysis or independent component analysis. Two corresponding instances of these techniques are component-based noise correction and automatic removal of motion artifacts. 

### outline of the functionalites 

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

## Preprocessing of structural MRI 

### Brain extraction, brain tissue segmentation and spatial normalization
The T1w is skull-stripped using a Nipype implementation of the *antsBrainExtraction.sh* tool (ANTs), which is an atlas-based brain extraction workflow. This is followed by a spatial normalization to standard spaces is performed using ANTs’ *antsRegistration* in a multiscale, mutual-information based, nonlinear registration scheme. 

### Cost function masking during spatial normalization
When processing images from patients with focal brain lesions (e.g., stroke, tumor resection), it is possible to provide a lesion mask to be used during spatial normalization to standard space. ANTs will use this mask to minimize warping of healthy tissue into damaged areas (or vice-versa). Lesion masks should be binary NIfTI images (damaged areas = 1, everywhere else = 0) in the same space and resolution as the T1 image, and follow the naming convention specified in BIDS Extension. This file should be placed in the sub-*/anat directory of the BIDS dataset to be run through fMRIPrep. Because lesion masks are not currently part of the BIDS specification, it is also necessary to include a .bidsignore file in the root of your dataset directory.
  
### Surface preprocessing
fMRIPrep uses FreeSurfer to reconstruct surfaces from T1w/T2w structural images. If enabled, several steps in the fMRIPrep pipeline are added or replaced. All surface preprocessing may be disabled with the *--fs-no-reconall* flag. Surface reconstruction is performed in three phases. The first phase initializes the subject with T1w and T2w (if available) structural images and performs basic reconstruction (autorecon1) with the exception of skull-stripping. Skull-stripping is skipped since the brain mask calculated previously is injected into the appropriate location for FreeSurfer. 
  

### Refinement of the brain mask
Typically, the original brain mask calculated with *antsBrainExtraction.sh* will contain some innaccuracies including small amounts of MR signal from outside the brain. Based on the tissue segmentation of FreeSurfer (located in mri/aseg.mgz) and only when the Surface Processing step has been executed, fMRIPrep replaces the brain mask with a refined one that derives from the aseg.mgz file as described in RefineBrainMask.
  

## BOLD preprocessing 

BOLD reference image estimation workflow estimates a reference image for a BOLD series. If a single-band reference *sbref* image associated with the BOLD series is available, then it is used directly. If not, a reference image is estimated from the BOLD series as follows: When T1-saturation effects (“dummy scans” or non-steady state volumes) are detected, they are averaged and used as reference due to their superior tissue contrast. Otherwise, a median of motion corrected subset of volumes is used.
  
        init_bold_reference_wf() <-input DSET>

###  Head-motion estimation

Using the previously estimated reference scan, FSL mcflirt is used to estimate head-motion. As a result, one rigid-body transform with respect to the reference image is written for each BOLD time-step. Additionally, a list of 6-parameters (three rotations, three translations) per time-step is written and fed to the confounds workflow. For a more accurate estimation of head-motion, we calculate its parameters before any time-domain filtering (i.e., slice-timing correction).

  
        init_bold_hmc_wf() <-input DSET>


###  Slice time correction

If the SliceTiming field is available within the input dataset metadata, this workflow performs slice time correction prior to other signal resampling processes. Slice time correction is performed using AFNI *3dTShift*. All slices are realigned in time to the middle of each TR. Slice time correction can be disabled with the --ignore slicetiming command line argument. If a BOLD series has fewer than 5 usable (steady-state) volumes, slice time correction will be disabled for that run.
  
        init_bold_stc_wf() <-input DSET>

###  Resampling BOLD runs onto standard spaces

*bold_std_trans_wf* concatenates the transforms calculated upstream (e.g. Head-motion estimation) to map the EPI image to the standard spaces given by the --output-spaces argument. It also maps the T1w-based mask to each of those standard spaces.Transforms are concatenated and applied all at once, with one interpolation (Lanczos) step, so as little information is lost as possible. The output space grid can be specified using modifiers to the --output-spaces argument.
 
        init_bold_std_trans_wf() <-input DSET>

###  EPI to T1w registration

The alignment between the reference EPI image of each run and the reconstructed subject using the gray/white matter boundary is calculated by the bbregister routine. If FreeSurfer processing is disabled, FSL flirt is run with the BBR cost function, using the fast segmentation to establish the gray/white matter boundary. After BBR is run, the resulting affine transform will be compared to the initial transform found by FLIRT. Excessive deviation will result in rejecting the BBR refinement and accepting the original, affine registration.
  
        init_bold_reg_wf() <-input DSET>


###  EPI sampled to FreeSurfer surfaces

If FreeSurfer processing is enabled, the motion-corrected functional series (after single shot resampling to T1w space) is sampled to the surface by averaging across the cortical ribbon. Specifically, at each vertex, the segment normal to the white-matter surface, extending to the pial surface, is sampled at 6 intervals and averaged. Surfaces are generated for the “subject native” surface, as well as transformed to the fsaverage template space. All surface outputs are in GIFTI format.
  
        init_bold_surf_wf() <-input DSET>

###  Confounds estimation

Given a motion-corrected fMRI, a brain mask, mcflirt movement parameters and a segmentation, the *discover_wf sub-workflow* calculates potential confounds per volume. Calculated confounds include the mean global signal, mean tissue class signal, tCompCor, aCompCor, Frame-wise Displacement, 6 motion parameters, DVARS, spike regressors, and, if the --use-aroma flag is enabled, the noise components identified by ICA-AROMA (those to be removed by the “aggressive” denoising strategy). Particular details about ICA-AROMA are given below.
  
        init_bold_confs_wf() <-input DSET>

###  ICA-AROMA

ICA-AROMA denoising is performed in MNI152 space, which is automatically added to the list of --output-spaces if it was not already requested by the user. The number of ICA-AROMA components depends on a dimensionality estimate made by *FSL MELODIC*. For datasets with a very short TR and a large number of timepoints, this may result in an unusually high number of components. By default, dimensionality is limited to a maximum of 200 components. To override this upper limit one may specify the number of components to be extracted with --aroma-melodic-dimensionality. 
  
        init_ica_aroma_wf() <-input DSET>

## Technical points

###  MRI scanner
If the study is acquiring new data, then a whole-head, BOLD-capable scanner is required. fMRIPrep has been tested on images acquired at 1–3 Tesla field strength. Recent multi-band echo-planar imaging sequences are supported, although all performance estimates given in this document derive from benchmarks on single-band datasets. fMRIPrep autonomously adapts the preprocessing workflow to the input data, affording researchers the possibility to fine-tune their MR protocols to their experimental needs and design.

### Computing hardware

fMRIPrep is amenable to execution on almost any platform with enough memory: PC, HPC or cloud. Some elements of the workflow will require a minimum of 8 GB RAM, although 32 GB is recommended. fMRIPrep is able to optimize the workflow execution via parallelization. The use of 8–16 CPUs is recommended for optimal performance. To store interim results, fMRIPrep requires ~450 MB of hard-disk space for the anatomical workflow and ~500 MB for each functional BOLD run per subject. Therefore, a dataset with an imaging matrix of 90 × 90 × 70 voxels and a total of 2,500 timepoints across all its BOLD runs will typically require ~3 GB of temporary storage. This storage can be volatile, e.g., ‘local’ scratch in HPC, which is a fast, local hard disk installed in the compute node that gets cleared after execution.

### Visualization hardware

The tools used in this protocol generate HTML reports to carry out visual quality control. These reports contain dynamic, rich visual elements to inspect the data and results from processing steps. Therefore, a high-resolution, high-static contrast and widescreen monitor (>30 inches) is recommended. Visual reports can be opened with Firefox or Chrome browsers, and graphics acceleration support is recommended.

### Computing software

fMRIPrep can be manually installed (‘bare-metal’ installation as per its documentation) on Linux and OSX systems or executed via containers (e.g., using Docker for Windows). When setting up manually, all software dependencies must also be correctly installed (e.g., Analysis of Functional NeuroImages. (AFNI), Advanced Normalization Tools (ANTs), the FMRIB Software Library (FSL), FreeSurfer, Nilearn and Nipype). When using containers (which is recommended), a new Docker image is provided from the Docker Hub for each new release of fMRIPrep, and it includes all the dependencies pinned to specific versions to ensure the reproducibility of the computational framework. Containers encapsulate all necessary software required to run a particular data-processing pipeline akin to virtual machines. However, containers leverage some lightweight virtualization features of the Linux kernel without incurring much of the performance penalties of hardware-level virtualization. For these two reasons (ease and reproducibility), container execution is preferred. This protocol recommends running quality control on the original data before preprocessing, using MRIQC. MRIQC is a companion tool to fMRIPrep to perform a quality assessment of the anatomical and functional MRI scans, which account for the most relevant data within the typical fMRI protocol. The tool is distributed as a Docker image (recommended) and as a Python package.

### Running fMRIPrep 
Timing 2–15 h of computing time per subject, depending on the number and resolution of BOLD runs, T1w reference quality, data acquisition parameters (e.g., longer for multiband fMRI data) and the workflow configuration 10 Run fMRIPrep. Figure 2 describes an example of batch prescription file $STUDY/fmriprep. sbatch and the elements that may be customized for the particular execution environment.

### Inspection of all visual reports generated by fMRIPrep
Timing 5–20 min per subject, depending on the number of BOLD runs Alongside the corresponding preprocessed data (Box 3, Outcomes), fMRIPrep will generate one HTML (hypertext markup language) report per subject. Screen these reports to ensure sufficient quality of preprocessed data (e.g., accuracy of image registration processes, correctness of artifact correction techniques, etc.). Checking the visual reports from fMRIPrep ensures that the T1w reference brain was accurately extracted, adequate susceptibility distortion correction was correctly applied, an acceptable brain mask was calculated from the BOLD signal, the alignment of BOLD and T1w data was accurate, etc. If the report is satisfactory, proceed to the next step.

### Running first-level analysis on a preprocessed dataset 
Timing 5–60 min of computing time, depending on the number of BOLD runs and the workflow configuration 13 Determine an appropriate workflow and model design to be used for computing voxelwise activation contrasts. For this purpose, we provide reference Nipype workflows36 that execute first- and secondlevel analysis on the example dataset using tools from FSL (principally FEAT, FMRIB’s improved linear model (FILM), and FMRIB’s local analysis of mixed effects (FLAME)). To make use of these workflows with a new dataset, the code should be modified so that the statistical analysis is performed using the most appropriate contrasts. Create a batch prescription file $STUDY/analysis.sbatch akin to the script proposed in Fig. 2, replace the Singularity image with the one packing the analysis workflow36 and finally submit the job to the scheduler: sbatch $STUDY/analysis.sbatch.

### Visualization of results 
Timing 5–20 min 14 Visualize results with Nilearn’s plotting functions. Here, we list examples of figures that can beenerated, although most neuroimaging toolboxes include alternative utilities as well.

## References

+ [Documentation](https://fmriprep.org/en/stable/usage.html)
+ [Analysis of task-based functional MRI data preprocessed with fMRIPrep](https://www.nature.com/articles/s41596-020-0327-3)
+ [fMRIPrep: a robust preprocessing pipeline for functional MRI](https://www.nature.com/articles/s41592-018-0235-4)
+ [fMRIPrep github 1](https://github.com/nipreps/fmriprep)
+ [fMRIPrep github 2](https://github.com/poldracklab/ds003-post-fMRIPrep-analysis)
