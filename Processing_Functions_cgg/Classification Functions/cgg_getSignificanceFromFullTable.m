function [WindowSignificance,PeakSignificance,SignificanceTable] = cgg_getSignificanceFromFullTable(FullTable,cfg,varargin)
%CGG_GETSIGNIFICANCEFROMFULLTABLE Summary of this function goes here
%   Detailed explanation goes here
% arguments (Input)
%     FullTable
%     cfg
%     % DefaultParameters.IsSplit false
% end
% 
% arguments (Output)
%     OverwriteSignificance
% end

%%

isfunction=exist('varargin','var');

if isfunction
IsSplit = CheckVararginPairs('IsSplit', false, varargin{:});
else
if ~(exist('IsSplit','var'))
IsSplit=false;
end
end

if isfunction
IsAttentional = CheckVararginPairs('IsAttentional', false, varargin{:});
else
if ~(exist('IsAttentional','var'))
IsAttentional=false;
end
end

% if isfunction
% IsBlock = CheckVararginPairs('IsBlock', false, varargin{:});
% else
% if ~(exist('IsBlock','var'))
% IsBlock=false;
% end
% end
% 
% if isfunction
% IsLabelClass = CheckVararginPairs('IsLabelClass', false, varargin{:});
% else
% if ~(exist('IsLabelClass','var'))
% IsLabelClass=false;
% end
% end
% 
% if isfunction
% cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
% else
% if ~(exist('cfg_OverwritePlot','var'))
% cfg_OverwritePlot=struct();
% end
% end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
NumIterations = CheckVararginPairs('NumIterations', 10000, varargin{:});
else
if ~(exist('NumIterations','var'))
NumIterations=10000;
end
end

if isfunction
MetricType = CheckVararginPairs('MetricType', 'Peak', varargin{:});
else
if ~(exist('MetricType','var'))
MetricType='Peak';
end
end

%%

TableVariables = [["P Value", "double"]; ...
    ["Group Name 1", "string"]; ...
    ["Bar Name 1", "string"]; ...
    ["Group Name 2", "string"]; ...
    ["Bar Name 2", "string"]];

NumVariables = size(TableVariables,1);
SignificanceTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));
%%
NumPlots = height(FullTable);

WindowSignificance = cell(1,NumPlots);
PeakSignificance = cell(1,NumPlots);

for pidx = 1:NumPlots

this_FullTable = FullTable(pidx,:);

FilterColumn = cfg.FilterColumn;
cfg_Encoder = cgg_mergeStructs(cfg, cfg.cfg_Encoder);
% cfg_Encoder = cfg.cfg_Encoder;
cfg_Epoch = cfg.cfg;
Subset=FullTable.("Session Name"){1};
TrialFilter="All";
TrialFilter_Value=NaN;
MatchType=cfg.MatchType;
TargetFilter='Overall';
LabelClassFilter='';

if IsSplit
this_ExtraTerm = cfg.ExtraSaveTerm;
this_ExtraTerm = erase(this_ExtraTerm,...
    {'Distractor (','Distractor-(','Distractor_('});
SplitType = extractBetween(this_ExtraTerm,'(',')');
if isempty(SplitType)
SplitType = FullTable(pidx,:).Properties.RowNames;
end
TypeValues = cgg_getSplitTableRowValues(SplitType, FilterColumn);
[TrialFilter,TrialFilter_Value] = ...
            cgg_getPackedTrialFilter(FilterColumn,TypeValues,'Pack');
end

