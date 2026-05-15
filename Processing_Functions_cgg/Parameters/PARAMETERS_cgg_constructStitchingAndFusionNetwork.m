function cfg = PARAMETERS_cgg_constructStitchingAndFusionNetwork(StitchingAndFusionNetworkType)
%PARAMETERS_CGG_CONSTRUCTSTITCHINGANDFUSIONNETWORK Summary of this function goes here
%   Detailed explanation goes here

TemporalKernelSizes = [3];
ReductionMethod = 'stride'; % {'maxpool', 'stride'}
EncoderReduction = [4,4];
StrideBypassMethod = 'kernel'; % {'kernel', 'avgpool'}
NumResidualLayers = 2;
NumCascadeLayers = 1;
CascadeStrideMode = 'progressive'; % {'single', 'progressive'}

WantPreActivation = false;
WantPostDecoderConvolution = false;
WantPreDecoderConvolution = false;
WantLearnableOffset = false;
WantLearnableScale = false;

BottleNeckNormalization = 'Layer';

IsSimple = true;
% HiddenSizeAutoEncoder = [5,10];
HiddenSizeAutoEncoder = 16;
FilterSizes = [3,5,7];
FilterSizePercent = {0.05,0.15};
% FilterSizePercent = {0.05};
WantSplitAreas = false;
Stride = 4;
DownSampleMethod = 'MaxPool';
UpSampleMethod = 'Transpose Convolution';
Dropout = 0;
WantNormalization = false;
% WantNormalization = 'Instance';
Transform = 'Feedforward';
Activation = 'None';
FinalActivation = 'Convolutional';
% FinalActivation = 'None';
WantResnet = true;
IsVariational = false;
needReshape = true;
OutputFullyConnected = true;
BottleNeckDepth = 1;
RepetitionsPerBlock = 2;
% RepetitionsPerBlock = 1;
WantSingleResidualBlock = true;
TemporalAndSpatialFusionSize = [5,3];
CrossAreaFusionType = 'Feedforward';
WantCombinationBlocks = false;

IsGemini = false;

    UseBottleneck = false;
    Normalization = 'none'; % 'none'
    UseDepthwiseSeparable = false;

switch StitchingAndFusionNetworkType
    case 'Default'
WantPreActivation = false;
WantPostDecoderConvolution = false;
WantPreDecoderConvolution = false;
WantLearnableOffset = false;
WantLearnableScale = false;

BottleNeckNormalization = 'Layer';

IsSimple = false;
% HiddenSizeAutoEncoder = [5,10];
HiddenSizeAutoEncoder = 16;
FilterSizes = [3,5,7];
FilterSizePercent = {0.05,0.15};
% FilterSizePercent = {0.05};
WantSplitAreas = true;
Stride = 4;
DownSampleMethod = 'MaxPool';
UpSampleMethod = 'Transpose Convolution';
Dropout = 0;
WantNormalization = false;
% WantNormalization = 'Instance';
Transform = 'Feedforward';
Activation = 'Leaky ReLU';
FinalActivation = 'Convolutional';
% FinalActivation = 'None';
WantResnet = true;
IsVariational = false;
needReshape = false;
OutputFullyConnected = false;
BottleNeckDepth = 1;
RepetitionsPerBlock = 2;
% RepetitionsPerBlock = 1;
WantSingleResidualBlock = true;
TemporalAndSpatialFusionSize = [5,3];
CrossAreaFusionType = 'Feedforward';
WantCombinationBlocks = false;
    case 'Feedforward'
WantPreActivation = false;
WantPostDecoderConvolution = false;
WantPreDecoderConvolution = false;
WantLearnableOffset = false;
WantLearnableScale = false;

BottleNeckNormalization = 'Layer';

IsSimple = true;
% HiddenSizeAutoEncoder = [5,10];
HiddenSizeAutoEncoder = 16;
FilterSizes = [3,5,7];
FilterSizePercent = {0.05,0.15};
% FilterSizePercent = {0.05};
WantSplitAreas = false;
Stride = 4;
DownSampleMethod = 'MaxPool';
UpSampleMethod = 'Transpose Convolution';
Dropout = 0;
WantNormalization = false;
% WantNormalization = 'Instance';
Transform = 'Feedforward';
Activation = 'None';
FinalActivation = 'Convolutional';
% FinalActivation = 'None';
WantResnet = true;
IsVariational = false;
needReshape = true;
OutputFullyConnected = true;
BottleNeckDepth = 1;
RepetitionsPerBlock = 2;
% RepetitionsPerBlock = 1;
WantSingleResidualBlock = true;
TemporalAndSpatialFusionSize = [5,3];
CrossAreaFusionType = 'Feedforward';
WantCombinationBlocks = false;
    case 'Parallel Single Level'
        IsGemini = true;
TemporalKernelSizes = [3,5,7];
ReductionMethod = 'stride'; % {'maxpool', 'stride'}
EncoderReduction = [4,4];
StrideBypassMethod = 'avgpool'; % {'kernel', 'avgpool'}
NumResidualLayers = 2;
NumCascadeLayers = 1;
CascadeStrideMode = 'progressive'; % {'single', 'progressive'}
    case 'Cascade Single Kernel - Single Reduction'
        IsGemini = true;
TemporalKernelSizes = 3;
ReductionMethod = 'stride'; % {'maxpool', 'stride'}
EncoderReduction = [4,4];
StrideBypassMethod = 'avgpool'; % {'kernel', 'avgpool'}
NumResidualLayers = 2;
NumCascadeLayers = 3;
CascadeStrideMode = 'single'; % {'single', 'progressive'}
    case 'Cascade Single Kernel - Progressive Reduction'
        IsGemini = true;
TemporalKernelSizes = 3;
ReductionMethod = 'stride'; % {'maxpool', 'stride'}
EncoderReduction = [4,2];
StrideBypassMethod = 'avgpool'; % {'kernel', 'avgpool'}
NumResidualLayers = 2;
NumCascadeLayers = 3;
CascadeStrideMode = 'progressive'; % {'single', 'progressive'}
    case 'ZZZ'
    otherwise
        fprintf("!!! No Stitching and Fusion Network has been selected\n");
end

        %%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end
end