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
subjs = {'0177','MC','RO'};

%% Paths
mri_path = fullfile(raw_folder, 'MRI','dicoms');
sub_path = fullfile(out_folder, subjs{1});

%% STEP 1A: Load subject MRI and save as "template"
% Load the subject anatomical image. Determine coordinate systen (ras, origin not
% a landmark).

% Read MRI
raw_fpath = fullfile(mri_path, '00000001.dcm');
mri_orig = ft_read_mri(raw_fpath);

% Define coordinates of raw (r-a-s-n)
mri_orig = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

%Save (for later comparison)
save(fullfile(sub_path, 'mri_orig.mat'), 'mri_orig')

%% Alternative MRI #1
load('/home/mikkel/mri_scripts/warpig/warptest/mri1.mat')
mri_orig = mri1;
sub_path = fullfile(out_folder, subjs{2});

%% Alternative MRI #2
load('/home/mikkel/mri_scripts/warpig/warptest/mri2.mat')
mri_orig = mri2;
sub_path = fullfile(out_folder, subjs{3});

%% Convert subject MRI to acpc coordinate system
% Convert to the desired coordinate system. In this e example we convert to
% three different commonly used coordinate systems in % MEG data analysis; 
% acpc, neuromag, and cft, to test performance. Only one % of the templates
% will be used in the folowing MEG data analysis. For % information on the
% differenty coordinate systems see: http://www.fieldtriptoolbox.org/faq/how_are_the_different_head_and_mri_coordinate_systems_defined/

% Align to acpc coordinate system.
cfg = [];
cfg.method = 'interactive';
cfg.coordsys = 'acpc';  
mri_acpc = ft_volumerealign(cfg, mri_orig);       

% Not that if it gives warnings about left/right it might lead to erros

% Reslice to new coordinate system
mri_acpc_resliced = ft_volumereslice([], mri_acpc);

% Plot for inspection
ft_sourceplot([], mri_acpc_resliced); title('orig MRI acpc')

%Save
fprintf('saving...'); save(fullfile(sub_path,'mri_acpc_resliced'), 'mri_orig'); disp('done')

%% Write subject volume as the "template". 
% The template anatomy should always be stored in a SPM-compatible file (i.e.
% NIFTI).
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

% Not that if it gives warnings about left/right it might lead to erros

% Reslice to new coordinate system
mri_neuromag_resliced = ft_volumereslice([], mri_neuromag);

% Save subject volume as the "template". The template anatomy should always
% be stored in a SPM-compatible file (i.e. NIFTI).
cfg = [];
cfg.filetype    = 'nifti';          % .nii exntension
cfg.parameter   = 'anatomy';
cfg.filename    = fullfile(sub_path,'orig_neuromag_rs');   % Same base filename but different format
ft_volumewrite(cfg, mri_neuromag_resliced)
% 
% %% Convert to ctf coordsys
% cfg = [];
% cfg.method = 'interactive';
% cfg.coordsys = 'ctf'; 
% mri_ctf = ft_volumerealign(cfg, mri_coord);     
% 
% % Reslice to new coordinate system
% mri_ctf_resliced = ft_volumereslice([], mri_ctf);
% 
% % Save subject volume as the "template". The template anatomy should always
% % be stored in a SPM-compatible file (i.e. NIFTI).
% cfg = [];
% cfg.filetype    = 'nifti';          % .nii exntension
% cfg.parameter   = 'anatomy';
% cfg.filename    = fullfile(sub_path,'orig_ctf_rs');   % Same base filename but different format
% ft_volumewrite(cfg, mri_ctf_resliced)

%% STEP 2: warp a template MRI to the individual "templates"
% In this example we load the Colin27 template (https://www.mcgill.ca/bic/software/tools-data-analysis/anatomical-mri/atlases/colin-27),
% which comes as the standard_mri in FieldTrip. Then use
% ft_volumenormalise to "normalise" the Colin27 template to the indivdual 
% anatomical "templates" created above.

% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;   % Rename to avoid confusion

%% Normalise template -> subject (acpc subject template)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will  use SPM's default posterior tissue maps not the template
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'acpc';      % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_acpc_rs.nii');
mri_warp2acpc = ft_volumenormalise(cfg, mri_colin);

% Determine unit of volume (mm)
mri_warp2acpc = ft_determine_units(mri_warp2acpc);

% Plot for inspection
ft_sourceplot([],mri_warp2acpc); title('Warped template to subject')
saveas(gcf, fullfile(sub_path, ['template2',cfg.templatecoordsys,'.pdf']))
close
      
%% Normalise template -> subject (neuromag subject template)
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'neuromag';  % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_neuromag_rs.nii');
mri_warp2neuromag = ft_volumenormalise(cfg, mri_colin);

% Determine unit of volume (mm)
mri_warp2neuromag = ft_determine_units(mri_warp2neuromag);

% Plot for inspection
ft_sourceplot([],mri_warp2neuromag); title('Warped2neuromag')
saveas(gcf, fullfile(sub_path, ['template2',cfg.templatecoordsys,'.pdf']))
close
      
%% Normalise template -> subject (ctf subject template)
% Something is wrong in the initial alignment and how SPM use this to
% calculate the inital Affine alignment.
cfg = [];
cfg.nonlinear        = 'yes';       % Non-linear warping
cfg.spmmethod        = 'old';       % Note: method = "new" will only use SPM's default posterior tissue maps.
cfg.spmversion       = 'spm12';     % Default = "spm12"
cfg.templatecoordsys = 'ctf';       % Coordinate system of the template
cfg.template         = fullfile(sub_path,'orig_ctf_rs.nii');
mri_warp2ctf = ft_volumenormalise(cfg, mri_colin);

% Determine unit of volume (mm)
mri_warp2ctf = ft_determine_units(mri_warp2ctf);

% Plot for inspection
ft_sourceplot([],mri_warp2ctf); title('Warped2ctf')

%% Save
fprintf('saving...')
save(fullfile(sub_path,'mri_warp2acpc'), 'mri_warp2acpc')
% save(fullfile(sub_path,'mri_warp2ctf'), 'mri_warp2ctf')
% save(fullfile(sub_path,'mri_warp2neuromag'), 'mri_warp2neuromag')
disp('done')

%% Preapre for Freesurfer
% Save in mgz format in a Freesurfer suubject directory to run Freesurfer's
% recon-all later (only works on Linux).
load(fullfile(sub_path,'mri_warp2acpc.mat'))
load(fullfile(sub_path, 'mri_orig.mat'))

fs_subjdir = '/home/mikkel/mri_scripts/warpig/fs_subjects_dir/';

% Warped
cfg = [];
cfg.filename    = fullfile(fs_subjdir, '0177warp', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_warp2acpc);

% Origninal
cfg = [];
cfg.filename    = fullfile(fs_subjdir, '0177', 'mri','orig', '001');
cfg.filetype    = 'mgz';
cfg.parameter   = 'anatomy';
ft_volumewrite(cfg, mri_orig);

% END