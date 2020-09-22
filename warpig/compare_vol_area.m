%% Comparison of volume headmodels:
% * Volume
% * Surface areas
addpath '~/fieldtrip/fieldtrip/'
ft_defaults

%% Paths
subjs = {'0177','MC','RO'};

subj = 2;

data_path  = fullfile('/home/mikkel/mri_scripts/warpig/data/',subjs{subj});

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

%% Plot headmodels
figure; hold on
ft_plot_headmodel(headmodel_org, 'facealpha', 0.5, 'facecolor', 'k')
ft_plot_headmodel(headmodel_tmp, 'facealpha', 0.5, 'facecolor', 'b')

%%  Plot new volume as function of old volume
figure; hold on
scatter(v_org, v_tmp, 'b','filled')
xlabel('Original volume (cm^3)'); ylabel('Warped volume (cm^3)');

%% Compare brainmasks
fprintf('loading data... ')
load(fullfile(data_path,'mri_orig_seg.mat'))
load(fullfile(data_path,'mri_tmp_seg.mat'))
disp('done')

x = mri_orig_seg.brain(:);
y = mri_tmp_seg.brain(:);

mean(x==y);

dat = [x'; y'];

fprintf('Calculating alpha... ')
a_brainmask(subj) = kriAlpha(dat, 'nominal');
disp('done')

save(fullfile(data_path,'a_brainmask'), 'a_brainmask')

%END