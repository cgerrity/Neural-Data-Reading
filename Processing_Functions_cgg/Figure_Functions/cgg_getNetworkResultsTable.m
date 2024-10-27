function NetworkResults = cgg_getNetworkResultsTable(NetworkResultsDir)
%CGG_GETNETWORKRESULTSTABLE Summary of this function goes here
%   Detailed explanation goes here

%%

FileList = dir(fullfile(NetworkResultsDir, '**/EncodingParameters.yaml'));  %get list of files and folders in any subfolder
FileList = FileList(~[FileList.isdir]);

FolderList = {FileList.folder};

%% Parameters

EssentialParameterNames = ["Fold","ModelName","DataWidth",...
    "WindowStride","InitialLearningRate","LossFactorReconstruction",...
    "LossFactorKL","MiniBatchSize","Subset","HiddenSizes_1",...
    "HiddenSizes_2","HiddenSizes_3","HiddenSizes_4","HiddenSizes_5",...
    "HiddenSizes_6","HiddenSizes_7","HiddenSizes_8","HiddenSizes_9",...
    "ClassifierName","ClassifierHiddenSizeString","HiddenSizesString",...
    "GradientThreshold"];
EssentialParameterNames = cellstr(EssentialParameterNames);

% IncludedEssentialIDX = false(1,length(EssentialParameterNames));

%%
NumFolders = length(FolderList);

