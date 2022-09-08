
## FreeSurfer Overview: 


Virtually all neuroimaging studies acquire a T1-weighted anatomical scan: A high-resolution image with high contrast between the white matter and the grey matter. In these images white matter is lighter, grey matter is darker, and cerebrospinal fluid is black. These are the images that will be used by FreeSurfer to partition the cortical surface and the subcortical structures into distinct areas. FreeSurfer is a software package that enables you to analyze structural MRI images. FreeSurfer allows you to quantify the amount of grey matter and white matter in specific regions of the brain and to estiamte measurements such as the thickness, curvature, and volume of the different tissue types. In terms of modelling, these measurements can be used covariates or to be compared between groups.


The Martino Center for Biomedical Imaging created FreeSurfer. For the multi-step analysis of anatomical brain images, the software tool provides an automatic reconstruction pipeline. The steps are bias field correction, motion artefact correction, and skull stripping. Gray-white matter segmentation based on a deformable surface template established in MNI305 space is then performed. The subject's cortical surface is nonlinearly registered with the Desikan-Killiany/Destrieux atlas to perform area labelling on the cortical surface, which is the third stage.

FreeSurfer, however, converts the cortex into a 2D surface rather than viewing the brain as a 3D volume. How come a 2D surface? Imagine a voxel that spans the sulcus's two edges. The partial voluming effect refers to the issue where a voxel has a mixture of signals from both regions and it is impossible to tell which region contributed to the signal. Similar issues arise when a voxel comprises two or more distinct tissue types. Imagine a voxel that consists of cerebrospinal fluid, white matter, and grey matter. We are unable to determine how much of each is included in that voxel in this situation. Although each of the several tissue types within the voxel is represented by a single number, it is impossible to determine how much of each tissue type is present in the voxel.

FreeSurfer circumvents this issue, by tracing the borders between the various brain tissues, such as those between the grey and white matter, the grey and pial matter, and so on, and then inflating those surfaces into spheres. The majority of the remaining flaws in the inflated surface are automatically repaired (although some defects need to be fixed manually). These surfaces can then be depicted as partially, completely, or spherically expanded brains.

The brain is like a flaccid balloon. Wrinkles representing the gyri and sulci of the cortex. Now imagin inflating the brain where the wrinkles disappear and the brain becomes like a fully inflated balloon. This is a different way to view the brain data with vertices and edges as a chain link fence wrapped around the surface of the cortex, where the links are the edges and the intersections of the links are the vertices. The vertex is now our smallest resolution element, and at each vertex we can calculate structural measurements such as thickness, volume, and surface area.


After the surface has been rebuilt, you may either deflate the surface to examine where the activation is located on the original, wrinkled cortex or resample your fMRI statistical maps to view them on the inflated surface. You can now see more clearly how the statistical maps are distributed across the hills and valleys of the brain. 

FreeSurfer labels the cortical and subcortical structures based on the reconstructed surface and preexisting knowledge of the topology of a normal human brain. Parcellation and Segmentation are the terms used to describe the labelling of the cortex and subcortical regions, respectively. These labelings are based on the Destrieux atlas, which has finer-grained parcellations than the Desikan-Killiany atlas, and the Desikan-Killiany atlas. The average of structural measurements inside each parcellation is then calculated. These measurements can be used to compare individuals or to determine individual differences based on factors like sex, IQ, or age.


## Reconstructing the Cortical Surface and subcortical volumes with [Recon-all](https://surfer.nmr.mgh.harvard.edu/fswiki/recon-all)

The Freesurfer pipeline and analytic procedure for neuroanatomical images is intended to function based on T1-weighted structural MRI of the brain. The Freesurfer recon-all function, where "recon" stands for reconstruction, implements the entire pipeline. The recon-all function conducts around 30 different processes when the -all flag is used, and it takes 20 to 40 hours to process a subject completely. The recon all freesurfer function implements the suggested procedure for fully processing a T1-weighted image in Freesurfer. Users must enter a T1-weighted image, the output directory, and the subject identifier in the recon all function. The outcomes will be recorded in the relevant subject directory.


