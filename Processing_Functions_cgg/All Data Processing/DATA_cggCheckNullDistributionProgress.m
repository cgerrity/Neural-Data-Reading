clc; clear; close all;
%%

% TrialFilters = {"Learned"};
% TrialFilters = {"Dimensionality"};
% TrialFilters = {"Trials From Learning Point Category"};
TrialFilters = {"Learned","Dimensionality"};
TrialFilters = {"Prediction Error Category"};
TrialFilters = {"Gain","Loss"};
TrialFilters = {"Gain"};
TrialFilters = {"Loss"};
TrialFilters = {"Correct Trial"};
TrialFilters = {"Previous"};
% TrialFilters = {"Target Value Category"};
% TrialFilters = {"Target Prediction Error Category"};
% TrialFilters = {"Value Difference Category"};
% TrialFilters = {"Multi Trials From Learning Point"};
% TrialFilters = {"Dimensionality","Multi Trials From Learning Point"};
% TrialFilters = {"Previous","Learned"};
% TrialFilters = {"Previous","Dimensionality"};
% TrialFilters = {"Prediction Error Category","Learned","Dimensionality"};
% TrialFilters = {"Prediction Error Category","Learned"};
% TrialFilters = {"Gain","Loss","Multi Trials From Learning Point"};
% TrialFilters = {"Prediction Error Category","Dimensionality"};
% TrialFilters = {"Trials From Learning Point Category","Dimensionality"};
% TrialFilters = {"Learned","Gain","Loss"};
% TrialFilters = {"Previous Trial Effect","Learned"};
% TrialFilters = {"Previous Trial Effect","Dimensionality"};
% TrialFilters = {"Previous Trial Effect"};
%%
StatusType = "Session";
DeleteFilters = {};
WantLC = false;

Target = 'Dimension';
Epoch = 'Decision';

%%
TotalFolds = 10;
MatchTypes = ["Scaled-BalancedAccuracy","Scaled-MicroAccuracy"];
MatchTypes_LabelClass = ["Scaled-MacroBalancedAccuracy","Scaled-MicroBalancedAccuracy"];
cfg_IA = PARAMETERS_cggImportanceAnalysis('TrialFilter',string(TrialFilters),'MatchType',MatchTypes(1));
MaxNumIter = cfg_IA.MaxNumIter;
%%
cfg_Session = DATA_cggAllSessionInformationConfiguration;
SessionNames = replace({cfg_Session.SessionName},'-','_');
% SessionNames = SessionNames(14);
%%
outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Session(1).temporarydir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Encoding',true,'Target',Target,'WantDirectory',false);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true,'Target',Target,'WantDirectory',false);
cfg.ResultsDir=cfg_Results.TargetDir;

cfg_Epoch = struct();
cfg_Epoch.Main = cgg_getDirectory(cfg.TargetDir,'Epoch');
cfg_Epoch.Results = cgg_getDirectory(cfg.ResultsDir,'Epoch');
cfg_Epoch.TargetDir = cfg.TargetDir;
cfg_Epoch.ResultsDir = cfg.ResultsDir;
%%
Identifiers_Table = cgg_getIdentifiersTable(cfg,false,'Epoch',Epoch);
%%

TrialFilter_Values_Cell = cell(1,length(TrialFilters));
for tidx = 1:length(TrialFilters)
    TrialFilter = TrialFilters{tidx};
switch TrialFilter
    case 'All'
        TrialFilter_Values = NaN;
    case 'Learned'
        TrialFilter_Values = [-1,0,1];
    case 'Dimensionality'
        TrialFilter_Values = [1,2,3];
    case 'Trials From Learning Point Category'
        TrialFilter_Values = [1,2,3,4,5,6];
    case 'Prediction Error Category'
        TrialFilter_Values = [0,1,2,3];
    case 'Multi Trials From Learning Point'
        TrialFilter_Values = 1:50;
    case 'Gain'
        TrialFilter_Values = [2,3];
    case 'Loss'
        TrialFilter_Values = [-1,-3];
    case 'Correct Trial'
        TrialFilter_Values = [0,1];
    case 'Previous Trial Effect'
        TrialFilter_Values = [0,1,2,3,4];
    case 'Previous'
        TrialFilter_Values = [0,1];
    case 'Value Difference Category'
        TrialFilter_Values = [0,1,2,3];
    case 'Target Value Category'
        TrialFilter_Values = [0,1,2,3];
    case 'Target Prediction Error Category'
        TrialFilter_Values = [0,1,2,3];
end

% TrialFilter_Values_Cell{tidx} = unique(Identifiers_Table.(TrialFilter));
TrialFilter_Values_Cell{tidx} = TrialFilter_Values;
end

TrialFilters = {"All",TrialFilters};
TrialFilter_Values_tmp = combinations(TrialFilter_Values_Cell{:});
TrialFilter_Values = {NaN,TrialFilter_Values_tmp{:,:}};

