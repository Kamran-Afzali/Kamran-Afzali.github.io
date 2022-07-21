
FSL (the FMRIB Software Library) is a comprehensive library of analysis tools for functional, structural and diffusion MRI brain imaging data, written mainly by members of the Analysis Group, FMRIB, Oxford. For this NeuroImage special issue on “20 years of fMRI” we have been asked to write about the history, developments and current status of FSL. We also include some descriptions of parts of FSL that are not well covered in the existing literature. We hope that some of this content might be of interest to users of FSL, and also maybe to new research groups considering creating, releasing and supporting new software packages for brain image analysis.






We present the package fslr, a set of R functions that interface with FSL (FMRIB Software Library), a commonly-used open-source software package for processing and analyzing neuroimaging data. The fslr package performs operations on ‘nifti’ image objects in R using command-line functions from FSL, and returns R objects back to the user. fslr allows users to develop image processing and analysis pipelines based on FSL functionality while interfacing with the functionality provided by R. We present an example of the analysis of structural magnetic resonance images, which demonstrates how R users can leverage the functionality of FSL without switching to shell commands.


# References

[FSL](https://www.youtube.com/watch?v=3ExL6J4BIeo&list=PLvgasosJnUVl_bt8VbERUyCLU93OG31h_)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[FSL](https://fsl.fmrib.ox.ac.uk/fslcourse/lectures/intro.pdf)

[FSL](https://open.win.ox.ac.uk/pages/fslcourse/website/online_materials.html)

[fslr: Connecting the FSL Software with R](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4911193/pdf/nihms-792376.pdf)

[FSL Paper](https://pdf.sciencedirectassets.com/272508/1-s2.0-S1053811912X00119/1-s2.0-S1053811911010603/main.pdf?X-Amz-Security-Token=IQoJb3JpZ2luX2VjEP7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIBZ7MKEXrri7SO%2FUC6a0OI1hQwmQXJ%2Fmn%2FmmJRcvkPzKAiEArbyUN7rgneoNXFX4fWxSlX1xXxEVw0RKEqw7YpZyjo8q0gQIRxAFGgwwNTkwMDM1NDY4NjUiDCAr2sAbUILLxNGqliqvBE%2BFWp07BWc9nwT0hV%2FYTyUTE0nmqEobsB6QURk7pWojxHnWxSsOrvnk%2FMHoNt69X75pfmAuIDzjhz6yRBt%2F8yh6VLbPc8QqbAUvzy5VTOcxDAh0x5B2%2FW6CMyhLK9B12aqOqK%2BnAwf6TEQDHKM%2FMnJofOwJIyTy5RJ6%2FWuwkmgZqtsm%2FD7T6iwG5G0DjfvucfgWziJxXki87TIamX5bW7f%2FYgLfYlaBspEuIB1sOQXaoBaQ0xlCA1thOXmZOlRVGJ2KdiPuZbOm9UB8lU29YRp3DUQre%2Fm3%2FnzRedoCxS9bKaAylMrO0buVsUn1kKB7Rma2LRvLnXBU4pkrvnj%2BdUaaZKC3ZOQm9wxSH6I1ZTSuilR0k27NVAYFTn%2FHpDWu%2FReoR7qduCJ7Lp8IdDNxnlypboUgNKLKZFMytwmtIig6PrDx06P0hzFyTx5JrD4V0WmiFHC6kSqyguqaEcAAvLBv6kznOg3f8Jgfqxk%2B3H6rPzRzE8YPMV3BuOT0%2FW74gLgM1S8%2FXq380IXxDdoJk5VafR62AUNIet4pB2Eb7%2B3ze8HlZEApJmwXR6D7eCdeZmOHot97T2J18bcnnni60g0XMBb%2FlPk3jkvYQDyz9kCcg7B56BZuGvj0t70%2Fnikq%2B0sb4avSd6YeHpxXWcL7rT3AHNRL62kpD%2Bx2ziMLGDu2NiS7VVkmTLOGHwxQnDy5eUfsFiY2%2FMxB97P6vcQ20hrfDW1RUe3XxbqmUQNlT6cwganllgY6qQEmwdZS8wKKOO0xX%2FBPlxcmU39utUibQui2X3v1jGxAMfwWNNgJLlH0vX%2FpVZTqIh8e4WuQ6DffRjq3sh5L6pJgXKwW2Rl5JdbD1msyclywL5a0J4jx68SJ9zZa74Y0xnJUrKJ0STPl3%2FiGUSNYFYEW7HnsaJuPdiyjzkYtEFSMc%2FKEUM4WbFFUBSuMrh%2BRGRbZq9aE8CL%2BT2C53uN3CZ5J1P17Tg2vk86L&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20220721T142033Z&X-Amz-SignedHeaders=host&X-Amz-Expires=300&X-Amz-Credential=ASIAQ3PHCVTYTWSMZFGV%2F20220721%2Fus-east-1%2Fs3%2Faws4_request&X-Amz-Signature=1248d4ea5c26f6ea0457a0f0aa782b504e2a6d72591aa9623c1ed06f1be78ac7&hash=620a8e745bfba1abd2228f71614971ea12d9fd6e8fac5827322880a09e2498ed&host=68042c943591013ac2b2430a89b270f6af2c76d8dfd086a07176afe7c76c2c61&pii=S1053811911010603&tid=spdf-d9ee94e5-ee74-491d-b31b-1dfa79035d78&sid=c834f2a814e09140b719d9992d1e58347199gxrqa&type=client&ua=4d5c02565c50005b0c02&rr=72e493f4ca8e4bd0)
