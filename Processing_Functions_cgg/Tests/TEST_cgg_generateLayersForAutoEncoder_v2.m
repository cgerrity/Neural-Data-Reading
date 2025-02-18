

clc; clear; close all;

%%

HiddenSizes = [8,16,32];
LatentSize = [10];

NetworkToView = 'Decoder';
Pause_Time = 0;

wantGrouped = false;

% ModelName = 'Feedforward - ReLU';
% ModelName = 'Feedforward - ReLU - Normalized';
% ModelName = 'Feedforward - ReLU - Normalized - Dropout 0.5';
% ModelName = 'Feedforward - Softplus';
% ModelName = 'Feedforward - Softplus - Dropout 0.5';
% ModelName = 'Feedforward - Softplus - Dropout 0.5 - Skip 0.9';
% ModelName = 'Variational Feedforward - Softplus - Dropout 0.5';
% ModelName = 'Variational GRU - Dropout 0.5';
% ModelName = 'LSTM';
% ModelName = 'LSTM - Normalized';
ModelName = 'Convolutional';
% ModelName = 'Multi-Filter Convolution';
% ModelName = 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM';
% ModelName = 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM';
% ModelName = 'Variational Convolutional 3x3 - Split Area - ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh';
% ModelName = 'Variational Convolutional 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh';
% ModelName = 'Variational Convolutional Resnet 3x3 - Split Area - Leaky ReLU - Max Pool, Transpose Point-Wise - Normalized - Bottle Neck LSTM - Final Tanh';
% ModelName = 'Variational Convolutional Multi-Filter [3,5,7] - Split Area - ReLU - Max Pool, Transpose Point-Wise - Bottle Neck LSTM';

% ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierName = 'Deep Feedforward - Dropout 0.5';
LossType = 'Classification';
ClassifierHiddenSize = [500];

NumChannels = 9;
DataWidth = 17;
NumWindows = 3;
NumAreas = 3;
NumExamples = 8;

NumClasses = [1,4,4,4];

%%
InputSize = [NumChannels,DataWidth,NumAreas];
HiddenSizes = [HiddenSizes,LatentSize];

RandomChannelNaN = randi(NumChannels);
RandomAreaNaN = randi(NumAreas);

%%

X_Input=randn([InputSize,NumWindows,NumExamples]);
X_Input(RandomChannelNaN,:,RandomAreaNaN,:,:) = NaN;
DataFormat='SSCTB';
X_Input = dlarray(X_Input,DataFormat);

% switch NetworkToView
%     case 'Encoder'
%         X_TEST=randn([InputSize,NumWindows,NumExamples]);
%         DataFormat='SSCTB';
%     case 'Decoder'
%         X_TEST=randn(LatentSize,NumWindows,NumExamples);
%         DataFormat='CTB';
%     case 'Classifier'
%         X_TEST=randn(LatentSize,NumWindows,NumExamples);
%         DataFormat='CTB';
% end
% X_TEST = dlarray(X_TEST,DataFormat);
%%

[Encoder,Decoder] = cgg_constructNetworkArchitecture(ModelName,...
    'InputSize',InputSize,'HiddenSize',HiddenSizes);

switch NetworkToView
    case 'Encoder'
        InputNet= initialize(Encoder);
        X_Network = X_Input;
    case 'Decoder'
        InputNet= initialize(Decoder);
        Encoder = initialize(Encoder);
        X_Network = forward(Encoder,X_Input);
    case 'Classifier'
        InputNet= initialize(Classifier);
        Encoder = initialize(Encoder);
        X_Network = forward(Encoder,X_Input);
end

%%
InputNet_Grouped = InputNet;
for aidx = 1:NumAreas
    for lidx = 1:length(HiddenSizes)-1
this_Name = sprintf("Area-%d_Layer-%d",aidx,lidx);
this_LayerIDX = find(contains({InputNet_Grouped.Layers(:).Name},this_Name));
InputNet_Grouped = groupLayers(InputNet_Grouped,this_LayerIDX,GroupNames=this_Name);
    end
end

if wantGrouped
InputNet = InputNet_Grouped;
end

%%
NumLayers = length(InputNet.Layers);
OutputLayerNames = cell(1,NumLayers);
for idx = 1:NumLayers
OutputLayerNames{idx} = InputNet.Layers(idx).OutputNames;
end

%%
OutputNames=cellfun(@(x,y) cellfun(@(z) [x '/' z],y,'UniformOutput',false),{InputNet.Layers(:).Name},OutputLayerNames,'UniformOutput',false);
OutputNames = [OutputNames{:}];
% OutputNames=cellfun(@(x,y) [x '/' y{1}],{InputNet.Layers(:).Name},OutputLayerNames,'UniformOutput',false);
OutputExample=cell(1,length(OutputNames));
[OutputExample{:}]=forward(InputNet,X_Network,Outputs=OutputNames);


