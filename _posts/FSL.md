

## FSL

Developed primarily by members of the Analysis Group of FMRIB at Oxford, the FSL (the FMRIB Software Library) is a comprehensive library of analysis tools for different modilities of brain imaging data.  With over two hundred individual command line tools (approximately 140 scripts and 90 compiled C++ programs — including 50 small/flexible tools in the “fslutils” set) FSL divides into three main areas, related to functional, diffusion and structural image analysis. Additionally, GUIs make FSL incredibly flexible but quite difficult for a beginner to utilise. The different underlying command-line utilities are provided with a straightforward interface and pipe-line by GUIs. The existence of a command log file that is output by the GUI makes it simpler to reproduce an analysis that was performed using a GUI using solely command-line tools. Although some of the "bigger" FSL GUIs already take care of automatically spreading jobs over a cluster, this makes custom scripting reasonably simple, including parallelizing work on a computing cluster. We'll go over some of the frequently used FSL tools (in the context of structural and functional MRI) in the sections below.

## Outline of some useful commands 

### Structural MRI analysis

### BET		[Brain extraction](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET)

The capacity to precisely separate brain from non-brain tissue is important for a wide variety of applications in brain imaging. Because of the nature of the imaging, FMRI and PET functional images frequently contain little non-brain tissue, whereas high-resolution MR images are likely to contain a significant amount—eyes, skin, fat, muscle, etc.—and registration robustness is improved if these non-brain parts of the image can be automatically removed before registration. Additionally, for many tissue-type segmentation methods to work effectively, brain-nonbrain segmentation must have been completed first. The Brain Extraction Tool is a fully automated brain extraction that functions dependably on a number of MR modalities. A triangular tessellation of a spherical surface is initially initiated inside the brain and then allowed to expand, one vertex at a time, while being propelled toward the edge of the brain by forces that keep the surface evenly spaced and smooth. If a clean enough solution cannot be found, the entire procedure is repeated with a tighter smoothness restriction. The outside surface of the skull can also be estimated, if necessary. BET is a component of numerous functional MRI processing packages as well as the whole-brain volume change measuring methods SIENA and SIENAX. The brain surface is modelled by BET using a tessellated mesh, which is then allowed to deform in accordance with various dynamic regulating parameters until it reaches the brain edge. The performance of BET can be optimised using a variety of variables and factors.


[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)

### FAST		[Tissue segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST)

The FAST module divides the brain into various tissue types while adjusting for bias field. The tool is simple to use: Provide a brain that has been stripped of its skull, then pick how many tissue classes to section (e.g. three tissue classes: White matter, grey matter, and cerebrospinal-fluid). However, you might wish to raise the number of classes to four in order to separate the lesion into its own class if you are working with a person that has a brain abnormality (lesion). Each tissue type's dataset is produced using FAST. One output dataset will correspond to each tissue class, for instance, if three different tissue types were segmented. Each dataset is a mask for each tissue type and comprises a fraction estimate at each voxel.

After separating the brain from the non-brain, each voxel can be divided into grey matter, white matter, cerebrospinal fluid (CSF). This process is known as tissue-type segmentation. Once the best intensity thresholds for differentiating between the various tissue classes have been identified, it is usual practise to segment voxels using their intensity. This can be thought of as an analysis of the image histogram, where the various classes show up as separate peaks and spreaded by elements like image noise, motion artefacts, partial-volume effect, bias field, and true within-class variation. 

A mixture of Gaussians (one for each class) are used to model the histogram, which provides the mean (and variance) intensity for each class. The labelling of each voxel is subsequently determined by accounting for both its local neighbours' labels as well as its intensity in relation to the estimated class means. By subtracting the idealised image from the actual image (and smoothing), segmentation enables an approximation of the bias field. Then, the entire process is repeated multiple times. A major issue is that accurate segmentation knowledge is necessary for robust estimation of the bias field, and vice versa. Due to the circularity of the dependence, iterating between estimating the segmentation and the bias field until convergence is the only sensible method to both problems.