TargetFilters = ["Overall","TargetFeature","DistractorCorrect","DistractorError"];

%%
TableVariables = [["Session", "string"]; ...
    ["Overall", "double"]; ...
    ["Attention", "double"]; ...
    ["Split", "double"]; ...
    ["Split Attention", "double"]; ...
    ["LC - Overall", "double"]; ...
    ["LC - Attention", "double"]; ...
    ["LC - Split", "double"]; ...
    ["LC - Split Attention", "double"]];

NumVariables = size(TableVariables,1);
CompletionTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
ProgressTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

%%

parfor sidx = 1:length(SessionNames)
SessionName = SessionNames{sidx};
Overall_Completion = NaN;
Overall_Progress = NaN;
Attention_Completion = NaN;
Attention_Progress = NaN;
% Attention_Progress = NaN(1,length(TargetFilters)-1);
Split_Completion = NaN;
Split_Progress = NaN;
% Split_Progress = NaN(1,length(TrialFilter_Values));
Split_Attention_Completion = NaN;
Split_Attention_Progress = NaN;

Overall_Completion_LC = NaN;
Overall_Progress_LC = NaN;
Attention_Completion_LC = NaN;
Attention_Progress_LC = NaN;
Split_Completion_LC = NaN;
Split_Progress_LC = NaN;
Split_Attention_Completion_LC = NaN;
Split_Attention_Progress_LC = NaN;

if WantLC
this_Identifiers_Table = cgg_getIdentifiersTable(cfg,true,'Epoch',Epoch,'Subset',SessionName);

%% Generate ClassNames

if strcmp(Target, 'Dimension')
    TrueValueIDX=contains(this_Identifiers_Table.Properties.VariableNames,'Dimension ');
else
    TrueValueIDX=contains(this_Identifiers_Table.Properties.VariableNames,Target);
end
TrueValue=this_Identifiers_Table{:,TrueValueIDX};
this_Identifiers_Table.TrueValue = TrueValue;
[ClassNames,~,~,~] = cgg_getClassesFromCMTable(this_Identifiers_Table);

else
    ClassNames = {};
end

%%
for lidx = 1:length(ClassNames) + 1
this_Label = lidx;
    this_LabelFilter = sprintf("Label %d",this_Label);
    if this_Label == length(ClassNames) + 1
        this_Classes = [];
    else
        this_Classes = ClassNames{lidx};
    end
for cidx = 1:length(this_Classes) + 1
    if isempty(this_Classes)
        this_LabelClassFilter = '';
        this_MatchTypes = MatchTypes;
    else
    if cidx == length(this_Classes) + 1
        this_LabelClassFilter = this_LabelFilter;
    else
    this_Class = this_Classes(cidx);
    this_ClassFilter = sprintf("Class %d",this_Class);
    this_LabelClassFilter = sprintf("%s ~ %s",this_LabelFilter, ...
        this_ClassFilter);
    end
    this_MatchTypes = MatchTypes_LabelClass;
    end

for tidx = 1:length(TrialFilters)
    TrialFilter = TrialFilters{tidx};
    this_TrialFilter_Values = TrialFilter_Values{tidx};
for vidx = 1:length(this_TrialFilter_Values)
TrialFilter_Value = this_TrialFilter_Values(vidx,:);
for aidx = 1:length(TargetFilters)
    TargetFilter = TargetFilters(aidx);
    switch TargetFilter
        case 'Overall'
            MatchType = this_MatchTypes(1);
        otherwise
            MatchType = this_MatchTypes(2);
    end
    
    [NullTablePath,NullTableName] = cgg_generateNullTableFileName(Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'cfg',cfg_Epoch,'LabelClassFilter',this_LabelClassFilter);
    NullTableNameExt = NullTableName + ".mat";
    NullTablePathNameExt = fullfile(NullTablePath,NullTableNameExt);
    % fprintf("!!! This Trial Filter -- %s\n",string(TrialFilter));
    if ~isempty(DeleteFilters) && any(strcmp(string(TrialFilter),string(DeleteFilters)))
        
    if isfile(NullTablePathNameExt)
        fprintf("!!! Deleting -- %s\n",NullTableName);
        delete(NullTablePathNameExt);
    else
        fprintf("!!! File Does not Exist -- %s\n",NullTableName);
    end
    end

    cfg_IA = PARAMETERS_cggImportanceAnalysis('TrialFilter',string(TrialFilter),'MatchType',MatchType,'LabelClassFilter',this_LabelClassFilter);
MaxNumIter = cfg_IA.MaxNumIter;

NullTable = cgg_loadNullTable(cfg_Epoch,Target,SessionName,TrialFilter,TrialFilter_Value,TargetFilter,MatchType,'LabelClassFilter',this_LabelClassFilter);
if ~isempty(NullTable.DataNumber{1})
    NumFolds = height(NullTable);
    BaselineChanceDistribution = NullTable.BaselineChanceDistribution;
    ChanceDistribution = NullTable.ChanceDistribution;
    PerFoldStatus = cellfun(@(x,y) min([length(x),length(y)])/MaxNumIter,BaselineChanceDistribution,ChanceDistribution);
