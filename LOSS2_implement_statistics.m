%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%implementing statistics: this script is attached to the permutation data
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all 
close all
addpath('/home/kumral/Desktop/Projects/LOSS_analyses/')  
%%please dont forget to add brewermap package to the directory
condition = 'audiobook';
mkdir(condition);
%%
%%arrange the conditions
if isequal(condition,'dream') %reduce the time before awakening
    load('data_reduced_dream.mat') %38
    parameters = data_reduced.dream; %dream information: 1 or 2   
elseif isequal(condition,'full_dream') 
    load('data_reduced_full.mat') %%it should be person ordered 3,3,3,3,4,4,4,4:this is important for permutation 
    data_reduced = sortrows(data_reduced,'VP','ascend');
    data_reduced.dream(data_reduced.dream==0) = 2;
    parameters = data_reduced.dream; %dream information: or 2
elseif isequal(condition,'audiobook')
    load('data_reduced.mat')
    parameters = data_reduced.audiobook; %audiobookinformation
elseif isequal(condition,'full_audiobook') %it should be person ordered 3,3,3,3,4,4,4,4:this is important for permutation 
    load('data_reduced_full.mat')
    parameters = data_reduced.audiobook; %audiobookinformation
end
cd(condition)
sz = size(data_reduced,1); %size of individuals (participants or documents)
%%
%%compute the SWSor NonREM
for i=1:sz
    PSD2 = data_reduced.PSD_res_red{i,2};
    PSD3 = data_reduced.PSD_res_red{i,3};
    PSD4 = data_reduced.PSD_res_red{i,4};
    PSDSWS = nanmean([PSD3,PSD4],2);
    data_reduced.PSD_res_red{i,6}   = PSDSWS;
    PSDNONREM = nanmean([PSD2,PSD3,PSD4],2);
    data_reduced.PSD_res_red{i,7}   = PSDNONREM; %2 3 4
end
clear PSD3 PSD2 PSD4 PSDSWS PSDNONREM
%%
%analyses parameters
searchlight = 'no';
stat = 'larger'; %implement the statistics: within>between
PSD = data_reduced.PSD_res_red; 
VP = data_reduced.VP; %Versuch person
stage = [5]; % sleep stages (REM = 5, NREM = 7)
nperm =1000; %number of permutation [in the script it is nperm+1]
%%
%permutation for individual PSD shuffling
[p, observeddifference] = permutation_RSA_matrix(PSD,nperm,sz, VP, parameters, stat, stage,searchlight)
[p, observeddifference] = permutation_leave_one_out3between_1within(PSD, nperm, sz, VP, parameters,stat,stage,searchlight)
%%
%Frequency of interests analyses (FOI)
%searchlight analyses depending on frequency of the audiobook÷ PSD shuffling
searchlight = 'freq';
stage = 5; % Rem Sleep
mkdir searchlight_foi
cd searchlight_foi
currentFolder = pwd;
ROI = [];
r = [];
frangeAll = [0.5,3.5; 4,7.5 ; 8,10.5;18,30]; % Frequency of interests 

for ifreq=1:size(frangeAll,1)
    fileName = [num2str(frangeAll(ifreq,1)),'_',num2str(frangeAll(ifreq,2))];
    mkdir(fileName)
    cd(fileName)
    [p, observeddifference] = permutation_RSA_matrix(PSD,nperm, sz, VP, parameters, stat, stage,searchlight, ROI,r,frangeAll,ifreq);
    [p, observeddifference] = permutation_leave_one_out3between_1within(PSD,nperm, sz, VP, parameters, stat, stage, searchlight,ROI,r,frangeAll,ifreq)
    cd(currentFolder)
