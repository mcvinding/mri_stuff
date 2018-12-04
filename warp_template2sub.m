% Warp template MRI to subject MRI and do source reconstruction.
% addpath '~/fieldtrip/fieldtrip/'
% addpath '~/fieldtrip/fieldtrip/external/mne'

if ispc
    addpath C:\Users\Mikkel\Documents\MATLAB
    [dirs, sub_info, lh_subs] = PD_proj_setup_WIN('tap');
    addpath C:\fieldtrip\external\mne
    mri_path = 'Z:\PD_motor\fs_subjects_dir';
    out_path = 'Z:\PD_motor\MRI';
else
    addpath /home/mikkel/PD_motor/global_scripts
    [dirs, sub_info, lh_subs] = PD_proj_setup('tap');
    mri_path = '/home/mikkel/PD_motor/fs_subjects_dir';
    out_path = '/home/mikkel/PD_motor/MRI'; 
end

ft_defaults

rawmri_path = '..';
fs_path = '/home/mikkel/PD_motor/fs_subjects_dir';
% fs_path = 'Z:\PD_motor\fs_subjects_dir'
% mri_outpath = 
sub = '0362';  %Change if loop

%% Load template MRI
load standard_mri  % Load Colin 27
mri_colin = mri;

%% Load subject MRI (Not working on WIN PC)
% dicom_name = '00000001.dcm';
% dicom_path = fullfile(rawmri_path, 'dicoms', subjects{1}, dicom_name);

orig_fpath = fullfile(fs_path,sub,'mri/orig.mgz');
 
mri_orig = ft_read_mri(orig_fpath);

mri_coord = ft_determine_coordsys(mri_orig, 'interactive', 'yes');

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
cfg.filename    = fullfile(fs_path,sub,'mri/orig');   % Same base filename but different format
ft_volumewrite(cfg, mri_acap)

save(fullfile(fs_path,sub,'mri/template_morphed.mgz'));

%% Normalize
mri_orig = ft_read_mri(fullfile(fs_path,sub,'mri/orig.nii'));

cfg = [];
cfg.template = fullfile(fs_path,sub,'mri/orig.nii');
mri_norm = ft_volumenormalise(cfg, mri_colin);

cfg.nonlinear = 'no';
mri_normL = ft_volumenormalise(cfg, mri_colin);

mri_norm = ft_determine_units(mri_norm);
mri_normL = ft_determine_units(mri_normL);

%% Plot
ft_sourceplot([],mri_colin); title('Colins')
ft_sourceplot([],mri_norm); title('Norm')
ft_sourceplot([],mri_normL); title('Norm (linear)')

ft_sourceplot([],mri_coord); title('Sub')

%% Preapre for Freesurfer (testing)
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

