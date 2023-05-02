
function results = GetSubjMeans_GAVG_SEM(subjResults)
if size(subjResults,2) > 1 && size(subjResults,1) == 1
    subjResults = subjResults';
end
results.SubjData = subjResults;
results.Mean = nanmean(subjResults,1);
results.Median = nanmedian(subjResults,1);
results.SEM = nanstd(subjResults,1) ./ sqrt(sum(~isnan(subjResults),1));