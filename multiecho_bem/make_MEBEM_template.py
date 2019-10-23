#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Create multiecho BEM for all subjects. This is a wrapper that will run all stages
to create the BEM:
    1) Sort multiecho DICOM.
    2) Make BEM
    3) Copy to apppropiate foldersw
Copy this file to your project dir and change the path defitions in the script 
below.
"""
# Import
import os.path as op
import sys
sys.path.append('/home/mikkel/mri_scripts/multiecho_bem')   # Path to folder with scripts (change)
from multiechoBEM_funs import sort_MEdicom, run_MEBEM, copyBEM2folder

#%% Options
# Where to put files (example)
subjects_dir = '/home/MYNAME/FOLDER/fs_subjects_dir'       # Path to Freesurfer SUBJECTS_DIR
dicom_folder = '/home/MYNAME/FOLDER/MRI'                   # Intermediate path for sorted DICOM. Will create a subfolder with name <subj>

# Input filenames (subject name and folder with raw DICOM)
subs_and_folders = {
                    'SUBJID' : '/PATH/TO/RAW/MULTIECHO/MRI/FILENAME',
                    }

# Generic output filenames (Intermediate path with sorted DICOM)
subs_and_dicompaths = {k:v for (k, v) in zip(subs_and_folders.keys(), (op.join(dicom_folder,f) for f in subs_and_folders.keys()))}

#%% RUN
for sub in subs_and_folders:
    print('Processing subj: '+sub)
    
    #Sort DICOMS
    print('##### SORTING ME DICOMS #####')
    sort_MEdicom(subs_and_folders[sub], subs_and_dicompaths[sub])
    
    # Run ME BEM
    print('##### MAKING BEM #####')
    run_MEBEM(sub, subs_and_dicompaths[sub], subjects_dir)
    
    # Copy BEM surfaces to folder for further processing in MNE-PY
    print('##### COPY FILES #####')
    copyBEM2folder(sub, subjects_dir, target='inner_skull')
    
# END
# * This is an alternative pipeline whjere everythins is run on all subjects before
#   proceeding to the next step. Useful for debugging.
##%% Sort DICOMS
#for sub in subs_and_folders:
#    print(sub)
#    sort_MEdicom(subs_and_folders[sub], subs_and_dicompaths[sub])
#    
##%% Run ME BEM
#for sub in subs_and_dicompaths:
#    print(sub)
#    run_MEBEM(sub, subs_and_dicompaths[sub], subjects_dir)
#
##%% Copy BEM surfaces to folder for further processing in MNE-PY
#for sub in subs_and_folders:
#    print(sub)
#    copyBEM2folder(sub, subjects_dir, target='inner_skull')

#END