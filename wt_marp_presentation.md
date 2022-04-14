---
marp: true
style: |
    img[alt~="center"] {
      display: block;
      margin: 0 auto;
    }
    section{
      justify-content: flex-start;
    }
---
# **Preprocessing Investigation**

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