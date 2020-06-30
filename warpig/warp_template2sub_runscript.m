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

%% Step 1: Load subject MRI and save as "template"
% Load the subject anatomical image. Determine coordinate systen (ras, origin not
% a landmark). The nconvert to the desired coordinate system. In this
% example we convert to three different commonly used coordinate systems in
% MEG data analysis; acpc, neuromag, and cft, to test performance. Only one
% of the templates will be used in the folowing MEG data analysis. For
% information on the differenty coordinate systems see http://www.fieldtriptoolbox.org/faq/how_are_the_different_head_and_mri_coordinate_systems_defined/
%
% Only convert of acpc will give correct results at the moment (June 2020).
% There seem to be an error in how SPM calculates the affine alignment for
% coordinate systems not similar to SPM's coordinate system. For analysis I
% will first convert the subject MRI to acpc coordinate system, do the
% template warp, and then convert the warped templte to neuromag for MEG 
% analysis.

% Read MRI
raw_fpath = fullfile(mri_path, '00000001.dcm');
mri_orig = ft_read_mri(raw_fpath);

%Save (optional)
save(fullfile(sub_path, 'mri_orig.mat'), 'mri_raw')

% Define coordinates of raw (r-a-s-n)
mri_coord = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

%% Convert to acpc format
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';  
mri_acpc = ft_volumerealign(cfg, mri_coord);       

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI).
% ONLY THE RESLICED SHOULD (PROBABLY) BE SAVED IN THIS STEP
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc)

% Reslice to new coordinate system
mri_acpc_resliced = ft_volumereslice([], mri_acpc);

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI).
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_acpc_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_acpc_resliced)

%% Convert to Neuromag format
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'neuromag';  
mri_neuromag = ft_volumerealign(cfg, mri_coord);       

% Not that if it gives warnings about left/right it might lead to erross

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI)
% cfg = [];
% cfg.filetype    = 'nifti';          % .nii exntension
% cfg.parameter   = 'anatomy';
% cfg.filename    = fullfile(sub_path,'orig_neuromag');   % Same base filename but different format
% ft_volumewrite(cfg, mri_neuromag)

% Reslice to new coordinate system
mri_neuromag_resliced = ft_volumereslice([], mri_neuromag);

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI).
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_neuromag_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_neuromag_resliced)

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

% Reslice to new coordinate system
mri_ctf_resliced = ft_volumereslice([], mri_ctf);

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI).
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_ctf_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_ctf_resliced)

%% plot (for inspection)
ft_sourceplot([], mri_acpc_resliced); title('orig MRI acpc')
ft_sourceplot([], mri_neuromag_resliced); title('orig MRI neuromag')
ft_sourceplot([], mri_ctf_resliced); title('orig MRI ctf')

%% Step 2: warp a template MRI to the individual "templates"
% In this example we load the Colin27 template (https://www.mcgill.ca/bic/software/tools-data-analysis/anatomical-mri/atlases/colin-27),
% which comes as the standard_mri in FieldTrip. Then use
% ft_volumenormalise to "normalise" the Colin27 template to the indivdual 
% anatomical "templates" created above.
%
% Only convert of acpc will give correct results at the moment (June 2020).
% There seem to be an error in how SPM calculates the affine alignment for
% coordinate systems not similar to SPM's coordinate system. For analysis I
% will first convert the subject MRI to acpc coordinate system, do the
% template warp, and then convert the warped templte to neuromag for MEG 
% analysis.

% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;   % Rename to avoid confusion

%% Normalise template -> subject (acpc subject template)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will  use SPM's default posterior tissue maps,. not the template
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'acpc';      % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_acpc_rs.nii');
mri_temp2sub = ft_volumenormalise(cfg, mri_colin);

% Resture unit information (mm)
mri_temp2sub = ft_determine_units(mri_temp2sub)

% Plot for inspection
ft_sourceplot([],mri_temp2sub); title('Warped2acpc')

%% Normalise template -> subject (neuromag subject template)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'neuromag';  % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_neuromag_rs.nii');
mri_warp2neuromag = ft_volumenormalise(cfg, mri_colin);

% Plot for inspection
ft_sourceplot([],mri_warp2neuromag); title('Warped2neuromag')


%% Normalise template -> subject (ctf subject template)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'ctf';      % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_ctf_rs.nii');
mri_warp2ctf = ft_volumenormalise(cfg, mri_colin);

% Plot for inspection
ft_sourceplot([],mri_warp2ctf); title('Warped2ctf')

%% Save
mri_temp2sub = mri_warp2acpc;       % Rename for now!
fprintf('saving...')
save(fullfile(sub_path,'mri_temp2sub'), 'mri_temp2sub')
fprintf('done\n')

%% Preapre for Freesurfer
% Save in mgz format in a Freesurfer suubject directory to run Freesurfer's
% recon-all later (only works on Linux).
fs_subjdir = '/home/mikkel/mri_scripts/warpig/fs_subjects_dir/';

cfg = [];
cfg.filename    = fullfile(fs_subjdir, subj{1}, 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_temp2sub);


%% THIS IS WHERE THE PROCESSING ENDS.
% It contimues in the script create_headmodel.m

%% Old tests
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