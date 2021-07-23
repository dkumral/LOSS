%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute PSD slope for every individual, stage, and channel (N=32) this
% script using the fitpowerlaw function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
clear all
close all
load('/home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/data_PSD_averaged_interpolated_30.mat')
doPlot =1;
robRegMeth= 'ols';
nmax=30;
XX = data.F;
%%
for i = 1:81
    for stg = 1:5
        for ch = 1:32
            try
                YY = data(i).PSD_avg_epoch_rej{1, stg}(ch,:)'; %arrange for interpolated channels and rejected epochs
            catch
                YY = NaN;
            end %Added because program crashes when data(i).PSD_avg_epoch{1, stg} is NaN and ch>1
            
            if any(~isnan(YY), 'all')
                [intSlo, stat, Pows, Deviants,  stat0, intSlo0] = fitPowerLaw3steps(XX,YY, 'ols');
                spectralExponent= intSlo(2);
                data(i).Pows.pred{stg}(ch,:) = Pows.pred;
                data(i).Pows.res{stg}(ch,:) =  Pows.res;
                data(i).Pows.obs{stg}(ch,:) =   Pows.obs;
                data(i).Pows.frex{stg}(ch,:) =    Pows.frex;
                data(i).spectralExponent{stg}(ch) = spectralExponent;
                N = Pows.frex; 
                ind = interp1(N,1:length(N),XX,'nearest');
                if isnan(ind(end)) == 1
                   ind(end) = 240;
                end 
                Pows.res_red = data(i).Pows.res{1, stg}(ch,ind);
                data(i).Pows.res_red{stg}(ch,:) =  Pows.res_red;
                data(i).Pows.frex_red{stg}(ch,:) = data(i).Pows.frex{stg}(ch,ind);
            else
                disp('data is a nan')
                data(i).Pows.pred{stg}(ch,:) = NaN(1,240);
                data(i).Pows.obs{stg}(ch,:) = NaN(1,240);
                data(i).Pows.res{stg}(ch,:) = NaN(1,240);
                data(i).Pows.frex{stg}(ch,:) =   NaN(1,240);
                data(i).spectralExponent{stg}(ch) = NaN;
                data(i).Pows.res_red{stg}(ch,:) =  NaN(1,60);

            end
        end
    end

end

save('data_PSD_averaged_slope_interpolated_rejected_30.mat', 'data', '-v7.3')
%%