There are several processes where users can change specific processing steps if there are problems with the results. Once these steps have been rectified, the pipeline can continue to operate. The entire pipeline is divided into three distinct sets of stages known as autorecon1, autorecon2, and autorecon3, which are associated with the same-named flags in recon-all that are used to start these procedures. In order to allow users to conduct certain pipeline steps or continue a failed operation following data rectification, we created wrapper functions called autorecon1, autorecon2, and autorecon3.

FreeSurfer contains a large suite of programs which can take several hours to process a single subject, and days to process an entire dataset. Fortunately, the processing itself is very simple to do - FreeSurfer has a single command that, when executed, does virtually all of the most tedious parts of preprocessing a single subject. This command, recon-all, is easy to use and requires only a few arguments in order to run. Later on, you will learn how to execute multiple recon-all commands simultaneously, which will save you a considerable amount of time.

Recon-all stands for reconstruction, as in reconstructing a two-dimensional cortical surface from a three-dimensional volume. The images we collect from an MRI scanner are three-dimensional blocks, and these images are transformed by recon-all into a smooth, continuous, two-dimensional surface - similar to taking a paper lunch bag crumpled into the size of a pellet, and then blowing into it to expand it like a balloon.

The Output of Recon-all

Before discussing how to use the recon-all command, it is informative to see examples of what it creates. Recon-all first strips the skull from the anatomical image to generate a dataset called brainmask.mgz. (The .mgz extension stands for a compressed, or zipped, Massachusetts General Hospital file; it is an extension specific to FreeSurfer, similar to AFNI’s BRIK/HEAD extension.) Any files that are output as three-dimensional volumes are stored in a folder called mri. Recon-all then estimates where the interface is between the white matter and grey matter for both hemispheres, and these surface estimates are stored in files called lh.orig and rh.orig.

This initial estimate is refined and then saved into files called lh.white and rh.white. This boundary is then used as a base from which recon-all extends feelers to search for the edge of the grey matter. Once this edge is reached, a third pair of datasets are created: lh.pial and rh.pial. These datasets represent the pial surface, which is like a plastic film wrapped around the edge of the grey matter.



One of the advantages of using these surfaces is the ability to depict within the sulci measurements such as cortical thickness differences or the BOLD signal. In a three-dimensional volume, it is possible for a single voxel to span two separate ridges of grey matter, which makes it impossible to determine which part of the cortex generates the observed signal. To more easily see where the activation maps lie along the banks of the sulci and the ridges of the gyri, the surface datasets can be further expanded to create the datasets lh.inflated and rh.inflated.


These inflated surfaces can be inflated yet again, this time into a sphere. This is not an image that you would use to visualize your results; it is an image that is instead normalized to a template image called fsaverage, an average of 40 subjects, and then re-shaped into an inflated surface or a pial surface. Once the individual subject’s surface map is normalized to this template, an atlas can be used to parcellate the cortex into anatomically distinct regions. Recon-all will parcellate the individual subject’s brain according to two atlases: The Desikan-Killiany atlas, and the Destrieux atlas. The Destrieux atlas contains more parcellations; which one you use for your analysis will depend on how fine-grained an analysis you wish to perform.


As you will soon find out, FreeSurfer takes a long time to process an individual subject - around sixteen to twenty-four hours on a typical iMac, with some variation due to factors such as the quality of the input data. For many researchers, this can be a prohibitively long time to wait, especially if the study contains dozens or hundreds of subjects.

One way to reduce the amount of time it takes to analyze so many subjects is to run the analyses in parallel. Modern computers typically have a central processing unit with several cores, which can be individually used for different tasks. To illustrate what cores are, picture eight men and eight kitchens, with each kitchen only big enough for one man to prepare his meal. In this analogy, each computer core is a kitchen. Eight men cannot fit into one kitchen, but if the other kitchens are unlocked and made available for use, each man can make his own meal in each room.

