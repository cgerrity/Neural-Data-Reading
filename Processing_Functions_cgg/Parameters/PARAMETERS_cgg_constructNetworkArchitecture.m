function cfg = PARAMETERS_cgg_constructNetworkArchitecture(ArchitectureType)
%PARAMETERS_CGG_CONSTRUCTNETWORKARCHITECTURE Summary of this function goes here
%   Detailed explanation goes here


switch ArchitectureType
    case 'Feedforward - ReLU'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'Feedforward';
        Activation = 'ReLU';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational Feedforward - ReLU'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'Feedforward';
        Activation = 'ReLU';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Feedforward - ReLU - Normalized'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = true;
        Transform = 'Feedforward';
        Activation = 'ReLU';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Feedforward - ReLU - Normalized - Dropout 0.5'
        IsSimple = true;
        Dropout = 0.5;
        WantNormalization = true;
        Transform = 'Feedforward';
        Activation = 'ReLU';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Feedforward - Softplus'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'Feedforward';
        Activation = 'Softplus';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Feedforward - Softplus - Dropout 0.5'
        IsSimple = true;
        Dropout = 0.5;
        WantNormalization = false;
        Transform = 'Feedforward';
        Activation = 'Softplus';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational Feedforward - Softplus - Dropout 0.5'
        IsSimple = true;
        Dropout = 0.5;
        WantNormalization = false;
        Transform = 'Feedforward';
        Activation = 'Softplus';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'GRU'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'GRU';
        Activation = '';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational GRU'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'GRU';
        Activation = '';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational GRU - Dropout 0.5'
        IsSimple = true;
        Dropout = 0.5;
        WantNormalization = false;
        Transform = 'GRU';
        Activation = '';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational GRU - Dropout 0.25'
        IsSimple = true;
        Dropout = 0.25;
        WantNormalization = false;
        Transform = 'GRU';
        Activation = '';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'LSTM'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = '';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'LSTM - Normalized'
        IsSimple = true;
        Dropout = 0;
        WantNormalization = true;
        Transform = 'LSTM';
        Activation = '';
        IsVariational = false;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Variational LSTM - Dropout 0.5'
        IsSimple = true;
        Dropout = 0.5;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = '';
        IsVariational = true;
        needReshape = true;
        OutputFullyConnected = true;
        BottleNeckDepth = 1;
    case 'Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = false;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = true;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = true;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'Tanh';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = true;
        Transform = 'LSTM';
        Activation = 'Leaky ReLU';
        FinalActivation = 'Tanh';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional Resnet 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = true;
        Transform = 'LSTM';
        Activation = 'Leaky ReLU';
        FinalActivation = 'Tanh';
        WantResnet = true;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = 3;
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = 'Leaky ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Convolutional Multi-Filter [3,5,7] - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = [3,5,7];
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = false;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
    case 'Variational Convolutional Multi-Filter [3,5,7] - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM'
        IsSimple = false;
        FilterSizes = [3,5,7];
        WantSplitAreas = true;
        Stride = 2;
        DownSampleMethod = 'MaxPool';
        UpSampleMethod = 'Transpose Convolution - Point-Wise';
        Dropout = 0;
        WantNormalization = false;
        Transform = 'LSTM';
        Activation = 'ReLU';
        FinalActivation = 'None';
        WantResnet = false;
        IsVariational = true;
        needReshape = false;
        OutputFullyConnected = false;
        BottleNeckDepth = 2;
end



w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end

end

