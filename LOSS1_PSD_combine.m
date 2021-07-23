%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%PSD data combine: wakeful and sleep with sleep stages, rejected epochs and
%channels, this script also includes the dimension reduction (to 32
%channel), connected to reduce_dimension function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all
addpath('/home/kumral/neurostorage/LOSS/EEG_raw/')
filesDir = '/home/kumral/Desktop/Projects/LOSS_analyses/interpolated_PSD/';
nmin = 0.05;
nmax=30;

            
%% Does the same thing as the cell before, but here bad channels are replaced via interpolation
for cyc = 2%:5
    % clear filenameS filenameW i PSD_W PSD_S F_W F_S sleep_S sleep_W Stages_S
    for vp = 13%:21
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
            Stages_use_S= [Stages_S,use_S];
            rejE_S=[rejE_S];
      
            %sleep and log transformation
            PSD_S = PSD(:,F>=nmin & F<=nmax,:); % taking only <nmax Hz %%% should change the argument to F%%%
            PSD_S = PSD_S(:,:,use_S); %sl  data            dim_PSD_S=size(PSD_S);
            dim_PSD_S=size(PSD_S);

            
            %Averaging over channels   %%interpolation, 
           %PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2)*dim_PSD_S(3)]);
          % PSD_S = egb_interp(PSD_S,EEG.chanlocs,~rejC_S,'nearest');
          % PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2),dim_PSD_S(3)]);
            
            
            %PSD_S(:,:,find(rejE_S==1))=NaN; %rejected data
            
            PSD_S = log(PSD_S);                        % log transformation
                
            %DEPENDING ON SLEEP STAGES
            for stg = 1:5
                Stages_S = Stages_use_S(:,1);
                PSD_rej = PSD_S(:,:,Stages_S==stg); %PSD_S depending on sleep stages
                rejected_epochs(stg) = sum(isnan(PSD_rej(1,1,:)));
                PSD_avg_epoch_rej = nanmean(PSD_rej,3); % %take the mean in 3rd dimension: epochs
                total_stg(stg) = sum(Stages_S==stg);     %count how many times it is stg
                PSD_avg{stg} = PSD_avg_epoch_rej;
            end

            PSD_S = PSD_avg{2}

            %put back together
            PSD_S_red = reduce_dimension(PSD_S); %reduce dimension
            PSD_S_red_norm = eegcha_normalize0_1(PSD_S_red);
            PSD_S_red_norm_sharp= sharp_tool(PSD_S_red_norm,3);
            

            fdim= 0.5:0.5:30;
            for n = 1:32
                command = [ 'disp(''x ' num2str(n) ''')' ];
                hold on
                plot(fdim, PSD_S_red_norm_sharp(n,:))
            end
            saveas(gcf, fullfile(filenameS(1:12)), 'jpeg')
            close all
            
            
     
            save(fullfile(filesDir, sprintf('VP%d_%d_PSD_interpolated_stages_.mat',vp,cyc)), 'Stages_use_S', 'F','PSD_S_red','rejE_S', 'rejC_S', 'PSD_S');
        else
            display('no data');
        end
    end
end