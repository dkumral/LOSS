%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% visualize the predicted and real PSD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('/home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/data_PSD_averaged_slope_interpolated.mat')
F = data(1).F';
dir = '/home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/'
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%visualize real PSDs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for subj=1%:81
    close all
    t = tiledlayout(1, 5);
    set(gcf, 'PaperUnits', 'inches');
    x_width=28 ;y_width=7;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    dir = strcat(data(subj).filename(1:10),'_real_rejected_epochs_interpolated_30');
    for stg = 1:5
        nexttile()
        for n = 1:32
            command = [ 'disp(''x ' num2str(n) ''')' ];
            hold on
            try
                plot(F, log10(data(subj).PSD_avg_epoch_rej{1, stg}(n,:)))
            catch
                plot(F, log10(data(subj).PSD_avg_epoch_rej{1, stg}))
            end
            docName = ['PSD real ', num2str(stg) ];
            title(docName)
        end
        saveas(t, fullfile(dir), 'jpeg')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%visualize real PSDs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for subj=1:81
    close all
    t = tiledlayout(1, 5);
    set(gcf, 'PaperUnits', 'inches');
    x_width=28 ;y_width=7;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    dir = strcat(data(subj).filename(1:10),'_real_notrejected_epochs_interpolated_30');
    for stg = 1:5
        nexttile()
        for n = 1:32
            command = [ 'disp(''x ' num2str(n) ''')' ];
            hold on
            try
                plot(F, log10(data(subj).PSD_avg_epoch{1, stg}(n,:)))
            catch
                plot(F, log10(data(subj).PSD_avg_epoch{1, stg}))
            end
            docName = ['PSD real ', num2str(stg) ];
            title(docName)
        end
        saveas(t, fullfile(dir), 'jpeg')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%visualize res PSDs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
F= data(1).Pows.frex_red{1, 1}(1,4:end);
for subj=1:81
    close all
    t = tiledlayout(1, 5);
    set(gcf, 'PaperUnits', 'inches');
    x_width=28 ;y_width=7;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    dir = strcat(data(subj).filename(1:10),'_res_corrected_30');
    for stg = 1:5
        nexttile()
        for n = 1:32
            command = [ 'disp(''x ' num2str(n) ''')' ];
            hold on
            try
                plot(F, rescale(data(subj).Pows.res_red{1, stg}(n,4:end)))
            catch
                plot(F, rescale(data(subj).Pows.res_red{1, stg}(n,4:end)))
            end
            docName = ['PSD 1/F Corrected ', num2str(stg) ];
            title(docName)
        end
        saveas(t, fullfile(dir), 'jpeg')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%visualize the number of epochs for each cycle%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

