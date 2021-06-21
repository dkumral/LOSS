%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSD data combine: wakeful and sleep with sleep stages, rejected epochs and
%channels, this script also includes the dimension reduction (to 32
%channel), connected to reduce_dimension function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
filesDir = '/home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/';
%% Does the same thing as the cell before, but here bad channels are replaced via interpolation
for cyc = 1:5
    % clear filenameS filenameW i PSD_W PSD_S F_W F_S sleep_S sleep_W Stages_S
    for vp = 2:21
        if vp<10
            filenameS = sprintf('LOSS_VP0%d_%d-rejected-sleep.set',vp,cyc);
        else
            filenameS = sprintf('LOSS_VP%d_%d-rejected-sleep.set',vp,cyc);
        end
        if exist(filenameS, 'file') == 2
            load(filenameS, '-mat');
            Stages_S = EEG.stats.sleep_trial;
            use_S = EEG.stats.usetrials;
            rejE_S = EEG.reject.rejglobal;
            rejC_S = EEG.reject.rejglobalC;
            
            if vp<10
                filenameM = sprintf('LOSS_VP0%d_%d_PSD.mat', vp,cyc );
            else
                filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', vp,cyc );
            end
            
            load(filenameM)
            F = F;
            
            %%interpolation, sleep%%
            %sleep
            PSD_S = PSD(:,:,use_S);
            dim_PSD_S=size(PSD_S);
            PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2)*dim_PSD_S(3)]);
            PSD_S = egb_interp(PSD_S,EEG.chanlocs,~rejC_S,'nearest');
            PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2),dim_PSD_S(3)]);
            
            %put back together
            PSD_S_red = reduce_dimension_interpolated(PSD_S); %reduce dimension
            
            
            for n = 1:32
                command = [ 'disp(''x ' num2str(n) ''')' ];
                hold on
                meanPSD= mean(PSD_S_red,3);
                plot(F, log10(meanPSD(n,:)))
            end
            saveas(gcf, fullfile(filenameS(1:12)), 'jpeg')
            close all
            
            
            Stages_use_S= [Stages_S,use_S];
            rejE_S=[rejE_S];
            
            save(fullfile(filesDir, sprintf('VP%d_%d_PSD_interpolated_stages.mat',vp,cyc)), 'Stages_use_S', 'F','PSD_S_red','rejE_S', 'rejC_S', 'PSD_S');
        else
            display('no data');
        end
    end
end