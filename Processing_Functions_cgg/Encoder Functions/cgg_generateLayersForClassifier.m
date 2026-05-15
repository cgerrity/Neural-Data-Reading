function Layers_Classifier = cgg_generateLayersForClassifier(NumClasses,varargin)
%CGG_GENERATELAYERSFORTUNINGNET Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
LossType = CheckVararginPairs('LossType', 'Classification', varargin{:});
else
if ~(exist('LossType','var'))
LossType='Classification';
end
end

if isfunction
ClassifierHiddenSize = CheckVararginPairs('ClassifierHiddenSize', 1, varargin{:});
else
if ~(exist('ClassifierHiddenSize','var'))
ClassifierHiddenSize=1;
end
end

if isfunction
DropoutPercent = CheckVararginPairs('DropoutPercent', 0, varargin{:});
else
if ~(exist('DropoutPercent','var'))
DropoutPercent=0;
end
end

if isfunction
NetworkType = CheckVararginPairs('NetworkType', 'LSTM', varargin{:});
else
if ~(exist('NetworkType','var'))
NetworkType='LSTM';
end
end

if isfunction
MultipleInstanceLearningType = CheckVararginPairs('MultipleInstanceLearningType', 'None', varargin{:});
else
if ~(exist('MultipleInstanceLearningType','var'))
MultipleInstanceLearningType='None';
end
end

if isfunction
ConfidenceType = CheckVararginPairs('ConfidenceType', 'None', varargin{:});
else
if ~(exist('ConfidenceType','var'))
ConfidenceType='None';
end
end

%%

if strcmp(NetworkType,'Logistic')
ClassifierHiddenSize = 1;
end

Depth = length(ClassifierHiddenSize);
IsDeepClassifier = false;
if Depth > 1
IsDeepClassifier = true;
end

WantDropout = false;
if DropoutPercent > 0
WantDropout = true;
end

NumDimensions=length(NumClasses);

Layers_Classifier=cell(NumDimensions,1);

for didx=1:NumDimensions

    switch ConfidenceType
        case 'Trial Confidence'
            NameAddition = "TrialConfidence";
            this_LayerName_LSTM=sprintf("LSTM_%s",NameAddition);
            this_LayerName_GRU=sprintf("GRU_%s",NameAddition);
            this_LayerName_FullyConnected=sprintf("fc_%s",NameAddition);
            this_LayerName_Activation=sprintf("activation_%s",NameAddition);
            this_LayerName_output=sprintf("softmax_%s",NameAddition);
            this_LayerName_Dropout=sprintf("dropout_%s",NameAddition);
            this_LayerName_Confidence=sprintf("sigmoid_%s",NameAddition);
        otherwise
            this_LayerName_LSTM=sprintf("LSTM_Dim_%d",didx);
            this_LayerName_GRU=sprintf("GRU_Dim_%d",didx);
            this_LayerName_FullyConnected=sprintf("fc_Dim_%d",didx);
            this_LayerName_Activation=sprintf("activation_Dim_%d",didx);
            this_LayerName_output=sprintf("softmax_Tuning_Dim_%d",didx);
            this_LayerName_Dropout=sprintf("dropout_Dim_%d",didx);
            this_LayerName_Confidence=sprintf("sigmoid_Tuning_Dim_%d",didx);
    end
