

## FSL
FSL (the FMRIB Software Library) is a comprehensive library of analysis tools for functional, structural and diffusion MRI brain imaging data, written mainly by members of the Analysis Group, FMRIB, Oxford. For this NeuroImage special issue on “20 years of fMRI” we have been asked to write about the history, developments and current status of FSL. We also include some descriptions of parts of FSL that are not well covered in the existing literature. We hope that some of this content might be of interest to users of FSL, and also maybe to new research groups considering creating, releasing and supporting new software packages for brain image analysis.

FSL divides into three main areas, related to functional, diffusion and structural image analysis. There are over 230 individual com- mand line tools (approximately 140 scripts and 90 compiled C++ programs — including 50 small/flexible tools in the “fslutils” set) plus 23 GUIs, making it very flexible but rather formidable to the first-time user. However, there are only a handful of major tools that most people use directly, as shown in Table 1, which gives a rough idea of the current scope of FSL.

As mentioned above, the GUIs provide a simple interface and pipe- line for the various underlying command-line tools. It is always pos- sible to replicate an analysis that was done with a GUI using only command-line tools, and this is made easier by the existence of a command log file that is output by the GUI. This makes custom-scripting relatively easy, including parallelising tasks on a computing cluster, although distributing jobs over a cluster is already automatically handled by some of the “larger” FSL GUIs (e.g., FEAT, FDT).

Some of these tools have existed for a long time (e.g., FEAT, BET, FLIRT) while others are relatively new (e.g., FABBER, TBSS, FSLVBM). At times there have been “delays” before including certain functional- ity that might arguably have appeared earlier, for example nonlinear registration and VBM-like functionality; we now describe a little of the relevant history.

## Outile of some useful commands 

### BET		[Brain extraction](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET)

Several automated brain volume change measuring techniques are available. Many have as a common first step the “brain extraction”, which refers to the separation of brain and non-brain tissue. The automated brain extraction tool (BET) (Smith, 2002a) provided as part of the FSL software package is frequently used to this effect. It is an integrated part of the whole-brain volume change measurement techniques SIENA and SIENAX as well as several functional MRI processing packages. BET uses a tessellated mesh to model the brain surface, which is allowed to deform according to various dynamic controlling terms until it reaches the brain edge. Several options and parameters are available for optimizing BET performance.

Bet uses several options and some are mutually exclusive forinstance :

1. “f”: “fractional intensity threshold” sets the brain/non-brain intensity threshold. It ranges between 0 and 1, and 0.5 is the default value. Lower values than default give larger brain outlines; higher values lead to smaller brain outlines. 
2. “B”: bias field correction and neck removal. This consists of various stages involving FSL-FAST (FMRIB's Automated Segmentation Tool) bias field removal and standard-space masking.
3. “R”: uses an iterative procedure to estimate the brain center more accurately, especially in images with a lot of non-brain tissue.
4. “S”: cleans up residual eye and optic nerve voxels using standard-space masking, morphological operations and thresholding (Battaglini et al., 2008).

BET only allows one of last three options to be selected in any single run.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)

### FAST		[Tissue segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST)

Following brain–nonbrain segmentation, tissue-type segmentation can be performed, that is, classification of each voxel into grey-matter, white-matter, or cerebrospinal fluid (CSF), and possibly pathology (e.g., lesion). It is common to segment purely using voxel intensity, once intensity thresholds have been found to optimally distinguish between the different tissue classes. This can be considered as an analysis of the image histogram, where the different classes appear (ideally) as separate peaks, which have a spread caused by factors such as image noise, motion artefacts, partial-volume effect, bias field (intensity fluctuations across the image caused by inhomogeneities in the radio frequency field), and true within-class variation. This spread can cause serious mislabeling of voxels, particularly if the bias field is strong.

