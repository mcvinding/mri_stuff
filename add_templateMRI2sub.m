% Fitting and scaling of the template (Colin 27) MRI to the 
% polhemus headshape. Testin different options. Option 4 seems like to most
% optimal solution.
% Put template in Freesurfer fs_subjects_dir to run Freesurfer pipeline.
clear all;
close all;
restoredefaultpath
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

load standard_mri %Colin 27 template in fieldtrip
mri_colin = mri;

%% Init.
sub = '0327'; % Subject without MRI
overwrite = 1;

%% Load data
meg_file = fullfile(dirs.megDir,sub,'0327_tap_1-ica_raw.fif');
% read MEG sensor location
MEG_sens = ft_read_sens(meg_file);
MEG_sens = ft_convert_units(MEG_sens,'mm');
% read polhemus headshape
headshape = ft_read_headshape(meg_file);
headshape   = ft_convert_units(headshape,'mm');

ft_plot_sens(MEG_sens); hold on
ft_plot_headshape(headshape)

save headshape headshape
save MEG_sens MEG_sens

%% %%%%%%%%%%%%%%%%%%  Option 1: Spherical scaling  %%%%%%%%%%%%%%%%%%%%%%%
% Based on script found at: http://www.fieldtriptoolbox.org/example/sphere_fitting_and_scaling_of_the_template_colin_27_mri_to_the_meg_polhemus_headshape)
% realign to neuromag coordinate system
lpa=    [  7 104  26]; 
nas=    [ 92 210  32];
rpa=    [176 104  26];
zpoint= [ 92 106 139];

cfg                = [];
cfg.method         = 'fiducial';
cfg.fiducial.nas    = nas;
cfg.fiducial.lpa    = lpa;
cfg.fiducial.rpa    = rpa;
cfg.fiducial.zpoint = zpoint;
cfg.coordsys       = 'neuromag';
mri_realigned_fiducial      = ft_volumerealign(cfg,mri);

cfg           = [];
cfg.output    = {'brain','skull','scalp'};
segmentedmri  = ft_volumesegment(cfg, mri);

T_neuromag = mri_realigned_fiducial.transform;
segmentedmri.transform = T_neuromag;
segmentedmri.coordsys = 'neuromag';

cfg             = [];
cfg.tissue      = {'brain'};
cfg.numvertices = 3600;
brain           = ft_prepare_mesh(cfg, segmentedmri);

cfg             = [];
cfg.tissue      = {'scalp'};
cfg.numvertices = 3600;
bnd             = ft_prepare_mesh(cfg, segmentedmri);

save('template_meshes.mat','brain','bnd')

%% Deface and remove face points, to make it more "spherical".
% remove the lower part of the head
cfg = [];
cfg.translate = [0 0 -140];
cfg.scale = [300 300 300];
cfg.selection =' outside';
bnd_deface = ft_defacemesh(cfg,bnd);

% remove digitized head points on the nose
cfg = [];
cfg.translate = [0 90 -50];
cfg.scale = [400 400 100];
cfg.selection = 'outside';
headshape_denosed = ft_defacemesh(cfg,headshape);

% Plot for inspection
figure
ft_plot_headshape(headshape);
hold on
ft_plot_mesh(bnd_deface, 'edgecolor', 'none', 'facecolor', 'skin', 'facealpha',0.9)
ft_plot_mesh(brain, 'edgecolor', 'none', 'facecolor', [1 0 1]/1.2, 'facealpha',  0.5)
ft_plot_axes(headshape_denosed)
camlight left
camlight right
material dull
alpha 0.8
lighting phong


%% Spherical fit
%fit a sphere to MRI template
cfg=[];
cfg.method='singlesphere';
scalp_sphere=ft_prepare_headmodel(cfg,bnd_deface);

%fit a sphere to polhemus headshape
cfg=[];
cfg.method='singlesphere';
headshape_sphere=ft_prepare_headmodel(cfg,headshape_denosed);

%scale the template MRI
scale=headshape_sphere.r/scalp_sphere.r;

T2=[1 0 0 scalp_sphere.o(1);
    0 1 0 scalp_sphere.o(2);
    0 0 1 scalp_sphere.o(3);
    0 0 0 1                ];

T1=[1 0 0 -scalp_sphere.o(1);
    0 1 0 -scalp_sphere.o(2);
    0 0 1 -scalp_sphere.o(3);
    0 0 0 1                 ];

S= [scale 0 0 0;
    0 scale 0 0;
    0 0 scale 0;
    0 0 0 1 ];

TRANSFORM=T1*S*T2;

segmentedmri.transform = TRANSFORM*T_neuromag;

cfg             = [];
cfg.tissue      = {'scalp'};
cfg.numvertices = 3300;
scalp_scaled    = ft_prepare_mesh(cfg, segmentedmri);

cfg             = [];
cfg.tissue      = {'brain'};
cfg.numvertices = 3300;
brain_scaled    = ft_prepare_mesh(cfg, segmentedmri);

