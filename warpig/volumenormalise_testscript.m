% Test functionality of normalising custom MRI in different coordinate
% systems.
ftpath = '/home/mikkel/fieldtrip/fieldtrip';
addpath(ftpath)
% addpath(fullfile(ftpath,'external/spm12'))
ft_defaults 

%% Settings
coordsysts  = {'acpc', 'ctf', 'neuromag'};   % add more later...
spmversions = {'spm2', 'spm8', 'spm12'};
spmmethods   = {'old','new','mars'};

fpath   = '/home/mikkel/mri_scripts/warpig/warptest';
outpath = '/home/mikkel/mri_scripts/warpig/warptest/output';

%% Load and prepare MRI
mri1 = ft_read_mri('/home/mikkel/mri_scripts/warpig/data/MC/00000002/00000001.dcm');
mri2 = ft_read_mri('/home/mikkel/mri_scripts/warpig/data/RO/20160825/PAUGAA_20160825_MEGANATOMY.MR.DCCN_PRISMAFIT.0002.0046.2016.08.25.16.54.09.114696.482173804.IMA');
mri1 = ft_determine_coordsys(mri1, 'interactive', 'yes');
mri2 = ft_determine_coordsys(mri2, 'interactive', 'yes');

ft_sourceplot([],mri1)
ft_sourceplot([],mri2)

%% Create from MRI with all coordinate systems
mris_from = [];
mris_to = [];
for ii = 1:length(coordsysts)
  coordsys = coordsysts{ii};
  disp(coordsys)
  
%   cfg = [];
%   cfg.method = 'interactive';
%   cfg.coordsys = coordsys; 
%   mris_from.(coordsys)  = ft_volumerealign(cfg, mri1);
%   mris_to.(coordsys)    = ft_volumerealign(cfg, mri2);
%    
  %Export 
  cfg = [];
  cfg.filetype    = 'nifti';          % .nii exntension
  cfg.parameter   = 'anatomy';
  cfg.filename    = fullfile(outpath,['mrito_',coordsys]);   % Same base filename but different format
  ft_volumewrite(cfg, mris_to.(coordsys))
end

save(fullfile(outpath, 'mris'), 'mris_from', 'mris_to')

%% Test default functionality (anything -> SPM template)
mris_norm2temp = [];
for ii = 1:length(coordsysts)
  cfg = [];
  for jj = 1:length(spmversions)
    cfg.spmversion = spmversions{jj};
    if strcmp(cfg.spmversion, 'spm12')
      for kk = 1:length(spmmethods)
        cfg.spmmethod= spmmethods{kk};
        mris_norm2temp.([cfg.spmversion,cfg.spmmethod]) = ft_volumenormalise(cfg, mris_from.(coordsysts{ii}));
            
        ft_sourceplot([], mris_norm2temp.([cfg.spmversion,cfg.spmmethod]))
        title([coordsysts{ii},' to SPM template (',cfg.spmversion,cfg.spmmethod,')'])
        saveas(gcf, fullfile(outpath, [coordsysts{ii},' to SPM template (',cfg.spmversion,cfg.spmmethod,')']))
        close
      end
    else
      cfg.spmmethod = [];
      mris_norm2temp.([cfg.spmversion,cfg.spmmethod]) = ft_volumenormalise(cfg, mris_from.(coordsysts{ii}));
      
      ft_sourceplot([], mris_norm2temp.([cfg.spmversion,cfg.spmmethod]))
      title([coordsysts{ii},' to SPM template (',cfg.spmversion,cfg.spmmethod,')'])
      saveas(gcf, fullfile(outpath, [coordsysts{ii},'2template_',cfg.spmversion,cfg.spmmethod,'.pdf']))
      close
    end
  end
end 
    

%% Custom MRI template
mris_warped   = [];
coordsys_from = coordsysts;
cordsys_to    = coordsysts;

cfg = [];
for ii = 1:length(coordsys_from)
  ci = coordsys_from{ii};   
  for jj = 1:length(cordsys_to)
    cj = cordsys_to{jj};
      for kk = 1:length(spmversions)
        cfg.spmversion       = spmversions{kk};
        cfg.spmmethod        = 'old';
        cfg.template         = fullfile(outpath,['mrito_',cj,'.nii']);
        cfg.templatecoordsys = cj;
        
        try
          mris_warped.([ci,'2',cj,'_',cfg.spmversion]) = ft_volumenormalise(cfg, mris_from.(ci));
          
          ft_sourceplot([], mris_warped.([ci,'2',cj,'_',cfg.spmversion]))
          title([ci,'2',cj,' (',cfg.spmversion,')'])
          saveas(gcf, fullfile(outpath, [ci,'2',cj,'_',cfg.spmversion,'.pdf']))
          close
        catch
          fprintf('%s to %s (%s) failed\n', ci, cj, cfg.spmversion)
          mris_warped.([ci,'2',cj,'_',cfg.spmversion]) = 'error';
        end
      end
  end
end