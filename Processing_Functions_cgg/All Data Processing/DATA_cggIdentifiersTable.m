
clc; clear; close all;
rng('shuffle');
%% Additional Target
AdditionalTargetIDX = 0;
AdditionalTarget = cell(AdditionalTargetIDX);
AdditionalTargetIDX = AdditionalTargetIDX + 1;
AdditionalTarget{AdditionalTargetIDX} = 'Prediction Error Category';
AdditionalTargetIDX = AdditionalTargetIDX + 1;
AdditionalTarget{AdditionalTargetIDX} = 'Absolute Prediction Error';
AdditionalTargetIDX = AdditionalTargetIDX + 1;
AdditionalTarget{AdditionalTargetIDX} = 'Prediction Error';
AdditionalTargetIDX = AdditionalTargetIDX + 1;
AdditionalTarget{AdditionalTargetIDX} = 'Choice Probability CMB';
%% Augment Identifiers Table
AugmentIDX = 0;
AugmentFunctions = cell(AugmentIDX,2);
AugmentIDX = AugmentIDX + 1;
AugmentFunctions{AugmentIDX,1} = @cgg_getCorrectedPreviousOutcome;
AugmentFunctions{AugmentIDX,2} = "Previous Outcome Corrected";
AugmentIDX = AugmentIDX + 1;
AugmentFunctions{AugmentIDX,1} = @(x) cgg_getCorrectedPreviousOutcome(x,true);
AugmentFunctions{AugmentIDX,2} = "Previous";
AugmentIDX = AugmentIDX + 1;
AugmentFunctions{AugmentIDX,1} = @cgg_getPreviousTrialEffect;
AugmentFunctions{AugmentIDX,2} = "Previous Trial Effect";
AugmentIDX = AugmentIDX + 1;
AugmentFunctions{AugmentIDX,1} = @cgg_calcTrialsFromLPMultipleCategories;
AugmentFunctions{AugmentIDX,2} = "Multi Trials From Learning Point";

%%
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
cfg_Encoder = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2;
Epoch = cfg_Encoder.Epoch;
outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;
cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',1,'WantDirectory',false);
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'Encoding',true,'Target',cfg_Encoder.Target,'Fold',1,'WantDirectory',false);
cfg.ResultsDir=cfg_Results.TargetDir;
%%

cgg_getIdentifiersTable(cfg,false,'Epoch',Epoch,'AdditionalTarget',AdditionalTarget);

%%

for fidx = 1:size(AugmentFunctions,1)
    InFunc = AugmentFunctions{fidx,1};
    VariableName = AugmentFunctions{fidx,2};
cgg_augmentIdentifiersTable(cfg,InFunc,VariableName)
end

