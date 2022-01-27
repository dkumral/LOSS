%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%create EEG signal based only pink noise%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%here we assessed the number of averaging epochs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%3 versions will be computed, 1) based on real epoch numbers, 2) constant for%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%everyone, 3) different scenerios%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear all
%load('sleep_info_audiobook.mat')
%1) based on real epoch numbers
for i = 1:19
    ind = find(sleep_info_audiobook.VP == (i+2));
    numberofepochs = sleep_info_audiobook.total_sleepstage(ind)
    for sz = 1:size(numberofepochs,1)
        for stg = 1:5
            info(sz,stg) = numberofepochs{sz,1}(stg);
            info(info == 0) = NaN;
            mean_epoch_across = nanmean(info); 
            sum_epoch_across= nansum(info) ; 
        end
    end
    sum_epoch_across_stg(i,:)=sum_epoch_across; %sum of epochs
    mean_epoch_across_stg(i,:)=mean_epoch_across; %mean of epochs
    clear  ind  numberofepochs sum_epoch_across mean_epoch_across
end
save sum_epoch_across_stg sum_epoch_across_stg
save mean_epoch_across_stg mean_epoch_across_stg
%%
%%parameters of interests for pwelch%%
clear all
rng(555, 'twister')
Fs= 1000; %sampling rate
timeS= 4; %second
dataPoints= 1: Fs*timeS; %number of data points
nchan=32; %number of channels
fftwindow = Fs*2;
noverlap = Fs*1.9;
nfft = Fs*2;
minspind = 11;
maxspind = 16;
f = minspind + (maxspind-minspind).*rand(48,1);
fmin = 0.5;
fmax = 45;
F= 0:0.5:99.5'; %F
sharptool=0;
Freq = F(F>=fmin & F<=fmax);
epochs = 1%:1500;
%h = 0.08 + (0.13-0.08).*rand(19,1);
h = 0.05 + (0.10-0.05).*rand(48,1);
h = h*-1;
%%
for i = 20:48
    for n= epochs
        for ch = 1:nchan
            seed = randperm(9999999, 1); % you may generate new seeds
            rng(seed, 'twister')
            pink= pinknoise(dataPoints(end),1);     %myEEGch=  randn(1,dataPoints(end));
            %pink_chan(:, ch)= smooth(pink, Fs)';            
            x = h(i)*cos(2*pi*f(i)*dataPoints/Fs);
            x = x(:);
            pink_chan_epoch(ch,:,n) = pink+x;
            PSD(ch,:,n) = pwelch(pink_chan_epoch(ch,:,n),fftwindow,noverlap,nfft,Fs);
        end
    end
    
    PSD_S = PSD(:,F>=fmin & F<=fmax,epochs); % taking only <nmax Hz %%%
    PSD_S = log10(PSD_S); % log transformation of PSD
    PSD_S_avg = nanmean(PSD_S,3); %mean in 3rd dimension: epochs
    PSD_S_avg = eegcha_normalize0_1(PSD_S_avg); %normalize between 1 and 0
   
    PSD_S_avg_shap= sharp_tool(PSD_S_avg,6);

    for ch = 1:size(PSD_S_avg,1)
        command = [ 'disp(''x ' num2str(ch) ''')' ];
        hold on
        plot(Freq,  PSD_S_avg(ch,:));
    end
    
    saveas(gcf, sprintf('VP%d_PSD_simulate',i), 'jpeg');
    close all
    data_reduced(i).PSD_res_red{1, 1} = reshape(PSD_S_avg.',1,[])';
    data_reduced(i).PSD_S_avg{1, 1} = PSD_S_avg;
    data_reduced(i).PSD_S_avg_sharp = reshape(PSD_S_avg_shap.',1,[])';

end
save data_reduced_all data_reduced
%%
% 
load('data_reduced.mat')
VP = data_reduced.VP;
audiobook = data_reduced.audiobook;
clear data_reduced
% 
load('data_reduced.mat')
data_reduced = struct2table(data_reduced);
data_reduced.VP = VP;
data_reduced.audiobook = audiobook;
% 
save data_reduced data_reduced
%%
data_reduced=table2struct(data_reduced)

for i = 1:19
    PSD_ind = data_reduced(i).PSD_S_avg ;
    
    PSD_S_avg= sharp_tool(PSD_ind,6);
    for ch = 1:size(PSD_S_avg,1)
        command = [ 'disp(''x ' num2str(ch) ''')' ];
        hold on
        plot(Freq,  PSD_S_avg(ch,:));
    end
    saveas(gcf, sprintf('VP%d_PSD_simulate',i), 'jpeg');
    close all
    data_reduced(i).PSD_S_avg_sharp = reshape(PSD_S_avg.',1,[])';
end
data_reduced = struct2table(data_reduced);
save data_reduced data_reduced
%%