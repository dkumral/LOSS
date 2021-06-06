%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%averaging across awakenings: PSD (residual), audiobooks, and
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/combined_data.mat');

for stg = 1:5
    for subj = 1:20
        clear ind PSD_mean
        PSD = [];
        PSDXX = [];
        ind = find(combined_data.VP == (subj+1)); %find the subject
        for ch = 1:32
            for i = 1:length(ind)
                PSD_xx = combined_data.PSD_avg_epoch{ind(i),stg}(ch,:); %arrange for the original PSD
                PSDXX = vertcat(PSDXX, PSD_xx); % combine all CH1 for all awakenings
                PSD_mean_org(ch,:) = nanmean(PSDXX,1); % channel averaging the channel across each awakenings
                
                PSD_x = combined_data.Pows(ind(i),1).res{1, stg}(ch,:);
                PSD = vertcat(PSD, PSD_x); % combine all CH1 for all awakenings
                PSD_mean(ch,:) = nanmean(PSD,1); % channel averaging the channel across each awakenings
            end
        end
        data_reduced(subj).PSD{1, stg} = PSD_mean;
        data_reduced(subj).PSD_red{1, stg} = reshape(PSD_mean.',1,[])';
        
        data_reduced(subj).PSD_org{1, stg} = PSD_mean_org;
        data_reduced(subj).PSD_red_org{1, stg} = reshape(PSD_mean_org.',1,[])';

        data_reduced(subj).VP = (subj+1);
        data_reduced(subj).audibook = combined_data.audiobook(ind(end));
    end
end

data_reduced = struct2table(data_reduced);
save data_reduced_PSD data_reduced
%%