%% FIGURE_cggVariableToData

clc; clear; close all;

%%

Epoch='Decision';

InIncrement=1;

% EVType='Chosen Feature';
% EVType='Shared Feature';
% EVType='Previous Correct Shared';
% EVType='Correct';
% EVType='Prediction Error';
% EVType='Positive Prediction Error';
% EVType='Negative Prediction Error';
% EVType='Previous Trial Effect';
% EVType = 'Absolute Prediction Error';
% EVType = 'Outcome';
% EVType = 'Error Trace';
% EVType = 'Choice Probability WM';
% % EVType = 'Choice Probability RL';
% EVType = 'Choice Probability CMB';
EVType = 'Value RL';
% % EVType = 'Value WM';
% % EVType = 'WM Weight';

Data_Location = "Main";

WantPaperFormat = true;
wantPaperSized = false;

WantPlotExplainedVariance = false;
WantPlotCorrelation = false;
WantPlotModelSignificance = false;
WantPlotSignificant = false;
WantPlotCombinedExplainedVariance = false;
WantPlotCorrelationSignificance = false;
WantPlotCorrelationValues = false;
WantPlotSignificantCorrelationValues = false;
WantPlotCoefficientProportionPositiveNegative = false;
WantPlotCoefficientSignificant = false;
WantPlotCoefficient = false;
WantPlotCorrelationSignificanceDifference = false;
WantPlotCorrelationProportionPositiveNegative = false;
WantPlotCorrelationProportionPositiveNegativeHistogram = false;
WantPlotCorrProportionPositiveNegativeHistogramNeighborhood = false;
WantPlotMultiPlot = true;

WantAllVersion = true;

wantSignificant = false;

AreaNameCheck={'ACC','PFC','CD'};
SignificanceValue = 0.05;
SignificanceMimimum = [];

%%
Time_Start = -1.5;
Time_End = 1.5;
SamplingRate = 1000;
DataWidth = 1;
WindowStride = 1; % Should be related to InIncrement???

TimeSelection = [0.95,1.15];
% NeighborhoodSize = 60;
PlotValue_CoverageAmount = 0.5;

%%
ExtraTerm = '';
PlotFolder = 'Variable Comparison';
if WantPaperFormat
    ExtraTerm = 'PaperFormat_';
    PlotFolder = 'Paper Figures';
end

%%

PlotInformation = struct;
PlotInformation.Time_Start = Time_Start;
PlotInformation.Time_End = Time_End;
PlotInformation.SamplingRate = SamplingRate;
PlotInformation.DataWidth = DataWidth;
PlotInformation.WindowStride = WindowStride;
%%

PlotInformation.PlotParameters = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',WantPaperFormat);
PlotInformation.PlotParameters.wantPaperSized = false;
PlotInformation.ExtraTerm = ExtraTerm;
PlotInformation.SignificanceMimimum = SignificanceMimimum;
PlotInformation.PlotValue_CoverageAmount = PlotValue_CoverageAmount;
%%

WantPlot = any([WantPlotExplainedVariance, WantPlotSignificant, ...
    WantPlotCombinedExplainedVariance, WantPlotModelSignificance, ...
    WantPlotCorrelationSignificance, WantPlotCorrelationValues, ...
    WantPlotSignificantCorrelationValues, ...
    WantPlotCoefficientProportionPositiveNegative, ...
    WantPlotCoefficientSignificant, ...
    WantPlotCorrelationSignificanceDifference, ...
    WantPlotCorrelationProportionPositiveNegative, ...
    WantPlotCorrelationProportionPositiveNegativeHistogram, ...
    WantPlotCorrProportionPositiveNegativeHistogramNeighborhood, ...
    WantPlotMultiPlot, WantPlotCoefficient]);

cfg_VariableSet = PARAMETERS_cggVariableToData(EVType);

%%

[inputfolder_base,outputfolder_base,temporaryfolder_base,...
    Current_System] = cgg_getBaseFolders();

MainDir=[outputfolder_base filesep 'Data_Neural'];
ResultsDir=[temporaryfolder_base filesep 'Data_Neural'];

% switch EVType
%     case 'Chosen Feature'
%         PlotSubFolder='Chosen Feature';
%     case 'Shared Feature'
%         PlotSubFolder='Shared Feature Coding';
%     case 'Previous Correct Shared'
%         PlotSubFolder='Previous Correct Shared';
%     case 'Previous Trial Effect'
%         PlotSubFolder='Previous Trial Effect';
%     case 'Correct'
%         PlotSubFolder='Correct';
%     case 'Prediction Error'
%         PlotSubFolder='Prediction Error';
% end

