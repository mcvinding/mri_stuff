#!/bin/sh
#
# This is a wrapper for making "FLASH" BEM models within the NatMEG structure (currently only for PD_proj).
# 
# It uses the MNE FLASH BEM procedure, but with alternations adapted to the GE scanner at KI.
#
# It first sorts the multiecho sequences and then runs an modified version of mne_flash_bem [(C) Matti Hamalainen 2006].
# Wrapper created by MCV (mikkel.vinding@ki.se)


# MAKE HELP
display_help() {
	echo
	echo "Useage: $0 [SUBJECT] [multiecho seq nr] [multiecho_folder]"
	echo 
	echo "This script will sort all multiecho *.dcm files for subject with id *subId* and then use these to create BEM. Requires that FREESURFER has been set up, and T1 images already has been processed"
	echo 
	echo "	[SUBJECT] is four-digit subject number"
	echo "	[multiecho seq nr] is the number of the multiecho sequence in the MR folder"
	echo "	[multiecho_folder] is where links to multiecho *.dcm subjectfolder (not the files) will be put. If no multiecho_folder is specified it will use the current work directory."
	echo ""
	exit 1
}

if [ -z $@ ]
then
	display_help
elif [ -z $2 ]
then
	echo 'Warning: Arguments missing. Must have subject and multiecho sequence number!'
	display_help
fi
# --------------------------- #
export SUBJECT=$1
seq_nr=$2

if [ $3 ]; then
	out_folder="$3"	
else
	out_folder=$(pwd)
fi
echo "MEG id = $SUBJECT, Multiecho MR seq. = $seq_nr"

# GET/SET FREESURFER (Remove or change if making a general script!)
export FREESURFER_HOME=/opt/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
export SUBJECTS_DIR=/home/mikkel/PD_motor/fs_subjects_dir
#echo $SUBJECTS_DIR

if [ ! -d $SUBJECTS_DIR/$SUBJECT ]; then
	echo "$SUBJECT does not exist in $SUBJECTS_DIR. Are you sure 'recon-all' has been run?"
	exit 1
fi

# ----------------------------
# Get functions
scripts_path='/home/mikkel/PD_motor/global_scripts'

ipython $scripts_path/sort_dicom2.py $SUBJECT $seq_nr $out_folder

cd $out_folder/$SUBJECT

echo "Multiecho files have been sorted in $out_folder/$SUBJECT"
echo "Now creating BEM models in $SUBJECTS_DIR/$SUBJECT"

$scripts_path/mne_flash_bem_NatMEG

echo "-----------------DONE $SUBJECT ----------------------"





















