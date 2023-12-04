function [ImportantAreaCount,Area_Names,Sorted_Values] = cgg_procImportanceAnalysisRanking(Difference_Accuracy,NumRankings)
%CGG_PROCIMPORTANCEANALYSISRANKING Summary of this function goes here
%   Detailed explanation goes here

[Sorted_Values,Sorted_Indices]=sort(Difference_Accuracy(:));


%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order = cfg_param.Probe_Order;

Area_Names=unique(extractBefore(Probe_Order,'_'));

%%

[ChannelNumber,ProbeNumber] = ind2sub(size(Difference_Accuracy),Sorted_Indices(1:NumRankings));

ImportantAreas=Probe_Order(ProbeNumber);

ImportantAreas=extractBefore(ImportantAreas,'_');

AreaNumbers=NaN(NumRankings,1);
for aidx=1:numel(Area_Names)
AreaNumbers(strcmp(ImportantAreas,Area_Names(aidx)))=aidx;
end

[ImportantAreaCount] = histcounts(AreaNumbers, numel(Area_Names));
end