NetworkResults = table();
%%
for fidx = 1:NumFolders
    %%
    this_PathNameExt = [FolderList{fidx} filesep 'Optimal_Results.mat'];
    this_CurrentPathNameExt = [FolderList{fidx} filesep 'CurrentIteration.mat'];

    this_OptimalIteration = NaN;
    this_CurrentIteration = NaN;
    this_ValidationAccuracy = NaN;
    this_ValidationWindow_Accuracy = NaN;
    this_ValidationMostCommon = NaN;
    this_ValidationRandomChance = NaN;
    this_TestingAccuracy = NaN;
    this_TestingWindow_Accuracy = NaN;
    this_TestingMostCommon = NaN;
    this_TestingRandomChance = NaN;
    this_ValidationAccuracy_Measure = NaN;
    this_TestingAccuracy_Measure = NaN;

    if isfile(this_PathNameExt)
        m_Optimal_Results = matfile(this_PathNameExt,"Writable",false);
        m_Current = matfile(this_CurrentPathNameExt,"Writable",false);
        this_TestingAccuracy = m_Optimal_Results.TestingAccuracy;
        this_TestingWindow_Accuracy = m_Optimal_Results.Window_AccuracyTesting;
        this_TestingMostCommon = m_Optimal_Results.TestingMostCommon;
        this_TestingRandomChance = m_Optimal_Results.TestingRandomChance;
        this_ValidationAccuracy = m_Optimal_Results.ValidationAccuracy;
        this_ValidationWindow_Accuracy = m_Optimal_Results.Window_AccuracyValidation;
        this_ValidationMostCommon = m_Optimal_Results.ValidationMostCommon;
        this_ValidationRandomChance = m_Optimal_Results.ValidationRandomChance;
        this_OptimalIteration = m_Optimal_Results.Iteration;
        this_CurrentIteration = m_Current.CurrentIteration;
        this_ValidationAccuracy_Measure = m_Optimal_Results.Combined_Accuracy_MeasureValidation;
        this_ValidationAccuracy_Measure = this_ValidationAccuracy_Measure{1};
        this_TestingAccuracy_Measure = m_Optimal_Results.Combined_Accuracy_MeasureTesting;
        this_TestingAccuracy_Measure = this_TestingAccuracy_Measure{1};
    end

    this_YAMLPathNameExt = [FolderList{fidx} filesep 'EncodingParameters.yaml'];
    EncodingParameters = ReadYaml(this_YAMLPathNameExt,0,true);

    % this_Fold = EncodingParameters.Fold;
    if isfield(EncodingParameters,"ClassifierHiddenSize")
        if iscell(EncodingParameters.ClassifierHiddenSize)
            EncodingParameters.ClassifierHiddenSizeString = ...
                sprintf("[%d]",[EncodingParameters.ClassifierHiddenSize{:}]);
        else
            EncodingParameters.ClassifierHiddenSizeString = ...
                sprintf("[%d]",EncodingParameters.ClassifierHiddenSize);
        end
    end
    if iscell(EncodingParameters.HiddenSizes)
        EncodingParameters.HiddenSizesString = ...
            sprintf("[%d]",[EncodingParameters.HiddenSizes{:}]);
    else
        EncodingParameters.HiddenSizesString = ...
            sprintf("[%d]",EncodingParameters.HiddenSizes);
    end
    %%
    % EncodingParameters.ClassifierHiddenSize = sprintf("[%d]",[EncodingParameters.ClassifierHiddenSize{:}]);
    % EncodingParameters.HiddenSizes = {cell2mat(EncodingParameters.HiddenSizes)};
    EncodingParameters = struct2table(EncodingParameters,"AsArray",true);
    EncodingParameters.HiddenSizes = cell2mat(EncodingParameters.HiddenSizes);
    EncodingParameters = splitvars(EncodingParameters,'HiddenSizes');
    EncodingParameters=convertvars(EncodingParameters,'ModelName','string');
    EncodingParameters=convertvars(EncodingParameters,'ClassifierName','string');
    AllVariableNames = EncodingParameters.Properties.VariableNames;
    TableRemovalIDX = ~ismember(AllVariableNames,EssentialParameterNames);
    EncodingParameters = removevars(EncodingParameters,TableRemovalIDX);

    AllVariableNames = EncodingParameters.Properties.VariableNames;
    CurrentEssentialIDX = ismember(EssentialParameterNames,AllVariableNames);
    % IncludedEssentialIDX = IncludedEssentialIDX | CurrentEssentialIDX;

    % IncludedEssentialParameterNames = EssentialParameterNames(IncludedEssentialIDX);
    ExcludedEssentialParameterNames = EssentialParameterNames(~CurrentEssentialIDX);
    
    for eidx = 1:length(ExcludedEssentialParameterNames)
    EncodingParameters.(ExcludedEssentialParameterNames{eidx}) = 0;
    end

    EncodingParameters.OptimalIteration = this_OptimalIteration;
    EncodingParameters.CurrentIteration = this_CurrentIteration;
    EncodingParameters.ValidationAccuracy = this_ValidationAccuracy;
    EncodingParameters.ValidationWindow_Accuracy = {this_ValidationWindow_Accuracy};
    EncodingParameters.ValidationAccuracy_Maximum = max(this_ValidationWindow_Accuracy);
    EncodingParameters.ValidationMostCommon = this_ValidationMostCommon;
    EncodingParameters.ValidationRandomChance = this_ValidationRandomChance;
    EncodingParameters.TestingAccuracy = this_TestingAccuracy;
    EncodingParameters.TestingWindow_Accuracy = {this_TestingWindow_Accuracy};
    EncodingParameters.TestingAccuracy_Maximum = max(this_TestingWindow_Accuracy);
    EncodingParameters.TestingMostCommon = this_TestingMostCommon;
    EncodingParameters.TestingRandomChance = this_TestingRandomChance;
    EncodingParameters.ValidationAccuracy_Measure = this_ValidationAccuracy_Measure;
    EncodingParameters.TestingAccuracy_Measure = this_TestingAccuracy_Measure;

    % this_OptimalIterationName = sprintf('OptimalIteration_Fold_%d',this_Fold);
    % this_CurrentIterationName = sprintf('CurrentIteration_Fold_%d',this_Fold);
    % this_ValidationAccuracyName = sprintf('ValidationAccuracy_Fold_%d',this_Fold);
    % this_ValidationMostCommonName = sprintf('ValidationMost_Fold_%d',this_Fold);
    % this_TestingAccuracyName = sprintf('TestingAccuracy_Fold_%d',this_Fold);
    % this_TestingMostCommonName = sprintf('TestingMostCommon_Fold_%d',this_Fold);
    % 
    % EncodingParameters.(this_OptimalIterationName) = this_OptimalIteration;
    % EncodingParameters.(this_CurrentIterationName) = this_CurrentIteration;
    % EncodingParameters.(this_ValidationAccuracyName) = this_ValidationAccuracy;
    % EncodingParameters.(this_ValidationMostCommonName) = this_ValidationMostCommon;
    % EncodingParameters.(this_TestingAccuracyName) = this_TestingAccuracy;
    % EncodingParameters.(this_TestingMostCommonName) = this_TestingMostCommon;

    % EncodingParameters(:,ismissing(EncodingParameters,NaN)) = {0};


    %%
    if fidx ==1
        NetworkResults = EncodingParameters;
    else
        NetworkResults = [NetworkResults;EncodingParameters];
    % NetworkResults = outerjoin(NetworkResults,EncodingParameters,'Keys',EssentialParameterNames,'MergeKeys',true);
    end
end

%%

NetworkResults.ValidationAccuracyAboveBaseline = NetworkResults.ValidationAccuracy - NetworkResults.ValidationMostCommon;
NetworkResults.TestingAccuracyAboveBaseline = NetworkResults.TestingAccuracy - NetworkResults.TestingMostCommon;

NetworkResults.RelativeValidationAccuracyAboveBaseline = NetworkResults.ValidationAccuracyAboveBaseline ./ (1-NetworkResults.ValidationMostCommon);
NetworkResults.RelativeTestingAccuracyAboveBaseline = NetworkResults.TestingAccuracyAboveBaseline ./ (1-NetworkResults.TestingMostCommon);

NetworkResults.OptimalIterationProgress = NetworkResults.OptimalIteration ./ NetworkResults.CurrentIteration *100;

end

