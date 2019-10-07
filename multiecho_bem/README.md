# Multiecho BEM
Project for running "FLASH" sequence BEM for creating forward models in MNE similar to https://martinos.org/mne/stable/manual/c_reference.html#mne-flash-bem but tweaked to work with the GE scanner at MR-centrum at Karolinska Institutet.

## Pipeline
**Warning**: The pipeline is designed to run within the NatMEG infrastructure (www.natmeg.se). I cannot gurrantee that it will work elsewere and will have to be adjust to work elsewhere. But feel free to make changes if you want.

1. Run normal Freesurfer pipeline (*recon-all* etc., use e.g. the *NatMEG_recon* wrapper in *mri_stuff* if using within the NatMEG infrastructure)
2. Copy/paste the script *make_MEBEM_template.py* to relevant project and change paths and subject names.
3. Run.
4. Use BEM surfaces in MNE-PY as normal (e.g. as demonstrated in this tutorial: https://mne.tools/stable/auto_tutorials/source-modeling/plot_forward.html#sphx-glr-auto-tutorials-source-modeling-plot-forward-py)

## Content
The Python script *make_MEBEM_template.py* is a wrapper for running a pipeline that will take multiecho DICOM files and return them in the appropriate Freesurfer SUBJECTS_DIR. The files that the wrapper uses are:

* **make_MEBEM_template.py**: Wrapper to run the pipeline in one go.
* **multiechoBEM_funs**: Various python functions for sorting files and calling Bash scripts.
* **mne_flash_bem_NatMEG**: A version of *mne_flash_bem* from *mne* ((c) 2006 Matti Hamalainen ). This version is modified to run on multiecho sequence from GE scanner at KI.

For questions, please contact mikkel.vinding@ki.se