A central problem is that robust and accurate estimation of the bias field ideally requires perfect knowledge of the segmentation, while obtaining a perfect segmentation requires that the bias field be known and corrected. This circularity of dependence means that a sensible approach to both problems is to solve the two problems together, in practice iterating between estimating the segmentation and the bias field, until convergence. This is the approach taken in FMRIB's Automated Segmentation Tool (FAST) (Zhang et al., 2001). The histogram is modeled as a mixture of Gaussians (one for each class), giving each class's mean (and variance) intensity. Each voxel is then labeled by taking into account not only its intensity with respect to the estimated class means, but also the labeling of its local neighbors—a Markov random field (MRF) is placed on the labeling, causing spatial regularization (i.e., smoothness of segmentation). This greatly reduces the effect of noise on the segmentation. The segmentation allows an idealized reconstruction of the image; subtracting this from the real image (and smoothing) gives an estimate of the bias field. This whole process is then iterated several times.

If required, FAST also models the partial volume effect (PVE) at each voxel. The voxel's intensity with respect to the global class (tissue-type) means and variances is used to estimate the PVE, and this is augmented with an MRF on the PVE to spatially regularize with local voxels.

The above approach easily generalizes to “multichannel segmentation”, that is, if more than one input modality (image type) is available. For example, if both T1-weighted and proton density images are available, the input can be thought of as a vector image instead of just a scalar. FAST allows for two or more input images, which can give improved results, for example, in the deep grey structures where T1-only segmentation often has problems due to the intermediate (between white and cortical grey) intensities of some subcortical “grey” matter.

FAST does not use segmentation priors (images in standard space of the expected distribution of the tissue types, averaged over many subjects) by default, as the prior segmentation images tend to be very blurred, and therefore not very informative. However, this option can be turned on, for example, to aid the initial segmentation in the case of very bad bias field.

FAST, FMRIB's Automated Segmentation Tool, is a module for segmenting the brain into different tissue types while correcting the bias field. Also, in FAST's advanced options, the input image is first registered to standard space and then standard tissue probability maps (from the MNI152 dataset) are used to estimate the initial parameters of tissue classes. The segmentation routine used in this tool works based on a Hidden Markov Random Field (HMRF) model optimized by Expectation- Maximization algorithm [8]. The fully automated segmentation process bring about a bias field- corrected version of input image and a probabilistic and/or partial volume tissue segmentation.


So goes the story of the creation of FAST. The tool is straightforward: Provide a skullstripped brain, decide how many tissue classes you wish to segment, and the rest of the defaults are usually fine. Often a researcher will want three tissue classes: White matter, grey matter, and cerebrospinal fluid (CSF). However, if you are dealing with a subject that presents with a brain abnormality, such as a lesion, you may want to increase the number of classes to four in order to segment the lesion into its own class.

FAST outputs a dataset for each tissue type. For example, if three tissue types have been segmented, there will be three output datasets, one corresponding to each tissue class; each dataset is a mask for each tissue type, and contains a fraction estimate at each voxel. The picture below shows a grey matter mask segmented with FAST. The intensity at the voxel centered at the crosshairs is 0.42, meaning that 42% of that voxel is estimated to be grey matter; presumably, the other 58% is white matter, as the voxel lies at the boundary between the head of the caudate nucleus (a grey matter structure), and the internal capsule (which is composed of white matter).

MAIN OPTIONS

Now set the Image type. This aids the segmentation in identifying which classes are which tissue type. Note that this option is not used for multi-channel segmentation.

Now select the Output image(s) basename. Output images will have filenames derived from this basename. For example, the main ouput, the Binary segmentation: All classes in one image will have filename <basename>_seg. If multi-channel segmentation is carried out, some of the optional outputs will have basenames derived instead from the input names (but into the directory of the outputbasename). For example, the main segmentation output will be as described above, but the restored images (one for each input image) will be named according to the input images.

Now choose the Number of classes to be segmented. Normally you will want 3 (Grey Matter, White Matter and CSF). However, if there is very poor grey/white contrast you may want to reduce this to 2; alternatively, if there are strong lesions showing up as a fourth class, you may want to increase this. Also, if you are segmenting T2-weighted images, you may need to select 4 classes so that dark non-brain matter is processed correctly (this is not a problem with T1-weighted as CSF and dark non-brain matter look similar).
  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST/UserGuide)


