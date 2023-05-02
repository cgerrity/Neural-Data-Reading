function output = blockResults(blockData, dv)

SelectorDetails;



blockData(isnan(blockData.ID_ED),:) = [];

dimDets = analysisDetails.BlockClasses.Dimensionality;
stoDets = analysisDetails.BlockClasses.Stochasticity;
typDets = analysisDetails.BlockClasses.ID_ED;
subjectCall = {'subject', 1, blockData, {@(x) true(size(x,1),1), {}, {'SubjectNum'}, {'SubjectNum'}}, {@(x) x, {}, 1}};

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
            blockCall = {'block', 2, blockData, {blockSelector, {}, {'SubjectNum', 'SessionNum', 'Block'}}, ...
                {@(x) nanmean(x.(dv)), {}, 1}};
            output.BlockMeans.(['Dim_' dim]).(['Stoch_' sto]).(['IdEd_' typ]) = ...
                GetSubjMeans_GAVG_SEM(squeeze(HierarchicalAnalysis(subjectCall, blockCall))');
        end
    end
end




output.LMEs.Dim_X_Sto_X_Typ = ...
    LpLME_FLU(blockData, dv, {'NumActiveDims', 'HighRewardValue', 'ID_ED'}, {}, 'SubjectNum', [dv '~ NumActiveDims * HighRewardValue * ID_ED']);
output.LMEs.Dim_p_Sto_p_Typ = ...
    LpLME_FLU(blockData, dv, {'NumActiveDims', 'HighRewardValue', 'ID_ED'}, {}, 'SubjectNum', [dv '~ NumActiveDims + HighRewardValue + ID_ED']);
output.LMEs.Dim_p_Sto_X_Typ = ...
    LpLME_FLU(blockData, dv, {'NumActiveDims', 'HighRewardValue', 'ID_ED'}, {}, 'SubjectNum', [dv '~ (NumActiveDims + HighRewardValue) * ID_ED']);
output.LMEs.Dim_X_Sto = ...
    LpLME_FLU(blockData, dv, {'NumActiveDims', 'HighRewardValue'}, {}, 'SubjectNum', [dv '~ NumActiveDims * HighRewardValue']);
output.LMEs.Dim_p_Sto = ...
    LpLME_FLU(blockData, dv, {'NumActiveDims', 'HighRewardValue'}, {}, 'SubjectNum', [dv '~ NumActiveDims + HighRewardValue']);

output.LMEComp.Dim_p_Sto__vs__Dim_X_Sto = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_X_Sto.AllSubjs.LME);
output.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_p_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_p_Sto_p_Typ.AllSubjs.LME);
output.LMEComp.Dim_p_Sto__vs__Dim_X_Sto_X_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_X_Sto_X_Typ.AllSubjs.LME);
output.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_X_Typ = CompareLMEs(output.LMEs.Dim_p_Sto.AllSubjs.LME,output.LMEs.Dim_p_Sto_X_Typ.AllSubjs.LME);

function compResults = CompareLMEs(lme1, lme2)
[compResults.Results, compResults.SimInfo] = compare(lme1, lme2, 'NSim', 500);

function func = ChooseSelectorFromList(list, details)
func = FindFuncFromName(list.(details{1}).Names, list.(details{1}).Selectors, details{2});

function func = FindFuncFromName(nameList, funcList, name)
func = funcList{strcmp(nameList, name)};