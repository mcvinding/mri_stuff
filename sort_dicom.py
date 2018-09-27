# -*- coding: utf-8 -*-
"""
Read EchoNumber from raw DICOM files. This should do the same as the "mne_organize_dicom" from MNE but work for GE scanner.
"""

import dicom
from os import listdir, chdir, symlink, makedirs
from os.path import isfile, join, exists

in_path = '/archive/20055_parkinson_motor/MRI/NatMEG_0245/00000006'         #Raw data folder
out_path = '/home/mikkel/FLASH_bem_test/twlv_deg/'                           #Where to put folders with sorted .dcm files

#chdir(out_path)

dcm_files = [f for f in listdir(in_path) if isfile(join(in_path,f))]
print('Number of .dcm files = %s') % len(dcm_files)

echo_dummy = [0]*len(dcm_files)

#First find number of differen echos from .dcm files in folder
print('Reading number of ECHOs in folder...')
for dcm_fname in dcm_files:
    dcm = dicom.read_file(in_path+'/'+dcm_fname)
    echo_dummy[dcm_files.index(dcm_fname)] = dcm.EchoNumbers
    echos = set(echo_dummy)
    
print('There are %d different echoes\nValues are %s') % (len(echos), echos)

# Create folders for sorted .dcm    
#Pname = dcm.ProtocolName                                                       #Does this matter?
folders = ['']*len(echos)
print('Creating folders in %s') % out_path
    
for ecco in echos:
    folname = 'flash06/00'+str(ecco)   #+'_'+Pname
    folders[ecco-1] = folname    
    if not exists(out_path+folname):
        makedirs(out_path+folname)
        print('Folder "%s" created for echo #%d') % (folname, ecco)
    else:
        print('Folder %s already exists!') %folname
        
# Sort .dcm in folders
for dcm_fname in dcm_files:
    echo = dicom.read_file(in_path+'/'+dcm_fname).EchoNumbers
    print("Fname = %s is echo #%d") % (dcm_fname,  echo)
    where_to_put = [i for i, s in enumerate(folders) if '00'+str(echo) in s][0]
    fname_out = out_path+folders[where_to_put]+'/'+dcm_fname
    if not isfile(fname_out):
        symlink(in_path+'/'+dcm_fname, fname_out)
        print("File put in folder %s") % out_path+folders[where_to_put]
    else:
        print('Link to %s already exists!') %dcm_fname
        
        
print('DONE')
        
