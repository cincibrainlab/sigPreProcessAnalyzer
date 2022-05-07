% Wavelet Thresholding 
% Part I
% Continuous Data Performance

% Code run on MATLAB 2021a and EEGLAB 2022.0

% For conveniance dataset is cloudhosted
raw.srcchirp.atlas <- 
  read_csv("https://www.dropbox.com/s/wkbezwt1qitzueo/DK_atlas-68_dict.csv?dl=1") %>% 
  select(labelclean, brainpaint, region, RSN, side, lobe)
% WT1_ContinousData.mat
% Resting State Data
% contains 2 EEGLAB SET variables
%  - EEG_PreICA  - filtered, post-channel removal, continous clean
%  - EEG_PostICA - Standard ICA cleaning method

% WT2_ErpData.mat
% Auditory Evoked Potential
% https://www.frontiersin.org/articles/10.3389/fnint.2019.00060/full
% contains 2 EEGLAB SET variables
%  - ERP_PreICA  - filtered, post-channel removal, continous clean
%  - ERP_PostICA - Standard ICA cleaning method

load(websave('WT1_ContData.mat', 'https://zenodo.org/record/6409036/files/WT1_ContData.mat?download=1'))
load(websave('WT2_ErpData.mat', 'https://zenodo.org/record/6409036/files/WT2_ErpData.mat?download=1'));

ERP_PreICA = pop_loadset('D0051_hab_preica.set','C:\Users\ernie\Downloads');
ERP_PreICA.etc = [];
ERP_PreICA.group = [];
ERP_PreICA.subject = 'D0051';
ERP_PreICA.condition = [];
ERP_PreICA.history = [];
ERP_PreICA.comments = [];

ERP_PostICA.comments = [];

save('WT2_ErpData.mat', 'ERP_PostICA', 'ERP_PreICA');  


% add toolkit paths
vhtp_path = 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_SAT\EEG Paper\vhtp';
eeglab_path = 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_SAT\EEG Paper\eeglab';
brainstorm_path = 'E:\Research Software\brainstorm3';
restoredefaultpath;
addpath(genpath(vhtp_path));
addpath(eeglab_path);
addpath(brainstorm_path);

eeg_htpEegAssessPipelineHAPPE(EEG_PreICA, EEG_PostICA, ...
    'groupLabels',{'PreICA','PostICA'})

EEG_wavlvl = [];
wavlvl_arr = [7,9,11];
for i = 1 : numel(wavlvl_arr)
    wavlvl = wavlvl_arr(i);
    EEG_wavlvl{i} = eeg_htpEegWaveletDenoiseHappe( EEG_PreICA, ...
        'wavLvl', wavlvl, ...
        'ThresholdRule', 'Soft' );
end

figure('color', 'w');
test_ts = [];
for i = 1 : numel(EEG_wavlvl) + 1
    if i == numel(EEG_wavlvl) + 1
            test_ts(i,:) = squeeze(EEG_PreICA.data(30, 1:EEGtmp.srate*6));
    else
            EEGtmp = EEG_wavlvl{i};

    test_ts(i,:) = squeeze(EEGtmp.data(30, 1:EEGtmp.srate*6));
    end
