

## FSL

Developed primarily by members of the Analysis Group of FMRIB at Oxford, the FSL (the FMRIB Software Library) is a comprehensive library of analysis tools for different modilities of brain imaging data.  With over two hundred individual command line tools (approximately 140 scripts and 90 compiled C++ programs — including 50 small/flexible tools in the “fslutils” set) FSL divides into three main areas, related to functional, diffusion and structural image analysis. Additionally, GUIs make FSL incredibly flexible but quite difficult for a beginner to utilise. The different underlying command-line utilities are provided with a straightforward interface and pipe-line by GUIs. The existence of a command log file that is output by the GUI makes it simpler to reproduce an analysis that was performed using a GUI using solely command-line tools. Although some of the "bigger" FSL GUIs already take care of automatically spreading jobs over a cluster, this makes custom scripting reasonably simple, including parallelizing work on a computing cluster. We'll go over some of the frequently used FSL tools (in the context of structural and functional MRI) in the sections below.

### Outline of some useful commands for structural and functional MRI

### Structural MRI analysis

#### BET [Brain extraction](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET)

The capacity to precisely separate brain from non-brain tissue is important for a wide variety of applications in brain imaging. Because of the nature of the imaging, FMRI and PET functional images frequently contain little non-brain tissue, whereas high-resolution MR images are likely to contain a significant amount—eyes, skin, fat, muscle, etc.—and registration robustness is improved if these non-brain parts of the image can be automatically removed before registration. Additionally, for many tissue-type segmentation methods to work effectively, brain-nonbrain segmentation must have been completed first. The Brain Extraction Tool is a fully automated brain extraction that functions dependably on a number of MR modalities. A triangular tessellation of a spherical surface is initially initiated inside the brain and then allowed to expand, one vertex at a time, while being propelled toward the edge of the brain by forces that keep the surface evenly spaced and smooth. If a clean enough solution cannot be found, the entire procedure is repeated with a tighter smoothness restriction. The outside surface of the skull can also be estimated, if necessary. BET is a component of numerous functional MRI processing packages as well as the whole-brain volume change measuring methods SIENA and SIENAX. The brain surface is modelled by BET using a tessellated mesh, which is then allowed to deform in accordance with various dynamic regulating parameters until it reaches the brain edge. The performance of BET can be optimised using a variety of variables and factors.


[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/BET/UserGuide)

#### FAST [Tissue segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST)

The FAST module divides the brain into various tissue types while adjusting for bias field. The tool is simple to use: Provide a brain that has been stripped of its skull, then pick how many tissue classes to section (e.g. three tissue classes: White matter, grey matter, and cerebrospinal-fluid). However, you might wish to raise the number of classes to four in order to separate the lesion into its own class if you are working with a person that has a brain abnormality (lesion). Each tissue type's dataset is produced using FAST. One output dataset will correspond to each tissue class, for instance, if three different tissue types were segmented. Each dataset is a mask for each tissue type and comprises a fraction estimate at each voxel.

After separating the brain from the non-brain, each voxel can be divided into grey matter, white matter, cerebrospinal fluid (CSF). This process is known as tissue-type segmentation. Once the best intensity thresholds for differentiating between the various tissue classes have been identified, it is usual practise to segment voxels using their intensity. This can be thought of as an analysis of the image histogram, where the various classes show up as separate peaks and spreaded by elements like image noise, motion artefacts, partial-volume effect, bias field, and true within-class variation. 

A mixture of Gaussians (one for each class) are used to model the histogram, which provides the mean (and variance) intensity for each class. The labelling of each voxel is subsequently determined by accounting for both its local neighbours' labels as well as its intensity in relation to the estimated class means. By subtracting the idealised image from the actual image (and smoothing), segmentation enables an approximation of the bias field. Then, the entire process is repeated multiple times. A major issue is that accurate segmentation knowledge is necessary for robust estimation of the bias field, and vice versa. Due to the circularity of the dependence, iterating between estimating the segmentation and the bias field until convergence is the only sensible method to both problems.

FAST models the partial volume effect at each voxel if necessary. Regarding the global class (tissue-type) means and variances, the voxel's intensity. If more than one input modality (type of image) is available, this method is simply generalised to "multichannel segmentation." Since segmentation priors tend to be quite blurry and consequently not very helpful, FAST does not by default utilise segmentation priors (pictures in standard space showing the expected distribution of the tissue types, averaged over many patients). However, in the event if the bias field is extremely poor, this option can be enabled to help with the first segmentation.

  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FAST/UserGuide)


