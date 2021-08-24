%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this function is based on PSD averaging: one leave out: not equal 1 for within 3 values for btw%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_leave_one_out3between_1within(PSD,nperm, sz, VP, audiobook, stat, stage)
%%this part is for the observed differences%%
close all
rng(123, 'twister')

for stg = stage 
    within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[]; %create empty files
    for a =1:4 %audiobook
        PSD_within = PSD(audiobook==a,stg); %take the PSDs based on the audiobook (e.g., A1)
        for l = 1:length(PSD_within) %leave one out based on the lenght of within PSD
            PSD_within = PSD(audiobook==a,stg);
            Aleft= PSD_within{l, 1} ;
            PSD_within{l, 1}  = nan(size(Aleft));  %make the PSD NAN
            within_rest = nanmean([(PSD_within{:})],2); % take average of the rest PSDs
            within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman')); %spearman correlation btw Aleft and the rest and fishertoztransformation
            within(within==0) = NaN; %make zeros to NaN
            
            other_audio = audiobook(audiobook~=a); %other audiobooks
            ia = unique(other_audio); 
            for iax = 1:length(ia) 
                PSD_btw = PSD(audiobook==ia(iax),stg); %PSD of other audiobooks for between correlation
                btw_rest = nanmean([(PSD_btw{:})],2);  %take the nanmean of the PSDs
                between(l,iax,a) = atanh(corr(Aleft, btw_rest,'Type','Spearman')); %correlate the Aleft with the between averaged PSDs for each audiobook
                between(between==0) = NaN; %make zeros to NaN
                clear PSD_btw btw_rest
            end
        end
    end
    within_corr_books = rmmissing(within(:));  %the size of within correlation should be equal to sz
    between_corr_books = rmmissing(between(:)); % the size of btw correlation should be equal to sz*3
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
end

%% this is for the permutation (shuffle)
%     for ix = 1:nperm
%         VPx(:,ix) = VP(randperm(sz,sz));
%     end
%
VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data

for stg = stage
    for i=1:sz
        for ix = 1:nperm
            PSD_perm(i,ix,stg) = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
        end
    end
end
clear ix within between PSD_within PSD_between within_rest between_corr_books within_corr_books
%% compute the differences in the randomization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%compute the random differences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this loop is basically same above, but uses permuted PSD matrix by taking audiobook as constant%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    for ix = 1:nperm
        within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[];
        for a =1:4
            PSD_within = PSD_perm(audiobook==a,ix,stg);
            for l = 1:length(PSD_within)
                PSD_within = PSD_perm(audiobook==a,ix,stg);
                Aleft= PSD_within{l, 1} ;
                PSD_within{l, 1}  = nan(size(Aleft));
                within_rest = nanmean([(PSD_within{:})],2);
                within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman'));
                within(within==0) = NaN;
                
                other_audio = audiobook(audiobook~=a);
                ia = unique(other_audio);
                for iax = 1:length(ia)
                    PSD_btw = PSD_perm(audiobook==ia(iax),ix,stg);
                    btw_rest = nanmean([(PSD_btw{:})],2);
                    between(l,iax,a) = atanh(corr(Aleft, btw_rest,'Type','Spearman'));
                    between(between==0) = NaN;
                    clear PSD_btw btw_rest
                end
            end
        end
        within_corr_books = rmmissing(within(:)); %the size of within correlation should be equal to sz
        between_corr_books = rmmissing(between(:)); % the size of btw correlation should be equal to sz*3
        randomdifferences_ztrans(ix,stg) = [nanmean(within_corr_books)-nanmean(between_corr_books)]';
        clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%compute p-value visulation of the permutations results%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
saveas(t, 'permutation_PSD_averaging_1-3.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%