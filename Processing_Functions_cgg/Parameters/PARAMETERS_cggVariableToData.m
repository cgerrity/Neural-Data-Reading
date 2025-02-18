function cfg = PARAMETERS_cggVariableToData(VariableSet)
%PARAMETERS_CGGVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here

%% Variable Information

VariableInformation = PARAMETERS_cgg_VariableInformation(VariableSet);

%% Plot Sub Folder

switch VariableSet
    case 'Chosen Feature'
        PlotSubFolder='Chosen Feature';
    case 'Shared Feature'
        PlotSubFolder='Shared Feature Coding';
    case 'Previous Correct Shared'
        PlotSubFolder='Previous Correct Shared';
    case 'Previous Trial Effect'
        PlotSubFolder='Previous Trial Effect';
    case 'Correct'
        PlotSubFolder='Correct';
    case 'Prediction Error'
        PlotSubFolder='Prediction Error';
    case 'Positive Prediction Error'
        PlotSubFolder = 'Positive Prediction Error';
    case 'Negative Prediction Error'
        PlotSubFolder = 'Negative Prediction Error';
    case 'Absolute Prediction Error'
        PlotSubFolder = 'Absolute Prediction Error';
    case 'Outcome'
        PlotSubFolder = 'Outcome';
    case 'Error Trace'
        PlotSubFolder = 'Error Trace';
    case 'Choice Probability WM'
        PlotSubFolder = 'Choice Probability WM';
    case 'Choice Probability RL'
        PlotSubFolder = 'Choice Probability RL';
    case 'Choice Probability CMB'
        PlotSubFolder = 'Choice Probability CMB';
    case 'Value RL'
        PlotSubFolder = 'Value RL';
    case 'Value WM'
        PlotSubFolder = 'Value WM';
    case 'WM Weight'
        PlotSubFolder = 'WM Weight';
    case 'Dimension'
        PlotSubFolder = 'Dimension';
    case 'Trial Outcome'
        PlotSubFolder = 'Trial Outcome';
    case 'Adaptive Beta'
        PlotSubFolder = 'Adaptive Beta';
    case 'ZZZZZZ'
        PlotSubFolder = 'ZZZZZZ';
    otherwise
        PlotSubFolder = 'All Targets';
end

%% Target Function

switch VariableSet
    case 'Chosen Feature'
        Dimension=1:4;
        Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
    case 'Shared Feature'
        Target_Fun=@(x) cgg_loadTargetArray(x,'SharedFeatureCoding',true);
    case 'Previous Correct Shared'
        Dimension=1:4;
        Target_Fun_Previous=@(x) cgg_loadTargetArray(x,'OtherValue','AdjustedPreviousTrialCorrect');
        Target_Fun_Correct=@(x) cgg_loadTargetArray(x,'OtherValue','AdjustedCorrectTrial');
        Target_Fun_Shared=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
        Target_Fun=@(x) [Target_Fun_Previous(x), Target_Fun_Correct(x), Target_Fun_Shared(x)];
    case 'Previous Trial Effect'
        Target_Fun_Previous=@(x) cgg_loadTargetArray(x,'OtherValue','AdjustedPreviousTrialCorrect');
        Target_Fun_Correct=@(x) cgg_loadTargetArray(x,'OtherValue','AdjustedCorrectTrial');
        Target_Fun=@(x) Target_Fun_Correct(x)*2 + Target_Fun_Previous(x) + 1;
    case 'Correct'
        Target_Fun=@(x) cgg_loadTargetArray(x,'CorrectTrial',true);
    case 'Prediction Error'
        Target_Fun=@(x) mean(cgg_loadTargetArray(x,'PredictionError',true));
    case 'Positive Prediction Error'
        Target_Fun_PE=@(x) mean(cgg_loadTargetArray(x,'PredictionError',true));
        Target_Fun = @(x) cgg_setRangeToNaN(Target_Fun_PE(x),'Positive');
    case 'Negative Prediction Error'
        Target_Fun_PE=@(x) mean(cgg_loadTargetArray(x,'PredictionError',true));
        Target_Fun = @(x) cgg_setRangeToNaN(Target_Fun_PE(x),'Negative');
    case 'Absolute Prediction Error'
        Target_Fun=@(x) mean(abs(cgg_loadTargetArray(x,'PredictionError',true)));
    case 'Outcome'
        Target_Fun=@(x) cgg_loadTargetArray(x,'OtherValue','R') + 0*cgg_loadTargetArray(x,'OtherValue','NonRewardTrace');
    case 'Error Trace'
        Target_Fun=@(x) cgg_loadTargetArray(x,'OtherValue','NonRewardTrace');
    case 'Choice Probability WM'
        Target_Fun_ChoiceProbability=@(x) cgg_loadTargetArray(x,'OtherValue','ChoiceProbability_ObjectChosen_WM_RL_CMB');
        Target_Fun = @(x) max(cgg_getDataFromIndices(Target_Fun_ChoiceProbability(x),1:3));
    case 'Choice Probability RL'
        Target_Fun_ChoiceProbability=@(x) cgg_loadTargetArray(x,'OtherValue','ChoiceProbability_ObjectChosen_WM_RL_CMB');
        Target_Fun = @(x) max(cgg_getDataFromIndices(Target_Fun_ChoiceProbability(x),4:6));
    case 'Choice Probability CMB'
        Target_Fun_ChoiceProbability=@(x) cgg_loadTargetArray(x,'OtherValue','ChoiceProbability_ObjectChosen_WM_RL_CMB');
        Target_Fun = @(x) max(cgg_getDataFromIndices(Target_Fun_ChoiceProbability(x),7:9));
    case 'Value RL'
        Target_Fun=@(x) mean(cgg_loadTargetArray(x,'OtherValue','Value_ObjectChosen_RL'));
    case 'Value WM'
        Target_Fun=@(x) mean(cgg_loadTargetArray(x,'OtherValue','Value_ObjectChosen_WM'));
    case 'WM Weight'
        Target_Fun_ChoiceProbability=@(x) cgg_loadTargetArray(x,'OtherValue','ChoiceProbability_ObjectChosen_WM_RL_CMB');
        Target_Fun = @(x) cgg_getDataFromIndices(Target_Fun_ChoiceProbability(x),10);
    case 'Dimension'
        Dimension=1:4;
        Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
    case 'Trial Outcome'
        Target_Fun=@(x) double(cgg_loadTargetArray(x,'CorrectTrial',true));
    case 'Adaptive Beta'
        Target_Fun=@(x) cgg_loadTargetArray(x,'OtherValue','AdaptiveBeta');
    case 'ZZZZZ'
        Target_Fun=@(x) cgg_loadTargetArray(x,'OtherValue','R');
    otherwise
        Target_Fun=@(x) cgg_loadTargetArray(x,'AllTargets',true);
end


%%

cfg = struct;
cfg.VariableInformation = VariableInformation;
cfg.PlotSubFolder = PlotSubFolder;
cfg.Target_Fun = Target_Fun;

end

