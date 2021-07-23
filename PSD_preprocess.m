function [PSD_S_avg, Stages_use_S, rejE_S, rejC_S, rejected_epochs, dim_PSD_S, F] = PSD_preprocess(filenameS, filenameM, fmin, fmax, logtrans,  interpolate, reject, reduce, sharptool, doplot,vp, cyc, condition,transform)
if exist(filenameS, 'file') == 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(filenameS, '-mat');
    Stages_S = EEG.stats.sleep_trial; %used trials/epochs for sleep stages
    use_S = EEG.stats.usetrials; %used trials/epochs
    rejE_S = EEG.reject.rejglobal; %rejected epochs
    rejC_S = EEG.reject.rejglobalC; %rejected channels
    Stages_use_S= [Stages_S,use_S]; %combining
    rejE_S=[rejE_S];
    
    %%%%%%%%%%load the event when the audiobook start and stop%%%%%%%%%%%%%
    S254_latencies=[EEG.event(find(strcmp('S254',{EEG.event.type}))).latency];
    S255_latencies=[EEG.event(find(strcmp('S255',{EEG.event.type}))).latency];
    S254_latencies_epoch =  S254_latencies/1000/4;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    load(filenameM); %load the PSD
    F = F(F>=fmin & F<=fmax);
    PSD_S = PSD(:,F>=fmin & F<=fmax,:); % taking only <nmax Hz %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dim_PSD_total = size(PSD_S,3); %dimension (how many epochs in total in overall PSD)
    PSD_S = PSD_S(:,:,use_S); %use the sleep or wake data data;
    dim_PSD = size(PSD_S,3); % info about the dimension (wake or sleep)
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if logtrans==1
        PSD_S = log(PSD_S); % log transformation of PSD
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%interpolation of channels%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dim_PSD_S=size(PSD_S);
    if interpolate==1       %%%interpolation,
        PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2)*dim_PSD_S(3)]);
        PSD_S = egb_interp(PSD_S,EEG.chanlocs,~rejC_S,'nearest');
        PSD_S = reshape(PSD_S,[dim_PSD_S(1),dim_PSD_S(2),dim_PSD_S(3)]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%reject bad epochs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if reject==1       %%%reject "bad" epochs,
        PSD_S(:,:,find(rejE_S==1))=NaN; %rejected data
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%PSD averaging%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(condition,'sleep')
        for stg = 1:5    %averaging depending sleep stages
            PSD_rej = PSD_S(:,:,Stages_S==stg); %PSD_S depending on sleep stages
            PSD_S_avg(:,:,stg) = nanmean(PSD_rej,3); %mean in 3rd dimension: epochs
            total_stg(stg) = sum(Stages_S==stg);     %count how many times it is stg
        end
    else %wake
        PSD_S_avg = nanmean(PSD_S,3); % %take the mean in 3rd dimension: epochs
        total_stg= sum(Stages_S==0);     %count how many times it is stg
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%reduce the channel dimension%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if reduce==1 %%reduce the channel dimension
        PSD_S_avg = reduce_dimension(PSD_S_avg); %reduce dimension
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%transformation of %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(transform,'norm')
        PSD_S_avg = eegcha_normalize0_1(PSD_S_avg); %normalize between 1 and 0
    else
        PSD_S_avg = rescale(PSD_S_avg); %https://de.mathworks.com/help/matlab/ref/rescale.html
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(condition,'sleep') %select whether sleep or nor
        if sharptool==1 %sharpening tool
            for stg = 1:5 %stages
                psd= squeeze(PSD_S_avg(:,:,stg)); 
                PSD_S_avg(:,:,stg)= sharp_tool(psd,6);
            end
        elseif sharptool==2 %taking raw values
            PSD_S_avg = PSD_S_avg;
        else
            for stg = 1:5 %stages
                for ch = 1:size(PSD_S_avg,1) %channel dimension
                    psd= squeeze(PSD_S_avg(ch,:,stg))';
                    %psd(psd==0)= 0.0001;
                    if any(~isnan(psd), 'all')
                        [intSlo, stat, Pows]  = fitPowerLaw3steps(F',psd, 'ols');
                    else
                        disp('data is a nan');
                        Pows.res2=NaN(1,size(PSD_S_avg,2));
                    end
                    PSD_S_avg(ch,:,stg) = Pows.res2;
                end
                F=Pows.frex2;
            end
        end
    else
        if sharptool==1 % sharpening tool
            PSD_S_avg= sharp_tool(PSD_S_avg,6);
        elseif sharptool==2 %taking raw values
            PSD_S_avg = PSD_S_avg;
        else
            for ch = 1:size(PSD_S_avg,1) %channel dimension
                psd= PSD_S_avg(ch,:)';
                %psd(psd==0)= 0.001;
                if any(~isnan(psd), 'all')
                    [intSlo, stat, Pows]  = fitPowerLaw3steps(F',psd, 'ols');
                else
                    disp('data is a nan');
                    Pows.res2=NaN(1,size(PSD_S_avg,2));
                end
                PSD_S_avg(ch,:) = Pows.res2;
            end
            F=Pows.frex2;
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%plot the PSD files with channels%%%%%%%%%%%%%%%%%
    if doplot==1
        t = tiledlayout(1, 5);
        x_width=28 ;y_width=7;
        set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
        set(gcf, 'PaperUnits', 'inches');set(gcf, 'PaperUnits', 'inches');
        if isequal(condition,'sleep')
            for stg = 1:5
                nexttile()
                for ch = 1:size(PSD_S_avg,1)
                    command = [ 'disp(''x ' num2str(ch) ''')' ];
                    hold on
                    plot(F,  PSD_S_avg(ch,:,stg));
                end
            end
        else
            x_width=5 ;y_width=5;
            set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
            set(gcf, 'PaperUnits', 'inches');set(gcf, 'PaperUnits', 'inches');
            for ch = 1:size(PSD_S_avg,1)
                command = [ 'disp(''x ' num2str(ch) ''')' ];
                hold on
                plot(F,  PSD_S_avg(ch,:));
            end
        end
        saveas(gcf, fullfile(filenameS(1:11)), 'jpeg');
        close all
    end
  if sharptool==0 %1/f removal
    save(sprintf('VP%d_%d_PSD.mat',vp,cyc),'intSlo','Pows' ,'stats','dim_PSD_total','dim_PSD','S255_latencies', 'S254_latencies','S254_latencies_epoch','Stages_use_S', 'F','rejE_S', 'rejC_S', 'PSD_S_avg', 'total_stg');
  elseif sharptool==2
    save(sprintf('VP%d_%d_PSD.mat',vp,cyc),'dim_PSD_total','dim_PSD','S255_latencies', 'S254_latencies','S254_latencies_epoch','Stages_use_S', 'F','rejE_S', 'rejC_S', 'PSD_S_avg', 'total_stg');
  else
    save(sprintf('VP%d_%d_PSD.mat',vp,cyc),'dim_PSD_total','dim_PSD','S255_latencies', 'S254_latencies','S254_latencies_epoch','Stages_use_S', 'F','rejE_S', 'rejC_S', 'PSD_S_avg', 'total_stg'); 
  end
  
  else
    display('no data');
end
