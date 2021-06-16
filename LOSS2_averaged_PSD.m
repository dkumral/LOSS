%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%compute averaged PSD: each cycle and each person for each sleep stage
%save it to one file
%%
clear all
addpath('/home/kumral/Desktop/Projects/LOSS_analyses/PSD_data/full_PSD/')
%addpath('C:\Users\neurointern\Data\git\Eddie\LOSS\Loss_analysis')
fullfolder = '/home/kumral/Desktop/Projects/LOSS_analyses/PSD_data/full_PSD/';
%fullfolder = 'C:\Users\neurointern\Data\git\Eddie\LOSS\Loss_analysis\';
fullfiles=dir([fullfolder,'*.mat']);

for i = 1:81
    filename = fullfiles(i).name; %name of the file
    load(filename);
    
    %Normal Sleep all
    PSD_S_ALL = PSD_W_S_red(:,F>=0.05 & F<=45,:); % taking only <45 Hz %%% should change the argument to F%%%
    ind = Stages_use_S(:,2);
    PSD_S_ALL =PSD_S_ALL(:,:,ind);
    PSD_S_ALL(:,:,find(rejE_S))=NaN;
    
    PSD_S = nanmean(PSD_S_ALL,3); % %take the mean in 3rd dimension: epochs
    
    %DEPENDING ON SLEEP STAGES
    for stg = 1:5
        Stages_S = Stages_use_S(:,1);
        PSD = PSD_S_ALL(:,:,Stages_S==stg); %PSD_S depending on sleep stages
        PSD_avg_epoch = nanmean(PSD,3); % %take the mean in 3rd dimension: epochs
        total_stg(stg) = sum(Stages_S==stg);     %count how many times it is stg
        data(i).PSD_avg_epoch{stg} = PSD_avg_epoch;
    end
    
    %DEPENDING ONlY SWS
    PSD_SWS = PSD_S_ALL(:,:,Stages_S==3 | Stages_S==4);%%%that probably needs to be an or operator%%%
    PSD_SWS = nanmean(PSD_SWS,3);

    %NON-REM
    PSD_NONREM = PSD_S_ALL(:,:,Stages_S== 2 | Stages_S==3 | Stages_S==4);%%%that probably needs to be an or operator, also why not 1?%%%
    PSD_NONREM = nanmean(PSD_NONREM,3);
    
    %wake
    PSD_W_ALL = PSD_W_S_red(:,F>=0.05 & F<=45,:); % taking only <45 Hz %%%probably need to change the argument%%%
    indW = Stages_use_W(:,2);
    PSD_W_ALL =PSD_W_ALL(:,:,indW);
    PSD_W_ALL(:,:,find(rejE_W))=NaN;
    PSD_W = nanmean(PSD_W_ALL,3); % %take the mean in 3rd dimension: epochs
    Stages_W = Stages_use_W(:,1);
    total_awake = sum(Stages_W==0);     %count how many times it is stg
    
    F_int=F(F>=0.5&F<=45);
    data(i).filename = filename; %for naming
    data(i).VP = strtok(filename, "_"); %for naming
    flname = fliplr(filename); %flip naming
    data(i).Weckung = strtok(flname(15:20), "_");
    data(i).original = PSD_W_S;
    data(i).originalRed = PSD_W_S_red;
    data(i).Stages_use_S = Stages_use_S;
    data(i).Stages_use_W = Stages_use_W;
    data(i).F = F_int;
    
    data(i).PSD_avg_awake = PSD_W;
    data(i).PSD_SWS = PSD_SWS;
    data(i).PSD_NONREM = PSD_NONREM;
    data(i).PSD_avg_sleep= PSD_S;
    data(i).total_sleepstage = total_stg';
    data(i).total_awake = total_awake';
end
save('data_PSD_averaged.mat', 'data', '-v7.3')
%%