end
plot(test_ts')
legend()

eegplot(EEG.data, 'data2', EEG2.data)


%% ERP Investigation

% add toolkit paths
vhtp_path = 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\external\vhtp';
eeglab_path = 'C:\Users\ernie\Dropbox\code\eeglab';
brainstorm_path = 'E:\Research Software\brainstorm3';
restoredefaultpath;
addpath(genpath(vhtp_path));
addpath(eeglab_path);
addpath(brainstorm_path);

eeglab nogui;
%%
erp_file.import = 'D0051_hab_import.set';
erp_file.preica = 'D0051_hab_preica.set';
erp_file.postica = 'D0051_hab_postcomp.set';
erp_filepath = 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset';

% get epochs
EEG = pop_loadset('filename', erp_file.import, 'filepath', erp_filepath);
EEG_PreIca = pop_loadset('filename', erp_file.postica, 'filepath', erp_filepath);

%% Run 1: Original Three Methods
comment_tags = table({'S1_Filter_Channel'; 'S2_Manual Cleaning'; 'S4_Post_ICA'}, 'VariableNames', {'Description'});
EEGHab = {};
erp_fields = fieldnames(erp_file);
for i = 1 : numel(erp_fields)
    
    cur_field = erp_fields{i};
    EEG = pop_loadset('filename', erp_file.(cur_field), 'filepath', erp_filepath);
    if EEG.trials == 1
        EEG = eeg_htpEegCreateEpochsHabEeglab(EEG);
    end
    EEG.setname = comment_tags{i,1}{1};
    EEG.etc.vhtp.eeg_htpVisualizeHabErp.tag = comment_tags{i,1}{1};
    EEG.filename = sprintf('D0051_%s.set', EEG.setname);
    EEGHab{i} = eeg_htpCalcHabErp(EEG);
    
    pop_saveset(EEGHab{i}, 'filename', EEGHab{i}.filename, ...
        'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets' )
end

% Code to zero out a certain ERP for visualization
blank_data = zeros(size(EEGHab{i}.etc.htp.hab.erp));
% EEGHab{1}.etc.htp.hab.erp = blank_data;
% EEGHab{2}.etc.htp.hab.erp = blank_data;
% EEGHab{3}.etc.htp.hab.erp = blank_data;

% Visualize original three methods on same plot
% with latencies
eeg_htpVisualizeHabErp(EEGHab, 'groupmean', false, 'singleplot', false, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% all on single plot
eeg_htpVisualizeHabErp(EEGHab, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% Zooom
eeg_htpVisualizeHabErp(EEGHab, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output',...
    'drugNames', {'S4_Post-ICA','S2_Manual Cleaning', 'S1_Filter_Only'}, ...
    'plotstyle','tetra')
%%
EEG = eeg_htpEegValidateErpPipeline( EEG_PreIca );


%% Wavlet Thresholding
% EEGHab = {};

% load seed EEG
EEG_preica    = EEGHab{2};
EEG_postcomps = EEGHab{3};

% WT at default settings
% COIF4, Bayes, Soft, 12, CC .926
EEG_wtdefault = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', false);
EEG_wtdefault.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_Default';
EEG_wt_hab = eeg_htpCalcHabErp(EEG_wtdefault);
EEG_wt_hab.setname = 'WT Default Settings';
EEG_wt_hab.filename = 'D0051_S3_WTDefaultErp.set';
pop_saveset(EEG_wt_hab, 'filename', EEG_wt_hab.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )

EEGWTDefault = {EEG_preica, EEG_postcomps, EEG_wt_hab};

% Visualize original three methods on same plot
% with latencies
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', false, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% all on single plot
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')

% Zooom
% Code to zero out a certain ERP for visualization
% blank_data = zeros(size(EEGWTDefault{i}.etc.htp.hab.erp));
% EEGWTDefault{1}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{2}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{3}.etc.htp.hab.erp = blank_data;
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output',...
    'drugNames', {'S3_WT', 'S4_Post-ICA', 'S2_PreICA'}, ...
    'plotstyle','tetra')

%% Specific Settings
% EEGHab = {};

% load seed EEG
EEG_preica    = EEGHab{2};
EEG_postcomps = EEGHab{3};

% WT at default settings
% COIF4, Bayes, Soft, 12, CC .926
EEG_wtdefault = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', false);
EEG_wtdefault.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_Default';

% Hard
EEG_wt_hab_hard = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', ...
    false,'ThresholdRule','hard');
EEG_wt_hab_hard.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_Default';
EEG_wt_hab_hard = eeg_htpCalcHabErp(EEG_wtdefault);
EEG_wt_hab_hard.setname = 'WT Thres hard';
EEG_wt_hab_hard.filename = 'D0051_S3_WT_Hard.set';
pop_saveset(EEG_wt_hab_hard, 'filename', EEG_wt_hab_hard.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )

% Soft
EEG_wt_hab_soft = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', false, ...
    'ThresholdRule','soft');
EEG_wt_hab_soft.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_Soft';
EEG_wt_hab_soft = eeg_htpCalcHabErp(EEG_wtdefault);
EEG_wt_hab_soft.setname = 'WT Thres Soft';
EEG_wt_hab_soft.filename = 'D0051_S3_WT_Soft.set';
pop_saveset(EEG_wt_hab_soft, 'filename', EEG_wt_hab_soft.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )

EEGWTDefault = {EEG_preica, EEG_wt_hab_hard, EEG_wt_hab_soft};

% Visualize original three methods on same plot
% with latencies
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', false, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% all on single plot
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')

% Zooom
% Code to zero out a certain ERP for visualization
% blank_data = zeros(size(EEGWTDefault{i}.etc.htp.hab.erp));
% EEGWTDefault{1}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{2}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{3}.etc.htp.hab.erp = blank_data;
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output',...
    'drugNames', {'S3_Soft', 'S3_Hard', 'S2_PreICA'}, ...
    'plotstyle','tetra')

%% wave level
% EEGHab = {};

% load seed EEG
EEG_preica    = EEGHab{2};
EEG_postcomps = EEGHab{3};

% WT at default settings
% COIF4, Bayes, Soft, 12, CC .926
EEG_wtdefault = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', false);
EEG_wtdefault.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_Default';

% 8
EEG_wt_hab_8 = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', ...
    false,'wavLvl',8);
