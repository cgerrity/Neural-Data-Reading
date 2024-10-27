function [IA_Table_Fold,IA_Table_Average] = cgg_procBestSequentialImportanceAnalysis(cfg_Encoder,EpochDir,varargin)
%CGG_PROCBESTSEQUENTIALIMPORTANCEANALYSIS Summary of this function goes here
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
NumRemoved = CheckVararginPairs('NumRemoved', 1, varargin{:});
else
if ~(exist('NumRemoved','var'))
NumRemoved=1;
end
end

if isfunction
NumEntries = CheckVararginPairs('NumEntries', 500, varargin{:});
else
if ~(exist('NumEntries','var'))
NumEntries=500;
end
end

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end

if isfunction
DataFormat = CheckVararginPairs('DataFormat', {'SSCTB','CBT',''}, varargin{:});
else
if ~(exist('DataFormat','var'))
DataFormat={'SSCTB','CBT',''};
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
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

if isfunction
BaselineArea = CheckVararginPairs('BaselineArea', NaN, varargin{:});
else
if ~(exist('BaselineArea','var'))
BaselineArea=NaN;
end
end

if isfunction
BaselineChannel = CheckVararginPairs('BaselineChannel', NaN, varargin{:});
else
if ~(exist('BaselineChannel','var'))
BaselineChannel=NaN;
end
end

if isfunction
BaselineLatent = CheckVararginPairs('BaselineLatent', NaN, varargin{:});
else
if ~(exist('BaselineLatent','var'))
BaselineLatent=NaN;
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
end
end

if isfunction
SaveTerm = CheckVararginPairs('SaveTerm', '', varargin{:});
else
if ~(exist('SaveTerm','var'))
SaveTerm='';
end
end

if isfunction
WantRemovalTableAcrossFolds = CheckVararginPairs('WantRemovalTableAcrossFolds', false, varargin{:});
else
if ~(exist('WantRemovalTableAcrossFolds','var'))
WantRemovalTableAcrossFolds=false;
end
end

if isfunction
Folds = CheckVararginPairs('Folds', [], varargin{:});
else
if ~(exist('Folds','var'))
Folds=[];
end
end

if isfunction
NumChannels = CheckVararginPairs('NumChannels', 58, varargin{:});
else
if ~(exist('NumChannels','var'))
NumChannels=58;
end
end

if isfunction
NumAreas = CheckVararginPairs('NumAreas', 6, varargin{:});
else
if ~(exist('NumAreas','var'))
NumAreas=6;
end
end

if isfunction
LatentSize = CheckVararginPairs('LatentSize', 500, varargin{:});
else
if ~(exist('LatentSize','var'))
LatentSize=500;
end
end

if isfunction
BadChannelTable = CheckVararginPairs('BadChannelTable', [], varargin{:});
else
if ~(exist('BadChannelTable','var'))
BadChannelTable=[];
end
end

%%

CurrentSaveTerm = sprintf(SaveTerm,NumRemoved);
if NumRemoved > 1
    PriorSaveTerm = sprintf(SaveTerm,NumRemoved-1);
else
    PriorSaveTerm = '';
end

CurrentSaveTerm_Test = sprintf('%s_Test',CurrentSaveTerm);

% IA_AccuracyBestNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm,MatchType);
% IA_AccuracyBestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracyBestNameExt);
IA_AccuracyTestNameExt = sprintf('IA_Table%s_%s.mat',CurrentSaveTerm_Test,MatchType);
IA_AccuracyTestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracyTestNameExt);

IABestNameExt = sprintf('IA_Table%s.mat',CurrentSaveTerm);
% IABestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IABestNameExt);
IATestNameExt = sprintf('IA_Table%s.mat',CurrentSaveTerm_Test);
IATestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IATestNameExt);

% IAPriorNameExt = 'IA_Table_Sequential.mat';
% IAPriorPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IAPriorNameExt);

IAPriorNameExt = sprintf('IA_Table%s.mat',PriorSaveTerm);
IAPriorPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IAPriorNameExt);
%% Check Removal Tables
AnalysisDir = fullfile(EpochDir.Results,'Analysis');
HasRemovalTableFunc =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,2,2)]);
HasBestRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IABestNameExt, HasRemovalTableFunc);
if isempty(HasBestRemovalTable)
HasBestRemovalTable = false;
end
HasPriorRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IAPriorNameExt, HasRemovalTableFunc);
if isempty(HasPriorRemovalTable)
HasPriorRemovalTable = false;
end
HasTestRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IATestNameExt, HasRemovalTableFunc);
if isempty(HasTestRemovalTable)
HasTestRemovalTable = false;
end

% %% Check Importance Analysis
% AnalysisDir = fullfile(EpochDir.Results,'Analysis');
% HasIA_TableFunc =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,1,2)]);
% HasBestIA_Table = cgg_procDirectorySearchAndApply(AnalysisDir, IABestNameExt, HasIA_TableFunc);
% if isempty(HasBestIA_Table)
% HasBestIA_Table = false;
% end
% HasPriorIA_Table = cgg_procDirectorySearchAndApply(AnalysisDir, IAPriorNameExt, HasIA_TableFunc);
% if isempty(HasPriorIA_Table)
% HasPriorIA_Table = false;
% end
% HasTestIA_Table = cgg_procDirectorySearchAndApply(AnalysisDir, IATestNameExt, HasIA_TableFunc);
% if isempty(HasTestIA_Table)
% HasTestIA_Table = false;
% end