### FIRST		[Subcortical segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST)
  
Automatic segmentation of subcortical structures in human brain MR images is an important but difficult task due to poor and variable intensity contrast. Clear, well-defined intensity features are absent in many places along typical structure boundaries and so extra information is required to achieve successful segmentation. 
  
Achieving this in the subcortical areas of the brain, given the typical low contrast-to-noise, is a great challenge for automated methods. When trained human specialists perform manual segmentations they draw on prior knowledge of shape, image intensities and shape-to-shape relationships. We present here a formulation of a computationally efficient shape and appearance model based on a Bayesian framework that incorporates both intra-and inter-structure variability information, while also taking account of the limited size of the training set with respect to the dimensionality of the data. The method is capable of performing segmentations of individual or multiple subcortical structures as well as analysing differences in shape between different groups, showing the location of changes in these structures, rather than just changes in the overall volume.

FIRST is a model-based segmentation/registration tool. The shape/appearance models used in FIRST are constructed from manually segmented images provided by the Center for Morphometric Analysis (CMA), MGH, Boston. The manual labels are parameterized as surface meshes and modelled as a point distribution model. Deformable surfaces are used to automatically parameterize the volumetric labels in terms of meshes; the deformable surfaces are constrained to preserve vertex correspondence across the training data. Furthermore, normalized intensities along the surface normals are sampled and modelled. The shape and appearance model is based on multivariate Gaussian assumptions. Shape is then expressed as a mean with modes of variation (principal components). Based on our learned models, FIRST searches through linear combinations of shape modes of variation for the most probable shape instance given the observed intensities in a T1-weighted image.
  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST/UserGuide)

### FLIRT		[Linear registration](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT)

FLIRT—affine intermodal image registration
Robust automated intensity-based image registration is a core capability needed for most brain image analysis applications. Ideally, it provides a fast, accurate, robust, and objective way to align images of the same or different MR modalities, crucial for many applications such as localizing functional activations within a subject's own neuroanatomy and for allowing group comparisons via the registration to a standard image. However, a common problem is that registration methods sometimes fail to produce “sensible” results, with gross misalignment clearly visible. These failures often occur when the images being registered are initially in different orientations. For automated analysis methods that rely on registration (e.g., FMRI analysis and atrophy analysis), such failures are very problematic.

The standard framework for intensity-based registration involves the minimization of a cost function (which quantitates how well aligned two images are) as the registration parameters (such as rotation and translation) are varied. Consequently, the cause of misregistrations arises from either nonideal cost functions (which return minimum values for poor alignments) or from nonideal optimization methods that fail to find the (global) minimum value of the cost function. Much work has gone into proposing suitable cost functions for image registration, for example, using information theory (Viola and Wells, 1997). However, little work has been done on improving optimization methods for image registration, even though “getting stuck” in a local minimum is the main cause of failure for many registration methods.
  
We will first co-register the images within each separate visit to the T1 image from that visit. This operation overlays the images on one another and allows us to investigate joint distributions of voxel intensities from different image modalities. This is performed using FMRIB's Linear Image Registration Tool (FLIRT; Jenkinson and Smith 2001; Jenkinson et al. 2002). As the images are from the same individual, we may assume that the overall shape of the brain has not changed, but each scan may have undergone a translation and/or rotation in space. Therefore, we will use a rigid-body transformation, with 6 degrees of freedom (dof).
  
My FLIRT registration doesn't work well - what can I do?

There are many reasons why a registration may not work well. Here is a general checklist of things to test and try in order to improve the registration results (please do not post a query to the FSL email list about registration results until you have gone through this list):

