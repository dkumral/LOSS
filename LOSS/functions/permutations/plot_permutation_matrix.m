%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%this function is for plotting the permutation results%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  []= plot_permutation_matrix(randomdifferences_ztrans, observeddifference_ztrans, stg,p,parameters,PSD,VP)

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
[parameters ind] = sortrows(parameters); %sorting basedon parameters
data = corr([PSD{ind,stg}]);
matrix = tril(atanh(data)); %z-transform and take the Lower triangular part of matrix
colormap(brewermap([],'GnBu')); %get current colormap
imagesc(matrix);
for aud = 1:length(unique(parameters))-1
    x1 = find(parameters==aud);
    loc(aud) = (x1(end) +0.5);
    line([0 loc(aud)], [loc(aud) loc(aud)],'Color', '#A2142F', 'LineWidth',3); % vertical
    line([loc(aud) loc(aud)],[loc(aud) size(VP,1)],'Color', '#A2142F', 'LineWidth',2); % vertical
end
colorbar();
xticklabels('')
yticklabels('')
end
%%
