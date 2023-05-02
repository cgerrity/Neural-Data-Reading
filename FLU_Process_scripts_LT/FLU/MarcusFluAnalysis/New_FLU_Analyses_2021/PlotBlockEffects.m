function PlotBlockEffects(blockData)

subplot(1,3,1)
PlotMe(blockData.LP.BlockMeans, 'LP Trial');
ylim([2 9]);
legend({'2D', '5D'}, 'location', 'northwest');

subplot(1,3,2)
PlotMe(blockData.PostLpAcc.BlockMeans, 'Proportion Errors Post LP', 1);
ylim([0 0.16]);
yticks([0 0.05 0.10 0.15])

subplot(1,3,3)
PlotMe(blockData.ProportionLps.BlockMeans, 'Proportion Unreached LPs', 1)
ylim([0 0.16]);
yticks([0 0.05 0.10 0.15])


function PlotMe(blockMeans, ylab, varargin)
means = [blockMeans.Dim_2D.Stoch_15.IdEd_All.Mean, blockMeans.Dim_2D.Stoch_30.IdEd_All.Mean; ...
    blockMeans.Dim_5D.Stoch_15.IdEd_All.Mean, blockMeans.Dim_5D.Stoch_30.IdEd_All.Mean];
sems = [blockMeans.Dim_2D.Stoch_15.IdEd_All.SEM, blockMeans.Dim_2D.Stoch_30.IdEd_All.SEM; ...
    blockMeans.Dim_5D.Stoch_15.IdEd_All.SEM, blockMeans.Dim_5D.Stoch_30.IdEd_All.SEM];
if ~isempty(varargin)
    means = 1-means;
end

errorbar(means, sems);

% errorbar(means(1,:), sems(1,:));
% hold on
% errorbar(means(2,:), sems(2,:));

xlim([0.5 2.5])
xticks(1:2)
xticklabels({'15', '30'})
xlabel('Stochasticity')
ylabel(ylab)
set(gca, 'fontsize', 12);

