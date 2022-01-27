%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this script is to create the average for nondream and dream condition for
%each individual subject based on full data that we have
function data_reduced =average_dream_subjects(data_reduced, stage,subjects)

for stg = stage
    for subj = subjects
        clear T_ind dream dream_PSD  Ndream Ndream_PSD
        T_ind = data_reduced(find(data_reduced.VP == (subj)),:);
        dream = T_ind(find(T_ind.dream ==1),:); %find the dream conditions
        dream_PSD = nanmean([(dream.PSD_res_red{:,stg})],2);  %take the nanmean of the PSDs
        dreamT(subj).VP = subj;
        dreamT(subj).PSD{1, stg} = dream_PSD;
        dreamT(subj).dream = 1;
        Ndream = T_ind(find(T_ind.dream ==2),:); %find the dream conditions
        Ndream_PSD = nanmean([(Ndream.PSD_res_red{:,stg})],2);  %take the nanmean of the PSDs
        NdreamT(subj).VP = subj;
        NdreamT(subj).PSD{1, stg} = Ndream_PSD;
        NdreamT(subj).dream = 2;
    end
end

tableall = [dreamT,NdreamT];
tableall = tableall(~cellfun(@isempty,{tableall.dream}));
tablealls = struct2table(tableall);
tablealls.Properties.VariableNames{2} = 'PSD_res_red';


idx=all(cellfun(@isempty,tablealls.PSD_res_red),2);
ind = find(idx == 1)';

for x = ind
    for stg = stage
        tablealls.PSD_res_red{x,stg} = NaN(size(tablealls.PSD_res_red{1,stg}));
    end
end

data_reduced = tablealls;
data_reduced = sortrows(data_reduced, 'VP','ascend'); %sorting basedon audiobook
save data_reduced_dream data_reduced
end