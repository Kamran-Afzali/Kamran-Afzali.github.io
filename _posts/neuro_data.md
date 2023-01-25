### Introduction

The brain occupies space, so it is possible to collect data on how it fills space, also called volume data. All the volume data needed to create the complete, 3D image of the brain, recorded at one single timepoint is called a *volume*. The data is measured in voxels, which are like the pixels used to display images on your screen, only in 3D. Each voxel has a specific dimension, with the same dimension from all sides (isotropic). Each voxel contains one value which stands for the average signal measured at the given location. A standard anatomical volume, with an isotropic voxel resolution of 1mm contains almost 17 million voxels, which are arranged in a 3D matrix of 256 x 256 x 256 voxels. 
As the scanner can’t measure the whole volume at once it has to measure portions of the brain sequentially in time. This is done by measuring one plane of the brain (generally the horizontal one) after the other. The resolution of the measured volume data, therefore, depends on the in-plane resolution (the size of the squares in the above image), the number of slices and their thickness (how many layers), and any possible gaps between the layers. The quality of the measured data depends on the resolution and the following parameters:

+ Repetition time (TR): time required to scan one volume

+ Acquisition time (TA): time required to scan one slice. TA = TR - (TR/number of slices)

+ field of view (FOV): defines the extent of a slice, e.g. 256mm x 256mm

### Specifics of MRI Data

MRI scanners output their neuroimaging data in a raw data format with which most analysis packages cannot work. DICOM is a common, standardized, raw medical image format. Raw data is saved in k-space format, and it needs to be converted into a format that the analysis packages can use. The most frequent format for newly generated data is called NIfTI. MRI data formats will have an image and a header part. For NifTI format, they are in the same file (.nii-file), whereas in the older Analyze format, they are in separate files (.img and .hdr-file). The image is the actual data and is represented by a 3D matrix that contains a value (e.g. gray value) for each voxel.
The header contains information about the data like voxel dimension, voxel extend in each dimension, number of measured time points, a transformation matrix that places the 3D matrix from the image part in a 3D coordinate system, etc.

### Modalities of MRI Data

There are many different kinds of acquisition techniques. But the most common ones are structural magnetic resonance imaging (sMRI), functional magnetic resonance imaging (fMRI) and diffusion tensor imaging (DTI).

#### sMRI (structural MRI)

Structural magnetic resonance imaging (sMRI) is a technique for measuring the anatomy of the brain. By measuring the amount of water at a given location, sMRI is capable of acquiring a detailed anatomical picture of our brain. This allows us to accurately distinguish between different types of tissue, such as gray and white matter, with grey matter structures are seen in dark, and the white matter structures in bright colors. Structural images are high-resolution images of the brain that are used as reference images for multiple purposes, such as corregistration, normalization, segmentation, and surface reconstruction. As the anatomy is not supposed to change while the person is in the scanner, a higher resolution can be used for recording anatomical images, with a voxel extent of 0.2 to 1.5mm, depending on the strength of the magnetic field in the scanner, e.g. 1.5T, 3T or 7T. 

#### fMRI (functional MRI)

Functional magnetic resonance imaging (fMRI) is a technique for measuring brain activity by detecting the changes in blood oxygenation and blood flow that occur in response to neural activity. Brain needs a lot of energy to sustain its functionality, and increased activity at a location increases the local energy consumption in the form of oxygen (O2) which is carried by the blood. Therefore, increased function results in increased blood flow towards the energy consuming location. Immediately after neural activity the blood oxygen level decreases, known as the initial dip, because of the local energy consumption. This is followed by increased flow of new and oxygen-rich blood towards the energy consuming region. After 4-6 seconds a peak of blood oxygen level is reached. After no further neuronal activation takes place the signal decreases again and typically undershoots, before rising again to the baseline level. The blood oxygen level is exactly what we measure with fMRI. The MRI Scanner is able to measure the changes in the magnetic field caused by the difference in the magnetic susceptibility of oxygenated (diamagnetic) and deoxygenated (paramagnetic) blood. The signal is therefore called the Blood Oxygen Level Dependent (BOLD) response. Because the BOLD signal has to be measured quickly, the resolution of functional images is normally lower (2-4mm) than the resolution of structural images (0.5-1.5mm). But this depends strongly on the strength of the magnetic field in the scanner, e.g. 1.5T, 3T or 7T. In a functional image, the gray matter is seen as bright and the white matter as dark colors, which is the exact opposite to structural images.

##### fMRI designs.

+ Event-related design
  + Event-related means that stimuli are administered to the subjects in the scanner for a short period. The stimuli are only administered briefly and generally in random order. Stimuli are typically visual, but audible or or other sensible stimuli could also be used. This means that the BOLD response consists of short bursts of activity, which should manifest as peaks.

+ Block design
  + If multiple stimuli of a similar nature are shown in a block, or phase, of 10-30 seconds, that is a block design. Such a design has the advantages that the peak in the BOLD signal is not just attained for a short period but elevated for a longer time, creating a plateau in the graph. This makes it easier to detect an underlying activation increase.

