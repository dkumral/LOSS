%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this function is based on PSD averaging one leave out: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%Equal values (in terms of within vs between) equal 1 for within 1 values for btw%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_leave_one_out1between_1within(PSD,nperm, sz, VP, audiobook, stat,stage,Weckung)
%this is for the observed differences
close all
rng(1234, 'twister')

for stg = stage
    within = []; between =[]; PSD_within=[]; PSD_between =[];
    for a =1:length(unique(audiobook))
        PSD_within = PSD(audiobook==a,stg); %take the audiobook
        PSD_btw = PSD(audiobook~=a,stg);%take the rest of the audiobook
        btw_rest = nanmean([(PSD_btw{:})],2);%take mean of rest of the audiobook across 2nd dimension
        
        for l = 1:length(PSD_within)
            PSD_within = PSD(audiobook==a,stg); %take the audiobook
            Aleft= PSD_within{l, 1} ; %leave one audiobook alone (one leave out)
            PSD_within{l, 1}  = nan(size(Aleft)); %delete that audiobook in the within book dim
            within_rest = nanmean([(PSD_within{:})],2); %take the mean of rest within audiobook
            within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman')); %correlation of within audiobook: one leave out and SNR increased averaged rest
            between(l,a) = atanh(corr(Aleft, btw_rest,'Type','Spearman')); % correlation of left alone and between all audiobooks
        end
    end
    within(within==0) = NaN;
    between(between==0) = NaN;
    
    within_corr_books = rmmissing(within(:));
    between_corr_books = rmmissing(between(:));
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
end

%% this is for the permutation (shuffle)
% for ix = 1:nperm
%     VPx(:,ix) = VP(randperm(sz,sz)); %generate the random individuals = audiobook is constant
%
% % end

if sz>19
    VP2 = unique(VP);
    VPx =  VP2(cell2mat(arrayfun(@(dummy) randperm(length(VP2)), 1:nperm, 'UniformOutput', false)')'); %permute the data
    PSD3 = [];
    for ix = 1:nperm
        for stg = stage
            for i=1:length(VP2)
                PSD_x = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
                PSD3 = vertcat(PSD3, PSD_x); % combine all CH1 for all awakenings
            end
            PSD_perm(1:sz,ix,stg) = PSD3;
            PSD3 = [];
        end
    end
else
    VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data
    for stg = stage
        for i=1:sz
            for ix = 1:nperm
                PSD_perm(i,ix,stg) = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
            end
        end
    end
end  

%% compute the random differences
clear ix within between PSD_within PSD_between within_rest between_corr_books within_corr_books randomdifferences_ztrans
for stg = stage
    for ix = 1:nperm
        within = []; between =[]; PSD_between=[]; PSD_within =[];
        for a =1:length(unique(audiobook))
            PSD_within = PSD_perm(audiobook==a,ix,stg); %audiobook is constant
            PSD_btw = PSD_perm(audiobook~=a,ix,stg);
            btw_rest = nanmean([(PSD_btw{:})],2); % take the nanmean of the PSD (for the rest of audibook)
            for l = 1:length(PSD_within)
                PSD_within = PSD_perm(audiobook==a,ix,stg);
                Aleft= PSD_within{l, 1} ;
                PSD_within{l, 1}  = nan(size(Aleft));
                within_rest = nanmean([(PSD_within{:})],2);
                within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman')); %correlation of within audiobook: one leave out and SNR increased averaged rest
                between(l,a) = atanh(corr(Aleft, btw_rest,'Type','Spearman')); % correlation of left alone and between all audiobooks
                within(within==0) = NaN;
                between(between==0) = NaN;
            end
        end
        within_corr_books = rmmissing(within(:)); %the size of within correlation should be equal to sz
        between_corr_books = rmmissing(between(:)); %the size of btw correlation should be equal to sz
        randomdifferences_ztrans(ix,stg) = [nanmean(within_corr_books)-nanmean(between_corr_books)]';
    end
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
end


% compute the p value and plot the results both matrix as well as
% permutation
t = tiledlayout(length(stage), 1);
set(gcf, 'PaperUnits', 'inches');
x_width=8 ;y_width=5.8*length(stage);
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
for stg =stage
    %Phibson 2010 Permutation P-values should never be zero: calculating exact P - NCBI
    % getting probability of finding observed difference from random permutations
    if strcmp(stat, 'both')
        p(stg) = (length(find(abs(randomdifferences_ztrans(:, stg)) > abs(observeddifference_ztrans(stg))))+1) / (nperm+1);
    elseif strcmp(stat, 'smaller')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) < observeddifference_ztrans(stg)))+1) / (nperm+1);
    elseif strcmp(stat, 'larger')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) > observeddifference_ztrans(stg)))+1) / (nperm+1);
    end
    
    % plotting result
    nexttile()
    histogram(randomdifferences_ztrans(:, stg), 20, 'facecolor','#9ebcda', 'EdgeColor', '#9ebcda', 'facealpha', 0.5,  'LineStyle', 'none' );
    box off
    hold on;
    xlabel('Random Difference (z-transformed)');
    ylabel('Frequency')
    od = plot(observeddifference_ztrans(stg), 0, '*', 'MarkerSize',8,'MarkerEdgeColor','#8856a7', 'DisplayName', sprintf('p = %.3f',p(stg) ));
    xline(observeddifference_ztrans(stg), 'LineWidth', 2, 'color', '#8856a7');
    legend(od);
    legend boxoff
end
saveas(t, 'permutation_PSD_averaging_1-1_NONREM.jpeg')
save stats_averaging_1-1 p randomdifferences_ztrans observeddifference_ztrans

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%