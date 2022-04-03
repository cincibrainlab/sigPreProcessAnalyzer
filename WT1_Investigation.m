% Wavelet Thresholding 
% Part I
% Continuous Data Performance

% Code run on MATLAB 2021a and EEGLAB 2022.0

% For conveniance dataset is cloudhosted

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




