%% FIGURE_cggPercentExplainedVariance

clc; clear; close all;

Epoch='Decision';

InIncrement=1;

% EVType='Chosen Feature';
EVType='Shared Feature';
% EVType='Previous Correct Shared';
% EVType='Correct';

Data_Location = "Backup";

WantPlotExplainedVariance = false;
WantPlotSignificant = true;
WantPlotCombinedExplainedVariance = true;

WantAllVersion = true;

wantSignificant = false;

AreaNameCheck='ACC';
AreaNameCheck={'ACC','PFC','CD'};
SignificanceValue = 0.05;

%%

WantPlot = any([WantPlotExplainedVariance, WantPlotSignificant, ...
    WantPlotCombinedExplainedVariance]);

%%

[inputfolder_base,outputfolder_base,temporaryfolder_base,...
    Current_System] = cgg_getBaseFolders();

MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

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

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Plot Data','PlotSubFolder',PlotSubFolder);
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
switch EVType
    case 'ChosenFeature'
        Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
    case 'Shared Feature'
        Target_Fun=@(x) cgg_loadTargetArray(x,'SharedFeatureCoding',true);
    case 'Previous Correct Shared'
        Target_Fun_Previous=@(x) cgg_loadTargetArray(x,'PreviousTrialCorrect',true);
        Target_Fun_Correct=@(x) cgg_loadTargetArray(x,'CorrectTrial',true);
        Target_Fun_Shared=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
        Target_Fun=@(x) [Target_Fun_Previous(x), Target_Fun_Correct(x), Target_Fun_Shared(x)];
    case 'Correct'
        Target_Fun=@(x) cgg_loadTargetArray(x,'CorrectTrial',true);
end

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
for sidx=1:NumSessions
%%

this_SessionName=SessionListUnique{sidx};
this_SessionIDX=strcmp(this_SessionName,SessionsList);

InSavePathNameExt=[PlotDatacfg.path filesep 'Regression_Data_%s_' this_SessionName '.mat'];
this_ProbeProcessing=ProbeProcessing{sidx};

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

MatchArray=cell2mat(readall(this_Target_ds));

%%

InFunction=@(x,y) cgg_procRegressionValues(x,y,MatchArray,InIncrement,Probe_Order,InSavePathNameExt);

NumOutputs=0;

Outputs = cgg_applyFunctionToProcessedAreasFromSession(InFunction,this_DataDir,Areas,NumOutputs);

end

end

end

if WantPlot

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
    
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Explained Variance',...
    'PlotSubFolder',PlotSubFolder,...
    'PlotSubSubFolder',{'High Zoom','Medium Zoom','Low Zoom'});
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

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

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        InputTable{acidx} = cgg_getAreaRegressionValues(this_InputTable,this_PlotDataPathNameExt,this_AreaNameCheck);
    end
end % End Loop through areas

end % End Loop through Sessions

if WantPlotSignificant
    %%

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Significance',...
    'PlotSubFolder',PlotSubFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotSignificantRegression(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg);
        % cgg_plotSignificantRegression_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg);
        cgg_plotSignificantRegression_v3(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg);
    end

% cgg_plotSignificantRegression(InputTable,SignificanceValue,AreaNameCheck,Plotcfg);

end

if WantPlotCombinedExplainedVariance
    %%

if wantSignificant
this_PlotFolder = 'Significant Coefficient Values';
else
this_PlotFolder = 'All Coefficient Values';
end

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',this_PlotFolder,...
    'PlotSubFolder',PlotSubFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotCoefficientValuesRegression(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg,'wantSignificant',wantSignificant);
        % cgg_plotCoefficientValuesRegression_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg,'wantSignificant',wantSignificant);
        cgg_plotCoefficientValuesRegression_v3(this_InputTable,SignificanceValue,this_AreaNameCheck,Plotcfg,'wantSignificant',wantSignificant);
    end


end

close all
end % End want Plot
