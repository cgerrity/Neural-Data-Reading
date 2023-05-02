function blockData = AddBlockType(blockData, exptType, dataPath)

nBlocks = height(blockData);
ID_ED = nan(nBlocks,1);
BlockType = nan(nBlocks,1);

if strcmp(exptType, 'FLU')
    fileInfo = dir([dataPath filesep 'FrameData' filesep '*__block_defs.json']);
    if strcmp(fileInfo(1).name(1), '.')
        fileInfo(1) = [];
    end
    blockDefs = jsondecode(fileread([dataPath filesep 'FrameData' filesep fileInfo(1).name]));
    if ismember('RelevantDimension', blockData.Properties.VariableNames)
        blockData.RelevantDimension = [];
        blockData.RewardedValue = [];
        blockData.RelevantDimension = nan(height(blockData),1);
        blockData.RewardedValue = nan(height(blockData),1);
    end
end

for iBlock = 1:nBlocks
    
    if iBlock > 1
        if strcmp(exptType, 'FLU_GL')
            if blockData.RelevantDimension(iBlock) == blockData.RelevantDimension(iBlock - 1)
                ID_ED(iBlock) = 1;
            else
                ID_ED(iBlock) = 0;
            end
        elseif strcmp(exptType, 'FLU')
           relDimPrev = find(blockDefs(iBlock-1).RuleArray(1).RelevantFeatureTemplate ~= -1);
           relDimCurr = find(blockDefs(iBlock).RuleArray(1).RelevantFeatureTemplate ~= -1);
           if relDimPrev == relDimCurr
               ID_ED(iBlock) = 1;
           else
               ID_ED(iBlock) = 0;
           end
        end
    end
    if strcmp(exptType,'FLU')
        blockData.RelevantDimension(iBlock) = find(blockDefs(iBlock).RuleArray(1).RelevantFeatureTemplate ~= -1);
        blockData.RewardedValue(iBlock) = blockDefs(iBlock).RuleArray(1).RelevantFeatureTemplate(blockData.RelevantDimension(iBlock));
    end
    
    switch exptType
        case 'FLU'
            BlockType(blockData.HighRewardValue == 0.85 & blockData.NumActiveDims == 2) = 1;
            BlockType(blockData.HighRewardValue == 0.85 & blockData.NumActiveDims == 5) = 2;
            BlockType(blockData.HighRewardValue == 0.7 & blockData.NumActiveDims == 2) = 3;
            BlockType(blockData.HighRewardValue == 0.7 & blockData.NumActiveDims == 5) = 4;
        case 'FLU_GL'
            BlockType(blockData.MeanPositiveTokens == 2 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 2) = 1;
            BlockType(blockData.MeanPositiveTokens == 1 & blockData.MeanNegativeTokens == -2 & blockData.NumActiveDims == 2) = 2;
            BlockType(blockData.MeanPositiveTokens == 0 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 2) = 3;
            BlockType(blockData.MeanPositiveTokens == 2 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 5) = 4;
            BlockType(blockData.MeanPositiveTokens == 1 & blockData.MeanNegativeTokens == -2 & blockData.NumActiveDims == 5) = 5;
            BlockType(blockData.MeanPositiveTokens == 0 & blockData.MeanNegativeTokens == 0 & blockData.NumActiveDims == 5) = 6;
        otherwise
            error('Unknown experiment type');
    end
    if sum(isnan(BlockType)) > 0
        error('Blocks not assigned to condition.');
    end
end

blockData = [blockData table(ID_ED, BlockType)];