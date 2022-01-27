%%%%%%%%%%%%%%%%%%preprocessing%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%parameters of preprocessing
%% 
clear all
cd /home/kumral/Desktop/Projects/LOSS_analyses/audiobook_PSDs/ 
load('sleep_info_audiobook.mat') %%one EEG file including all individual PSD info (epoch, stages etc...)
addpath('/home/kumral/Desktop/Projects/LOSS/EEG_raw/') %directory for raw EEG files for 'rejection' info
filesDir = '//home/kumral/Desktop/Projects/LOSS_analyses/audiobook_PSDs/'; %directory to sava
fmin = 0.5; fmax=30;
logtrans =1; %do log transform, (0=no,1=yes)
doplot = 1; %do plotting of PSD (0=no,1=yes)
reject = 0; %reject the noisy epochs (0=no,1=yes)
reduce = 0; %reduce the channels to 32 (0=no,1=yes)
interpolate =  0; %interpolate the channels (0=no,1=yes)
sharptool = 1; %sharpening toolbox (0=no,1=yes)
condition = 'sleep'; %sleep or %wake
transform = 'norm'; %normalize or %rescale function of matlab
reducetime = 'minutes'; % full or %minutes
timing = 'last'; %last %first or %random
min = 15;
saveDir = [timing,'_',condition,'_',num2str(min),'min_fmax',num2str(fmax),'_fmin',num2str(fmin),'_log',num2str(logtrans),'_reject',num2str(reject),'_reduce', num2str(reduce), '_interpolate', num2str(interpolate),transform, '_sharptool', num2str(sharptool)];
mkdir(saveDir)
cd(saveDir)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:size(sleep_info_audiobook,1)
    filenameM = sleep_info_audiobook.original{i,1};
    filenameS = sleep_info_audiobook.sleep_audiobook_epoch{i,1};
    vp = sleep_info_audiobook.VP(i);
    cyc = sleep_info_audiobook.Weckung(i);
    if vp<10
        filenameSinfo = sprintf('LOSS_VP0%d_%d-rejected-%s.set',vp,cyc,condition);
    else
        filenameSinfo = sprintf('LOSS_VP%d_%d-rejected-%s.set',vp,cyc, condition);
    end
    PSD_preprocess(filenameS, filenameSinfo, filenameM, fmin, fmax, logtrans, interpolate, reject, reduce, sharptool, doplot,vp,cyc, condition, transform,reducetime,timing,min)
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%merging the data files%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fileInfo =fullfile(filesDir,saveDir) %directory info
data = merge_PSD(fileInfo);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%combining with the behavioral the data files%%%%%%%%%%%%%%%%%%%%%%
combined_data = combine_behavioral_table(data);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%averaging across sleep cycles%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
stage= 1:5; %stages to combine (averaging, for wake it is 1, sleep 1:5)
subjects = unique(combined_data.VP)'; %subjects
data_reduced = average_PSD_awakenings(combined_data,stage,subjects);
%final product is data_reduced.mat --> use this file for the statistical
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this is for the full matrix  to create also empty files: if 19 subject x 4
%weckungen, it will create 76 indivduals with some of them are empty
%it uses combine_data
load('data_all_behavior.mat')
stage= 1:5; %stages to combine (averaging, for wake it is 1, sleep 1:5)
subjects = unique(combined_data.VP)'; %subjects
Weckung = 1:4;
data_reduced = average_full_subjects(combined_data,stage,subjects,Weckung);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script is to create the average for nondream and dream condition for
%each individual subject based on full data that we have
load('data_reduced_full.mat')
stage= 1:5; %stages to combine (averaging, for wake it is 1, sleep 1:5)
subjects = unique(data_reduced.VP)'; %subjects
data_reduced= average_dream_subjects(data_reduced,stage,subjects);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
