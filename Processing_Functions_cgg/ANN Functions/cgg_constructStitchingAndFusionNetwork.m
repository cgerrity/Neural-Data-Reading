function StitchingAndFusionNetwork = cgg_constructStitchingAndFusionNetwork(StitchingAndFusionNetworkType,cfg,Coder)
%cgg_constructStitchingAndFusionNetwork Summary of this function goes here
%   Detailed explanation goes here


cfg_NetworkConstruction = PARAMETERS_cgg_constructStitchingAndFusionNetwork(StitchingAndFusionNetworkType);

    Transform = cfg_NetworkConstruction.Transform;

    FilterHiddenSizes = cfg_NetworkConstruction.HiddenSizeAutoEncoder;
    RepetitionsPerBlock = cfg_NetworkConstruction.RepetitionsPerBlock;
    InputSize = cfg.InputSize;
    WantSplitAreas = cfg_NetworkConstruction.WantSplitAreas;
    DownSampleMethod = cfg_NetworkConstruction.DownSampleMethod;
    UpSampleMethod = cfg_NetworkConstruction.UpSampleMethod;
    Stride = cfg_NetworkConstruction.Stride;
    WantNormalization = cfg_NetworkConstruction.WantNormalization;
    Dropout = cfg_NetworkConstruction.Dropout;
    Activation = cfg_NetworkConstruction.Activation;
    WantResnet = cfg_NetworkConstruction.WantResnet;
    WantSingleResidualBlock = cfg_NetworkConstruction.WantSingleResidualBlock;
    TemporalAndSpatialFusionSize = cfg_NetworkConstruction.TemporalAndSpatialFusionSize;
    CrossAreaFusionType = cfg_NetworkConstruction.CrossAreaFusionType;
    WantCombinationBlocks = cfg_NetworkConstruction.WantCombinationBlocks;
    FilterSizePercent = cfg_NetworkConstruction.FilterSizePercent;
    FilterSizes = cellfun(@(x) ceil(InputSize(1:2)*x), ...
        FilterSizePercent,'UniformOutput',false);

    FilterSizes_Time = cellfun(@(x) [1,x(2)],FilterSizes,'UniformOutput',false);
    FilterSizes = FilterSizes_Time;

    if cfg_NetworkConstruction.IsGemini
    TemporalKernelSizes = cfg_NetworkConstruction.TemporalKernelSizes;
    ReductionMethod = cfg_NetworkConstruction.ReductionMethod; % {'maxpool', 'stride'}
    EncoderReduction = cfg_NetworkConstruction.EncoderReduction;
    StrideBypassMethod = cfg_NetworkConstruction.StrideBypassMethod; % {'kernel', 'avgpool'}
    NumResidualLayers = cfg_NetworkConstruction.NumResidualLayers;
    NumCascadeLayers = cfg_NetworkConstruction.NumCascadeLayers;
    CascadeStrideMode = cfg_NetworkConstruction.CascadeStrideMode; % {'single', 'progressive'}
    UseBottleneck = cfg_NetworkConstruction.UseBottleneck;
    Normalization = cfg_NetworkConstruction.Normalization; % 'none'
    UseDepthwiseSeparable = cfg_NetworkConstruction.UseDepthwiseSeparable;

    Final_Channels = cfg.CrossAreaFusionSize/2;
    [best_x, best_y] = cgg_findOptimalDivisors(Final_Channels, InputSize(1), InputSize(2));
    TargetSizes = [best_x,best_y];

            StitchingAndFusionNetwork = ...
                cgg_createStitchingFusionModule_v2(InputSize(3), ...
                FilterHiddenSizes(1), 'Mode',Coder,...
                'TargetSize',TargetSizes,'OutputSize',InputSize(1:2),...
                'TemporalKernelSizes',TemporalKernelSizes,...
                'StrideBypassMethod',StrideBypassMethod,...
                'NumResidualLayers',NumResidualLayers,...
                'ReductionMethod',ReductionMethod,...
                'EncoderReduction',EncoderReduction,...
                'NumCascadeLayers',NumCascadeLayers, ...
                'CascadeStrideMode',CascadeStrideMode, ...
                'UseBottleneck',UseBottleneck, ...
                'Normalization',Normalization, ...
                'UseDepthwiseSeparable',UseDepthwiseSeparable, ...
                'NameSuffix',Coder);

    elseif cfg_NetworkConstruction.IsSimple

        switch Coder
            case 'Encoder'

                StitchingAndFusionNetwork = cgg_constructSimpleCoder(cfg.CrossAreaFusionSize,...
                        'Coder','StitchingAndFusion_Encoder','Dropout',Dropout,...
                        'WantNormalization',WantNormalization,...
                        'Transform',Transform,'Activation',Activation);

            case 'Decoder'
            
                StitchingAndFusionNetwork = cgg_constructSimpleCoder(cfg.CrossAreaFusionSize,...
                        'Coder','StitchingAndFusion_Decoder','Dropout',Dropout,...
                        'WantNormalization',WantNormalization,...
                        'Transform',Transform,'Activation',Activation);
        end

        % StitchingAndFusionNetwork = layerGraph(StitchingAndFusionNetwork);

    else

    switch Coder
        case 'Encoder'
            UpSampleMethod = 'None';
    StitchingAndFusionNetwork = cgg_constructConvolutionalCoder(FilterSizes, ...
        FilterHiddenSizes,InputSize,'WantSplitAreas',WantSplitAreas, ...
        'DownSampleMethod',DownSampleMethod, ...
        'UpSampleMethod',UpSampleMethod,'Stride',Stride, ...
        'WantNormalization',WantNormalization,'Dropout',Dropout, ...
        'Activation',Activation,'WantResnet',WantResnet, ...
        'Coder','StitchingAndFusion_Encoder', ...
        'RepetitionsPerBlock',RepetitionsPerBlock, ...
        'WantSingleResidualBlock',WantSingleResidualBlock, ...
        'TemporalAndSpatialFusionSize',TemporalAndSpatialFusionSize, ...
        'CrossAreaFusionType',CrossAreaFusionType);

            switch CrossAreaFusionType
                case 'Feedforward'
                    CrossAreaFusionLayer = fullyConnectedLayer(cfg.CrossAreaFusionSize,"Name","AreaFusion" + "_StitchingAndFusion_Encoder");
                    StitchingAndFusionNetwork = cgg_connectLayerGraphs(StitchingAndFusionNetwork,layerGraph(CrossAreaFusionLayer));
            end
        case 'Decoder'
            DownSampleMethod = 'None';
        StitchingAndFusionNetwork = cgg_constructConvolutionalCoder(FilterSizes, ...
        FilterHiddenSizes,InputSize,'WantSplitAreas',WantSplitAreas, ...
        'DownSampleMethod',DownSampleMethod, ...
        'UpSampleMethod',UpSampleMethod,'Stride',Stride, ...
        'WantNormalization',WantNormalization,'Dropout',Dropout, ...
        'Activation',Activation,'WantResnet',WantResnet, ...
        'Coder','Decoder', ...
        'RepetitionsPerBlock',RepetitionsPerBlock, ...
        'WantSingleResidualBlock',WantSingleResidualBlock, ...
        'TemporalAndSpatialFusionSize',TemporalAndSpatialFusionSize, ...
        'CrossAreaFusionType',CrossAreaFusionType, ...
        'WantCombinationBlocks',WantCombinationBlocks);

        ReshapeFilterHiddenSize = FilterHiddenSizes(end)*InputSize(3);
    [~,UpSampleSizes] = cgg_getCropAmount(InputSize(1:2),Stride,length(FilterHiddenSizes));
