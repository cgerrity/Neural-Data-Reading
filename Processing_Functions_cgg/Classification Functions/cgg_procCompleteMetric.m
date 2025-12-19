function [Metric,Window_Metric] = cgg_procCompleteMetric(CM_Table,cfg,varargin)
%CGG_PROCCOMPLETEMETRIC Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=NaN;
end
end

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
end
end

if isfunction
MatchType_Attention = CheckVararginPairs('MatchType_Attention', 'Scaled-MicroAccuracy', varargin{:});
else
if ~(exist('MatchType_Attention','var'))
MatchType_Attention='Scaled-MicroAccuracy';
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
AttentionalFilter = CheckVararginPairs('AttentionalFilter', '', varargin{:});
else
if ~(exist('AttentionalFilter','var'))
AttentionalFilter='';
end
end

if isfunction
RandomChance = CheckVararginPairs('RandomChance', [], varargin{:});
else
if ~(exist('RandomChance','var'))
RandomChance=[];
end
end

if isfunction
MostCommon = CheckVararginPairs('MostCommon', [], varargin{:});
else
if ~(exist('MostCommon','var'))
MostCommon=[];
end
end

if isfunction
Stratified = CheckVararginPairs('Stratified', [], varargin{:});
else
if ~(exist('Stratified','var'))
Stratified=[];
end
end

if isfunction
Identifiers_Table = CheckVararginPairs('Identifiers_Table', [], varargin{:});
else
if ~(exist('Identifiers_Table','var'))
Identifiers_Table=[];
end
end

if isfunction
AdditionalTarget = CheckVararginPairs('AdditionalTarget', {}, varargin{:});
else
if ~(exist('AdditionalTarget','var'))
AdditionalTarget={};
end
end

if isfunction
Subset = CheckVararginPairs('Subset', '', varargin{:});
else
if ~(exist('Subset','var'))
Subset='';
end
end

if isfunction
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
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
WantSpecificChance = CheckVararginPairs('WantSpecificChance', true, varargin{:});
else
if ~(exist('WantSpecificChance','var'))
WantSpecificChance=true;
end
end

if isfunction
WantFilteredChance = CheckVararginPairs('WantFilteredChance', true, varargin{:});
else
if ~(exist('WantFilteredChance','var'))
WantFilteredChance=true;
end
end

if isfunction
WantDisplay = CheckVararginPairs('WantDisplay', false, varargin{:});
else
if ~(exist('WantDisplay','var'))
WantDisplay=false;
end
end

if isfunction
WantOutputChance = CheckVararginPairs('WantOutputChance', false, varargin{:});
else
if ~(exist('WantOutputChance','var'))
WantOutputChance=false;
end
end

if isfunction
Target = CheckVararginPairs('Target', 'Dimension', varargin{:});
else
if ~(exist('Target','var'))
Target='Dimension';
end
end

if isfunction
WantUseNullTable = CheckVararginPairs('WantUseNullTable', false, varargin{:});
else
if ~(exist('WantUseNullTable','var'))
WantUseNullTable=false;
end
end

if isfunction
NullTable = CheckVararginPairs('NullTable', [], varargin{:});
else
if ~(exist('NullTable','var'))
NullTable=[];
end
end

if isfunction
LabelClassFilter = CheckVararginPairs('LabelClassFilter', '', varargin{:});
else
if ~(exist('LabelClassFilter','var'))
LabelClassFilter='';
end
end
%% Get CFG for any analysis
% You can uncomment this section to generate the base cfg for further
% testing
% [~,TargetDir,ResultsDir,~] = ...
%     cgg_getBaseFoldersFromSessionInformation('','','');
% 
% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch);
% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch);
% cfg.ResultsDir=cfg_Results.TargetDir;

%% Ensure TrialFilter and TrialFilter_Value are unpacked
% Only an issue with multi-trialfilter runs. Should not alter values if
% already unpacked.
[TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,'Unpack');

%% Ensure Subset and wantSubset Agree
[Subset,wantSubset] = cgg_verifySubset(Subset,wantSubset);

%% Ensure Target is used in cfg_Encoder

if ~isempty(Target)
cfg_Encoder.Target = Target;
end

%% Rename Attentional Filter
if strcmp(AttentionalFilter,"Overall")
AttentionalFilter = [];
end
%% Get Timeline for Time Range specification

if ~isempty(TimeRange)
    if isfield(cfg_Encoder,'Time_Start') && ...
        isfield(cfg_Encoder,'SamplingRate') && ...
        isfield(cfg_Encoder,'DataWidth') && ...
        isfield(cfg_Encoder,'WindowStride') && ...
        isfield(cfg_Encoder,'Time_End')
