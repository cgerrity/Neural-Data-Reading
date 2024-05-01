%% DATA_cggPercentExplainedVariance

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

Epoch='Decision';

FeatureDimensions = [1,2,3,5];

%%

outdatadir=cfg(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg(1).temporarydir;

% cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

cfg_Save = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'ExplainedVariance',true,'ExplainedVariance_Zoom',...
    {'High Zoom','Medium Zoom','Low Zoom'});
cfg_Results = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'ExplainedVariance',true,'ExplainedVariance_Zoom',...
    {'High Zoom','Medium Zoom','Low Zoom'});
cfg_Save.ResultsDir=cfg_Results.TargetDir;

Plotcfg=cfg_Save.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.ExplainedVariance;

%%

% for sidx=1:length(cfg)
    sidx=1;
    
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
Dimensions=[Target.SelectedObjectDimVals]';
Dimensions=Dimensions(:,FeatureDimensions);

[C,ia,GroupIDX] = unique(Dimensions(:,1),'rows');

ProbeProcessing=matfile(ProbeProcessingPathNameExt,"Writable",false);
ProbeProcessing=ProbeProcessing.ProbeProcessing;

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

Recorded_Areas=find(any(cell2mat(cellfun(@(x) strcmp(Probe_Order,x),fieldnames(ProbeProcessing),'UniformOutput',false)),1));

Data_All=gather(tall(Data_ds));

[NumChannels,NumSamples,NumAreas]=size(preview(Data_ds));

PEV=NaN(NumChannels,NumSamples,NumAreas);

Data_Fit_Size=size(Data_All{1});
NumTrials=length(Data_All);

Data_Fit=NaN([Data_Fit_Size(1:2),NumTrials]);

for sel_area=Recorded_Areas

% sel_area=5;

for idx=1:NumTrials
    Data_Fit(:,:,idx)=Data_All{idx}(:,:,sel_area);
end

MatchArray=Dimensions;
InIncrement=10;
InData=Data_Fit;

% InData(2,1,1)

[~,R_Value,~,~,R_Value_Adjusted]=cgg_procTrialVariableRegression(InData,MatchArray,InIncrement);

Time_Start=-1.5;
DataWidth=1/1000;
WindowStride=InIncrement/1000;
ZLimits=[0,0.2];

PlotTitle=sprintf('Session: %s, Area: %s',cfg(sidx).SessionName,Probe_Order{sel_area});

PlotTitle=replace(PlotTitle,'_','-');

[fig,~,~]=cgg_plotHeatMapOverTime(R_Value_Adjusted,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle);

PlotNameExt=sprintf('Explained_Variance_%s_%s_ESA.pdf',cfg(sidx).SessionName,Probe_Order{sel_area});
drawnow;

ZLimits=[0,0.2];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.Zoom_1.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[0,0.1];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.Zoom_2.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

ZLimits=[0,0.05];
clim([ZLimits(1),ZLimits(2)]);
drawnow;
PlotPath=Plotcfg.Zoom_3.path;
PlotPathNameExt=[PlotPath filesep PlotNameExt];
saveas(fig,PlotPathNameExt);

close all

% [fig,~,~]=cgg_plotHeatMapOverTime(R_Value_Adjusted,'Time_Start',Time_Start,'DataWidth',DataWidth,'WindowStride',WindowStride,'ZLimits',ZLimits,'PlotTitle',PlotTitle);
% 
% PlotNameExt=sprintf('Explained_Variance_Adjusted_%s_%s.pdf',cfg(sidx).SessionName,Probe_Order{sel_area});
% drawnow;
% 
% ZLimits=[0,0.2];
% clim([ZLimits(1),ZLimits(2)]);
% drawnow;
% PlotPath=Plotcfg.Zoom_1.path;
% PlotPathNameExt=[PlotPath filesep PlotNameExt];
% saveas(fig,PlotPathNameExt);
% 
% ZLimits=[0,0.1];
% clim([ZLimits(1),ZLimits(2)]);
% drawnow;
% PlotPath=Plotcfg.Zoom_2.path;
% PlotPathNameExt=[PlotPath filesep PlotNameExt];
% saveas(fig,PlotPathNameExt);
% 
% ZLimits=[0,0.05];
% clim([ZLimits(1),ZLimits(2)]);
% drawnow;
% PlotPath=Plotcfg.Zoom_3.path;
% PlotPathNameExt=[PlotPath filesep PlotNameExt];
% saveas(fig,PlotPathNameExt);
% 
% close all

% ind = sub2ind([NumChannels,NumSamples,NumAreas],I1,I2,I3)
% [cidx,sidx,aidx] = ind2sub([NumChannels,NumSamples,NumAreas],ind);
end
% end


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