FAST models the partial volume effect at each voxel if necessary. Regarding the global class (tissue-type) means and variances, the voxel's intensity. If more than one input modality (type of image) is available, this method is simply generalised to "multichannel segmentation." Since segmentation priors tend to be quite blurry and consequently not very helpful, FAST does not by default utilise segmentation priors (pictures in standard space showing the expected distribution of the tissue types, averaged over many patients). However, in the event if the bias field is extremely poor, this option can be enabled to help with the first segmentation.

  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST/UserGuide)


### FIRST		[Subcortical segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST)
  
Due to the weak and fluctuating intensity contrast, automatic segmentation of subcortical regions in human brain MR images is a crucial yet challenging endeavour. In many instances, well-defined intensity features and typical structural boundaries are absent, necessitating the addition of additional data to successfully segment the data. For automated approaches, achieving this in the subcortical regions of the brain is quite difficult. FIRST is a Bayesian framework-based shape and appearance model that is computationally effective and integrates information about both intra- and inter-structure variability. It also accounts for the small size of the training set in relation to the dimensionality of the data. It is on par with skilled human specialists who manually segment images using their prior understanding of shape, picture intensities, and correlations between shapes. FIRST is able to segment subcortical structures, analyse shape variations between groups, and highlight where alterations to these structures and changes to the overall volume have occurred. FIRST is a segmentation and registration technique based on models. FIRST's shape/appearance models are built using manually segmented photos that are parameterized as surface meshes and modelled as point distribution models. The multivariate Gaussian presumptions provide the foundation of the shape and appearance model. Principal components are then used to depict shape as a mean with modes of variation. FIRST looks through linear combinations of shape modes of variation based on our learnt models to find the shape instance that matches the measured intensities in a T1-weighted image the most closely.
  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST/UserGuide)

### FLIRT		[Linear registration](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT)

FLIRT—affine intermodal image registration
  
For the majority of brain image analysis tools, reliable and automated picture registration is a fundamental feature. The ability to quickly, accurately, robustly, and objectively align images of the same or different modalities is provided by registration. Registration is essential for many applications, including locating functional activations within a subject's own neuroanatomy and enabling group comparisons by registering images to a reference image. Through this procedure, which superimposes the images on top of one another, we are able to look into joint distributions of voxel intensities from various image modalities. Utilizing the Linear Image Registration Tool from FMRIB, this is accomplished. Since the images are from the same person, we may presume that the brain's general shape hasn't altered, but it's possible that each scan has undergone a translation and/or rotation in space. A rigid-body transformation with six degrees of freedom will be used as a result (dof). However, a recurrent issue is that registration techniques can fail to yield "reasonable" results, with severe misalignment being readily apparent. When the photos being registered are initially in various orientations, these failures frequently happen.

As the registration parameters (such as rotation and translation) are changed, the conventional framework for intensity-based registration comprises the minimization of a cost function (which quantifies how well aligned two pictures are). Therefore, nonideal cost functions (which return minimum values for poor alignments) or nonideal optimization techniques (which fail to obtain the (global) minimum value of the cost function) are the root causes of misregistrations. Using information theory, acceptable cost functions have been proposed for image registration, for instance. Even though "being trapped" in a local minimum is the primary reason for many registration approaches to fail, little work has been done to improve optimization strategies for picture registration.
  
There are numerous causes for a registration not to function properly. A broad list of things to test and try in order to enhance registration outcomes is provided below: 

By (a) examining the images with slices (none of the views should appear squished or stretched), and (b) examining the voxel measurements, confirm that the input image appears fine and that the voxel size is accurate. 

Remove non-brain structures from both pictures using BET (Note that small errors in the BET results will only have a very small impact on the registration quality) 

Try using fast to create a restored image (one with no bias field) if there is a significant bias field (slow intensity change, particularly near the end slices), and then register using the restored image. 

The registration may benefit from employing cost function weighting to increase the value of this region if there are relatively tiny errors in some important region of interest (for example, ventricles). To do this, a weighting picture with a value of 1.0 everywhere but the region of interest should be created. This region should have a larger weight, such as 10.0. The fit in this region should be improved by using this weighting volume in either the GUI or command line registration calls.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT/UserGuide)  
  
  
### MCFLIRT		[Intra-modal motion correction tool](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT)
  
