function cgg_trainAllAutoEncoder(InDataStore,DataStore_Validation,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,Encoding_Dir)
%CGG_TRAINALLAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsBase=cfg_Encoder.NumEpochsBase;
MiniBatchSize=cfg_Encoder.MiniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
NumEpochsSession=cfg_Encoder.NumEpochsSession;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName=cfg_Encoder.ModelName;
LossFactorReconstruction=cfg_Encoder.LossFactorReconstruction;
LossFactorKL=cfg_Encoder.LossFactorKL;
WeightedLoss = cfg_Encoder.WeightedLoss;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;

Time_Start=cfg_Encoder.Time_Start;
DataWidth=cfg_Encoder.DataWidth;
WindowStride=cfg_Encoder.WindowStride;
SamplingRate=cfg_Encoder.SamplingRate;

IsQuaddle=cfg_Encoder.IsQuaddle;

MatchType_Accuracy_Measure = cfg_Encoder.MatchType_Accuracy_Measure;

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
[ClassNames,NumClasses,~,~] = cgg_getClassesFromDataStore(InDataStore);
NumDimensions = length(ClassNames);
%%

DataFormat_AutoEncoder={'SSCTB','SSCTB'};
DataFormat_Reshape='SSCTB';
if NumWindows==1
DataFormat_AutoEncoder={'SSCBT','SSCBT'};
end
if NumDimensions > 1
DataFormat={DataFormat_AutoEncoder{1},'CBT'};
else
% DataFormat={DataFormat_AutoEncoder{1},'BTC'};
DataFormat={DataFormat_AutoEncoder{1},'BCT'};
end

%%

WindowMonitor = cgg_generateFullAccuracyProgressMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate);
WindowMonitor_Accuracy_Measure = cgg_generateFullAccuracyProgressMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate,'SaveTerm',MatchType_Accuracy_Measure);

ReconstructionMonitor = cgg_generateFullReconstructionAndClassificationMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate,'NumDimensions',length(ClassNames));

GradientMonitor = cgg_generateGradientMonitor('SaveDir',Encoding_Dir);
%%

% FinalSavePathNameExt=sprintf([Encoding_Dir filesep 'VariationalFinalNet' ExtraSaveTerm '.mat']);
FinalSavePathNameExt = [Encoding_Dir filesep 'FinalNet.mat'];

if isfile(FinalSavePathNameExt)
    m_NetFinal=matfile(FinalSavePathNameExt,"Writable",false);
    NetFinal=m_NetFinal.Encoder;
else

% TuningSavePathNameExt=sprintf([Encoding_Dir filesep 'VariationalTuning' ExtraSaveTerm '.mat']);
ClassifierSavePathNameExt = [Encoding_Dir filesep 'Classifier.mat'];

% if ~isfile(TuningSavePathNameExt)
if ~isfile(ClassifierSavePathNameExt)
    
%     LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses);
    % LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses,'LossType',LossType);
    Layers_Classifier = cgg_selectClassifier(ClassifierName,NumClasses,LossType,'ClassifierHiddenSize',ClassifierHiddenSize);

    ClassifierSaveVariables = {Layers_Classifier,ClassNames};
    ClassifierSaveVariablesName = {'Classifier','ClassNames'};
    cgg_saveVariableUsingMatfile(ClassifierSaveVariables,ClassifierSaveVariablesName,ClassifierSavePathNameExt);

    % TuningSaveVariables={LayerGraph_Tuning,ClassNames};
    % TuningSaveVariablesName={'Encoder','ClassNames'};
    % cgg_saveVariableUsingMatfile(TuningSaveVariables,TuningSaveVariablesName,TuningSavePathNameExt);
else
    % m_Tuning=matfile(TuningSavePathNameExt,"Writable",false);
    % LayerGraph_Tuning=m_Tuning.Encoder;
    m_Classifier = matfile(ClassifierSavePathNameExt,"Writable",false);
    Layers_Classifier = m_Classifier.Classifier;
end

    %%
%     [~,Layers_Custom] = cgg_generateLayersForVariationalAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForVariationalAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
%     [~,Layers_Custom]=cgg_generateLayersForAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    % Layers_Custom = cgg_generateLayersForReccurentEncoder(DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    Layers_Custom = cgg_selectAutoEncoder(ModelName,DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    NetBase= initialize(Layers_Custom);

%%

    % NetFullTuning = cgg_getTuningNetFromFullVariationalAutoEncoder(NetBase,LayerGraph_Tuning);
    NetFull = cgg_constructClassifierNetwork_v2(NetBase,Layers_Classifier);
%     NetFullTuning = NetBase;

    Layer_Names_All={NetFull.Layers(:).Name};
    Layer_Output_IDX=contains(Layer_Names_All,'softmax');
    Layer_Names_Output=Layer_Names_All(Layer_Output_IDX);
    OutputNames=string(Layer_Names_Output);

    % InputNet=NetFullTuning;
    InputNet = NetFull;

    DataStore_Training=InDataStore;
    MatchType='combinedaccuracy';
    NumEpochs=NumEpochsFinal;
    ValidationFrequency=5;
    
    %%
    NetFinal = cgg_trainNetworkParallel(InputNet,DataStore_Training,...
        DataStore_Validation,DataStore_Testing,'MatchType', MatchType,'IsQuaddle', IsQuaddle,...
        'GradientThreshold', GradientThreshold,'NumEpochs', NumEpochs,...
        'ValidationFrequency', ValidationFrequency,...
        'MiniBatchSize', MiniBatchSize,'DataFormat', DataFormat,...
        'InitialLearningRate',InitialLearningRate,...
        'SaveDirPlot',Encoding_Dir,...
        'LossFactorReconstruction',LossFactorReconstruction,...
        'LossFactorKL',LossFactorKL,...
        'WeightedLoss',WeightedLoss,'WindowMonitor',WindowMonitor,...
        'ReconstructionMonitor',ReconstructionMonitor,...
        'GradientMonitor',GradientMonitor,...
        'MatchType_Accuracy_Measure',MatchType_Accuracy_Measure,...
        'WindowMonitor_Accuracy_Measure',WindowMonitor_Accuracy_Measure);

% [NetFinal] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochsFinal,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames);

FinalSaveVariables={NetFinal};
FinalSaveVariablesName={'Encoder'};
cgg_saveVariableUsingMatfile(FinalSaveVariables,FinalSaveVariablesName,FinalSavePathNameExt);
end

end