RemovedChannelsDir = [MainDir filesep 'Variables' filesep 'Summary'];

BadChannelsPathNameExt = [RemovedChannelsDir filesep 'BadChannels.mat'];
NotSignificantChannelsPathNameExt = [RemovedChannelsDir filesep ...
    'NotSignificantChannels.mat'];

BadChannels = load(BadChannelsPathNameExt);
NotSignificantChannels = load(NotSignificantChannelsPathNameExt);

CommonRemovedChannels = [BadChannels.CommonDisconnectedChannels, ...
    NotSignificantChannels.CommonNotSignificant];

%%

VariableFolder = cfg_VariableSet.PlotSubFolder;
VariablePlotFolder = VariableFolder;

if ~isempty(PlotInformation.SignificanceMimimum)
    SignificanceMimimumName = sprintf(' ~ Significance Mimimum - %f',PlotInformation.SignificanceMimimum);
    VariablePlotFolder = [VariableFolder SignificanceMimimumName];
end

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
% switch EVType
%     case 'ChosenFeature'
%         Target_Fun=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
%     case 'Shared Feature'
%         Target_Fun=@(x) cgg_loadTargetArray(x,'SharedFeatureCoding',true);
%     case 'Previous Correct Shared'
%         Target_Fun_Previous=@(x) cgg_loadTargetArray(x,'PreviousTrialCorrect',true);
%         Target_Fun_Correct=@(x) cgg_loadTargetArray(x,'CorrectTrial',true);
%         Target_Fun_Shared=@(x) cgg_loadTargetArray(x,'Dimension',Dimension);
%         Target_Fun=@(x) [Target_Fun_Previous(x), Target_Fun_Correct(x), Target_Fun_Shared(x)];
%     case 'Correct'
%         Target_Fun=@(x) cgg_loadTargetArray(x,'CorrectTrial',true);
%     case 'Prediction Error'
%         Target_Fun=@(x) mean(cgg_loadTargetArray(x,'PredictionError',true));
% 
% end

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

InFunction=@(x,y) cgg_procRegressionValues(x,y,MatchArray,InIncrement,Probe_Order,VariableInformation,InSavePathNameExt);

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

PlotInformation.CoefficientNames = CoefficientNames;

%%

if WantPlotCorrelationSignificance
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = false;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCorrelationSignificanceDifference
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = true;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCorrelationValues
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = false;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotSignificantCorrelationValues
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = false;
    PlotInformation.WantSignificant = true;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotModelSignificance
    PlotInformation.PlotVariable = 'Model';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = false;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCoefficientProportionPositiveNegative
    PlotInformation.PlotVariable = 'Coefficient';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCoefficient
    PlotInformation.PlotVariable = 'Coefficient';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = false;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = false;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCoefficientSignificant
    PlotInformation.PlotVariable = 'Coefficient';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = false;
    PlotInformation.WantSignificant = true;
    PlotInformation.WantSplitPositiveNegative = false;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCorrelationProportionPositiveNegative
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Line';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = false;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end

end

%%

if WantPlotCorrelationProportionPositiveNegativeHistogram
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Bar';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = true;
    PlotInformation.TimeSelection = TimeSelection;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end
PlotInformation = rmfield(PlotInformation,'TimeSelection');
end

%%

if WantPlotCorrProportionPositiveNegativeHistogramNeighborhood
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Swarm';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = true;
    PlotInformation.TimeSelection = TimeSelection;
    PlotInformation.NeighborhoodSize = NeighborhoodSize;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end
PlotInformation = rmfield(PlotInformation,'TimeSelection');
PlotInformation = rmfield(PlotInformation,'NeighborhoodSize');
end

%%

if WantPlotCorrProportionPositiveNegativeHistogramNeighborhood
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Scatter';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = true;
    % PlotInformation.WantCoverage = true;
    % PlotInformation.WantScatter = true;
    PlotInformation.TimeSelection = TimeSelection;
    PlotInformation.NeighborhoodSize = NeighborhoodSize;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end
PlotInformation = rmfield(PlotInformation,'TimeSelection');
PlotInformation = rmfield(PlotInformation,'NeighborhoodSize');
end

%%

