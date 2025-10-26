function [IA_Table_Fold,IA_Table_Average] = cgg_procRandomImportanceAnalysis(cfg_Encoder,cfg_Epoch,varargin)
%CGG_PROCRANDOMIMPORTANCEANALYSIS Summary of this function goes here
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
PauseTime_Long = CheckVararginPairs('PauseTime_Long', 60, varargin{:});
else
if ~(exist('PauseTime_Long','var'))
PauseTime_Long=60;
end
end

if isfunction
PauseTime_Short = CheckVararginPairs('PauseTime_Short', 5, varargin{:});
else
if ~(exist('PauseTime_Short','var'))
PauseTime_Short=5;
end
end

if isfunction
WantDelay = CheckVararginPairs('WantDelay', true, varargin{:});
else
if ~(exist('WantDelay','var'))
WantDelay=true;
end
end
%%

if ~WantDelay
PauseTime_Long = 1;
PauseTime_Short = 1;
end
%%
% SaveTerm = '_Random';
IANameExt = 'IA_Table_Random.mat';
IAPathNameExt = fullfile('Fold %d',SessionName,IANameExt);

% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
%%

NumChannelsRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.ChannelRemoved);
NumLatentRemovedFunc = @(y) cellfun(@(x) sum(~isnan(x)),y.LatentRemoved);
NumRemovalsFunc = @(y) NumChannelsRemovedFunc(y) + NumLatentRemovedFunc(y);
MaxNumRemovalsFunc = @(y) max(NumRemovalsFunc(y));

% AnalysisDir = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType);
AnalysisDir = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType);
RemovalTable_Func =@(y) cgg_getRemovalTable(y);

funcHandle_RemovalTable = @(x,y) min([x,MaxNumRemovalsFunc(RemovalTable_Func(y))]);

%%

CurrentNumRemovals_RemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IANameExt, funcHandle_RemovalTable);
if isempty(CurrentNumRemovals_RemovalTable)
    CurrentNumRemovals_RemovalTable = 0;
end

[MaximumRemovals,NumChannels,NumAreas,LatentSize,BadChannelTable] = cgg_getMaximumNumberOfRemovals(cfg_Encoder,cfg_Epoch,'RemovalType',RemovalType,'SessionName',SessionName);

IsFinished_RemovalTable = CurrentNumRemovals_RemovalTable == MaximumRemovals;

%%

% AnalysisDir = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType);
AnalysisDir = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType);
funcHandle =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,2,2)]);
HasRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IANameExt, funcHandle);
funcHandle =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,1,2)]);
HasIA_Table = cgg_procDirectorySearchAndApply(AnalysisDir, IANameExt, funcHandle);
if isempty(HasRemovalTable)
HasRemovalTable = false;
end
if isempty(HasIA_Table)
HasIA_Table = false;
end

%%

if ~HasRemovalTable
NumFolds = length(Folds);
    %%
TableVariables = [["RemovalTable", "cell"]; ...
    ["Fold", "cell"]];

NumVariables = size(TableVariables,1);
Full_IA_Table_Fold = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

for fidx = 1:NumFolds
RemovalTable_tmp = cgg_makeRemovalTable(1,1,1,[],'NumEntries',0);
Full_IA_Table_Fold(fidx,:) = {{RemovalTable_tmp},{Folds(fidx)}};
end
    %%

NumRemoved_Vector = 1:NumRemoved;
RemovalChunkSize = 10;
% Run multiple instances working on different Number of Removals
for idx = 1:randi(10)
% NumRemoved_Vector = NumRemoved_Vector(randperm(NumRemoved));
NumRemoved_Vector = cgg_procRandomizeChunks(NumRemoved_Vector, RemovalChunkSize);
end


for ridx = 1:NumRemoved

this_NumRemoved = NumRemoved_Vector(ridx);

SaveTerm = sprintf('_Random-%d',this_NumRemoved);

pause(randi(PauseTime_Long)-1);

[IA_Table_Fold,IA_Table_Average] = ...
    cgg_procBestRandomImportanceAnalysis(cfg_Encoder,cfg_Epoch, ...
    'MatchType',MatchType,'NumRemoved',this_NumRemoved, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',SaveTerm, ...
    'WantRemovalTableAcrossFolds',WantRemovalTableAcrossFolds, ...
    'WantDelay',WantDelay);

if ~(istable(IA_Table_Average) && istable(IA_Table_Fold))
continue
end

NumFolds = height(IA_Table_Fold);

for fidx = 1:NumFolds
    this_Fold = Folds(fidx);
this_IA_Table = IA_Table_Fold{this_Fold,"IA_Table_Metric"};
this_IA_Table = this_IA_Table{1};
Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(this_IA_Table, ...
    BaselineArea,BaselineChannel,BaselineLatent);
this_IA_Table(Baseline_IDX,:) = [];

this_Fold_RemovalTable = Full_IA_Table_Fold{this_Fold,"RemovalTable"};
this_Fold_RemovalTable = this_Fold_RemovalTable{1};

this_RemovalTable = this_IA_Table(:,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);
    
this_Fold_RemovalTable(this_NumRemoved+1,:) = this_RemovalTable;

Full_IA_Table_Fold{this_Fold,"RemovalTable"} = {this_Fold_RemovalTable};

end

end


SaveTerm = '_Random';
Folds = cell2mat(Full_IA_Table_Fold.Fold);
Fold_RemovalTable = Full_IA_Table_Fold{:,"RemovalTable"};

