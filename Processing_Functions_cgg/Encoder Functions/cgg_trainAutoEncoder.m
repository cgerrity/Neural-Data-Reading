function cgg_trainAutoEncoder(InDataStore,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,Encoding_Dir)
%CGG_TRAINAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsBase=cfg_Encoder.NumEpochsBase;
miniBatchSize=cfg_Encoder.miniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
NumEpochsSession=cfg_Encoder.NumEpochsSession;

NumEpochsBase=1;
NumEpochsSession=1;
NumEpochsFinal=500;


%%

Values_Examples=read(InDataStore);

Example_Data=Values_Examples{1};
Example_Target=Values_Examples{1};

InputSize=size(Example_Data);

DataSize=InputSize(1:3);
NumWindows=1;
if length(InputSize)>3
NumWindows=InputSize(4);
end

%%

SessionNames=unique(SessionsList);
NumSessions=length(SessionNames);

%%

DataFormat_AutoEncoder={'SSCTB','SSCTB'};
DataFormat_Reshape='SSCTB';
if NumWindows==1
DataFormat_AutoEncoder={'SSCBT','SSCBT'};
end
LossType_AutoEncoder='Regression';

%% Base AutoEncoder

BaseSavePathNameExt=[Encoding_Dir filesep 'AutoEncoder_Base' ExtraSaveTerm '.mat'];

if isfile(BaseSavePathNameExt)
    m_NetBase=matfile(BaseSavePathNameExt,"Writable",false);
    NetBase=m_NetBase.Encoder;
else

[~,Layers_Custom] = cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);

InputNet= initialize(Layers_Custom);

DataStoreBase=combine(InDataStore.UnderlyingDatastores{1},InDataStore.UnderlyingDatastores{1});
DataStore_Testing_Base=combine(DataStore_Testing.UnderlyingDatastores{1},DataStore_Testing.UnderlyingDatastores{1});

DataStoreTrain=DataStoreBase;
DataStoreTest=DataStore_Testing_Base;
DataFormat=DataFormat_AutoEncoder;
NumEpochs=NumEpochsBase;
LossType=LossType_AutoEncoder;

[NetBase] = cgg_trainCustomTrainingParallel(InputNet,DataStoreTrain,DataStoreTest,DataFormat,NumEpochs,miniBatchSize,GradientThreshold,LossType);

BaseSaveVariables={NetBase};
BaseSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(BaseSaveVariables,BaseSaveVariablesName,BaseSavePathNameExt);
end

%% TESTING

[~,Layers_Custom] = cgg_generateLayersForAutoEncoder(DataSize,[10,6],NumWindows,DataFormat_Reshape);

InputNet= initialize(Layers_Custom);

TEST_Sampling=cgg_samplingLayer("Name",'SamplingLayer');

Layer_Test=9;

if ~strcmp(Layer_Test,'None')
InputNet_TEST = initialize(removeLayers(InputNet,{InputNet.Layers(Layer_Test:end).Name}));
else
InputNet_TEST = initialize(InputNet);
end

InputNet_TEST = replaceLayer(InputNet_TEST,'fc_Decoder_2',TEST_Sampling);

InputNet_TEST=initialize(InputNet_TEST);

MiniBatch_TEST = minibatchqueue(DataStoreBase,...
        MiniBatchSize=2,...
        MiniBatchFormat=DataFormat_AutoEncoder);

[X_TEST,T_TEST] = next(MiniBatch_TEST);

[Output_TEST_Z,Output_TEST_mu,Output_TEST_sig]=forward(InputNet_TEST,X_TEST);

size(Output_TEST_Z)
size(Output_TEST_mu)
size(Output_TEST_sig)
% 
% disp(sum(cgg_extractData(isnan(Output_TEST)),"all"))

%% Session Specific AutoEncoder

for seidx=1:NumSessions

    this_SessionName=SessionNames{seidx};

    SessionSavePathNameExt=[Encoding_Dir filesep 'AutoEncoder_Session' '_' this_SessionName ExtraSaveTerm '.mat'];

if isfile(SessionSavePathNameExt)
    m_NetSession=matfile(SessionSavePathNameExt,"Writable",false);
    NetSession=m_NetSession.Encoder;
else
    InputNetSession=NetBase;
    SessionIndices=strcmp(SessionsList,this_SessionName);
    DataStoreSession=subset(DataStoreBase,SessionIndices);

    DataStore_Testing_Session=DataStore_Testing_Base;

[NetSession] = cgg_trainCustomTrainingParallel(InputNetSession,DataStoreSession,DataStore_Testing_Session,DataFormat_AutoEncoder,NumEpochsSession,miniBatchSize,GradientThreshold,LossType_AutoEncoder);

SessionSaveVariables={NetSession};
SessionSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(SessionSaveVariables,SessionSaveVariablesName,SessionSavePathNameExt);
end

