# MRI stuff
Various helper functions for processing MRI for MEG analysis within the NatMEG infrastructure at Karolinska Institutet (www.natmeg.se).

## Tools:
* **NatMEG_recon** (bash): Wrapper that runs Freesurfers *recon-all* on raw MRI dicom and arranges output according to the project you specify. Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR. [working?]
* **NatMEG_recon_ima.sh** (bash): Wrapper that runs Freesurfer on raw MRI dicom "IMA" files (a weird Simens data format). Will read from MRI folder on Archive and store in your Freesurfer $SUBJECTS_DIR. Not pretty but it works! [I am not sure if I merged this into the first NatMEG_recon file?]
* **sort_dicom.py** and **sort_dicum2.py** (Python): Quick sorting of DICOM files [not working!].
* **warp_template2sub_example** (Matlab/FieldTrip): Script to warp and scale template MRI to subject MRI. The idea was that the warped template can be shared without breaking confidentiality.This is an example script that show how it is done for a single subject. Sometimes this does work, but other times it makes some wierd results.
* **add_template2sub_example** (Matlab/FieldTrip): script to add a template MRI to a subject without MRI based on headpoints. This is an example script that show how it is done for a single subject.
* **multiecho_bem** (folder): BEM models using multiecho sequences (similar mne_flash_bem https://martinos.org/mne/dev/manual/appendix/bem_model.html#using-flash-images) on GE scanner. See documentation in folder. [is semi-working]

I will update functions to make them available for different projects. Functions are made to run within the NatMEG infrastructure. So far this is mostly backup from piloting and/or specific helper functions from the PD project. Some will work, some will probably not.
Feel free to use whatever you like from this project wherever you would like to. I provide no guarantee that it will work or hold any warranty. All application of the function is upon your own responsibility.


