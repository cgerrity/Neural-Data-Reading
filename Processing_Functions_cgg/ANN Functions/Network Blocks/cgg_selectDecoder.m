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

    FilterSizes = cfg.FilterSizes;
    FilterHiddenSizes = HiddenSizeAutoEncoder;
    InputSize = cfg.InputSize;
    WantSplitAreas = cfg.WantSplitAreas;
    DownSampleMethod = 'None';
    UpSampleMethod = cfg.UpSampleMethod;
    Stride = cfg.Stride;
    WantNormalization = cfg.WantNormalization;
    Dropout = cfg.Dropout;
    Activation = cfg.Activation;
    FinalActivation = cfg.FinalActivation;
    WantResnet = cfg.WantResnet;
    HiddenSizeAugment = cfg.HiddenSizeBottleNeck;

    DecoderBlocks = cgg_constructConvolutionalCoder(FilterSizes, ...
        FilterHiddenSizes,InputSize,'WantSplitAreas',WantSplitAreas, ...
        'DownSampleMethod',DownSampleMethod, ...
        'UpSampleMethod',UpSampleMethod,'Stride',Stride, ...
        'WantNormalization',WantNormalization,'Dropout',Dropout, ...
        'Activation',Activation,'FinalActivation',FinalActivation,...
        'WantResnet',WantResnet,'Coder',Coder, ...
        'HiddenSizeAugment',HiddenSizeAugment);


    ReshapeFilterHiddenSize = FilterHiddenSizes(end)*InputSize(3);
    [~,UpSampleSizes] = cgg_getCropAmount(InputSize(1:2),Stride,length(FilterHiddenSizes));
PreDecoderBlock = [functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="addspatial_BottleNeck")
        transposedConv2dLayer(UpSampleSizes{1},ReshapeFilterHiddenSize,"Name","reshape_BottleNeck",'Stride',UpSampleSizes{1})];

% PostDecoderBlock = convolution2dLayer(1,InputSize(3),"Name","Combination_Decoder","Padding",'same');

end


end