%% Get Test Removal Table

if HasPriorRemovalTable && ~HasTestRemovalTable

    %%
NumChannelsRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.ChannelRemoved);
NumLatentRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.LatentRemoved);
NumRemovalsFunc = @(y) NumChannelsRemovedFunc(y) + NumLatentRemovedFunc(y);
% MaxNumRemovalsFunc = @(y) max(NumRemovalsFunc(y));

    %%


NumFolds = length(Folds);
RemovalTable_Fold = cell(NumFolds,1);

for fidx = 1:NumFolds
    this_Fold = Folds(fidx);
    this_IAPathNameExt = sprintf(IAPriorPathNameExt,this_Fold);
    this_RemovalTable = cgg_getRemovalTable(this_IAPathNameExt);

    [~,PriorMaxRemovalIDX] = max(NumRemovalsFunc(this_RemovalTable));
    PriorRemovals = this_RemovalTable(PriorMaxRemovalIDX,:);
    MustIncludeChannels = PriorRemovals.ChannelRemoved;
    MustIncludeAreas = PriorRemovals.AreaRemoved;
    MustIncludeLatent = PriorRemovals.LatentRemoved;

    MustIncludeChannels = MustIncludeChannels{1};
    MustIncludeAreas = MustIncludeAreas{1};
    MustIncludeLatent = MustIncludeLatent{1};

    MustIncludeTable = table(MustIncludeAreas',MustIncludeChannels',MustIncludeLatent','VariableNames',{'AreaIndices','ChannelIndices','LatentIndices'});


RemovalTable = cgg_makeRemovalTable(NumChannels,NumAreas,LatentSize,BadChannelTable,'RemovalType',RemovalType,'NumRemoved',1,'NumEntries',NumEntries,'MustIncludeTable',MustIncludeTable);
RemovalTable_Fold{this_Fold} = RemovalTable;
end

%%

cgg_saveRemovalTable(RemovalTable_Fold,Folds,EpochDir.Results,RemovalType,SessionName,CurrentSaveTerm_Test);
end

%% Get Test Importance Analysis

if ~HasBestRemovalTable
[IA_Table_Fold_Test,IA_Table_Average_Test] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',NumRemoved, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',CurrentSaveTerm_Test, ...
    'WantRemovalTableAcrossFolds',WantRemovalTableAcrossFolds, ...
    'SessionName',SessionName);

if ~(istable(IA_Table_Fold_Test) && istable(IA_Table_Average_Test))
    IA_Table_Fold = NaN;
    IA_Table_Average = NaN;
return
end

%%

Folds = cell2mat(IA_Table_Fold_Test.Fold);

switch RemovalType
    case 'Channel'
        [~,BestIDX] = min(IA_Table_Average_Test.Peak);
        RemovalTable = IA_Table_Average_Test(:,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);
        RemovalTable_Best = RemovalTable(BestIDX,:);
        Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(RemovalTable, ...
        BaselineArea,BaselineChannel,BaselineLatent);
        RemovalTable_Baseline = RemovalTable(Baseline_IDX,:);
        RemovalTable_Best = [RemovalTable_Baseline; RemovalTable_Best];
    case 'Latent'
        NumFolds = height(IA_Table_Fold_Test);
        RemovalTable_Best = cell(NumFolds,1);
        for fidx = 1:height(IA_Table_Fold_Test)
            this_IA_Table = IA_Table_Fold_Test(fidx,"IA_Table_Metric");
            [~,this_BestIDX] = min(IA_Table_Average_Test.Peak);
            this_RemovalTable = this_IA_Table(:,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);
            this_RemovalTable_Best = this_RemovalTable(this_BestIDX,:);
            this_Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(this_RemovalTable, ...
            BaselineArea,BaselineChannel,BaselineLatent);
            this_RemovalTable_Baseline = this_RemovalTable(this_Baseline_IDX,:);
            % this_RemovalTable_Best = [this_RemovalTable_Baseline; this_RemovalTable_Best];
            RemovalTable_Best{fidx} = [this_RemovalTable_Baseline; this_RemovalTable_Best];
        end
end

cgg_saveRemovalTable(RemovalTable_Best,Folds,EpochDir.Results,RemovalType,SessionName,CurrentSaveTerm);

end

%%

% end
[IA_Table_Fold_Best,IA_Table_Average_Best] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',NumRemoved, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',CurrentSaveTerm, ...
    'WantRemovalTableAcrossFolds',WantRemovalTableAcrossFolds, ...
    'SessionName',SessionName);

%%
Folds = cell2mat(IA_Table_Fold_Best.Fold);

for fidx = 1:length(Folds)
Fold = Folds(fidx);
this_IA_AccuracyTestPathNameExt = sprintf(IA_AccuracyTestPathNameExt,Fold);
this_IATestPathNameExt = sprintf(IATestPathNameExt,Fold);
if isfile(this_IA_AccuracyTestPathNameExt)
delete(this_IA_AccuracyTestPathNameExt);
end
if isfile(this_IATestPathNameExt)
delete(this_IATestPathNameExt);
end
end

%%
IA_Table_Fold = IA_Table_Fold_Best;
IA_Table_Average = IA_Table_Average_Best;

end

