function blockData = AddTokenInfo(blockData, blockjson)

nBlocks = height(blockData);
MeanPositiveTokens = nan(nBlocks,1);
MeanNegativeTokens = nan(nBlocks,1);

for iBlock = 1:nBlocks
    
    pos = blockjson(iBlock).BaseTokenRewardsPositive;
    neg = blockjson(iBlock).BaseTokenRewardsNegative;
    
    posRew = 0;
    for iRew = 1:length(pos)
        posRew = posRew + pos(iRew).NumTokens * pos(iRew).Probability;
    end
    negRew = 0;
    for iRew = 1:length(neg)
        negRew = negRew + neg(iRew).NumTokens * neg(iRew).Probability;
    end
    
    MeanPositiveTokens(iBlock) = posRew;
    MeanNegativeTokens(iBlock) = negRew;
end

blockData = [blockData table(MeanPositiveTokens, MeanNegativeTokens)];