Time = cgg_getTime(cfg_Encoder.Time_Start,cfg_Encoder.SamplingRate,...
    cfg_Encoder.DataWidth,cfg_Encoder.WindowStride,NaN,0,...
    'Time_End',cfg_Encoder.Time_End);
    end
end
%% Get MatchType for given analysis

if ~isempty(char(AttentionalFilter))
    MatchType = MatchType_Attention;
end

IsScaled = contains(MatchType,'Scaled');
if IsScaled
        MatchType_Calc = extractAfter(MatchType,'Scaled-');
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled_');
        end
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled');
        end
end

%% Get Identifiers Table

if isempty(Identifiers_Table)
Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,'Epoch',Epoch,'AdditionalTarget',AdditionalTarget,'Subset',Subset);
fprintf('@@@ Loaded Identifiers Table for %s\n',Subset);
% if isempty(NullTable)
%     disp('Within Iterations');
% head(Identifiers_Table)
% disp(size(Identifiers_Table));
% end
end

%% Generate ClassNames

if isfield(cfg_Encoder,'Target')
    Target = cfg_Encoder.Target;
    if strcmp(Target, 'Dimension')
        TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
    else
        TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,Target);
    end
    TrueValue=Identifiers_Table{:,TrueValueIDX};
    Identifiers_Table.TrueValue = TrueValue;
    [ClassNames,~,ClassPercent,~] = cgg_getClassesFromCMTable(Identifiers_Table);
end

%% Generate Attention Weights

Identifiers_Table = cgg_getAttentionWeights(Identifiers_Table);
% if ~isempty(AttentionalFilter)
% Weights = Identifiers_Table.(AttentionalFilter);
% end

%% Generate Label-Class Weights

Identifiers_Table = cgg_getTargetFilters(Identifiers_Table,LabelClassFilter);

%% Join CM_Table and Identifiers_Table

CM_Table=join(CM_Table,Identifiers_Table);
% if ~isempty(AttentionalFilter)
% Weights = CM_Table.(AttentionalFilter);
% end

%% Filter Trials

% Determine the attentional filter weights
if ~isempty(char(AttentionalFilter))
    % Weights_Chance = Chance_Table.(AttentionalFilter);
    Weights_Chance = Identifiers_Table.(AttentionalFilter);
else
    Weights_Chance = ones(size(Identifiers_Table.TrueValue));
end

% Determine the Label-Class filter Weights
if ~isempty(char(LabelClassFilter))
    Weights_LabelClass = double(Identifiers_Table.(LabelClassFilter));
    Weights_Chance = Weights_Chance.*Weights_LabelClass;
end

% Select whether to calculate chance based on the full dataset or strictly
% the set being analyzed
if WantSpecificChance
    % Chance_Table = Identifiers_Table;
    SpecificTrials = ismember(Identifiers_Table.DataNumber,CM_Table.DataNumber);
    Weights_Chance(~SpecificTrials,:) = 0;
% else
%     Chance_Table = Identifiers_Table;
end

% % Determine the attentional filter weights
% if ~isempty(AttentionalFilter)
%     Weights_Chance = Chance_Table.(AttentionalFilter);
% else
%     Weights_Chance = Weights;
% end

% If WantFilteredChance is true then the chance levels are calculated using
% all the examples but weights the filtered out components as zero instead
% of not considering them. The TrueValues will represent the full set,
% which will affect the calculations of MostCommon and Stratified chance.
% ex. TrialFilter = 'Dimensionality'; TrialFilter_Value = 1;
% WantFilteredChance = false; All trials are included when calculating
% MostCommon and Stratified. 
% WantFilteredChance = true; 1-D trials are examined for calculating
% MostCommon and Stratified, but the possible values to consider are the
% whole dataset. This setting reflects best how the model is trained and
% the set to be analyzed. The TrueValues come from the whole dataset
% similar to training, but only the filtered values are considered for what
% values to examine.
% An alternate method was tested where the TrueValues and data to be
% examined come from the filtered dataset. This does not reflect the actual
% training since this would eliminate the possibility of certain classes.
% e.g. 3-D would have TrueValues that do not have any neutral features, but
% the model is able to assign neutral to these features regardless, making
% any comparison to the model unfair.