+ Resting-state design
  + Resting-state designs acquire data in the absence of stimulation. Subjects are asked to lay still and rest in the scanner without falling asleep. The goal of such a scan is to record brain activation in the absence of an external task. This is sometimes done to analyze the functional connectivity of the brain.

#### dMRI (diffusion MRI)

Diffusion imaging is done to obtain information about the brain’s white matter connections. There are multiple modalities to record diffusion images, such as diffusion tensor imaging (DTI), diffusion spectrum imaging (DSI), diffusion weighted imaging (DWI) and diffusion functional MRI (DfMRI). By recording the diffusion trajectory of the molecules (usually water) in a given voxel, one can make inferences about the underlying structure in the voxel. For example, if one voxel contains mostly horizontal fiber tracts, the water molecules in this region will mostly move in a horizontal manner, as they can’t move vertically because of this neural barrier. There are many different diffusion measurements, such as mean diffusivity (MD), fractional anisotropy (FA) and Tractography. Each measurement gives different insights into the brain’s neural fiber tracts. Diffusion MRI is a rather new field in MRI and still has some problems with its sensitivity to correctly detect fiber tracts and their underlying orientation. For more about diffusion MRI see the Diffusion MRI Wikipedia page.

### Data science tools for neuroimaging

In previous chapters, we saw that there is plenty of things that you can do with general-purpose software and data science tools. Many of the examples used data from neuroimaging experiments, but the ideas that we introduced – arrays and computing with arrays, tables and how to manipulate tabular data, scientific computing, and data visualization – were not specific to neuroimaging. In this chapter, we will discuss data science approaches that are specifically tailored to neuroimaging data. First (in Section 11.1), we will present a survey of neuroimaging-specific software implemented in Python. Next (in Section 11.2), we will discuss how to organize data from neuroscience experiments for data analysis that best takes advantage of these software tools. In the following chapters, we will dive into some of the applications of these data science tools to fundamental problems in neuroimaging data analysis.

### Neuroimaging in Python

Within the broader ecosystem of Python tools for science, there is a family of tools specifically focused on neuroimaging (we will refer to them collectively as “NiPy”, which stands for “Neuroimaging in Python”). These software tools, developed by and for neuroimaging researchers, cover a wide range of data analysis tasks on a variety of different kinds of experimental data. In the next few sections, we will see in detail how some of these tools are used. But first, we will provide a broad survey of the different kinds of tools that currently exist. It is important to emphasize that this is a very dynamically evolving ecosystem, and some of these tools may evolve into other tools over time, or even disappear. New tools will inevitably also emerge. So, this survey will be, by necessity, a bit superficial and a bit dated. That said, we’ll try to give you a sense of how an ecosystem like this one emerges and evolves so that you can keep an eye on these trends as they play out in the future.


### Software Packages
There are many different software packages to analyze neuroimaging data. Most of them are open source and free to use (with the exception of BrainVoyager). The most popular ones (SPM, FSL, & AFNI) have been around a long time and are where many new methods are developed and distributed. These packages have focused on implementing what they believe are the best statistical methods, ease of use, and computational efficiency. They have very large user bases so many bugs have been identified and fixed over the years. There are also lots of publicly available documentation, listserves, and online tutorials, which makes it very easy to get started using these tools.

There are also many more boutique packages that focus on specific types of preprocessing step and analyses such as spatial normalization with ANTs, connectivity analyses with the conn-toolbox, representational similarity analyses with the rsaToolbox, and prediction/classification with pyMVPA.

Many packages have been developed within proprietary software such as Matlab (e.g., SPM, Conn, RSAToolbox, etc). Unfortunately, this requires that your university has site license for Matlab and many individual add-on toolboxes. If you are not affiliated with a University, you may have to pay for Matlab, which can be fairly expensive. There are free alternatives such as octave, but octave does not include many of the add-on toolboxes offered by matlab that may be required for a specific package. Because of this restrictive licensing, it is difficult to run matlab on cloud computing servers and to use with free online courses such as dartbrains. Other packages have been written in C/C++/C# and need to be compiled to run on your specific computer and operating system. While these tools are typically highly computationally efficient, it can sometimes be challenging to get them to install and work on specific computers and operating systems.

There has been a growing trend to adopt the open source Python framework in the data science and scientific computing communities, which has lead to an explosion in the number of new packages available for statistics, visualization, machine learning, and web development. pyMVPA was an early leader in this trend, and there are many great tools that are being actively developed such as nilearn, brainiak, neurosynth, nipype, fmriprep, and many more. One exciting thing is that these newer developments have built on the expertise of decades of experience with imaging analyses, and leverage changes in high performance computing. There is also a very tight integration with many cutting edge developments in adjacent communities such as machine learning with scikit-learn, tensorflow, and pytorch, which has made new types of analyses much more accessible to the neuroimaging community. There has also been an influx of younger contributors with software development expertise. You might be surprised to know that many of the popular tools being used had core contributors originating from the neuroimaging community (e.g., scikit-learn, seaborn, and many more).

