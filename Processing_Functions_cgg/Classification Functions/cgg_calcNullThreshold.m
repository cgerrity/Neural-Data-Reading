function Threshold = cgg_calcNullThreshold(Information_Table,MetricFunc,varargin)
%CGG_CALCNULLTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
cfg_Encoder = CheckVararginPairs('cfg_Encoder', struct(), varargin{:});
else
if ~(exist('cfg_Encoder','var'))
cfg_Encoder=struct();
end
end

if isfunction
cfg_Epoch = CheckVararginPairs('cfg_Epoch', struct(), varargin{:});
else
if ~(exist('cfg_Epoch','var'))
cfg_Epoch=struct();
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
NumIterations = CheckVararginPairs('NumIterations', 10000, varargin{:});
else
if ~(exist('NumIterations','var'))
NumIterations=10000;
end
end

if isfunction
WantDebug = CheckVararginPairs('WantDebug', false, varargin{:});
else
if ~(exist('WantDebug','var'))
WantDebug=false;
end
end

%%
Threshold = NaN;
if isempty(fieldnames(cfg_Epoch)) || isempty(fieldnames(cfg_Encoder))
    fprintf('!!! There is no cfg_Epoch or cfg_Encoder.\n');
    return
end

%% Obtain Required Null Distributions
NullDistributions = cell(1,height(Information_Table));
NullTable = cgg_generateBlankNullTable();

for didx = 1:height(Information_Table)
    DataNumber = Information_Table{didx,"DataNumber"}{:};
    SessionName = Information_Table{didx,"SessionName"};
    this_cfg_Encoder = cfg_Encoder;
    [Subset,wantSubset] = cgg_verifySubset(SessionName,true);
    this_cfg_Encoder.Subset = Subset;
    this_cfg_Encoder.wantSubset = wantSubset;

    TrialFilter = Information_Table{didx,"TrialFilter"};
    TrialFilter_Value = Information_Table{didx,"TrialFilter_Value"};
    MatchType = Information_Table{didx,"MatchType"};
    TargetFilter = Information_Table{didx,"TargetFilter"};
    LabelClassFilter = Information_Table{didx,"LabelClassFilter"};


CM_Table = cgg_generateBlankCMTable('DataNumber',DataNumber);

% [IsComplete,NullTable] = cgg_isNullTableComplete(CM_Table,cfg_Epoch,...
%     this_cfg_Encoder,'TrialFilter',TrialFilter,...
%     'TrialFilter_Value',TrialFilter_Value,...
%     'MatchType',MatchType,'TargetFilter',TargetFilter);

DataNumber_Null = NullTable.DataNumber;
MatchingNullEntry = cellfun(@(x) isequal(sort(x),...
        sort(DataNumber)),DataNumber_Null,'UniformOutput',true);
HasMatchingNullEntry = any(MatchingNullEntry);

if ~HasMatchingNullEntry
[IsComplete,NullTable] = cgg_isNullTableComplete(CM_Table,cfg_Epoch,...
    this_cfg_Encoder,'TrialFilter',TrialFilter,...
    'TrialFilter_Value',TrialFilter_Value,...
    'MatchType',MatchType,'TargetFilter',TargetFilter,...
    'LabelClassFilter',LabelClassFilter);

if ~IsComplete
    fprintf('!!! Null Table is incomplete.\n');
    return
end
DataNumber_Null = NullTable.DataNumber;
MatchingNullEntry = cellfun(@(x) isequal(sort(x),...
        sort(DataNumber)),DataNumber_Null,'UniformOutput',true);
HasMatchingNullEntry = any(MatchingNullEntry);
end

if HasMatchingNullEntry
    this_NullTable = NullTable(MatchingNullEntry,:);
    ChanceDistribution = this_NullTable.ChanceDistribution{1};
else
    fprintf('!!! Null Table has no matching entry.\n');
    return
end

NullDistributions{didx} = ChanceDistribution;
end
%% Obtain Composite Distribution

CompositeNullDistribution = NaN(1,NumIterations);
parfor nidx = 1:NumIterations
    this_MetricList = cellfun(@(x) ...
        cgg_getDataFromIndices(x,randi(length(x))),NullDistributions);
CompositeNullDistribution(nidx) = MetricFunc(this_MetricList);
end

%% Get Specified Threshold value
this_Percentile = (1-Alpha)*100;
% fprintf('??? Significance Level: %f\n',Alpha);
Threshold = prctile(CompositeNullDistribution,this_Percentile);
if WantDebug
fprintf('??? Threshold: %f; NumIterations: %d\n',Threshold,NumIterations);
end
end

