

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';
sel_session_idx=23;
%%

% cgg_plotTrialActivityAllChannels(Epoch,cfg(sel_session_idx));


%% Parameters

inputfolder=cfg(sel_session_idx).inputfolder;
outdatadir=cfg(sel_session_idx).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg(sel_session_idx).temporarydir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir);

DataPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data.path;
TargetPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
ProcessingPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing.path;

%%

DataStruct=dir(DataPath);
DataStruct([DataStruct.isdir]==1)=[];
NumTrials=length(DataStruct);

TargetPathNameExt=[TargetPath filesep 'Target_Information.mat'];
ProcessingPathNameExt=[ProcessingPath filesep 'Probe_Processing_Information.mat'];

m_Target=matfile(TargetPathNameExt,"Writable",false);
Target=m_Target.Target;

m_ProbeProcessing=matfile(ProcessingPathNameExt,"Writable",false);
ProbeProcessing=m_ProbeProcessing.ProbeProcessing;

%%

Dimensions=[Target.SelectedObjectDimVals]';
Dimensions(:,4)=[];

CorrectTrial=[Target.CorrectTrial]';

sel_Dimension=2;
sel_Channels=9:16;

this_Dimension=Dimensions(:,sel_Dimension);

this_SplitValues=this_Dimension;

[this_SplitUnique,~,this_Split]=unique(this_SplitValues);


%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

ProbeAreas=fieldnames(ProbeProcessing);

fig_plot='';

% for tidx=1:NumTrials
% 
%     DataPathNameExt=[DataStruct(tidx).folder filesep DataStruct(tidx).name]; 
%     m_Data=matfile(DataPathNameExt,"Writable",false);
%     Data=m_Data.Data;

for aidx=1:length(ProbeAreas)

this_Area=ProbeAreas{aidx};

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir,'AreaPlot',this_Area);

PlotPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Plots.AreaPlot.path;

this_AreaIDX=strcmp(Probe_Order,this_Area);

% this_DataArea=Data(:,:,this_AreaIDX);
% InData=this_DataArea;

% NumTrials=100;
% this_Split=this_Split(1:NumTrials);
for tidx=1:NumTrials

DataPathNameExt=[DataStruct(tidx).folder filesep DataStruct(tidx).name]; 
m_Data=matfile(DataPathNameExt,"Writable",false);
Data=m_Data.Data;

% this_DataArea=Data(:,:,this_AreaIDX);
% InData=this_DataArea;
this_DataArea=Data(sel_Channels,:,this_AreaIDX);
if tidx==1
InData=NaN([size(this_DataArea), NumTrials]);
end
InData(:,:,tidx)=this_DataArea;
end

%%

InData_Cell=cell(1,length(this_SplitUnique));
for didx=1:length(this_SplitUnique)
    this_SplitIDX=this_Split==didx;
    this_SplitData=InData(:,:,this_SplitIDX);
InData_Cell{didx}=this_SplitData;
end

%%

Time_Start=-1.5;
Time_End=1.5;
SamplingRate=1000;
DataWidth=0;
WindowStride=1/1000;
X_Name='Time (s)';
Y_Name='Channels';
PlotTitle='Activity';
wantDecisionIndicators=true;
RangeCompressionFactor=0.02;

PriorFigure=fig_plot;

% PriorFigure='';
InData=InData_Cell;

[fig_plot,p_Plots] = cgg_plotMultipleSignals(InData,'Time_Start',...
    Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,...
    'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,...
    'Y_Name',Y_Name,'PlotTitle',PlotTitle,...
    'wantDecisionIndicators',wantDecisionIndicators,...
    'RangeCompressionFactor',RangeCompressionFactor,...
    'PriorFigure',PriorFigure);
drawnow;

%%
% 
% [FileNumber,NumberWidth] = cgg_getNumberFromFileName(DataStruct(tidx).name);
% 
% SaveName=sprintf('Trial_%%0%dd',NumberWidth);
% SaveName=sprintf(SaveName,FileNumber);

SaveName=sprintf('Channels_%d_%d',sel_Channels(1),sel_Channels(end));

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[PlotPath filesep SaveNameExt];

drawnow;

saveas(fig_plot,SavePathNameExt,'pdf');


end

% end





close all