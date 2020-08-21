%% Comparison of volume headmodels:
% * Volume
% * Surface areas
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load headmodels
% Add a loop over files when testing

load(fullfile(data_path, 'headmodel_tmp.mat'))
load(fullfile(data_path, 'headmodel_org.mat'))

%% Convert to cm for more easy intrepretation of volumes
headmodel_tmp = ft_convert_units(headmodel_tmp, 'cm');
headmodel_org = ft_convert_units(headmodel_org, 'cm');

%% Get volume and surface area
% create vecors for later comparison when testing on multiple datasets.
[~, v_org] = convhull(headmodel_org.bnd.pos);
[~, v_tmp] = convhull(headmodel_tmp.bnd.pos);

asurf_org = surfaceArea(alphaShape(headmodel_org.bnd.pos));
asurf_tmp = surfaceArea(alphaShape(headmodel_tmp.bnd.pos));

%% 
scatter([v_org, v_tmp], [asurf_org, asurf_tmp])

%% Plot headmodels
figure; hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.5, 'facecolor', 'k')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'b')

%%  Plot new volume as function of old volume
figure; hold on
scatter(v_org, v_tmp, 'b','filled')
xlabel('Original volume (cm^3)'); ylabel('Warped volume (cm^3)');

%END