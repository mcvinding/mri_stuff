%% Warp template MRI to subject MRI for creating source model

% ftpath = 'C:\fieldtrip';
ftpath = '/home/mikkel/fieldtrip/fieldtrip';
addpath(ftpath)
addpath(fullfile(ftpath,'external/spm12'))
ft_defaults

%% Paths
% Run on local Windows for better plotting
if ispc
    raw_folder = 'Y:/workshop_source_reconstruction/20180206';
    out_folder = 'Z:/mri_scripts/warpig/data';
else
    raw_folder = '/home/share/workshop_source_reconstruction/20180206';
    out_folder = '/home/mikkel/mri_scripts/warpig/data/';
end

%% Subject
subj = {'0177'};

%% Paths
mri_path = fullfile(raw_folder, 'MRI','dicoms');
sub_path = fullfile(out_folder, subj{1});

%% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;

%% Step 1: Load subject MRI and save as "template"
% Read MRI
raw_fpath = fullfile(mri_path, '00000001.dcm');
mri_orig = ft_read_mri(raw_fpath);

%Save for later
save(fullfile(sub_path, 'mri_orig.mat'), 'mri_raw')

% Define coordinates
mri_coord = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

% Convert to acpc format [why the two step procedure: because finding ac and pc point is difficult]
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';   % Changeing to 'spm' stil converts to 'acpc'
mri_acpc = ft_volumerealign(cfg, mri_coord);       

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI)
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc)

%% Make a resliced version for plotting (and for later processing)
mri_acpc_resliced = ft_volumereslice([], mri_acpc);

%% plot (for inspection)
cfg = [];
cfg.parameter = 'anatomy';
ft_sourceplot(cfg, mri_acpc_resliced); title('MRI acpc')

%% Normalize: template -> subject

% A) Non-linear normalization (SPM8) (Gives Cronenberg image)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
mri_norm_spm8 = ft_volumenormalise(cfg, mri_colin);

% B) Non-linear normalization "new" method (SPM12)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
cfg.spmmethod = 'new';
cfg.spmversion = 'spm12';
mri_norm_spm12 = ft_volumenormalise(cfg, mri_colin);

% Linear normalization for comparison (SPM12 - same as SPM8)
cfg = [];
cfg.nonlinear = 'no';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
cfg.spmversion = 'spm8';
mri_norm_lin = ft_volumenormalise(cfg, mri_colin);


%% Determine coordsys
mri_norm_spm8   = ft_determine_units(mri_norm_spm8);
mri_norm_spm12  = ft_determine_units(mri_norm_spm12);
mri_norm_lin    = ft_determine_units(mri_norm_lin);

%% Plot
cfg = [];
cfg.funparameter = 'anatomy';

ft_sourceplot([],mri_colin); title('Original Colin')
ft_sourceplot([],mri_norm_spm8); title('Norm (non-lienar, SPM8)')
ft_sourceplot([],mri_norm_spm12); title('Norm (non-lienar, SPM12, new method)')
ft_sourceplot([],mri_norm_lin); title('Norm (linear, SPM12)')

ft_sourceplot([],mri_acpc_resliced); title('Original sub')

%% Save template
fprintf('saving...')
save(fullfile(sub_path,'mri_norm_spm8'), 'mri_norm_spm8')
save(fullfile(sub_path,'mri_norm_spm12'),'mri_norm_spm12')
save(fullfile(sub_path,'mri_norm_lin'), 'mri_norm_lin')
fprintf('done\n')

%% Preapre for Freesurfer (nor used)
% I have still not tested how the normalized MRI run in Freesurfer.

% cfg = [];
% cfg.output = 'brain';
% seg = ft_volumesegment(cfg, mri_norm);
% mri.anatomy = mri.anatomy.*double(seg.brain);
% 
% cfg             = [];
% cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
% cfg.filetype    = 'mgz';
% cfg.parameter   = 'anatomy';
% ft_volumewrite(cfg, mri);

% END