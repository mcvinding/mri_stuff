#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Sort multiecho DICOM for all subjects.
"""
# Import
import os.path as op
import sys
sys.path.append('/home/mikkel/mri_scripts/multiecho_bem')   # Path to folder with scripts
from multiechoBEM_funs import sort_MEdicom, run_MEBEM, copyBEM2folder

#%% Options
# Where to put files
subjects_dir = '/home/mikkel/PD_long/fs_subjects_dir'       # Path to Freesurfer SUBJECTS_DIR
dicom_folder = '/home/mikkel/PD_long/MRI'                   # Intermediate path for sorted DICOM. Will create a subfolder with name <subj>

# Input filenames (subject name and folder with raw DICOM)
subs_and_folders = {
#                    '0522':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0522/00000004',
                   '0523':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0523/00000004'
#                   '0524':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0524/00000004',
#                   '0525':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0525/00000004' 
                    }

# Generic output filenames (Intermediate path with sorted DICOM)
subs_and_dicompaths = {k:v for (k, v) in zip(subs_and_folders.keys(), (op.join(dicom_folder,f) for f in subs_and_folders.keys()))}

#%% Sort DICOMS
for sub in subs_and_folders:
    print(sub)
    sort_MEdicom(subs_and_folders[sub], subs_and_dicompaths[sub])
    
#%% Run ME BEM
for sub in subs_and_dicompaths:
    print(sub)
    run_MEBEM(sub, subs_and_dicompaths[sub], subjects_dir)

#%% Copy BEM surfaces to folder for further processing in MNE-PY
for sub in subs_and_folders:
    print(sub)
    copyBEM2folder(sub, subjects_dir, target='inner_skull')

#%%END
