
## FreeSurfer Overview: 


Virtually all neuroimaging studies acquire a T1-weighted anatomical scan: A high-resolution image with high contrast between the white matter and the gray matter. In these images white matter is lighter, gray matter is darker, and cerebrospinal fluid is black. These are the images to be used by FreeSurfer to partition the cortical surface and the subcortical structures into distinct areas. FreeSurfer is a software package that enables you to analyze structural MRI images. FreeSurfer allows you to quantify the amount of gray matter and white matter in specific regions of the brain and to estimate measurements such as the thickness, curvature, and volume of the different tissue types. In terms of modeling, these measurements can be used covariates or to be compared between groups.

The Martino Center for Biomedical Imaging created FreeSurfer, for the multi-step analysis of anatomical brain images, the software tool provides an automatic reconstruction pipeline. The steps are bias field correction, motion artifact correction, and skull stripping. Gray-white matter segmentation based on a deformable surface template established in MNI305 space is then performed. The subject's cortical surface is nonlinearly registered with the Desikan-Killiany/Destrieux atlas to perform area labeling on the cortical surface, which is the third stage.
FreeSurfer, however, converts the cortex into a 2D surface rather than viewing the brain as a 3D volume. How come a 2D surface? Imagine a voxel that spans the sulcus's two edges. The partial valuing effect refers to the issue where a voxel has a mixture of signals from both regions and it is impossible to tell which region contributed to the signal. Similar issues arise when a voxel comprises two or more distinct tissue types. Imagine a voxel that consists of cerebrospinal fluid, white matter, and gray matter. We are unable to determine how much of each is included in that voxel in this situation. Although each of the several tissue types within the voxel is represented by a single number, it is impossible to determine how much of each tissue type is present in the voxel.

FreeSurfer circumvents this issue, by tracing the borders between the various brain tissues, such as those between the gray and white matter, the gray and pial matter, and so on, and then inflating those surfaces into spheres. Most of the remaining flaws in the inflated surface are automatically repaired. These surfaces can then be depicted as partially, completely, or spherically expanded brains. The brain is like a flaccid balloon. Wrinkles representing the gyri and sulci of the cortex. Now imagine inflating the brain where the wrinkles disappear, and the brain becomes like a fully inflated balloon. This is a different way to view the brain data with vertices and edges as a chain-link fence wrapped around the surface of the cortex, where the links are the edges, and the intersections of the links are the vertices. The vertex is now our smallest resolution element, and at each vertex we can calculate structural measurements such as thickness, volume, and surface area.
After the surface has been rebuilt, you may either deflate the surface to examine where the activation is located on the original, wrinkled cortex or resample your fMRI statistical maps to view them on the inflated surface. You can now see more clearly how the statistical maps are distributed across the hills and valleys of the brain.

FreeSurfer labels the cortical and subcortical structures based on the reconstructed surface and pre-existing knowledge of the topology of a normal human brain. Parcellation and Segmentation are the terms used to describe the labeling of the cortex and subcortical regions, respectively. These labeling are based on the Durieux atlas, which has finer-grained parcellations than the Desikan-Killiany atlas, and the Desikan-Killiany atlas. The average of structural measurements inside each percolation is then calculated. These measurements can be used to compare individuals or to determine individual differences based on factors like sex, IQ, or age.


## Viewing Your Data with [Freeview](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeviewGuide)

There is a data viewer, or a programme that lets you view your data, in every neuroimaging software package.
Data viewers from AFNI, SPM, and FSL all essentially accomplish the same task: the user enters imaging data, typically anatomical or functional images, and is able to see them in three dimensions. The majority of viewers can open NIFTI files containing any form of image data. Freeview, a viewer provided by FreeSurfer, can be started from the Terminal by entering the command freeview. In addition to supporting NIFTI pictures like the other packages, it also supports FreeSurfer-specific file types like.mgz and.inflated data. The Viewing Panel allows you to view the image in all three dimensions, or you can rearrange the arrangement to only show one. 

