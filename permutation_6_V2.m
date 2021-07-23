%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this function is based on PSD averaging: one leave out: equal amounth of
%%between vs within group
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation(PSD,nperm, sz, VP, audiobook, stat,stage)
%this is for the observed differences
close all
for stg = stage
    within = []; between =[]; PSD_within=[]; PSD_between =[];
    for a =1:4
        PSD_within = PSD(audiobook==a,stg); %take the audiobook
        PSD_btw = PSD(audiobook~=a,stg);%take the rest of the audiobook
        btw_rest = nanmean([(PSD_btw{:})],2);%take mean of rest of the audiobook across 2nd dimension
        
        for l = 1:length(PSD_within)
            PSD_within = PSD(audiobook==a,stg); %take the audiobook
            Aleft= PSD_within{l, 1} ; %leave one audiobook alone (one leave out)
            PSD_within{l, 1}  = nan(size(Aleft)); %delete that audiobook in the within book dim
            within_rest = nanmean([(PSD_within{:})],2); %take the mean of rest within audiobook
            within(l,a) = corr(Aleft, within_rest, 'Type','Spearman'); %correlation of within audiobook: one leave out and SNR increased averaged rest
            between(l,a) = corr(Aleft, btw_rest,'Type','Spearman'); % correlation of left alone and between all audiobooks
        end
    end
    within(within==0) = NaN;
    between(between==0) = NaN;
    
    within_corr_books = atanh(rmmissing(within(:)));
    between_corr_books = atanh(rmmissing(between(:)));
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
end

%% this is for the permutation (shuffle)
% for ix = 1:nperm
%     VPx(:,ix) = VP(randperm(sz,sz)); %generate the random individuals = audiobook is constant
%     
% % end

VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')');

for stg = stage
    for i=1:sz
        for ix = 1:nperm
            PSD_perm(i,ix,stg) = PSD(find(VP  == VPx(i,ix)),stg);
        end
    end
end


%% compute the differences in the randomization
clear ix within between PSD_within PSD_between within_rest between_corr_books within_corr_books randomdifferences_ztrans
for stg = stage
    for ix = 1:nperm
        within = []; between =[]; PSD_between=[]; PSD_within =[];
        for a =1:4
            PSD_within = PSD_perm(audiobook==a,ix,stg); %audiobook is constant
            PSD_btw = PSD_perm(audiobook~=a,ix,stg);
            btw_rest = nanmean([(PSD_btw{:})],2);
            for l = 1:length(PSD_within)
                PSD_within = PSD_perm(audiobook==a,ix,stg);
                Aleft= PSD_within{l, 1} ;
                PSD_within{l, 1}  = nan(size(Aleft));
                within_rest = nanmean([(PSD_within{:})],2);
                within(l,a) = corr(Aleft, within_rest, 'Type','Spearman'); %correlation of within audiobook: one leave out and SNR increased averaged rest
                between(l,a) = corr(Aleft, btw_rest,'Type','Spearman'); % correlation of left alone and between all audiobooks
                within(within==0) = NaN;
                between(between==0) = NaN;
            end
        end
        within_corr_books = atanh(rmmissing(within(:)));
        between_corr_books = atanh(rmmissing(between(:)));
        randomdifferences_ztrans(ix,stg) = [nanmean(within_corr_books,1)-nanmean(between_corr_books,1)]';

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
saveas(t, 'permutation_PSD_averaging_1-1.jpeg')
%%%%% %%%%% %%%%%  %%%%%  %%%%%