pause(randi(PauseTime_Long)-1);

% cgg_saveRemovalTable(Fold_RemovalTable,Folds,cfg_Epoch.Results,RemovalType,SessionName,SaveTerm);
cgg_saveRemovalTable(Fold_RemovalTable,Folds,EpochDir_Results,RemovalType,SessionName,SaveTerm);

end

%%

if ~HasIA_Table

NumFolds = length(Folds);
    %%
TableVariables = [["IA_Table", "cell"]; ...
    ["Fold", "cell"]];

NumVariables = size(TableVariables,1);
Full_IA_Table_Fold = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

IATableVariables = [["AreaRemoved", "cell"]; ...
    ["ChannelRemoved", "cell"]; ...
    ["LatentRemoved", "cell"]; ...
    ["AreaNames", "cell"]; ...
    ["CM_Table", "cell"]];

NumVariables = size(TableVariables,1);
IA_Table_tmp = table('Size',[0,NumVariables],... 
	    'VariableNames', IATableVariables(:,1),...
	    'VariableTypes', IATableVariables(:,2));

for fidx = 1:NumFolds
Full_IA_Table_Fold(fidx,:) = {{IA_Table_tmp},{Folds(fidx)}};
end

for ridx = 1:NumRemoved
    this_NumRemoved = ridx;
    SaveTerm = sprintf('_Random-%d',this_NumRemoved);
    IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
    for fidx = 1:NumFolds
        this_Fold = Folds(fidx);
        % IAPathNameExt = fullfile(cfg_Epoch.Results,'Analysis', ...
        % 'Importance Analysis',RemovalType,sprintf('Fold %d',this_Fold), ...
        % SessionName,IANameExt);
        IAPathNameExt = fullfile(EpochDir_Results,'Analysis', ...
        'Importance Analysis',RemovalType,sprintf('Fold %d',this_Fold), ...
        SessionName,IANameExt);
        [this_IA_Table,~,~] = cgg_getImportanceAnalysis(IAPathNameExt);

        this_Fold_IA_Table = Full_IA_Table_Fold{fidx,"IA_Table"};
        this_Fold_IA_Table = this_Fold_IA_Table{1};

        if ridx == 1
        Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(this_IA_Table, ...
            BaselineArea,BaselineChannel,BaselineLatent);
        this_IA_Table_Baseline = this_IA_Table(Baseline_IDX,:);
        this_Fold_IA_Table = this_IA_Table_Baseline;
        end

        if ~isempty(this_IA_Table)
        Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(this_IA_Table, ...
            BaselineArea,BaselineChannel,BaselineLatent);
        this_IA_Table(Baseline_IDX,:) = [];

        this_Fold_IA_Table(ridx+1,:) = this_IA_Table;

        Full_IA_Table_Fold{fidx,"IA_Table"} = {this_Fold_IA_Table};
        end

    end

end

%%

SaveTerm = '_Random';

for fidx = 1:NumFolds
    this_Fold = Folds(fidx);
    this_Fold_IA_Table = Full_IA_Table_Fold{fidx,"IA_Table"};
    this_Fold_IA_Table = this_Fold_IA_Table{1};

    pause(randi(PauseTime_Long)-1);

% cgg_saveImportanceAnalysis(this_Fold_IA_Table,cfg_Epoch.Results,...
%     RemovalType,this_Fold,SessionName,'SaveTerm',SaveTerm);
cgg_saveImportanceAnalysis(this_Fold_IA_Table,EpochDir_Results,...
    RemovalType,this_Fold,SessionName,'SaveTerm',SaveTerm);

end

end


%%

SaveTerm = '_Random';

pause(randi(PauseTime_Short)-1);

[IA_Table_Fold,IA_Table_Average] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,cfg_Epoch,'MatchType',MatchType,'NumRemoved',1, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',SaveTerm);

%%
IANameExt = 'IA_Table_Random.mat';
funcHandle =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,1,2)]);
HasIA_Table = cgg_procDirectorySearchAndApply(AnalysisDir, IANameExt, funcHandle);

if isempty(HasIA_Table)
HasIA_Table = false;
end

%%

if HasIA_Table

RemovedIDX = 1:NumRemoved;
RemovedIDX = RemovedIDX(randperm(length(RemovedIDX)));
for ridx = 1:length(RemovedIDX)
    this_NumRemoved = RemovedIDX(ridx);
SaveTerm = sprintf('_Random-%d',this_NumRemoved);
IASingleNameExt = sprintf('IA_Table%s.mat',SaveTerm);
% IASinglePathNameExt = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IASingleNameExt);
IASinglePathNameExt = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IASingleNameExt);
IA_AccuracySingleNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm,MatchType);
% IA_AccuracySinglePathNameExt = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracySingleNameExt);
IA_AccuracySinglePathNameExt = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracySingleNameExt);

% pause(randi(PauseTime_Short));

for fidx = 1:length(Folds)
Fold = Folds(fidx);
this_IA_AccuracySinglePathNameExt = sprintf(IA_AccuracySinglePathNameExt,Fold);
this_IASinglePathNameExt = sprintf(IASinglePathNameExt,Fold);

if isfile(this_IA_AccuracySinglePathNameExt)
delete(this_IA_AccuracySinglePathNameExt);
end
if isfile(this_IASinglePathNameExt)
delete(this_IASinglePathNameExt);
end
end

end

end


end

