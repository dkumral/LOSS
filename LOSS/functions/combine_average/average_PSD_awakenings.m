function data_reduced = average_PSD_awakenings(combined_data, stage, subjects)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%averaging across awakenings: PSD (residual)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ind = find(combined_data.VP == 9 & combined_data.Weckung ==4); %%change/make NaN the participants 9, 4th weckung, since this subject has different book%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    combined_data.PSD_S_avg{ind,1} =NaN(size(combined_data.PSD_S_avg{ind,1}));
end

for stg = stage
    for subj = subjects
        clear ind PSD_mean
        PSD = [];
        ind = find(combined_data.VP == (subj)); %find the subject
        for ch = 1:size(combined_data.PSD_S_avg{1,1} ,1) %this should be either 32 or 128
            for i = 1:length(ind)
                PSD_x = combined_data.PSD_S_avg{ind(i),1}(ch,:,stg);
                PSD = vertcat(PSD, PSD_x); % combine all CH1 for all awakenings
                PSD_mean(ch,:) = nanmean(PSD,1); % channel averaging the channel across each awakenings
            end
        end
        data_reduced(subj).PSD{1, stg} = PSD_mean;
        data_reduced(subj).PSD_res_red{1, stg} = reshape(PSD_mean.',1,[])';
        data_reduced(subj).VP = (subj);
        data_reduced(subj).audiobook = combined_data.audiobook(ind(1));
        data_reduced(subj).dream = combined_data.dream(ind(1));

    end
end
data_reduced(1:2) = []
data_reduced = struct2table(data_reduced);
save data_reduced data_reduced

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%visualization%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F = combined_data.F(1,:);
for subj=1:19
    close all
    t = tiledlayout(1, size(stage,2));
    set(gcf, 'PaperUnits', 'inches');
    x_width=28 ;y_width=7;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    dir = strcat(string(data_reduced.VP(subj)),'_averaged_PSD');
    for stg = stage
        nexttile()
        for ch = 1:size(combined_data.PSD_S_avg{1,1} ,1)
            command = [ 'disp(''x ' num2str(ch) ''')' ];
            hold on
            plot(F', data_reduced.PSD{subj, stg}(ch,:))
        end
        saveas(t, fullfile(dir), 'jpeg')
    end
end

end
%%