if WantPlotCorrProportionPositiveNegativeHistogramNeighborhood
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Histogram';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = true;
    % PlotInformation.WantCoverage = true;
    % PlotInformation.WantScatter = true;
    PlotInformation.TimeSelection = TimeSelection;
    PlotInformation.NeighborhoodSize = NeighborhoodSize;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end
PlotInformation = rmfield(PlotInformation,'TimeSelection');
PlotInformation = rmfield(PlotInformation,'NeighborhoodSize');
end

%%

if WantPlotCorrProportionPositiveNegativeHistogramNeighborhood
    PlotInformation.PlotVariable = 'Correlation';
    PlotInformation.PlotType = 'Bar';
    PlotInformation.WantProportionSignificant = true;
    PlotInformation.WantSignificant = false;
    PlotInformation.WantSplitPositiveNegative = true;
    PlotInformation.WantDifference = false;
    % PlotInformation.WantBar = true;
    % PlotInformation.WantCoverage = true;
    % PlotInformation.WantScatter = true;
    PlotInformation.TimeSelection = TimeSelection;
    PlotInformation.NeighborhoodSize = NeighborhoodSize;
    PlotInformation.WantCoverage = true;

    PlotSubFolder = cgg_constructPlotFolderName(PlotInformation);

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc = @(x,y) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg,'AdditionalTerm',y);
        cgg_plotAllMonkeyPlotWrapper(PlotFunc,this_InputTable);
    end
PlotInformation = rmfield(PlotInformation,'TimeSelection');
PlotInformation = rmfield(PlotInformation,'WantCoverage');
PlotInformation = rmfield(PlotInformation,'NeighborhoodSize');
end

%%

if WantPlotMultiPlot
    PlotInformation_1 = PlotInformation;
    PlotInformation_1.PlotVariable = 'Correlation';
    PlotInformation_1.PlotType = 'Line';
    PlotInformation_1.WantProportionSignificant = true;
    PlotInformation_1.WantSignificant = false;
    PlotInformation_1.WantSplitPositiveNegative = true;
    PlotInformation_1.WantDifference = false;
    PlotInformation_1.WantBar = false;

    PlotInformation_2 = PlotInformation;
    PlotInformation_2.PlotVariable = 'Correlation';
    PlotInformation_2.PlotType = 'Line';
    PlotInformation_2.WantProportionSignificant = false;
    PlotInformation_2.WantSignificant = true;
    PlotInformation_2.WantSplitPositiveNegative = true;
    PlotInformation_2.WantDifference = false;
    PlotInformation_2.WantBar = false;

    PlotSubFolder = 'Multi-Plot';

cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder',PlotFolder,...
    'PlotSubFolder',PlotSubFolder,'PlotSubSubFolder',VariablePlotFolder);
cfg_Save.ResultsDir=cfg_Results.TargetDir;

this_Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.PlotFolder.SubFolder_1.SubSubFolder_1;

    for acidx=1:length(AreaNameCheck)
        this_AreaNameCheck=AreaNameCheck{acidx};
        this_InputTable=InputTable{acidx};
        % cgg_plotVariableToData_v2(this_InputTable,SignificanceValue,this_AreaNameCheck,PlotInformation,this_Plotcfg);
        PlotFunc_1 = @(x,y,z) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation_1,'','AdditionalTerm',y,'InFigure',z);
        PlotFunc_2 = @(x,y,z) cgg_plotVariableToData_v2(x,SignificanceValue,this_AreaNameCheck,PlotInformation_2,this_Plotcfg,'AdditionalTerm',y,'InFigure',z);
        MultiplePlotFunc = @(x,y) cgg_plotMultiplePlotWrapper({PlotFunc_1,PlotFunc_2},x,y,wantPaperSized);
        cgg_plotAllMonkeyPlotWrapper(MultiplePlotFunc,this_InputTable);
    end
end

close all
end % End want Plot






%%

% NeighborhoodFunc = @(x) sum(x.ChannelNumbers);
% PlotDataFunc = @(x) cgg_getPlotDataForVariableToData(x,SignificanceValue,AreaName,PlotInformation);
% PlotValue_SingleFunc = @(x) squeeze(x.PlotValue_Single);
% NeighborhoodFunc = @(x) PlotValue_SingleFunc(PlotDataFunc(x));
% 
% OutputTable = cgg_addTableNeighborhoodColumn(InputTable,NeighborhoodSize,NeighborhoodFunc);