else
    NumFolds = 0;
    PerFoldStatus = 0;
end

PercentComplete = NumFolds/TotalFolds;
PercentFinished = sum(PerFoldStatus)/TotalFolds;

if isempty(this_LabelClassFilter)
if any(strcmp(TrialFilter,'All')) && strcmp(TargetFilter,'Overall')
    Overall_Completion = [Overall_Completion,PercentComplete];
    Overall_Progress = [Overall_Progress,PercentFinished];
    % Overall_Progress = mean([Overall_Progress,PercentFinished],"all","omitmissing");
elseif ~any(strcmp(TrialFilter,'All')) && strcmp(TargetFilter,'Overall')
    Split_Completion = [Split_Completion,PercentComplete];
    Split_Progress = [Split_Progress,PercentFinished];
    % Split_Progress = mean([Split_Progress,PercentFinished],"all","omitmissing");
elseif any(strcmp(TrialFilter,'All')) && ~strcmp(TargetFilter,'Overall')
    Attention_Completion = [Attention_Completion,PercentComplete];
    Attention_Progress = [Attention_Progress,PercentFinished];
    % Attention_Progress = mean([Attention_Progress,PercentFinished],"all","omitmissing");
elseif ~any(strcmp(TrialFilter,'All')) && ~strcmp(TargetFilter,'Overall')
    Split_Attention_Completion = [Split_Attention_Completion,PercentComplete];
    Split_Attention_Progress = [Split_Attention_Progress,PercentFinished];
    % Split_Attention_Progress = mean([Split_Attention_Progress,PercentFinished],"all","omitmissing");
end
else
if any(strcmp(TrialFilter,'All')) && strcmp(TargetFilter,'Overall')
    Overall_Completion_LC = [Overall_Completion_LC,PercentComplete];
    Overall_Progress_LC = [Overall_Progress_LC,PercentFinished];
elseif ~any(strcmp(TrialFilter,'All')) && strcmp(TargetFilter,'Overall')
    Split_Completion_LC = [Split_Completion_LC,PercentComplete];
    Split_Progress_LC = [Split_Progress_LC,PercentFinished];
elseif any(strcmp(TrialFilter,'All')) && ~strcmp(TargetFilter,'Overall')
    Attention_Completion_LC = [Attention_Completion_LC,PercentComplete];
    Attention_Progress_LC = [Attention_Progress_LC,PercentFinished];
elseif ~any(strcmp(TrialFilter,'All')) && ~strcmp(TargetFilter,'Overall')
    Split_Attention_Completion_LC = [Split_Attention_Completion_LC,PercentComplete];
    Split_Attention_Progress_LC = [Split_Attention_Progress_LC,PercentFinished];
end
end

end % for -  TargetFilters
end % for -  this_TrialFilterValues
end % for -  TrialFilters
end % for -  this_Classes
end % for -  this_Label

Overall_Completion = mean(Overall_Completion,"all","omitmissing");
Attention_Completion = mean(Attention_Completion,"all","omitmissing");
Split_Completion = mean(Split_Completion,"all","omitmissing");
Split_Attention_Completion = mean(Split_Attention_Completion,"all","omitmissing");

Overall_Progress = mean(Overall_Progress,"all","omitmissing");
Attention_Progress = mean(Attention_Progress,"all","omitmissing");
Split_Progress = mean(Split_Progress,"all","omitmissing");
Split_Attention_Progress = mean(Split_Attention_Progress,"all","omitmissing");

Overall_Completion_LC = mean(Overall_Completion_LC,"all","omitmissing");
Attention_Completion_LC = mean(Attention_Completion_LC,"all","omitmissing");
Split_Completion_LC = mean(Split_Completion_LC,"all","omitmissing");
Split_Attention_Completion_LC = mean(Split_Attention_Completion_LC,"all","omitmissing");

Overall_Progress_LC = mean(Overall_Progress_LC,"all","omitmissing");
Attention_Progress_LC = mean(Attention_Progress_LC,"all","omitmissing");
Split_Progress_LC = mean(Split_Progress_LC,"all","omitmissing");
Split_Attention_Progress_LC = mean(Split_Attention_Progress_LC,"all","omitmissing");

CompletionTable(sidx,:) = {SessionName,Overall_Completion,Attention_Completion,Split_Completion,Split_Attention_Completion,Overall_Completion_LC,Attention_Completion_LC,Split_Completion_LC,Split_Attention_Completion_LC};
ProgressTable(sidx,:) = {SessionName,Overall_Progress,Attention_Progress,Split_Progress,Split_Attention_Progress,Overall_Progress_LC,Attention_Progress_LC,Split_Progress_LC,Split_Attention_Progress_LC};
end % parfor - SessionNames