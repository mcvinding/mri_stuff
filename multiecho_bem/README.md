Project for running "FLASH" sequence BEM for creating forward models in MNE similar to https://martinos.org/mne/stable/manual/c_reference.html#mne-flash-bem but tweaked to work with the GE scanner at MR-centrum at Karolinska Institutet.

##Pipeline
1. Run normal Freesurfer pipeline (use <script> in <folder>)
2. Sort dicom echo files with *sort_MEdicoms.py*
3. Run *mne_flash_bem_NatMEG*
4. ???
5. Profit

##To do:
* Test that it works
