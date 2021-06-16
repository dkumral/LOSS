%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSD data combine: wakeful and sleep with sleep stages, rejected epochs and
%channels, this script also includes the dimension reduction (to 32
%channel), connected to reduce_dimension function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
%addpath('C:\Users\neurointern\Data\Experiment\Eddie2\EEG_raw')
%addpath('C:\Users\neurointern\Data\Experiment\Eddie2\03_PSDData')
filesDir = '/home/kumral/Desktop/Projects/LOSS_analyses/PSD_data/full_PSD/';
%filesDir='C:\Users\neurointern\Data\git\Eddie\LOSS\Loss_analysis';
%%
for cyc = 1:5
    % clear filenameS filenameW i PSD_W PSD_S F_W F_S sleep_S sleep_W Stages_S
    for vp =  2:21
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
                filenameW = sprintf('LOSS_VP0%d_%d-rejected-wake.set',vp,cyc);
            else
                filenameW = sprintf('LOSS_VP%d_%d-rejected-wake.set',vp,cyc);
            end
            
            load(filenameW, '-mat');
            Stages_W = EEG.stats.sleep_trial;
            rejE_W=EEG.reject.rejglobal;
            rejC_W = EEG.reject.rejglobalC;
            
            if vp<10
                filenameM = sprintf('LOSS_VP0%d_%d_PSD.mat', vp,cyc );
            else
                filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', vp,cyc );
            end
            
            load(filenameM)
            F = F;
            PSD_W_S = PSD;
            PSD_W_S_red = reduce_dimension(rejC_W, rejC_S, rejE_W, PSD_W_S); %reduce dimension

            
            use_W= EEG.stats.usetrials;
            Stages_use_W = [Stages_W,use_W];
            Stages_use_S= [Stages_S,use_S];
            rejE_all=[rejE_W rejE_S];
            
            save(fullfile(filesDir, sprintf('VP%d_%d_PSD_stages.mat',vp,cyc)), 'Stages_use_S','Stages_use_W','PSD_W_S', 'F','PSD_W_S_red','rejE_S','rejE_W', 'rejE_all', 'rejC_S', 'rejC_W');
        else
            display('no data');
        end
    end
end
%% Does the same thing as the cell before, but here bad channels are replaced via interpolation
for cyc = 1:5
    % clear filenameS filenameW i PSD_W PSD_S F_W F_S sleep_S sleep_W Stages_S
    for vp =  2%:21
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
                filenameW = sprintf('LOSS_VP0%d_%d-rejected-wake.set',vp,cyc);
            else
                filenameW = sprintf('LOSS_VP%d_%d-rejected-wake.set',vp,cyc);
            end
            
            load(filenameW, '-mat');
            Stages_W = EEG.stats.sleep_trial;
            rejE_W=EEG.reject.rejglobal;
            rejC_W = EEG.reject.rejglobalC;
            
            if vp<10
                filenameM = sprintf('LOSS_VP0%d_%d_PSD.mat', vp,cyc );
            else
                filenameM = sprintf('LOSS_VP%d_%d_PSD.mat', vp,cyc );
            end
            
            load(filenameM)
            F = F;
            PSD_W_S = PSD;
            use_W= EEG.stats.usetrials;


            %%interpolation, separated for wake and sleep%%
            %wake
            PSD_W = PSD_W_S(:,:,1:length(use_W));
            dim_PSD_W=size(PSD_W);
            PSD_W = reshape(PSD_W,dim_PSD_W(1),dim_PSD_W(2)*dim_PSD_W(3));
            PSD_W = egb_interp(PSD_W,EEG.chanlocs,~rejC_W,'nearest');
            PSD_W = reshape(PSD_W,dim_PSD_W(1),dim_PSD_W(2),dim_PSD_W(3));
            
            %sleep
            PSD_S = PSD_W_S(:,:,length(use_W)+1:end);
            dim_PSD_S=size(PSD_S);
            PSD_S = reshape(PSD_S,dim_PSD_S(1),dim_PSD_S(2)*dim_PSD_S(3));
            PSD_S = egb_interp(PSD_S,EEG.chanlocs,~rejC_S,'nearest');
            PSD_S = reshape(PSD_S,dim_PSD_S(1),dim_PSD_S(2),dim_PSD_S(3));
            
            %put back together
            PSD_W_S=cat(3, PSD_W, PSD_S);

            PSD_W_S_red = reduce_dimension_interpolated(rejE_W, PSD_W_S); %reduce dimension

            Stages_use_W = [Stages_W,use_W];
            Stages_use_S= [Stages_S,use_S];
            rejE_all=[rejE_W rejE_S];

            
            save(fullfile(filesDir, sprintf('VP%d_%d_PSD_interpolated_stages.mat',vp,cyc)), 'Stages_use_S','Stages_use_W','PSD_W_S', 'F','PSD_W_S_red','rejE_S','rejE_W', 'rejE_all', 'rejC_S', 'rejC_W');
        else
            display('no data');
        end
    end
end