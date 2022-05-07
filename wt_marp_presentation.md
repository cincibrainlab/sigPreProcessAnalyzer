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
## **Preprocessing Investigation**
### Code run on MATLAB 2021a and EEGLAB 2022.0
For conveniance dataset is cloudhosted
WT1_ContinousData.mat
Resting State Data
- contains 2 EEGLAB SET variables
  - EEG_PreICA  - filtered, post-channel removal, continous clean
  - EEG_PostICA - Standard ICA cleaning method

WT2_ErpData.mat
  Auditory Evoked Potential
  contains 2 EEGLAB SET variables
   - ERP_PreICA  - filtered, post-channel removal, continous clean
   - ERP_PostICA - Standard ICA cleaning method

---
# Preprocessing of Audiory Evoked Potential (AEP)
## Habituation Paradigm
ERP|Sensors
-|-
![left h:300px width:300px](https://www.dropbox.com/s/snnvnxz5u4tz58u/CleanShot%202022-04-14%20at%2007.06.28%402x.png?raw=1)|![right fit width:300px](https://www.dropbox.com/s/kvk0m3a4t1cjhov/CleanShot%202022-04-14%20at%2007.07.03%402x.png?raw=1)
### https://www.frontiersin.org/articles/10.3389/fnint.2019.00060/full

