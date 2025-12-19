function OutFullTable = cgg_getSpecifiedFullTableSessions(FullTable,varargin)
%CGG_GETSPECIFIEDFULLTABLESESSIONS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
ChanceLevel = CheckVararginPairs('ChanceLevel', 0, varargin{:});
else
if ~(exist('ChanceLevel','var'))
ChanceLevel=0;
end
end

if isfunction
WantAllFromGroup = CheckVararginPairs('WantAllFromGroup', false, varargin{:});
else
if ~(exist('WantAllFromGroup','var'))
WantAllFromGroup=false;
end
end

if isfunction
TimeRange = CheckVararginPairs('TimeRange', [], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[];
end
end

if isfunction
cfg_Encoder = CheckVararginPairs('cfg_Encoder', struct(), varargin{:});
else
if ~(exist('cfg_Encoder','var'))
cfg_Encoder=struct();
end
end

if isfunction
WantAllFromBest = CheckVararginPairs('WantAllFromBest', false, varargin{:});
else
if ~(exist('WantAllFromBest','var'))
WantAllFromBest=false;
end
end

if isfunction
WantBlockSingleArea = CheckVararginPairs('WantBlockSingleArea', false, varargin{:});
else
if ~(exist('WantBlockSingleArea','var'))
WantBlockSingleArea=false;
end
end

%% One tailed significance
if WantAllFromGroup
    AllGroupString = "Group ";
else
    AllGroupString = "";
end
if WantAllFromBest
    OverallBestString = "Overall-Significant ";
else
    OverallBestString = "";
end
if isempty(TimeRange)
    TimeRangeString = "";
else
    TimeRangeString = sprintf("Time [%.2f to %.2f] ",TimeRange);
end
% CombinedName = sprintf('Combined %s%s~ alpha %.3f ~ %s',AllGroupString,TimeRangeString,SignificanceValue,datetime('today'));
if SignificanceValue >= 0.001
CombinedName = sprintf('Combined %s%s%s~ alpha %.3f',AllGroupString,OverallBestString,TimeRangeString,SignificanceValue);
elseif SignificanceValue >= 0.0001
CombinedName = sprintf('Combined %s%s%s~ alpha %.4f',AllGroupString,OverallBestString,TimeRangeString,SignificanceValue);
end
SignificanceValue = SignificanceValue*2;

%% Remove Non-Session Entries

FullTableNames = FullTable.Properties.RowNames;

RemoveIDX = ~contains(FullTableNames,'Probe');
OldResultsIDX = contains(FullTableNames,'Old Results');
SpecificSubsetIDX = contains(FullTableNames,'true') | ...
    contains(FullTableNames,'Subset') ;
RemoveIDX = RemoveIDX | OldResultsIDX | SpecificSubsetIDX;

if any(contains(FullTableNames,'Filtered'))
CombinedName = sprintf('%s ~ %s',CombinedName,'Filtered');
end

SessionFullTable = FullTable;
SessionFullTable(RemoveIDX,:) = [];

NumSessions = height(SessionFullTable);
% IsSignificant = false(NumSessions,1);
% SessionNames = SessionFullTable.Properties.RowNames;
% 
% SessionNamesSimplified = cgg_setSessionNamesForParameterSweep(SessionNames);

%%
SignificanceOverwrite = false;
if WantAllFromBest
BestFunc = @(x) cgg_testAccuracyTableSignificance(x,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);

BestSessionIDX = NaN(NumSessions,1);
for sidx = 1:NumSessions
BestSessionIDX(sidx) = BestFunc(SessionFullTable(sidx,:));
end
% BestSessionTable = SessionFullTable;
% BestSessionTable(BestSessionIDX==1,:) = [];
SessionFullTable(BestSessionIDX~=1,:) = [];
NumSessions = height(SessionFullTable);
SignificanceValue = 2;
SignificanceOverwrite = true;
end

%%
AttentionalFilters = SessionFullTable.("Attentional Table"){1}.Properties.RowNames;
NumFilters = length(AttentionalFilters);

SplitNames = SessionFullTable.("Split Table"){1}.Properties.RowNames;
NumSplits = length(SplitNames);

HasBlock = any(ismember("Block", SessionFullTable.Properties.VariableNames));

if HasBlock
    RemovedAreas = unique(string(cellfun(@(x) join(x,"-"),...
        vertcat(SessionFullTable.('Block'){:}).("Area Names"),...
        "UniformOutput",false)));
    if WantBlockSingleArea
        ReIndexAreas = count(RemovedAreas,"-")==0;
    else
    RemovedAreas = ["None";RemovedAreas];
    [~,ReIndexAreas] = sort(count(RemovedAreas,"-"));
    end
    RemovedAreas = RemovedAreas(ReIndexAreas);
    NumAreas = length(RemovedAreas);
end

HasLabel = any(ismember("Label Table", SessionFullTable.Properties.VariableNames));
HasClass = any(ismember("Class Table", SessionFullTable.Properties.VariableNames));
NumLabels = [];
NumClasses = [];

if HasLabel
    LabelNames = cellfun(@(x) string(x.Properties.RowNames), FullTable.("Label Table"),"UniformOutput",false);
    LabelNames = unique(vertcat(LabelNames{:}));
    NumLabels = length(LabelNames);
end
if HasClass
    ClassNames = cellfun(@(x) string(x.Properties.RowNames), FullTable.("Class Table"),"UniformOutput",false);
    ClassNames = unique(vertcat(ClassNames{:}));
    NumClasses = length(ClassNames);
end

%%
if HasBlock
    BlockTableVariables = [["Removed Areas", "cell"];...
        ["Present Areas", "cell"];...
        ["Not Present Areas", "cell"]];
    TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Area Names", "cell"]; ...
    ["Session Number", "cell"]; ...
    ["Weight Table", "cell"]];
    NumVariables = size(TableVariables,1);
    BlockTable_Template = table('Size',[NumAreas,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
    BlockTable_Template.("Area Names") = RemovedAreas;
    % BlockTable_Template.("Area Names") = RemovedAreas;
    BlockTable_Template.Properties.RowNames = RemovedAreas;
else
    BlockTableVariables = [];
end

if HasLabel
    LabelTableVariables = ["Label Table", "cell"];
    TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Session Number", "cell"]];
    NumVariables = size(TableVariables,1);
    LabelTable_Template = table('Size',[NumLabels,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
    LabelTable_Template.Properties.RowNames = LabelNames;
else
    LabelTableVariables = [];
end

if HasClass
    ClassTableVariables = ["Class Table", "cell"];
    TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Session Number", "cell"]];
    NumVariables = size(TableVariables,1);
    ClassTable_Template = table('Size',[NumClasses,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
    ClassTable_Template.Properties.RowNames = ClassNames;
else
    ClassTableVariables = [];
end

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Split Table", "cell"]; ...
    ["Attentional Table", "cell"]; ...
    ["Session Number", "cell"]];
TableVariables = [TableVariables;BlockTableVariables];
TableVariables = [TableVariables;LabelTableVariables];
TableVariables = [TableVariables;ClassTableVariables];

NumVariables = size(TableVariables,1);
OutFullTable = table('Size',[1,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
if HasBlock
    OutFullTable{:,"Removed Areas"} = {BlockTable_Template};
    OutFullTable{:,"Not Present Areas"} = {BlockTable_Template};
    OutFullTable{:,"Present Areas"} = {BlockTable_Template};
end
if HasLabel
    OutFullTable{:,"Label Table"} = {LabelTable_Template};
end
if HasClass
    OutFullTable{:,"Class Table"} = {ClassTable_Template};
end

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    % ["Split Table", "cell"]; ...
    ["Session Number", "cell"]];
TableVariables = [TableVariables;BlockTableVariables];
TableVariables = [TableVariables;LabelTableVariables];
TableVariables = [TableVariables;ClassTableVariables];

NumVariables = size(TableVariables,1);
AttentionalTable_Template = table('Size',[NumFilters,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',AttentionalFilters);
if HasBlock
    AttentionalTable_Template{:,"Removed Areas"} = {BlockTable_Template};
    AttentionalTable_Template{:,"Not Present Areas"} = {BlockTable_Template};
    AttentionalTable_Template{:,"Present Areas"} = {BlockTable_Template};
end
if HasLabel
    AttentionalTable_Template{:,"Label Table"} = {LabelTable_Template};
end
if HasClass
    AttentionalTable_Template{:,"Class Table"} = {ClassTable_Template};
end

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"];...
    % ["Attentional Table", "cell"]; ...
    ["Session Number", "cell"]];
TableVariables = [TableVariables;BlockTableVariables];
TableVariables = [TableVariables;LabelTableVariables];
TableVariables = [TableVariables;ClassTableVariables];

NumVariables = size(TableVariables,1);
SplitTable_Template = table('Size',[NumSplits,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',SplitNames);
if HasBlock
    SplitTable_Template{:,"Removed Areas"} = {BlockTable_Template};
    SplitTable_Template{:,"Not Present Areas"} = {BlockTable_Template};
    SplitTable_Template{:,"Present Areas"} = {BlockTable_Template};
end
if HasLabel
    SplitTable_Template{:,"Label Table"} = {LabelTable_Template};
end
if HasClass
    SplitTable_Template{:,"Class Table"} = {ClassTable_Template};
end

AttentionalTable = AttentionalTable_Template;
SplitTable = SplitTable_Template;

AttentionalTable{:,"Split Table"} = {SplitTable_Template};
SplitTable{:,"Attentional Table"} = {AttentionalTable_Template};

% for aidx = 1:NumFilters
%     AttentionalTable{aidx,"Split Table"} = {SplitTable_Template};
% end
% 
% for spidx = 1:NumSplits
%     SplitTable{spidx,"Attentional Table"} = {AttentionalTable_Template};
% end

OutFullTable.("Attentional Table") = {AttentionalTable};
OutFullTable.("Split Table") = {SplitTable};

%%

for sidx = 1:NumSessions
    this_FullTable = SessionFullTable(sidx,:);
%     this_Window_Accuracy = this_FullTable.('Window Accuracy'){1};
%     this_Accuracy = this_FullTable.('Accuracy'){1};
%     [~,NumWindows] = size(this_Window_Accuracy);
% 
% [Series_Mean,~,~,Series_CI] = ...
%     cgg_getMeanSTDSeries(this_Window_Accuracy,...
%     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
% 
% this_TestSignal = Series_Mean - Series_CI;
% IsSignificant = any(this_TestSignal > ChanceLevel);

IsSignificant = cgg_testAccuracyTableSignificance(this_FullTable,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);
IsSignificant = IsSignificant || SignificanceOverwrite;
OutFullTable = cgg_addSignificantAccuracyTableValues(OutFullTable,this_FullTable,sidx,IsSignificant);
% if IsSignificant
% OutFullTable.('Window Accuracy') = {[OutFullTable.('Window Accuracy'){1};this_Window_Accuracy]};
% OutFullTable.('Accuracy') = {[OutFullTable.('Accuracy'){1};this_Accuracy]};
% OutFullTable.('Session Number') = {[OutFullTable.('Session Number'){1}; sidx]};
% end
% %% Get Overall Tables
% this_OverallAttentionalTable = this_FullTable.('Attentional Table'){1};
% this_OverallAttentionalNames = this_OverallAttentionalTable.Properties.RowNames;
% 
% this_OverallSplitTable = this_FullTable.('Split Table'){1};
% this_OverallSplitNames = this_OverallSplitTable.Properties.RowNames;

%% Attentional Table
this_AttentionalTable = this_FullTable.('Attentional Table'){1};
this_AttentionalNames = this_AttentionalTable.Properties.RowNames;

% Significance_OverallAttentional = false(length(this_AttentionalNames),1);
Significance_OverallAttentional = false(length(this_AttentionalNames),1);
% Significance_Attentional_Split = false(length(this_AttentionalNames),1);
Significance_Attentional_Split = cell(length(this_AttentionalNames),1);

for aidx = 1:length(this_AttentionalNames)
    this_AttentionalType = this_AttentionalNames{aidx};
    this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);
    % this_Window_Accuracy = this_AttentionalRow.('Window Accuracy'){1};
    % % this_Accuracy = this_AttentionalRow.('Accuracy'){1};
    % [~,NumWindows] = size(this_Window_Accuracy);
    % 
    % [Series_Mean,~,~,Series_CI] = ...
    %     cgg_getMeanSTDSeries(this_Window_Accuracy,...
    %     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    % this_TestSignal = Series_Mean - Series_CI;
    % IsSignificant = any(this_TestSignal > ChanceLevel);
    IsSignificant = cgg_testAccuracyTableSignificance(this_AttentionalRow,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);
    IsSignificant = IsSignificant || SignificanceOverwrite;
    Significance_OverallAttentional(aidx) = IsSignificant;

    % if IsSignificant
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"}{1};this_Window_Accuracy]};
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"}{1};this_Accuracy]};
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"}{1}; sidx]};
    % end

    % Attentional-Split Table
    this_SplitTable = this_AttentionalRow.('Split Table'){1};
    this_SplitNames = this_SplitTable.Properties.RowNames;
    Significance_Attentional_Split{aidx} = false(length(this_SplitNames),1);

    for spidx = 1:length(this_SplitNames)
        this_SplitType = this_SplitNames{spidx};
        this_SplitRow = this_SplitTable(this_SplitType,:);
        % this_Window_Accuracy = this_SplitRow.('Window Accuracy'){1};
        % % this_Accuracy = this_SplitRow.('Accuracy'){1};
        % [~,NumWindows] = size(this_Window_Accuracy);
        % 
        % [Series_Mean,~,~,Series_CI] = ...
        %     cgg_getMeanSTDSeries(this_Window_Accuracy,...
        %     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
        % this_TestSignal = Series_Mean - Series_CI;
        % IsSignificant = any(this_TestSignal > ChanceLevel);
        IsSignificant = cgg_testAccuracyTableSignificance(this_SplitRow,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);
        IsSignificant = IsSignificant || SignificanceOverwrite;
        Significance_Attentional_Split{aidx}(spidx) = IsSignificant;
    
        % if IsSignificant
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Window Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Window Accuracy"}{1};this_Window_Accuracy]};
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Accuracy"}{1};this_Accuracy]};
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Session Number"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Session Number"}{1}; sidx]};
        % end
    end
end

%% Aggregate Significant Attentional Results

if WantAllFromGroup
    Significance_OverallAttentional = repmat(any(Significance_OverallAttentional),size(Significance_OverallAttentional));
    Significance_Attentional_Split = cellfun(@(x) repmat(any(x),size(x)),Significance_Attentional_Split,"UniformOutput",false);
% else
%     IsSignificant = Significance_OverallAttentional;
end
for aidx = 1:length(this_AttentionalNames)
    this_AttentionalType = this_AttentionalNames{aidx};
    this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);

    AttentionalTable(this_AttentionalType,:) = cgg_addSignificantAccuracyTableValues( ...
        AttentionalTable(this_AttentionalType,:),this_AttentionalRow,sidx, ...
        Significance_OverallAttentional(aidx));

    % this_Window_Accuracy = this_AttentionalRow.('Window Accuracy'){1};
    % this_Accuracy = this_AttentionalRow.('Accuracy'){1};
    % 
    % if Significance_OverallAttentional(aidx)
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"}{1};this_Window_Accuracy]};
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"}{1};this_Accuracy]};
    % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"}{1}; sidx]};
    % end

    % Attentional-Split Table
    Attentional_SplitTable = AttentionalTable{this_AttentionalType,"Split Table"}{1};
    this_SplitTable = this_AttentionalRow.('Split Table'){1};
    this_SplitNames = this_SplitTable.Properties.RowNames;
    % Significance_Attentional_Split{aidx} = false(length(this_SplitNames),1);

    for spidx = 1:length(this_SplitNames)
        this_SplitType = this_SplitNames{spidx};
        this_SplitRow = this_SplitTable(this_SplitType,:);

        Attentional_SplitTable(this_SplitType,:) = ...
            cgg_addSignificantAccuracyTableValues( ...
            Attentional_SplitTable(this_SplitType,:), ...
            this_SplitRow,sidx, ...
            Significance_Attentional_Split{aidx}(spidx));

        % this_Window_Accuracy = this_SplitRow.('Window Accuracy'){1};
        % this_Accuracy = this_SplitRow.('Accuracy'){1};
        % 
        % if Significance_Attentional_Split{aidx}(spidx)
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Window Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Window Accuracy"}{1};this_Window_Accuracy]};
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Accuracy"}{1};this_Accuracy]};
        % OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Session Number"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Split Table"}{1}{this_SplitType,"Session Number"}{1}; sidx]};
        % end
    end

    AttentionalTable(this_AttentionalType,"Split Table") = {Attentional_SplitTable};
end

%% Split Table

this_SplitTable = this_FullTable.('Split Table'){1};
this_SplitNames = this_SplitTable.Properties.RowNames;

% SplitSignificance = false(length(this_SplitNames),1);
Significance_OverallSplit = false(length(this_SplitNames),1);
Significance_Split_Attentional = cell(length(this_SplitNames),1);

for spidx = 1:length(this_SplitNames)
    this_SplitType = this_SplitNames{spidx};
    this_SplitRow = this_SplitTable(this_SplitType,:);
    % this_Window_Accuracy = this_SplitRow.('Window Accuracy'){1};
    % this_Accuracy = this_SplitRow.('Accuracy'){1};
    % [~,NumWindows] = size(this_Window_Accuracy);
    % 
    % [Series_Mean,~,~,Series_CI] = ...
    %     cgg_getMeanSTDSeries(this_Window_Accuracy,...
    %     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    % this_TestSignal = Series_Mean - Series_CI;
    % IsSignificant = any(this_TestSignal > ChanceLevel);
    IsSignificant = cgg_testAccuracyTableSignificance(this_SplitRow,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);
    IsSignificant = IsSignificant || SignificanceOverwrite;
    Significance_OverallSplit(spidx) = IsSignificant;

    % if IsSignificant
    % OutFullTable.('Split Table'){1}{this_SplitType,"Window Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Window Accuracy"}{1};this_Window_Accuracy]};
    % OutFullTable.('Split Table'){1}{this_SplitType,"Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Accuracy"}{1};this_Accuracy]};
    % OutFullTable.('Split Table'){1}{this_SplitType,"Session Number"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Session Number"}{1}; sidx]};
    % end

    % Split-Attentional Table
this_AttentionalTable = this_SplitRow.('Attentional Table'){1};
this_AttentionalNames = this_AttentionalTable.Properties.RowNames;
Significance_Split_Attentional{spidx} = false(length(this_SplitNames),1);

for aidx = 1:length(this_AttentionalNames)
    this_AttentionalType = this_AttentionalNames{aidx};
    this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);
    % this_Window_Accuracy = this_AttentionalRow.('Window Accuracy'){1};
    % this_Accuracy = this_AttentionalRow.('Accuracy'){1};
    % [~,NumWindows] = size(this_Window_Accuracy);
    % 
    % [Series_Mean,~,~,Series_CI] = ...
    %     cgg_getMeanSTDSeries(this_Window_Accuracy,...
    %     'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    % this_TestSignal = Series_Mean - Series_CI;
    % IsSignificant = any(this_TestSignal > ChanceLevel);
    IsSignificant = cgg_testAccuracyTableSignificance(this_AttentionalRow,'SignificanceValue',SignificanceValue,'ChanceLevel',ChanceLevel,'TimeRange',TimeRange,'cfg_Encoder',cfg_Encoder);
    IsSignificant = IsSignificant || SignificanceOverwrite;
    Significance_Split_Attentional{spidx}(aidx) = IsSignificant;

    % if IsSignificant
    % OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Window Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Window Accuracy"}{1};this_Window_Accuracy]};
    % OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Accuracy"}{1};this_Accuracy]};
    % OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Session Number"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Session Number"}{1}; sidx]};
    % end
