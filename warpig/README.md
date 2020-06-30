# Warp template MRI to subject MRI

The opposite of what you normally do for group analysis of source reconstructed data.

## Examples
* `warp_template2subject_runscript.m` is the example script. Update so it only run the step needed for the following analysis steps. Move the testing examples of spm methods etc. to another example script.
* `warp_template2subject_example.m` is an outdated example scripts. 

## Procedure for test
1. `example_01_warp_temp2subj.m`: create warped temp2subj images.
2. `example_02_create_headmodels.m`: create headmodels from the warped template (and the original subject MRI for comparison)
3. Create grid source models with `create_sourcemodels.m`.