EncoderSessionSavePathNameExt=[Encoding_Dir filesep 'Encoder_Session' '_' this_SessionName ExtraSaveTerm '.mat'];

if isfile(EncoderSessionSavePathNameExt)

    m_NetEncoder=matfile(EncoderSessionSavePathNameExt,"Writable",false);
    EncoderSession=m_NetEncoder.Encoder;

else
EncoderSession = cgg_getEncoderFromAutoEncoder(NetSession);

EncoderSessionSaveVariables={EncoderSession};
EncoderSessionSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(EncoderSessionSaveVariables,EncoderSessionSaveVariablesName,EncoderSessionSavePathNameExt);
end

end

%% 

[ClassNames,NumClasses] = cgg_getClassesFromDataStore(InDataStore);

TuningSavePathNameExt=sprintf([Encoding_Dir filesep 'Tuning' ExtraSaveTerm '.mat']);

if ~isfile(TuningSavePathNameExt)
    LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses);
    
    TuningSaveVariables={LayerGraph_Tuning,ClassNames};
    TuningSaveVariablesName={'Encoder','ClassNames'};
    cgg_saveVariableUsingMatfile(TuningSaveVariables,TuningSaveVariablesName,TuningSavePathNameExt);
else
    m_Tuning=matfile(TuningSavePathNameExt,"Writable",false);
    LayerGraph_Tuning=m_Tuning.Encoder;
end

%% Testing

% NetFullTuning = cgg_getTuningNetFromAutoEncoder(EncoderSession,LayerGraph_Tuning);
% 
% MiniBatch_TEST = minibatchqueue(InDataStore,...
%         MiniBatchSize=20,...
%         MiniBatchFormat={'SSCTB','CBT'});
% 
% [X_TEST,T_TEST] = next(MiniBatch_TEST);
% 
% Output_TEST=cell(4,1);
% 
% [Output_TEST{1:4},state]=forward(NetFullTuning,X_TEST,Outputs=["softmax_Tuning_Dim_1" "softmax_Tuning_Dim_2" "softmax_Tuning_Dim_3" "softmax_Tuning_Dim_4"]);

%% Combined Classifiers

DataFormat={DataFormat_AutoEncoder{1},'CBT'};
% InDataStore=DataStore_Classifier_Batch_1;
NetFullTuning = cgg_getTuningNetFromAutoEncoder(EncoderSession,LayerGraph_Tuning);

Layer_Names_All={NetFullTuning.Layers(:).Name};
Layer_Output_IDX=contains(Layer_Names_All,'softmax');
Layer_Names_Output=Layer_Names_All(Layer_Output_IDX);

Layer_Names=NetFullTuning.Learnables.Layer;
Layer_Parameters=NetFullTuning.Learnables.Parameter;

Layer_Encoder_IDX=contains(Layer_Names,'Encoder');

Layer_Names_Encoder=Layer_Names(Layer_Encoder_IDX);
Layer_Parameters_Encoder=Layer_Parameters(Layer_Encoder_IDX);

NumParameters=length(Layer_Names_Encoder);

%%

LearningRateFactor=0;

for pidx=1:NumParameters
NetFullTuning = setLearnRateFactor(NetFullTuning,Layer_Names_Encoder(pidx),Layer_Parameters_Encoder(pidx),LearningRateFactor);
end

%%

OutputNames=string(Layer_Names_Output);

InputNet=NetFullTuning;
LossType='Classification';

FullTuningSavePathNameExt=sprintf([Encoding_Dir filesep 'FullTuning' ExtraSaveTerm '.mat']);

%%

if isfile(FullTuningSavePathNameExt)
    m_NetFullTuning=matfile(FullTuningSavePathNameExt,"Writable",false);
    NetFullTuning=m_NetFullTuning.Encoder;
else
% GradientThreshold=0.1;
[NetFullTuning] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochsSession,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames);

FullTuningSaveVariables={NetFullTuning};
FullTuningSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(FullTuningSaveVariables,FullTuningSaveVariablesName,FullTuningSavePathNameExt);
end

%%

LearningRateFactor=1;

for pidx=1:NumParameters
NetFullTuning = setLearnRateFactor(NetFullTuning,Layer_Names_Encoder(pidx),Layer_Parameters_Encoder(pidx),LearningRateFactor);
end

FinalSavePathNameExt=sprintf([Encoding_Dir filesep 'FinalNet' ExtraSaveTerm '.mat']);

if isfile(FinalSavePathNameExt)
    m_NetFinal=matfile(FinalSavePathNameExt,"Writable",false);
    NetFinal=m_NetFinal.Encoder;
else

    InputNet=NetFullTuning;

[NetFinal] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochsFinal,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames);

FinalSaveVariables={NetFinal};
FinalSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(FinalSaveVariables,FinalSaveVariablesName,FinalSavePathNameExt);
end

end

