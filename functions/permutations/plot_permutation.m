%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%this function is for plotting the permutation results%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function  []= plot_permutation(randomdifferences_ztrans, observeddifference_ztrans, stg,p)
 % plotting result
    nexttile()
    histogram(randomdifferences_ztrans(:, stg), 20, 'facecolor','#e8c3d6', 'EdgeColor', '#e8c3d6', 'facealpha', 0.5,  'LineStyle', 'none' );
    box off
    hold on;
    xlabel('Random Difference (z-transformed)');
    ylabel('Frequency')
    od = plot(observeddifference_ztrans(stg), 0, '*', 'MarkerSize',8,'MarkerEdgeColor','#8856a7', 'DisplayName', sprintf('p = %.3f',p(stg) ));
    xline(observeddifference_ztrans(stg), 'LineWidth', 2.5, 'color', '#8856a7');
    legend(od);
    legend boxoff
end
%%