Let’s assume that each meal takes one hour to make. Instead of each man waiting his turn for the same kitchen every hour, everybody makes their meals simultaneously. What would otherwise take eight hours - that is, for all of the men to make their meal in the same kitchen - now takes one hour. If we could do something similar with our data analysis, we could finish processing the anatomical images in a more reasonable amount of time.

## Viewing Your Data with [Freeview](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeviewGuide)

Each neuroimaging software package has a data viewer, or an application that allows you to look at your data. AFNI, SPM, and FSL all have data viewers which basically do the same thing: the user loads imaging data, usually anatomical or functional images, and can view them in three dimensions. Most viewers are able to load NIFTI files that contains any kind of imaging data.

FreeSurfer has its own viewer called Freeview, which can by launched from the Terminal by typing freeview and pressing enter. It can load NIFTI images just like the other packages, and in addition it can load FreeSurfer-specific formats, such as data with .mgz and .inflated extensions. The image can be viewed in all three dimensions in the Viewing Panel, or you can change the layout so that only one viewing dimension is displayed.

Freeview can load both volumes and surfaces at the same time. To load a surface, click File -> Load Surface, and select an image in the surf directory, such as lh.pial. This will overlay a 3D representation of the surface in the three-dimensional box of the View window, and will trace the outline of the surface in the orthogonal boxes (i.e., the sagittal, axial, and coronal views). The color of the surface in the orthogonal views can be changed by selecting a new Edge color.

## FreeSurfer [Group Analysis](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/GroupAnalysisV6.0)

So far we have reviewed the basic commands of FreeSurfer: recon-all and freeview. Recon-all creates a series of volumes and surfaces from a T1-weighted anatomical image, and quantifies the amount of grey matter thickness and volume in different regions of the brain. The cortical regions are called parcellations, and the sub-cortical regions are called segmentations. For example, the left superior frontal gyrus is a parcellation delineated by the Desikan-Killiany atlas, and structural measurements are calculated in that region for each subject. The right amygdala, on the other hand, is a segmentation; because the sub-cortical regions are not inflated into a surface, they only contain measurements of grey matter volume, not thickness.

At this point, you may be thinking about how to compare structural measurements between groups and how to represent those differences on the surface of the brain. The procedure is similar to fMRI analysis: Just as we compare voxels in fMRI, we compare vertices in FreeSurfer. If the vertices are in a common space such as MNI, we can calculate differences in grey matter thickness at a particular vertex and test whether that difference is significant. This generates statistical maps that we can overlay on a template brain as a surface map.


The Cannabis dataset comes with a file called participants.tsv that contains labels and covariates for each subject: Group, gender, age, onset of cannabis use, and so on. To create a FreeSurfer Group Descriptor (FSGD) file, we will extract those covariates or group labels that we are interested in and format them in a way that FreeSurfer understands. The FSGD file will both contain the covariates that we want to contrast, and a separate contrast file will indicate which covariates to contrast and which weights to assign to them.


To keep our files organized, copy the participants.tsv file into the FSGD directory, and rename it CannabisStudy.tsv:

Now, open the file CannabisStudy.tsv in Excel. We will reformat it into an FSGD file, which is organized in such a way that can be understood by the group analysis commands we will run later. In the first column, type the following four lines:

These lines are called header lines, since they are needed at the top, or head, of the document and indicate the format of the FSGD file. The first line, GroupDescriptorFile 1, indicates that the file is in FSGD format; you will need this first line in any FSGD file that you create. The second line, Title CannabisStudy, will prepend the string “CannabisStudy” to the directories which store the results of your analyses. The next two lines, Class HC and Class CB, indicate that the subject name next to a column containing the string HC belongs to the HC group, and that the subject name next to a column containing the string CB belongs to the CB group. For example, after our header lines, we may see something like this:

Our next step is to create a contrast file that specifies the contrast weights for each regressor in our model. The “Class” variables that we specified in the FSGD file are group regressors: One for the Cannabis group, and one for the Control group. Since we have only two regressors, we only need to specify two contrast weights.


The previous tutorials have focused on preparing the data for a group analysis: First, the data was preprocessed using recon-all, with different structural measurements calculated at each vertex; and second, we created an FSGD file and a contrast file indicating which groups we want to compare against each other.

If you recall from a previous tutorial, I recommended using the qcache option when running recon-all. This will generate thickness, volume, and curvature maps at several different smoothing sizes, such as 0mm, 10mm, and 25mm full-width half-maximum kernels. One of the benefits of surface-based analysis is that you can use much larger smoothing kernels than you can in volumetric-based analyses, because there is no risk of smoothing across gyri. When you run the group analysis you can choose among any of the following smoothing sizes.

In order to run a group analysis, we will need to combine all of our individual structural maps into a single dataset. This is similar to the idea of combining consecutive volumes of an fMRI run into a one dataset - as though the volumes are daisy-chained together and laid end to end. (Or, to think of it another way, the structural images are stacked on top of each other, like pancakes; or layered like nachos. Use whatever food analogy is most helpful to remember this important point.)

The data are also resampled to the fsaverage template, which is in MNI space. Whenever we do any kind of group analysis - comparing groups, region of interest analysis, and so on - each subject’s data must have the same dimensions and voxel resolution. Forgetting to resample usually leads to errors during this step. (All of this applies to fMRI analysis as well.)


Now that all of the subjects are concatenated into a single dataset, we can fit a general linear model with FreeSurfer’s mri_glmfit command. In this example we will use the following inputs:

The concatenated dataset containing all of the subjects’ structural maps (--y);
The FSGD file (--fsgd);
A list of contrasts (each contrast specified by a different line containing --C);
The hemisphere of the template to analyze (--surf);
A mask to restrict our analysis only to the cortex (--cortex);
An output label for the directory containing the results (--glmdir).
As above, we will use nested for loops to analyze the hemispheres, smoothing kernels, and structural measurements of our choosing. In this example we will analyze both the left and right hemispheres at a smoothing kernel of 10mm, and we will analyze the strucutral maps of volume and thickness:


## FreeSurfer [Region of Interest Analysis](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI)


