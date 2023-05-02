function outData = LpLME_FLU(dataTable, dv, fixedCategoricalFactors, fixedNumericFactors, randomFactors, formula)

if islogical(dataTable.(dv))
    dataTable.(dv) = double(dataTable.(dv));
end

if sum(ismember(fixedCategoricalFactors, 'BlockReward')) > 0
    dataTable.BlockReward = cell(height(dataTable),1);
    dataTable.BlockReward(dataTable.MeanPositiveTokens == 2) = {'Positive'};
    dataTable.BlockReward(dataTable.MeanPositiveTokens == 1) = {'Negative'};
    dataTable.BlockReward(dataTable.MeanPositiveTokens == 0) = {'Neutral'};
end

outData.AllSubjs.RawData = dataTable(:,[{dv} fixedCategoricalFactors fixedNumericFactors randomFactors]);


for i = 1:length(fixedCategoricalFactors)
    outData.AllSubjs.RawData.(fixedCategoricalFactors{i}) = categorical(outData.AllSubjs.RawData.(fixedCategoricalFactors{i}));
end

outData.AllSubjs.LME = fitlme(outData.AllSubjs.RawData, [formula ' + (1|SubjectNum)'], 'dummyvarcoding', 'effects', 'fitmethod', 'reml');
outData.AllSubjs.FixedEffects = anova(outData.AllSubjs.LME, 'DFMethod', 'Satterthwaite');

subjs = unique(dataTable.SubjectNum);

for iSubj = 1:length(subjs)
    subj = subjs(iSubj);
    sData = outData.AllSubjs.RawData(outData.AllSubjs.RawData.SubjectNum == subj,:);
    outData.(['Subj' num2str(subj)]).RawData = sData;
    outData.(['Subj' num2str(subj)]).LME = fitlme(sData, formula, 'dummyvarcoding', 'effects', 'fitmethod', 'reml');
    outData.(['Subj' num2str(subj)]).FixedEffects = anova(outData.(['Subj' num2str(subj)]).LME, 'DFMethod', 'Satterthwaite');

end