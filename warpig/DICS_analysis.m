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
cfg.channel     = 'MEG';      % Change to 'MEG*1' to analyse all channels
cfg.method      = 'mtmconvol';
cfg.taper       = 'dpss';       % Slepian sequence as tapers
cfg.foi         = 1:1:45;       % Frequencies we want to estimate from 1 Hz to 45 Hz in steps of 1HZ
cfg.toi         = -1.650:0.01:1.650;             % Times to center on
cfg.t_ftimwin   = 5./cfg.foi;   % length of time window
cfg.tapsmofrq   = 0.5 *cfg.foi; % Smoothing

tfr = ft_freqanalysis(cfg, data);

cfg = [];
cfg.parameter       = 'powspctrm';
cfg.layout          = 'neuromag306mag';
cfg.showlabels      = 'yes';
cfg.baselinetype    = 'relative';  % Type of baseline, see help ft_multiplotTFR
cfg.baseline        = [-inf 0];    % Time of baseline

figure; ft_multiplotTFR(cfg, tfr);

%% Process data
desync_toi     = [0.220 0.500];
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
cfg.foilim     = [16 16];
cfg.keeptrials = 'no';
cfg.pad        = 'nextpow2';

pow_desync  = ft_freqanalysis(cfg, tois_desync);
pow_baseline = ft_freqanalysis(cfg, tois_baseline);
pow_combined = ft_freqanalysis(cfg, tois_combined);

%% Load headmodels and source spaces
load(fullfile(data_path, 'headmodel_lin.mat'));
load(fullfile(data_path, 'headmodel_orig.mat'));
load(fullfile(data_path, 'headmodel_spm12.mat'));

load(fullfile(data_path, 'sourcemodel_lin.mat'));
load(fullfile(data_path, 'sourcemodel_orig.mat'));
load(fullfile(data_path, 'sourcemodel_spm12.mat'));

%% Make leadfields

cfg = [];
cfg.grad            = pow_combined.grad;    % magnetometer and gradiometer specification
cfg.headmodel       = headmodel_orig;       % headmodel used
cfg.channel         = 'meg';
cfg.resolution      = 1; 
cfg.grid.unit       = 'cm'; 
cfg.senstype        = 'meg';

leadfield_orig = ft_prepare_leadfield(cfg);

cfg.headmodel       = headmodel_orig;       % headmodel used
leadfield_lin = ft_prepare_leadfield(cfg);

cfg.headmodel       = headmodel_spm12;      % headmodel used
leadfield_spm12 = ft_prepare_leadfield(cfg);

%% DICS
cfg = [];
cfg.method              = 'dics';                   % Dynamic Imaging of Coherent Sources
cfg.frequency           = pow_combined.freq;        % the frequency from the fourier analysis (as defined above to be 16 Hz)
cfg.dics.projectnoise   = 'yes';                    % estimate noise
cfg.dics.lambda         = '5%';                    % how to regularise
cfg.dics.keepfilter     = 'yes';                    % keep the spatial filter in the output
cfg.dics.realfilter     = 'yes';                    % retain the real values
cfg.channel             = 'meg';
cfg.senstype            = 'meg';
cfg.grad                = pow_combined.grad;

% ORIG
cfg.sourcemodel         = leadfield_orig;                % Our grid and the leadfield
cfg.headmodel           = headmodel_orig;                % our headmodel (tells us how the magnetic field/electrical potential is propagated)
dics_combined_orig = ft_sourceanalysis(cfg, pow_combined);    
cfg.sourcemodel.filter = dics_combined_orig.avg.filter;    
dics_desy_orig = ft_sourceanalysis(cfg, pow_desync);
dics_base_orig = ft_sourceanalysis(cfg, pow_baseline);    

% SPM12
cfg.sourcemodel         = leadfield_spm12;                % Our grid and the leadfield
cfg.headmodel           = headmodel_spm12;                % our headmodel (tells us how the magnetic field/electrical potential is propagated)
dics_combined_spm12 = ft_sourceanalysis(cfg, pow_combined);    
cfg.sourcemodel.filter = dics_combined_spm12.avg.filter;    
dics_desy_spm12 = ft_sourceanalysis(cfg, pow_desync);
dics_base_spm12 = ft_sourceanalysis(cfg, pow_baseline);    
    
%% **Plots**
cfg = [];
cfg.operation   = '(x1-x2)/(x1+x2)';
cfg.parameter   = 'pow';
contrast_orig = ft_math(cfg, dics_desy_orig, dics_base_orig);
contrast_spm12 = ft_math(cfg, dics_desy_spm12, dics_base_spm12);

%% Load resliced MRI
load('mri_orig_rs.mat')
load('mri_spm12_rs.mat')

%% Orig
cfg = [];
cfg.downsample = 2;
cfg.parameter = 'pow';
beam_int_orig = ft_sourceinterpolate(cfg, contrast_orig, mri_orig_rs);
[~, idx] = min(beam_int_orig.pow);

cfg = [];
cfg.method = 'ortho';
cfg.funparameter = 'pow';
cfg.location = beam_int_orig.pos(idx,:);

ft_sourceplot(cfg, beam_int_orig);

%% Plot spm12
cfg = [];
cfg.downsample = 2;
cfg.parameter = 'pow';
beam_int_spm12 = ft_sourceinterpolate(cfg, contrast_spm12, mri_spm12_rs);
[~, idx] = min(beam_int_spm12.pow);

cfg = [];
cfg.method = 'ortho';
cfg.funparameter = 'pow';
cfg.location = beam_int_spm12.pos(idx,:);

ft_sourceplot(cfg, beam_int_spm12);    


%% 
save('dics_plots', 'beam_int_spm12', 'beam_int_orig')
    