Regions of interest (ROIs) are groups of voxels that parameter estimates (or other data) are extracted from. With volumetric data, you specify the x-, y-, and z-coordinates of the origin for your ROI, and then build a sphere around it. (Spheres aren't the only method, but they are common.) You can do this with, for example: AFNI's 3dUndump; SPM's Marsbar toolbox; FSL's fslmaths.


In addition to creating a cortical surface and calculating structural measurements at each vertex, FreeSurfer parcellates and segments the brain - the parcellations outlining anatomically distinct regions of the cortex, and the segmentations dividing the sub-cortical nuclei into distinct structures. These parcellations are created along the lines of two atlases that come with FreeSurfer: The Destrieux atlas, and the Desikan-Killiany atlas.

Within each subject’s stats directory, there is a table corresponding to the parcellations for each atlas. For example, the results for the parcellation of the left hemisphere are located in the file lh.aparc.annot for the Desikan-Killiany atlas, and in the file lh.aparc.a2009s.annot for the Destrieux atlas. The main difference between the two is that the Destrieux atlas contains more parcellations which can be used for finer-grained analyses.

The segmentations, on the other hand, are contained within one file called aseg.stats. There are no separate segmentation files for each atlas.

Extracting data with asegstats2table and aparcstats2table

Both the command asegstats2table and aparcstats2table require a list of subjects and the structural measurement you wish to extract from the table.

Let’s begin with asegstats2table. A typical command would look like this:

The --subjects option specifies a list of subject names;
--common-segs signalizes to output segmentations common to all of the subjects - in other words, if one subject’s number of segmentations is different from the others, do not exit the command with errors;
--meas indicates which structural measurement to extract from the table (“volume” is the default; alternatives are “mean” and “std”);
--stats points to the stats file that the segmentation data will be extracted from; and
--table writes the extracted measurement to a text file, organized by subject name.
The command aparcstats2table requires similar arguments. Here is a typical command:

In this command you can specify the hemisphere to analyze (--hemi), the measurement to extract (--meas, with the options of “thickness”, “volume”, “area”, and “meancurv”), and which atlas to use for parcellation (--parc; you can specify either “aparc”, the Desikan-Killinay atlas, or “aparc.a2009s”, the Destrieux atlas). The label for the output file is specified with the --tablefile option. Include as many subjects as you like in your analysis.

The output from these commands are tab-delimited text files that can be read into a spreadsheet like Excel, or a statistical software program such as R. You would perform the statistical tests just like you would any other t-test: Select the structural measurements from the groups you wish to compare, and then contrast the two groups against each other.


## [FreeSurfer and Python](https://academic.oup.com/gigascience/article/5/suppl_1/s13742-016-0147-0-o/2965220?login=false) 

Nipype interfaces were created for the tools used in the recon-all workflow. These interfaces allow developers to recreate in a Nipype workflow the exact same commands used in the FreeSurfer's tcsh script. The Nipype version of the recon-all workflow was then created by using the Nipype interfaces to connect the FreeSurfer commands in the order necessary. To verify that the new Nipype workflow is equivalent to FreeSurfer's recon-all workflow, both workflows were run on the same set of MRI images on multiple platforms (CentOS 6.4 and Mac OS X) and in a high-performance computing environment. Output surface files were converted to VTK file format, and the output image files were converted to NIFTI file format. The images and surfaces output from FreeSurfer's recon-all workflow were compared to the outputs from Nipype recon-all workflow.





## [FreeSurfer and R](https://web.archive.org/web/20200228181635id_/https://f1000researchdata.s3.amazonaws.com/manuscripts/15624/d5fd45a2-e2a4-42ce-8bea-4503cbb00ec4_14361_-_john_muschelli.pdf?doi=10.12688/f1000research.14361.1&numberOfBrowsableCollections=20&numberOfBrowsableInstitutionalCollections=5&numberOfBrowsableGateways=22)

The freesurfer package relies on the oro.nifti14 package implementation of images (referred to as nifti objects) that are in the Neuroimaging Informatics Technology Initiative (NIfTI) format. For Freesurfer functions that require an image, the R freesurfer functions that call those Freesurfer functions will take in a file name or a nifti object. The R code will convert the nifti to the corresponding input required for Freesurfer. From the user’s perspective, the input/output process is all within R, with one object format (nifti). The advantage of this approach is that the user can read in an image, do manipulations of the nifti object using standard syntax for arrays, and pass this object into the freesurfer R function. Thus, users can use R functionality to manipulate objects while seamlessly passing these object to Freesurfer through freesurfer.
Other Freesurfer functions require imaging formats other than NIfTI, such as the Medical Imaging NetCDF (MINC) format. The Freesurfer installation provides functions to convert from MINC to NIfTI formats and these are implemented in functions such as nii2mnc and mnc2nii in R. Moreover, the mri_convert Freesurfer function has been interfaced in freesurfer (same function name), which allows for a more general conversion tool of imaging types for R users than currently implemented in native R. Thus, many formats can be converted to NIfTI and then read into R using the readNIfTI function from oro.nifti.


# References

+ [FreeSurferWiki](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferWiki)

+ [Nipype](https://nipype.readthedocs.io/en/latest/)

+ [FreeSurfer package R](https://www.rdocumentation.org/packages/freesurfer/versions/1.6.8)
