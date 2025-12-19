function ThresholdTable = cgg_getNullThreshold(IA_PassTable,cfg_Epoch,cfg_Encoder,varargin)
%CGG_GETNULLTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

% if isfunction
% MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
% else
% if ~(exist('MatchType','var'))
% MatchType='Scaled-BalancedAccuracy';
% end
% end

% if isfunction
% SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
% else
% if ~(exist('SessionName','var'))
% SessionName='Subset';
% end
% end

if isfunction
SetType = CheckVararginPairs('SetType', 'Testing', varargin{:});
else
if ~(exist('SetType','var'))
SetType='Testing';
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
EncoderParameters_CM_Table = CheckVararginPairs('EncoderParameters_CM_Table', [], varargin{:});
else
if ~(exist('EncoderParameters_CM_Table','var'))
EncoderParameters_CM_Table=[];
end
end

% if isfunction
% TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
% else
% if ~(exist('TrialFilter','var'))
% TrialFilter={'All'};
% end
% end

% if isfunction
% TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
% else
% if ~(exist('TargetFilter','var'))
% TargetFilter='Overall';
% end
% end
%%
% [Subset,wantSubset] = cgg_verifySubset(SessionName,true);
% cfg_Encoder.Subset = Subset;
% cfg_Encoder.wantSubset = wantSubset;
fprintf('*** Starting Null Threshold Calculations\n');
%%
EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
%%

% NumFolds = length(Folds);
this_Percentile = (1-Alpha)*100; 
% One tail since only care about if accuracy is higher not lower

%%
RequiredFields = ["SessionName","TrialFilter", "TrialFilter_Value",...
    "TargetFilter","MatchType","Fold","Target"];
ThresholdTable = IA_PassTable(:,RequiredFields);

for i = 1:width(ThresholdTable)
    if isnumeric(ThresholdTable{:, i})
        ThresholdTable{:, i} = fillmissing(ThresholdTable{:, i}, 'constant', Inf);
    end
end

TrialFilter_Value = ThresholdTable.TrialFilter_Value;
TrialFilter_Value_String = cellfun(@(x) join(string(x),'/'),TrialFilter_Value);
ThresholdTable.TrialFilter_Value = TrialFilter_Value_String;
ThresholdTable = unique(ThresholdTable);
TrialFilter_Value_String = ThresholdTable.TrialFilter_Value;
TrialFilter_Value = arrayfun(@(x) str2double(split(x,'/'))',TrialFilter_Value_String,"UniformOutput",false);
ThresholdTable.TrialFilter_Value = TrialFilter_Value;

for i = 1:width(ThresholdTable)
    if isnumeric(ThresholdTable{:, i})
        ThresholdTable{isinf(ThresholdTable{:, i}), i} = NaN;
    end
end
%%

% NullTable = ThresholdTable;
% NullTable.UnScaledChance = cell(height(ThresholdTable),1);
% NullTable.ChanceDistribution = cell(height(ThresholdTable),1);

%%
ThresholdTable.Threshold = zeros(height(ThresholdTable),1);

%%
waitbar = parallel.pool.Constant(cgg_getWaitBar(...
    'All_Iterations',height(ThresholdTable),'Process','Null Threshold',...
    'DisplayIndents', 0));

for tidx = 1:height(ThresholdTable)
    SessionName = ThresholdTable{tidx,"SessionName"};
    Fold = ThresholdTable{tidx,"Fold"};
    this_cfg_Encoder = cfg_Encoder;
    [Subset,wantSubset] = cgg_verifySubset(SessionName,true);
    this_cfg_Encoder.Subset = Subset;
    this_cfg_Encoder.wantSubset = wantSubset;
    Target = ThresholdTable{tidx,"Target"};
    if ~strcmp(Target,cfg_Encoder.Target)
        fprintf("!!! Reassigning the Encoder Target to align with Null Table Row\n");
        this_cfg_Encoder.Target = Target;
    end

    %%
    if ~isempty(EncoderParameters_CM_Table)
    EncoderParameter_TargetIDX = strcmp(EncoderParameters_CM_Table.Target,Target);
    EncoderParameter_SubsetIDX = strcmp(EncoderParameters_CM_Table.Subset,SessionName);
    this_Row = EncoderParameter_TargetIDX & EncoderParameter_SubsetIDX;
    this_EncoderParameter_CM_Table = EncoderParameters_CM_Table(this_Row,:);
    this_CM_TableIDX = this_EncoderParameter_CM_Table.Fold{1} == Fold;
    this_CM_Table = this_EncoderParameter_CM_Table.CM_Table{1}{this_CM_TableIDX};
    DataNumber = this_CM_Table.DataNumber;
    TrueValue = this_CM_Table.TrueValue;
    %%
    else
    [Training,Validation,Testing,~] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,this_cfg_Encoder,'WantData',false);
    
    switch SetType
        case 'Training'
            DataStore = Training;
        case 'Validation'
            DataStore = Validation;
        case 'Testing'
            DataStore = Testing;
        otherwise
            DataStore = Testing;
    end

    this_Output = readall(DataStore,UseParallel=true);
    DataNumber = [this_Output{:,2}]';
    TrueValue = [this_Output{:,1}]';

    end
