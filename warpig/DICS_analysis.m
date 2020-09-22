%% DICS
addpath '~/fieldtrip/fieldtrip/'
addpath '~/fieldtrip/fieldtrip/external/mne'
ft_defaults

%% Compute paths
raw_folder = '/home/share/workshop_source_reconstruction/20180206/MEG/NatMEG_0177/170424';
data_path = '/home/mikkel/mri_scripts/warpig/data/0177';

%% Load data
fprintf('Loading... ')
% load(fullfile(raw_folder, 'baseline_data.mat'))
load(fullfile(raw_folder, 'cleaned_downsampled_data.mat'))
disp('done')

cfg = [];
cfg.trials = cleaned_downsampled_data.trialinfo==8;
data = ft_selectdata(cfg, cleaned_downsampled_data);

%% TFR (for inspection)
cfg = [];
cfg.output      = 'pow';        
cfg.channel     = 'MEG';
cfg.method      = 'mtmconvol';
cfg.taper       = 'dpss';
cfg.foi         = 1:1:45;
cfg.toi         = -2:0.01:2;
cfg.t_ftimwin   = 5./cfg.foi;
cfg.tapsmofrq   = 0.5 *cfg.foi;

tfr = ft_freqanalysis(cfg, data);

cfg = [];
cfg.parameter       = 'powspctrm';
cfg.layout          = 'neuromag306mag';
cfg.showlabels      = 'yes';
cfg.baselinetype    = 'relative';  % Type of baseline, see help ft_multiplotTFR
cfg.baseline        = [-inf 0];    % Time of baseline

figure; ft_multiplotTFR(cfg, tfr);

% Wavelet
cfg = [];
cfg.output      = 'pow';        
cfg.channel     = 'MEG';
cfg.method      = 'wavelet';
cfg.foi         = 1:1:45;
cfg.toi         = -2:0.01:2;
cfg.width       = 7;

tfr = ft_freqanalysis(cfg, data);

cfg = [];
cfg.parameter       = 'powspctrm';
cfg.layout          = 'neuromag306mag';
cfg.showlabels      = 'yes';
cfg.baselinetype    = 'relative';  % Type of baseline, see help ft_multiplotTFR
cfg.baseline        = [-0.5 0];    % Time of baseline

figure; ft_multiplotTFR(cfg, tfr);

%% Process data
desync_toi   = [0.220 0.500];
baseline_toi = [-0.500 -0.220];

% Define segments
cfg = [];
cfg.toilim = desync_toi;
tois_desync = ft_redefinetrial(cfg, data);

cfg.toilim = baseline_toi;
tois_baseline = ft_redefinetrial(cfg, data);

tois_combined = ft_appenddata(cfg, tois_desync, tois_baseline);

%% Calculate CSD;
cfg = [];
cfg.method     = 'mtmfft';
cfg.output     = 'powandcsd';
cfg.taper      = 'hanning';
cfg.channel    = 'meg';
cfg.foilim     = [20 20];
cfg.keeptrials = 'no';
cfg.pad        = 'nextpow2';

pow_desync  = ft_freqanalysis(cfg, tois_desync);
pow_baseline = ft_freqanalysis(cfg, tois_baseline);
pow_combined = ft_freqanalysis(cfg, tois_combined);

%% Load headmodels and source spaces
load(fullfile(data_path, 'headmodel_org.mat'));
load(fullfile(data_path, 'headmodel_tmp.mat'));

load(fullfile(data_path, 'sourcemodels.mat'));

%% Make leadfields
cfg = [];
cfg.grad            = pow_combined.grad;    % magnetometer and gradiometer specification
cfg.channel         = 'meg';
cfg.senstype        = 'meg';

cfg.sourcemodel     = sourcemodel_orig;
cfg.headmodel       = headmodel_orig;

leadfield_orig = ft_prepare_leadfield(cfg);

cfg.sourcemodel     = sourcemodel_tmp;
cfg.headmodel       = headmodel_tmp;
leadfield_tmp = ft_prepare_leadfield(cfg);

%% DICS
cfg = [];
cfg.method              = 'dics';
cfg.frequency           = pow_combined.freq;
cfg.dics.projectnoise   = 'yes';
cfg.dics.lambda         = '5%';
cfg.dics.keepfilter     = 'yes';
cfg.dics.realfilter     = 'yes'; 
cfg.channel             = 'meg'; 
cfg.senstype            = 'meg';
cfg.grad                = pow_combined.grad;

% Original
cfg.sourcemodel         = leadfield_orig;       
cfg.headmodel           = headmodel_orig;
dics_combined_orig = ft_sourceanalysis(cfg, pow_combined);    
cfg.sourcemodel.filter = dics_combined_orig.avg.filter;    
dics_desy_orig = ft_sourceanalysis(cfg, pow_desync);
dics_base_orig = ft_sourceanalysis(cfg, pow_baseline);    

% Template
cfg.sourcemodel         = leadfield_tmp;
cfg.headmodel           = headmodel_tmp;
dics_combined_tmp = ft_sourceanalysis(cfg, pow_combined);
cfg.sourcemodel.filter = dics_combined_tmp.avg.filter; 
dics_desy_tmp = ft_sourceanalysis(cfg, pow_desync);
dics_base_tmp = ft_sourceanalysis(cfg, pow_baseline);
    
%% Contrast
cfg = [];
cfg.operation   = '(x1-x2)/(x1+x2)';
cfg.parameter   = 'pow';
contrast_orig = ft_math(cfg, dics_desy_orig, dics_base_orig);
contrast_tmp = ft_math(cfg, dics_desy_tmp, dics_base_tmp);

%% Save
save(fullfile(data_path, 'dics_contrasts'), 'contrast_tmp', 'contrast_orig');

%% Load resliced MRI
load(fullfile(data_path, 'mri_tmp_resliced.mat'));
load(fullfile(data_path, 'mri_org_resliced.mat'));

%% Plot original result
cfg = [];
cfg.downsample  = 2;
cfg.parameter   = 'pow';
beam_int_orig = ft_sourceinterpolate(cfg, contrast_orig, mri_org_resliced);
[~, idx] = min(beam_int_orig.pow);

cfg = [];
cfg.method       = 'ortho';
cfg.funparameter = 'pow';
cfg.location = beam_int_orig.pos(idx,:);

ft_sourceplot(cfg, beam_int_orig);

%% Plot template result
cfg = [];
cfg.downsample  = 2;
cfg.parameter   = 'pow';
beam_int_tmp = ft_sourceinterpolate(cfg, contrast_tmp, mri_tmp_resliced);
[~, idx] = min(beam_int_tmp.pow);

cfg = [];
cfg.method       = 'ortho';
cfg.funparameter = 'pow';
cfg.location = beam_int_tmp.pos(idx,:);

ft_sourceplot(cfg, beam_int_tmp);    

%% Compare (/move to another scritpt)
load(fullfile(data_path, 'dics_contrasts'))

dat = [round(contrast_orig.pow(contrast_orig.inside),2)';
       round(contrast_tmp.pow(contrast_tmp.inside),2)'];
   
fprintf('Calculating alpha... ')
a_dics = kriAlpha(dat, 'interval')
disp('done')

save(fullfile(data_path,'a_dics_redux'), 'a_dics');

%END