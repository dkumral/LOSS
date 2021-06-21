%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this function is based on PSD averaging: one leave out: not equal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation(PSD,nperm, sz, VP, audiobook, stat, stage)
%this is for the observed differences
close all

for stg = stage
    within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[];
    for a =1:4
        PSD_within = PSD(audiobook==a,stg);
        for l = 1:length(PSD_within)
            PSD_within = PSD(audiobook==a,stg);
            Aleft= PSD_within{l, 1} ;
            PSD_within{l, 1}  = [];
            within_rest = nanmean([(PSD_within{:})],2);
            within(l,a) = corr(Aleft, within_rest, 'Type','Pearson');
            
            other_audio = audiobook(audiobook~=a);
            ia = unique(other_audio);
            for iax = 1:length(ia)
                PSD_btw = PSD(audiobook==ia(iax),stg);
                btw_rest = nanmean([(PSD_btw{:})],2);
                between(l,iax,a) = corr(Aleft, btw_rest,'Type','Pearson');
                clear PSD_btw btw_rest
            end
        end
    end
    within(within==0) = [];
    between(between==0) = [];
    within_corr_books = atanh(within);
    between_corr_books = atanh(between);
    observeddifference_ztrans(stg) = nanmean(within_corr_books, 'all')-nanmean(between_corr_books,'all');
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
end

%% this is for the permutation (shuffle)
    for ix = 1:nperm
        VPx(:,ix) = VP(randperm(sz,sz));
    end
    
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
        within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[];
        for a =1:4
            PSD_within = PSD_perm(audiobook==a,ix,stg);
            for l = 1:length(PSD_within)
                PSD_within = PSD(audiobook==a,stg);
                Aleft= PSD_within{l, 1} ;
                PSD_within{l, 1}  = [];
                within_rest = nanmean([(PSD_within{:})],2);
                within(l,a) = corr(Aleft, within_rest, 'Type','Pearson');
                
                other_audio = audiobook(audiobook~=a);
                ia = unique(other_audio);
                for iax = 1:length(ia)
                    PSD_btw = PSD_perm(audiobook==ia(iax),ix,stg);
                    btw_rest = nanmean([(PSD_btw{:})],2);
                    between(l,iax,a) = corr(Aleft, btw_rest,'Type','Pearson');
                    clear PSD_btw btw_rest
                end
            end
        end
        within(within==0) = [];
        between(between==0) = [];
        within_corr_books = atanh(within);
        between_corr_books = atanh(between);
        randomdifferences_ztrans(ix, stg) = nanmean(within_corr_books, 'all')-nanmean(between_corr_books,'all');

        clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest
    end
end


% compute the p value and plot the results both matrix as well as
% permutation
t = tiledlayout(length(stage), 1);
set(gcf, 'PaperUnits', 'inches');
x_width=18 ;y_width=6.2*length(stage);
set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
for stg =stage
    %Phibson 2010 Permutation P-values should never be zero: calculating exact P - NCBI
    % getting probability of finding observed difference from random permutations
    if strcmp(stat, 'both')
        p(stg) = (length(find(abs(randomdifferences_ztrans(:, stg)) > abs(observeddifference_ztrans(stg))))+1) / (nperm+1);
    elseif strcmp(stat, 'smaller')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) < observeddifference_ztrans(stg)))+1) / (nperm+1);
    elseif strcmp(stat, 'larger')
        p(stg) = (length(find(observeddifference_ztrans(:, stg) > observeddifference_ztrans(stg)))+1) / (nperm+1);
    end
    
    % plotting result
    nexttile()
    histogram(randomdifferences_ztrans(:, stg), 20, 'facecolor','#7E2F8E' );
    hold on;
    xlabel('Random differences');
    ylabel('Count')
    od = plot(observeddifference_ztrans(stg), 0, '*r', 'DisplayName', sprintf('Observed difference.\np = %f',  p(stg) ));
    legend(od);
end
saveas(t, 'PSD_averaged_2.jpeg')
%%%%% %%%%% %%%%%  %%%%%  %%%%%