For this course, I have chosen to focus on tools developed in Python as it is an easy to learn programming language, has excellent tools, works well on distributed computing systems, has great ways to disseminate information (e.g., jupyter notebooks, jupyter-book, etc), and is free! If you are just getting started, I would spend some time working with NiLearn and Brainiak, which have a lot of functionality, are very well tested, are reasonably computationally efficient, and most importantly have lots of documentation and tutorials to get started.

We will be using many packages throughout the course such as PyBids to navigate neuroimaging datasets, fmriprep to perform preprocessing, and nltools, which is a package developed in my lab, to do basic data manipulation and analysis. NLtools is built using many other toolboxes such as nibabel and nilearn, and we will also be using these frequently throughout the course.

### Nipype, the Python tool to unify them all
One of the main challenges for anyone doing neuroimaging data analysis is that different algorithms are implemented in different software libraries. Even if you decide that you would like to use NiPy tools for most of your data analysis, you might still find yourself needing to use non-Python tools for some steps in your analysis. For example, to use novel algorithms that are implemented in the popular FMRIB Software Library (FSL) or Analysis of Functional NeuroImages (AFNI) frameworks for fMRI, the popular MRTRIX library for dMRI, or in FreeSurfer for analysis of structural MRI. In theory, if you wanted to construct an analysis pipeline that glues together operations from different frameworks, you would have to familiarize yourself with the varying ways in which these different frameworks expect their input data to appear and the varying ways in which they produce their output. The complexity can quickly become daunting. Moreover, creating reproducible data analysis programs that put together such pipelines becomes cumbersome and can be very difficult. Fortunately, these challenges have been addressed through the Nipype Python software library. Nipype implements Python interfaces to many neuroimaging software tools (including those we mentioned above). One of Nipype’s appealing features is that it provides a very similar programming interface across these different tools. In addition, it provides the functionality to represent pipelines of operations, where the outputs of one processing step become the inputs to the next processing steps. Running such a pipeline as one program is not only a matter of convenience but also important for reproducibility. By tracking and recording the set of operations that a dataset undergoes through analysis, as well as the parameters that are used in each step, Nipype allows users of the software to report exactly what they did with their data to come to a particular conclusion. In addition, Nipype allows a processing pipeline to be used with other datasets. However, this raises another kind of challenge: to achieve this kind of extensibility, the input data has to be organized in a particular way that the software recognizes. This is where community-developed data standards come in. In the rest of this section, we will discuss the Brain Imaging Data Structure, or BIDS, which is the most commonly-used data standard for organizing neuroimaging data for analysis.

### Reading and writing neuroimaging data
All of the NiPy tools depend to some degree on the ability to read neuroimaging data from commonly used file formats into the memory of the computer. The tool of choice for doing that is called nibabel. The name hints at the plethora of different file formats that exist to represent and store neuroimaging data. Nibabel, which has been in continuous development since 2007, provides a relatively straightforward common route to read many of these formats. Much in the way that Numpy serves as a basis for all of the scientific computing in Python, nibabel serves as the basis for the NiPy ecosystem. Because it is so fundamental, we devote an entire later section (Section 12) to some basic operations that you can do with nibabel. In Section 13, we will go even deeper to see how nibabel enables the integration of different neuroimaging data types. So, we will not say much more about nibabel right now.

### Loading Data with Nibabel
Neuroimaging data is often stored in the format of nifti files .nii which can also be compressed using gzip .nii.gz. These files store both 3D and 4D data and also contain structured metadata in the image header.

There is a very nice tool to access nifti data stored on your file system in python called nibabel. If you don’t already have nibabel installed on your computer it is easy via pip. First, tell the jupyter cell that you would like to access the unix system outside of the notebook and then install nibabel using pip !pip install nibabel. You only need to run this once (unless you would like to update the version).

nibabel objects can be initialized by simply pointing to a nifti file even if it is compressed through gzip. First, we will import the nibabel module as nib (short and sweet so that we don’t have to type so much when using the tool). I’m also including a path to where the data file is located so that I don’t have to constantly type this. It is easy to change this on your own computer.

We will be loading an anatomical image from subject S01 from the localizer dataset. See this paper for more information about this dataset.

The first step in almost any neuroimaging data analysis is reading neuroimaging data from files. We will start dipping our toes into how to do this with the nibabel software library. Many different file formats store neuroimaging data, but the NIfTI format (The acronym stands for Neuroimaging Informatics Technology Initiative, which was the group at the US National Institutes of Health that originally designed the file format) has gained significant traction in recent years. For example, it is the format required by the BIDS standard for storing raw MRI data. Because this file format is so common, we will focus on this format here and we will not go into detail on the other file formats that are supported by nibabel.

Getting acquainted with nibabel and its operations will also allow us to work through some issues that arise when analyzing data from neuroimaging experiments. In the next section (Section 13), we will dive even deeper into the challenge of aligning different measurements to each other. Let’s start by downloading some neuroimaging files and seeing how nibabel works. We’ll use the data downloading functionality implemented in ndslib to get data from the OpenNeuro archive. These two files are part of a study on the effects of learning on brain representations [Beukema et al., 2019]. From this dataset, we will download just one run of a functional MRI experiment and a corresponding T1-weighted image acquired for the same subject in the same session.

