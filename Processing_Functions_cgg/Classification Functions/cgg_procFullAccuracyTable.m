function FullTable = cgg_procFullAccuracyTable(EpochName,FilterColumn,MatchType,MatchType_Attention,IsQuaddle,AdditionalTarget,WantUseNullTable,WantLabelClassFilter,SavePathNameExt,cfg,cfg_Encoder)
%CGG_PROCFULLACCURACYTABLE Summary of this function goes here
%   Detailed explanation goes here
fprintf('*** Obtaining All Sessions and their associated parameters\n');
EncodingParametersPath = cgg_getDirectory(cfg.ResultsDir,'Fold');
[EncodingParametersPath,~,~] = fileparts(EncodingParametersPath);
cfg_Encoder_tmp = cfg_Encoder;
cfg_Encoder_tmp.Subset = '%s';
cfg_Network = cgg_generateEncoderSubFolders_v2('',cfg_Encoder_tmp,'WantDirectory',false);
OptimalPath = cgg_getDirectory(cfg_Network,'Classifier');

OptimalPathNameExt = fullfile(sprintf(OptimalPath,'*'),'EncodingParameters.yaml');

EncoderParametersFunc = @(x,y) cgg_getAllEncoderCMTable(x,y,...
    'WantFinished',false,'WantValidation',false);
EncoderParameters_CM_Table = cgg_procDirectorySearchAndApply(EncodingParametersPath, ...
    OptimalPathNameExt, EncoderParametersFunc,'IsSingleLevel',true);

EncoderParameters_CM_Table = EncoderParameters_CM_Table(randperm(height(EncoderParameters_CM_Table)),:);

%% Overall Results
FullTableTimer = tic;
FullTableFunc = @(x,y) cgg_getFullAccuracyTable(x,cfg,'Subset',y,'Epoch',EpochName,'TrialFilter',FilterColumn,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'MatchType_Attention',MatchType_Attention,'TimeRange',[],'cfg_Encoder',cfg_Encoder,'AdditionalTarget',AdditionalTarget,'WantFilteredChance',true,'WantSpecificChance',true,'WantUseNullTable',WantUseNullTable,'WantLabelClassFilter',WantLabelClassFilter);
FullTable = rowfun(FullTableFunc,EncoderParameters_CM_Table,"InputVariables",["CM_Table","Subset"],"SeparateInputs",true,"ExtractCellContents",false,"NumOutputs",1,"OutputFormat","cell");
FullTable = vertcat(FullTable{:});
FullTable.Properties.RowNames = EncoderParameters_CM_Table.Subset;

FullTableTime = seconds(toc(FullTableTimer));
FullTableTime.Format='hh:mm:ss';
fprintf('### Complete Calculations of Full Table for %s! [Time: %s]\n',...
    string(join(FilterColumn)),FullTableTime);

%% Old Results
cfg_Encoder_Old = PARAMETERS_OPTIMAL_cgg_runAutoEncoder;
OptimalPath = cgg_getOldEncoderParameters(cfg_Encoder_Old);
OptimalPathNameExt = fullfile(OptimalPath,'EncodingParameters.yaml');

EncoderParametersOld_CM_Table = cgg_procDirectorySearchAndApply(EncodingParametersPath, ...
    OptimalPathNameExt, EncoderParametersFunc,'IsSingleLevel',true);

FullTableFunc = @(x,y) cgg_getFullAccuracyTable(x,cfg,'Subset',y,'Epoch',EpochName,'TrialFilter',FilterColumn,'MatchType',MatchType,'IsQuaddle',IsQuaddle,'MatchType_Attention',MatchType_Attention,'TimeRange',[],'cfg_Encoder',cfg_Encoder_Old,'AdditionalTarget',AdditionalTarget,'WantFilteredChance',true,'WantSpecificChance',true,'WantUseNullTable',WantUseNullTable,'WantLabelClassFilter',WantLabelClassFilter);
FullTableOld = rowfun(FullTableFunc,EncoderParametersOld_CM_Table,"InputVariables",["CM_Table","Subset"],"SeparateInputs",true,"ExtractCellContents",false,"NumOutputs",1,"OutputFormat","cell");
FullTableOld = vertcat(FullTableOld{:});
FullTableOld.Properties.RowNames = "Old Results";

%%
FullTable = vertcat(FullTable,FullTableOld);

%%

fprintf('### Saving Full Table for %s!\n',string(join(FilterColumn)));
save(SavePathNameExt,'FullTable');
fprintf('### Saved Full Table for %s!\n',string(join(FilterColumn)));
end