Both volumes and surfaces can be loaded simultaneously by Freeview. Select an image from the surf directory, such as lh.pial, to load a surface. This will trace the surface's outline in the orthogonal boxes and overlay a three-dimensional representation of the surface in the View window's three-dimensional box (i.e., the sagittal, axial, and coronal views). By choosing a new Edge colour, the surface's colour in the orthogonal views can be altered. 

## FreeSurfer [Group Analysis](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/GroupAnalysisV6.0)

We have already gone over the fundamental FreeSurfer commands: freeview and recon-all. Recon-all measures the thickness and volume of grey matter in various brain regions by generating a variety of volumes and surfaces from a T1-weighted anatomical picture. Regions in the cortex are referred to as parcellations, while those in the subcortex are known as segmentations. For instance, the Desikan-Killiany atlas defines the left superior frontal gyrus as a parcellation, and structural metrics are computed in this region for each participant. The subcortical regions of the right amygdala, on the other hand, are segmented and only assess grey matter volume, not thickness, as they are not surface inflated.

You might be considering how to compare structural measurements between groups and how to depict those variations on the surface of the brain at this stage. The method is comparable to fMRI analysis: We compare vertices in FreeSurfer in the same way that we compare voxels in fMRI. We can determine variations in grey matter thickness at a certain vertex and determine whether they are statistically significant if the vertices are in a shared region, such as MNI. This produces statistical maps that we may overlay as a surface map on a model brain.

We will extract the group labels we are interested in and structure them in a way that FreeSurfer can understand to build a FreeSurfer Group Descriptor (FSGD) file. The covariates that we want to contrast will both be present in the FSGD file, and a second contrast file will specify which covariates to contrast and what weights to give them.


To keep our files organized, copy the participants.tsv file into the FSGD directory. In the first column, type the following lines (header lines--since they are needed at the top, or head, of the document and indicate the format of the FSGD file) as follows: 

+ The first line, GroupDescriptorFile 1, indicates that the file is in FSGD format; you will need this first line in any FSGD file that you create. 
+ The second line, Title , will append the string “StudyTitle” to the directories which store the results of your analyses. 
+ Next two lines, Class A and Class B, indicate that the subject name next to each group. 
+ Next step is to create a contrast file that specifies the contrast weights for each regressor in our model. 
+ The “Class” variables that we specified in the FSGD file are group regressors.

It is noteworthy that, whenever we do any kind of group analysis - comparing groups, region of interest analysis, and so on - each subject’s data must have the same dimensions and voxel resolution. Forgetting to resample usually leads to errors during this step. (All of this applies to fMRI analysis as well.)

Now that all of the subjects are concatenated into a single dataset, we can fit a general linear model with FreeSurfer’s mri_glmfit command. 

+ The concatenated dataset containing all of the subjects’ structural maps (--y);
+ The FSGD file (--fsgd);
+ A list of contrasts (each contrast specified by a different line containing --C);
+ The hemisphere of the template to analyze (--surf);
+ A mask to restrict our analysis only to the cortex (--cortex);
+ An output label for the directory containing the results (--glmdir).
+ As above, we will use nested for loops to analyze the hemispheres, smoothing kernels, and structural measurements of our choosing; 

## FreeSurfer [Region of Interest Analysis](https://surfer.nmr.mgh.harvard.edu/fswiki/FsTutorial/AnatomicalROI)


Groups of voxels known as regions of interest (ROIs) correspond to certain anatomical substrates. The x, y, and z coordinates of the origin should be specified for a ROI before a sphere is constructed around it. Tools like AFNI's 3dUndump, SPM's Marsbar toolbox, and FSL's fslmaths can be used for this. Accordingly, FreeSurfer parcellates and segments the brain, with the parcellations delineating physically separate parts of the cortex and the segmentations separating the sub-cortical nuclei into different structures. These parcellations were made using the Destrieux atlas and the Desikan-Killiany atlas, two atlases that come with FreeSurfer.

