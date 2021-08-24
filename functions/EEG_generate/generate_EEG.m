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
Fs= 1000; %sampling rate
timeS= 4; %second
dataPoints= 1: Fs*timeS; %number of data points
nchan=32; %number of channels
Fs = 1000;
fftwindow = Fs*2;
noverlap = Fs*1.9;
nfft = Fs*2;
condition = 'max' % change it accordingly, as sum, mean, max, min
%%
%the pink noise based on the epochs above and smooth it and take the pwelch
%run based on the real epoch number
load('sum_epoch_across_stg.mat')
load('mean_epoch_across_stg.mat')

for stg = 1:5
    for ind = 1:19
        if isequal(condition,'sum')
            epoch = sum_epoch_across_stg(ind,stg);
        elseif isequal(condition,'min')
            minepochs = min(sum_epoch_across_stg);
            epoch = minepochs(stg);
        elseif isequal(condition,'mean')
            mean_epoch = nanmean(mean_epoch_across_stg)
            epoch = mean_epoch(stg);
        else 
            maxepochs = max(sum_epoch_across_stg)
            epoch = maxepochs(stg);
        end
        for n= 1:epoch
            for ch = 1:nchan
                seed = randperm(9999999, 1); % you may generate new seeds
                rng(seed, 'twister')
                pink= pinknoise(dataPoints(end),1);     %myEEGch=  randn(1,dataPoints(end));
                %pink_chan(:, ch)= smooth(pink, Fs)';
                pink_chan_epoch(:,ch,n) = pink;
                PSD(:,ch,n) = pwelch(pink_chan_epoch(:,ch,n),fftwindow,noverlap,nfft,Fs);
            end
        end
        pink_noise(ind,stg).PSD(:,:,:) = PSD;
        PSD_avg = nanmean(pink_noise(ind,stg).PSD,3);
    end
    pink_noise(ind,stg).PSD_avg_epochs(:,:) = PSD_avg;
    clear pink_chan_epoch pink_chan pink PSD_avg psd  PSD
end
save pink_noise_max pink_noise
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%