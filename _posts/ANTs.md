## Introduction

The ANTs framework, originally, provided a set of open-source functionas for image registration with different levels of deformations with specific utility in neurodegenerative neuroimaging data where large deformation is required. ANTs has since grown to include bias correction, additional evaluation of multiple modalities and organ systems, univariate or multivariate image segmentation, tighter integration with the Insight ToolKit, a well-evaluated cortical thickness pipeline and, more recently, visualization tools and integration with R. It enables diffeomorphic normalization with a variety of transformation models, optimal template construction, multiple types of diffeomorphisms, multivariate similarity metrics, diffusion tensor processing and warping, image segmentation with and with out priors and measurement of cortical thickness from probabilistic segmentations. The normalization tools, alone, provide a near limitless range of functionality and allow the user to develop customized objective functions. ANTs serves as both a core library for further algorithm development and also as a command-line application-oriented toolkit with a permissive software license that allows it to be employed freely by industry.  

## antsRegistration 
The antsRegistration program itself is the central program encapsulating normalization/registration functionality. Its main output is an affine transform file and a deformation field, potentially with inverse. Options allow the user to navigate the similarity and transformations that are available. antsRegistration allows multiple similarity and optimization criteria as options. 

  
        antsRegistration <-input DSET>


The program is wrapped in antsRegistrationSyN.sh for normalization with “out of the box” parameters and in antsMultivariateTemplateConstruction2.sh for computationally distributed optimal (multivariate) template construction. Initializing antsRegistration. You can use the -r option in antsRegistration to initialize a registration with an ITK .mat format transformation
matrix, with a deformable mapping or with a center of mass alignment. See the scripts for examples. The output transformation will include the initial transformation.

##  antsApplyTransforms 
The antsApplyTransforms program applies ANTs mappings to images including scalars, tensors, timeseries and vector images. It also composes transforms together and is able to compute inverses of lowdimensional (affine, rigid) maps. antsApplyTransformsToPoints similarly works on point sets. One may apply an arbitrarily long series of transformations through these programs.

  
        antsApplyTransforms <-input DSET>


Thus, they enable one to compose a series of affine and deformable mappings
and/or their inverses. One may therefore avoid repeated interpolations of a single image. Several different interpolation options are available and multiple image types may be transformed including: tensors, vectors, timeseries and d-dimensional scalar images where d = 2;3; 4.

##  antsMotionCorr 

Performs motion correction of time-series data. Control parameters are similar to antsRegistration. See the [example](http://stnava.github.io/fMRIANTs/) that demonstrates how to run basic CompCor on fmri data. Our minimal fMRI pipeline involves running antsMotionCorr and CompCorr to factor out nuisance variables. More complex approaches require ANTsR.
  
        antsMotionCorr <-input DSET>


## Data visualization with ANTs

Data visualization is important for producing figures for manuscripts, qualitative inspection of results, facilitating collaborations, and gaining insight into data and data transformations. ANTs provides three flexible programs to help with such tasks which we describe below. For layering image data, it is often useful to map the grayscale image intensity values to distinct colormaps. We introduced such a processing framework into ITK described in. The ANTs program ConvertScalarImageToRGB interfaces this framework and permits conversion of grayscale intensity scalar images to RGB colormapped images which can be viewed in programs such as ITKSNAP. Converting scalar images to RGB intensities is also a preprocessing step for the next two programs described: CreateTiledMosaic and antsSurf. In addition to the built-in colormaps which are currently part of ITK, we also have several custom colormaps. Additionally, these custom colormaps can be used as examples to build one’s own set of colormaps for use with ConvertScalarImageToRGB.

## Statistics with ANTs and R: ANTsR
R is an open-source, cutting-edge statistical package used by statisticians world-wide. ANTs is designed to interface with R via the ANTsR package. Google this and learn more. Most statistical requirements may be met with this setup.

## More ANTs examples
The [paper](http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract) shows or links to several more examples. Some of these include morphometry. Many other examples are available in the literature Google Scholar Search.

## References

+ [ANTs Documentation](http://stnava.github.io/ANTs/)

+ [ANTs paper](http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract) 

+ [ATNs on Scholar](https://scholar.google.com/citations?user=ox-mhOkAAAAJ&hl=en)
