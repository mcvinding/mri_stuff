# -*- coding: utf-8 -*-
"""
Functions for multiecho BEM with GE scanner protocol.
* Sort multiecho dicoms
"""
import dicom
from os import listdir, chdir, symlink, makedirs
import os.path as op

def sort_MEdicom(in_path, out_path, replace=False):
    """
    Read EchoNumber from raw DICOM files. This should do the same as 
    "mne_organize_dicom" from MNE but work for GE scanner.
    
    Input: 
    in_path:    [str] Path to multiecho DICOM files.
    
    out_path:   [str] Path where the organised DICOM files will be.
    
    replace:    [logical] Overwrite old files (default=False).
    """   

    dcm_files = [f for f in listdir(in_path) if op.isfile(op.join(in_path,f))]
    print('Number of .dcm files = %s') % len(dcm_files)

# 1) Find number of differen echos from .dcm files in folder
    print('Reading number of echos...')
    echo_dummy = [0]*len(dcm_files)
    for ii, dcm_fname in enumerate(dcm_files):
        dcm = dicom.read_file(in_path+'/'+dcm_fname)
        echo_dummy[ii] = dcm.EchoNumbers

    echos = set(echo_dummy)    
    print('There are %d different echoes') % len(echos)

# 2) Create folders for sorted .dcm    
    folders = ['']*len(echos)
    print('Creating folders in %s') % out_path
    for ii, ecco in enumerate(echos):
        folname = op.join(out_path,'flash06','00'+str(ecco))                       # The flash06 is to force compabability with mne_function later on (should probably be fixed!)
        folders[ii] = folname    
        if not op.exists(folname):
            makedirs(folname)
            print('Folder "%s" created for echo #%d') % (folname, ecco)
        else:
            print('Folder %s already exists!') %folname
        
# 3) Sort .dcm in folders
    for ii, dcm_fname in enumerate(dcm_files):
        echo = echo_dummy[ii]           #dicom.read_file(op.join(in_path,dcm_fname)).EchoNumbers
        print("Fname = %s is echo #%d") % (dcm_fname,  echo)
        where_to_put = [i for i, s in enumerate(folders) if '00'+str(echo) in s][0]
        fname_out = op.join(out_path,folders[where_to_put],dcm_fname)
        if not op.isfile(fname_out) or replace:
            symlink(op.join(in_path,dcm_fname), fname_out)
            print("File put in folder %s") % op.join(out_path,folders[where_to_put])
        else:
            print('Link to %s already exists!') %dcm_fname
                
    print('DONE')
        
#END