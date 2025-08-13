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
TrialFilter = CheckVararginPairs('TrialFilter', 'All', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='All';
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

%% Ensure Subset and wantSubset Agree
[Subset,wantSubset] = cgg_verifySubset(Subset,wantSubset);

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

if ~isempty(AttentionalFilter)
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
end

%% Generate ClassNames

TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
TrueValue=Identifiers_Table{:,TrueValueIDX};
Identifiers_Table.TrueValue = TrueValue;
[ClassNames,~,~,~] = cgg_getClassesFromCMTable(Identifiers_Table);

%% Generate Attention Weights

Identifiers_Table = cgg_getAttentionWeights(Identifiers_Table);
% if ~isempty(AttentionalFilter)
% Weights = Identifiers_Table.(AttentionalFilter);
% end

%% Join CM_Table and Identifiers_Table

CM_Table=join(CM_Table,Identifiers_Table);
% if ~isempty(AttentionalFilter)
% Weights = CM_Table.(AttentionalFilter);
% end

%% Filter Trials

% if all(~strcmp(TrialFilter,'All'))
%     FilterRowIDX=all((CM_Table{:,TrialFilter}==TrialFilter_Value),2);
%     CM_Table(~FilterRowIDX,:)=[];
% end

if WantSpecificChance
    Chance_Table = CM_Table;
else
    Chance_Table = Identifiers_Table;
end
%% Generate Chance Levels

if ~isempty(AttentionalFilter)
Weights = Chance_Table.(AttentionalFilter);
end

if isempty(MostCommon) || isempty(RandomChance) || isempty(Stratified)
[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(...
    Chance_Table.TrueValue,ClassNames,MatchType_Calc,IsQuaddle,...
    'Weights',Weights);
end

%% Calculation of Metric

if ~isempty(AttentionalFilter)
Weights = CM_Table.(AttentionalFilter);
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
TimeRangeIndices = Time > min(Time_Range) & Time < max(Time_Range);
Window_Metric(~TimeRangeIndices) = [];
end

%%

Metric = max(Window_Metric);

end

