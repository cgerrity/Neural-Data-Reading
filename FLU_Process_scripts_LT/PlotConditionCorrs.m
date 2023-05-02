function PlotConditionCorrs(corrData, cond, ylab)

means = grpstats(corrData.SubjCorrsCondition, cond, 'nanmean');
sems = grpstats(corrData.SubjCorrsCondition, cond, 'SEM');

errorbar(means, sems, 'linestyle', 'none', 'marker', 'o')

xlim([0.5 4.5]);
xticks(1:4);
xticklabels({'2.85', '5.85', '2.70', '5.70'});
ylabel(ylab);