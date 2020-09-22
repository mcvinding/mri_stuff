## RUN FREESURFER
export SUBJECTS_DIR='/home/mikkel/mri_scripts/warpig/fs_subjects_dir'

recon-all -all -subjid 0177
recon-all -all -subjid 0177warp

echo 'done'