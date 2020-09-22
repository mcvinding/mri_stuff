%% Comparison of dip models
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load data
fprintf('loading data... ')
load(fullfile(data_path, 'dip_mag_early.mat'))
load(fullfile(data_path, 'dip_mag_late.mat'))
load(fullfile(data_path, 'dip_grad_early.mat'))
load(fullfile(data_path, 'dip_grad_late.mat'))
load(fullfile(data_path, 'mri_tmp_resliced'));
load(fullfile(data_path, 'mri_org_resliced'));
load(fullfile(data_path, 'mri_org_resliced'));
load(fullfile(data_path, 'dip_mag_all.mat'));
load(fullfile(data_path, 'dip_grad_all.mat'));
disp('done')

%% Compare dip: mags early component
% Distance error
norm(dip_mag_early_orig.dip.pos-dip_mag_early_tmp.dip.pos)

figure; hold on
plot(dip_mag_early_orig.time, dip_mag_early_orig.dip.rv)
plot(dip_mag_early_tmp.time, dip_mag_early_tmp.dip.rv)

figure; hold on
pos = mean(dip_mag_early_tmp.dip.pos,1);
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [1 0 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 1 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_mag_early_tmp.dip.pos, mean(dip_mag_early_tmp.dip.mom,2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_early_orig.dip.pos, mean(dip_mag_early_orig.dip.mom,2), 'size',2, 'unit', 'mm','color','b'); hold on

%% Compare dip: mags late component
norm(dip_mag_late_orig.dip.pos(1,:)-dip_mag_late_tmp.dip.pos(1,:))
norm(dip_mag_late_orig.dip.pos(2,:)-dip_mag_late_tmp.dip.pos(2,:))

figure; hold on
plot(dip_mag_late_orig.time,dip_mag_late_orig.dip.rv)
plot(dip_mag_late_tmp.time,dip_mag_late_tmp.dip.rv)

figure; hold on
pos = mean(dip_mag_late_tmp.dip.pos(1,:),1);
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [1 0 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 1 0]); hold on
ft_plot_slice(mri_tmp_resliced.anatomy, 'transform', mri_tmp_resliced.transform,'location', pos,'orientation', [0 0 1]); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(1,:), mean(dip_mag_late_tmp.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_tmp.dip.pos(2,:), mean(dip_mag_late_tmp.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm'); hold on
ft_plot_dipole(dip_mag_late_orig.dip.pos(1,:), mean(dip_mag_late_orig.dip.mom(1:3,:),2), 'size',2, 'unit', 'mm','color','b'); hold on
ft_plot_dipole(dip_mag_late_orig.dip.pos(2,:), mean(dip_mag_late_orig.dip.mom(4:6,:),2), 'size',2, 'unit', 'mm','color','b'); hold on


%% Compare dip: grads early component
norm(dip_grad_early_orig.dip.pos-dip_grad_early_tmp.dip.pos)

%% Compare dip: grads late component
norm(dip_grad_late_orig.dip.pos(1,:)-dip_grad_late_tmp.dip.pos(1,:))
norm(dip_grad_late_orig.dip.pos(2,:)-dip_grad_late_tmp.dip.pos(2,:))


%% Full time
% Mags
figure; hold on
plot(dip_mag_all_orig.time, dip_mag_all_orig.dip.rv)
plot(dip_mag_all_tmp.time, dip_mag_all_tmp.dip.rv)

figure; hold on
plot(dip_mag_all_orig.time, sqrt(sum(dip_mag_all_orig.dip.mom).^2))
plot(dip_mag_all_tmp.time, sqrt(sum(dip_mag_all_tmp.dip.mom).^2))

dat = [sqrt(sum(dip_mag_all_orig.dip.mom).^2); sqrt(sum(dip_mag_all_tmp.dip.mom).^2)]
a_mag_all = kriAlpha(dat, 'interval')

% Grads
figure; hold on
plot(dip_grad_all_orig.time, dip_grad_all_orig.dip.rv)
plot(dip_grad_all_tmp.time, dip_grad_all_tmp.dip.rv)

figure; hold on
plot(dip_grad_all_orig.time, sqrt(sum(dip_grad_all_orig.dip.mom).^2))
plot(dip_grad_all_tmp.time, sqrt(sum(dip_grad_all_tmp.dip.mom).^2))

dat = [sqrt(sum(dip_grad_all_orig.dip.mom).^2); sqrt(sum(dip_grad_all_tmp.dip.mom).^2)];
a_grad_all = kriAlpha(dat, 'interval');

save(fullfile(data_path, 'a_dips'), 'a_mag_all', 'a_grad_all')


%END