CM_Table = cgg_generateBlankCMTable('DataNumber',DataNumber,'TrueValue',TrueValue);
%%

TrialFilter = ThresholdTable{tidx,"TrialFilter"};
TrialFilter_Value = ThresholdTable{tidx,"TrialFilter_Value"};
MatchType = ThresholdTable{tidx,"MatchType"};
% AttentionalFilter = ThresholdTable{tidx,"TargetFilter"};
TargetFilter = ThresholdTable{tidx,"TargetFilter"};

[IsComplete,NullTable] = cgg_isNullTableComplete(CM_Table,cfg_Epoch,...
    this_cfg_Encoder,'TrialFilter',TrialFilter,...
    'TrialFilter_Value',TrialFilter_Value,...
    'MatchType',MatchType,'TargetFilter',TargetFilter);

% this_Counter = 0;

if ~IsComplete
    NullTable = cgg_getNullTable(CM_Table,cfg_Epoch,this_cfg_Encoder,...
        'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,...
        'MatchType',MatchType,'TargetFilter',TargetFilter,...
        'ObtainWithoutSaving',true);
end
% while ~IsComplete
%     % this_Counter = this_Counter + 1;
%     % fprintf("??? ~IsComplete %d; Counter: %d\n",~IsComplete,this_Counter);
%     cgg_getNullTable(CM_Table,cfg_Epoch,this_cfg_Encoder,...
%         'TrialFilter',TrialFilter,'TrialFilter_Value',TrialFilter_Value,...
%         'MatchType',MatchType,'TargetFilter',TargetFilter);
%     pause(60);
%     [IsComplete,NullTable] = cgg_isNullTableComplete(CM_Table,cfg_Epoch,...
%         this_cfg_Encoder,'TrialFilter',TrialFilter,...
%         'TrialFilter_Value',TrialFilter_Value,...
%         'MatchType',MatchType,'TargetFilter',TargetFilter);
% end

DataNumber_Null = NullTable.DataNumber;
this_DataNumber = CM_Table.DataNumber;
MatchingNullEntry = cellfun(@(x) isequal(sort(x),sort(this_DataNumber)),DataNumber_Null,'UniformOutput',true);

this_NullTable = NullTable(MatchingNullEntry,:);
ChanceDistribution = this_NullTable.ChanceDistribution{1};
this_Threshold = prctile(ChanceDistribution,this_Percentile);
ThresholdTable(tidx,"Threshold") = {this_Threshold};

waitbar.Value.update();
end

%%
% TrialFilter_Value = ThresholdTable.TrialFilter_Value;
% TrialFilter_Value_String = cellfun(@(x) join(string(x),'/'),TrialFilter_Value);
% ThresholdTable.TrialFilter_Value = TrialFilter_Value_String;
% ThresholdTable = unique(ThresholdTable);
% TrialFilter_Value_String = ThresholdTable.TrialFilter_Value;
% TrialFilter_Value = arrayfun(@(x) str2double(split(x,'/'))',TrialFilter_Value_String,"UniformOutput",false);
% ThresholdTable.TrialFilter_Value = TrialFilter_Value;
%%
% ThresholdTable{:, "TrialFilter_Value"} = fillmissing(ThresholdTable{:, "TrialFilter_Value"}, 'constant', Inf);
% IA_PassTable{:, "TrialFilter_Value"} = fillmissing(IA_PassTable{:, "TrialFilter_Value"}, 'constant', Inf);
% aaa = join(IA_PassTable,ThresholdTable);

% %%
% 
% for fidx = 1:NumFolds
%     Fold = Folds(fidx);
%     [Training,Validation,Testing,~] = cgg_getDatastore(EpochDir_Main,SessionName,Fold,cfg_Encoder);
% 
%     switch SetType
%         case 'Training'
%             DataStore = Training;
%         case 'Validation'
%             DataStore = Validation;
%         case 'Testing'
%             DataStore = Testing;
%         otherwise
%             DataStore = Testing;
%     end
% 
%     [ClassNames,~,~,~,TrueValue] = cgg_getClassesFromDataStore(DataStore);
%     [Distribution] = cgg_getBaselineAccuracyDistribution(TrueValue,ClassNames,MatchType,IsQuaddle,varargin{:});
% 
%     this_Threshold = prctile(Distribution(1,:),this_Percentile);
% 
%     ThresholdTable(Fold,:) = {Fold,this_Threshold};
% end

end

