%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p]  = permutation_splithalf(PSD1,PSD2, nhalf, nperm, VP, VP_new1, VP_new2, aud1, aud2, audiobook, stat,stage,observeddifference_mean)
close all
sz = floor(size(VP,1)/2); %half size of the number of individuals
audio = [1:4]; %audiobook
rng(123, 'twister')
%%
for ixm=1:nhalf %number of splitting half data
    for ix = 1:nperm %number of permutation
        VPx1 = VP_new1(randperm(sz,sz),ixm); %create permutation based on indviduals of data 1 (audiobook constant, shuffling PSDs)
        VP_new11 = squeeze(VP_new1(:,ixm));
        
        VPx2 = VP_new2(randperm(sz,sz),ixm); %create permutation based on indviduals of data 2 (audiobook constant, shuffling PSDs)
        VP_new22 = squeeze(VP_new2(:,ixm));
        
        for stg = stage %arrange everything based on stages
            PSD11 = squeeze(PSD1(:,ixm,stg));
            PSD22= squeeze(PSD2(:,ixm,stg));
            for i=1:sz
                PSD_perm1(i,ix,ixm,stg) = PSD11(find(VP_new11  == VPx1(i))); %PSD of permuted data 1: nindividuals x nperm x nsplithalf x stages
                PSD_perm2(i,ix,ixm,stg) = PSD22(find(VP_new22  == VPx2(i))); %PSD of permuted data 2: nindividuals x nperm x nsplithalf x stages
            end
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for ix=1:nperm
    for ixm = 1:nhalf
        for stg = stage
            for a =audio %audiobook
                aud11 = squeeze(aud1(:,ixm)); %squeeze the dim
                PSD_within1 = PSD_perm1(aud11==a,ix,ixm,stg); %find the correspinding PSD1 of that audiobook
                within1 = nanmean([(PSD_within1{:})],2); %take the mean PSD1 of audiobook1
                
                aud22 = squeeze(aud2(:,ixm));%reduce the dim
                PSD_within2 = PSD_perm2(aud22==a,ix,ixm,stg); %find the correspinding PSD2 of that audiobook
                within2 = nanmean([(PSD_within2{:})],2); %take the mean of PSD2 audiobook1
                
                mean_within_corr(a) = atanh(corr(within1, within2, 'Type','Spearman')); %take the correlation between groups
                mean_within(ixm) = nanmean(mean_within_corr); %we have 4 within correlation values representing each audiobook, and taking average of it
                
                btw_a1 = aud1(find(~ismember(aud11,a))); %find the rest
                btw_a2 = aud2(find(~ismember(aud22,a)));
                
                ia = unique(btw_a2); %find the unique audiobook
                %this section computes the between correlation
                for i = 1:length(ia)
                    PSD_btw1 = PSD_perm1(aud11==btw_a1(i),ix,ixm,stg);
                    btw_rest1 = nanmean([(PSD_btw1{:})],2); %take the mean of data1/PSD1 of audiobook2 or 3 or 4, seperately
                    
                    PSD_btw2 = PSD_perm2(aud22==btw_a2(i),ix,ixm,stg);
                    btw_rest2 = nanmean([(PSD_btw2{:})],2); %take the mean of data2/PSD2 of audiobook2 or 3 or 4, seperately
                    
                    btwcorr1(a,i) = atanh(corr(within1, btw_rest2, 'Type','Spearman')); %compute between correlation and fishertoztransform
                    btwcorr2(a,i) = atanh(corr(within2, btw_rest1, 'Type','Spearman')); %compute between correlation and fishertoztransform
                    btwcorr3(a,i) = atanh(corr(within1, btw_rest1, 'Type','Spearman')); %compute between correlation and fishertoztransform
                    btwcorr4(a,i) = atanh(corr(within2, btw_rest2, 'Type','Spearman')); %compute between correlation and fishertoztransform
                end
            end
            between_sim1_m = nanmean(btwcorr1(:)); %take the mean of across 3 x 4 groups = 12 values
            between_sim2_m = nanmean(btwcorr2(:)); %take the mean of across 3 x 4 groups = 12 values
            between_sim3_m = nanmean(btwcorr3(:)); %take the mean of across 3 x 4 groups = 12 values
            between_sim4_m = nanmean(btwcorr4(:)); %take the mean of across 3 x 4 groups = 12 values
            mean_between(ixm) = ((between_sim1_m+between_sim2_m+between_sim3_m+between_sim4_m)/4); %%% take the mean of halves
            randomdifferences_ztrans(stg) = nanmean(mean_within-mean_between);
        end
    end
    randomdifferences_meanall(ix,:)= randomdifferences_ztrans;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%visualization and p-value computation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tiledlayout(length(stage), 1);
set(gcf, 'PaperUnits', 'inches');
x_width=8 ;y_width=5.8*length(stage);
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
for stg =stage
    %Phibson 2010 Permutation P-values should never be zero: calculating exact P - NCBI
    % getting probability of finding observed difference from random permutations
    if strcmp(stat, 'both')
        p(stg) = (length(find(abs(randomdifferences_meanall(:, stg)) > abs(observeddifference_mean(stg))))+1) / (nperm+1);
    elseif strcmp(stat, 'smaller')
        p(stg) = (length(find(randomdifferences_meanall(:, stg) < observeddifference_mean(stg)))+1) / (nperm+1);
    elseif strcmp(stat, 'larger')
        p(stg) = (length(find(randomdifferences_meanall(:, stg) > observeddifference_mean(stg)))+1) / (nperm+1);
    end
    
    % plotting result
    nexttile()
    histogram(randomdifferences_meanall(:, stg), 20, 'facecolor','#9ebcda', 'EdgeColor', '#9ebcda', 'facealpha', 0.5,  'LineStyle', 'none' );
    box off
    hold on;
    xlabel('Random Difference (z-transformed)');
    ylabel('Frequency')
    od = plot(observeddifference_mean(stg), 0, '*', 'MarkerSize',8,'MarkerEdgeColor','#8856a7', 'DisplayName', sprintf('p = %.3f',p(stg) ));
    xline(observeddifference_mean(stg), 'LineWidth', 2, 'color', '#8856a7');
    legend(od);
    legend boxoff
end
saveas(t, 'permutation_PSD_averaging_splithalf.jpeg')
end