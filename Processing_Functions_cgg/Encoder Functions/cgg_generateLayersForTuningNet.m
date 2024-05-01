function LayerGraph_Tuning = cgg_generateLayersForTuningNet(NumClasses,varargin)
%CGG_GENERATELAYERSFORTUNINGNET Summary of this function goes here
%   Detailed explanation goes here

DropoutPercent_Tuning=0.5;

isfunction=exist('varargin','var');

if isfunction
LossType = CheckVararginPairs('LossType', 'Classification', varargin{:});
else
if ~(exist('LossType','var'))
LossType='Classification';
end
end

NumDimensions=length(NumClasses);

LayerGraph_Tuning=cell(NumDimensions,1);

for didx=1:NumDimensions

    this_LayerName_FC=sprintf("fc_Tuning_Dim_%d",didx);
    this_LayerName_DropOut=sprintf("dropout_Tuning_Dim_%d",didx);
    this_LayerName_output=sprintf("softmax_Tuning_Dim_%d",didx);

    switch LossType
        case 'CTC'
            this_NumClasses=NumClasses(didx)+1;
            this_LayerName_FC=this_LayerName_FC + "_CTC";
            this_LayerName_output=this_LayerName_output + "_CTC";
        otherwise
            this_NumClasses=NumClasses(didx);
    end

    %     dropoutLayer(DropoutPercent_Tuning,'Name',this_LayerName_DropOut)
Layers_Tuning=[
    fullyConnectedLayer(this_NumClasses, 'Name',this_LayerName_FC)
    softmaxLayer("Name",this_LayerName_output)
    ];

LayerGraph_Tuning{didx}=layerGraph(Layers_Tuning);

end

