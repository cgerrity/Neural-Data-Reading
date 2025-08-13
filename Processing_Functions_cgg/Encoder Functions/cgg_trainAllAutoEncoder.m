function cgg_trainAllAutoEncoder(InDataStore,DataStore_Validation,DataStore_Testing,SessionsList,cfg_Encoder,ExtraSaveTerm,cfg_Network,varargin)
%CGG_TRAINALLAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
PCAInformation = CheckVararginPairs('PCAInformation', [], varargin{:});
else
if ~(exist('PCAInformation','var'))
PCAInformation=[];
end
end

HiddenSizes=cfg_Encoder.HiddenSizes;
NumEpochsBase=cfg_Encoder.NumEpochsBase;
NumEpochsAutoEncoder = cfg_Encoder.NumEpochsAutoEncoder;
MiniBatchSize=cfg_Encoder.MiniBatchSize;
GradientThreshold=cfg_Encoder.GradientThreshold;
NumEpochsSession=cfg_Encoder.NumEpochsSession;
InitialLearningRate=cfg_Encoder.InitialLearningRate;
ModelName=cfg_Encoder.ModelName;
LossFactorReconstruction=cfg_Encoder.LossFactorReconstruction;
LossFactorKL=cfg_Encoder.LossFactorKL;
RescaleLossEpoch = cfg_Encoder.RescaleLossEpoch;
WeightedLoss = cfg_Encoder.WeightedLoss;
ClassifierName = cfg_Encoder.ClassifierName;
ClassifierHiddenSize = cfg_Encoder.ClassifierHiddenSize;
Optimizer = cfg_Encoder.Optimizer;

Time_Start=cfg_Encoder.Time_Start;
DataWidth=cfg_Encoder.DataWidth;
WindowStride=cfg_Encoder.WindowStride;
SamplingRate=cfg_Encoder.SamplingRate;

IsQuaddle=cfg_Encoder.IsQuaddle;

MatchType_Accuracy_Measure = cfg_Encoder.MatchType_Accuracy_Measure;

WantSaveNet = cfg_Encoder.WantSaveNet;

% NumEpochsSession=1;
NumEpochsFinal=NumEpochsSession;
LossType='Classification';

DataStore_Training=InDataStore;
ValidationFrequency=2;

%% Directories

Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderInformation');
% AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoder');

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

DataFormat{3} = '';
DataFormat_AutoEncoder{3} = '';

%%

WindowMonitor_Full = cgg_generateFullAccuracyProgressMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate);
WindowMonitor_Full_Accuracy_Measure = cgg_generateFullAccuracyProgressMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate,'SaveTerm',MatchType_Accuracy_Measure);

ReconstructionMonitor = cgg_generateFullReconstructionAndClassificationMonitor('SaveDir',Encoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate,'NumDimensions',length(ClassNames));
ReconstructionMonitor_AutoEncoder = cgg_generateFullReconstructionAndClassificationMonitor('SaveDir',AutoEncoding_Dir,'Time_Start',Time_Start,'DataWidth',DataWidth/SamplingRate,'WindowStride',WindowStride/SamplingRate,'NumWindows',NumWindows,'SamplingRate',SamplingRate,'NumDimensions',0);

GradientMonitor_Full = cgg_generateGradientMonitor('SaveDir',Encoding_Dir);
GradientMonitor_AutoEncoder = cgg_generateGradientMonitor('SaveDir',AutoEncoding_Dir);
%%

AutoEncoderSavePathNameExt = [AutoEncoding_Dir filesep 'AutoEncoder.mat'];

% FinalSavePathNameExt=sprintf([Encoding_Dir filesep 'VariationalFinalNet' ExtraSaveTerm '.mat']);
FinalSavePathNameExt = [Encoding_Dir filesep 'FinalNet.mat'];
% FinalSavePathNameExt = [Encoding_Dir filesep 'FullNetwork.mat'];
%%
if isfile(FinalSavePathNameExt)
    m_NetFinal=matfile(FinalSavePathNameExt,"Writable",false);
    NetFinal=m_NetFinal.Network;
else

if ~isfile(AutoEncoderSavePathNameExt)
    Layers_Custom = cgg_selectAutoEncoder(ModelName,DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    NetAutoEncoder= initialize(Layers_Custom);
    
%% Train AutoEncoder

    NetAutoEncoder = cgg_trainNetworkParallel(NetAutoEncoder,DataStore_Training,...
        DataStore_Validation,DataStore_Testing,...
        'GradientThreshold', GradientThreshold,'NumEpochs', NumEpochsAutoEncoder,...
        'ValidationFrequency', ValidationFrequency,...
        'MiniBatchSize', MiniBatchSize,'DataFormat', DataFormat,...
        'InitialLearningRate',InitialLearningRate,...
        'SaveDirPlot',AutoEncoding_Dir,...
        'LossFactorReconstruction',LossFactorReconstruction,...
        'LossFactorKL',LossFactorKL,...
        'WeightedLoss',WeightedLoss,...
        'GradientMonitor',GradientMonitor_AutoEncoder,...
        'MatchType_Accuracy_Measure',MatchType_Accuracy_Measure,...
        'WantSaveNet',WantSaveNet,'Optimizer',Optimizer,...
        'ReconstructionMonitor',ReconstructionMonitor_AutoEncoder);

%%

AutoEncoderSaveVariables={NetAutoEncoder};
AutoEncoderSaveVariablesName={'AutoEncoder'};
cgg_saveVariableUsingMatfile(AutoEncoderSaveVariables,AutoEncoderSaveVariablesName,AutoEncoderSavePathNameExt);
else
    m_AutoEncoder = matfile(AutoEncoderSavePathNameExt,"Writable",false);
    NetAutoEncoder = m_AutoEncoder.AutoEncoder;
end

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
    % Layers_Custom = cgg_selectAutoEncoder(ModelName,DataSize,HiddenSizes,NumWindows,DataFormat_Reshape);
    % NetAutoEncoder= initialize(Layers_Custom);

%%

    % NetFullTuning = cgg_getTuningNetFromFullVariationalAutoEncoder(NetBase,LayerGraph_Tuning);
    NetFull = cgg_constructClassifierNetwork_v2(NetAutoEncoder,Layers_Classifier);
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
        'WeightedLoss',WeightedLoss,'WindowMonitor',WindowMonitor_Full,...
        'ReconstructionMonitor',ReconstructionMonitor,...
        'GradientMonitor',GradientMonitor_Full,...
        'MatchType_Accuracy_Measure',MatchType_Accuracy_Measure,...
        'WindowMonitor_Accuracy_Measure',WindowMonitor_Full_Accuracy_Measure,...
        'WantSaveNet',WantSaveNet,'Optimizer',Optimizer,...
        'RescaleLossEpoch',RescaleLossEpoch);

% [NetFinal] = cgg_trainCustomTrainingParallelMultipleOutput(InputNet,InDataStore,DataStore_Testing,DataFormat,NumEpochsFinal,miniBatchSize,GradientThreshold,LossType,OutputNames,ClassNames);

FinalSaveVariables={NetFinal};
FinalSaveVariablesName={'Network'};
cgg_saveVariableUsingMatfile(FinalSaveVariables,FinalSaveVariablesName,FinalSavePathNameExt);
end

%%

% cgg_saveCMTableFromNetwork(DataStore_Testing,NetFinal,ClassNames,Encoding_Dir);

end