end 
%%
%Frequency of interests analyses (FOI): version 2
%here we remove the rest of the FOI range, and keep only FOI (e.g., only beta frequency remains in the main)
searchlight = 'no';
stage = [5]
mkdir searchlight_onlyfoi
cd searchlight_onlyfoi
currentFolder = pwd;
frangeAll = [0.5,3.5; 4,7.5 ; 8,10.5;18,30]; % Frequency of interests 
F=0.5:0.5:30;
for ifreq=1:size(frangeAll,1)
    values = 1:length(PSD{1, stage(1)});
    loc = find(F>=frangeAll(ifreq,1) & F<=frangeAll(ifreq,2));
    for k = 1:length(loc)
        main_loc(k,:) = loc(k):length(F):length(PSD{1, stage(1)});
        main_loc2 = reshape(main_loc,[],1); %find the corresponding frequency
    end
    % main_loc3 = ~ismember(values', main_loc2); %take not other frequencies
    for stg = stage
        for i=1:sz
            PSD_2{i,stg}= PSD{i,stg}(main_loc2,1);
        end
    end
    fileName = [num2str(frangeAll(ifreq,1)),'_',num2str(frangeAll(ifreq,2))];
    mkdir(fileName)
    cd(fileName)
    [p, observeddifference] = permutation_RSA_matrix(PSD_2,nperm,sz, VP, parameters, stat, stage,searchlight)
    [p, observeddifference] = permutation_leave_one_out3between_1within(PSD_2,nperm,sz, VP, parameters, stat, stage,searchlight)
    cd(currentFolder)
    clear PSD_2 main_loc2 main_loc
end
%%
%this is for the ROI analyses
%drive the rois based on 128 channels%
ROI{1} = [48,49,13,15,47,50,112,113,111,114,110,115,19,20,52,54,18,21,53,14,9,10,43,44,8,11,76,77,75,78,74,79]; %central
ROI{2} = [23,24,25,26,27,56,57,58,59,84,85,86,87,88,89,117,118,119,120,121,122,123,124]; %parietal
ROI{3} = [1,2,3,4,5,6,7,33,34,35,36,37,38,39,40,65,66,67,68,69,70,71,97,98,99,100,101,102,103,104,105,106,107,108]; %frontal
ROI{4} = [28,29,30,31,32,60,61,62,63,64,92,93,94,95,96,125,126,127,128]; %occpital
ROI{5} = [12,16,17,22,41,42,45,46,51,55,72,73,80,81,82,83,90,91,109,116]; %temporal
ROI{6}= [1:128] %full brain
%%
%this section is only for running searchlight ROI: searchlightROI
ifreq = [];
frangeAll = [];
searchlight = 'channel';
stage =[5] %REM
mkdir searchlight_channel
cd searchlight_channel
currentFolder = pwd;
for r = 1:5%size(ROI,2)
    mkdir(num2str(r))
    cd(num2str(r))
    [p, observeddifference] = permutation_RSA_matrix(PSD,nperm, sz, VP, parameters, stat, stage,searchlight, ROI,r,frangeAll,ifreq)
    [p, observeddifference] = permutation_leave_one_out3between_1within(PSD,nperm, sz, VP, parameters, stat, stage, searchlight,ROI,r,frangeAll,ifreq)
    cd(currentFolder)
end 
%%
%Regions of interests analyses (ROI): version 2
%here we remove the rest of the ROI range, and keep only ROI (e.g., only frontal remains in the main)
searchlight = 'no';
stage = [5];
mkdir searchlight_onlychannel
cd searchlight_onlychannel
currentFolder = pwd;
for r = 1:size(ROI,2)
    for i = 1:sz
        for stg = stage
            channel = PSD{i,stg} ;
            PSD_2dim = reshape(channel,[60,128]); %make it as 2 dimension 60 Hz x 128 channel
            PSD_ROI{i,stg} = PSD_2dim(:,ROI{r}); % 60 Hz x selecting regions of interests
            PSD_1dim{i,stg} = reshape(PSD_ROI{i,stg},1,[])'; %make it as 2 dimension 60 Hz x 128 channel
        end
    end
    
    mkdir(num2str(r))
    cd(num2str(r))
    [p, observeddifference] = permutation_RSA_matrix(PSD_1dim,nperm,sz, VP, parameters, stat, stage,searchlight)
    [p, observeddifference] = permutation_leave_one_out3between_1within(PSD_1dim,nperm,sz, VP, parameters, stat, stage,searchlight)
    cd(currentFolder)
    clear PSD_2dim PSD_1dim PSD_ROI
end
%%
%this section is only for running searchlight ROI + FOI based on shuffling
%here we use beta frequency range as FOI, because this FOI was significant
%full range is whether sanity check
searchlight = 'both';
stage = 5; % REM
mkdir searchlightboth
cd searchlightboth
currentFolder = pwd;
frangeAll = [0.5,30; 18,30]; % frequency of interests
for ifreq=1:size(frangeAll,1)
    fileName = [num2str(frangeAll(ifreq,1)),'_',num2str(frangeAll(ifreq,2))];
    mkdir(fileName)
    cd(fileName)
    for r = 1:size(ROI,2)
        currentFolder2 = pwd;
        mkdir(num2str(r))
        cd(num2str(r))
      %  [p, observeddifference] = permutation_RSA_matrix(PSD,nperm, sz, VP, parameters, stat, stage,searchlight, ROI,r,frangeAll,ifreq)
        [p, observeddifference] = permutation_leave_one_out3between_1within(PSD,nperm, sz, VP, parameters, stat, stage, searchlight,ROI,r,frangeAll,ifreq)
        cd(currentFolder2)
    end
   cd(currentFolder)
end

%%
%Regions of interests analyses (ROI) + frequency of interests: version 2
%here we remove the rest of the ROI+FOI range, and keep only ROI + FOI (e.g., only frontal remains in the main)
searchlight = 'no';
stage = [5];

mkdir searchlightboth_only
cd searchlightboth_only
frangeAll = [0.5,30; 18,30]; % frequency of interests
F=0.5:0.5:30; %this is for the frequency range


for r = 1:size(ROI,2) %number of ROIs
    for ifreq=2%:size(frangeAll,1)
        loc = find(F>=frangeAll(ifreq,1) & F<=frangeAll(ifreq,2)); %find the frequency range
        for k = 1:length(loc)
            main_loc(k,:) = loc(k):length(F):length(PSD{1, stage(1)});
            main_loc2 = reshape(main_loc,[],1); %find the main location of that frequency range as index form
        end
        
        values = 1:length(PSD{1, stage(1)});
        loc_nonfreq = ~ismember(values', main_loc2); %take other frequencies of interests
        loc_freq = ismember(values', main_loc2); %take not other frequencies
        clear main_loc
        %this is for the channel ROI range
        
        start = 1:length(F):length(PSD{1,stage(1)});
        ending = length(F):length(F):length(PSD{1, stage(1)});
        for s = 1:size(ROI{r},2) %number of channel
            Chrange(:,s) = [start(ROI{r}(s)):ending(ROI{r}(s))]; %channel range %chnnel for interests
        end
        
        main_loc_r = reshape(Chrange,[],1); %find the main location of that frequency range
        loc_nonROI = ~ismember(values', main_loc_r); %take other frequencies of interests
        loc_ROI = ismember(values', main_loc_r); %take not other frequencies
        
        %overlap for freq and ROI
        for m = 1:length(PSD{1, stage(1)})
            if(loc_freq(m) && loc_ROI(m) == 1)
                ovrl_freq_ROI(m,1)=1;
            else
                ovrl_freq_ROI(m,1)=0;
            end
        end
        ovrl_freq_ROI = logical(ovrl_freq_ROI);

        for stg = stage
            for i=1:sz
                PSD_2{i,stg}= PSD{i,stg}(ovrl_freq_ROI,1);
            end
        end

        currentFolder = pwd;
        mkdir(num2str(r))
        cd(num2str(r))
        fileName = [num2str(frangeAll(ifreq,1)),'_',num2str(frangeAll(ifreq,2))];
        mkdir(fileName)
        cd(fileName)
        %[p, observeddifference] = permutation_RSA_matrix(PSD_2,nperm,sz, VP, parameters, stat, stage,searchlight)
        [p, observeddifference] = permutation_leave_one_out3between_1within(PSD_2,nperm,sz, VP, parameters, stat, stage,searchlight)
        cd(currentFolder)
    end
     clear ovrl_freq_ROI loc_nonROI main_loc_r loc_ROI PSD_2
end
%%