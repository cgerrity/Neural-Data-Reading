function [PreDecoderBlock,DecoderBlocks,PostDecoderBlock] = ...
    cgg_selectDecoder(HiddenSizeAutoEncoder,cfg)
%CGG_SELECTDecoder Summary of this function goes here
%   Detailed explanation goes here

%%

PreDecoderBlock = [];
PostDecoderBlock = [];
DecoderBlocks = [];

Coder = 'Decoder';

if isempty(HiddenSizeAutoEncoder)
    return
end

if cfg.IsSimple
    Dropout = cfg.Dropout;
    WantNormalization = cfg.WantNormalization;
    Transform = cfg.Transform;
    Activation = cfg.Activation;
    HiddenSizeBottleNeck = cfg.HiddenSizeBottleNeck;
    HiddenSizeAutoEncoder = [HiddenSizeAutoEncoder, HiddenSizeBottleNeck];

    DecoderBlocks = cgg_constructSimpleCoder(HiddenSizeAutoEncoder,...
            'Coder',Coder,'Dropout',Dropout,...
            'WantNormalization',WantNormalization,...
            'Transform',Transform,'Activation',Activation);
    DecoderBlocks = layerGraph(DecoderBlocks);
elseif strcmp(cfg.Transform,'PCA')
    PCCoefficients = cfg.PCAInformation.PCCoefficients;
    PCMean = cfg.PCAInformation.PCMean;
    ApplyPerTimePoint = cfg.PCAInformation.ApplyPerTimePoint;
    OriginalChannels = cfg.PCAInformation.OriginalChannels;
    SpatialDimensions = cfg.PCAInformation.SpatialDimensions;

    DecoderBlocks = cgg_PCADecodingLayer(...
        Name="PCA_Decoder", ...
        PCCoefficients=PCCoefficients, ...
        PCMean=PCMean, ...
        ApplyPerTimePoint=ApplyPerTimePoint, ...
        OriginalChannels=OriginalChannels, ...
        SpatialDimensions=SpatialDimensions);
    DecoderBlocks = layerGraph(DecoderBlocks);
else

    % FilterSizes = cfg.FilterSizes;
    FilterHiddenSizes = HiddenSizeAutoEncoder;
    InputSize = cfg.InputSize;
    WantSplitAreas = cfg.WantSplitAreas;
    DownSampleMethod = 'None';
    UpSampleMethod = cfg.UpSampleMethod;
    Stride = cfg.Stride;
    WantNormalization = cfg.WantNormalization;
    Dropout = cfg.Dropout;
    Activation = cfg.Activation;
    WantPreActivation = cfg.WantPreActivation;
    FinalActivation = cfg.FinalActivation;
    WantResnet = cfg.WantResnet;
    HiddenSizeAugment = cfg.HiddenSizeBottleNeck;
    FilterSizePercent = cfg.FilterSizePercent;
    FilterSizes = cellfun(@(x) ceil(InputSize(1:2)*x), ...
        FilterSizePercent,'UniformOutput',false);
    WantPostDecoderConvolution = cfg.WantPostDecoderConvolution;
    WantPreDecoderConvolution = cfg.WantPreDecoderConvolution;
    WantLearnableOffset = cfg.WantLearnableOffset;
    WantLearnableScale = cfg.WantLearnableScale;

    DecoderBlocks = cgg_constructConvolutionalCoder(FilterSizes, ...
        FilterHiddenSizes,InputSize,'WantSplitAreas',WantSplitAreas, ...
        'DownSampleMethod',DownSampleMethod, ...
        'UpSampleMethod',UpSampleMethod,'Stride',Stride, ...
        'WantNormalization',WantNormalization,'Dropout',Dropout, ...
        'Activation',Activation,'FinalActivation',FinalActivation,...
        'WantResnet',WantResnet,'Coder',Coder, ...
        'HiddenSizeAugment',HiddenSizeAugment, ...
        'WantPreActivation',WantPreActivation, ...
        'WantPostDecoderConvolution',WantPostDecoderConvolution, ...
        'WantLearnableOffset',WantLearnableOffset, ...
        'WantLearnableScale',WantLearnableScale);


    ReshapeFilterHiddenSize = FilterHiddenSizes(end)*InputSize(3);
    [~,UpSampleSizes] = cgg_getCropAmount(InputSize(1:2),Stride,length(FilterHiddenSizes));
PreDecoderBlock = [functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="addspatial_BottleNeck")
        transposedConv2dLayer(UpSampleSizes{1},ReshapeFilterHiddenSize,"Name","reshape_BottleNeck",'Stride',UpSampleSizes{1})];

% PostDecoderBlock = cgg_generateSimpleConvolutionalBlock(FilterSizes{end},InputSize(3),NaN,NaN,NaN,'Coder','Decoder-Out','DownSampleMethod','None','UpSampleMethod','None','Stride',1,'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResnet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
% PostDecoderBlock = cgg_generateSingleConvolutionalPath(FilterSizes{end},InputSize(3),NaN,NaN,'Coder','Decoder-Out','DownSampleMethod','None','UpSampleMethod','None','Stride',1,'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResnet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
%
if WantPreDecoderConvolution
PreDecoderConvolution = cgg_generatePostDecoderConvolution("Decoder-In",FilterHiddenSizes(end)*InputSize(3),FilterSizes{end},FilterHiddenSizes(end),'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResnet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
DecoderBlocks = cgg_connectLayerGraphs(PreDecoderConvolution,DecoderBlocks);
end
if WantPostDecoderConvolution
PostDecoderBlock = cgg_generatePostDecoderConvolution("Decoder-Out",InputSize(3),FilterSizes{1},FilterHiddenSizes(1),'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResnet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
end

end


end

