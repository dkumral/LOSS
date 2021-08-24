%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%the function computes the permutation based on RSA matrix correlation computation%%%%%%%%%%%%%%%%%%%%%%
%%%it creates RSA matrix and from there it computes observed difference%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%RSA is based on spearman correlation%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [p, observeddifference_ztrans]  = permutation_RSA_matrix(PSD,nperm, sz, VP, audiobook, stat, stage)
%%this part is for the observed differences%%
close all
for stg = stage %stages of interests
    matrix = corr([PSD{:,stg}], 'type', 'Spearman'); %compute the correlation betweeen individuals: psdx19
    matrix = tril(atanh(matrix)); %z-transform and take the Lower triangular part of matrix
    matrix(matrix==0) = NaN;    %transform all 0 (which was created in atanh) to NaN
    matrix(matrix==Inf) =  NaN; %transform all Inf (corr dimension) (which was created in atanh) to NaN
    
    within_corr_books= [];      %create an empty output matrix for within
    between_corr_books = [];    %create an empty output matrix for between
    
    for a= 1:4 %number of audiobook
        within_corr =  rmmissing(reshape(matrix(find(audiobook == a),find(audiobook == a)).',1,[])); %find the corresponding correlation values
        within_corr_books  = horzcat(within_corr_books, within_corr); %Concatenate arrays
    end
    matrixdim = rmmissing(matrix(:)); %remove the empty cells or missings (NA) in the correlationmatrix
    between_corr_books = matrixdim(find(~ismember(matrixdim,within_corr_books))); %find the rest other than that audiobooks
    observeddifference_ztrans(stg) = nanmean(within_corr_books)-nanmean(between_corr_books);
end

clear  within_corr matrixdim  rowIdcs matrix  within_corr_books  matrix 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% this is for the permutation (shuffle)
VPx =  VP(cell2mat(arrayfun(@(dummy) randperm(sz), 1:nperm, 'UniformOutput', false)')'); %permute the data

for stg = stage 
    for i=1:sz
        for ix = 1:nperm
            PSD_perm(i,ix,stg) = PSD(find(VP  == VPx(i,ix)),stg); %arrange the PSDs based ont he permuted data
        end
    end
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%compute the random differences %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%this loop is basically same above, but uses permuted PSD matrix by taking audiobook as constant%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for stg = stage
    for ix = 1:nperm
        matrix = corr([PSD_perm{:,ix, stg}],'type', 'Spearman');
        matrix = tril(atanh(matrix));
        matrix(matrix==0) = NaN; 
        matrix(matrix==Inf) = NaN;
        within_corr_books= [];   
        between_corr_books = [];
        for a= 1:4 %number of audiobook
            within_corr =  rmmissing(reshape(matrix(find(audiobook == a),find(audiobook == a)).',1,[]));
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
    nexttile
    data = corr([PSD{:,stg}]);
    colormap(brewermap([],'YlGnBu')); %get current colormap
    imagesc(data)
    colorbar();
end
saveas(t, 'permutation_correlation_matrix.jpeg')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
