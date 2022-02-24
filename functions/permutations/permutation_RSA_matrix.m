%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%the function computes the permutation based on RSA matrix correlation computation%%%%%%%%%%%%%%%%%%%%%%
%%%it creates RSA matrix and from there it computes observed difference%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%RSA is based on Spearman correlation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_RSA_matrix(PSD,nperm, sz, VP, parameters, stat, stage,searchlight, ROI,r,frangeAll,ifreq)
%%this part is for the observed differences%%
close all
rng(999)
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
%% this is for the permutation (shuffle)
if isequal(searchlight,'freq') %this is for the searchlight analyses
    PSD_perm = searchlight_PSD(VP,sz,nperm,frangeAll,stage,PSD,ifreq);
elseif isequal(searchlight,'channel') %this is for the searchlight analyses
    PSD_perm = searchlight_ROI(VP,sz,nperm,stage,PSD,ROI,r);
elseif isequal(searchlight,'both') %this is for the searchlight analyses
    PSD_perm = searchlight_PSD_ROI(VP,sz,nperm,frangeAll,stage,PSD,ifreq,ROI,r); 
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%compute the random differences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this loop is basically same above, but uses permuted PSD matrix by taking parameters as constant%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    for ix = 1:nperm
        matrix = corr([PSD_perm{:,ix, stg}],'type', 'Spearman');
        matrix = tril(atanh(matrix));
        matrix(matrix==0) = NaN;
        matrix(matrix==Inf) = NaN;
        within_corr_books= [];
        between_corr_books = [];
        for a= 1:length(unique(parameters)) %number of parameters
            within_corr =  rmmissing(reshape(matrix(find(parameters == a),find(parameters == a)).',1,[]));
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

for stg =stage
    %Phibson 2010 Permutation P-values should never be zero: calculating exact P - NCBI
    % getting probability of finding observed difference from random permutations
    if strcmp(stat, 'both')
        p(stg) = (length(find(abs(randomdifferences_ztrans(:, stg)) > abs(observeddifference_ztrans(stg))))) / (nperm+1);
    elseif strcmp(stat, 'smaller')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) < observeddifference_ztrans(stg)))) / (nperm+1);
    elseif strcmp(stat, 'larger')
        p(stg) = (length(find(randomdifferences_ztrans(:, stg) >= observeddifference_ztrans(stg)))) / (nperm+1);
    end
    % plotting result
    
    t = tiledlayout(1, 2);
    set(gcf, 'PaperUnits', 'inches');
    x_width=15 ;y_width=5.8;
    set(gcf, 'PaperPosition', [0 0 x_width y_width]); %
    plot_permutation_matrix(randomdifferences_ztrans, observeddifference_ztrans, stg,p,parameters,PSD,VP)
    dir = strcat(string(stg),'_permutation_correlation_matrix');
    saveas(t, fullfile(dir), 'jpeg')
end

save stats_rsa p randomdifferences_ztrans observeddifference_ztrans
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