if IsAttentional
MatchType=cfg.MatchType_Attention;
TargetFilter = extractBetween(cfg.ExtraSaveTerm,'{','}');
if isempty(TargetFilter)
TargetFilter = FullTable(pidx,:).Properties.RowNames;
end
TargetFilter = erase(TargetFilter, {'-',' ','(',')'});
% TargetFilter = 'Overall';
end

    [~,WindowSignificance{pidx},PeakSignificance{pidx},P_Value] = cgg_testAccuracyTableSignificance(this_FullTable,'SignificanceValue',SignificanceValue,'cfg_Encoder',cfg_Encoder,'cfg_Epoch',cfg_Epoch,'Subset',Subset,'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,'MatchType',MatchType,'TargetFilter',TargetFilter,'LabelClassFilter',LabelClassFilter,'MetricType',MetricType);

% Assign the values to the significance table

    SignificanceTable(pidx,:) = {P_Value{2},"",this_FullTable.Properties.RowNames,"",""};
    % SignificanceTable{pidx,"P Value"} = P_Value{2};
    % SignificanceTable{pidx,"Group Name 2"} = "";
    % SignificanceTable{pidx,"Bar Name 1"} = this_FullTable.Properties.RowNames;
    % SignificanceTable{pidx,"Group Name 2"} = "";
    % SignificanceTable{pidx,"Bar Name 2"} = "";

end

%%

PermutationTestingInputs = cell(0);
InputCounter = 1;
PermutationTestingInputs{InputCounter} = 'NumIterations';
PermutationTestingInputs{InputCounter + 1} = NumIterations;
% InputCounter = 1;
% PermutationTestingInputs{InputCounter} = 'Alpha';
% PermutationTestingInputs{InputCounter + 1} = 0.05;
InputCounter = 1;
PermutationTestingInputs{InputCounter} = 'TargetVariable';
PermutationTestingInputs{InputCounter + 1} = 'Accuracy';
InputCounter = 1;
PermutationTestingInputs{InputCounter} = 'Tail';
PermutationTestingInputs{InputCounter + 1} = 'both';
InputCounter = 1;
PermutationTestingInputs{InputCounter} = 'SignificanceTable';
PermutationTestingInputs{InputCounter + 1} = SignificanceTable;

SignificanceTable = cgg_procPermutationTesting(FullTable, PermutationTestingInputs{:});
%%

% AllComparisons = nchoosek(1:height(FullTable),2);
% % NumIterations = 1000;
% for fidx = 1:size(AllComparisons,1)
% 
% this_Comparison = AllComparisons(fidx,:);
% 
% Row_1 = FullTable(this_Comparison(1),:);
% Row_2 = FullTable(this_Comparison(2),:);
% 
% Name_1 = Row_1.Properties.RowNames{1};
% Name_2 = Row_2.Properties.RowNames{1};
% 
% PeakAccuracy_1 = Row_1.Accuracy{1};
% PeakAccuracy_2 = Row_2.Accuracy{1};
% 
% SessionNumber_1 = Row_1.("Session Number"){1};
% SessionNumber_2 = Row_2.("Session Number"){1};
% 
% IsPaired = (length(PeakAccuracy_1) == length(PeakAccuracy_2)) && ...
%     all(SessionNumber_1 == SessionNumber_2);
% 
% if IsPaired
%     PeakAccuracyDifference = PeakAccuracy_1 - PeakAccuracy_2;
% end
% 
% MeanPeakAccuracyDifference = mean(PeakAccuracyDifference);
% 
% CompositeNullDistribution = NaN(NumIterations,1);
% parfor nidx = 1:NumIterations
% 
%     if ~IsPaired
%         PermutationIndices_1 = randi(length(PeakAccuracy_1),1,length(PeakAccuracy_1));
%         PermutationIndices_2 = randi(length(PeakAccuracy_2),1,length(PeakAccuracy_2));
% 
%         this_PeakAccuracy_1 = PeakAccuracy_1(PermutationIndices_1);
%         this_PeakAccuracy_2 = PeakAccuracy_2(PermutationIndices_2);
% 
%         CompositeNullDistribution(nidx) = mean(this_PeakAccuracy_1) - mean(this_PeakAccuracy_2);
%     else
%         PermutationSigns = sign(randn(length(PeakAccuracy_1),1));
%         this_PeakAccuracyDifference = PeakAccuracyDifference.*PermutationSigns;
%         CompositeNullDistribution(nidx) = mean(this_PeakAccuracyDifference);
%     end
% end
% 
% P_Value = (sum(abs(CompositeNullDistribution) > abs(MeanPeakAccuracyDifference))) / length(CompositeNullDistribution);
% 
% if P_Value < 0.05
% SignificanceTable(height(SignificanceTable)+1,:) = {P_Value,"",Name_1,"",Name_2};
% end
% end
end