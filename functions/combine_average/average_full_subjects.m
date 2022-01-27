%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this is for the full matrix: for creating also empty files: if 19 subject x 4
%weckungen, it will create 76 indivduals in which some of them are empty
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data_reduced =average_full_subjects(combined_data, stage,subjects, Weckung)

for stg = stage
    for i=1:size(combined_data,1)
        PSD_mean = combined_data.PSD_S_avg{i,1}(:,:,stg);
        combined_data.PSD_res_red{i,stg}   = reshape(PSD_mean.',1,[])';
    end
end


combined_data.dream(combined_data.dream==0) = 2; %change the nondream to 2

data_reduced = combined_data;
data_reduced = sortrows(data_reduced, 'Weckung','ascend'); %sorting basedon audiobook
data_reduced(find(data_reduced.Weckung ==5),:) = []; %we want to exclude  5th Weckungen

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this section is actually for adding empty information to the data
for subj = subjects
    ind = find(data_reduced.VP == (subj)); %find the subject
    data = data_reduced(ind,:); %have this subject as data format
    awakemissing=setdiff(Weckung,data.Weckung); %check the missing Weckung
    if size(data,1) < length(Weckung)
        toadd= length(Weckung)-size(data,1); %take the difference
        for t = 1:toadd
            data_reduced.PSD_res_red{end+t,1} = [];
            for stg = stage
                data_reduced.PSD_res_red{end,stg} = NaN(size(data_reduced.PSD_res_red{1,stg}));
                data_reduced.VP(end) = subj;
                data_reduced.audiobook(end) = data.audiobook(1);
                data_reduced.dream(end) = 9999; %adding empty
                data_reduced.Weckung(end) = awakemissing(t);
            end
        end
    else
        display('okey')
    end
end
clearvars -except data_reduced    %deletes all variables except X in workspace
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
data_reduced(find(data_reduced.dream== 0),:) = []; %remove the empty cells based on dream 0
indx = find(data_reduced.dream == 9999); %find the created files
num = length(indx);
data_reduced.dream(indx(1):floor(indx(num/2))) = 2; %add nondream
data_reduced.dream((floor(indx(num/2)+1):end)) = 1;%add dream
data_reduced = sortrows(data_reduced, 'Weckung','ascend'); %sorting basedon audiobook
data_reduced = sortrows(data_reduced, 'VP','ascend'); %sorting basedon audiobook
save data_reduced_full data_reduced
end