%%
% IDX = 1; {OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))}
OutputTable_Cell = cell(length(OutputExample),5);
for IDX = 1:length(OutputNames)
    OutputTable_Cell{IDX,1} = OutputNames{IDX};
    OutputTable_Cell{IDX,2} = IDX;
    OutputTable_Cell{IDX,3} = OutputExample{IDX}.dims;
    OutputTable_Cell{IDX,4} = size(OutputExample{IDX});
    OutputTable_Cell{IDX,5} = numel(OutputExample{IDX});
    OutputTable_Cell{IDX,6} = double([min(extractdata(OutputExample{IDX}(:))),max(extractdata(OutputExample{IDX}(:)))]);
    OutputTable_Cell{IDX,7} = OutputTable_Cell{IDX,6}(2)-OutputTable_Cell{IDX,6}(1);
    % OutputTable_Cell{IDX} = {OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))};
% disp({OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))})
end

OutputTable = table(OutputTable_Cell);

%%

plot([OutputTable_Cell{:,7}])
pause(Pause_Time);
close all

analyzeNetwork(InputNet);

% %%
% 
% NumData = [10,20];
% 
% MeanData = [10,12;80,82];
% 
% STDData = [4,5;5,6];
% 
% Series_1_1 = randn(NumData(1),1)*STDData(1,1) + MeanData(1,1);
% Series_1_2 = randn(NumData(1),1)*STDData(1,2) + MeanData(1,2);
% Series_2_1 = randn(NumData(2),1)*STDData(2,1) + MeanData(2,1);
% Series_2_2 = randn(NumData(2),1)*STDData(2,2) + MeanData(2,2);
% 
% 
% [H_1,P_1,CI_1,Stats_1] = ttest2(Series_1_1,Series_1_2,"Vartype","unequal");
% [H_2,P_2,CI_2,Stats_2] = ttest2(Series_2_1,Series_2_2,"Vartype","unequal");
% 
% Mean_1_1 = mean(Series_1_1);
% Mean_1_2 = mean(Series_1_2);
% Mean_2_1 = mean(Series_2_1);
% Mean_2_2 = mean(Series_2_2);
% 
% STD_1_1 = std(Series_1_1);
% STD_1_2 = std(Series_1_2);
% STD_2_1 = std(Series_2_1);
% STD_2_2 = std(Series_2_2);
% 
% STE_1_1 = STD_1_1/sqrt(NumData(1));
% STE_1_2 = STD_1_2/sqrt(NumData(1));
% STE_2_1 = STD_2_1/sqrt(NumData(2));
% STE_2_2 = STD_2_2/sqrt(NumData(2));
% 
% T_1 = (Mean_1_1-Mean_1_2)/sqrt(STE_1_1^2+STE_1_2^2);
% T_2 = (Mean_2_1-Mean_2_2)/sqrt(STE_2_1^2+STE_2_2^2);
% 
% DF_1 = ((STE_1_1^2+STE_1_2^2)^2)/(((STE_1_1^2)^2)/(NumData(1)-1)+((STE_1_2^2)^2)/(NumData(1)-1));
% DF_2 = ((STE_2_1^2+STE_2_2^2)^2)/(((STE_2_1^2)^2)/(NumData(2)-1)+((STE_2_2^2)^2)/(NumData(2)-1));
% 
% P_Value_1 = tcdf(-abs(T_1),DF_1) + tcdf(abs(T_1),DF_1,'upper');
% P_Value_2 = tcdf(-abs(T_2),DF_2) + tcdf(abs(T_2),DF_2,'upper');
% 
% Difference_1 = Series_1_1 - Series_1_2;
% Difference_2 = Series_2_1 - Series_2_2;
% 
% [H_Diff,P_Diff,CI_Diff,Stats_Diff] = ttest2(Difference_1,Difference_2,"Vartype","unequal");
% 
% Mean_Difference_1 = mean(Difference_1);
% Mean_Difference_2 = mean(Difference_2);
% 
% STD_Difference_1 = std(Difference_1);
% STD_Difference_2 = std(Difference_2);
% 
% STE_Difference_1 = STD_Difference_1/sqrt(NumData(1));
% STE_Difference_2 = STD_Difference_2/sqrt(NumData(2));
% 
% T_Difference = (Mean_Difference_1-Mean_Difference_2)/sqrt(STE_Difference_1^2+STE_Difference_2^2);
% 
% DF_Difference = ((STE_Difference_1^2+STE_Difference_2^2)^2)/(((STE_Difference_1^2)^2)/(NumData(1)-1)+((STE_Difference_2^2)^2)/(NumData(2)-1));
% 
% P_Difference = tcdf(-abs(T_Difference),DF_Difference) + tcdf(abs(T_Difference),DF_Difference,'upper');


