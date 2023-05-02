function PlotDvMeansSingleLine(conditionData, dv, ylab, varargin)

if ~isempty(varargin)
    suffix = ['_' varargin{1}];
else
    suffix = '';
end

means = [conditionData.(dv).(['D2_15' suffix]).BlockMeans.Mean conditionData.(dv).(['D2_30' suffix]).BlockMeans.Mean conditionData.(dv).(['D5_15' suffix]).BlockMeans.Mean conditionData.(dv).(['D5_30' suffix]).BlockMeans.Mean];
SEMs = [conditionData.(dv).(['D2_15' suffix]).BlockMeans.SEM conditionData.(dv).(['D2_30' suffix]).BlockMeans.SEM conditionData.(dv).(['D5_15' suffix]).BlockMeans.SEM conditionData.(dv).(['D5_30' suffix]).BlockMeans.SEM];


errorbar(means, SEMs);

xlim([0.5 4.5])
xticks(1:4)
xticklabels({'2/15', '2/30', '5/15', '5/30'})
ylabel(ylab)
set(gca, 'fontsize', 18);