figure
%ft_plot_sens(MEG_sens, 'style', '*b');
ft_plot_headshape(headshape_denosed);
hold on
ft_plot_mesh(scalp_scaled, 'edgecolor', 'none', 'facecolor', [1 1 1]/1.2, 'facealpha',  0.5)
ft_plot_mesh(brain_scaled, 'edgecolor', 'none', 'facecolor', [1 0 1]/1.2, 'facealpha',  0.5)
ft_plot_axes(headshape_denosed)
camlight left
camlight right
material dull
alpha 0.8
lighting phong

%% %%%%%%%%%%%%%%%%%%  Option 2: Plain alignment  %%%%%%%%%%%%%%%%%%%%%%%
% Use ft_volumerealign. Somehow this is actually working, but only because
% template and subject has approximatly same headsize.

cfg = [];
cfg.method = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.viewresult = 'yes';
cfg.coordsys = 'neuromag';
mri_align = ft_volumerealign(cfg, mri_colin);

cfg.headshape.icp = 'no';
mri_align = ft_volumerealign(cfg, mri_align); % Rotated 8 deg around Z-axis

cfg           = [];
cfg.output    = {'brain','scalp'};
segmri_align  = ft_volumesegment(cfg, mri_align);

cfg             = [];
cfg.tissue      = {'scalp'};
cfg.numvertices = 3300;
scalp_align    = ft_prepare_mesh(cfg, segmri_align);

cfg             = [];
cfg.tissue      = {'brain'};
cfg.numvertices = 3300;
brain_align    = ft_prepare_mesh(cfg, segmri_align);

figure
%ft_plot_sens(MEG_sens, 'style', '*b');
ft_plot_headshape(headshape);
hold on
ft_plot_mesh(scalp_align, 'edgecolor', 'none', 'facecolor', [1 1 1]/1.2, 'facealpha',  0.5)
ft_plot_mesh(brain_align, 'edgecolor', 'none', 'facecolor', [1 0 1]/1.2, 'facealpha',  0.5)
ft_plot_axes(headshape)
camlight left
camlight right
material dull
alpha 0.8
lighting phong

save('mri_align.mat','mri_align')
save('alignd_meshes.mat','scalp_align','brain_align')

%% %%%%%%%%%%% Option 3: Morph volume (not good option) %%%%%%%%%%%%%%%%%%%
cfg = [];
cfg.method = 'headshape';
cfg.headshape = headshape_denosed.pos;
hs = ft_prepare_mesh(cfg);

cfg = [];
cfg.method = 'singleshell';
hm = ft_prepare_headmodel(cfg, hs);

ft_plot_vol(hm)

% Make grid mimicking mri
cfg  = [];
cfg.grid.dim        = mri.dim;
cfg.grid.resolution = 1;
cfg.grid.unit       = mri.unit;
cfg.headmodel       = hm;
grid = ft_prepare_sourcemodel(cfg);

fake_mri.dim        = grid.dim;
fake_mri.anatomy    = reshape(grid.inside, grid.dim);
fake_mri.unit       = grid.unit;
fake_mri.coordsys   = 'neuromag';
fake_mri.transform  = eye(4);

fake_mri = ft_determine_coordsys(fake_mri)

ft_sourceplot([],fake_mri)

fake_mri_acpc = ft_convert_coordsys(fake_mri,'acpc')

cfg = [];
cfg.resolution = 1;
fake_mri_reslice = ft_volumereslice(cfg, fake_mri_acpc)

ft_sourceplot([],fake_mri_acpc)

cfg = [];
cfg.parameter = 'anatomy';
cfg.fiducial.nas  = headshape.fid.pos(2,:); %[x y z] position of nasion
cfg.fiducial.lpa  = headshape.fid.pos(1,:); %[x y z] position of LPA
cfg.fiducial.rpa  = headshape.fid.pos(3,:); %[x y z] position of RPA
cfg.filename = 'fake_mri2';
cfg.filetype = 'nifti';
ft_volumewrite(cfg, fake_mri_acpc)

% Warp
cfg = [];
cfg.template = 'fake_mri2.nii';
mri_norm = ft_volumenormalise(cfg, mri_colin);

cfg.nonlinear = 'no';
mri_normL = ft_volumenormalise(cfg, mri_colin);

mri_norm = ft_determine_units(mri_norm);
mri_normL = ft_determine_units(mri_normL);

%Plot (not so good morphing)
ft_sourceplot([],mri_colin); title('Colins')
ft_sourceplot([],mri_norm); title('Norm')
ft_sourceplot([],mri_normL); title('Norm (linear)')

ft_sourceplot([],mri_coord); title('Sub')

%% %%%%%%%%%%%% Option 4: Manual scaling (the best option) %%%%%%%%%%%%%%%%
cfg = [];
cfg.individual.mri = mri_colin;
cfg.template.headshape = headshape;
ft_interactiverealign(cfg)

% Manually align
col_intalign = ft_transform_geometry(mri_intalign.m,mri_colin);

% Plot
ft_sourceplot([],col_intalign)
ft_sourceplot([],mri_colin)

