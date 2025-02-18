function [InputTable,CoefficientNames] = ...
    cgg_procAllSessionRegressionToVariable(EVType,Epoch,InIncrement,...
    WantPlotExplainedVariance,WantPlotCorrelation)
%CGG_PROCALLSESSIONREGRESSIONTOVARIABLE Summary of this function goes here
%   Detailed explanation goes here

cfg_VariableSet = PARAMETERS_cggVariableToData(EVType);
Data_Location = "Main";
AreaNameCheck={'ACC','PFC','CD'};

%%

WantPlot = WantPlotExplainedVariance || WantPlotCorrelation;

%%

[~,outputfolder_base,temporaryfolder_base,~] = cgg_getBaseFolders();

MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

RemovedChannelsDir = [MainDir filesep 'Aggregate Data' filesep 'Variables' filesep 'Summary'];

BadChannelsPathNameExt = [RemovedChannelsDir filesep 'BadChannels.mat'];
NotSignificantChannelsPathNameExt = [RemovedChannelsDir filesep ...
    'NotSignificantChannels.mat'];

BadChannels = load(BadChannelsPathNameExt);
NotSignificantChannels = load(NotSignificantChannelsPathNameExt);

CommonRemovedChannels = [BadChannels.CommonDisconnectedChannels, ...
    NotSignificantChannels.CommonNotSignificant];

%%

VariableFolder = cfg_VariableSet.PlotSubFolder;

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Plot Data','PlotSubFolder',VariableFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

PlotDatacfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

%%

[cfg_Session] = DATA_cggAllSessionInformationConfiguration;
SessionsName={cfg_Session.SessionName}';
SessionsName_Hyphen={cfg_Session.SessionName}';
SessionsName=replace(SessionsName,'-','_');

NumSessions=length(cfg_Session);

SessionComplete=table(false(NumSessions,1),...
    'VariableNames',"IsSessionComplete",'RowNames',SessionsName);

%%

for sidx=1:NumSessions
    
this_SessionName=SessionsName{sidx};
this_SessionName_Hyphen=SessionsName_Hyphen{sidx};

InSavePathNameExt=[PlotDatacfg.path filesep 'Regression_Data_%s_' this_SessionName '.mat'];

[AreaNames,~] = PARAMETERS_cgg_getSessionProbeInformation(this_SessionName_Hyphen);

this_SessionComplete=true;

for aidx=1:length(AreaNames)
    this_AreaName=AreaNames{aidx};
    this_PlotDataPathNameExt=sprintf(InSavePathNameExt,this_AreaName);

    this_SessionComplete = this_SessionComplete && isfile(this_PlotDataPathNameExt);
end

SessionComplete{this_SessionName,:}=this_SessionComplete;

end

AllSessionComplete=all(SessionComplete{:,:});

%%
if ~AllSessionComplete
%%

switch Data_Location
    case "Main"
      [cfg, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,'Epoch',Epoch);
    case "Backup"
      [cfg, ~] = cgg_generateSessionAggregationFolders('TargetDir',ResultsDir,'Epoch',Epoch);
    otherwise
      [cfg, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,'Epoch',Epoch);
end

[cfg_NotData, ~] = cgg_generateSessionAggregationFolders('TargetDir',MainDir,'Epoch',Epoch);

DataDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetDir=cfg_NotData.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;

%%

TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
SessionNameDataStore = fileDatastore(TargetDir,"ReadFcn",TargetSession_Fun);

SessionsList=gather(tall(SessionNameDataStore));

[SessionListUnique,FirstSession,~]=unique(SessionsList);

NumSessions=length(SessionListUnique);
%%

TargetProcessing_Fun=@(x) cgg_loadTargetArray(x,'ProbeProcessing',true);
ProbeProcessingDataStore = fileDatastore(TargetDir,"ReadFcn",TargetProcessing_Fun);

ProbeProcessingDataStore=subset(ProbeProcessingDataStore,FirstSession);

ProbeProcessing=readall(ProbeProcessingDataStore);

%%

Target_Fun = cfg_VariableSet.Target_Fun;
VariableInformation = cfg_VariableSet.VariableInformation;

%%
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
Target_ds = fileDatastore(TargetDir,"ReadFcn",Target_Fun);
%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

%%
rng('shuffle');
SessionIndices = 1:NumSessions;
SessionIndices = SessionIndices(randperm(NumSessions));

for sidx=1:NumSessions
%%

this_SessionIndex = SessionIndices(sidx);

