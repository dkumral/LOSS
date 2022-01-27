%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%the function computes the permutation based on RSA matrix correlation computation%%%%%%%%%%%%%%%%%%%%%%
%%%it creates RSA matrix and from there it computes observed difference%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%RSA is based on spearman correlation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_RSA_matrix_dream(PSD,nperm, sz, VP, parameters, stat, stage,searchlight,frangeAll,ifreq)
%%this part is for the observed differences%%
close all
rng(10)
%%this is if it is searchlight
if isequal(searchlight,'yes') %this is for the searchlight analyses
    F=0.5:0.5:30;
    values = 1:length(PSD{1, stage(1)});
    loc = find(F>=frangeAll(ifreq,1) & F<=frangeAll(ifreq,2));
    for k = 1:length(loc)
        main_loc(k,:) = loc(k):length(F):length(PSD{1, stage(1)});
        main_loc2 = reshape(main_loc,[],1); %find the corresponding frequency
    end
    % main_loc3 = ~ismember(values', main_loc2); %take not other frequencies
    for stg = stage
        for i=1:sz
            PSD{i,stg}= PSD{i,stg}(main_loc2,1);
        end
    end
else
    PSD = PSD;
end
clear main_loc2 main_loc3 loc F 
%%
for stg = stage %stages of interests
    matrix = corr([PSD{:,stg}], 'type', 'Spearman'); %compute the correlation betweeen individuals: psdx19
    matrix = tril(atanh(matrix)); %z-transform and take the Lower triangular part of matrix
    matrix(matrix==0) = NaN;    %transform all 0 (which was created in atanh) to NaN
    matrix(matrix==Inf) =  NaN; %transform all Inf (corr dimension) (which was created in atanh) to NaN
    
    within_corr_books= [];      %create an empty output matrix for within
    between_corr_books = [];    %create an empty output matrix for between
    
    for a= 1:length(unique(parameters)) %number of parameters
        within_corr =  rmmissing(reshape(matrix(find(parameters == a),find(parameters == a)).',1,[])); %find the corresponding correlation values
        within_corr_books  = horzcat(within_corr_books, within_corr); %Concatenate arrays
    end
    matrixdim = rmmissing(matrix(:)); %remove the empty cells or missings (NA) in the correlationmatrix
    between_corr_books = matrixdim(find(~ismember(matrixdim,within_corr_books))); %find the rest other than that parameterss
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
end
clear  within_corr matrixdim  rowIdcs matrix  within_corr_books  matrix  between_corr_books
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%this permutation for the dream condition every line can be either 1 or 2,
%changing based on the every second row
dreamX= [1:2];
dreampermM = [];
for x = 1:19
    dreamperm =  dreamX(cell2mat(arrayfun(@(dummy) randperm(2), 1:nperm, 'UniformOutput', false)')'); %permute the data
    dreampermM = [dreamperm;dreampermM];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%compute the random differences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this loop is basically same above, but uses permuted PSD matrix by taking parameters as constant%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    for ix = 1:nperm
        matrix = corr([PSD{:,stg}], 'type', 'Spearman'); %compute the correlation betweeen individuals: psdx19
        matrix = tril(atanh(matrix));
        matrix(matrix==0) = NaN;
        matrix(matrix==Inf) = NaN;
        within_corr_books= [];
        between_corr_books = [];
        for a= 1:length(unique(parameters)) %number of parameters
            within_corr =  rmmissing(reshape(matrix(find(dreampermM(:,ix)  == a),find(dreampermM(:,ix)  == a)).',1,[]));
            within_corr_books  = horzcat(within_corr_books, within_corr); %combine the data
        end
        matrixdim = rmmissing(matrix(:));
        between_corr_books = matrixdim(find(~ismember(matrixdim,within_corr_books)));
        randomdifferences_ztrans(ix, stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
    end
end
clear ix data_btw data_within  matrixdim  rowIdcs matrix within_corr within_corr_books between_corr_books
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%compute p-value visulation of the permutations results%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t = tiledlayout(length(stage), 2);
set(gcf, 'PaperUnits', 'inches');
x_width=15 ;y_width=5.8*length(stage);
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
    plot_permutation_matrix(randomdifferences_ztrans, observeddifference_ztrans, stg,p,parameters,PSD,VP)
end

saveas(t, 'permutation_correlation_matrix_NONREM_s2.jpeg')
save stats_rsa p randomdifferences_ztrans observeddifference_ztrans dreampermM
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
