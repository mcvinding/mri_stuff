#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Sort multiecho DICOM for all subjects.
"""
# Import
import os.path as op
import sys
sys.path.append('/home/mikkel/mri_scripts/multiecho_bem')   # Path to folder with scripts
from multiechoBEM_funs import sort_MEdicom

#%% Options
# Where to put files
output_folder = '/home/mikkel/PD_long/MRI'           # Will create a subfolder with name <subj>

# Input filenames
in_paths = {'0522':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0522/00000004',
            '0523':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0523/00000004',
            '0524':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0524/00000004',
            '0525':'/archive/20079_parkinsons_longitudinal/MRI/NatMEG_0525/00000004' 
            }

# Generic output filenames
out_paths = {k:v for (k, v) in zip(in_paths.keys(), (op.join(output_folder,f) for f in in_paths.keys()))}

#%% Sort DICOMS
for sub in in_paths:
    print(sub)
    sort_MEdicom(in_paths[sub],out_paths[sub])

#%%END
