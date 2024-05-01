function cgg_trainVariationalAutoEncoder_v2(InDataStore,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,Encoding_Dir)
%CGG_TRAINAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsBase=cfg_Encoder.NumEpochsBase;
miniBatchSize=cfg_Encoder.miniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
NumEpochsSession=cfg_Encoder.NumEpochsSession;
InitialLearningRate=cfg_Encoder.InitialLearningRate;

NumEpochsBase=1;
NumEpochsSession=1;
NumEpochsFinal=500;
LossType='Classification';


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

%%

FinalSavePathNameExt=sprintf([Encoding_Dir filesep 'VariationalFinalNet' ExtraSaveTerm '.mat']);

if isfile(FinalSavePathNameExt)
    m_NetFinal=matfile(FinalSavePathNameExt,"Writable",false);
    NetFinal=m_NetFinal.Encoder;
else

[ClassNames,NumClasses] = cgg_getClassesFromDataStore(InDataStore);

TuningSavePathNameExt=sprintf([Encoding_Dir filesep 'VariationalTuning' ExtraSaveTerm '.mat']);

if ~isfile(TuningSavePathNameExt)
%     LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses);
    LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses,'LossType',LossType);
    
    TuningSaveVariables={LayerGraph_Tuning,ClassNames};
    TuningSaveVariablesName={'Encoder','ClassNames'};
    cgg_saveVariableUsingMatfile(TuningSaveVariables,TuningSaveVariablesName,TuningSavePathNameExt);
else
    m_Tuning=matfile(TuningSavePathNameExt,"Writable",false);
    LayerGraph_Tuning=m_Tuning.Encoder;
end

    
%     [~,Layers_Custom] = cgg_generateLayersForVariationalAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForVariationalAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    Layers_Custom = cgg_generateLayersForReccurentEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    NetBase= initialize(Layers_Custom);

    NetFullTuning = cgg_getTuningNetFromFullVariationalAutoEncoder(NetBase,LayerGraph_Tuning);
%     NetFullTuning = NetBase;

    Layer_Names_All={NetFullTuning.Layers(:).Name};
    Layer_Output_IDX=contains(Layer_Names_All,'softmax');
    Layer_Names_Output=Layer_Names_All(Layer_Output_IDX);
    OutputNames=string(Layer_Names_Output);

    InputNet=NetFullTuning;

    LossType='Classification';
    DataFormat={DataFormat_AutoEncoder{1},'CBT'};

    DataStore_Training=InDataStore;
    MatchType='combinedaccuracy';
    IsQuaddle=true;
    NumEpochs=NumEpochsFinal;
    ValidationFrequency=20;
    MiniBatchSize=miniBatchSize;

    NetFinal = cgg_trainNetworkParallel(InputNet,DataStore_Training,...
        DataStore_Testing,'MatchType', MatchType,'IsQuaddle', IsQuaddle,...
        'GradientThreshold', GradientThreshold,'NumEpochs', NumEpochs,...
        'ValidationFrequency', ValidationFrequency,...
        'MiniBatchSize', MiniBatchSize,'DataFormat', DataFormat,...
        'InitialLearnngRate',InitialLearningRate,'SaveDirPlot',Encoding_Dir);

% [NetFinal] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochsFinal,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames);

FinalSaveVariables={NetFinal};
FinalSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(FinalSaveVariables,FinalSaveVariablesName,FinalSavePathNameExt);
end

end

