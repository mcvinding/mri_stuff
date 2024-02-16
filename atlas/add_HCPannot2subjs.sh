export SUBJECTS_DIR=/home/mikkel/PD_long/fs_subjects_dir

# Define subjects
sub_list=( 0522 0530 0536 0544 0550 0557 0564 0570 0576 0582 0588 0594 0600 0606 0614 0620 0626 0633 0640 0648 0523 0531 0537 0545 0551 0559 0565 0571 0577 0583 0589 0595 0601 0607 0615 0621 0627 0634 0641 0649 0524 0532 0540 0546 0552 0560 0566 0572 0578 0584 0590 0596 0602 0608 0616 0622 0628 0635 0642 0650 0525 0533 0541 0547 0553 0561 0567 0573 0579 0585 0591 0597 0603 0610 0617 0623 0629 0636 0643 0528 0534 0542 0548 0554 0562 0568 0574 0580 0586 0592 0598 0604 0611 0618 0624 0630 0637 0645 0529 0535 0543 0549 0556 0563 0569 0575 0581 0587 0593 0599 0605 0612 0619 0625 0632 0638 0647 )


# Loop through subjects to create annot files: HCP combined
for SUB in ${sub_list[*]}; do
	# LH
	mri_surf2surf --srcsubject fsaverage --trgsubject $SUB --hemi lh \
	--sval-annot $SUBJECTS_DIR/fsaverage/label/lh.HCPMMP1_combined.annot \
	--tval       $SUBJECTS_DIR/$SUB/label/lh.HCPMMP1_combined.annot
	
	# RH
	mri_surf2surf --srcsubject fsaverage --trgsubject $SUB --hemi rh \
	--sval-annot $SUBJECTS_DIR/fsaverage/label/rh.HCPMMP1_combined.annot \
	--tval       $SUBJECTS_DIR/$SUB/label/rh.HCPMMP1_combined.annot
done

#END
