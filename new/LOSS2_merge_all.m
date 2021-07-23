%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute averaged PSD: each cycle and each person for each sleep stage
%save it to one file
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
addpath('//home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/')
fullfolder = '//home/kumral/Desktop/Projects/LOSS_analyses/preprocess/sleep/sharptool/sleep_fmax30_log1_reject0_reduce1_interpolate0norm_sharptool1/';
cd(fullfolder)
fullfiles=dir([fullfolder,'*.mat']); %add path

for i = 1:length(fullfiles)
    filename = fullfiles(i).name; %name of the file
    load(filename);
    data(i).filename = filename; %for naming
    data(i).VP = strtok(filename, "_"); %for naming
    flname = fliplr(filename); %flip naming
    data(i).Weckung = strtok(flname(8:9), "_");
    data(i).PSD_S_avg = PSD_S_avg;
    data(i).Stages_use_S = Stages_use_S; %stages info
    data(i).F = F; %frequency info
    data(i).dim_PSD_total = dim_PSD_total'; %dimension total
    data(i).dim_PSD_wake = dim_PSD'; %dimension of PSDwake
    data(i).dim_PSD_sleep = dim_PSD_total- dim_PSD;  %dimension of PSD sleep
    data(i).S254_latencies_end = S254_latencies'; %ofset for audiobook
    data(i).S254_latencies_epoch = S254_latencies_epoch'; %onset for audiobook as epoch
    data(i).S255_latencies_start = S255_latencies';%onset for audiobook
    data(i).S255_latencies_epoch = (S255_latencies)/1000/4; %onset for audiobook as epoch
    data(i).differences_latencybtwwake = round(S254_latencies_epoch)-dim_PSD %differences between wake epoch and audiobook epoch

end
save('data_all.mat', 'data', '-v7.3')
%%