%%%%%%%%%%%%%%function is for the implementation of PSD reprocessing%%%%%%%%%%%%%
function PSD_preprocess(uses,filenameS, filenameSinfo,filenameM, fmin, fmax, logtrans,  interpolate, reject, reduce, sharptool, doplot,vp, cyc, condition,transform,reducetime, timing, min)
if exist(filenameSinfo, 'file') == 2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %load(filenameM); %load the PSD
    PSD = filenameM; %load the PSD
    
    load(filenameSinfo, '-mat'); %load the sleep info
    rejE_S = EEG.reject.rejglobal; %rejected epochs
    rejC_S = EEG.reject.rejglobalC; %rejected channels
    rej_uses = [rejE_S', uses];
    
    if isequal(condition,'wake') %wake = audiobook
        audio = find(filenameS(:,end) ==999); %999 %wake = audiobook
        use_S = filenameS(audio,1); %used trials/epochs
        Stages_S = filenameS(audio,3);
    else
        b = [1:5]; %sleep stages
        c = ismember(filenameS(:,end), b);
        sleep_ind = find(c);
        use_S = filenameS(sleep_ind,1); %used trials/epochs
        Stages_S = filenameS(sleep_ind,3); %used trials/epochs
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(reducetime,'minutes') %reduce the time before awakening
        time = min*60; %15 min as interests
        time = round(time/4); % as the each trial/epochs is 4 second
        if length(use_S) < time
            Stages_S = Stages_S;
            use_S = use_S;
        elseif isequal(timing,'last')
            Stages_S = Stages_S(end-time+1:end);      % last min elements
            use_S = use_S(end-time+1:end);  % last min elements
        elseif isequal(timing,'first')
            Stages_S = Stages_S(1:time);      % last min elements for the wake
            use_S = use_S(1:time);  % last min elements for the wake
        else isequal(timing,'random')
            rng(1234, 'twister')
            rand = randperm(length(use_S),time); %taking random time intervals
            use_S = use_S(rand);
            Stages_S = Stages_S(rand);
        end
    else isequal(reducetime,'full')
        Stages_S = Stages_S;
        use_S = use_S;
    end
    
    %get the indices for the rejected epochs in last 250 epochs
    [ia,ind]=ismember(use_S,rej_uses(:,end));
    rej_info = rej_uses(ind,:);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%interpolation of channels%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dim_PSD_S=size(PSD);
    if interpolate==1       %%%interpolation,
        PSD = reshape(PSD,[dim_PSD_S(1),dim_PSD_S(2)*dim_PSD_S(3)]);
        PSD = egb_interp(PSD,EEG.chanlocs,~rejC_S,'nearest');
        PSD = reshape(PSD,[dim_PSD_S(1),dim_PSD_S(2),dim_PSD_S(3)]);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    F= 0:0.5:99.5'; %F
    PSD_S = PSD(:,F>=fmin & F<=fmax,:); % taking only <nmax Hz %%%
    F = F(F>=fmin & F<=fmax);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%averaging across sleep
    %%%%%%%%%%%%%%%stages%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    dim_PSD_total = size(PSD_S,3); %dimension (how many epochs in total in overall PSD)
    PSD_S = PSD_S(:,:,use_S); %use the sleep or wake data data;
    dim_PSD = size(PSD_S,3); % info about the dimension (wake or sleep)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if logtrans==1
        PSD_S = log10(PSD_S); % log transformation of PSD
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%reject bad epochs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if reject==1       %%%reject "bad" epochs,
        PSD_S(:,:,find(rej_info(:,1)==1))=NaN; %rejected data
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%reduce the channel dimension%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if reduce==1 %%reduce the channel dimension
        PSD_S_red = reduce_dimension(PSD_S); %reduce dimension
    else
        PSD_S_red =PSD_S;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%PSD averaging%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(condition,'sleep')
        for stg = 1:5    %averaging depending sleep stages
            PSD_rej = PSD_S_red(:,:,Stages_S==stg); %PSD_S depending on sleep stages
            PSD_S_avg(:,:,stg) = nanmean(PSD_rej,3); %mean in 3rd dimension: epochs
            total_stg(stg) = sum(Stages_S==stg);     %count how many times it is stg
        end
    else %wake/audiobook
        PSD_S_avg = nanmean(PSD_S_red,3); % %take the mean in 3rd dimension: epochs
        total_stg= sum(Stages_S==0);     %count how many times it is stg
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%transformation of %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(transform,'norm')
        PSD_S_avg = eegcha_normalize0_1(PSD_S_avg); %normalize between 1 and 0
    else
        PSD_S_avg = rescale(PSD_S_avg); %https://de.mathworks.com/help/matlab/ref/rescale.html
        PSD_S_avg = PSD_S_avg; %https://de.mathworks.com/help/matlab/ref/rescale.html
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if isequal(condition,'sleep') %select whether sleep or nor
        if sharptool==1 %sharpening tool
            for stg = 1:5 %stages
                psd= squeeze(PSD_S_avg(:,:,stg));
                PSD_S_avg(:,:,stg)= sharp_tool(psd,6);
            end
        else
            PSD_S_avg = PSD_S_avg; %take raw
        end
    else
        if sharptool==1 % sharpening tool
            PSD_S_avg= sharp_tool(PSD_S_avg,6);
        else
            PSD_S_avg = PSD_S_avg;
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
        saveas(gcf, sprintf('VP%d_%d_PSD',vp,cyc), 'jpeg');
        close all
    end
    save(sprintf('VP%d_%d_PSD.mat',vp,cyc),'dim_PSD_total','dim_PSD','PSD_S_avg', 'total_stg', 'F');
else
    display(sprintf('no data for %s', filenameSinfo));
end