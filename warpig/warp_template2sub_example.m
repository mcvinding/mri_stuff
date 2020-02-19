%% Warp template MRI to subject MRI for creating source model

% ftpath = 'C:\fieldtrip';
ftpath = '/home/mikkel/fieldtrip/fieldtrip';
addpath(ftpath)
addpath(fullfile(ftpath,'external/spm12'))
ft_defaults

%% Win paths
raw_folder = 'Y:/workshop_source_reconstruction/20180206';
out_folder = 'Z:/mri_scripts/warpig/data';

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206';
out_folder = '/home/mikkel/mri_scripts/warpig/data/';

%% Subject
subj = {'0177'};

%% Paths
mri_path = fullfile(raw_folder, 'MRI','dicoms');
sub_path = fullfile(out_folder, subj{1});

%% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;

%% Step 1: Load subject MRI
% Read MRI
raw_fpath = fullfile(mri_path, '00000001.dcm');
mri_raw = ft_read_mri(raw_fpath);

% Define coordinates
mri_coord = ft_determine_coordsys(mri_raw, 'interactive', 'yes');

% Convert to acpc format
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';   % Changeing to 'spm' stil converts to 'acpc'
mri_acpc = ft_volumerealign(cfg, mri_coord);

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI)
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc)

%% Make a resliced version for plotting (and for later processing)
mri_acpc_resliced = ft_volumereslice([], mri_acpc);

%% plot (for inspection)
cfg = [];
cfg.parameter = 'anatomy';
ft_sourceplot(cfg, mri_acpc_resliced); title('MRI acpc')

%% Normalize: template -> subject

% Non-linear normalization (SPM8)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
mri_norm1 = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison (SPM8)
cfg = [];
cfg.nonlinear = 'no';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
cfg.templatecoordsys = 'acpc';
mri_normL = ft_volumenormalise(cfg, mri_colin);

% Non-lineear normalization (SPM12)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
cfg.spmversion = 'spm12';
mri_norm2 = ft_volumenormalise(cfg, mri_colin);

% Non-linear normalization "new" method (SPM12)
% Gave Warning: conversion from spm to acpc is not supported [?]
cfg = [];
cfg.nonlinear   = 'yes';
cfg.template    = fullfile(sub_path,'orig_acpc.nii');
cfg.spmmethod   = 'new';
cfg.spmversion  = 'spm12';
cfg.templatecoordsys = 'acpc';  % Does not matter as ft_convert_coordsys will fix this
mri_norm3 = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison (SPM12) - same as SPM8
cfg = [];
cfg.nonlinear = 'no';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
cfg.spmversion = 'spm12';
mri_normL2 = ft_volumenormalise(cfg, mri_colin);

%% Experimental: fist linear, then nonlinear
% cfg = [];
% cfg.nonlinear = 'yes';
% cfg.template = fullfile(sub_path,'orig2.nii');
% cfg.spmmethod = 'new';
% cfg.spmversion = 'spm12';
% mri_normX = ft_volumenormalise(cfg, mri_normL);

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