this_SessionName=SessionListUnique{this_SessionIndex};
this_SessionIDX=strcmp(this_SessionName,SessionsList);

InSavePathNameExt=[PlotDatacfg.path filesep 'Regression_Data_%s_' this_SessionName '.mat'];
this_ProbeProcessing=ProbeProcessing{this_SessionIndex};

AreaNames=fieldnames(this_ProbeProcessing);

Recorded_Areas=find(any(cell2mat(cellfun(@(x) strcmp(Probe_Order,x),AreaNames,'UniformOutput',false)),1));

Areas=Recorded_Areas;

SessionComplete=true;

for aidx=1:length(Areas)
    this_AreaName=AreaNames{aidx};
    this_PlotDataPathNameExt=sprintf(InSavePathNameExt,this_AreaName);

    SessionComplete = SessionComplete && isfile(this_PlotDataPathNameExt);
end

%%
if ~SessionComplete
%%

this_Data_ds=subset(Data_ds,this_SessionIDX);
this_Target_ds=subset(Target_ds,this_SessionIDX);

this_DataDir=this_Data_ds.Files;

MatchArray = readall(this_Target_ds);
MatchArray=cell2mat(MatchArray');
MatchArray=MatchArray';

%%

InFunction=@(x,y) cgg_procRegressionValues(x,y,MatchArray,InIncrement,Probe_Order,VariableInformation,InSavePathNameExt);

NumOutputs=0;

cgg_applyFunctionToProcessedAreasFromSession(InFunction,this_DataDir,Areas,NumOutputs);

end

end

end

%%

InputTable=cell(1,length(AreaNameCheck));

for sidx=1:NumSessions

this_SessionName=SessionsName{sidx};
this_SessionName_Hyphen=SessionsName_Hyphen{sidx};

InSavePathNameExt=[PlotDatacfg.path filesep 'Regression_Data_%s_' this_SessionName '.mat'];

[AreaNames,~] = PARAMETERS_cgg_getSessionProbeInformation(this_SessionName_Hyphen);

for aidx=1:length(AreaNames)
    this_AreaName=AreaNames{aidx};
    this_PlotDataPathNameExt=sprintf(InSavePathNameExt,this_AreaName);

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        [InputTable{acidx},this_CoefficientNames] = cgg_getAreaRegressionValues(this_InputTable,this_PlotDataPathNameExt,this_AreaNameCheck,'CommonRemovedChannels',CommonRemovedChannels);
        if ~isempty(this_CoefficientNames)
            CoefficientNames = this_CoefficientNames;
        end
    end
end % End Loop through areas

end % End Loop through Sessions

%%

if WantPlot

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;

%%
    
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Explained Variance',...
    'PlotSubFolder',VariableFolder,...
    'PlotSubSubFolder',{'High Zoom','Medium Zoom','Low Zoom'});
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

cfg_Correlation_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Correlation',...
    'PlotSubFolder',VariableFolder,...
    'PlotSubSubFolder',{'High Zoom','Medium Zoom','Low Zoom'});
cfg_Correlation_Save.ResultsDir=cfg_Correlation_Results.TargetDir;

Plotcfg_Correlation=cfg_Correlation_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

% InputTable=[];
InputTable=cell(1,length(AreaNameCheck));

for sidx=1:NumSessions

this_SessionName=SessionsName{sidx};
this_SessionName_Hyphen=SessionsName_Hyphen{sidx};

InSavePathNameExt=[PlotDatacfg.path filesep 'Regression_Data_%s_' this_SessionName '.mat'];

[AreaNames,~] = PARAMETERS_cgg_getSessionProbeInformation(this_SessionName_Hyphen);

for aidx=1:length(AreaNames)
    this_AreaName=AreaNames{aidx};
    this_PlotDataPathNameExt=sprintf(InSavePathNameExt,this_AreaName);

    if WantPlotExplainedVariance
        cgg_plotExplainedVariance_v2(this_PlotDataPathNameExt,Plotcfg,'InFigure',InFigure);
    end

    if WantPlotCorrelation
        cgg_plotCorrelation(this_PlotDataPathNameExt,Plotcfg_Correlation,'InFigure',InFigure)
    end

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        [InputTable{acidx},this_CoefficientNames] = cgg_getAreaRegressionValues(this_InputTable,this_PlotDataPathNameExt,this_AreaNameCheck,'CommonRemovedChannels',CommonRemovedChannels);
        if ~isempty(this_CoefficientNames)
            CoefficientNames = this_CoefficientNames;
        end
    end
end % End Loop through areas

end % End Loop through Sessions

end
end

