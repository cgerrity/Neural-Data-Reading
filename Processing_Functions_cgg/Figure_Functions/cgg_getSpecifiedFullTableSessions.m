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

%% One tailed significance

SignificanceValue = SignificanceValue*2;

%% Remove Non-Session Entries

FullTableNames = FullTable.Properties.RowNames;

RemoveIDX = ~contains(FullTableNames,'Probe');
OldResultsIDX = contains(FullTableNames,'Old Results');
SpecificSubsetIDX = contains(FullTableNames,'true') | ...
    contains(FullTableNames,'Subset') ;
RemoveIDX = RemoveIDX | OldResultsIDX | SpecificSubsetIDX;

SessionFullTable = FullTable;
SessionFullTable(RemoveIDX,:) = [];

NumSessions = height(SessionFullTable);
% IsSignificant = false(NumSessions,1);
% SessionNames = SessionFullTable.Properties.RowNames;
% 
% SessionNamesSimplified = cgg_setSessionNamesForParameterSweep(SessionNames);

%%
AttentionalFilters = SessionFullTable.("Attentional Table"){1}.Properties.RowNames;
NumFilters = length(AttentionalFilters);

SplitNames = SessionFullTable.("Split Table"){1}.Properties.RowNames;
NumSplits = length(SplitNames);

%%
TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Split Table", "cell"]; ...
    ["Attentional Table", "cell"]; ...
    ["Session Number", "cell"]];

NumVariables = size(TableVariables,1);
OutFullTable = table('Size',[1,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"]; ...
    ["Session Number", "cell"]];

NumVariables = size(TableVariables,1);
AttentionalTable = table('Size',[NumFilters,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',AttentionalFilters);

OutFullTable.("Attentional Table") = {AttentionalTable};

TableVariables = [["Accuracy", "cell"]; ...
    ["Window Accuracy", "cell"];...
    ["Attentional Table", "cell"]; ...
    ["Session Number", "cell"]];

NumVariables = size(TableVariables,1);
SplitTable = table('Size',[NumSplits,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2),...
        'RowNames',SplitNames);

for sidx = 1:NumSplits
    SplitTable{sidx,"Attentional Table"} = {AttentionalTable};
end

OutFullTable.("Split Table") = {SplitTable};

%%

for sidx = 1:NumSessions
    this_FullTable = SessionFullTable(sidx,:);
    this_Window_Accuracy = this_FullTable.('Window Accuracy'){1};
    this_Accuracy = this_FullTable.('Accuracy'){1};
    [~,NumWindows] = size(this_Window_Accuracy);

[Series_Mean,~,~,Series_CI] = ...
    cgg_getMeanSTDSeries(this_Window_Accuracy,...
    'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);

this_TestSignal = Series_Mean - Series_CI;
IsSignificant = any(this_TestSignal > ChanceLevel);

if IsSignificant
OutFullTable.('Window Accuracy') = {[OutFullTable.('Window Accuracy'){1};this_Window_Accuracy]};
OutFullTable.('Accuracy') = {[OutFullTable.('Accuracy'){1};this_Accuracy]};
OutFullTable.('Session Number') = {[OutFullTable.('Session Number'){1}; sidx]};
end

% Attentional Table
this_AttentionalTable = this_FullTable.('Attentional Table'){1};
this_AttentionalNames = this_AttentionalTable.Properties.RowNames;

for aidx = 1:length(this_AttentionalNames)
    this_AttentionalType = this_AttentionalNames{aidx};
    this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);
    this_Window_Accuracy = this_AttentionalRow.('Window Accuracy'){1};
    this_Accuracy = this_AttentionalRow.('Accuracy'){1};
    [~,NumWindows] = size(this_Window_Accuracy);

    [Series_Mean,~,~,Series_CI] = ...
        cgg_getMeanSTDSeries(this_Window_Accuracy,...
        'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    this_TestSignal = Series_Mean - Series_CI;
    IsSignificant = any(this_TestSignal > ChanceLevel);

    if IsSignificant
    OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Window Accuracy"}{1};this_Window_Accuracy]};
    OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Accuracy"}{1};this_Accuracy]};
    OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"} = {[OutFullTable.('Attentional Table'){1}{this_AttentionalType,"Session Number"}{1}; sidx]};
    end
end

% Split Table
this_SplitTable = this_FullTable.('Split Table'){1};
this_SplitNames = this_SplitTable.Properties.RowNames;

for spidx = 1:length(this_SplitNames)
    this_SplitType = this_SplitNames{spidx};
    this_SplitRow = this_SplitTable(this_SplitType,:);
    this_Window_Accuracy = this_SplitRow.('Window Accuracy'){1};
    this_Accuracy = this_SplitRow.('Accuracy'){1};
    [~,NumWindows] = size(this_Window_Accuracy);

    [Series_Mean,~,~,Series_CI] = ...
        cgg_getMeanSTDSeries(this_Window_Accuracy,...
        'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    this_TestSignal = Series_Mean - Series_CI;
    IsSignificant = any(this_TestSignal > ChanceLevel);

    if IsSignificant
    OutFullTable.('Split Table'){1}{this_SplitType,"Window Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Window Accuracy"}{1};this_Window_Accuracy]};
    OutFullTable.('Split Table'){1}{this_SplitType,"Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Accuracy"}{1};this_Accuracy]};
    OutFullTable.('Split Table'){1}{this_SplitType,"Session Number"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Session Number"}{1}; sidx]};
    end


    % Split-Attentional Table
this_AttentionalTable = this_SplitRow.('Attentional Table'){1};
this_AttentionalNames = this_AttentionalTable.Properties.RowNames;

for aidx = 1:length(this_AttentionalNames)
    this_AttentionalType = this_AttentionalNames{aidx};
    this_AttentionalRow = this_AttentionalTable(this_AttentionalType,:);
    this_Window_Accuracy = this_AttentionalRow.('Window Accuracy'){1};
    this_Accuracy = this_AttentionalRow.('Accuracy'){1};
    [~,NumWindows] = size(this_Window_Accuracy);

    [Series_Mean,~,~,Series_CI] = ...
        cgg_getMeanSTDSeries(this_Window_Accuracy,...
        'SignificanceValue',SignificanceValue,'NumSamples',NumWindows);
    this_TestSignal = Series_Mean - Series_CI;
    IsSignificant = any(this_TestSignal > ChanceLevel);

    if IsSignificant
    OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Window Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Window Accuracy"}{1};this_Window_Accuracy]};
    OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Accuracy"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Accuracy"}{1};this_Accuracy]};
    OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Session Number"} = {[OutFullTable.('Split Table'){1}{this_SplitType,"Attentional Table"}{1}{this_AttentionalType,"Session Number"}{1}; sidx]};
    end
end

end

end

%%

OutFullTable.Properties.RowNames = {'Combined'};

% IsNotSignificant = ~IsSignificant;
% 
% SpecifiedFullTable(IsNotSignificant,:) = [];


%%

% LearningSet = CombinedFullTable.('Split Table'){1}.('Attentional Table'){'Learning',:}.('Session Number'){'DistractorError',:};
% LearnedSet = CombinedFullTable.('Split Table'){1}.('Attentional Table'){'Learned',:}.('Session Number'){'DistractorError',:};
% Both = intersect(LearningSet,LearnedSet); OnlyLearned = setdiff(LearnedSet,Both); OnlyLearning = setdiff(LearningSet,Both);
% p = piechart([numel(Both),numel(OnlyLearned),numel(OnlyLearning)],["Both","Learned","Learning"]);
% p.LabelStyle = "namedata";
end

