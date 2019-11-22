%% Dipole source analysis
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load data
cd(data_path)
load(fullfile(raw_folder,'timelockeds.mat'));
load(fullfile(data_path, 'headmodel_lin.mat'));
load(fullfile(data_path, 'headmodel_orig.mat'));
load(fullfile(data_path, 'headmodel_spm12.mat'));
load(fullfile(data_path, 'sourcemodel_lin.mat'));
load(fullfile(data_path, 'sourcemodel_orig.mat'));
load(fullfile(data_path, 'sourcemodel_spm12.mat'));
disp('Done');

data = timelockeds{4};   % Only indexfinger stim.

%% Settings
early_latency   = [0.040 0.060]; % s
late_latency    = [0.115 0.155]; % s

cfg = [];
cfg.channel = 'MEG*';
meg_data = ft_selectdata(cfg, data);
grad = meg_data.grad;                   % Something wierd! Somwhow all channels are megmag ???
grad = ft_convert_units(grad, 'mm');  %Remember to convert units or errors

%% Make leadfields
% cfg = [];
% cfg.senstype    = 'meg';
% cfg.channel     = 'MAGS';
% cfg.grad        = data.grad;
% 
% cfg.headmodel   = headmodel_lin;
% cfg.sourcemodel = sourcemodel_lin;
% leadfield_mag_lin = ft_prepare_leadfield(cfg, data);
% 
% 
% cfg.channel = 'meggrad';
% 
% leadfield_grad = ft_prepare_leadfield(cfg, timelockeds{1});

figure; hold on
ft_plot_sens(grad, 'unit', 'mm');
ft_plot_headmodel(headmodel_lin)
ft_plot_mesh(sourcemodel_lin.pos(sourcemodel_lin.inside,:), 'vertexcolor','y');

%% Do dipole fit: magnetometer fits
cfg = [];
cfg.gridsearch          = 'yes';        %% search the grid for an optimal starting point
cfg.dipfit.metric       = 'rv';         %% the metric to minimize (the relative residual variance: proportion of variance left unexplained by the dipole model)
cfg.model               = 'regional';   %% we assume that the dipole has a fixed position during the time points in the latency range
cfg.senstype            = 'MEG';        %% sensor type
cfg.channel             = 'megmag';     %% which channels to use
cfg.grad                = grad_raw;
cfg.nonlinear           = 'yes';        %% do a non-linear search

% FIRST COMPONENT
cfg.latency             = early_latency; %% specify the latency
cfg.numdipoles          = 1; %% we only expect contralateral activity
cfg.symmetry            = []; %% empty for single dipole fit

% linear
cfg.sourcemodel         = sourcemodel_lin;

cfg.sourcemodel.pos     = sourcemodel_lin.pos;
cfg.sourcemodel.inside  = sourcemodel_lin.inside;
cfg.sourcemodel.dim     = sourcemodel_lin.dim;
cfg.headmodel           = headmodel_lin;
dip_mag_early_lin = ft_dipolefitting(cfg, meg_data);

% orig
cfg.sourcemodel.pos     = sourcemodel_orig.pos;
cfg.sourcemodel.inside  = sourcemodel_orig.inside;
cfg.sourcemodel.dim     = sourcemodel_orig.dim;
cfg.headmodel           = headmodel_orig; %% supply the headmodel
dip_mag_early_orig = ft_dipolefitting(cfg, meg_data);

% spm12
cfg.sourcemodel.pos     = sourcemodel_spm12.pos;
cfg.sourcemodel.inside  = sourcemodel_spm12.inside;
cfg.sourcemodel.dim     = sourcemodel_spm12.dim;
cfg.headmodel           = headmodel_spm12; %% supply the headmodel
dip_mag_early_spm12 = ft_dipolefitting(cfg, meg_data);

% SECOND COMPONENT
cfg.latency             = late_latency;
cfg.numdipoles          = 2;    %% we expect bilateral activity
cfg.symmetry            = 'x';

% linear
cfg.sourcemodel.pos     = sourcemodel_lin.pos;
cfg.sourcemodel.inside  = sourcemodel_lin.inside;
cfg.sourcemodel.dim     = sourcemodel_lin.dim;
cfg.headmodel           = headmodel_lin; %% supply the headmodel
dip_mag_late_lin = ft_dipolefitting(cfg, meg_data);