EEG_wt_hab_8.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_wavlvl8';
EEG_wt_hab_8 = eeg_htpCalcHabErp(EEG_wt_hab_8);
EEG_wt_hab_8.setname = 'WT WaveLvl 8';
EEG_wt_hab_8.filename = 'D0051_S3_WT_WaveL8.set';
pop_saveset(EEG_wt_hab_8, 'filename', EEG_wt_hab_8.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )

% 10
EEG_wt_hab_10 = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', ...
    false,'wavLvl',10);
EEG_wt_hab_10.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_wavlvl10';
EEG_wt_hab_10 = eeg_htpCalcHabErp(EEG_wt_hab_10);
EEG_wt_hab_10.setname = 'WT WaveLvl 10';
EEG_wt_hab_10.filename = 'D0051_S3_WT_WaveL10.set';
pop_saveset(EEG_wt_hab_10, 'filename', EEG_wt_hab_10.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )


% 12
EEG_wt_hab_12 = eeg_htpEegWaveletDenoiseHappe( EEGHab{2}, 'isErp', true, 'filtOn', ...
    false,'wavLvl',12);
EEG_wt_hab_12.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'WT_wavlvl12';
EEG_wt_hab_12 = eeg_htpCalcHabErp(EEG_wt_hab_12);
EEG_wt_hab_12.setname = 'WT WaveLvl 12';
EEG_wt_hab_12.filename = 'D0051_S3_WT_WaveL12.set';
pop_saveset(EEG_wt_hab_12, 'filename', EEG_wt_hab_12.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )


EEGWTDefault = {EEG_preica, EEG_wt_hab_8, EEG_wt_hab_10, EEG_wt_hab_12};

% Visualize original three methods on same plot
% with latencies
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', false, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% all on single plot
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')

% Zooom
% Code to zero out a certain ERP for visualization
% blank_data = zeros(size(EEGWTDefault{i}.etc.htp.hab.erp));
% EEGWTDefault{1}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{2}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{3}.etc.htp.hab.erp = blank_data;
EEGWTDefault = {EEG_wt_hab_8, EEG_wt_hab_10, EEG_wt_hab_12};

eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output',...
    'drugNames', {'S3_8', 'S3_10', 'S2_12'}, ...
    'plotstyle','tetra')

%% CLEANRAWDATA
% EEGHab = {};

% load seed EEG
EEG_preica    = EEGHab{2};
EEG_postcomps = EEGHab{3};

% Makoto Suggestions:
% SD 20 (Default 5)


EEGCRD_Riemann = clean_artifacts(ERP_PreICA, 'UseRiemannian', true);
EEGCRD = clean_artifacts(ERP_PreICA, 'UseRiemannian', true);
EEGCRD.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'ASR_Default';
EEGCRD_DIN8_InterpolateNeeded = eeg_htpEegCreateEpochsHabEeglab(EEGCRD);
EEGCRD_DIN8 = pop_interp(EEGCRD_DIN8_InterpolateNeeded, ...
EEG.chanlocs);
EEGCRD_Hab = eeg_htpCalcHabErp(EEGCRD_DIN8);
EEGCRD_Hab.setname = 'EEG_ASR_Default';
EEGCRD_Hab.filename = 'D0051_CRD_Default.set';
pop_saveset(EEGCRD_Hab, 'filename', EEGCRD_Hab.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )
EEGCRD.etc


EEGASR = clean_asr(ERP_PreICA);
EEGASR.etc.vhtp.eeg_htpVisualizeHabErp.tag = 'ASR_Default';
EEGASR_DIN8 = eeg_htpEegCreateEpochsHabEeglab(EEGASR);
EEGASR_Hab = eeg_htpCalcHabErp(EEGASR_DIN8);
EEGASR_Hab.setname = 'EEG_ASR_Default';
EEGASR_Hab.filename = 'D0051_ASR_Default.set';
pop_saveset(EEGASR_Hab, 'filename', EEGASR_Hab.filename, ...
    'filepath', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output\WG_Datasets\' )

EEGWTDefault = {EEG_preica, EEGCRD_Hab, EEG_postcomps};

% Visualize original three methods on same plot
% with latencies
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', false, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')
% all on single plot
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output')

% Zooom
% Code to zero out a certain ERP for visualization
% blank_data = zeros(size(EEGWTDefault{i}.etc.htp.hab.erp));
% EEGWTDefault{1}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{2}.etc.htp.hab.erp = blank_data;
% EEGWTDefault{3}.etc.htp.hab.erp = blank_data;
eeg_htpVisualizeHabErp(EEGWTDefault, 'groupmean', false, 'singleplot', true, ...
    'outputdir', 'C:\Users\ernie\Dropbox\RESEARCH_FOCUS\MAIN_WT\Dataset\Output',...
    'drugNames', {'S4_PostComp', 'S3_CRD', 'S2_PreICA'}, ...
    'plotstyle','tetra')