end

end

%% Aggregate Significant Split Results

if WantAllFromGroup
    Significance_OverallSplit = repmat(any(Significance_OverallSplit),size(Significance_OverallSplit));
    Significance_Split_Attentional = cellfun(@(x) repmat(any(x),size(x)),Significance_Split_Attentional,"UniformOutput",false);
end
for spidx = 1:length(this_SplitNames)
    this_SplitType = this_SplitNames{spidx};
    this_SplitRow = this_SplitTable(this_SplitType,:);

    SplitTable(this_SplitType,:) = cgg_addSignificantAccuracyTableValues( ...
        SplitTable(this_SplitType,:),this_SplitRow,sidx, ...
        Significance_OverallSplit(spidx));

    % Split-Attentional Table
    Split_AttentionalTable = SplitTable{this_SplitType,"Attentional Table"}{1};
    this_AttentionalTable = this_SplitRow.('Attentional Table'){1};
    this_AttentionalNames = this_AttentionalTable.Properties.RowNames;

    for aidx = 1:length(this_AttentionalNames)
        this_AttentionalType = this_AttentionalNames{aidx};
        this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);

        Split_AttentionalTable(this_AttentionalType,:) = ...
            cgg_addSignificantAccuracyTableValues( ...
            Split_AttentionalTable(this_AttentionalType,:), ...
            this_AttentionalRow,sidx, ...
            Significance_Split_Attentional{spidx}(aidx));
    end

    SplitTable(this_SplitType,"Attentional Table") = {Split_AttentionalTable};
end


end

%%

OutFullTable.Properties.RowNames = {CombinedName};

% IsNotSignificant = ~IsSignificant;
% 
% SpecifiedFullTable(IsNotSignificant,:) = [];

%%

OutFullTable.("Attentional Table") = {AttentionalTable};
OutFullTable.("Split Table") = {SplitTable};

%%

% LearningSet = CombinedFullTable.('Split Table'){1}.('Attentional Table'){'Learning',:}.('Session Number'){'DistractorError',:};
% LearnedSet = CombinedFullTable.('Split Table'){1}.('Attentional Table'){'Learned',:}.('Session Number'){'DistractorError',:};
% Both = intersect(LearningSet,LearnedSet); OnlyLearned = setdiff(LearnedSet,Both); OnlyLearning = setdiff(LearningSet,Both);
% p = piechart([numel(Both),numel(OnlyLearned),numel(OnlyLearning)],["Both","Learned","Learning"]);
% p.LabelStyle = "namedata";
end

