%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
load('LOSS_VP21_1-rejected-wake.set', '-mat')

wakesize = size(EEG.stats.psd,3)
use_W = size(EEG.stats.usetrials,1);
totalwakemin = (wakesize*4)

load('LOSS_VP21_1-rejected-sleep.set', '-mat')
sleepsize = size(EEG.stats.psd,3)
use_S = size(EEG.stats.usetrials,1);
S1time = sum(EEG.stats.sleep_trial  ==1)*4;     %count how many times it is stg

S2time = sum(EEG.stats.sleep_trial  ==2)*4;     %count how many times it is stg

sum(EEG.stats.sleep_epoch(:,1) == 2 )*7.5*4

S3time = sum(EEG.stats.sleep_trial  ==3)*4;     %count how many times it is stg

sum(EEG.stats.sleep_epoch(:,1) == 3)*7.5*4

S4time = sum(EEG.stats.sleep_trial  ==4)*4;     %count how many times it is stg

filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', 21,1);
load(filenameM)
PSDsize = size(PSD,3)
totalsize = sleepsize + wakesize
totalsizeuse = use_W+use_S

load('LOSS21_night_ctrl_01.mat')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%detect 