The photographs will appear hazy if the subject is moving during the imaging session. Additionally, there is a chance of measuring a signal from a voxel from a different location or tissue type if the individual moves around a lot. For instance, If the subject moves every time in response to a stimulus - for example, if he jerks his head every time he feels an electrical shock - then it can become impossible to determine whether the signal we are measuring is in response to the stimulus, or because movement. The patient movement can cause considerable motion artefacts in FMRI analysis. This is especially true at tissue boundaries, the edge of the brain, or next to major blood arteries. Based on the affine registration tool in FSL, a rigid-body motion correction tool was created. Since there is little movement from one volume to the next during a FMRI sequence, this method (MCFLIRT) utilises the same cost function regularisation techniques as FLIRT but does not require multistart optimization techniques. Instead, the instrument was specially tailored to be extremely accurate for common FMRI data.

However, since the volume is not collected at a single instant but rather at several times for each slice, motion correction is a naturally nonrigid problem. Because each slice undergoes a somewhat different rigid-body transformation when the head moves, whole-volume rigid-body correction is oversimplified. Furthermore, the assumptions of the ensuing temporal analysis are inconsistent with the fact that each slice has slightly altered time relative to the others. Applying a slice-timing correction (interpolation within each voxel's time series) either before or after rigid-body motion correction is a common way to address this. Applying slice-timing corrections and rigid-body motion corrections separately (or in any particular order) is flawed since the two issues exist simultaneously and must be resolved as a single integrated problem.

In order to achieve this, we created a model of the slice transformation process with a limited degree of freedom, assuming smooth motion within each TR. (This model approximates the actual circumstance where any abrupt little motion could happen during a TR.) Since no single volume is likely to be able to be depended upon to offer a reference volume that is sufficiently free from motion, cost functions are expanded from the 3D situation to encompass the complete 4D data set. According to preliminary findings, this method can reduce final motion-related error in comparison to independent rigid-body correction and slice-timing correction.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT/UserGuide)

### Functional MRI analysis
  
  

  
### MELODIC		[Multivariate Exploratory Linear Optimized Decomposition into Independent Components](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC)
  
A common exploratory technique for evaluating complex data, such as that from FMRI research, is independent component analysis (ICA). In order to depict various artefacts or activation patterns, ICA seeks to divide the data into (statistically) separate spatial maps. This approach, does not require a (temporal) model because it analyses the entire 4D data set at once. However, the use of such a model-free approaches has been constrained both by the view that results may be difficult to interpret and by the incapacity to calculate statistical significance for estimated spatial maps.

A probabilistic ICA model for FMRI that describes the observations as mixtures of spatially non-Gaussian signals was proposed by Beckmann and Smith in 2004. They showed how Bayesian estimation of the amount of Gaussian noise can be used to circumvent the overfitting issue. The method suggested for determining the appropriate model order (i.e., how many ICA components to identify) also permits a distinctive decomposition of the data and lessens issues with interpretation because each final component is more likely to be the result of just one physical or physiological event.This methodology is implemented as Multivariate Exploratory Linear Optimized Decomposition into Independent Components (MELODIC).
  
MELODIC's single-session ICA processes each of the input files using a typical 2D ICA procedure. A 2D time x space matrix will be used to represent each input data set. After that, MELODIC separates each matrix into pairs of time courses and spatial mappings. When utilising single-session ICA, the components are arranged in decreasing order of the proportion of variance that is uniquely explained. MELODIC will attempt to identify non-Gaussian residuals within session/subject variance as well as more pertinent components. It is recommended to use this option in order to check for session-specific effects (i.e.artefacts).
 

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC/UserGuide)
  
  
### FEAT		[Functional preprocessing and analysis](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT)

