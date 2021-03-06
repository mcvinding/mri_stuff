# -*- coding: utf-8 -*-
"""
Functions for multiecho BEM with GE scanner protocol.
* Sort multiecho dicoms
"""
import pydicom
import os
import os.path as op
import shutil
import subprocess

mritools = op.dirname(op.abspath(__file__))


def sort_MEdicom(in_path, out_path, replace=False):
    """
    Read EchoNumber from raw DICOM files. This should do the same as 
    "mne_organize_dicom" from MNE but work for GE scanner.
    
    Input: 
    in_path:    [str] Path to multiecho DICOM files.
    
    out_path:   [str] Path where the organised DICOM files will be.
    
    replace:    [logical] Overwrite old files (default=False).
    """   

    dcm_files = [f for f in os.listdir(in_path) if op.isfile(op.join(in_path,f))]
    print(len(dcm_files))
    print('Number of .dcm files = ', len(dcm_files))

    # 1) Find number of differen echos from .dcm files in folder
    print('Reading number of echos...')
    echo_dummy = [0]*len(dcm_files)
    for ii, dcm_fname in enumerate(dcm_files):
        dcm = pydicom.read_file(in_path+'/'+dcm_fname)
        echo_dummy[ii] = dcm.EchoNumbers

    echos = set(echo_dummy)    
    print('There are ', len(echos), ' different echoes')

    # 2) Create folders for sorted .dcm    
    folders = ['']*len(echos)
    print('Creating folders in ', out_path)
    for ii, ecco in enumerate(echos):
        folname = op.join(out_path,'flash06','00'+str(ecco)) # The flash06 is to force compabability with mne_function later on (should probably be fixed!)
        folders[ii] = folname    
        if not op.exists(folname):
            os.makedirs(folname)
            print('Folder "',folname,'" created for echo ',ecco)
        else:
            print('Folder "',folname,'" already exists!')
        
        # 3) Sort .dcm in folders
    for ii, dcm_fname in enumerate(dcm_files):
        echo = echo_dummy[ii]           #dicom.read_file(op.join(in_path,dcm_fname)).EchoNumbers
        print("Fname =",dcm_fname,' is echo ', echo)
        where_to_put = [i for i, s in enumerate(folders) if '00'+str(echo) in s][0]
        fname_out = op.join(out_path,folders[where_to_put],dcm_fname)
        if not op.isfile(fname_out) or replace:
            if replace:
                try:
                    os.remove(fname_out)
                except:
                    pass
                
            os.symlink(op.join(in_path,dcm_fname), fname_out)
            print("File put in folder ",op.join(out_path,folders[where_to_put]))
        else:
            print('Link to',dcm_fname, 'already exists!')
                
    print('DONE')

        
def copyBEM2folder(subj, subjects_dir, target=['inner_skull','outer_skull','outer_skin'], replace=False, hardcopy=True):
    
    if op.exists(op.join(subjects_dir, subj, 'bem', 'inner_skull.surf')) and not replace:
        raise Exception("Files appear to already exist. Will not copy")
    
    if hardcopy:
        inpath = op.join(subjects_dir, subj,'bem','flash')
        outpath = op.join(subjects_dir,subj,'bem')
        
        [shutil.copy(op.join(inpath,t+'.surf'), op.join(outpath,t+'.surf')) for t in target if op.exists(op.join(inpath,t+'.surf')) and not (op.isfile(op.join(outpath,t+'.surf')) and not replace)]
        
    else:
        os.chdir(subjects_dir)
        inpath = op.join(subj,'bem','flash')
        outpath = op.join(subj,'bem')
        
        [os.symlink(op.join(inpath,t+'.surf'), op.join(outpath,t+'.surf')) for t in target if op.exists(op.join(inpath,t+'.surf'))]
    
    
def run_MEBEM(subj, dicom_dir, subjects_dir):
    tempdir = os.getcwd()
    
    if op.exists(op.join(subjects_dir, subj, 'bem', 'falsh', 'inner_skull.surf')):
        raise Exception("Files appear to already exist. Delete to run again")
    
    # Prepare arguments
    cmd = (op.join(mritools, 'mne_flash_bem_NatMEG'))         #Command to execute
#    print(cmd)
    os.environ["SUBJECT"] = str(subj)
#    print(os.environ["SUBJECT"])
    os.environ["SUBJECTS_DIR"] = str(subjects_dir)
#    print(os.environ["SUBJECTS_DIR"])
    
    # Go to dir
    os.chdir(op.join(dicom_dir))
    
    # Call script
    print('Running '+cmd)
    print('SUBJECT: '+os.environ["SUBJECT"])
    print('SUBJECTS_DIR: '+os.environ["SUBJECTS_DIR"])
    print('>> Go to terminal to see status <<')
    val = subprocess.call(cmd, shell=True)
#    print(val)
    os.chdir(tempdir)
    print('done: '+subj)      
    
    
def add_highres_headmod(subj, subjects_dir, overwrite=False):
    os.environ["SUBJECTS_DIR"] = str(subjects_dir)
    
    if overwrite:
        owstr = ' --overwrite'
    else:
        owstr = str()
    
    # Add high reas scalp surface
    cmd = 'mne make_scalp_surfaces -s '+subj+' -d '+subjects_dir+' --force'+owstr        #Command to execute
    val = subprocess.call(cmd, shell=True)

        
#END