if all(~strcmp(TrialFilter,'All')) && WantFilteredChance

    FilterFunc.Default = @(x,y) all((x{:,:}==y),2);
    FilterFunc.Double = @(x,y) ismember(x,y);
    FilterFunc.Cell = @(x,y) cellfun(@(x) any(ismember(x,y)),x,'UniformOutput',true);
    FilterFunc.CellCombine = @(x,y) all(cell2mat(x),2);
    FilterRowIDX = cgg_procFilterIdentifiersTable(Identifiers_Table,TrialFilter,TrialFilter_Value,FilterFunc);

    % DistributionVariable_Table=Identifiers_Table(:,TrialFilter);
    % 
    % if any(strcmp(DistributionVariable_Table.Properties.VariableTypes,"cell"))
    % 
    %     FilterRowIDX = false(size(DistributionVariable_Table));
    %     for tidx = 1:size(DistributionVariable_Table,2)
    %         this_Var = DistributionVariable_Table{:,tidx};
    %     if strcmp(DistributionVariable_Table.Properties.VariableTypes{tidx},"cell")
    %         FilterRowIDX(:,tidx) = cellfun(@(x) any(ismember(x,TrialFilter_Value(tidx))),this_Var,'UniformOutput',true);
    %     else
    %         FilterRowIDX(:,tidx) = this_Var == TrialFilter_Value(tidx);
    %     end
    %     end
    %     FilterRowIDX = all(FilterRowIDX,2);
    % else
    % % FilterRowIDX=all((Chance_Table{:,TrialFilter}==TrialFilter_Value),2);
    % FilterRowIDX=all((Identifiers_Table{:,TrialFilter}==TrialFilter_Value),2);
    % % Chance_Table(~FilterRowIDX,:)=[];
    % end

    if isempty(Weights_Chance)
    % Weights_Chance = ones(size(Chance_Table.TrueValue));
    Weights_Chance = ones(size(Identifiers_Table.TrueValue));
    end
    Weights_Chance(~FilterRowIDX,:)=0;
end

%% Compare data numbers to ensure the proper trials have been selected
if WantUseNullTable
    cfg_Encoder.Subset = Subset;
    cfg_Encoder.wantSubset = wantSubset;
    TargetFilter = AttentionalFilter;
    if isempty(NullTable)
    NullTable = cgg_getNullTable(CM_Table,cfg,cfg_Encoder,'MatchType',MatchType,'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,'TargetFilter',TargetFilter,'Identifiers_Table',Identifiers_Table,'LabelClassFilter',LabelClassFilter);
    end
    DataNumber_NullTable = NullTable.DataNumber;
    this_DataNumber = CM_Table.DataNumber;
    MatchingNullEntry = cellfun(@(x) isequal(sort(x),sort(this_DataNumber)),DataNumber_NullTable,'UniformOutput',true);
    this_NullTable = NullTable(MatchingNullEntry,:);
    if ~isempty(this_NullTable)
    BaselineChanceDistribution = this_NullTable.BaselineChanceDistribution;
    BaselineChanceDistribution = BaselineChanceDistribution{1};
    MostCommon = mean(BaselineChanceDistribution);
    RandomChance = mean(BaselineChanceDistribution);
    Stratified = mean(BaselineChanceDistribution);
    end
end

%% Generate Chance Levels

if (isempty(MostCommon) || isempty(RandomChance) || isempty(Stratified)) && IsScaled
[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(...
    Identifiers_Table.TrueValue,ClassNames,MatchType_Calc,IsQuaddle,...
    'Weights',Weights_Chance,'ClassPercent',ClassPercent);
if WantDisplay
fprintf('??? Chance Levels: Stratified~%.3f Random~%.3f Most Common~%.3f!\n',Stratified,RandomChance,MostCommon);
end
end

%% Output Chance Level if wanted

if WantOutputChance
    ChancePrediction = cgg_generateStratifiedPredictions(ClassNames,ClassPercent,size(CM_Table.TrueValue, 1),'IsQuaddle',IsQuaddle);
    CM_Table = removevars(CM_Table,contains(CM_Table.Properties.VariableNames,'Window'));
    CM_Table.Window_1 = ChancePrediction;
end

%% Calculation of Metric

if ~isempty(char(AttentionalFilter))
    Weights = CM_Table.(AttentionalFilter);
end
if ~isempty(char(LabelClassFilter))
    Weights_LabelClass = double(CM_Table.(LabelClassFilter));
    if ~isempty(Weights)
    Weights = Weights.*Weights_LabelClass;
    else
    Weights = Weights_LabelClass;
    end
end

[~,~,Window_Metric] = ...
        cgg_procConfusionMatrixWindowsFromTable(CM_Table,...
        ClassNames,'FilterColumn',TrialFilter,...
        'FilterValue',TrialFilter_Value,...
        'MatchType',MatchType,'IsQuaddle',IsQuaddle,...
        'RandomChance',RandomChance,...
        'MostCommon',MostCommon,'Stratified',Stratified,...
        'Weights',Weights);

%%
if exist("Time","var") && ~isempty(TimeRange)
TimeRangeIndices = Time > min(TimeRange) & Time < max(TimeRange);
Window_Metric(~TimeRangeIndices) = [];
end

%%

if WantOutputChance
    Metric = Stratified;
else
    Metric = max(Window_Metric);
end

end

