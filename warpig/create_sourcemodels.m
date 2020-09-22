%% Make source models
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Prepare template
ftpath   = '/home/mikkel/fieldtrip/fieldtrip'; % this is the path to fieldtrip at Donders
load(fullfile(ftpath, 'template/sourcemodel/standard_sourcemodel3d6mm'));
template_grid = sourcemodel;
template_grid = ft_convert_units(template_grid,'mm');
clear sourcemodel;

%% Load data
% Load headmodel and MRI
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'mri_tmp_resliced.mat'));
load(fullfile(data_path, 'headmodel_orig.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));

%% Make grid sourcemodels
% orig
cfg = [];
cfg.warpmni         = 'yes';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.mri             = mri_org_resliced;
cfg.spmversion      = 'spm12';
cfg.spmmethod       = 'new';
sourcemodel_orig = ft_prepare_sourcemodel(cfg);

% spm12
cfg = [];
cfg.warpmni         = 'yes';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.mri             = mri_tmp_resliced;
cfg.spmversion      = 'spm12';
cfg.spmmethod       = 'new';
sourcemodel_tmp = ft_prepare_sourcemodel(cfg);

%% Save
save(fullfile(data_path, 'sourcemodels'), 'sourcemodel_orig', 'sourcemodel_tmp')

%% Inspect
figure; hold on
ft_plot_mesh(sourcemodel_tmp.pos(sourcemodel_tmp.inside,:), 'vertexcolor','y');
ft_plot_mesh(sourcemodel_orig.pos(sourcemodel_orig.inside,:), 'vertexcolor','b');

%END