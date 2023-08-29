%% DATA_cggDecoderTesting

clc; clear; close all;

[cfg] = DATA_cggAllSessionInformationConfiguration;

%%

sidx=1;
inputfolder=cfg(sidx).inputfolder;
outdatadir=cfg(sidx).outdatadir;
SessionFolder=cfg(sidx).SessionFolder;
Epoch='Decision';
TargetDir=outdatadir;

[cfg_Decoder] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Epoch',Epoch);

% cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path

%%

DataAggregateDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Data.path;
TargetAggregateDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Target.path;
ProcessingDir=cfg_Decoder.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Processing.path;

TargetInformation_PathNameExt=[ProcessingDir filesep 'Target_Information.mat'];

DataAggregate_PathNameExt=[DataAggregateDir filesep ...
    Epoch '_Data_%d.mat'];
Target_PathNameExt=[TargetAggregateDir filesep ...
    Epoch 'Target_%d.mat'];

%%
existTargetInformation=isfile(TargetInformation_PathNameExt);

% If the aggregated target exists then load it 
if existTargetInformation
    m_TargetInformation = matfile(...
        TargetInformation_PathNameExt,'Writable',true);
    TargetInformation=m_TargetInformation.TargetInformation;
end

%%

% Create a datastore for .mat files in the folder

Dimension=3;

Data_ds = fileDatastore(DataAggregateDir,"ReadFcn",@cgg_loadDataArray);
Target_ds = fileDatastore(TargetAggregateDir,"ReadFcn",@(x) cgg_loadTargetArray(x,Dimension));

trainData=combine(Data_ds,Target_ds);

% % Set the ReadFcn to load the .mat files
% matFilesDatastore.ReadFcn = @(file) load(file);

%%
% 
% digitDatasetPath = fullfile(matlabroot,'toolbox','nnet', ...
%     'nndemos','nndatasets','DigitDataset');
% imds = imageDatastore(digitDatasetPath, ...
%     'IncludeSubfolders',true, ...
%     'LabelSource','foldernames');

%%

% NumData=100;
% 
% for didx=1:NumData
%     
%     this_Data=load(sprintf(DataAggregate_PathNameExt,didx));
%     this_Data=this_Data.Data;
%     
% end


%%
layers = [
    imageInputLayer([64 500 6],"Name","imageinput")
    fullyConnectedLayer(20,"Name","fc_1")
    reluLayer("Name","relu")
    fullyConnectedLayer(5,"Name","fc_2")
    softmaxLayer("Name","softmax")
    classificationLayer("Name","classoutput")];

options = trainingOptions('sgdm', ...
    'MaxEpochs',20,...
    'InitialLearnRate',1e-4, ...
    'Verbose',false, ...
    'Plots','training-progress');

net = trainNetwork(trainData,layers,options);
