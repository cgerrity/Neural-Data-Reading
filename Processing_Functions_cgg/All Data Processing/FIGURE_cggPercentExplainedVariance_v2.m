%% FIGURE_cggPercentExplainedVariance

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';

FeatureDimensions = [1,2,3,5];

% EVType='Chosen Feature';
EVType='Shared Feature';
% EVType='Previous Correct Shared';
% EVType='Correct';

%%

outdatadir=cfg(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg(1).temporarydir;


switch EVType
    case 'Chosen Feature'
        PlotSubFolder='Chosen Feature';
    case 'Shared Feature'
        PlotSubFolder='Shared Feature Coding';
    case 'Previous Correct Shared'
        PlotSubFolder='Previous Correct Shared';
    case 'Correct'
        PlotSubFolder='Correct';
end

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

% cfg_Save = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'ExplainedVariance',true,'ExplainedVariance_Zoom',...
%     {'High Zoom','Medium Zoom','Low Zoom'});
cfg_Save = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'PlotFolder','Plot Data','PlotSubFolder',PlotSubFolder);
% cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',Epoch,'ExplainedVariance',true,'ExplainedVariance_Zoom',...
%     {'High Zoom','Medium Zoom','Low Zoom'});
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Plot Data','PlotSubFolder',PlotSubFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

%%

for sidx=1:length(cfg)
%     sidx=1;
    
    inputfolder=cfg(sidx).inputfolder;
    outdatadir=cfg(sidx).outdatadir;

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir);

DataDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data.path;
TargetDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
ProcessingDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing.path;

TargetPathNameExt=[TargetDir filesep 'Target_Information.mat'];
ProbeProcessingPathNameExt=[ProcessingDir filesep 'Probe_Processing_Information.mat'];

DataWidth='All';
WindowStride=50;

ChannelRemoval=[];
WantDisp=false;
WantRandomize=false;
WantNaNZeroed=true;
Want1DVector=false;
StartingIDX=1;
EndingIDX=1;

Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector);
Data_ds = fileDatastore(DataDir,"ReadFcn",Data_Fun);

Target=matfile(TargetPathNameExt,"Writable",false);
Target=Target.Target;
SharedFeatureCoding=[Target.SharedFeatureCoding]';
SharedFeature=[Target.SharedFeature]';
PreviousTrialCorrect=[Target.AdjustedPreviousTrialCorrect]';
CorrectTrial=[Target.AdjustedCorrectTrial]';
Dimensions=[Target.SelectedObjectDimVals]';
Dimensions=Dimensions(:,FeatureDimensions);

switch EVType
    case 'ChosenFeature'
        MatchArray=Dimensions;
    case 'Shared Feature'
        MatchArray=SharedFeatureCoding;
    case 'Previous Correct Shared'
        MatchArray=[PreviousTrialCorrect,CorrectTrial,SharedFeature];
    case 'Correct'
        MatchArray=CorrectTrial;
end

%%

ProbeProcessing=matfile(ProbeProcessingPathNameExt,"Writable",false);
ProbeProcessing=ProbeProcessing.ProbeProcessing;

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

Recorded_Areas=find(any(cell2mat(cellfun(@(x) strcmp(Probe_Order,x),fieldnames(ProbeProcessing),'UniformOutput',false)),1));

Areas=Recorded_Areas;

%%

InIncrement=10;
InSavePathNameExt=[Plotcfg.path filesep 'Regression_Data_%s_' cfg(sidx).SessionName '.mat'];
InFunction=@(x,y) cgg_procRegressionValues(x,y,MatchArray,InIncrement,Probe_Order,InSavePathNameExt);

NumOutputs=0;

Outputs = cgg_applyFunctionToProcessedAreasFromSession(InFunction,DataDir,Areas,NumOutputs);

end


% %%
% 
% NumParallelLoops=prod([NumChannels,NumSamples,NumAreas]);
% 
% PEV_Cell=cell(NumParallelLoops,1);
% 
% parfor pidx=1:NumParallelLoops
% 
% % for cidx=1:NumChannels
% %     for sidx=1:NumSamples
% %         for aidx=1:NumAreas
% 
% [cidx,sidx,aidx] = ind2sub([NumChannels,NumSamples,NumAreas],pidx);
% 
% this_Activity=cellfun(@(x) x(cidx,sidx,aidx),Data_All);
% 
% PEV_Cell{pidx} = cgg_procPercentExplainedVariance(Activity,GroupIDX);
% 
% %         end
% %     end
% % end
% 
% end
% 
% % end