#### FIRST [Subcortical segmentation](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST)
  
Due to the weak and fluctuating intensity contrast, automatic segmentation of subcortical regions in human brain MR images is a crucial yet challenging endeavour. In many instances, well-defined intensity features and typical structural boundaries are absent, necessitating the addition of additional data to successfully segment the data. For automated approaches, achieving this in the subcortical regions of the brain is quite difficult. FIRST is a Bayesian framework-based shape and appearance model that is computationally effective and integrates information about both intra- and inter-structure variability. It also accounts for the small size of the training set in relation to the dimensionality of the data. It is on par with skilled human specialists who manually segment images using their prior understanding of shape, picture intensities, and correlations between shapes. FIRST is able to segment subcortical structures, analyse shape variations between groups, and highlight where alterations to these structures and changes to the overall volume have occurred. FIRST is a segmentation and registration technique based on models. FIRST's shape/appearance models are built using manually segmented photos that are parameterized as surface meshes and modelled as point distribution models. The multivariate Gaussian presumptions provide the foundation of the shape and appearance model. Principal components are then used to depict shape as a mean with modes of variation. FIRST looks through linear combinations of shape modes of variation based on our learnt models to find the shape instance that matches the measured intensities in a T1-weighted image the most closely.
  
[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIRST/UserGuide)

#### FLIRT [Linear registration](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT)

FLIRT—affine intermodal image registration
  
For the majority of brain image analysis tools, reliable and automated picture registration is a fundamental feature. The ability to quickly, accurately, robustly, and objectively align images of the same or different modalities is provided by registration. Registration is essential for many applications, including locating functional activations within a subject's own neuroanatomy and enabling group comparisons by registering images to a reference image. Through this procedure, which superimposes the images on top of one another, we are able to look into joint distributions of voxel intensities from various image modalities. Utilizing the Linear Image Registration Tool from FMRIB, this is accomplished. Since the images are from the same person, we may presume that the brain's general shape hasn't altered, but it's possible that each scan has undergone a translation and/or rotation in space. A rigid-body transformation with six degrees of freedom will be used as a result (dof). However, a recurrent issue is that registration techniques can fail to yield "reasonable" results, with severe misalignment being readily apparent. When the photos being registered are initially in various orientations, these failures frequently happen.

As the registration parameters (such as rotation and translation) are changed, the conventional framework for intensity-based registration comprises the minimization of a cost function (which quantifies how well aligned two pictures are). Therefore, nonideal cost functions (which return minimum values for poor alignments) or nonideal optimization techniques (which fail to obtain the (global) minimum value of the cost function) are the root causes of misregistrations. Using information theory, acceptable cost functions have been proposed for image registration, for instance. Even though "being trapped" in a local minimum is the primary reason for many registration approaches to fail, little work has been done to improve optimization strategies for picture registration.
  
There are numerous causes for a registration not to function properly. A broad list of things to test and try in order to enhance registration outcomes is provided below: 

By (a) examining the images with slices (none of the views should appear squished or stretched), and (b) examining the voxel measurements, confirm that the input image appears fine and that the voxel size is accurate. 

Remove non-brain structures from both pictures using BET (Note that small errors in the BET results will only have a very small impact on the registration quality) 

Try using fast to create a restored image (one with no bias field) if there is a significant bias field (slow intensity change, particularly near the end slices), and then register using the restored image. 

The registration may benefit from employing cost function weighting to increase the value of this region if there are relatively tiny errors in some important region of interest (for example, ventricles). To do this, a weighting picture with a value of 1.0 everywhere but the region of interest should be created. This region should have a larger weight, such as 10.0. The fit in this region should be improved by using this weighting volume in either the GUI or command line registration calls.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FLIRT/UserGuide)  
  
  
#### MCFLIRT [Intra-modal motion correction tool](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT)
  
