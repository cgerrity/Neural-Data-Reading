function Layers_Custom = cgg_selectAutoEncoder(ModelName,DataSize,HiddenSizes,NumWindows,DataFormat)
%CGG_SELECTAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

switch ModelName
    case 'Feedforward - ReLU'
        Dropout_Main=0;
        Activation = 'ReLU';
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main,'Activation',Activation);
    case 'Feedforward - ReLU - Normalized'
        WantNormalization = true;
        Dropout_Main=0;
        Activation = 'ReLU';
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main,'Activation',Activation,'WantNormalization',WantNormalization);
    case 'Feedforward - ReLU - Normalized - Dropout 0.5'
        WantNormalization = true;
        Dropout_Main=0.5;
        Activation = 'ReLU';
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main,'Activation',Activation,'WantNormalization',WantNormalization);
    case 'Feedforward - Softplus'
        Dropout_Main=0;
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main);
    case 'Feedforward - Softplus - Dropout 0.5'
        Dropout_Main=0.5;
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main);
    case 'Feedforward - Softplus - Dropout 0.5 - Skip 0.9'
        Dropout_Main=0.5;
        Dropout_Skip=0.9;
        [~,Layers_Custom]=cgg_generateLayersForAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout_Main',Dropout_Main,'Dropout_Skip',Dropout_Skip);
    case 'Variational Feedforward - Softplus - Dropout 0.5'
        Dropout_Main=0.5;
        [~,Layers_Custom] = cgg_generateLayersForVariationalAutoEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main);
    case 'Variational GRU - Dropout 0.5'
         Dropout_Main=0.5;
        [~,Layers_Custom] = cgg_generateLayersForVariationalAutoEncoder_v2(DataSize,HiddenSizes,NumWindows,DataFormat,'Dropout',Dropout_Main);
    case 'LSTM'
        Layers_Custom = cgg_generateLayersForReccurentEncoder(DataSize,HiddenSizes,NumWindows,DataFormat);
    case 'LSTM - Normalized'
        WantNormalization = true;
        Layers_Custom = cgg_generateLayersForReccurentEncoder(DataSize,HiddenSizes,NumWindows,DataFormat,'WantNormalization',WantNormalization);
    case 'Convolution'
        HiddenSizes_Filters = HiddenSizes(1:end-1);
        LatentSize = HiddenSizes(end);
        Layers_Custom = cgg_generateLayersForConvolutionalEncoder(DataSize,HiddenSizes_Filters,LatentSize);
    case 'Multi-Filter Convolution'
        HiddenSizes_Filters = HiddenSizes(1:end-1);
        LatentSize = HiddenSizes(end);
        Layers_Custom = cgg_generateLayersForConvolutionalEncoder_v2(DataSize,HiddenSizes_Filters,LatentSize);
    otherwise
end



end

