function outData = LpLME_FLU_GL(blockData, fixedFactors)

if sum(ismember(fixedFactors, 'BlockReward')) > 0
    blockData.BlockReward = cell(height(blockData),1);
    blockData.BlockReward(blockData.MeanPositiveTokens == 2) = {'Positive'};
    blockData.BlockReward(blockData.MeanPositiveTokens == 1) = {'Negative'};
    blockData.BlockReward(blockData.MeanPositiveTokens == 0) = {'Neutral'};
end

outData.RawData = blockData(:,[{'LP', 'SubjectNum'} fixedFactors]);



factorString = fixedFactors{1};
for i = 1:length(fixedFactors)
    outData.RawData.(fixedFactors{i}) = categorical(outData.RawData.(fixedFactors{i}));
    if i > 1
        factorString = [factorString ' * ' fixedFactors{i}];
    end
end

outData.LME = fitlme(outData.RawData, ['LP ~ ' factorString ' + (1|SubjectNum)'], 'dummyvarcoding', 'effects', 'fitmethod', 'reml');
outData.FixedEffects = anova(outData.LME, 'DFMethod', 'Satterthwaite');
