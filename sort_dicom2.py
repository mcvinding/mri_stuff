# -*- coding: utf-8 -*-
"""
Read EchoNumber from raw DICOM files. This should do the same as the "mne_organize_dicom" from MNE but work for GE scanner.

Run as sort_dicom2.py [subID] [seqNr] optional:[out_path]
subID = number or full name of subject folder on archive
seqNr = number of MRI sequence that is the multiecho sequence
out_path = Path to where the files will be put. Default is pwd

This is for PD_proj. Undeveloped version 1 is in FLASH_bem folder!
"""

import dicom
import sys
from os import listdir, chdir, symlink, makedirs, path, getcwd, rmdir

subID = str(sys.argv[1])
seqNr = str(sys.argv[2])

if len(sys.argv) > 3:
    out_path = path.join(sys.argv[3],subID)
else:
    out_path = path.join(getcwd(),subID)

MRI_dir = '/archive/20055_parkinson_motor/MRI'  #For general purpose this can be set to 50001 folder on /archive
overwrite = True        #

sub_folder = path.join(out_path,subID)
if path.exists(sub_folder) and not overwrite:
    print('Already sorted. Cancel operation!')
elif path.exists(sub_folder):
    try:
        rmdir(sub_folder)
    except:
        print('Folder not empty')
else:
    makedirs(sub_folder)    
    


#def sort_dcm(subID,seqNr,out_path)
# CHECK IF SUBJECT EXSISTS!
sub_dir = [s for s in listdir(MRI_dir) if subID in s] #Look for folders containing subject name.
if not sub_dir :
    sys.exit('No sub "'+subID+'" exists in folder: '+MRI_dir)
elif len(sub_dir) > 1:
    sys.exit('Found '+str(len(sub_dir))+' sub "'+subID+'" in folder: '+MRI_dir+'\nPlease be more specific about subjectname!')
else:
    sub_raw_path = path.join('/archive/20055_parkinson_motor/MRI/'+sub_dir[0])
    
# CHECK IF MRI SEQUENCE EXSISTS!
seq_dir = [s for s in listdir(sub_raw_path) if seqNr in s]
if not seq_dir :
    sys.exit('No MRI sequence named "'+seqNr+'" exists for sub '+subID)
elif len(seq_dir) > 1:
    sys.exit('Found '+str(len(seq_dir))+' sequences containtin "'+seqNr+'" for sub '+subID+'\nPlease be more specific about sequence number!')
else:
    dcm_path = path.join(sub_raw_path,seq_dir[0])
    
#if not path.exists(sub_r)
#out_path = '/home/mikkel/FLASH_bem_test/twlv_deg/'                           #Where to put folders with sorted .dcm files

#chdir(out_path)

dcm_files = [f for f in listdir(dcm_path) if path.isfile(path.join(dcm_path,f))]
print('Number of *.dcm files = %s') % len(dcm_files)

echo_dummy = [0]*len(dcm_files)

#First find number of differen echos from .dcm files in folder
print('Reading number of ECHOs in folder...')
for dcm_fname in dcm_files:
    dcm = dicom.read_file(dcm_path+'/'+dcm_fname)
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
    if not path.exists(path.join(out_path,folname)):
        makedirs(path.join(out_path,folname))
        print('Folder "%s" created for echo #%d') % (folname, ecco)
    else:
        print('Folder %s already exists!') %folname
        
# Sort .dcm in folders
for dcm_fname in dcm_files:
    echo = dicom.read_file(dcm_path+'/'+dcm_fname).EchoNumbers
    print("Fname = %s is echo #%d") % (dcm_fname,  echo)
    where_to_put = [i for i, s in enumerate(folders) if '00'+str(echo) in s][0]
    fname_out = path.join(out_path,folders[where_to_put],dcm_fname)
    if not path.isfile(fname_out):
        symlink(path.join(dcm_path,dcm_fname), fname_out)
        print("File put in folder %s") % path.join(out_path,folders[where_to_put])
    else:
        print('Link to %s already exists!') %dcm_fname
        
chdir(out_path)
print('DONE')
        
