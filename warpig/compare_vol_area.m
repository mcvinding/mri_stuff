%% Comparison of volume headmodels:
% * Volume
% * Surface areas
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load headmodels
% Add a loop over files when testing

load(fullfile(data_path, 'headmodel_lin.mat'))
load(fullfile(data_path, 'headmodel_spm12.mat'))
load(fullfile(data_path, 'headmodel_orig.mat'))

%% Convert to cm for more easy intrepretation of volumes
headmodel_orig = ft_convert_units(headmodel_orig, 'cm');
headmodel_lin = ft_convert_units(headmodel_lin, 'cm');
headmodel_spm12 = ft_convert_units(headmodel_spm12, 'cm');

%% Get volume and surface area
% create vecors for later comparison when testing on multiple datasets.
[~, v_orig] = convhull(headmodel_orig.bnd.pos);
[~, v_lin] = convhull(headmodel_lin.bnd.pos);
[~, v_spm12] = convhull(headmodel_spm12.bnd.pos);

asurf_orig = surfaceArea(alphaShape(headmodel_orig.bnd.pos));
asurf_lin = surfaceArea(alphaShape(headmodel_lin.bnd.pos));
asurf_spm12 = surfaceArea(alphaShape(headmodel_spm12.bnd.pos));

%% 
scatter([v_orig, v_lin, v_spm12], [asurf_orig, asurf_lin, asurf_spm12])


%% Plot headmodels
figure; hold on
ft_plot_headmodel(headmodel_orig, 'facealpha', 0.5, 'facecolor', 'k')
ft_plot_headmodel(headmodel_lin, 'facealpha', 0.5, 'facecolor', 'b')
ft_plot_headmodel(headmodel_spm12, 'facealpha', 0.5, 'facecolor', 'r')



%%  Plot new volume as function of old volume
figure; hold on
scatter(v_orig, v_spm12, 'k','filled')
scatter(v_orig, v_lin, 'b','filled')
xlabel('Original volume (cm^3)'); ylabel('Warped volume (cm^3)');