%%

    switch LossType
        case 'CTC'
            this_NumClasses=NumClasses(didx)+1;
            this_LayerName_LSTM=this_LayerName_LSTM + "_CTC";
            this_LayerName_GRU=this_LayerName_GRU + "_CTC";
            this_LayerName_FullyConnected=this_LayerName_FullyConnected + "_CTC";
            this_LayerName_Activation=this_LayerName_Activation + "_CTC";
            this_LayerName_output=this_LayerName_output + "_CTC";
            this_LayerName_Dropout=this_LayerName_Dropout + "_CTC";
        otherwise
            this_NumClasses=NumClasses(didx);
    end

    Layers_Tuning=[];

    if IsDeepClassifier
        for dpidx = 1:Depth-1
            this_Depth_LayerName_LSTM = this_LayerName_LSTM + sprintf("_Layer-%d",dpidx);
            this_Depth_LayerName_GRU = this_LayerName_GRU + sprintf("_Layer-%d",dpidx);
            this_Depth_LayerName_Dropout = this_LayerName_Dropout + sprintf("_Layer-%d",dpidx);
            this_Depth_LayerName_FullyConnected = this_LayerName_FullyConnected + sprintf("_Layer-%d",dpidx);
            this_Depth_LayerName_Activation = this_LayerName_Activation + sprintf("_Layer-%d",dpidx);
            this_HiddenSize = ClassifierHiddenSize(dpidx);

            if WantDropout
                this_Layer_Dropout=[dropoutLayer(DropoutPercent,'Name',this_Depth_LayerName_Dropout)];
            else
                this_Layer_Dropout = [];
            end

            switch NetworkType
                case 'LSTM'
                    this_Layer_Before = [lstmLayer(this_HiddenSize, 'Name',this_Depth_LayerName_LSTM)];
                    this_Layer_After = [];
                case 'GRU'
                    this_Layer_Before = [gruLayer(this_HiddenSize, 'Name',this_Depth_LayerName_GRU)];
                    this_Layer_After = [];
                case 'Feedforward'
                    this_Layer_Before = [fullyConnectedLayer(this_HiddenSize,"Name",this_Depth_LayerName_FullyConnected)];
                    this_Layer_After = [reluLayer("Name",this_Depth_LayerName_Activation)];
                otherwise
            end

            this_Layer = [this_Layer_Before
                this_Layer_Dropout
                this_Layer_After];

            Layers_Tuning=[
                Layers_Tuning
                this_Layer
                ];
        end
    end

    this_Out_LayerName_LSTM = this_LayerName_LSTM + "_Layer-Out";
    this_Out_LayerName_GRU = this_LayerName_GRU + "_Layer-Out";
    this_Out_LayerName_Dropout = this_LayerName_Dropout + "_Layer-Out";
    this_Out_LayerName_FullyConnected = this_LayerName_FullyConnected + "_Layer-Out";
    this_Out_LayerName_Activation = this_LayerName_Activation + "_Layer-Out";
    this_HiddenSize = ClassifierHiddenSize(end);

    if WantDropout
        this_Layer_Dropout=[dropoutLayer(DropoutPercent,'Name',this_Out_LayerName_Dropout)];
    else
        this_Layer_Dropout = [];
    end

    switch NetworkType
        case 'LSTM'
            this_Layer_Before = [lstmLayer(this_HiddenSize, 'Name',this_Out_LayerName_LSTM)];
            this_Layer_After = [];
        case 'GRU'
            this_Layer_Before = [gruLayer(this_HiddenSize, 'Name',this_Out_LayerName_GRU)];
            this_Layer_After = [];
        case 'Feedforward'
            this_Layer_Before = [fullyConnectedLayer(this_HiddenSize,"Name",this_Out_LayerName_FullyConnected)];
            this_Layer_After = [reluLayer("Name",this_Out_LayerName_Activation)];
        case 'Logistic'
            this_Layer_Before = [];
            this_Layer_After = [];
        otherwise
    end

    this_Layer = [this_Layer_Before
                this_Layer_Dropout
                this_Layer_After];

    switch MultipleInstanceLearningType
        case 'None'
            this_Layer_Output = softmaxLayer("Name",this_LayerName_output);
        case 'MIL'
            this_Layer_Output = cgg_softmaxLayer('SCT',this_LayerName_output);
        otherwise
            this_Layer_Output = softmaxLayer("Name",this_LayerName_output);
    end

    switch ConfidenceType
        case 'Trial Confidence'
            this_Layer_Output = sigmoidLayer("Name",this_LayerName_Confidence);
    end

    Layers_Tuning=[
                Layers_Tuning
                this_Layer
                fullyConnectedLayer(this_NumClasses,"Name",this_LayerName_FullyConnected)
                this_Layer_Output
                ];

Layers_Classifier{didx}=layerGraph(Layers_Tuning);

end

end
