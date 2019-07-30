% Warp template MRI to subject MRI and do source reconstruction.
% addpath '~/fieldtrip/fieldtrip/'
% addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

fs_path = '/home/mikkel/PD_motor/fs_subjects_dir';
mri_path = '/home/mikkel/PD_motor/MRI';

%% Options
sub = '0362';  %Change if loop

%% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;

%% Step 1: Convert Load subject MRI (Option 1: from Freesurfer)
% NB: not working on WIN PC

% Read MRI
orig_fpath = fullfile(fs_path,sub,'mri/orig.mgz');
mri_orig = ft_read_mri(orig_fpath);

% Define coordinates
mri_coord = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

% Convert to acpc format [why the two step procedure?]
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri_realigned = ft_volumerealign(cfg, mri_coord);

mri_acap = ft_convert_coordsys(mri_realigned, 'acpc');

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(mri_path,sub,'mri/orig');   % Same base filename but different format
ft_volumewrite(cfg, mri_acap)

% save(fullfile(fs_path,sub,'mri/template_morphed.mgz'));

%% Step 1: Load subject MRI (Option 2: from FieldTrip)

% Read MRI
orig_fpath = fullfile(mri_path,sub,'mri.mat');
load(orig_fpath)

% Define coordinates
mri_coord = ft_determine_coordsys(mri, 'interactive', 'yes');

% Convert to acpc format [why the two step procedure: because finding ac and pc point is difficult]
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri_realigned = ft_volumerealign(cfg, mri_coord);

mri_acap = ft_convert_coordsys(mri_realigned, 'spm');

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(mri_path,sub,'orig');   % Same base filename but different format
ft_volumewrite(cfg, mri_acap)

%% Normalize: template -> subject

% Non-linear normalization
cfg = [];
cfg.template = fullfile(mri_path,sub,'orig.nii');
mri_norm = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison
cfg.nonlinear = 'no';
mri_normL = ft_volumenormalise(cfg, mri_colin);

mri_norm = ft_determine_units(mri_norm);
mri_normL = ft_determine_units(mri_normL);

%% Plot
ft_sourceplot([],mri_colin); title('Colin')
ft_sourceplot([],mri_norm); title('Norm')
ft_sourceplot([],mri_normL); title('Norm (linear)')

ft_sourceplot([],mri_acap); title('Sub')

%% Preapre for Freesurfer
% I have still not tested how the normalized MRI run in Freesurfer.

cfg = [];
cfg.output = 'brain';
seg = ft_volumesegment(cfg, mri_norm);
mri.anatomy = mri.anatomy.*double(seg.brain);

cfg             = [];
cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);


%% Process MRI for MEG source analysis
% Determine coordinate system
mri_coord = ft_determine_coordsys(mri, 'interactive', 'yes');

cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri_realigned_1 = ft_volumerealign(cfg, mri_norm);

save('/home/mikkel/mri_trans_misc/mri_realigned.mat', 'mri_realigned_1');

%
subdir =   '/home/mikkel/PD_motor/rebound/meg_data/0362';
rawfile = '0362_2-ica_raw.fif';
headshape   = ft_read_headshape(fullfile(subdir, rawfile));
grad        = ft_read_sens(fullfile(subdir, rawfile),'senstype','meg'); % Load MEG sensors

cfg = [];
cfg.method  = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.coordsys = 'neuromag';

mri_realigned_2 = ft_volumerealign(cfg, mri_realigned_1);

cfg.headshape.icp = 'no';
mri_realigned_3 = ft_volumerealign(cfg, mri_realigned_2);
    
cfg = [];
cfg.resolution = 1;
mri_resliced = ft_volumereslice(cfg, mri_realigned_2);

save('mri_resliced.mat', 'mri_resliced');
    
cfg = [];
cfg.output = {'brain' 'skull' 'scalp'};

mri_segmented = ft_volumesegment(cfg, mri_resliced);

    cfg = [];
    cfg.funparameter = 'brain';
    ft_sourceplot(cfg, mri_segmented);

    cfg.funparameter = 'skull';
    ft_sourceplot(cfg, mri_segmented);

    cfg.funparameter = 'scalp';
    ft_sourceplot(cfg, mri_segmented);

%         save(fullfile(sub_dir, 'mri_segmented'), 'mri_segmented');

%% CONSTRUCT A BRAIN MESH
cfg = [];
cfg.method      = 'projectmesh';
cfg.tissue      = 'brain';
cfg.numvertices = 3000;
mesh_brain = ft_prepare_mesh(cfg, mri_segmented);

figure;
ft_plot_mesh(mesh_brain)

%         save(fullfile(sub_dir, 'mesh_brain'), 'mesh_brain');

cfg = [];
cfg.method = 'singleshell';
headmodel = ft_prepare_headmodel(cfg, mesh_brain);

