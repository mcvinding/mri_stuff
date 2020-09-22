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
load(fullfile(data_path, 'headmodel_tmp.mat'));
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'grad'));    % !!!

disp('Done');

data = timelockeds{4};   % Only indexfinger stim.

%% Plot topographies
cfg = [];
cfg.layout = 'neuromag306mag';
figure; ft_multiplotER(cfg, data);

% cfg = [];
% cfg.viewmode = 'butterfly';
% cfg.channels = 'grad'
% figure; ft_databrowser(cfg, data)

%% Settings
early_latency   = [0.050 0.075]; % s
late_latency    = [0.115 0.155]; % s

cfg = [];
cfg.channel = 'MEG*';
meg_data = ft_selectdata(cfg, data);
meg_data.grad = ft_convert_units(grad, 'mm');

%% Plot alignment
figure; hold on
ft_plot_sens(grad, 'unit', 'mm');
ft_plot_headmodel(headmodel_org)
ft_plot_headmodel(headmodel_tmp)

%% Do dipole fit: magnetometer fits
cfg = [];
cfg.gridsearch      = 'yes';
cfg.dipfit.metric   = 'rv';
cfg.model           = 'regional';
cfg.senstype        = 'MEG';
cfg.channel         = 'megmag';
cfg.nonlinear       = 'yes';

% FIRST COMPONENT
cfg.latency         = early_latency;
cfg.numdipoles      = 1;
cfg.symmetry        = [];

% template
cfg.headmodel       = headmodel_tmp;
dip_mag_early_tmp = ft_dipolefitting(cfg, meg_data);

% orig
cfg.headmodel       = headmodel_org;
dip_mag_early_orig = ft_dipolefitting(cfg, meg_data);

% SECOND COMPONENT
cfg.latency         = late_latency;
cfg.numdipoles      = 2;    %% we expect bilateral activity
cfg.symmetry        = 'x';

% template
cfg.headmodel       = headmodel_tmp;
dip_mag_late_tmp = ft_dipolefitting(cfg, meg_data);

% orig
cfg.headmodel       = headmodel_org; 
dip_mag_late_orig = ft_dipolefitting(cfg, meg_data);

disp('done')

%% Do dipole fit: gradiometer fits
cfg = [];
cfg.gridsearch      = 'yes';            % search the grid for an optimal starting point
cfg.dipfit.metric   = 'rv';             % the metric to minimize (the relative residual variance: proportion of variance left unexplained by the dipole model)
cfg.model           = 'regional';       % assume that the dipole has a fixed position during the time points in the latency range
cfg.senstype        = 'MEG';            % sensor type
cfg.channel         = 'meggrad';        % which channels to use
cfg.grad            = grad;
cfg.nonlinear       = 'yes';            % do a non-linear search

% FIRST COMPONENT
cfg.latency         = early_latency;    % specify the latency
cfg.numdipoles      = 1;                % we only expect contralateral activity
cfg.symmetry        = [];               % empty for single dipole fit

% template
cfg.headmodel       = headmodel_tmp;
dip_grad_early_tmp = ft_dipolefitting(cfg, meg_data);

% orig
cfg.headmodel       = headmodel_org;
dip_grad_early_orig = ft_dipolefitting(cfg, meg_data);

% SECOND COMPONENT
cfg.latency         = late_latency;
cfg.numdipoles      = 2;                
cfg.symmetry        = 'x';              % bilateral symetry

% template
cfg.headmodel       = headmodel_tmp;
dip_grad_late_tmp = ft_dipolefitting(cfg, meg_data);

% orig
cfg.headmodel       = headmodel_org;
dip_grad_late_orig = ft_dipolefitting(cfg, meg_data);

disp('done')

%% Save
fprintf('Saving... ')
save(fullfile(data_path, 'dip_mag_early.mat'),  'dip_mag_early*')
save(fullfile(data_path, 'dip_mag_late.mat'),   'dip_mag_late*')
save(fullfile(data_path, 'dip_grad_early.mat'), 'dip_grad_early*')
save(fullfile(data_path, 'dip_grad_late.mat'),  'dip_grad_late*')
disp('done')

%% Whole window
% general settings (grads)
cfg = [];
cfg.gridsearch     = 'no';
cfg.dipfit.metric  = 'rv';
cfg.model          = 'regional';
cfg.senstype       = 'MEG';
cfg.channel        = 'meggrad';
cfg.grad           = grad;
cfg.nonlinear      = 'no';
cfg.latency        = [0.000; 0.500];

% Original
cfg.headmodel      = headmodel_org; 
cfg.dip.pos        = dip_grad_early_orig.dip.pos;
dip_grad_all_orig = ft_dipolefitting(cfg, meg_data);

% Template
cfg.headmodel           = headmodel_tmp; 
cfg.dip.pos             = dip_grad_early_tmp.dip.pos;
dip_grad_all_tmp = ft_dipolefitting(cfg, meg_data);

% Inspect
figure; hold on
plot(dip_grad_all_orig.time, sqrt(mean(dip_grad_all_orig.dip.mom.^2)))
plot(dip_grad_all_tmp.time, sqrt(mean(dip_grad_all_tmp.dip.mom.^2)))

% General settings (mags)
cfg = [];
cfg.gridsearch      = 'no';
cfg.dipfit.metric   = 'rv';
cfg.model           = 'regional';
cfg.senstype        = 'MEG';
cfg.channel         = 'megmag';
cfg.grad            = grad;
cfg.nonlinear       = 'no';
cfg.latency         = [0.000; 0.500];

% Original
cfg.headmodel       = headmodel_org;
cfg.dip.pos         = dip_mag_early_orig.dip.pos;
dip_mag_all_orig = ft_dipolefitting(cfg, meg_data);

% Template
cfg.headmodel       = headmodel_tmp;
cfg.dip.pos         = dip_mag_early_tmp.dip.pos;
dip_mag_all_tmp = ft_dipolefitting(cfg, meg_data);

% Inspect
figure; hold on
plot(dip_mag_all_orig.time, sqrt(mean(dip_mag_all_orig.dip.mom.^2)))
plot(dip_mag_all_tmp.time, sqrt(mean(dip_mag_all_tmp.dip.mom.^2)))

%% SAVE
fprintf('Saving... ')
save(fullfile(data_path, 'dip_mag_all.mat'),   'dip_mag_all*')
save(fullfile(data_path, 'dip_grad_all.mat'),  'dip_grad_all*')
disp('done')

%END