FEAT is a software tool for high quality model-based FMRI data analysis, with an easy-to-use graphical user interface (GUI). FEAT is part of FSL (FMRIB's Software Library). FEAT automates as many of the analysis decisions as possible, and allows easy (though still robust, efficient and valid) analysis of simple experiments whilst giving enough flexibility to also allow sophisticated analysis of the most complex experiments.

Analysis for a simple experiment can be set up in less than 1 minute, whilst a highly complex experiment need take no longer than 5 minutes to set up. The FEAT programs then typically take 5-20 minutes to run (per first-level session), producing a web page analysis report, including colour activation images and time-course plots of data vs model.

The data modelling which FEAT uses is based on general linear modelling (GLM), otherwise known as multiple regression. It allows you to describe the experimental design; then a model is created that should fit the data, telling you where the brain has activated in response to the stimuli. In FEAT, the GLM method used on first-level (time-series) data is known as FILM (FMRIB's Improved Linear Model). FILM uses a robust and accurate nonparametric estimation of time series autocorrelation to prewhiten each voxel's time series; this gives improved estimation efficiency compared with methods that do not pre-whiten.

FEAT saves many images to file - various filtered data, statistical output and colour rendered output images - into a separate FEAT output directory for each session. If you want to re-run the statistical stage of analysis, you can do so without re-running any of the pre-processing, by telling FEAT to look in a FEAT directory for the processed functional data it needs to do this.

FEAT can also carry out the registration of the low resolution functional images to a high resolution scan, and registration of the high resolution scan to a standard (e.g. MNI152) image. Registration is carried out using FLIRT.

For higher-level analysis (e.g. analysis across sessions or across subjects) FEAT uses FLAME (FMRIB's Local Analysis of Mixed Effects). FLAME uses very sophisticated methods for modelling and estimating the random-effects component of the measured inter-session mixed-effects variance, using MCMC sampling to get an accurate estimation of the true random-effects variance and degrees of freedom at each voxel.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT/UserGuide)
  
## Nipype  
  
Current neuroimaging software offer users an incredible opportunity to analyze their data in different ways, with different underlying assumptions. Several sophisticated software packages (e.g., AFNI, BrainVoyager, FSL, FreeSurfer, Nipy, R, SPM) are used to process and analyze large and often diverse (highly multi-dimensional) data. However, this heterogeneous collection of specialized applications creates several issues that hinder replicable, efficient, and optimal use of neuroimaging analysis approaches: (1) No uniform access to neuroimaging analysis software and usage information; (2) No framework for comparative algorithm development and dissemination; (3) Personnel turnover in laboratories often limits methodological continuity and training new personnel takes time; (4) Neuroimaging software packages do not address computational efficiency; and (5) Methods sections in journal articles are inadequate for reproducing results. 
  
  
Nipype provides a uniform interface to existing neuroimaging software and facilitates interaction between these packages within a single workflow.
Nipype, an open-source, community-developed initiative under the umbrella of NiPy, is a Python project that provides a uniform interface to existing neuroimaging software and facilitates interaction between these packages within a single workflow. Nipype provides an environment that encourages interactive exploration of algorithms from different packages (e.g., ANTS, SPM, FSL, FreeSurfer, Camino, MRtrix, MNE, AFNI, Slicer), eases the design of workflows within and between packages, and reduces the learning curve necessary to use different packages. Nipype is creating a collaborative platform for neuroimaging software development in a high-level language and addressing limitations of existing pipeline systems.

Nipype allows you to:
Easily interact with tools from different software packages.
Combine processing steps from different software packages.
Develop new workflows faster by reusing common steps from old ones.
Process data faster by running it in parallel on many cores/machines.
Make your research easily reproducible.
Share your processing workflows with the community.  

## FSLr
R does not presently support several of the essential features of neuroimage processing, such as tissue segmentation and brain extraction. FSL, a well-known image processing and analysis software suite, is the foundation for the functions that fslr offers R users for image processing and analysis. The fslr package is a collection of R functions that work with FSL and manipulate 'nifti' image objects. The fslr package relies heavily on the oro.nifti (Whitcher et al., 2011) package implementation of images (referred to as ‘nifti’ objects) that are in the Neuroimaging Informatics Technology Initiative (NIfTI) format, as well as other common image formats such as ANALYZE. oro.nifti also provides useful functions for plotting and manipulating images. fslr expands on the oro.nifti package by providing additional functions for manipulation of ‘nifti’ objects.

By integrating with R's functionality, fslr enables users to create image processing and analysis pipelines based on FSL functionality. We give an illustration of how R users can use the FSL feature without switching to shell commands by analysing structural magnetic resonance images. Users can access well-tested software and a larger user base by integrating R with sophisticated, already-existing programmes, which would not be possible if the functionalities were rewritten in R. To summerize, the fslr workflow enables R users to manipulate array-like "nifti" objects, send them to fslr functions, and receive back "nifti" objects, making fslr simple to use for any ordinary R user. Furthermore, as FSL and R are open-source and free, all people can easily access this programme.

# References

[FSL Course Video Lectures 2021](https://www.youtube.com/watch?v=3ExL6J4BIeo&list=PLvgasosJnUVl_bt8VbERUyCLU93OG31h_)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[FSL](https://fsl.fmrib.ox.ac.uk/fslcourse/lectures/intro.pdf)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[fslr: Connecting the FSL Software with R](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4911193/pdf/nihms-792376.pdf)

[FSL Paper](https://pdf.sciencedirectassets.com/272508/1-s2.0-S1053811912X00119/1-s2.0-S1053811911010603/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEP7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIBZ7MKEXrri7SO%2FUC6a0OI1hQwmQXJ%2Fmn%2FmmJRcvkPzKAiEArbyUN7rgneoNXFX4fWxSlX1xXxEVw0RKEqw7YpZyjo8q0gQIRxAFGgwwNTkwMDM1NDY4NjUiDCAr2sAbUILLxNGqliqvBE%2BFWp07BWc9nwT0hV%2FYTyUTE0nmqEobsB6QURk7pWojxHnWxSsOrvnk%2FMHoNt69X75pfmAuIDzjhz6yRBt%2F8yh6VLbPc8QqbAUvzy5VTOcxDAh0x5B2%2FW6CMyhLK9B12aqOqK%2BnAwf6TEQDHKM%2FMnJofOwJIyTy5RJ6%2FWuwkmgZqtsm%2FD7T6iwG5G0DjfvucfgWziJxXki87TIamX5bW7f%2FYgLfYlaBspEuIB1sOQXaoBaQ0xlCA1thOXmZOlRVGJ2KdiPuZbOm9UB8lU29YRp3DUQre%2Fm3%2FnzRedoCxS9bKaAylMrO0buVsUn1kKB7Rma2LRvLnXBU4pkrvnj%2BdUaaZKC3ZOQm9wxSH6I1ZTSuilR0k27NVAYFTn%2FHpDWu%2FReoR7qduCJ7Lp8IdDNxnlypboUgNKLKZFMytwmtIig6PrDx06P0hzFyTx5JrD4V0WmiFHC6kSqyguqaEcAAvLBv6kznOg3f8Jgfqxk%2B3H6rPzRzE8YPMV3BuOT0%2FW74gLgM1S8%2FXq380IXxDdoJk5VafR62AUNIet4pB2Eb7%2B3ze8HlZEApJmwXR6D7eCdeZmOHot97T2J18bcnnni60g0XMBb%2FlPk3jkvYQDyz9kCcg7B56BZuGvj0t70%2Fnikq%2B0sb4avSd6YeHpxXWcL7rT3AHNRL62kpD%2Bx2ziMLGDu2NiS7VVkmTLOGHwxQnDy5eUfsFiY2%2FMxB97P6vcQ20hrfDW1RUe3XxbqmUQNlT6cwganllgY6qQEmwdZS8wKKOO0xX%2FBPlxcmU39utUibQui2X3v1jGxAMfwWNNgJLlH0vX%2FpVZTqIh8e4WuQ6DffRjq3sh5L6pJgXKwW2Rl5JdbD1msyclywL5a0J4jx68SJ9zZa74Y0xnJUrKJ0STPl3%2FiGUSNYFYEW7HnsaJuPdiyjzkYtEFSMc%2FKEUM4WbFFUBSuMrh%2BRGRbZq9aE8CL%2BT2C53uN3CZ5J1P17Tg2vk86L&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220721T142033Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYTWSMZFGV%2F20220721%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=1248d4ea5c26f6ea0457a0f0aa782b504e2a6d72591aa9623c1ed06f1be78ac7&hash=620a8e745bfba1abd2228f71614971ea12d9fd6e8fac5827322880a09e2498ed&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1053811911010603&tid=spdf-d9ee94e5-ee74-491d-b31b-1dfa79035d78&sid=c834f2a814e09140b719d9992d1e58347199gxrqa&type=client&ua=4d5c02565c50005b0c02&rr=72e493f4ca8e4bd0)
