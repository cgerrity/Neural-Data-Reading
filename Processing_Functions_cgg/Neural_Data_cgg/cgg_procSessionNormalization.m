function cgg_procSessionNormalization(Epoch,inputfolder,outdatadir)
%CGG_PROCSESSIONNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here

[cfg_epoch] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir,'Data_Normalized',true);

DataDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data.path;
DataNormalizedDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Data_Normalized.path;
TargetDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
ProcessingDir=cfg_epoch.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing.path;

%%

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

ProbeProcessing=matfile(ProbeProcessingPathNameExt,"Writable",false);
ProbeProcessing=ProbeProcessing.ProbeProcessing;

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;

Recorded_Areas=find(any(cell2mat(cellfun(@(x) strcmp(Probe_Order,x),fieldnames(ProbeProcessing),'UniformOutput',false)),1));

Data_All_Cell=gather(tall(Data_ds));

%%

[NumChannels,NumSamples,NumAreas]=size(Data_All_Cell{1});
NumTrials=length(Data_All_Cell);

Data_Mean=NaN(NumChannels,1,NumAreas);
Data_STD=NaN(NumChannels,1,NumAreas);

% Data_All=NaN([NumChannels,NumSamples,NumAreas,NumTrials]);
% Data_All=zeros([NumChannels,NumSamples*NumTrials,NumAreas]);

for aidx=1:NumAreas
    this_Data_All=zeros([NumChannels,NumSamples*NumTrials,1]);

for idx=1:NumTrials
    this_sampleIDXStart=NumSamples*(idx-1)+1;
    this_sampleIDXEnd=this_sampleIDXStart+NumSamples-1;
    this_sampleIndices=this_sampleIDXStart:this_sampleIDXEnd;
%     Data_All(:,:,:,idx)=Data_All_Cell{idx};
    this_Data_All(:,this_sampleIndices,:)=Data_All_Cell{idx}(:,:,aidx);
end

this_Data_Mean=mean(this_Data_All,2);
this_Data_STD=std(this_Data_All,[],2);

Data_Mean(:,:,aidx)=this_Data_Mean;
Data_STD(:,:,aidx)=this_Data_STD;

end
% Data_All=reshape(Data_All,NumChannels,[],NumAreas)

% Data_Mean=mean(Data_All,2);
% Data_STD=std(Data_All,[],2);

Data_Mean_Full=repmat(Data_Mean,1,NumSamples,1);
Data_STD_Full=repmat(Data_STD,1,NumSamples,1);

%%

Data_File_Names=Data_ds.Files;

parfor idx=1:NumTrials

    this_FileName=Data_File_Names{idx};
    
    [~,this_Name,this_Ext]=fileparts(this_FileName);

    m_Data=matfile(this_FileName,"Writable",false);
    this_Data=m_Data.Data;

    this_Data_Normalized=(this_Data-Data_Mean_Full)./Data_STD_Full;

    this_SavePathNameExt=[DataNormalizedDir filesep this_Name this_Ext];

    SaveVariables={this_Data_Normalized};
    SaveVariablesName={'Data'};

    cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,this_SavePathNameExt);

end


end