### Image processing
Images are used as data in many different contexts. For one, many different research fields use imaging instruments to study a variety of natural phenomena: everything from telescopes that image faraway galaxies, to powerful microscopes that can image individual molecular components of a living cell. But images are also used in commercial applications of data science. For example, in sorting through the photographs that we upload into social media or photo sharing services. Computer vision, another name for some of the advanced applications of image processing, has been used for a long time in things like quality control of printed circuit boards but is also highly used in many newfangled technologies, such as in providing driverless cars with the input they need to decide where to go.

Neuroscience research has also been fascinated with images for almost as long as it has existed as a science. Santiago Ramón y Cajal, a Spanish neuroanatomist who lived around the turn of the 20th century, and who was arguably one of the first modern neuroscientists, conducted a large part of his research by peering at brain tissue through a microscope and making (often strikingly beautiful!) pictures of what he saw (you can see some of them on the Marginalian website. One could argue that we haven’t made much progress, judging from the fact that a lot of contemporary research in neuroscience aims to do something very similar. More optimistically, we could say that the rapid development of imaging instruments and experimental techniques that have happened even just in the last few years has vaulted the field forward to create imaging data that show the activity of hundreds and even thousands of neurons simultaneously, while animals are performing a specific behavior. It’s still images, but they contain much more information than what Cajal had under his microscope. And we have fast computers and modern algorithms to analyze the data with, so maybe there is some progress.

Neuroimaging is of course all about images and the fundamental type of data that most neuroimaging researchers use are images of brains. In this section, we’ll give a broad introduction to image processing that will survey a wide range of different kinds of operations that you can do with images. We’ll focus on the open-source Scikit Image library and the operations that are implemented within this library. One of the advantages of using Scikit Image is that it is built as a domain-agnostic tool. Thus, instead of focusing on one particular application domain, the library exemplifies the interdisciplinary and quantitative nature of image processing by collecting together algorithms that have been developed in many different contexts.

Overall, the purpose of this chapter is to develop an intuition for the kind of things that you might think about when you are doing image processing. In the next sections, we will zoom in and dissect in more detail two kinds of operations: image segmentation and image registration. These are particularly common in the analysis of neuroimaging data and a detailed understanding of these operations should serve you well, even if you ultimately use specialized off-the-shelf software tools for these operations, rather than implementing them yourself.

### Images are arrays
As you saw earlier in this book, data from neuroimaging experiments can be represented as Numpy arrays. That is also true of images in general. So, what is the difference between an image and another kind of array? One thing that distinguishes images from other kinds of data is that spatial relationships are crucially important for the analysis of images. That is because neighboring parts of the image usually represent objects that are near each other in the physical world as well. As we’ll see below, many kinds of image-processing algorithms use these neighborhood relationships. Conversely, in some cases, these neighborhood relationships induce constraints on the operations one can do with the images because we’d like to keep these neighborhood relationships constant even if we put the image through various transformations. This too will come up when we discuss image processing methods that change the content of images.

### Images can have two dimensions or more
We typically think of images as having two dimensions, because when we look at images, we are usually viewing them on a two-dimensional surface: on the screen of a computer or a page. But some kinds of images have more than one dimension. For example, in most cases where we are analyzing brain images, we are interested in the full three-dimensional image of the brain. This means that brain images are usually (at least) three-dimensional. Again, under our definition of an image, this is fine. So long as the spatial relationships are meaningful and important in the analysis, it is fine that they extend over more than two dimensions.


### Image segmentation 

The general scope of image processing and some basic terminology were introduced in Section 14. We will now dive deeper into specific image processing methods in a bit more detail. We are going to look at computational tasks that are in common use in neuroimaging data analysis and we are going to demonstrate some solutions to these problems using relatively simple computations.

The first is image segmentation. Image segmentation divides the pixels or voxels of an image into different groups. For example, you might divide a neuroimaging dataset into parts that contain the brain itself and parts that are non-brain (e.g., background, skull, etc.). Generally speaking, segmenting an image allows us to know where different objects are in an image and allows us to separately analyze parts of the image that contain particular objects of interest. Let’s look at a specific example. We’ll start by loading a neuroimaging dataset that has BOLD fMRI images in it:

First of all, a large part of the image is in the background – the air around the subject’s head. If we are going to do statistical computations on the data in each of the voxels, we would like to avoid looking at these voxels. That would be a waste of time. In addition, there are parts of the image that are not clearly in the background but contain parts of the subject’s head or parts of the brain that we are not interested in. For example, we don’t want to analyze the voxels that contain parts of the subject’s skull and/or skin that appear as bright lines alongside the top of the part of the image that contains the brain. We also don’t want to analyze the voxels that are in the ventricles, appearing here as brighter parts of the image. To be able to select only the voxels that are in the brain proper, we need to segment the image into brain and non-brain. There are a few different approaches to this problem.

Intensity-based segmentation
The first and simplest approach to segmentation is to use the distribution of pixel intensities as a basis for segmentation As you can see, the parts of the image that contain the brain are brighter – have higher intensity values. The parts of the image that contain the background are dark and contain low-intensity values. One way of looking at the intensity values in the image is using a histogram. This code displays a histogram of pixel intensity values. I am using the Matplotlib “hist” function, which expects a one-dimensional array as input, so the input is the “flat” representation of the image array, which unfolds the two-dimensional array into a one-dimensional array.

Otsu’s method
A classic approach to this problem is now known as “Otsu’s method”, after the Japanese engineer Nobuyuki Otsu, who invented it in the 1970s [Otsu, 1979]. The method relies on a straightforward principle: find a threshold that minimizes the variance in pixel intensities within each class of pixels (for example, brain and non-brain). This principle is based on the idea that pixels within each of these segments should be as similar as possible to each other, and as different as possible from the other segment. It also turns out that this is a very effective strategy for many other cases where you would like to separate the background from the foreground (for example, text on a page).

Let’s examine this method in more detail. We are looking for a threshold that would minimize the total variance in pixel intensities within each class, or “intraclass variance”. This has two components: The first is the variance of pixel intensities in the background pixels, weighted by the proportion of the image that is in the background. The other is the variance of pixel intensities in the foreground, weighted by the proportion of pixels belonging to the foreground. To find this threshold value, Otsu’s method relies on the following procedure: Calculate the intraclass variance for every possible value of the threshold and find the candidate threshold that corresponds to the minimal intraclass variance. We will look at an example with some code below, but we will first describe this approach in even more detail with words.

We want to find a threshold corresponding to as small as possible intraclass variance, so we start by initializing our guess of the intraclass variance to the largest possible number: infinity. We are certain that we will find a value of the threshold that will have a smaller intraclass variance than that. Then, we consider each possible pixel value that could be the threshold. In this case, that’s every unique pixel value in the image (which we find using np.unique). As background, we select the pixel values that have values lower than the threshold. As foreground, we select the values that have values equal to or higher than the threshold.

Then, the foreground contribution to the intraclass variance is the variance of the intensities among the foreground pixels (np.var(foreground), multiplied by the number of foreground pixels (len(foreground)). The background contribution to the intraclass variance is the variance of the intensities in the background pixels, multiplied by the number of background pixels (with very similar code for each of these). The intraclass variance is the sum of these two. If this value is smaller than the previously found best intraclass variance, we set this to be the new bests intraclass variance, and replace our previously found threshold with this one. After running through all the candidates, the value stored in the threshold variable will be the value of the candidate that corresponds to the smallest possible intraclass variance.

Edge-based segmentation
Threshold-based segmentation assumes that different parts of the image that should belong to different segments should have different distributions of pixel values. In many cases that is true. But this approach does not take advantage of the spatial layout of the image. Another approach to segmentation uses the fact that parts of the image that should belong to different segments are usually separated by edges. What is an edge? Usually, these are contiguous boundaries between parts of the image that look different from each other. These differences can be differences in intensity, but also differences in texture, pattern, and so on. In a sense, finding edges and segmenting the image are a bit of a chicken and egg: if you knew where different parts of the image were, you wouldn’t have to segment them. Nevertheless, in practice, using algorithms that specifically focus on finding edges in the image can be useful to perform the segmentation. Finding edges in images has been an important part of computer vision for about as long as there has been a field called computer vision. As you saw in chapter Section 14, one part of finding edges could be to construct a filter that emphasizes changes in the intensity of the pixels (such as the Sobel filter that you explored in the exercise in Section 14.4.3.1). Sophisticated edge detection algorithms can use this, together with a few more steps, to more robustly find edges that extend in space. One such algorithm is the Canny edge detector, named after its inventor, John Canny, a computer scientist, and computer vision researcher [Canny, 1986]. The algorithm takes several steps that include smoothing the image to get rid of noisy or small parts, finding the local gradients of the image (for example, with the Sobel filter) and then thresholding this image, selecting edges that are connected to other strong edges and suppressing edges that are connected to weaker edges. We will not implement this algorithm step by step, but instead, use the algorithm as it is implemented in Scikit Image. If you are interested in learning more about the algorithm and would like an extra challenge, we would recommend also reading through the source code of the Scikit Image implementation 2. It’s just a few dozen lines of code, and understanding each step that the code is taking will help you understand this method much better. For now, we will use this as a black box and see whether it helps us with the segmentation problem. We start by running our image through the canny edge detector. This creates an image of the edges, containing a 1 in locations that are considered to be at an edge and 0 in all other locations.




### registration

The last major topic we will cover in this chapter is image registration. Image registration is something we do when we have two images that contain parts that should overlap with each other, but do not. For example, consider what happens when you take two photos of the same person. If your camera moves between the two photos, or the person moves between the two photos, their image will be in a slightly different part of the frame in each of the photos. Or, if you zoom closer between the photos, their face might take up more space in the photo. Other parts of the image that appear in the background might also be displaced. Let’s look at an example of this. We will load two photos taken in close succession. In between the two photos, both the camera and the object of the photos moved. This means that the two images look a little bit different. This is apparent if we display the images side-by-side, but becomes even more apparent when we create a “stereo” image from the two images. This is done by inserting each of the images into different channels in an RGB image.

Affine registration
The first kind of registration that we will talk about corrects for changes between the images that affect all of the content in the image. The fact that the person in the photo is in a different part of the frame, as are details of the background: the fence above and to the right of their shoulder and the path winding to the left of them in the image. In this case, these global changes are mostly affected by the motion of the camera between the two photos. In the case of brain imaging, a global change to the position of the brain is mostly related to the fact that the subject moved between the time in which each of the images was acquired. We will see some examples with brain data further down, but let’s keep going with our photographic example for now.

An affine registration can correct for global differences between images by applying a combination of transformations on the image: translating the entire image up or down, to the left or the right; rotating it clockwise or counter-clockwise, scaling the image (zooming in or out), and shearing the image. While most of these are straightforward to understand, the last one is a bit more complex: image shearing means that different parts of the image move tos different degrees. It is simplest to understand by considering a horizontal shear. In one example of a horizontal shear, the top row of pixels doesn’t move at all, the second row moves by some amount, the third row moves by that amount, and a small amount more, and so on. A larger amount of shear means that as we go down the image subsequent rows of pixels move by more and more.

Diffeomorphic registration
As you saw in the results of the affine registration, this kind of “global” registration approach does well in registering the overall structure of one brain image to another, but it doesn’t necessarily capture differences in small details. Another family of registration algorithms registers different parts of the image separately. In principle, you can imagine that each pixel in the first image could independently move to any location in the second image. But using this unconstrained approach, in which you can move every pixel in one image to any location in the other image, you haven’t registered the images to each other, you’ve replaced them.

Diffeomorphic registration is an approach that balances this flexibility with constraints. In principle, every pixel/voxel in the moving image could be moved to overlap with any pixel/voxel in the static image, but neighboring pixels/voxels are constrained to move by a similar amount. That is, the mapping between the moving and the static image varies smoothly in space. To demonstrate this, we’ll use the DIPY implementation of an algorithm that learns this kind of transformation between two images, the Symmetric Normalization algorithm, or SyN [Avants et al., 2008]. The API for this algorithm is slightly different because you need to explicitly define the metric that the algorithm uses to figure out whether the images are similar enough to each other, as part of the optimization procedure. Here, we are going to use the cross-correlation between the images, using the CCMetric object to define this. This metric also has some other parameters that need to be defined, a smoothing kernel that is applied to the image and the size of a window of pixels over which the metric is calculated.

### Preprocessing

Preprocessing is the term used to for all the steps taken to improve our data and prepare it for statistical analysis. We may correct or adjust our data for a number of things inherent in the experimental situation: to take account of time differences between acquiring each image slice, to correct for head movement during scanning, to detect ‘artifacts’ – anomalous measurements – that should be excluded from subsequent analysis; to align the functional images with the reference structural image, and to normalize the data into a standard space so that data can be compared among several subjects; to apply filtering to the image to increase the signal-to-noise ratio; finally, if sMRI is intended, a segmentation step may be performed. We will now look at each of those steps in more detail.

Being able to study brain activity associated with cognitive processes in humans is an amazing achievement. However, as we have noted throughout this course, there is an extraordinary amount of noise and a very low levels of signal, which makes it difficult to make inferences about the function of the brain using this BOLD imaging. A critical step before we can perform any analyses is to do our best to remove as much of the noise as possible. The series of steps to remove noise comprise our neuroimaging data preprocessing pipeline.

We will cover:

Image transformations

Head motion correction

Spatial Normalization

Spatial Smoothing

There are other preprocessing steps that are also common, but not necessarily performed by all labs such as slice timing and distortion correction. We will not be discussing these in depth outside of the videos.

Image Transformations
Ok, now let’s dive deeper into how we can transform images into different spaces using linear transformations.

Recall from our introduction to neuroimaging data lab, that neuroimaging data is typically stored in a nifti container, which contains a 3D or 4D matrix of the voxel intensities and also an affine matrix, which provides instructions for how to transform the matrix into another space.

Let’s create an interactive plot using ipywidgets so that we can get an intuition for how these affine matrices can be used to transform a 3D image.

We can move the sliders to play with applying rigid body transforms to a 3D cube. A rigid body transformation has 6 parameters: translation in x,y, & z, and rotation around each of these axes. The key thing to remember is that a rigid body transform doesn’t allow the image to be fundamentally changed. A full 12 parameter affine transformation adds an additional 3 parameters each for scaling and shearing, which can change the shape of the cube.

Try moving some of the sliders around. Note that the viewer is a little slow. Each time you move a slider it is applying an affine transformation to the matrix and re-plotting.

Translation moves the cube in x, y, and z dimensions.

We can also rotate the cube around the x, y, and z axes where the origin is the center point. Continuing to rotate around the point will definitely lead to the cube leaving the current field of view, but it will come back if you keep rotating it.

You’ll notice that every time we change the slider and apply a new affine transformation that the cube gets a little distorted with aliasing. Often we need to interpolate the image after applying a transformation to fill in the gaps after applying a transformation. It is important to keep in mind that every time we apply an affine transformation to our images, it is actually not a perfect representation of the original data. Additional steps like reslicing, interpolation, and spatial smoothing can help with this.


#### cost-functions

Now that we have learned how affine transformations can be applied to transform images into different spaces, how can we use this to register one brain image to another image?

The key is to identify a way to quantify how aligned the two images are to each other. Our visual systems are very good at identifying when two images are aligned, however, we need to create an alignment measure. These measures are often called cost functions.

There are many different types of cost functions depending on the types of images that are being aligned. For example, a common cost function is called minimizing the sum of the squared differences and is similar to how regression lines are fit to minimize deviations from the observed data. This measure works best if the images are of the same type and have roughly equivalent signal intensities.

Let’s create another interactive plot and find the optimal X & Y translation parameters that minimize the difference between a two-dimensional target image to a reference image.

Now that we have learned how affine transformations can be applied to transform images into different spaces, how can we use this to register one brain image to another image?

The key is to identify a way to quantify how aligned the two images are to each other. Our visual systems are very good at identifying when two images are aligned, however, we need to create an alignment measure. These measures are often called cost functions.

There are many different types of cost functions depending on the types of images that are being aligned. For example, a common cost function is called minimizing the sum of the squared differences and is similar to how regression lines are fit to minimize deviations from the observed data. This measure works best if the images are of the same type and have roughly equivalent signal intensities.

Let’s create another interactive plot and find the optimal X & Y translation parameters that minimize the difference between a two-dimensional target image to a reference image.



#### Motion Correction (fMRI only)

Now let’s put everything we learned together to understand how we can correct for head motion in functional images that occurred during a scanning session. It is extremely important to make sure that a specific voxel has the same 3D coordinate across all time points to be able to model neural processes. This of course is made difficult by the fact that participants move during a scanning session and also in between runs.

Motion correction, also known as Realignment, is used to correct for head movement during the acquisition of functional data. Even small head movements lead to unwanted variation in voxels and reduce the quality of your data. Motion correction tries to minimize the influence of movement on your data by aligning your data to a reference time volume. This reference time volume is usually the mean image of all timepoints, but it could also be the first, or some other, time point.

Head movement can be characterized by six parameters: Three translation parameters which code movement in the directions of the three dimensional axes, movement along the X, Y, or Z axes; and three rotation parameters which code rotation about those axes, rotation centered on each of the X, Y, and Z axes).


Motion correction tries to correct for smaller movements, but sometimes it’s best to just remove the images acquired during extreme rapid movement. We use Artifact Detection to identify the timepoints/images of the functional image that vary so much they should be excluded from further analysis and to label them so they are excluded from subsequent analyses.

For example, checking the translation and rotation graphs for a session shown above for sudden movement greater than 2 standard deviations from the mean, or for movement greater than 1mm, artifact detection would show that images 16-19, 21, 22 and 169-172 should be excluded from further analysis. The graph produced by artifact detection, with vertical lines corresponding to images with drastic variation is shown below.


#### Slice Timing Correction (fMRI only)
Because functional MRI measurement sequences don’t acquire every slice in a volume at the same time we have to account for the time differences among the slices. For example, if you acquire a volume with 37 slices in ascending order, and each slice is acquired every 50ms, there is a difference of 1.8s between the first and the last slice acquired. You must know the order in which the slices were acquired to be able to apply the proper correction. Slices are typically acquired in one of three methods: descending order (top-down); ascending order (bottom-up); or interleaved (acquire every other slice in each direction), where the interleaving may start at the top or the bottom. (Left: ascending, Right: interleaved)

Slice Timing Correction is used to compensate for the time differences between the slice acquisitions by temporally interpolating the slices so that the resulting volume is close to equivalent to acquiring the whole brain image at a single time point. This temporal factor of acquisition especially has to be accounted for in fMRI models where timing is an important factor (e.g. for event related designs, where the type of stimulus changes from volume to volume).


#### Realignment
Realignment usually uses an affine rigid body transformation to manipulate the data in those six parameters. That is, each image can be moved but not distorted to best align with all the other images. Below you see a plot of a “good” subject where the movement is minimal.


Realignment is the preprocessing step in which a rigid body transformation is applied to each volume to align them to a common space. One typically needs to choose a reference volume, which might be the first, middle, or last volume, or the mean of all volumes.

Let’s look at an example of the translation and rotation parameters after running realignment on our first subject.

Don’t forget that even though we can approximately put each volume into a similar position with realignment that head motion always distorts the magnetic field and can lead to nonlinear changes in signal intensity that will not be addressed by this procedure. In the resting-state literature, where many analyses are based on functional connectivity, head motion can lead to spurious correlations. Some researchers choose to exclude any subject that moved more than certain amount. Other’s choose to remove the impact of these time points in their data through removing the volumes via scrubbing or modeling out the volume with a dummy code in the first level general linear models.

#### Coregistration
Motion correction aligns all the images within a volume so they are ‘aligned’. Coregistration aligns the functional image with the reference structural image. If you think of the functional image as having been printed on tracing paper, coregistration moves that image around on the reference image until the alignment is at its best. In other words, coregistration tries to superimpose the functional image perfectly on the anatomical image. This allows further transformations of the anatomical image, such as normalization, to be directly applied to the functional image.

The following picture shows an example of good (top) and bad (bottom) coregistration of functional images with the corresponding anatomical images. The red lines are the outline of the cortical folds of the anatomical image superimposed on the underlying greyscale functional image.

#### Normalization
Every person’s brain is slightly different from every other’s. Brains differ in size and shape. To compare the images of one person’s brain to another’s, the images must first be translated onto a common shape and size, which is called normalization. Normalization maps data from the individual subject-space it was measured in onto a reference-space. Once this step is completed, a group analysis or comparison among data can be performed. There are different ways to normalize data but it always includes a template and a source image.

The template image is the standard brain in reference-space onto which you want to map your data. This can be a Talairach-, MNI-, or SPM-template, or some other reference image you choose to use.

The source image (normally a higher resolution structural image) is used to calculate the transformation matrix necessary to map the source image onto the template image. This transformation matrix is then used to map the rest of your images (functional and structural) into the reference-space.


There are several other preprocessing steps that involve image registration. The main one is called spatial normalization, in which each subject’s brain data is warped into a common stereotactic space. Talaraich is an older space, that has been subsumed by various standards developed by the Montreal Neurological Institute.

There are a variety of algorithms to warp subject data into stereotactic space. Linear 12 parameter affine transformation have been increasingly been replaced by more complicated nonlinear normalizations that have hundreds to thousands of parameters.

One nonlinear algorithm that has performed very well across comparison studies is diffeomorphic registration, which can also be inverted so that subject space can be transformed into stereotactic space and back to subject space. This is the core of the ANTs algorithm that is implemented in fmriprep. See this overview for more details.

Let’s watch another short video by Martin Lindquist and Tor Wager to learn more about the core preprocessing steps.

#### Spatial Smoothing
The last step we will cover in the preprocessing pipeline is spatial smoothing. This step involves applying a filter to the image, which removes high frequency spatial information. This step is identical to convolving a kernel to a 1-D signal that we covered in the Signal Processing Basics lab, but the kernel here is a 3-D Gaussian kernel. The amount of smoothing is determined by specifying the width of the distribution (i.e., the standard deviation) using the Full Width at Half Maximum (FWHM) parameter.

Why we would want to decrease our image resolution with spatial smoothing after we tried very hard to increase our resolution at the data acquisition stage? This is because this step may help increase the signal to noise ratio by reducing the impact of partial volume effects, residual anatomical differences following normalization, and other aliasing from applying spatial transformation.

Structural as well as functional images are smoothed by applying a filter to the image. Smoothing increases the signal to noise ratio of your data by filtering the highest frequencies from the frequency domain; that is, removing the smallest scale changes among voxels. That helps to make the larger scale changes more apparent. There is some inherent variability in functional location among individuals, and smoothing helps to reduce spatial differences between subjects and therefore aids comparing multiple subjects. The trade-off, of course, is that you lose resolution by smoothing. Keep in mind, though, that smoothing can cause regions that are functionally different to combine with each other. In such cases a surface based analysis with smoothing on the surface might be a better choice.

Smoothing is implemented by applying a 3D Gaussian kernel to the image, and the amount of smoothing is typically determined by its full width at half maximum (FWHM) parameter. As the name implies, FWHM is the width/diameter of the smoothing kernel at half of its height. Each voxel’s value is changed to the result of applying this smoothing kernel to its original value.

Choosing the size of the smoothing kernel also depends on your reason for smoothing. If you want to study a small region, a large kernel might smooth your data too much. The filter shouldn’t generally be larger than the activation you’re trying to detect. Thus, the amount of smoothing that you should use is determined partly by the question you want to answer. Some authors suggest using twice the voxel dimensions as a reasonable starting point.





#### Artifact Detection (fMRI only)
Almost no subjects lie perfectly still. As we can see from the sharp spikes in the graphs below, some move quite drastically. Severe, sudden movement can contaminate your analysis quite severely.




#### Segmentation (sMRI only)
Segmentation is the process by which a brain is divided into neurological sections according to a given template specification. This can be rather general, for example, segmenting the brain into gray matter, white matter and cerebrospinal fluid, as is done with SPM’s Segmentation, or quite detailed, segmenting into specific functional regions and their subregions, as is done with FreeSurfer’s recon-all, and that is illustrated in the figure.

Segmentation can be used for different things. You can use the segmentation to aid the normalization process or use it to aid further analysis by using a specific segmentation as a mask or as the definition of a specific region of interest (ROI).
### References
+ https://dartbrains.org/content/Introduction_to_Neuroimaging_Data.html#
+ https://dartbrains.org/content/Signal_Processing.html
+ https://dartbrains.org/content/Preprocessing.html
+ http://neuroimaging-data-science.org/content/005-nipy/001-nipy.html
+ https://miykael.github.io/nipype-beginner-s-guide/neuroimaging.html
