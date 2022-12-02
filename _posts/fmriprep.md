Preprocessing of functional magnetic resonance imaging (fMRI) involves numerous steps to clean and standardize the data before statistical analysis. Generally, researchers create ad hoc preprocessing workflows for each dataset, building upon a large inventory of available tools. The complexity of these workflows has snowballed with rapid advances in acquisition and processing. We introduce fMRIPrep, an analysis-agnostic tool that addresses the challenge of robust and reproducible preprocessing for fMRI data. fMRIPrep automatically adapts a best-in-breed workflow to the idiosyncrasies of virtually any dataset, ensuring high-quality preprocessing without manual intervention. By introducing visual assessment checkpoints into an iterative integration framework for software testing, we show that fMRIPrep robustly produces high-quality results on a diverse fMRI data collection. Additionally, fMRIPrep introduces less uncontrolled spatial smoothness than observed with commonly used preprocessing tools. fMRIPrep equips neuroscientists with an easy-to-use and transparent preprocessing workflow, which can help ensure the validity of inference and the interpretability of results.

The fMRIPrep workflow takes as principal input the path of the dataset that is to be processed. The input dataset is required to be in valid BIDS format, and it must include at least one T1w structural image and (unless disabled with a flag) a BOLD series. We highly recommend that you validate your dataset with the free, online BIDS Validator.

The exact command to run fMRIPRep depends on the Installation method. The common parts of the command follow the BIDS-Apps definition. 

## References

https://fmriprep.org/en/stable/usage.html
https://github.com/poldracklab/ds003-post-fMRIPrep-analysis
https://github.com/nipreps/fmriprep
