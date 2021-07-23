%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%averaging across awakenings: PSD (residual), audiobooks, and
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
load('//home/kumral/Desktop/Projects/LOSS_analyses/preprocess/sleep/sharptool/sleep_fmax30_log1_reject0_reduce1_interpolate0norm_sharptool1/data_all_behavior.mat');

%%%%%%change/make NaN the participants 9, 4th weckung, since this subject has
%%%%%%different book

ind = find(combined_data.VP == 9 & combined_data.Weckung ==4);

for stg = 1:5
    combined_data.PSD_S_avg{ind,1}   =NaN(size(combined_data.PSD_S_avg{ind,1}));
end

for stg = 1:5
    for subj = 1:20
        clear ind PSD_mean
        PSD = [];
        ind = find(combined_data.VP == (subj+1)); %find the subject
        for ch = 1:32
            for i = 1:length(ind)                
                PSD_x = combined_data.PSD_S_avg{ind(i),1}(ch,:,stg);
                PSD = vertcat(PSD, PSD_x); % combine all CH1 for all awakenings
                PSD_mean(ch,:) = nanmean(PSD,1); % channel averaging the channel across each awakenings
            end
        end
        data_reduced(subj).PSD{1, stg} = PSD_mean;
        data_reduced(subj).PSD_res_red{1, stg} = reshape(PSD_mean.',1,[])';        
        data_reduced(subj).VP = (subj+1);
        data_reduced(subj).audiobook = combined_data.audiobook(ind(1));
    end
end

data_reduced = struct2table(data_reduced);
save data_reduced data_reduced
%%