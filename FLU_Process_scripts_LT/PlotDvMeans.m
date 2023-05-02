function PlotDvMeans(conditionData, dv, ylab)

means = [conditionData.(dv).D2_15.BlockMeans.Mean conditionData.(dv).D2_30.BlockMeans.Mean; conditionData.(dv).D5_15.BlockMeans.Mean conditionData.(dv).D5_30.BlockMeans.Mean];
SEMs = [conditionData.(dv).D2_15.BlockMeans.SEM conditionData.(dv).D2_30.BlockMeans.SEM; conditionData.(dv).D5_15.BlockMeans.SEM conditionData.(dv).D5_30.BlockMeans.SEM];

d5Means = [conditionData.(dv).D5_15.BlockMeans.Mean conditionData.(dv).D5_30.BlockMeans.Mean];
d5SEMs = [conditionData.(dv).D5_15.BlockMeans.SEM conditionData.(dv).D5_30.BlockMeans.SEM];

errorbar(means, SEMs);

xlim([0.5 2.5])
xticks(1:2)
ylabel(ylab)
set(gca, 'fontsize', 18);