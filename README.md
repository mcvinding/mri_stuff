# MRI stuff
Various helper functions for processing MRI for MEG analysis within the NatMEG infrastructure at Karolinska Institutet (www.natmeg.se).

## Tools:
* Wrapper that runs Freesurfer on raw MRI dicom and arranges output according to the project you specify. Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR.
* Wrapper that runs Freesurfer on raw MRI dicom "IMA" files (a weird Simens data format). Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR. Not pretty but it works!
* BEM models using multiecho sequences (similar mne_flash_bem https://martinos.org/mne/dev/manual/appendix/bem_model.html#using-flash-images) on GE scanner (pipeline is not complete).
* Quick sorting of DICOM files (not working).
* Matlab/FieldTrip script to copy and scale template brain to subject digitalized headpoints from MEG.
* Matlab/FieldTrip script to warp template MRI to subject MRI

So far this is mostly backup from piloting and/or specific helper functions from the PD project. Some will work, some will probably not.
I will update functions to make them globally available. Functions are made to run within the NatMEG infrastructure. 
Feel free to use whatever you like from this project wherever you would like to. I provide no guarantee that it will work or hold any warranty. All application of the function is upon your own responsibility.


