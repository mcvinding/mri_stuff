%% Warp template MRI to subject MRI for creating source model

% ftpath = 'C:\fieldtrip';
ftpath = '/home/mikkel/fieldtrip/fieldtrip';
addpath(ftpath)
% addpath(fullfile(ftpath,'external/spm12'))
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

%% Load tem
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

% Convert to acpc format
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';  
mri_acpc = ft_volumerealign(cfg, mri_coord);       

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI)
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc)


%% Convert to ctf coordsys
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'ctf'; 
mri_ctf = ft_volumerealign(cfg, mri_coord);     

cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_ctf');   % Same base filename but different format
ft_volumewrite(cfg, mri_ctf)

%% Make a resliced version for plotting (and for later processing)
mri_acpc_resliced = ft_volumereslice([], mri_acpc);

%% plot (for inspection)
cfg = [];
cfg.parameter = 'anatomy';
ft_sourceplot(cfg, mri_acpc_resliced); title('MRI acpc')

%% Neuromag coordsys (sandbox)
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';
mri_nromg = ft_volumerealign(cfg, mri_coord);       

cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_neuromag');   % Same base filename but different format
ft_volumewrite(cfg, mri_nromg)

%% Normalize: template -> subject
cfg = [];
cfg.nonlinear   = 'yes';
cfg.spmmethod   = 'new';
% cfg.spmversion  = 'spm8';
% cfg.template    = fullfile(sub_path,'orig_neuromag.nii');
% cfg.template    = fullfile(sub_path,'orig_ctf.nii');
% cfg.templatecoordsys = 'ctf';
% cfg.template = mri_nromg;
mri_warp_def = ft_volumenormalise(cfg, mri_colin);

%% Plot
ft_sourceplot([],mri_warp_ctf); title('Warped CTF')
ft_sourceplot([],mri_warp_nmg); title('Warped Neuromag')
ft_sourceplot([],mri_warp_def); title('Warped defaults')

% Works for both acpc and neuromag nad now cft
tst = ft_convert_coordsys(mri_warp_nmg, 'ctf')

ft_sourceplot([],tst); title('Warped Neuromag')

%%
ft_sourceplot([],tst); 
%%




% A) Non-linear normalization (SPM8) (Gives Cronenberg image)
cfg = [];
cfg.nonlinear = 'yes';
cfg.template = fullfile(sub_path,'orig_acpc.nii');
mri_norm_spm8 = ft_volumenormalise(cfg, mri_colin);

% B) Non-linear normalization "new" method (SPM12)
cfg = [];
cfg.nonlinear   = 'yes';
cfg.template    = fullfile(sub_path,'orig_acpc.nii');
cfg.spmmethod   = 'new';
cfg.spmversion  = 'spm12';
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

%% Preapre for Freesurfer
cfg = [];
cfg.filename = '/home/mikkel/mri_scripts/warpig/fs_subjects_dir/0177_lin/mri/orig/001';
cfg.filetype = 'mgz';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_norm_lin);

cfg = [];
cfg.filename = '/home/mikkel/mri_scripts/warpig/fs_subjects_dir/0177_spm8/mri/orig/001';
cfg.filetype = 'mgz';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_norm_spm8);

cfg = [];
cfg.filename = '/home/mikkel/mri_scripts/warpig/fs_subjects_dir/0177_spm12/mri/orig/001';
cfg.filetype = 'mgz';
cfg.parameter = 'anatomy';
ft_volumewrite(cfg, mri_norm_spm12);


% cfg = [];
% cfg.output = 'brain';
% seg = ft_volumesegment(cfg, mri_norm_lin);
% mri.anatomy = mri.anatomy.*double(seg.brain);
% 
% cfg             = [];
% cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
% cfg.filetype    = 'mgz';
% cfg.parameter   = 'anatomy';
% ft_volumewrite(cfg, mri);
% 
% cfg = [];
% cfg.output = 'brain';
% seg = ft_volumesegment(cfg, mri_norm_lin);
% mri.anatomy = mri.anatomy.*double(seg.brain);
% 
% cfg             = [];
% cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
% cfg.filetype    = 'mgz';
% cfg.parameter   = 'anatomy';
% ft_volumewrite(cfg, mri);
% 
% cfg = [];
% cfg.output = 'brain';
% seg = ft_volumesegment(cfg, mri_norm_lin);
% mri.anatomy = mri.anatomy.*double(seg.brain);
% 
% cfg             = [];
% cfg.filename    = 'workshop_material/data/mri/freesurfer/Sub02/sub02mask';
% cfg.filetype    = 'mgz';
% cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri);

% END