%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute averaged PSD: each cycle and each person for each sleep stage
%save it to one file
%%
clear all
addpath('//home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/')
fullfolder = '/home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/';
fullfiles=dir([fullfolder,'*.mat']);
nmin = 0.05;
nmax=30;

for i = 1:81
    filename = fullfiles(i).name; %name of the file
    load(filename);
    
    %Normal Sleep all
    PSD_S_ALL = PSD_S_red(:,F>=nmin & F<=nmax,:); % taking only <nmax Hz %%% should change the argument to F%%%
    PSD_S_ALL(:,:,find(rejE_S==1))=NaN;
    total_rejected  = sum(rejE_S==1);     %count how many times it is stg

    %DEPENDING ON SLEEP STAGES
    for stg = 1:5
        Stages_S = Stages_use_S(:,1);
        PSD_rej = PSD_S_ALL(:,:,Stages_S==stg); %PSD_S depending on sleep stages
        rejected_epochs(stg) = sum(isnan(PSD_rej(1,1,:)));
        PSD_avg_epoch_rej = nanmean(PSD_rej,3); % %take the mean in 3rd dimension: epochs
        total_stg(stg) = sum(Stages_S==stg);     %count how many times it is stg
        data(i).PSD_avg_epoch_rej{stg} = PSD_avg_epoch_rej;
    end
    
    
     %DEPENDING ON SLEEP STAGES
    for stg = 1:5
        Stages_S = Stages_use_S(:,1);
        PSD = PSD_S_red(:,F>=nmin & F<=nmax,Stages_S==stg); %PSD_S depending on sleep stages
        PSD_avg_epoch = nanmean(PSD,3); % %take the mean in 3rd dimension: epochs
        data(i).PSD_avg_epoch{stg} = PSD_avg_epoch;
    end
    
    F_int=F(F>=nmin&F<=nmax);
    data(i).filename = filename; %for naming
    data(i).VP = strtok(filename, "_"); %for naming
    flname = fliplr(filename); %flip naming
    data(i).Weckung = strtok(flname(29:32), "_");
    data(i).original = PSD_S;
    data(i).originalRed = PSD_S_red;
    data(i).originalRed_epochrej = PSD_S_ALL;
    data(i).Stages_use_S = Stages_use_S;
    data(i).F = F_int;
    data(i).total_rejected = total_rejected';
    data(i).total_rejected_epochs = rejected_epochs';
    data(i).total_sleepstage = total_stg';
end
save('data_PSD_averaged_interpolated_30.mat', 'data', '-v7.3')
%%