cfg = [];
cfg.method = 'headshape';
cfg.headshape.headshape = headshape;
cfg.headshape.icp = 'yes';
cfg.viewresult = 'yes';
cfg.coordsys = 'neuromag';
col_intalign_align = ft_volumerealign(cfg, col_intalign);
cfg.headshape.icp = 'no';
col_intalign_align = ft_volumerealign(cfg, col_intalign_align);

% volumereslice
cfg = [];
cfg.resolution = 1;
col_intalign_reslice = ft_volumereslice(cfg, col_intalign_align);

ft_sourceplot([],col_intalign_reslice)

save('Z:\PD_motor\fs_subjects_dir\0327\mri\col_intalign_reslice.mat','col_intalign_reslice')
% save('home/mikkel/PD_motor/fs_subjects_dir/0327/mri/col_intalign_reslice.mat','col_intalign_reslice')

%% save for freesurfer (must be done on Linux)
load('home/mikkel/PD_motor/fs_subjects_dir/0327/mri/col_intalign_reslice.mat')

cfg = [];
cfg.parameter = 'anatomy';
cfg.filename = '/home/mikkel/PD_motor/fs_subjects_dir/0327/mri/orig';
cfg.filetype = 'mgz';
ft_volumewrite(cfg, col_intalign_reslice)


% END
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% UNUSED (SADBOX)
% Convox hull (testing)
headshape_cvx = headshape;
x = squeeze(headshape.pos(:,1)');
y = squeeze(headshape.pos(:,2)');
z = squeeze(headshape.pos(:,3)');

% [X,Y,Z] = meshgrid(headshape.pos);
[TriIdxc, Vc] = convhull(x,y,z, 'simplify',true);
[TriIdxb, Vb] = boundary(x,y,z, 1);

DT = delaunayTriangulation(x,y,z);
TS = DT(:,:)
[K,v] = convexHull(DT);
trisurf(K,DT.Points(:,1),DT.Points(:,2),DT.Points(:,3)); axis off
tetramesh(TS,headshape.pos);camorbit(20,0); axis off


trisurf(TriIdxb, x, y, z); hold on
ft_plot_headshape(headshape); axis off

figure;
trisurf(TriIdxc, x, y, z); hold on
ft_plot_headshape(headshape); axis off

N = 100;
x = linspace(0,1,N);
y = linspace(0,1,N);
Z = peaks(N);
[X,Y] = meshgrid(x,y);
[TriIdx, V] = convhull(X,Y,Z)
trisurf(TriIdx, X, Y, Z)

cfg = [];
cfg.method = 'headshape';
cfg.headshape = headshape.pos;
hs = ft_prepare_mesh(cfg)

% Try remove (no will create holes in mesh)
% rmidx = logical(zeros(length(hs.tri),1));
% for i = 1:length(hs.tri)
%     xidx = hs.tri(i,1);
%     yidx = hs.tri(i,2);
%     zidx = hs.tri(i,3);
%     
%     xy = sqrt((hs.pos(xidx,1)-hs.pos(yidx,1))^2 + (hs.pos(xidx,2)-hs.pos(yidx,2))^2 + (hs.pos(xidx,3)-hs.pos(yidx,3))^2);
%     xz = sqrt((hs.pos(xidx,1)-hs.pos(zidx,1))^2 + (hs.pos(xidx,2)-hs.pos(zidx,2))^2 + (hs.pos(xidx,3)-hs.pos(zidx,3))^2);
%     yz = sqrt((hs.pos(yidx,1)-hs.pos(zidx,1))^2 + (hs.pos(yidx,2)-hs.pos(zidx,2))^2 + (hs.pos(yidx,3)-hs.pos(zidx,3))^2);
%     
%     if any([xy,xz,yz]>30)
%         rmidx(i) = 1;
%     end
% end
% hs.tri(rmidx,:) = [];
% sum(rmidx)

ft_plot_mesh(hs)

% surf = isosurface(x,y,z,ones(length(x)),.1)

cfg = []
cfg.method = 'singleshell';
hm = ft_prepare_headmodel(cfg, hs)


[x, y, z] = meshgrid([-1 0 1]);
v = x .* exp(-x.^2 - y.^2 - z.^2);
scatter3(x(:), y(:), z(:), 72, v(:), 'filled');
view(-15, 35);
colorbar;

[x,y,z] = meshgrid(-3:0.5:3);
v = x.*exp(-x.^2 - y.^2 - z.^2);
scatter3(x(:), y(:), z(:), 30, v(:), 'filled');
view(-15, 35);

clf;
isosurface(x, y, z, v, 1e-5);
axis([-3 3 -3 3 -3 3]);

x=[2.5 4 6 18 9]; 
y=[12 3 7.5 1 10];
[X,Y]=meshgrid(x,y)
% and for example 
Z=X+Y
mesh(X,Y,Z)

[X,Y,Z] = meshgrid(x,y,z);
Z = X .* exp(-X.^2 - Y.^2);
surf(X,Y,Z)