Check that the input image looks fine and that the voxel size is correct by (a) looking at the images with slices (none of the views should look squashed or stretched) and (b) checking the voxel dimensions (pixdim) with `fslhd (Note: voxel size can be fixed using fslchpixdim)
Remove non-brain structures with BET from both images (Note that small errors in the BET results will only have a very small impact on the registration quality)
Use the image with the best contrast and resolution as the reference image. If this gives you the registration in the opposite direction than you wanted then the result can be easily inverted using InvertXFM or convert_xfm.
For 2D images (single slices) you must use one of the valid 2D degrees of freedom options (or -2D and appropriate schedules from the command line - see below)
If there is large bias field (slow intensity variation - especially near the end slices) then try using fast to create a restored image (one with no bias field) and then register using the restored image.
If there are relatively small errors in some crucial region of interest (e.g. ventricles) then the registration may benefit from using cost function weighting to enhance the importance of this region. To do this a weighting image must be made which has the value of 1.0 everywhere except in the region of interest where a higher weight (e.g. 10.0) should be used. Using this weighting volume in either the GUI or command line registration calls should improve the fit in this region.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT/UserGuide)  
  
  
### MCFLIRT		[Intra-modal motion correction tool](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT)
  
hen we take three-dimensional pictures of the brain. If the subject is moving, the images will look blurry; if the subject is still, the images will look more defined. But that’s not all: If the subject moves a lot, we also risk measuring signal from a voxel that moves. We are then in danger of measuring signal from the voxel for part of the experiment and, after the subject moves, from a different region or tissue type.

Lastly, motion can introduce confounds into the imaging data because motion generates signal. If the subject moves every time in response to a stimulus - for example, if he jerks his head every time he feels an electrical shock - then it can become impossible to determine whether the signal we are measuring is in response to the stimulus, or because of the movement.

  
Motion correction is an important issue in FMRI analysis as even the slightest patient motion can induce significant motion artefacts (potentially of greater magnitude than the BOLD effect itself), particularly at tissue boundaries, at the edge of the brain or near major vessels. A rigid-body motion correction tool was developed based on the affine registration tool in FSL (FLIRT, see above). This method (MCFLIRT) applies the same cost function regularization techniques as FLIRT but does not need the multistart optimization techniques because movement from one volume to another within an FMRI sequence is small, giving good initialization. Instead, the tool was specifically customized to be highly accurate for typical FMRI data (Jenkinson et al., 2002a).

Motion correction, however, is an inherently nonrigid problem because the volume is not acquired at a single instant, but each slice is acquired at a different time. Consequently, when the head is moving, each slice is transformed by a slightly different rigid-body transformation, making whole-volume rigid-body correction oversimplistic. Furthermore, the fact that each slice has slightly shifted timing with respect to each other is incompatible with the assumptions of subsequent temporal analysis. This is often dealt with by applying a slice-timing correction (interpolation within each voxel's time series) either before or after rigid-body motion correction. Applying rigid-body motion correction and slice-timing corrections separately (in either order) is imperfect, as the two problems arise simultaneously and therefore need to be solved in a single integrated approach.

To this end, we have developed a limited degree of freedom (DOF) model of the slice transformation process, assuming smooth motion within each TR. (This model is an approximation to the real situation where any sudden small motion could occur during a TR; using a more general model would be problematic as it introduces extra degrees of freedom, requiring rigid-body registration of a single slice to a reference volume, which is nonrobust and inaccurate.) Cost functions are generalized from the 3D case to include the entire 4D data set because it is unlikely that any single volume can be relied upon to provide a sufficiently accurate (motion-free) reference volume. Initial results using this approach (called FORCE–FMRIB's Optimized Retrospective Correction Environment) indicate that it is possible to reduce final motion-related error in comparison with separated rigid-body correction and slice-timing correction (Bannister et al., 2002).
  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT/UserGuide)

### FEAT		[Functional preprocessing and analysis](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT)

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT/UserGuide)
  
### MELODIC		[Multivariate Exploratory Linear Optimized Decomposition into Independent Components](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC)
  
Independent component analysis (ICA) is becoming a popular exploratory method for analyzing complex data such as that from FMRI experiments. ICA attempts to decompose the data into (statistically) independent spatial maps (and associated time courses), which ideally each represent different artefacts or activation patterns. By using all of the 4D data set together in the analysis, this kind of approach does not need a (temporal)
model in the way that the above research does. The application of such bmodel-freeQ methods, however, has been restricted both by the view that results can be uninterpretable and by the lack of ability to quantify statistical significance for estimated spatial maps.
In Beckmann and Smith (2004a), we proposed a probabilistic ICA (PICA) model for FMRI that models the observations as mixtures of spatially non-Gaussian signals and artefacts in the presence of Gaussian noise. We demonstrated that using an objective estimation of the amount of Gaussian noise through
Bayesian analysis of the number of activation and (non-Gaussian) noise sources, the problem of boverfittingQ can be overcome. The approach proposed for estimating a suitable model order (i.e., how many ICA components to find) also allows for a unique decomposition of the data and reduces problems of interpretation, as each final component is more likely to be due to only one physical or physiological process (Figs. 4 and 5). The model also
advanced standard ICA with other improvements, such as voxelwise temporal prewhitening, variance normalization of time series, and the use of prior information about the spatiotemporal nature of the source processes. Finally, to statistically infer areas of activation from the estimated PICA maps, we used an alternative-hypothesis testing approach based on a nonspatial Gaussian–Gamma mixture model (Beckmann et al., 2003b). The above methodology is implemented as Multivariate Exploratory Linear Optimized Decomposition into Independent Components (MELODIC).
  
Single-session ICA: This will perform standard 2D ICA on each of the input files. The input data will each be represented as a 2D time x space matrix. MELODIC then de-composes each matrix separately into pairs of time courses and spatial maps. The original data is assumed to be the sum of outer products of time courses and spatial maps. All the different time courses (one per component) will be saved in the mixing matrix melodic_mix and all the spatial maps (one per component) will be saved in the 4D file melodic_IC.
When using separate analyses, MELODIC will attempt to find components which are relevant and non-Gaussian relative to the residual fixed-effects within session/subject variation. It is recommended to use this option in order to check for session-specific effects (such as MR artefacts). You will need to use this option if you want to perform MELODIC denoising using fsl_regfilt. When using single-session ICA the component are ordered in order of decreasing amounts of uniquely explained variance.
 

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC/UserGuide)

## FSLr

We present the package fslr, a set of R functions that interface with FSL (FMRIB Software Library), a commonly-used open-source software package for processing and analyzing neuroimaging data. The fslr package performs operations on ‘nifti’ image objects in R using command-line functions from FSL, and returns R objects back to the user. fslr allows users to develop image processing and analysis pipelines based on FSL functionality while interfacing with the functionality provided by R. We present an example of the analysis of structural magnetic resonance images, which demonstrates how R users can leverage the functionality of FSL without switching to shell commands.

Fundamental functionality that FSL and other imaging software provide is not currently implemented in R. In particular, this includes algorithms for performing slice-time correction, motion correction, brain extraction, tissue- class segmentation, bias-field correction, co-registration, and normalization. This lack of functionality is currently hindering R users from performing complete analysis of image data within R. Instead of re-implementing FSL functions in R, we propose a user-friendly interface between R and FSL that preserves all the functionality of FSL, while retaining the advantages of using R. This will allow R users to implement complete imaging pipelines without necessarily learning software-specific syntax.
The fslr package relies heavily on the oro.nifti (Whitcher et al., 2011) package implementation of images (referred to as ‘nifti’ objects) that are in the Neuroimaging Informatics Technology Initiative (NIfTI) format, as well as other common image formats such as ANALYZE. oro.nifti also provides useful functions for plotting and manipulating images. fslr expands on the oro.nifti package by providing additional functions for manipulation of ‘nifti’ objects.


# References

[FSL Course Video Lectures 2021](https://www.youtube.com/watch?v=3ExL6J4BIeo&list=PLvgasosJnUVl_bt8VbERUyCLU93OG31h_)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[FSL](https://fsl.fmrib.ox.ac.uk/fslcourse/lectures/intro.pdf)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[fslr: Connecting the FSL Software with R](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4911193/pdf/nihms-792376.pdf)

[FSL Paper](https://pdf.sciencedirectassets.com/272508/1-s2.0-S1053811912X00119/1-s2.0-S1053811911010603/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEP7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIBZ7MKEXrri7SO%2FUC6a0OI1hQwmQXJ%2Fmn%2FmmJRcvkPzKAiEArbyUN7rgneoNXFX4fWxSlX1xXxEVw0RKEqw7YpZyjo8q0gQIRxAFGgwwNTkwMDM1NDY4NjUiDCAr2sAbUILLxNGqliqvBE%2BFWp07BWc9nwT0hV%2FYTyUTE0nmqEobsB6QURk7pWojxHnWxSsOrvnk%2FMHoNt69X75pfmAuIDzjhz6yRBt%2F8yh6VLbPc8QqbAUvzy5VTOcxDAh0x5B2%2FW6CMyhLK9B12aqOqK%2BnAwf6TEQDHKM%2FMnJofOwJIyTy5RJ6%2FWuwkmgZqtsm%2FD7T6iwG5G0DjfvucfgWziJxXki87TIamX5bW7f%2FYgLfYlaBspEuIB1sOQXaoBaQ0xlCA1thOXmZOlRVGJ2KdiPuZbOm9UB8lU29YRp3DUQre%2Fm3%2FnzRedoCxS9bKaAylMrO0buVsUn1kKB7Rma2LRvLnXBU4pkrvnj%2BdUaaZKC3ZOQm9wxSH6I1ZTSuilR0k27NVAYFTn%2FHpDWu%2FReoR7qduCJ7Lp8IdDNxnlypboUgNKLKZFMytwmtIig6PrDx06P0hzFyTx5JrD4V0WmiFHC6kSqyguqaEcAAvLBv6kznOg3f8Jgfqxk%2B3H6rPzRzE8YPMV3BuOT0%2FW74gLgM1S8%2FXq380IXxDdoJk5VafR62AUNIet4pB2Eb7%2B3ze8HlZEApJmwXR6D7eCdeZmOHot97T2J18bcnnni60g0XMBb%2FlPk3jkvYQDyz9kCcg7B56BZuGvj0t70%2Fnikq%2B0sb4avSd6YeHpxXWcL7rT3AHNRL62kpD%2Bx2ziMLGDu2NiS7VVkmTLOGHwxQnDy5eUfsFiY2%2FMxB97P6vcQ20hrfDW1RUe3XxbqmUQNlT6cwganllgY6qQEmwdZS8wKKOO0xX%2FBPlxcmU39utUibQui2X3v1jGxAMfwWNNgJLlH0vX%2FpVZTqIh8e4WuQ6DffRjq3sh5L6pJgXKwW2Rl5JdbD1msyclywL5a0J4jx68SJ9zZa74Y0xnJUrKJ0STPl3%2FiGUSNYFYEW7HnsaJuPdiyjzkYtEFSMc%2FKEUM4WbFFUBSuMrh%2BRGRbZq9aE8CL%2BT2C53uN3CZ5J1P17Tg2vk86L&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220721T142033Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYTWSMZFGV%2F20220721%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=1248d4ea5c26f6ea0457a0f0aa782b504e2a6d72591aa9623c1ed06f1be78ac7&hash=620a8e745bfba1abd2228f71614971ea12d9fd6e8fac5827322880a09e2498ed&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1053811911010603&tid=spdf-d9ee94e5-ee74-491d-b31b-1dfa79035d78&sid=c834f2a814e09140b719d9992d1e58347199gxrqa&type=client&ua=4d5c02565c50005b0c02&rr=72e493f4ca8e4bd0)
