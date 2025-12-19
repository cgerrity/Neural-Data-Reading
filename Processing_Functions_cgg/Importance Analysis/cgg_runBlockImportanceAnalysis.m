function IA_Table = cgg_runBlockImportanceAnalysis(PassTableEntry,...
    cfg_Epoch,cfg_Encoder)
%CGG_RUNBLOCKIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

% <<<<<<BLOCK>>>>>>
fprintf('   *** Starting Block Run\n');
[IAPathName,RemovalTablePathName,IATestPathName] = ...
    cgg_generateImportanceAnalysisFileNames(PassTableEntry,cfg_Epoch,...
    'WantDirectory',true);
RemovalTablePathNameExt = sprintf('%s.mat',RemovalTablePathName);
IATestPathNameExt = sprintf('%s.mat',IATestPathName);
IAPathNameNameExt = sprintf('%s.mat',IAPathName);

%%
Message_FileIA = extractAfter(fileparts(IATestPathNameExt),...
    'Importance Analysis/');
fprintf('   *** File: %s\n',Message_FileIA);
%%

if isfield(cfg_Encoder,'Epoch')
Epoch = cfg_Encoder.Epoch;
end

PassTableVariableNames = PassTableEntry.Properties.VariableNames;
if ismember("SessionName", PassTableVariableNames)
SessionName = PassTableEntry.SessionName;
end
if ismember("Fold", PassTableVariableNames)
Fold = PassTableEntry.Fold;
end
if ismember("RemovalType", PassTableVariableNames)
RemovalType = PassTableEntry.RemovalType;
end
if ismember("TrialFilter", PassTableVariableNames)
TrialFilter = PassTableEntry.TrialFilter;
end
if ismember("TrialFilter_Value", PassTableVariableNames)
TrialFilter_Value = PassTableEntry.TrialFilter_Value;
end
if ismember("MatchType", PassTableVariableNames)
MatchType = PassTableEntry.MatchType;
MatchType_Attention = MatchType;
end
if ismember("TimeRange", PassTableVariableNames)
TimeRange = PassTableEntry.TimeRange;
end
if ismember("TargetFilter", PassTableVariableNames)
TargetFilter = PassTableEntry.TargetFilter;
AttentionalFilter = TargetFilter;
end
if ismember("Target", PassTableVariableNames)
Target = PassTableEntry.Target;
end

IsQuaddle = false;
if strcmp(Target,"Dimension")
    IsQuaddle = true;
end

[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Unpack');
%%

% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
FoldDir = cgg_getDirectory(cfg_Epoch.ResultsDir,'Fold');

[Subset,wantSubset] = cgg_verifySubset(SessionName,cfg_Encoder.wantSubset);
cfg_Encoder.Subset = Subset;
cfg_Encoder.wantSubset = wantSubset;
cfg_Encoder.Fold = Fold;
%% Get Network and Data
fprintf('   *** Getting Network and Data\n');

% Network
cfg_Network = cgg_generateEncoderSubFolders_v2(FoldDir,cfg_Encoder,'WantDirectory',false);
Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
EncoderPathNameExt =fullfile(Encoding_Dir, 'Encoder-Optimal.mat');
ClassifierPathNameExt =fullfile(Encoding_Dir, 'Classifier-Optimal.mat');

HasEncoderClassifier = isfile(EncoderPathNameExt) && isfile(ClassifierPathNameExt);

if HasEncoderClassifier
    % m_Encoder = matfile(EncoderPathNameExt,"Writable",false);
    m_Encoder = load(EncoderPathNameExt);
    Encoder=m_Encoder.Encoder;
    % m_Classifier = matfile(ClassifierPathNameExt,"Writable",false);
    m_Classifier = load(ClassifierPathNameExt);
    Classifier=m_Classifier.Classifier;
else
    fprintf('   !!! No Encoder and Classifier\n');
    return
end

% Data
EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
[~,~,Testing,ClassNames,~] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,cfg_Encoder,'WantData',true);

%%
BadData = preview(Testing);
BadData = squeeze(isnan(BadData{1}(:,1,:,1)));

[BadChannel,BadArea] = ind2sub(size(BadData),find(BadData));
BadChannelTable = table(BadChannel,BadArea,'VariableNames',{'ChannelIndices','AreaIndices'});

%
LayerNameIDX = contains({Encoder.Layers(:).Name},'Input_Encoder');
InputSize = Encoder.Layers(LayerNameIDX).InputSize;
LayerNameIDX = contains({Classifier.Layers(:).Name},'Input_Classifier');
LatentSize = Classifier.Layers(LayerNameIDX).InputSize;

NumChannels = InputSize(1);
NumAreas = InputSize(3);
%% Generate Removal Table
fprintf('   *** Generating Removal Table\n');
if isfile(RemovalTablePathNameExt)
    RemovalTable = load(RemovalTablePathNameExt);
    RemovalTable = RemovalTable.RemovalTable;
else
% <<<<<<BLOCK>>>>>>
    RemovalTable = cgg_getBlockRemovalTable(NumChannels,NumAreas,LatentSize,BadChannelTable,RemovalType);
    save(RemovalTablePathNameExt,'RemovalTable');
end
%% Obtain CM_Table Results
fprintf('   *** Obtaining IA Test Results\n');
if isfile(IATestPathNameExt)
    IA_Table_Test = load(IATestPathNameExt);
    IA_Table_Test = IA_Table_Test.IA_Table_Test;
else
    IA_Table_Test = cgg_procImportanceAnalysisFromRemovalTable(RemovalTable, Testing, Encoder, Classifier, 'ClassNames',ClassNames,'IsQuaddle',IsQuaddle);
    save(IATestPathNameExt,'IA_Table_Test');
end

%% Select Most Important Removal

fprintf('   *** Obtaining IA Results\n');
if isfile(IAPathNameNameExt)
    IA_Table = load(IAPathNameNameExt);
    IA_Table = IA_Table.IA_Table;
else
    %% Obtain Metric Results

    [~,NullTable] = cgg_isNullTableComplete(IA_Table_Test.CM_Table,cfg_Epoch,cfg_Encoder,'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,...
        'MatchType',MatchType,'TargetFilter',TargetFilter);
    Identifiers_Table = cgg_getIdentifiersTable(cfg_Epoch,wantSubset,'Epoch',Epoch,'Subset',Subset);

    MetricFunc = @(x) cgg_procCompleteMetric(x,cfg_Epoch,'Epoch',Epoch,...
        'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,...
        'MatchType',MatchType,'IsQuaddle',IsQuaddle,...
        'MatchType_Attention',MatchType_Attention,'TimeRange',TimeRange,...
        'AttentionalFilter',AttentionalFilter,'Subset',Subset,...
        'cfg_Encoder',cfg_Encoder,'Target',Target,...
        'WantUseNullTable',true,'Identifiers_Table',Identifiers_Table,...
        'NullTable',NullTable);
    
    MetricOutput = rowfun(MetricFunc,IA_Table_Test,"InputVariables","CM_Table","SeparateInputs",true,"ExtractCellContents",true,"NumOutputs",2,"OutputFormat","cell");
    
    Metric = cell2mat(MetricOutput(:,1));
    Window_Metric = cell2mat(MetricOutput(:,2));
%%
    % Block Specific
    % <<<<<<BLOCK>>>>>>
    IA_Table = IA_Table_Test;
    IA_Table = removevars(IA_Table, "CM_Table");
    IA_Table.Metric = Metric;
    IA_Table.WindowMetric = Window_Metric;
    save(IAPathNameNameExt,'IA_Table');
end

end

