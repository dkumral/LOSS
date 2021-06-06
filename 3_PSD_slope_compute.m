%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compute PSD slope for every individual, stage, and channel (N=32) this
% script using the fitpowerlaw function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
load('/home/kumral/Desktop/Projects/LOSS_analyses/github_scripts/data_PSD_averaged.mat')
XX = data.F;
%%
for i = 1:81
    for stg = 1:5
        for ch = 1:32
            YY = data(i).PSD_avg_epoch{1, stg}(ch,:)';
            if any(~isnan(YY), 'all')
                [intSlo, stat, Pows, Deviants,  stat0, intSlo0] = fitPowerLaw3steps(XX,YY, 'ols');
                spectralExponent= intSlo(2);
                data(i).Pows.pred{stg}(ch,:) = Pows.pred;
                data(i).Pows.res{stg}(ch,:) =  Pows.res;
                data(i).Pows.obs{stg}(ch,:) =   Pows.obs;
                data(i).Pows.frex{stg}(ch,:) =    Pows.frex;
                data(i).spectralExponent{stg}(ch) = spectralExponent;
            else
                disp('data is a nan')
                data(i).Pows.pred{stg}(ch,:) = NaN(1,360);
                data(i).Pows.obs{stg}(ch,:) = NaN(1,360);
                data(i).Pows.res{stg}(ch,:) = NaN(1,360);
                data(i).Pows.frex{stg}(ch,:) =   NaN(1,360);
                data(i).spectralExponent{stg}(ch) = NaN;
            end
        end
    end
end
save('data_PSD_averaged_slope.mat', 'data', '-v7.3')
%%