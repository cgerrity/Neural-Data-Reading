function Layers_Classifier = cgg_generateLayersForLSTMClassifier(NumClasses,varargin)
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

    this_LayerName_LSTM=sprintf("LSTM_Dim_%d",didx);
    this_LayerName_FullyConnected=sprintf("fc_Dim_%d",didx);
    this_LayerName_output=sprintf("softmax_Tuning_Dim_%d",didx);
    this_LayerName_Dropout=sprintf("dropout_Dim_%d",didx);

    switch LossType
        case 'CTC'
            this_NumClasses=NumClasses(didx)+1;
            this_LayerName_LSTM=this_LayerName_LSTM + "_CTC";
            this_LayerName_FullyConnected=this_LayerName_FullyConnected + "_CTC";
            this_LayerName_output=this_LayerName_output + "_CTC";
            this_LayerName_Dropout=this_LayerName_Dropout + "_CTC";
        otherwise
            this_NumClasses=NumClasses(didx);
    end

    Layers_Tuning=[];

    if IsDeepClassifier
        for dpidx = 1:Depth-1
            this_Depth_LayerName_LSTM = this_LayerName_LSTM + sprintf("_Layer-%d",dpidx);
            this_Depth_LayerName_Dropout = this_LayerName_Dropout + sprintf("_Layer-%d",dpidx);
            this_HiddenSize = ClassifierHiddenSize(dpidx);

            Layers_Tuning=[
                Layers_Tuning
                lstmLayer(this_HiddenSize, 'Name',this_Depth_LayerName_LSTM)
                ];

            if WantDropout
            Layers_Tuning=[
                Layers_Tuning
                dropoutLayer(DropoutPercent,'Name',this_Depth_LayerName_Dropout)
                ];
            end
        end
    end

    this_Out_LayerName_LSTM = this_LayerName_LSTM + "_Layer-Out";
    this_Out_LayerName_Dropout = this_LayerName_Dropout + "_Layer-Out";
    this_HiddenSize = ClassifierHiddenSize(end);

    Layers_Tuning = [
        Layers_Tuning
        lstmLayer(this_HiddenSize, 'Name',this_Out_LayerName_LSTM)];

    if WantDropout
    Layers_Tuning=[
        Layers_Tuning
        dropoutLayer(DropoutPercent,'Name',this_Out_LayerName_Dropout)
        ];
    end

    Layers_Tuning = [
        Layers_Tuning
        fullyConnectedLayer(this_NumClasses,"Name",this_LayerName_FullyConnected)
        softmaxLayer("Name",this_LayerName_output)];

Layers_Classifier{didx}=layerGraph(Layers_Tuning);

end

end