%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%implementing statistics: this script is attached to the permutation data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COMMPUTE BASED ON WECKUNGEN%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('combined_data_interpolate.mat');
rng(123)
data_com = combined_data((combined_data.Weckung)==1,:);
data_com = sortrows(data_com, 'audiobook','ascend');

VP = (data_com.VP);
Weckung = (data_com.Weckung);
audiobook = data_com.audiobook;
%PSD = data_com.PSD_red_org; %original
PSD = data_com.PSD_res; %resudial
stat = 'both';
nperm =1001; %number of permutation
sz = size(data_com,1);
stage = 1:5;
[p, observeddifference] = permutation_6_V2(PSD, nperm, sz, VP, audiobook, stat,stage)
[p, observeddifference] = permutation_6(PSD, nperm, sz, VP, audiobook, stat,stage, Weckung)
[p, observeddifference] = permutation_6_V3(PSD, nperm, sz, VP, audiobook, stat,stage)
%SWS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
data_com = combined_data((combined_data.Weckung)==1,:);
sz = size(data_com,1);
VP = (data_com.VP);
Weckung = (data_com.Weckung);
audiobook = data_com.audiobook;
PSD = data_com.PSD_res; %resudial
stat = 'both';
nperm =1001; %number of permutation

s = 3:4
 for i=1:sz
     PSD2{i,1}= nanmean(cell2mat(PSD(i,s)),2)
     PSD2{i,2}= PSD{i,5};
 end
stage = 1:2;
[p, observeddifference] = permutation_6_V2(PSD2, nperm, sz, VP, audiobook, stat,stage)

%AVERAGED DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
load('data_reduced_interpolate.mat');
data_reduced = sortrows(data_reduced, 'audiobook','ascend');
sz = size(data_reduced,1);
PSD = data_reduced.PSD_res_red;

VP = data_reduced.VP; 
audiobook = data_reduced.audiobook;
stat = 'both';
stage = 1:5;
nperm =1001; %number of permutation
[p, observeddifference] = permutation_6_V2(PSD, nperm, sz, VP, audiobook, stat,stage)
[p, observeddifference] = permutation_6_V3(PSD, nperm, sz, VP, audiobook, stat,stage)
[p, observeddifference] = permutation_6(PSD,nperm,sz, VP, audiobook, stat, stage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