The photographs will appear hazy if the subject is moving during the imaging session. Additionally, there is a chance of measuring a signal from a voxel from a different location or tissue type if the individual moves around a lot. For instance, If the subject moves every time in response to a stimulus - for example, if he jerks his head every time he feels an electrical shock - then it can become impossible to determine whether the signal we are measuring is in response to the stimulus, or because movement. The patient movement can cause considerable motion artefacts in FMRI analysis. This is especially true at tissue boundaries, the edge of the brain, or next to major blood arteries. Based on the affine registration tool in FSL, a rigid-body motion correction tool was created. Since there is little movement from one volume to the next during a FMRI sequence, this method (MCFLIRT) utilises the same cost function regularisation techniques as FLIRT but does not require multistart optimization techniques. Instead, the instrument was specially tailored to be extremely accurate for common FMRI data.

However, since the volume is not collected at a single instant but rather at several times for each slice, motion correction is a naturally nonrigid problem. Because each slice undergoes a somewhat different rigid-body transformation when the head moves, whole-volume rigid-body correction is oversimplified. Furthermore, the assumptions of the ensuing temporal analysis are inconsistent with the fact that each slice has slightly altered time relative to the others. Applying a slice-timing correction (interpolation within each voxel's time series) either before or after rigid-body motion correction is a common way to address this. Applying slice-timing corrections and rigid-body motion corrections separately (or in any particular order) is flawed since the two issues exist simultaneously and must be resolved as a single integrated problem.

In order to achieve this, we created a model of the slice transformation process with a limited degree of freedom, assuming smooth motion within each TR. (This model approximates the actual circumstance where any abrupt little motion could happen during a TR.) Since no single volume is likely to be able to be depended upon to offer a reference volume that is sufficiently free from motion, cost functions are expanded from the 3D situation to encompass the complete 4D data set. According to preliminary findings, this method can reduce final motion-related error in comparison to independent rigid-body correction and slice-timing correction.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MCFLIRT/UserGuide)

### Functional MRI analysis
  
  

  
#### MELODIC [Multivariate Exploratory Linear Optimized Decomposition into Independent Components](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC)
  
A common exploratory technique for evaluating complex data, such as that from FMRI research, is independent component analysis (ICA). In order to depict various artefacts or activation patterns, ICA seeks to divide the data into (statistically) separate spatial maps. This approach, does not require a (temporal) model because it analyses the entire 4D data set at once. However, the use of such a model-free approaches has been constrained both by the view that results may be difficult to interpret and by the incapacity to calculate statistical significance for estimated spatial maps.

A probabilistic ICA model for FMRI that describes the observations as mixtures of spatially non-Gaussian signals was proposed by Beckmann and Smith in 2004. They showed how Bayesian estimation of the amount of Gaussian noise can be used to circumvent the overfitting issue. The method suggested for determining the appropriate model order (i.e., how many ICA components to identify) also permits a distinctive decomposition of the data and lessens issues with interpretation because each final component is more likely to be the result of just one physical or physiological event.This methodology is implemented as Multivariate Exploratory Linear Optimized Decomposition into Independent Components (MELODIC).
  
MELODIC's single-session ICA processes each of the input files using a typical 2D ICA procedure. A 2D time x space matrix will be used to represent each input data set. After that, MELODIC separates each matrix into pairs of time courses and spatial mappings. When utilising single-session ICA, the components are arranged in decreasing order of the proportion of variance that is uniquely explained. MELODIC will attempt to identify non-Gaussian residuals within session/subject variance as well as more pertinent components. It is recommended to use this option in order to check for session-specific effects (i.e.artefacts).
 

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/MELODIC/UserGuide)
  
  
#### FEAT [Functional preprocessing and analysis](http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT)

