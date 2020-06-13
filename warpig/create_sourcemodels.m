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
load(fullfile(data_path, 'headmodel_lin.mat'));
load(fullfile(data_path, 'mri_lin_rs.mat'));
load(fullfile(data_path, 'headmodel_orig.mat'));
load(fullfile(data_path, 'mri_orig_rs.mat'));
load(fullfile(data_path, 'headmodel_spm12.mat'));
load(fullfile(data_path, 'mri_spm12_rs.mat'));

%% Make grid sourcemodels
% orig
cfg = [];
cfg.warpmni         = 'yes';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.mri             = mri_orig_rs;
cfg.spmversion      = 'spm12';          % SPM8 makes wierd source space.
cfg.spmmethod       = 'new';
sourcemodel_orig = ft_prepare_sourcemodel(cfg);

% spm12
cfg = [];
cfg.warpmni         = 'yes';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.mri             = mri_spm12_rs;
cfg.spmversion      = 'spm12';          % SPM8 makes wierd source space.
cfg.spmmethod       = 'new';
sourcemodel_spm12 = ft_prepare_sourcemodel(cfg);

% lin
cfg = [];
cfg.warpmni         = 'yes';
cfg.nonlinear       = 'yes';
cfg.unit            = 'mm';
cfg.template        = template_grid;
cfg.mri             = mri_lin_rs;
cfg.spmversion      = 'spm12';          % SPM8 makes wierd source space.
cfg.spmmethod       = 'new';
sourcemodel_lin = ft_prepare_sourcemodel(cfg);

%% Save
save(fullfile(data_path, 'sourcemodel_orig'), 'sourcemodel_orig')
save(fullfile(data_path, 'sourcemodel_spm12'), 'sourcemodel_spm12')
save(fullfile(data_path, 'sourcemodel_lin'), 'sourcemodel_lin')

%% Inspect
figure; hold on
ft_plot_mesh(sourcemodel_lin.pos(sourcemodel_lin.inside,:), 'vertexcolor','y');
ft_plot_mesh(sourcemodel_orig.pos(sourcemodel_orig.inside,:), 'vertexcolor','b');
ft_plot_mesh(sourcemodel_spm12.pos(sourcemodel_spm12.inside,:), 'vertexcolor','r');

%END