# MRI stuff
Various helper functions for processing MRI for MEG analysis within the NatMEG infrastructure at Karolinska Institutet (www.natmeg.se).

## Tools:
* **NatMEG_recon** (bash): Wrapper that runs Freesurfers *recon-all* on raw MRI dicom and arranges output according to the project you specify. Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR. [working?]
* **NatMEG_recon_ima.sh** (bash): Wrapper that runs Freesurfer on raw MRI dicom "IMA" files (a weird Simens data format). Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR. Not pretty but it works! [I am not sure if I merged this into the first NatMEG_recon file?]
* **sort_dicom.py** and **sort_dicum2.py** (Python): Quick sorting of DICOM files [not working!].
* **?** Matlab/FieldTrip script to copy and scale template brain to subject digitalized headpoints from MEG.
* **?** Matlab/FieldTrip script to warp template MRI to subject MRI
* **multiecho_bem** (folder): BEM models using multiecho sequences (similar mne_flash_bem https://martinos.org/mne/dev/manual/appendix/bem_model.html#using-flash-images) on GE scanner. See documentation in folder. [is semi-working]

I will update functions to make them available for different projects. Functions are made to run within the NatMEG infrastructure. So far this is mostly backup from piloting and/or specific helper functions from the PD project. Some will work, some will probably not.
Feel free to use whatever you like from this project wherever you would like to. I provide no guarantee that it will work or hold any warranty. All application of the function is upon your own responsibility.


