%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%this function is based on PSD averaging: one leave out: not equal 1 for within 3 values for btw%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_leave_one_out3between_1within(PSD,nperm, sz, VP, parameters, stat, stage, searchlight,ROI,r,frangeAll,ifreq)
%%this part is for the observed differences%%
close all
rng(10)
for stg = stage 
    within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[]; %create empty files
    for a =1:length(unique(parameters)) %parameters
        PSD_within = PSD(parameters==a,stg); %take the PSDs based on the parameters (e.g., A1)
        PSD_within_VP = VP(parameters==a); %take the PSDs based on the parameters (e.g., A1)

        for l = 1:length(PSD_within) %leave one out based on the lenght of within PSD
            PSD_within = PSD(parameters==a,stg);
            Aleft= PSD_within{l, 1} ;
            Aleft_VP(l,a)= PSD_within_VP(l) ;
            PSD_within{l, 1}  = nan(size(Aleft));  %make the PSD NAN
            within_rest = nanmean([(PSD_within{:})],2); % take average of the rest PSDs
            within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman')); %spearman correlation btw Aleft and the rest and fishertoztransformation
            within(within==0) = NaN; %make zeros to NaN
            Aleft_VP(Aleft_VP==0) = NaN; %make zeros to NaN for VP
             
            other_audio = parameters(parameters~=a); %other parameterss
            ia = unique(other_audio); 
            for iax = 1:length(ia) 
                PSD_btw_VP{iax} = VP(parameters==ia(iax)); %take the PSDs based on the parameters (e.g., A1)
                Bleft_VP{a} = cell2mat(PSD_btw_VP(:)); 
                PSD_btw = PSD(parameters==ia(iax),stg); %PSD of other parameterss for between correlation
                btw_rest = nanmean([(PSD_btw{:})],2);  %take the nanmean of the PSDs
                between(l,iax,a) = atanh(corr(Aleft, btw_rest,'Type','Spearman')); %correlate the Aleft with the between averaged PSDs for each parameters
                between(between==0) = NaN; %make zeros to NaN
                clear PSD_btw btw_rest
            end
        end
    end
    between_order_VP = cell2mat(Bleft_VP(:)); 
    within_order_VP = rmmissing(Aleft_VP(:));
    within_corr_books = rmmissing(within(:));  %the size of within correlation should be equal to sz
    between_corr_books = rmmissing(between(:)); % the size of btw correlation should be equal to sz*3
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
    save within_corr_books within_corr_books
    save within_order_VP within_order_VP
    save between_corr_books between_corr_books
    save between_order_VP between_order_VP
    clear  within between  within_corr_books  between_corr_books Aleft PSD_within PSD_between PSD_within within_rest 
end
clear ix within between PSD_within PSD_between within_rest between_corr_books within_corr_books Aleft_VP PSD_within_VP

%% this is for the permutation (shuffle)
if isequal(searchlight,'freq') %this is for the searchlight analyses
    PSD_perm = searchlight_PSD(VP,sz,nperm,frangeAll,stage,PSD,ifreq);
elseif isequal(searchlight,'channel') %this is for the searchlight analyses
    PSD_perm = searchlight_ROI(VP,sz,nperm,stage,PSD,ROI,r);
else %else means no searchight, here we use permutation based on individual levels
    for stg = stage
        for ix = 1:nperm
            if sz>19
                VP2 = unique(VP);
                VPx =  VP2(cell2mat(arrayfun(@(dummy) randperm(length(VP2)), 1:nperm, 'UniformOutput', false)')'); %permute the data
                PSD3 = [];
                for i=1:length(VP2)
                    PSD_x = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
                    PSD3 = vertcat(PSD3, PSD_x); % combine all CH1 for all awakenings
                end
                PSD_perm(:,ix,stg) = PSD3;
                PSD3 = [];
            else
                VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data
                for i=1:sz
                    PSD_perm(i,ix,stg) = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
                end
            end
        end
    end
end
%% compute the differences in the randomization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%compute the random differences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this loop is basically same above, but uses permuted PSD matrix by taking parameters as constant%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    for ix = 1:nperm
        within = []; between =[]; PSD_within=[]; PSD_between =[]; between_corr_books=[];
        for a =1:length(unique(parameters))
            PSD_within = PSD_perm(parameters==a,ix,stg);
            for l = 1:length(PSD_within)
                PSD_within = PSD_perm(parameters==a,ix,stg);
                Aleft= PSD_within{l, 1} ;
                PSD_within{l, 1}  = nan(size(Aleft));
                within_rest = nanmean([(PSD_within{:})],2);
                within(l,a) = atanh(corr(Aleft, within_rest, 'Type','Spearman'));
                within(within==0) = NaN;
                
                other_audio = parameters(parameters~=a);
                ia = unique(other_audio);
                for iax = 1:length(ia)
                    PSD_btw = PSD_perm(parameters==ia(iax),ix,stg);
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

for stg =stage
    %Phibson 2010 Permutation P-values should never be zero: calculating exact P - NCBI
    % getting probability of finding observed difference from random permutations
    if strcmp(stat, 'both')
        p(stg) = (length(find(abs(randomdifferences_ztrans(:, stg)) > abs(observeddifference_ztrans(stg))))+1) / (nperm+1);
    elseif strcmp(stat, 'smaller')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) < observeddifference_ztrans(stg)))+1) / (nperm+1);
    elseif strcmp(stat, 'larger')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) >= observeddifference_ztrans(stg)))) / (nperm+1);
    end
    t = tiledlayout(1, 1);
    set(gcf, 'PaperUnits', 'inches');
    x_width=8 ;y_width=5.8;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    plot_permutation(randomdifferences_ztrans, observeddifference_ztrans, stg,p)
    dir = strcat(string(stg),'_permutation_1-3_leaveour');
    saveas(t, fullfile(dir), 'jpeg') 
end
clear PSD_perm
save stats_averaging_1-3 p randomdifferences_ztrans observeddifference_ztrans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%