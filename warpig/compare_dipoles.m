%% Comparison of dip models
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load data
load(fullfile(data_path, 'dip_mag_early.mat'))
load(fullfile(data_path, 'dip_mag_late.mat'))
load(fullfile(data_path, 'dip_grad_early.mat'))
load(fullfile(data_path, 'dip_grad_late.mat'))

%% Compare dip: mags early component
norm(dip_mag_early_orig.dip.pos-dip_mag_early_lin.dip.pos)

%% Compare dip: mags late component
norm(dip_mag_late_orig.dip.pos(1,:)-dip_mag_late_lin.dip.pos(2,:))

%% Compare dip: grads early component
norm(dip_grad_early_orig.dip.pos-dip_grad_early_lin.dip.pos)
norm(dip_grad_early_orig.dip.pos-dip_grad_early_spm12.dip.pos)
norm(dip_grad_early_spm12.dip.pos-dip_grad_early_lin.dip.pos)

%% Compare dip: grads late component
norm(dip_grad_late_orig.dip.pos(1,:)-dip_grad_late_lin.dip.pos(2,:))
norm(dip_grad_late_orig.dip.pos(1,:)-dip_grad_late_spm12.dip.pos(1,:))
norm(dip_grad_late_spm12.dip.pos(1,:)-dip_grad_late_lin.dip.pos(2,:))


%END

%%
dip_mag_early_orig
dip_mag_early_orig.Vdiff = dip_mag_early_orig.Vdata-dip_mag_early_orig.Vmodel;

cfg = [];
cfg.layout = 'neuromag306mag.lay';
cfg.parameter = 'Vdiff';

figure; ft_multiplotER(cfg, rmfield(dip_mag_early_orig, 'dip'))
