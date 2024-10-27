%% TEST_CGG_SELECTNORMALIZATION

clc; clear; close all;

%%

Epoch = 'Decision';
Normalization = 'Channel - Z-Score - Global - MinMax - [0,1]';

%%

cfg_Session = DATA_cggAllSessionInformationConfiguration;

outdatadir=cfg_Session(1).outdatadir;
TargetDir=outdatadir;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,'Epoch',Epoch,'NormalizationInformation',true);

%%

DataDir = cgg_getDirectory(cfg,'Data');
TargetAggregateDir = cgg_getDirectory(cfg,'Target');
NormalizationInformationDir = ...
    cgg_getDirectory(cfg,'NormalizationInformation');

NormalizationInformationPathNameExt = [NormalizationInformationDir filesep 'NormalizationInformation.mat'];
DataHistogramPathNameExt = [NormalizationInformationDir filesep 'DataHistogram.mat'];

m_NormalizationInformation=matfile(NormalizationInformationPathNameExt,"Writable",false);
NormalizationInformation=m_NormalizationInformation.NormalizationInformation;

m_DataHistogram=matfile(DataHistogramPathNameExt,"Writable",true);
DataHistogram=m_DataHistogram.DataHistogram;
BinEdges=DataHistogram.BinEdges;

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

FileName_Fun = @(x) x;
Data_Fun=@(x) cgg_loadDataArray(x,DataWidth,StartingIDX,EndingIDX,WindowStride,ChannelRemoval,WantDisp,WantRandomize,WantNaNZeroed,Want1DVector);
TargetSession_Fun=@(x) cgg_loadTargetArray(x,'SessionName',true);
NormalizationTable_Fun = @(x) cgg_getNormalizationTableFromDataName(x);

FileName_ds = fileDatastore(DataDir,"ReadFcn",FileName_Fun);

%%

FileName_ds = shuffle(FileName_ds);

this_FileName = read(FileName_ds);

Data = Data_Fun(this_FileName);
NormalizationTable = NormalizationTable_Fun(this_FileName);

%%

figure;
DataNormalized = cgg_selectNormalization(Data,NormalizationTable,Normalization);
histogram(DataNormalized)
title('Not Zero Centered');

figure;
DataNormalized = cgg_selectNormalization(Data,NormalizationTable,[Normalization, ' - Zero Centered']);
histogram(DataNormalized)
title('Zero Centered');
disp(std(DataNormalized,[],"all","omitnan")*4)
