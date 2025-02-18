function [IA_Table_Fold,IA_Table_Average] = cgg_procBestRandomImportanceAnalysis(cfg_Encoder,EpochDir,varargin)
%CGG_PROCBESTRANDOMIMPORTANCEANALYSIS Summary of this function goes here
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
PauseTime_Long = CheckVararginPairs('PauseTime_Long', 60, varargin{:});
else
if ~(exist('PauseTime_Long','var'))
PauseTime_Long=60;
end
end

if isfunction
PauseTime_Short = CheckVararginPairs('PauseTime_Short', 15, varargin{:});
else
if ~(exist('PauseTime_Short','var'))
PauseTime_Short=15;
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

SaveTerm_Test = sprintf('%s_Test',SaveTerm);

% IA_AccuracyBestNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm,MatchType);
% IA_AccuracyBestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracyBestNameExt);
IA_AccuracyTestNameExt = sprintf('IA_Table%s_%s.mat',SaveTerm_Test,MatchType);
IA_AccuracyTestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IA_AccuracyTestNameExt);


IABestNameExt = sprintf('IA_Table%s.mat',SaveTerm);
% IABestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IABestNameExt);
IATestNameExt = sprintf('IA_Table%s.mat',SaveTerm_Test);
IATestPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IATestNameExt);

%%
AnalysisDir = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType);
funcHandle =@(x,y) all([x,cgg_getOutputFromIndices(@cgg_checkImportanceAnalysis,y,2,2)]);
HasRemovalTable = cgg_procDirectorySearchAndApply(AnalysisDir, IABestNameExt, funcHandle);
if isempty(HasRemovalTable)
HasRemovalTable = false;
end
%%

if ~HasRemovalTable
[IA_Table_Fold_Test,IA_Table_Average_Test] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',NumRemoved, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',SaveTerm_Test, ...
    'WantRemovalTableAcrossFolds',WantRemovalTableAcrossFolds, ...
    'SessionName',SessionName);

if ~(istable(IA_Table_Fold_Test) && istable(IA_Table_Average_Test))
    IA_Table_Fold = NaN;
    IA_Table_Average = NaN;
return
end

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
            this_RemovalTable_Best = [this_RemovalTable_Baseline; this_RemovalTable_Best];
            RemovalTable_Best{fidx} = this_RemovalTable_Best;
        end
end
% disp({class(Folds),size(Folds),cell2mat(Folds)});
pause(randi(PauseTime_Long)-1);
cgg_saveRemovalTable(RemovalTable_Best,Folds,EpochDir.Results,RemovalType,SessionName,SaveTerm);

end

pause(randi(PauseTime_Short)-1);

[IA_Table_Fold_Best,IA_Table_Average_Best] = cgg_procSingleImportanceAnalysis(...
    cfg_Encoder,EpochDir,'MatchType',MatchType,'NumRemoved',NumRemoved, ...
    'NumEntries',NumEntries, ...
    'maxworkerMiniBatchSize',maxworkerMiniBatchSize, ...
    'DataFormat',DataFormat,'IsQuaddle',IsQuaddle, ...
    'RemovalType',RemovalType,'BaselineArea',BaselineArea, ...
    'BaselineChannel',BaselineChannel,'BaselineLatent',BaselineLatent, ...
    'SaveTerm',SaveTerm, ...
    'WantRemovalTableAcrossFolds',false, ...
    'SessionName',SessionName);
%%
Folds = cell2mat(IA_Table_Fold_Best.Fold);

for fidx = 1:length(Folds)
Fold = Folds(fidx);
this_IA_AccuracyTestPathNameExt = sprintf(IA_AccuracyTestPathNameExt,Fold);
this_IATestPathNameExt = sprintf(IATestPathNameExt,Fold);

pause(randi(PauseTime_Short)-1);
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

