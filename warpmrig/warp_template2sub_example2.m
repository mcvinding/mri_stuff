% Warp template MRI to subject MRI and do source reconstruction.
% addpath '~/fieldtrip/fieldtrip/'
% addpath '~/fieldtrip/fieldtrip/external/mne'
ftpath = 'C:\fieldtrip';
addpath(ftpath)
addpath(fullfile(ftpath,'external/spm12'))
ft_defaults

mri_path = 'Z:\PD_motor\MRI';
mri_path = 'home/mikkel/PD_motor/MRI';


%% Options
sub = '0362';  %Change if loop

sub_path = fullfile(mri_path,sub);

%% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;

%% Step 1: Convert Load subject MRI (Option 1: from Freesurfer)
% % NB: not working on WIN PC
% 
% % Read MRI
% orig_fpath = fullfile(fs_path,sub,'mri/orig.mgz');
% mri_orig = ft_read_mri(orig_fpath);
% 
% % Define coordinates
% mri_coord = ft_determine_coordsys(mri_orig, 'interactive', 'yes');         % RAS, not a landmark
% 
% % Convert to acpc format [why the two step procedure?]
% cfg = [];
% cfg.method = 'interactive';
% cfg.coordsys = 'neuromag';
% mri_realigned = ft_volumerealign(cfg, mri_coord);
% 
% mri_acpc = ft_convert_coordsys(mri_realigned, 'acpc');
% 
% % Save subject volume as the "template". The template anatomy should always
% % be stored in a SPM-compatible file
% cfg = [];
% cfg.filetype    = 'nifti';          % .nii exntension
% cfg.parameter   = 'anatomy';
% cfg.filename    = fullfile(mri_path,sub,'mri/orig');   % Same base filename but different format
% ft_volumewrite(cfg, mri_acpc)

% save(fullfile(fs_path,sub,'mri/template_morphed.mgz'));

%% Step 1: Load subject MRI (Option 2: from FieldTrip)

% Read MRI
orig_fpath = fullfile(sub_path,'mri.mat');
load(orig_fpath)

% Define coordinates
mri_coord = ft_determine_coordsys(mri, 'interactive', 'yes');

% Convert to acpc format [why the two step procedure: because finding ac and pc point is difficult]
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'spm';   % Changeing to 'spm' stil converts to 'acpc'
mri_realigned = ft_volumerealign(cfg, mri_coord);       

mri_acpc = ft_convert_coordsys(mri_realigned, 'acpc');     

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc)

%% Make a resliced version for plotting (and for later processing)
mri_acpc_resliced = ft_volumereslice([], mri_acpc);
mri_spm_resliced = ft_volumereslice([], mri_spm);

%% Make a resliced original MRI in neuromag coordsys for later processing
mri_spm_resliced = ft_volumereslice([], mri_spm);


%% plot 
cfg = [];
cfg.parameter = 'anatomy';
ft_sourceplot(cfg, mri_acpc_resliced); title('MRI acpc')

%% Normalize: template -> subject

% Non-linear normalization (SPM8)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig2.nii');
mri_norm1 = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison (SPM8)
cfg = [];
cfg.nonlinear = 'no';
cfg.template = fullfile(sub_path,'orig2.nii');
cfg.templatecoordsys = 'acpc';
mri_normL = ft_volumenormalise(cfg, mri_colin);

% Non-lineear normalization (SPM12)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig2.nii');
cfg.spmversion = 'spm12';
mri_norm2 = ft_volumenormalise(cfg, mri_colin);

% Non-linear normalization "new" method (SPM12)
% Gave Warning: conversion from spm to acpc is not supported [?]
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig2.nii');
cfg.spmmethod = 'new';
cfg.spmversion = 'spm12';
mri_norm3 = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison (SPM12) - same as SPM8
cfg = [];
cfg.nonlinear = 'no';
cfg.template = fullfile(sub_path,'orig2.nii');
cfg.spmversion = 'spm12';
mri_normL2 = ft_volumenormalise(cfg, mri_colin);

%% Experimental: fist linear, then nonlinear
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig2.nii');
cfg.spmmethod = 'new';
cfg.spmversion = 'spm12';
mri_normX = ft_volumenormalise(cfg, mri_normL);

%% Determine coordsys
mri_norm1 = ft_determine_units(mri_norm1);
mri_norm2 = ft_determine_units(mri_norm2);
mri_norm3 = ft_determine_units(mri_norm3);
mri_normL = ft_determine_units(mri_normL);
mri_normX = ft_determine_units(mri_normX);

%% Plot
cfg = [];
cfg.funparameter = 'anatomy';

ft_sourceplot([],mri_colin); title('Original Colin')
ft_sourceplot([],mri_norm1); title('Norm (non-lienar, SPM8)')
ft_sourceplot([],mri_norm2); title('Norm (non-lienar, SPM12)')
ft_sourceplot([],mri_norm3); title('Norm (non-lienar, SPM12, new method)')
ft_sourceplot([],mri_normL); title('Norm (linear, SPM8)')
ft_sourceplot([],mri_normL2); title('Norm (linear, SPM12)')

ft_sourceplot([],mri_resliced); title('Original sub')

ft_sourceplot([],mri_normX); title('Norm (linear, then non-linear')


%% Save template
cd(fullfile('Z:\mri_scripts\warpmrig\data',sub))
fprintf('saving...')
save('mri_norm1','mri_norm1')
save('mri_norm2','mri_norm2')
save('mri_norm3','mri_norm3')
save('mri_normL','mri_normL')
save('mri_resliced', 'mri_acpc_resliced')
fprintf('done\n')



%% Preapre for Freesurfer
% I have still not tested how the normalized MRI run in Freesurfer.

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri_norm);
mri.anatomy = mri.anatomy.*double(seg.brain);

cfg             = [];
cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);

% END