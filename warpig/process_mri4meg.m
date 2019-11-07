%% Process MRI for MEG source analysis (compare=
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

data_path = '/home/mikkel/mri_scripts/warpmrig/data/0362';

%% Load
load(fullfile(data_path, 'mri_norm1.mat'));         % SPM8 warped
load(fullfile(data_path, 'mri_norm3.mat'));         % SPM12+new warped
load(fullfile(data_path, 'mri_normL.mat'));         % Linear trans only
load(fullfile(data_path, 'mri_resliced.mat'));      % original subject

%% Determine coordinate system
% mri_coord = ft_determine_coordsys(mri_norm3, 'interactive', 'yes');

%% Redefine normalized MRI to neuromag coordsys
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri1_realigned_1 = ft_volumerealign(cfg, mri_norm1);
mri3_realigned_1 = ft_volumerealign(cfg, mri_norm3);
mriL_realigned_1 = ft_volumerealign(cfg, mri_normL);
mri0_realigned_1 = ft_volumerealign(cfg, mri_resliced);


% save('Z:\mri_scripts\warpmrig\0362\mri_realigned_1', 'mri_realigned_1');

%% Get headshapes and sensor info
subdir =   '/home/mikkel/PD_motor/rebound/meg_data/0362';
rawfile = '0362_2-ica_raw.fif';
headshape   = ft_read_headshape(fullfile(subdir, rawfile));
grad        = ft_read_sens(fullfile(subdir, rawfile),'senstype','meg'); % Load MEG sensors

%% Aligh to headpoints
cfg = [];
cfg.method  = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.coordsys = 'neuromag';

mri1_realigned_2 = ft_volumerealign(cfg, mri1_realigned_1);
mri3_realigned_2 = ft_volumerealign(cfg, mri3_realigned_1);
mriL_realigned_2 = ft_volumerealign(cfg, mriL_realigned_1);
mri0_realigned_2 = ft_volumerealign(cfg, mri0_realigned_1);

cfg.headshape.icp = 'no';
mri1_realigned_3 = ft_volumerealign(cfg, mri1_realigned_2);
mri3_realigned_3 = ft_volumerealign(cfg, mri3_realigned_2);
mriL_realigned_3 = ft_volumerealign(cfg, mriL_realigned_2);
mri0_realigned_3 = ft_volumerealign(cfg, mri0_realigned_2);

%% Reslice (takes a very long time)
cfg = [];
cfg.resolution = 1;
mri1_resliced = ft_volumereslice(cfg, mri1_realigned_2);
mri3_resliced = ft_volumereslice(cfg, mri3_realigned_2);
mriL_resliced = ft_volumereslice(cfg, mriL_realigned_2);
mri0_resliced = ft_volumereslice(cfg, mri0_realigned_2);

%% Save
save(fullfile(data_path,'mri1_resliced.mat'), 'mri1_resliced');
save(fullfile(data_path,'mri3_resliced.mat'), 'mri3_resliced');
save(fullfile(data_path,'mriL_resliced.mat'), 'mriL_resliced');
save(fullfile(data_path,'mri0_resliced.mat'), 'mri0_resliced');

%% Seqment MRI for both template and original MRI (orig not iimplemeted, loaded previous from TAP proj instead)
cfg = [];
% cfg.output = {'brain' 'skull' 'scalp'};
cfg.output = 'brain';

mri1_segmented = ft_volumesegment(cfg, mri1_resliced);
mri3_segmented = ft_volumesegment(cfg, mri3_resliced);
mriL_segmented = ft_volumesegment(cfg, mriL_resliced);
mri0_segmented = ft_volumesegment(cfg, mri0_resliced);

% mri_segmented_org = ft_volumesegment(cfg, mri_resliced_);

%     cfg = [];
%     cfg.funparameter = 'brain';
%     ft_sourceplot(cfg, mri_segmented);

%     cfg.funparameter = 'skull';
%     ft_sourceplot(cfg, mri_segmented);
% 
%     cfg.funparameter = 'scalp';
%     ft_sourceplot(cfg, mri_segmented);

%         save(fullfile(sub_dir, 'mri_segmented'), 'mri_segmented');

%% CONSTRUCT A BRAIN MESH AND HEADMODEL
cfg = [];
cfg.method      = 'projectmesh';
cfg.tissue      = 'brain';
cfg.numvertices = 3000;
mesh_brain1 = ft_prepare_mesh(cfg, mri1_segmented);
mesh_brain3 = ft_prepare_mesh(cfg, mri3_segmented);
mesh_brainL = ft_prepare_mesh(cfg, mriL_segmented);
mesh_brain0 = ft_prepare_mesh(cfg, mri0_segmented);

cfg = [];
cfg.method = 'singleshell';
headmodel1 = ft_prepare_headmodel(cfg, mesh_brain1);
headmodel3 = ft_prepare_headmodel(cfg, mesh_brain3);
headmodelL = ft_prepare_headmodel(cfg, mesh_brainL);
headmodel0 = ft_prepare_headmodel(cfg, mesh_brain0);

%% SAVE HEADMODELS

%% Plot
figure;
ft_plot_mesh(mesh_brain)
