## Introduction

Originally, the ANTs framework provided open-source functionality for deformable image registration with small or large deformations, as
shown in figure 1. Independent evaluation of the 0.0 version of ANTs software, applied to “control” data, placed the toolkit as a top performer amongst 14 methods [26]. Developer evaluation showed stronger differences with other methodology in neurodegenerative neuroimaging data, where large deformation is required [10]. ANTs has since grown to include N4 bias correction [37], additional evaluation of multiple modalities and organ systems [36, 38, 28], univariate or multivariate image segmentation [19, 40], tighter integration with the Insight ToolKit [35, 17], a well-evaluated cortical thickness pipeline [41] and, more recently, visualization tools and integration with R[42]. ANTs serves as both a core library for further algorithm development and also as a command-line application-oriented toolkit. ANTs also has a permissive software  license that allows it to be employed freely by industry [31]. ANTs enables diffeomorphic normalization with a variety of transformation models, optimal template construction, multiple types of diffeomorphisms, multivariate similarity metrics, diffusion tensor processing and warping, image segmentation with and with out priors and measurement of cortical thickness from probabilistic segmentations. The normalization tools, alone, provide a near limitless range of functionality and allow the user to develop customized objective functions.

## The antsRegistration executable
The antsRegistration program itself is the central program encapsulating normalization/registration functionality. Its main output is an affine transform file and a deformation field, potentially with inverse. Options allow the user to navigate the similarity and transformations that are available. antsRegistration allows multiple similarity and optimization criteria as options. The program is wrapped in antsRegistrationSyN.sh for normalization with “out of the box” parameters and in antsMultivariateTemplateConstruction2.sh for computationally distributed optimal (multivariate) template construction. Initializing antsRegistration. You can use the -r option in antsRegistration to initialize a registration with an ITK .mat format transformation
matrix, with a deformable mapping or with a center of mass alignment. See the scripts for examples. The output transformation will include the initial transformation.

## The antsApplyTransforms executable
The antsApplyTransforms program applies ANTs mappings to images including scalars, tensors, timeseries and vector images. It also composes transforms together and is able to compute inverses of lowdimensional (affine, rigid) maps. antsApplyTransformsToPoints similarly works on point sets. One may apply an arbitrarily long series of transformations through these programs. Thus, they enable one to compose a series of affine and deformable mappings
and/or their inverses. One may therefore avoid repeated interpolations of a single image. Several different interpolation options are available and multiple image types may be transformed including: tensors, vectors, timeseries and d-dimensional scalar images where d = 2;3; 4.

## The antsMotionCorr executable
Performs motion correction of time-series data. Control parameters are similar to antsRegistration. See the example http://stnava.github.io/fMRIANTs/. This example also shows how to run basic CompCor on fmri data. Our minimal fMRI pipeline involves running antsMotionCorr and CompCorr to factor out
nuisance variables. More complex approaches require ANTsR.

## More ANTs examples
The paper http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract shows or links to several
more examples. Some of these include morphometry. Many other examples are available in the literature
Google Scholar Search.

## References

[ANTs](http://stnava.github.io/ANTs/)

http://journal.frontiersin.org/Journal/10.3389/fninf.2014.00044/abstract 

https://scholar.google.com/citations?user=ox-mhOkAAAAJ&hl=en
