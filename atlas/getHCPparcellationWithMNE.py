#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Feb 15 22:27:49 2024
@author: mikkel
"""

import mne

subjects_dir='/home/mikkel/PD_long/fs_subjects_dir'

mne.datasets.fetch_hcp_mmp_parcellation(subjects_dir=subjects_dir, combine=True, accept=True, verbose=None)

# For this to work I had to remove the symbolic link to fsaverage and copy fsaverage
# to the fs subhects dir instead.