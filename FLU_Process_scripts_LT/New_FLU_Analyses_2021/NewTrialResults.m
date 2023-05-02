function output = NewTrialResults(blockData, trialData, dv)

SelectorDetails;

minTrial = 1;
maxTrial = 80;
windowSize = 3;

blockData(isnan(blockData.ID_ED),:) = [];

dimDets = analysisDetails.BlockClasses.Dimensionality;
stoDets = analysisDetails.BlockClasses.Stochasticity;
typDets = analysisDetails.BlockClasses.ID_ED;
accDets = analysisDetails.TrialClasses.Accuracy;
lsDets = analysisDetails.TrialClasses.LearningStatus;
subjectCall = {'subject', 1, blockData, {@(x) true(size(x,1),1), {}, {'SubjectNum'}, {'SubjectNum'}}, {@(x) x, {}, 1}};

disp('Generating Meaned Data')
for iDim = 1:length(dimDets.Names)
    dim = dimDets.Names{iDim};
    dimFunc = ChooseSelectorFromList(analysisDetails.BlockClasses, {'Dimensionality', dim});
    for iStoch = 1:length(stoDets.Names)
        sto = stoDets.Names{iStoch};
        stoFunc = ChooseSelectorFromList(analysisDetails.BlockClasses, {'Stochasticity', sto});
        for iType = 1:length(typDets.Names)
            typ = typDets.Names{iType};
            typFunc = ChooseSelectorFromList(analysisDetails.BlockClasses, {'ID_ED', typ});
            blockSelector = @(x) dimFunc(x) & stoFunc(x) & typFunc(x);
            blockCall = {'block', 2, blockData, {blockSelector, {}, {'SubjectNum', 'SessionNum', 'Block'}, {'SubjectNum', 'SessionNum', 'Block'}}, ...
                {@(x) nanmean(x), {}, 1}};
            for iLs = 1:length(lsDets.Names)
                ls = lsDets.Names{iLs};
                lsFunc = ChooseSelectorFromList(analysisDetails.TrialClasses, {'LearningStatus', ls});
                for iAcc = 1:length(accDets.Names)
                    acc = accDets.Names{iAcc};
                    accFunc = ChooseSelectorFromList(analysisDetails.TrialClasses, {'Accuracy', acc});
                    trialSelector = @(x) lsFunc(x) & accFunc(x);
                    trialCall = {'trial', 3, trialData, {trialSelector, {}, {'SubjectNum', 'SessionNum', 'Block', 'Trial'}}, {@MeanBlock, {dv, minTrial, maxTrial}, 1}};
                    output.BlockMeans.(['Dim_' dim]).(['Stoch_' sto]).(['IdEd_' typ]) = ...
                        GetSubjMeans_GAVG_SEM(squeeze(HierarchicalAnalysis(subjectCall, blockCall, trialCall))');
                end
            end
        end
    end
end

blockData.SubjectNum = categorical(blockData.SubjectNum);
trialData.SubjectNum = categorical(trialData.SubjectNum);
% trialData.Acc = categorical(trialData.Acc);

if ~strcmpi(dv, 'acc')  
    disp('Generating models with accuracy')
    [output.AccModels.LMEs, output.AccModels.ModelCriteria, output.AccModels.ModelComparisons] = CompleteLME_3Factor(trialData, dv, {'Dim', 'Sto', 'Acc'}, {}, {'SubjectNum'});
    disp('Generating correct trial models.')
    [output.CorrModels.LMEs, output.CorrModels.ModelCriteria, output.CorrModels.ModelComparisons] = CompleteLME_3Factor(trialData(trialData.Acc==1,:), dv, {'Dim', 'Sto', 'LS'}, {}, {'SubjectNum'});
    disp('Generating incorrect trial models.')
    [output.IncModels.LMEs, output.IncModels.ModelCriteria, output.IncModels.ModelComparisons] = CompleteLME_3Factor(trialData(trialData.Acc==0,:), dv, {'Dim', 'Sto', 'LS'}, {}, {'SubjectNum'});
else
    [output.Models.LMEs, output.Models.ModelCriteria, output.Models.ModelComparisons] = CompleteLME_3Factor(trialData, dv, {'Dim', 'Sto', 'LS'}, {}, {'SubjectNum'});
end

% output.LMEComp.Dim_p_Sto__vs__Dim_X_Sto = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_X_Sto.AllSubjs.LME);
% output.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_p_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_p_Sto_p_Typ.AllSubjs.LME);
% output.LMEComp.Dim_p_Sto__vs__Dim_X_Sto_X_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_X_Sto_X_Typ.AllSubjs.LME);
% output.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_X_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_p_Sto_X_Typ.AllSubjs.LME);

function compResults = CompareLMEs(lme1, lme2)
[compResults.Results, compResults.SimInfo] = compare(lme1, lme2, 'NSim', 500);

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