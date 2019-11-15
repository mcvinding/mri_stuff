%% Process MRI for MEG source analysis (compare=
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load
load(fullfile(data_path, 'mri_norm_lin.mat'));         % Linear trans onl
load(fullfile(data_path, 'mri_norm_spm8.mat'));        % SPM8 warped
load(fullfile(data_path, 'mri_norm_spm12.mat'));       % SPM12+new warped
load(fullfile(data_path, 'mri_orig.mat'));             % original subject

%% Determine coordinate system
% mri_coord = ft_determine_coordsys(mri_norm3, 'interactive', 'yes');

%% Redefine normalized MRI to neuromag coordsys
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri_lin_re_1 = ft_volumerealign(cfg, mri_norm_lin);
% mri_smp8_re_1 = ft_volumerealign(cfg, mri_norm_spm8);  % Fails horribly. Full Cronenberg
mri_spm12_re_1 = ft_volumerealign(cfg, mri_norm_spm12);
mri_orig_re_1 = ft_volumerealign(cfg, mri_raw);

% save('Z:\mri_scripts\warpmrig\0362\mri_realigned_1', 'mri_realigned_1');

%% Get headshapes and sensor info
rawfile = fullfile(raw_folder, 'tactile_stim_raw_tsss_mc.fif');
headshape   = ft_read_headshape(rawfile);
grad        = ft_read_sens(rawfile,'senstype','meg'); % Load MEG sensors

%% Aligh to headpoints
cfg = [];
cfg.method              = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp       = 'yes';
cfg.coordsys            = 'neuromag';

mri_lin_re_2 = ft_volumerealign(cfg, mri_lin_re_1);
% mri_smp8_re_2 = ft_volumerealign(cfg, mri_smp8_re_1);
mri_spm12_re_2 = ft_volumerealign(cfg, mri_spm12_re_1);
mri_orig_re_2 = ft_volumerealign(cfg, mri_orig_re_1);

cfg.headshape.icp = 'no';
mri_lin_re_3 = ft_volumerealign(cfg, mri_lin_re_2);
% mri_smp8_re_3 = ft_volumerealign(cfg, mri_smp8_re_2);
mri_spm12_re_3 = ft_volumerealign(cfg, mri_spm12_re_2);
mri_orig_re_3 = ft_volumerealign(cfg, mri_orig_re_2);

%% Reslice (takes a very long time)
cfg = [];
cfg.resolution = 1;
mri_lin_rs = ft_volumereslice(cfg, mri_lin_re_2);
% mri_spm8_rs = ft_volumereslice(cfg, mri_smp8_re_2);
mri_spm12_rs = ft_volumereslice(cfg, mri_spm12_re_2);
mri_orig_rs = ft_volumereslice(cfg, mri_orig_re_2);

%% Save
disp('saving...')
save(fullfile(data_path,'mri_lin_rs.mat'), 'mri_lin_rs');
save(fullfile(data_path,'mri_spm12_rs.mat'), 'mri_spm12_rs');
save(fullfile(data_path,'mri_orig_rs.mat'), 'mri_orig_rs');
disp('done')

%% Seqment MRI for both template and original MRI (orig not iimplemeted, loaded previous from TAP proj instead)
cfg = [];
% cfg.output = {'brain' 'skull' 'scalp'};
cfg.output = 'brain';

mri_lin_seg = ft_volumesegment(cfg, mri_lin_rs);
% mri3_segmented = ft_volumesegment(cfg, mri_spm8_rs);
mri_spm12_seg = ft_volumesegment(cfg, mri_spm12_rs);
mri_orig_seg = ft_volumesegment(cfg, mri_orig_rs);

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
mesh_brain_lin = ft_prepare_mesh(cfg, mri_lin_seg);
mesh_brain_spm12 = ft_prepare_mesh(cfg, mri_spm12_seg);
mesh_brain_orig = ft_prepare_mesh(cfg, mri_orig_seg);

cfg = [];
cfg.method = 'singleshell';
headmodel_lin = ft_prepare_headmodel(cfg, mesh_brain_lin);
headmodel_spm12 = ft_prepare_headmodel(cfg, mesh_brain_spm12);
headmodel_orig = ft_prepare_headmodel(cfg, mesh_brain_orig);

%% SAVE HEADMODELS
save(fullfile(data_path, 'headmodel_lin,mat'), 'headmodel_lin')
save(fullfile(data_path, 'headmodel_spm12,mat'), 'headmodel_spm12')
save(fullfile(data_path, 'headmodel_orig,mat'), 'headmodel_orig')

%% Plot
figure;
ft_plot_mesh(mesh_brain)
