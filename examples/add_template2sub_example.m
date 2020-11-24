% Add template to subject with missing MRI. Scale based on headpoints.
clear all;
close all;
restoredefaultpath
if ispc
    addpath C:\Users\Mikkel\Documents\MATLAB
    [dirs, sub_info, lh_subs] = PD_proj_setup_WIN('tap');
    addpath C:\fieldtrip\external\mne
    mri_path = 'Z:\PD_motor\fs_subjects_dir';
    out_path = 'Z:\PD_motor\MRI';
else
    addpath /home/mikkel/PD_motor/global_scripts
    [dirs, sub_info, lh_subs] = PD_proj_setup('tap');
    mri_path = '/home/mikkel/PD_motor/fs_subjects_dir';
    out_path = '/home/mikkel/PD_motor/MRI'; 
end

% Load template MRI
load standard_mri %Colin 27 template in fieldtrip
mri_colin = mri;

%% Init.
sub = '0327'; % Subject without MRI
% overwrite = 1;

%% Load data
meg_file = fullfile(dirs.megDir,sub,'0327_tap_1-ica_raw.fif');
% read MEG sensor location
MEG_sens = ft_read_sens(meg_file);
MEG_sens = ft_convert_units(MEG_sens,'mm');
% read polhemus headshape
headshape = ft_read_headshape(meg_file);
headshape   = ft_convert_units(headshape,'mm');

ft_plot_sens(MEG_sens); hold on
ft_plot_headshape(headshape)

save headshape headshape
save MEG_sens MEG_sens

% Manually align
cfg = [];
cfg.individual.mri = mri_colin;
cfg.template.headshape = headshape;
mri_intalign = ft_interactiverealign(cfg);

col_intalign = ft_transform_geometry(mri_intalign.m, mri_colin);

% Plot
ft_sourceplot([],col_intalign)
ft_sourceplot([],mri_colin)

% Automatic align
cfg = [];
cfg.method = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.viewresult = 'yes';
cfg.coordsys = 'neuromag';
col_intalign_align = ft_volumerealign(cfg, col_intalign);
cfg.headshape.icp = 'no';
col_intalign_align = ft_volumerealign(cfg, col_intalign_align);

% volumereslice
cfg = [];
cfg.resolution = 1;
col_intalign_reslice = ft_volumereslice(cfg, col_intalign_align);

ft_sourceplot([],col_intalign_reslice)

save('Z:\PD_motor\fs_subjects_dir\0327\mri\col_intalign_reslice.mat','col_intalign_reslice')
% save('home/mikkel/PD_motor/fs_subjects_dir/0327/mri/col_intalign_reslice.mat','col_intalign_reslice')

%% save for freesurfer (must be done on Linux)
load('home/mikkel/PD_motor/fs_subjects_dir/0327/mri/col_intalign_reslice.mat')

cfg = [];
cfg.parameter = 'anatomy';
cfg.filename = '/home/mikkel/PD_motor/fs_subjects_dir/0327/mri/orig';
cfg.filetype = 'mgz';
ft_volumewrite(cfg, col_intalign_reslice)


% END