%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%implementing statistics: this script is attached to the permutation data
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%AVERAGED DATA%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
rng(999)
load('data_reduced.mat');
data_reduced = sortrows(data_reduced, 'audiobook','ascend');
sz = size(data_reduced,1);
PSD = data_reduced.PSD_res_red;
VP = data_reduced.VP; 
audiobook = data_reduced.audiobook;
stat = 'larger';
stage = 1:5
nperm =1000; %number of permutation
[p, observeddifference] = permutation_6(PSD,nperm,sz, VP, audiobook, stat, stage)
[p, observeddifference] = permutation_6_V2(PSD, nperm, sz, VP, audiobook, stat,stage)
[p, observeddifference] = permutation_6_V3(PSD, nperm, sz, VP, audiobook,stat,stage)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%assign random number
% rng(999)
% for stg= 1:5
%     for i= 1:20
%         PSD{i,stg} = rand(100,1)
%     end
% end
% sz = 20;
% VP = data_reduced.VP;
% audiobook = data_reduced.audiobook;
% stat = 'larger';
% stage = 1:5;
% nperm =1000; %number of permutation
% [p, observeddifference] = permutation_6(PSD,nperm,sz, VP, audiobook, stat, stage)
% [p, observeddifference] = permutation_6_V2(PSD, nperm, sz, VP, audiobook, stat,stage)
% [p, observeddifference] = permutation_6_V3(PSD, nperm, sz, VP, audiobook,stat,stage)