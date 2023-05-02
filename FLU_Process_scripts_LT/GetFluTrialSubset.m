
function results = GetFluTrialSubset(blockData, trialData, blockSelectorDetails, trialSelectorDetails, varName)

minTrial = 1;
maxTrial = 80;
windowSize = 3;


%Current block dimensionality
analysisDetails.BlockClasses.Dimensionality.Names = {'All', '2D', '5D'};
analysisDetails.BlockClasses.Dimensionality.Selectors = {'all', @(x) TableSelector(x, 'NumActiveDims', @(y) y == 2), @(x) TableSelector(x, 'NumActiveDims', @(y) y == 5)};
%Current block stochasticity
analysisDetails.BlockClasses.Stochasticity.Names = {'All', '0.15', '0.30'};
analysisDetails.BlockClasses.Stochasticity.Selectors = {'all', @(x) TableSelector(x, 'HighRewardValue', @(y) y == 0.85), @(x) TableSelector(x, 'HighRewardValue', @(y) y == 0.70)};
%Current block intradimensional/extradimensional relationship to
%previous block
analysisDetails.BlockClasses.ID_ED.Names = {'All', 'ID', 'ED'};
analysisDetails.BlockClasses.ID_ED.Selectors = {'all', @(x) TableSelector(x, 'ID_ED', @(y) y == 1), @(x) TableSelector(x, 'ID_ED', @(y) y == 0)};%Current block intradimensional/extradimensional relationship to
%Current block learning status
analysisDetails.BlockClasses.LearningStatus.Names = {'All', 'Learned', 'Unlearned'};
analysisDetails.BlockClasses.LearningStatus.Selectors = {'all', @(x) TableSelector(x, 'LP', @(y) ~isnan(y)), @(x) TableSelector(x, 'LP', @(y) isnan(y))};

%Current trial accuracy
analysisDetails.TrialClasses.Accuracy.Names = {'All', 'Corr', 'Inc'};
analysisDetails.TrialClasses.Accuracy.Selectors = {'all', @(x) TableSelector(x, 'Acc', @(y) y == 1), @(x) TableSelector(x, 'Acc', @(y) y == 0)};
%Learning status of current trial context
analysisDetails.TrialClasses.LearningStatus.Names = {'All', 'Unlearned', 'PreLP', 'PostLP'};
analysisDetails.TrialClasses.LearningStatus.Selectors = {'all', @(x) TableSelector(x, 'LearningStatus', @(y) isnan(y)),...
    @(x) TableSelector(x, 'LearningStatus', @(y) y == 0), @(x) TableSelector(x, 'LearningStatus', @(y) y == 1)};


blockSelector = ChooseSelectorFromList(analysisDetails.BlockClasses, blockSelectorDetails{1});

if length(blockSelectorDetails) > 1
    for iSel = 2:length(blockSelectorDetails)
        newFunc = ChooseSelectorFromList(analysisDetails.BlockClasses, blockSelectorDetails{iSel});
        blockSelector = @(x) blockSelector(x) & newFunc(x);
    end
end


trialSelector = ChooseSelectorFromList(analysisDetails.TrialClasses, trialSelectorDetails{1});

if length(trialSelectorDetails) > 1
    for iSel = 2:length(trialSelectorDetails)
        newFunc = ChooseSelectorFromList(analysisDetails.TrialClasses, trialSelectorDetails{iSel});
        trialSelector = @(x) trialSelector(x) & newFunc(x);
    end
end

subjectCall = {'subject', 1, blockData, {@(x) true(size(x,1),1), {}, {'SubjectNum'}, {'SubjectNum'}}, {@(x) x, {}, 1}};
blockCall = {'block', 2, blockData, {blockSelector, {}, {'SubjectNum', 'SessionNum', 'Block'}, {'SubjectNum', 'SessionNum', 'Block'}}, {@nanmean, {}, 1}};
trialinBlockCall = {'trial', 3, trialData, {trialSelector, {}, {'SubjectNum', 'SessionNum', 'Block', 'Trial'}}, {@PreserveAndSlide, {varName, minTrial, maxTrial, windowSize}, maxTrial - minTrial + 1}};
trialMeanCall= {'trial', 3, trialData, {trialSelector, {}, {'SubjectNum', 'SessionNum', 'Block', 'Trial'}}, {@MeanBlock, {varName, minTrial, maxTrial}, 1}};

results.TrialInBlock = GetSubjMeans_GAVG_SEM(squeeze(HierarchicalAnalysis(subjectCall, blockCall, trialinBlockCall))');
results.BlockMeans = GetSubjMeans_GAVG_SEM(squeeze(HierarchicalAnalysis(subjectCall, blockCall, trialMeanCall))');


function func = ChooseSelectorFromList(list, details)
func = FindFuncFromName(list.(details{1}).Names, list.(details{1}).Selectors, details{2});

function func = FindFuncFromName(nameList, funcList, name)
func = funcList{strcmp(nameList, name)};

function smoothData = PreserveAndSlide(data, varName, minTrial, maxTrial, windowSize)
orderedData = PreserveTrialPosition(data, varName, minTrial, maxTrial);
smoothData = SlidingWindowBackward(orderedData,windowSize);

function result = MeanBlock(data, varName, minTrial, maxTrial)
orderedData = PreserveTrialPosition(data, varName, minTrial, maxTrial);
result = nanmean(orderedData);