There is a table that corresponds to the parcellations for each atlas in the statistics directory for each subject. For instance, the findings for the parcellation of the left hemisphere can be found in the files lh.aparc.annot and lh.aparc.a2009s.annot for the Desikan-Killiany and Destrieux atlases, respectively. The Destrieux atlas contains more parcellations, which can be utilised for finer-grained studies, which is the fundamental distinction between the two. On the other hand, the segmentations are contained in a single file called aseg.stats. For each atlas, there are no unique segmentation files.

It is possible to extracte ROI data with asegstats2table and aparcstats2table commands. Both these commands require a list of subjects and the structural measurement you wish to extract from the table.

A typical command includes following flags

+ --subjects option specifies a list of subject names;
+ --common-segs signalizes to output segmentations common to all of the subjects;
+ --meas indicates which structural measurement to extract from the table (“volume” is the default; alternatives are “mean” and “std”);
+ --stats points to the stats file that the segmentation data will be extracted from;
+ --table writes the extracted measurement to a text file, organized by subject name;
+ --tablefile label for the output file is specified with the  option;

The output from these commands are tab-delimited text files that can be read into a spreadsheet like Excel, or a statistical software program such as R. 


## [FreeSurfer and Python](https://academic.oup.com/gigascience/article/5/suppl_1/s13742-016-0147-0-o/2965220?login=false) 

In order to interact with the recon-all workflow and duplicate the exact same commands used in the FreeSurfer's script, interfaces were established in the Nipype package. Then, in order to confirm that Nipype is equivalent to FreeSurfer recon-all, the workflows were put to the test. The same set of MRI images were run through both workflows on different operating systems (CentOS 6.4 and Mac OS X), in a high-performance computing environment. Both the output image files and the output surface files were converted to the NIFTI file format. The results from the Nipype recon-all workflow and the photos and surfaces produced by FreeSurfer's recon-all workflow were compared. 

## [FreeSurfer and R](https://web.archive.org/web/20200228181635id_/https://f1000researchdata.s3.amazonaws.com/manuscripts/15624/d5fd45a2-e2a4-42ce-8bea-4503cbb00ec4_14361_-_john_muschelli.pdf?doi=10.12688/f1000research.14361.1&numberOfBrowsableCollections=20&numberOfBrowsableInstitutionalCollections=5&numberOfBrowsableGateways=22)

The implementation of images in the Neuroimaging Informatics Technology Initiative (NIfTI) format by the oro.nifti14 package is a prerequisite for the freesurfer package. The R freesurfer functions that call Freesurfer routines that need an image will accept a file name or a nifti object as input. The nifti will be transformed by the R code into the appropriate input needed by Freesurfer. The user's perspective is that R handles all of the input and output. This method has the benefit of allowing users to read in an image, manipulate the nifti object using ordinary array syntax, and then give this object to the freesurfer R function. Users can handle objects using R functionality while effortlessly delivering those objects to Freesurfer using Freesurfer.Other Freesurfer functions, such those requiring the Medical Imaging NetCDF (MINC) format for imaging, call for imaging formats other than NIfTI. Functions to convert between MINC and NIfTI formats are included in the Freesurfer installation and are implemented in R functions like nii2mnc and mnc2nii. Additionally, the mri convert Freesurfer function has been interfaced in freesurfer (same function name), giving R users access to a tool for more general conversion of imaging types than is currently provided by native R. Thus, using the readNIfTI function from oro.nifti, a variety of formats can be translated to NIfTI and then read into R.

# References

+ [FreeSurferWiki](https://surfer.nmr.mgh.harvard.edu/fswiki/FreeSurferWiki)

+ [Nipype](https://nipype.readthedocs.io/en/latest/)

+ [FreeSurfer package R](https://www.rdocumentation.org/packages/freesurfer/versions/1.6.8)
