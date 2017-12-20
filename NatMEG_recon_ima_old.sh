#!/bin/sh
# Template for doing FreeSurfer recon-all on subjects with IMA files.

#Get subject id
if [[ -z "$@" ]]
then
	echo "Use as: NatMEG_recon [megID] [T1-sequence-number - i.e. last digits] [out_dir] [subid(if not same as megID)]"
	exit 1
fi

export megId="$1"
t1_nr="$2"
if [ $3 ]; then
	export SUBJECTS_DIR="$3"	
else
	echo "Warning OUT_DIR not set. Use FS dir from enviromen: $SUBJECTS_DIR"
	read -rsp "[press SPACE to confirm or anything else to cancel]" -n1 ans
	if [ ! $ans = ' ' ]; then
		echo ''
		exit 1
	else
		echo '------------------------------------'	
	fi
fi
if [ $4 ]; then
	export subId="$4"
else
	export subId=$megId
fi

echo "MEG id = $megId, MR seq. = $t1_nr, fs output id = $subId"
# --------------------------- #

export FREESURFER_HOME=/opt/freesurfer
source $FREESURFER_HOME/SetUpFreeSurfer.sh
#export SUBJECTS_DIR=/home/mikkel/PD_motor/fs_subjects_dir
echo "Subjects dir = $SUBJECTS_DIR"

#Find correct T1 folder
MRI_archive='/archive/50001_MR_archive'
MRI_subDir=$(find $MRI_archive -maxdepth 1 -type d -name "*$megId*" | awk 'NR==1')
#echo $MRI_subDir
dcmPath=$(find $MRI_subDir -maxdepth 1 -type d -name "*$t1_nr*" | awk 'NR==1')
#echo $dcmPath

if [[ $dcmPath = $MRI_subDir ]]; then
	echo "Sequence $t1_nr not found. Try providing a longer part of the sequence name"
	if [ -z "$2" ]; then
		echo "Hint: You are missing MR sequence as argument"
	fi
	ls $MRI_subDir
	return
else
	echo "Using files in $dcmPath"	
fi

# FIND FILE AS INPUT
echo "Searching for right file in $dcmPath... this takes a while"
fileExtension="IMA"
OUTPUT="$(dcmunpack -src $dcmPath -ext $fileExtension)"
array=($OUTPUT)

for i in "${array[@]}"
do
    if [[ "$i" == *"$fileExtension"* ]] ; then
        export fname=$i
    fi
done

#Let it run recon-all and crash (there might be a way around this!)
echo "Running recon-all but expecting it to crash!"
TESTVAR="$(recon-all -subjid $subId -i $fname -all)"
#echo "IGNORE WARNINGS ABOVE"

#cd $SUBJECTS_DIR/$subId/mri/orig
#echo "Copying $SUBJECTS_DIR/$subId/mri/orig/001.mgz to $SUBJECTS_DIR/$subId/mri/orig/too_many_frames.mgz for future use"
#mv $SUBJECTS_DIR/$subId/mri/orig/001.mgz $SUBJECTS_DIR/$subId/mri/orig/too_many_frames.mgz
#mri_convert -nth 0 $SUBJECTS_DIR/$subId/mri/orig/too_many_frames.mgz 001.mgz
cd $SUBJECTS_DIR

echo '------------------------------------------------------------'
echo "---------- Now running recon-all on $subId -----------------"
echo '------------------------------------------------------------'

recon-all -subjid $subId -all -no-isrunning #-i $fname -all

echo '------------------------------------------------------------'
echo "------------------- DONE $subId ----------------------------"
echo '------------------------------------------------------------'

cd $SUBJECTS_DIR/$subId/mri














