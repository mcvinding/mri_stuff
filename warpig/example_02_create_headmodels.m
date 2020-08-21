%% Create headmodels 
% Create headmodels (volume conductor models) from anatomical MRIs for MEG 
% source analysis. This is done for the template MRI warped to subject and for
% the original subject MRI for comparison.

%% Setup
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path  = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load MRI
load(fullfile(data_path, 'mri_warp2neuromag.mat'));   % Warped template MRI
load(fullfile(data_path, 'mri_orig.mat'));        % original subject MRI

%% STEP 2A: Align MRI and MEG headpoints in MEG coordinate system (neuromag)
% Get headshapes and sensor info from MEG file
rawfile     = fullfile(raw_folder, 'tactile_stim_raw_tsss_mc.fif');
headshape   = ft_read_headshape(rawfile);
grad        = ft_read_sens(rawfile,'senstype','meg'); % Load MEG sensors

% Make sure units are mm 
headshape = ft_convert_units(headshape, 'mm');
grad      = ft_convert_units(grad, 'mm');

% Save headshapes and sensor info (optional)
save(fullfile(data_path, 'headshape'), 'headshape')
save(fullfile(data_path, 'grad'), 'grad')

% Initial alignment of normalized MRI to neuromag coordinate system (this
% step can be omitted by loading the correct files)
cfg = [];
cfg.method   = 'interactive';
cfg.coordsys = 'neuromag';
mri_tmp_realign1 = ft_volumerealign(cfg, mri_warp2neuromag);
mri_org_realign1 = ft_volumerealign(cfg, mri_orig);

% Aligh MRI to MEG headpoints
cfg = [];
cfg.method              = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp       = 'yes';
cfg.coordsys            = 'neuromag';
mri_tmp_realign2 = ft_volumerealign(cfg, mri_tmp_realign1);
mri_org_realign2 = ft_volumerealign(cfg, mri_org_realign1);

% Inspection
cfg.headshape.icp = 'no';
mri_tmp_realign3 = ft_volumerealign(cfg, mri_tmp_realign2);
mri_org_realign3 = ft_volumerealign(cfg, mri_org_realign2);

% Save
save(fullfile(data_path, 'mri_tmp_realign3'), 'mri_tmp_realign3')
save(fullfile(data_path, 'mri_org_realign3'), 'mri_org_realign3')
disp('done')

%% STEP 2B: reslice aligned MRI
% tic
mri_tmp_resliced = ft_volumereslice([], mri_tmp_realign3);
mri_org_resliced = ft_volumereslice([], mri_org_realign3);
% toc

% Save
fprintf('saving...')
save(fullfile(data_path,'mri_tmp_resliced'), 'mri_tmp_resliced');
save(fullfile(data_path,'mri_org_resliced'), 'mri_org_resliced');
disp('done')

%% STEP 2C: Segment inner volume of MRI.
cfg = [];
cfg.output = 'brain';
mri_tmp_seg = ft_volumesegment(cfg, mri_tmp_resliced);
mri_org_seg = ft_volumesegment(cfg, mri_org_resliced);

% Save 
save(fullfile(data_path, 'mri_tmp_seg.mat'), 'mri_tmp_seg')
save(fullfile(data_path, 'mri_org_seq.mat'), 'mri_org_seg')

% Plot segmentations for inspection
mri_tmp_seg.anatomy = mri_tmp_resliced.anatomy;
mri_org_seg.anatomy = mri_org_resliced.anatomy;

cfg = [];
cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, mri_tmp_seg);
ft_sourceplot(cfg, mri_org_seg);

% Plot both segmentations on original volume
pltvol = mri_org_resliced;
pltvol.brain = mri_org_seg.brain + mri_tmp_seg.brain;

cfg.anaparameter = 'anatomy';
cfg.funparameter = 'brain';
ft_sourceplot(cfg, pltvol);

%% STEP 2D: Construct mesh from inner volume and create the headmodel
cfg = [];
cfg.method      = 'projectmesh';
cfg.tissue      = 'brain';
cfg.numvertices = 3000;
mesh_brain_tmp = ft_prepare_mesh(cfg, mri_tmp_seg);
mesh_brain_org = ft_prepare_mesh(cfg, mri_org_seg);

cfg = [];
cfg.method = 'singleshell';
headmodel_tmp = ft_prepare_headmodel(cfg, mesh_brain_tmp);
headmodel_org = ft_prepare_headmodel(cfg, mesh_brain_org);

% Save headmodels
save(fullfile(data_path, 'headmodel_tmp.mat'), 'headmodel_tmp')
save(fullfile(data_path, 'headmodel_org.mat'), 'headmodel_org')
disp('done')

%% Plot headmodels for inspection
subplot(1,2,1); hold on
ft_plot_headmodel(headmodel_tmp, 'edgecolor','b','facealpha',0.5)
ft_plot_sens(grad)
ft_plot_headshape(headshape)
title('template')

subplot(1,2,2); hold on
ft_plot_headmodel(headmodel_org, 'edgecolor','r','facealpha',0.5)
ft_plot_sens(grad)
ft_plot_headshape(headshape)
title('orig')

figure; hold on
ft_plot_headmodel(headmodel_tmp, 'edgecolor','b','facealpha',0.5)
ft_plot_headmodel(headmodel_org, 'edgecolor','r','facealpha',0.5)

%END