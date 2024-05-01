function cgg_plotTrialActivityAllChannels(Epoch,cfg)
%CGG_PLOTTRIALACTIVITYALLCHANNELS Summary of this function goes here
%   Detailed explanation goes here


cfg_PreProcessing = PARAMETERS_cgg_proc_NeuralDataPreparation('SessionName','none');
cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

SamplingFrequency = cfg_PreProcessing.rect_samprate;

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
    Time_End = cfg_Processing.Window_After_Data;
else
    Time_Start = 0;
    Time_End = '';
end

%% Parameters

inputfolder=cfg.inputfolder;
outdatadir=cfg.outdatadir;
% TargetDir=outdatadir;
% ResultsDir=cfg.temporarydir;

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir);

DataPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data.path;
ProcessingPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing.path;

%%

DataStruct=dir(DataPath);
DataStruct([DataStruct.isdir]==1)=[];
NumTrials=length(DataStruct);

ProcessingPathNameExt=[ProcessingPath filesep 'Probe_Processing_Information.mat'];

m_ProbeProcessing=matfile(ProcessingPathNameExt,"Writable",false);
ProbeProcessing=m_ProbeProcessing.ProbeProcessing;

%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

ProbeAreas=fieldnames(ProbeProcessing);

fig_plot='';


for tidx=1:NumTrials

    DataPathNameExt=[DataStruct(tidx).folder filesep DataStruct(tidx).name]; 
    m_Data=matfile(DataPathNameExt,"Writable",false);
    Data=m_Data.Data;

for aidx=1:length(ProbeAreas)

this_Area=ProbeAreas{aidx};

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir,'AreaPlot',this_Area);

PlotPath=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Plots.AreaPlot.path;

this_AreaIDX=strcmp(Probe_Order,this_Area);

this_DataArea=Data(:,:,this_AreaIDX);
InData=this_DataArea;

%%

SamplingRate=SamplingFrequency;


DataWidth=0;
WindowStride=1/SamplingRate;


X_Name='Time (s)';
Y_Name='Channels';
PlotTitle='Activity';
wantDecisionIndicators=true;
RangeCompressionFactor=0.25;

PriorFigure=fig_plot;

[fig_plot,~] = cgg_plotMultipleSignals(InData,'Time_Start',...
    Time_Start,'Time_End',Time_End,'SamplingRate',SamplingRate,...
    'DataWidth',DataWidth,'WindowStride',WindowStride,'X_Name',X_Name,...
    'Y_Name',Y_Name,'PlotTitle',PlotTitle,...
    'wantDecisionIndicators',wantDecisionIndicators,...
    'RangeCompressionFactor',RangeCompressionFactor,...
    'PriorFigure',PriorFigure);
drawnow;

%%

[FileNumber,NumberWidth] = cgg_getNumberFromFileName(DataStruct(tidx).name);

SaveName=sprintf('Trial_%%0%dd',NumberWidth);
SaveName=sprintf(SaveName,FileNumber);

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[PlotPath filesep SaveNameExt];

drawnow;

saveas(fig_plot,SavePathNameExt,'pdf');


end

end

close all

end

