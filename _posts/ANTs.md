## Introduction

The ANTs framework, originally, provided a set of open-source functionas for image registration with different levels of deformations with specific utility in neurodegenerative neuroimaging data where large deformation is required. ANTs has since grown to include bias correction, additional evaluation of multiple modalities and organ systems, univariate or multivariate image segmentation, tighter integration with the Insight ToolKit, a well-evaluated cortical thickness pipeline and, more recently, visualization tools and integration with R. It enables diffeomorphic normalization with a variety of transformation models, optimal template construction, multiple types of diffeomorphisms, multivariate similarity metrics, diffusion tensor processing and warping, image segmentation with and with out priors and measurement of cortical thickness from probabilistic segmentations. The normalization tools, alone, provide a near limitless range of functionality and allow the user to develop customized objective functions. ANTs serves as both a core library for further algorithm development and also as a command-line application-oriented toolkit with a permissive software license that allows it to be employed freely by industry.  

## antsRegistration 
The *antsRegistration* function is the central functionality encapsulating normalization/registration tasks. Its main output is an affine transform file and a deformation field, potentially with inverse. Options allow the user to navigate the similarity and transformations that are available. *antsRegistration* allows multiple similarity and optimization criteria as options. 

  
        antsRegistrationSyN <-input DSET>


The program is wrapped in *antsRegistrationSyN.sh* for normalization with default parameters and in *antsMultivariateTemplateConstruction2.sh* for computationally distributed optimal (multivariate) template construction. Initializing antsRegistration. It is also possbile to use the -r option in antsRegistration to initialize a registration with an ITK format transformation matrix, with a deformable mapping or with a center of mass alignment. 

##  antsApplyTransforms 

The *antsApplyTransforms* functionality applies ANTs mappings to images with different dimensionality. Several different interpolation options are available and multiple image types may be transformed including: tensors, vectors, timeseries and d-dimensional scalar images where d = 2;3; 4. It also composes transforms together and is able to compute inverses of lowdimensional (affine, rigid) maps. The sub function *antsApplyTransformsToPoints* similarly works on point sets.

  
        antsApplyTransforms <-input DSET>


*antsApplyTransforms* composes a series of affine and deformable mappings and/or their inverses, hence it avoids repeated interpolations of a single image. 

##  antsMotionCorr 

Performs motion correction of time-series data. Control parameters are similar to antsRegistration. See the [example](http://stnava.github.io/fMRIANTs/) showing how to run basic *CompCor* on fmri data. Our minimal fMRI pipeline involves running *antsMotionCorr* and *CompCorr* to factor out nuisance variables.
  
        antsMotionCorr <-input DSET>


## Data visualization with ANTs

Data visualization is important for producing figures for manuscripts, qualitative inspection of results, facilitating collaborations, and gaining insight into data and data transformations. ANTs provides three flexible programs to help with such tasks which we describe below. For layering image data, it is often useful to map the grayscale image intensity values to distinct colormaps.

### Creating faux-colormapped images with ConvertScalarImageToRGB

*ConvertScalarImageToRGB* interfaces permits conversion of grayscale intensity scalar images to RGB colormapped images. Additionally, these custom colormaps can be used as examples to build one’s own set of colormaps for use with *ConvertScalarImageToRGB*. Converting scalar images to RGB intensities is also a preprocessing step for the next two programs described: *CreateTiledMosaic* and *antsSurf*.

### Figure production and large-scale data inspection using CreateTiledMosaic

The program CreateTiledMosaic in conjunction with ConvertScalarImageToRGB provides useful functionality for common image analysis tasks. The basic usage of CreateTiledMosaic is to tile a 3-D image volume slice-wise into a 2-D image. The help menu CreateTiledMosaic --help provides more in-depth coverage of options but some of the functionality includes:

+ Padding or cropping each tile element
+ Alpha channel for translucent overlaid rob maps
+ Flipping or permuting of each tile element
+ Comprehensive slice selection
+ Tiling pattern (i.e. custom number of rows and/or columns)

### Volumetric visualizations with antsSurf

*antsSurf* is used to produce volumetric surface renderings from binary images with optional functional overlays with a comprehensive description of functionality but some available options include:

+ Specification of more than one functional overlay
+ Painting of functional overlays based on order on the command line
+ Localization of the functional overlay within a specified masked region
+ Manual reorientation
+ Manual adjustment of solid background and surface colors 
+ Simple estimation of binary image given a mesh

## Statistics with ANTs and R: ANTsR
R is an open-source statistical echosystem used by statisticians world-wide. ANTs is designed to interface with R via the [ANTsR](https://github.com/ANTsX/ANTsR) package. 

Some of the ANTsR functionallies adapted for neuro-imaging research are as follows:

+ Inter-modality inference
+ Eigenanatomy for multiple modality population studies function sparseDecom
+ Tumor segmentation function mrvnrfs 
+ Multiple modality pediatric template 
+ Structural networks from subject-level data 
+ Sparse regression with manifold smoothness constraints 
+ Prior-based eigenanatomy function sparseDecom


## More ANTs examples
The ANTs [paper](http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract) iincludes links to several more examples for above-mentioned functionalities and more such as morphometry. Many other examples are available in the literature on [ATNs on Scholar](https://scholar.google.com/citations?user=ox-mhOkAAAAJ&hl=en).

## References

+ [ANTs Documentation](http://stnava.github.io/ANTs/)

+ [ANTs paper](http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract) 

+ [ATNs on Scholar](https://scholar.google.com/citations?user=ox-mhOkAAAAJ&hl=en)