FEAT automates as many analysis decisions as it can, making it feasible to analyse simple experiments in a straightforward manner that is nonetheless effective, fast, and valid while still allowing for sophisticated analysis of even the most challenging trials. A highly complex experiment only needs to take few minutes to set up, whereas analysis for a basic experiment can be set up in less than five minute. The FEAT programmes then typically take 5 to 20 minutes to run (per first-level session), providing an analysis report of a web page that includes colour activation images and time-course charts of data versus model. The data modelling which FEAT uses is based on general linear modelling (GLM), otherwise known as multiple regression. FEAT enables you to explain the experimental setup, after which a model is built to fit the data and reveal the brain regions that responded to the stimuli. The GLM technique used in FEAT is referred to as FILM (FMRIB's Improved Linear Model), and it is utilised on first-level (time-series) data. In contrast to approaches that do not pre-whiten, FILM uses a robust and accurate nonparametric estimation of time series autocorrelation to pre-whiten the time series of each voxel.

For every session, FEAT creates a distinct FEAT output directory where it stores a large number output, including various filtered data, statistical output, and colour rendered output images. If you instruct FEAT to look in a directory for the pre-processed functional data, you can perform the statistical stage of analysis without repeating any of the pre-processing.   FEAT is also capable of registering high-resolution scans to standard pictures (like MNI152) and low-resolution functional images to high-resolution scans using the FLIRT functionality as described above.

For higher-level analysis (e.g. analysis across sessions or across subjects) FEAT uses FLAME (FMRIB's Local Analysis of Mixed Effects). FLAME uses MCMC sampling for estimating the fixed and random-effects component of the measured inter-session and intra-session variance to get an accurate estimation of the true effect of stimuli on each voxel.

[UserGuide](https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FEAT/UserGuide)
 
## Python and R interfaces 

To enable FSL users to accees imaging-specific features without switching to shell commands external collaborators developed Python and R interfaces. 

### Nipype  
  
Users of the most modern neuroimaging software have a fantastic opportunity to examine their data in various ways and on various underlying assumptions. Large and often heterogeneous (highly multi-dimensional) data are processed and analysed using a variety of sophisticated software programmes, such as AFNI, BrainVoyager, FSL, FreeSurfer, Nipy, R, and SPM. However, this fragmented group of specialised applications raises a number of problems that prevent the optimal, effective, and repeatable use of neuroimaging analysis methodologies. (1) There is inconsistent access to neuroimaging analysis software and usage data; (2) There is no framework for comparing algorithm development and dissemination; (3) Laboratories regularly face staff turnover, which hinders methodological continuity; (4) Neuroimaging software packages do not take computational efficiency into account; and (5) Methods sections in journal articles are insufficient for replicating results.
  
  
In order to enable communication across various programmes within a single workflow, Nipype offers a standard interface to modern neuroimaging tools. 
The Python project Nipype, an open-source, community-developed endeavour under the NiPy umbrella, offers a consistent interface to current neuroimaging tools and makes it easier for different packages to interact with one another inside a single workflow. Nipype offers a setting that promotes interactive exploration of algorithms from various packages, such as ANTS, SPM, FSL, FreeSurfer, Camino, MRtrix, MNE, AFNI, and Slicer. It also makes it easier to design workflows both within and between packages and lessens the learning curve associated with using various packages. In order to address the shortcomings of current pipeline systems, Nipype is developing a collaborative platform for neuroimaging software development in a high-level language. Using Nipype you may easily interface with tools and combine processing operations from many software packages; reuse common stages from previous workflows, which might help you create new ones more quickly. Moreover, itallows running data in parallel across numerous cores/machines that speed up processing. Finally, share your workflows for processing and make it simple to replicate your research. 

### FSLr
R does not presently support several of the essential features of neuroimage processing, such as tissue segmentation and brain extraction. FSL, a well-known image processing and analysis software suite, is the foundation for the functions that fslr offers R users for image processing and analysis. The fslr package is a collection of R functions that work with FSL and manipulate 'nifti' image objects. The fslr package relies heavily on the oro.nifti (Whitcher et al., 2011) package implementation of images (referred to as ‘nifti’ objects) that are in the Neuroimaging Informatics Technology Initiative (NIfTI) format, as well as other common image formats such as ANALYZE. oro.nifti also provides useful functions for plotting and manipulating images. fslr expands on the oro.nifti package by providing additional functions for manipulation of ‘nifti’ objects.

By integrating with R's functionality, fslr enables users to create image processing and analysis pipelines based on FSL functionality. R users can use the FSL feature without switching to shell commands by analysing structural magnetic resonance images. Users can access well-tested software and a larger user base by integrating R's sophisticated, already-existing packages. To summerize, the fslr workflow enables R users to manipulate array-like "nifti" objects, send them to fslr functions, and receive back "nifti" objects, making fslr simple to use for any ordinary R user. Furthermore, as FSL and R are open-source and free, all people can easily access this programme.

# References

[FSL Course Video Lectures 2021](https://www.youtube.com/watch?v=3ExL6J4BIeo&list=PLvgasosJnUVl_bt8VbERUyCLU93OG31h_)

[FSL website](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)