StitchingAndFusionBlock = [fullyConnectedLayer(cfg.CrossAreaFusionSize/2,"Name","fc_In_StitchingAndFusion_Decoder")
    functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="addspatial_StitchingAndFusion_Decoder")
        transposedConv2dLayer(UpSampleSizes{1},ReshapeFilterHiddenSize,"Name","reshape_StitchingAndFusion_Decoder",'Stride',UpSampleSizes{1})];

% PostDecoderBlock = cgg_generatePostDecoderConvolution("Decoder-Out",InputSize(3),FilterSizes{1},FilterHiddenSizes(1),'WantNormalization',WantNormalization,'Activation',Activation,'WantResnet',WantResnet,'WantPreActivation',WantPreActivation,'Dropout',Dropout);
StitchingAndFusionNetwork = cgg_connectLayerGraphs(layerGraph(StitchingAndFusionBlock),StitchingAndFusionNetwork);
    end

    end

    
    % switch Coder
    %     case 'Encoder'
    %         StitchingAndFusionNetwork = cgg_createStitchingFusionModule_v2(InputSize(3), FilterHiddenSizes(1),'TemporalKernelSizes',TemporalKernelSizes,'ReductionMethod',ReductionMethod,'EncoderReduction',EncoderReduction,'StrideBypassMethod',StrideBypassMethod,'NumResidualLayers',NumResidualLayers);
    %     case 'Decoder'
    %         % StitchingAndFusionNetwork = cgg_createStitchingFusionModule(InputSize(3), FilterHiddenSizes(1), 'Mode', 'Decoder', 'TargetSize', TargetSizes, 'CropAmount', CropSizes{1});
    %         StitchingAndFusionNetwork = cgg_createStitchingFusionModule_v2(InputSize(3), FilterHiddenSizes(1), 'Mode','Decoder','TargetSize',TargetSizes,'OutputSize',InputSize(1:2),'TemporalKernelSizes',TemporalKernelSizes,'StrideBypassMethod',StrideBypassMethod,'NumResidualLayers',NumResidualLayers);
    % end
% PreEncoderBlock = 
end