function [PreEncoderBlock,EncoderBlocks,PostEncoderBlock] = ...
    cgg_selectEncoder(HiddenSizeAutoEncoder,cfg)
%CGG_SELECTENCODER Summary of this function goes here
%   Detailed explanation goes here

%%

PreEncoderBlock = [];
PostEncoderBlock = [];
Coder = 'Encoder';

if cfg.IsSimple
    Dropout = cfg.Dropout;
    WantNormalization = cfg.WantNormalization;
    Transform = cfg.Transform;
    Activation = cfg.Activation;

    EncoderBlocks = cgg_constructSimpleCoder(HiddenSizeAutoEncoder,...
            'Coder',Coder,'Dropout',Dropout,...
            'WantNormalization',WantNormalization,...
            'Transform',Transform,'Activation',Activation);
    EncoderBlocks = layerGraph(EncoderBlocks);
else

    FilterSizes = cfg.FilterSizes;
    FilterHiddenSizes = HiddenSizeAutoEncoder;
    InputSize = cfg.InputSize;
    WantSplitAreas = cfg.WantSplitAreas;
    DownSampleMethod = cfg.DownSampleMethod;
    UpSampleMethod = 'None';
    Stride = cfg.Stride;
    WantNormalization = cfg.WantNormalization;
    Dropout = cfg.Dropout;
    Activation = cfg.Activation;
    WantResnet = cfg.WantResnet;

    EncoderBlocks = cgg_constructConvolutionalCoder(FilterSizes, ...
        FilterHiddenSizes,InputSize,'WantSplitAreas',WantSplitAreas, ...
        'DownSampleMethod',DownSampleMethod, ...
        'UpSampleMethod',UpSampleMethod,'Stride',Stride, ...
        'WantNormalization',WantNormalization,'Dropout',Dropout, ...
        'Activation',Activation,'WantResnet',WantResnet,'Coder',Coder);

end


end

