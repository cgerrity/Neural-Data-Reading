function RemovalPlotTable = cgg_procFullImportanceAnalysis_v2(cfg_Encoder,cfg_Epoch,cfg,varargin)
%CGG_PROCFULLIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
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
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
TargetFilters = CheckVararginPairs('TargetFilters', ["Overall","TargetFeature","DistractorCorrect","DistractorError"], varargin{:});
else
if ~(exist('TargetFilters','var'))
TargetFilters=["Overall","TargetFeature","DistractorCorrect","DistractorError"];
end
end

if isfunction
Alpha = CheckVararginPairs('Alpha', 0.05, varargin{:});
else
if ~(exist('Alpha','var'))
Alpha=0.05;
end
end

if isfunction
RemovalTypes = CheckVararginPairs('RemovalTypes', "Channel", varargin{:});
else
if ~(exist('RemovalTypes','var'))
RemovalTypes="Channel";
end
end

if isfunction
TimeRange = CheckVararginPairs('TimeRange', [-Inf,Inf], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[-Inf,Inf];
end
end

if isfunction
Methods = CheckVararginPairs('Methods', "Block", varargin{:});
else
if ~(exist('Methods','var'))
Methods="Block";
end
end

%%
rng('shuffle');

%%
Target = cfg_Encoder.Target;

% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');

EncodingTargetDir = fullfile(EpochDir_Results,'Encoding',Target);

%%
fprintf('*** Obtaining All Sessions and their associated parameters\n');
cfg_Encoder_tmp = cfg_Encoder;
cfg_Encoder_tmp.Subset = '%s';
cfg_Network = cgg_generateEncoderSubFolders_v2('',cfg_Encoder_tmp,'WantDirectory',false);
OptimalPath = cgg_getDirectory(cfg_Network,'Classifier');

OptimalPathNameExt = fullfile(sprintf(OptimalPath,'*'),'EncodingParameters.yaml');

EncoderParametersFunc = @(x,y) cgg_getAllEncoderCMTable(x,y,...
    'WantFinished',false,'WantValidation',false);
EncoderParameters_CM_Table = cgg_procDirectorySearchAndApply(EncodingTargetDir, ...
    OptimalPathNameExt, EncoderParametersFunc,'IsSingleLevel',true);

EncoderParameters_CM_Table(...
    strcmp(EncoderParameters_CM_Table.Subset,'true'),:) = [];

EncoderParameters_CM_Table = EncoderParameters_CM_Table(randperm(height(EncoderParameters_CM_Table)),:);

%%

fprintf('*** Constructing Importance Analysis Pass Table\n');
IA_PassTable_Session_Func = @(x,y) cgg_getOverallPassTable(...
    x, y,cfg_Epoch,'MatchType',MatchType,...
    'MatchType_Attention',MatchType_Attention,...
    'TrialFilter',TrialFilter,'TargetFilters',TargetFilters,...
    'RemovalTypes',RemovalTypes,'Target',Target,'TimeRange',TimeRange,...
    'Methods',Methods);

IA_PassTable_Cell_Func = @() rowfun(IA_PassTable_Session_Func,EncoderParameters_CM_Table,"InputVariables",["Fold","Subset"],"SeparateInputs",true,"ExtractCellContents",true,"NumOutputs",1,"OutputFormat","cell");
Cat_Func = @(x) vertcat(x{:});
IA_PassTable_Func = @() Cat_Func(IA_PassTable_Cell_Func());
IA_PassTable = IA_PassTable_Func();

%%

fprintf('*** Getting Null Threshold for Signigicance Level: %.3f\n',Alpha);
ThresholdTable = cgg_getNullThreshold(IA_PassTable,cfg_Epoch,cfg_Encoder,'SetType','Testing','Alpha',Alpha,'EncoderParameters_CM_Table',EncoderParameters_CM_Table);
IA_PassTable{:, "TrialFilter_Value"} = fillmissing(IA_PassTable{:, "TrialFilter_Value"}, 'constant', Inf);
IA_PassTable = join(IA_PassTable,ThresholdTable);

%%
RepeatPass = true;

fprintf('*** Running Importance Analysis Passes\n');
while RepeatPass
IA_PassTable = IA_PassTable(randperm(size(IA_PassTable,1)),:);

NumPasses = height(IA_PassTable);
for pidx = 1:NumPasses
    fprintf('*** Running Importance Analysis Passes: Pass %d of %d\n',pidx,NumPasses);
    cgg_runImportanceAnalysis(IA_PassTable(pidx,:),cfg_Epoch,cfg_Encoder,varargin)
% Insert run of Importance Analysis
end

IA_PassTable = IA_PassTable_Func();
IA_PassTable{:, "TrialFilter_Value"} = fillmissing(IA_PassTable{:, "TrialFilter_Value"}, 'constant', Inf);
IA_PassTable = join(IA_PassTable,ThresholdTable);

RepeatPass = ~all(IA_PassTable.IsComplete & ~IA_PassTable.HasFlag);
end

%%
RemovalPlotTable = [];

end

