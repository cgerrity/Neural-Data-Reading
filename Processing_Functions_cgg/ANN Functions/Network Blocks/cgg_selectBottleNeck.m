function BottleNeck = cgg_selectBottleNeck(HiddenSizeBottleNeck,cfg)
%CGG_SELECTBOTTLENECK Summary of this function goes here
%   Detailed explanation goes here


Coder = 'BottleNeck';
BottleNeckDepth = cfg.BottleNeckDepth;
HiddenSizeBottleNeck = repmat(HiddenSizeBottleNeck,[1,BottleNeckDepth]);

BottleNeck = [];
if isempty(HiddenSizeBottleNeck)
    BottleNeck = flattenLayer('Name','flatten_BottleNeck');
    BottleNeck = layerGraph(BottleNeck);
    return
end

if cfg.IsSimple
    Dropout = cfg.Dropout;
    WantNormalization = cfg.WantNormalization;
    Transform = cfg.Transform;
    Activation = cfg.Activation;

    BottleNeck = cgg_constructSimpleCoder(HiddenSizeBottleNeck,...
            'Coder',Coder,'Dropout',Dropout,...
            'WantNormalization',WantNormalization,...
            'Transform',Transform,'Activation',Activation);

    % BottleNeck = cgg_generateSimpleBlock(HiddenSizeBottleNeck,NaN,...
    %         'Coder',Coder,'Dropout',Dropout,...
    %         'WantNormalization',WantNormalization,...
    %         'Transform',Transform,'Activation',Activation);
elseif strcmp(cfg.Transform,'PCA')
    return
else
    Dropout = cfg.Dropout;
    WantNormalization = cfg.BottleNeckNormalization;
    Transform = cfg.Transform;
    Activation = cfg.Activation;

    switch Transform
        case 'LSTM'
            Activation='';
        case 'GRU'
            Activation='';
        case 'Feedforward'
        otherwise
            Activation='';
    end

    % BottleNeck = cgg_generateSimpleBlock(HiddenSizeBottleNeck,NaN,...
    %         'Coder',Coder,'Dropout',Dropout,...
    %         'WantNormalization',WantNormalization,...
    %         'Transform',Transform,'Activation',Activation);

    BottleNeck = cgg_constructSimpleCoder(HiddenSizeBottleNeck,...
            'Coder',Coder,'Dropout',Dropout,...
            'WantNormalization',WantNormalization,...
            'Transform',Transform,'Activation',Activation);
end

BottleNeck = [BottleNeck
    fullyConnectedLayer(HiddenSizeBottleNeck,"Name","fc_OUT_BottleNeck","WeightsInitializer","he")];

BottleNeck = layerGraph(BottleNeck);

end

