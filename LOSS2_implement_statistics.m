%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%implementing statistics: this script is attached to the permutation data
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
rng(123, 'twister')
load('data_reduced.mat');
data_reduced = sortrows(data_reduced, 'audiobook','ascend'); %sorting basedon audiobook
sz = size(data_reduced,1); %size of individuals (participants, N=19)
PSD = data_reduced.PSD_res_red; %PSD dimension: sz (19) X stg (5) in cell format: each PSD is one dimension
VP = data_reduced.VP; %Versuch person
audiobook = data_reduced.audiobook; %audiobookinformation
stat = 'larger'; %implement the statistics: within>between
stage = 1%:5; %number of sleep stages (If it is a wake, change it as 1)
nperm =1000; %number of permutation
%%please dont forget to add brewermap package to the directory
[p, observeddifference] = permutation_RSA_matrix(PSD,nperm,sz, VP, audiobook, stat, stage)
[p, observeddifference] = permutation_leave_one_out3between_1within(PSD, nperm, sz, VP, audiobook,stat,stage)
[p, observeddifference] = permutation_leave_one_out1between_1within(PSD, nperm, sz, VP, audiobook, stat,stage)

nhalf = 15; %number of splitting
[observeddifference_mean,VP_new1, VP_new2,PSD1,PSD2,aud1,aud2]  = split_half(PSD, VP, audiobook,nhalf,stage)
[p]  = permutation_splithalf(PSD1,PSD2, nhalf, nperm, VP, VP_new1, VP_new2, aud1, aud2, audiobook, stat,stage,observeddifference_mean)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%