% orig
cfg.sourcemodel.pos     = sourcemodel_orig.pos;
cfg.sourcemodel.inside  = sourcemodel_orig.inside;
cfg.sourcemodel.dim     = sourcemodel_orig.dim;
cfg.headmodel           = headmodel_orig; %% supply the headmodel
dip_mag_late_orig = ft_dipolefitting(cfg, meg_data);

% spm12
cfg.sourcemodel.pos     = sourcemodel_spm12.pos;
cfg.sourcemodel.inside  = sourcemodel_spm12.inside;
cfg.sourcemodel.dim     = sourcemodel_spm12.dim;
cfg.headmodel           = headmodel_spm12; %% supply the headmodel
dip_mag_late_som12 = ft_dipolefitting(cfg, meg_data);


%% Do dipole fit: gradiometer fits
cfg = [];
cfg.gridsearch          = 'yes'; %% search the grid for an optimal starting point
cfg.dipfit.metric       = 'rv'; %% the metric to minimize (the relative residual variance: proportion of variance left unexplained by the dipole model)
cfg.model               = 'regional'; %% we assume that the dipole has a fixed position during the time points in the latency range
cfg.senstype            = 'MEG'; %% sensor type
cfg.channel             = 'G'; %% which channels to use
cfg.nonlinear           = 'yes'; %% do a non-linear search

% FIRST COMPONENT
cfg.latency             = early_latency; %% specify the latency
cfg.numdipoles          = 1; %% we only expect contralateral activity
cfg.symmetry            = []; %% empty for single dipole fit

% linear
cfg.sourcemodel.pos     = sourcemodel_lin.pos;
cfg.sourcemodel.inside  = sourcemodel_lin.inside;
cfg.sourcemodel.dim     = sourcemodel_lin.dim;
cfg.headmodel           = headmodel_lin; %% supply the headmodel
dip_grad_early_lin = ft_dipolefitting(cfg, meg_data);

% orig
cfg.sourcemodel.pos     = sourcemodel_orig.pos;
cfg.sourcemodel.inside  = sourcemodel_orig.inside;
cfg.sourcemodel.dim     = sourcemodel_orig.dim;
cfg.headmodel           = headmodel_orig; %% supply the headmodel
dip_grad_early_orig = ft_dipolefitting(cfg, meg_data);

% spm12
cfg.sourcemodel.pos     = sourcemodel_spm12.pos;
cfg.sourcemodel.inside  = sourcemodel_spm12.inside;
cfg.sourcemodel.dim     = sourcemodel_spm12.dim;
cfg.headmodel           = headmodel_spm12; %% supply the headmodel
dip_grad_early_spm12 = ft_dipolefitting(cfg, meg_data);

% SECOND COMPONENT
cfg.latency             = late_latency;
cfg.numdipoles          = 2;    %% we expect bilateral activity
cfg.symmetry            = 'x';

% linear
cfg.sourcemodel.pos     = sourcemodel_lin.pos;
cfg.sourcemodel.inside  = sourcemodel_lin.inside;
cfg.sourcemodel.dim     = sourcemodel_lin.dim;
cfg.headmodel           = headmodel_lin;
dip_grad_late_lin = ft_dipolefitting(cfg, meg_data);

% orig
cfg.sourcemodel.pos     = sourcemodel_lin.pos;
cfg.sourcemodel.inside  = sourcemodel_lin.inside;
cfg.sourcemodel.dim     = sourcemodel_lin.dim;
cfg.headmodel           = headmodel_orig; %% supply the headmodel
dip_grad_late_orig = ft_dipolefitting(cfg, meg_data);

% spm12
cfg.sourcemodel.pos     = sourcemodel_spm12.pos;
cfg.sourcemodel.inside  = sourcemodel_spm12.inside;
cfg.sourcemodel.dim     = sourcemodel_spm12.dim;
cfg.headmodel           = headmodel_spm12; %% supply the headmodel
dip_grad_late_spm12 = ft_dipolefitting(cfg, meg_data);

%% Save
save(fullfile(data_path, 'dip_mag_early.mat'), 'dip_mag_early*')
save(fullfile(data_path, 'dip_mag_late.mat'), 'dip_mag_late*')
save(fullfile(data_path, 'dip_grad_early.mat'), 'dip_grad_early*')
save(fullfile(data_path, 'dip_grad_late.mat'), 'dip_grad_late*')

%% Checks
find(ismember(sourcemodel_spm12.pos, dip_mag_early_spm12.dip.pos))





%END
