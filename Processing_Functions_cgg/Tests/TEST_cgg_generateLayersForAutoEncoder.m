

clc; clear; close all;


%%

HiddenSizes = [50,25];
LatentSize = [10];

wantClassifier = true;
Pause_Time = 5;

% ModelName = 'Feedforward - ReLU';
% ModelName = 'Feedforward - ReLU - Normalized';
% ModelName = 'Feedforward - ReLU - Normalized - Dropout 0.5';
% ModelName = 'Feedforward - Softplus';
% ModelName = 'Feedforward - Softplus - Dropout 0.5';
% ModelName = 'Feedforward - Softplus - Dropout 0.5 - Skip 0.9';
% ModelName = 'Variational Feedforward - Softplus - Dropout 0.5';
% ModelName = 'Variational GRU - Dropout 0.5';
% ModelName = 'LSTM';
ModelName = 'LSTM - Normalized';
% ModelName = 'Convolution';
% ModelName = 'Multi-Filter Convolution';

% ClassifierName = 'Deep LSTM - Dropout 0.5';
ClassifierName = 'Deep Feedforward - Dropout 0.5';
LossType = 'Classification';
ClassifierHiddenSize = [500];

NumChannels = 20;
DataWidth = 100;
NumWindows = 10;
NumAreas = 6;
NumExamples = 7;

NumClasses = [1,4,4,4];

DataFormat='SSCTB';

%%
X_TEST=randn(NumChannels,DataWidth,NumAreas,NumWindows,NumExamples);
X_TEST = dlarray(X_TEST,DataFormat);

HiddenSizes = [HiddenSizes,LatentSize];

%%

DataSize=size(X_TEST);
InputSize = NaN(1,3);

InputSize(1:2)=DataSize(finddim(X_TEST,"S"));
InputSize(3)=DataSize(finddim(X_TEST,"C"));
NumTimeWindows=DataSize(finddim(X_TEST,"T"));

ReshapeInputSize=[InputSize,NumTimeWindows,0];

NumStacks=numel(HiddenSizes);
NumAreas = InputSize(3);
NumChannels = InputSize(1);

% Layers_Custom= dlnetwork(layerGraph([ ...
%     sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
%     fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace"), ...
%     fullyConnectedLayer(prod(InputSize,"all"),"Name","fc_Decoder_Out"), ...
%     functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_Decoder"), ...
%     reshapeLayer("reshape_Decoder",ReshapeInputSize,DataFormat) 
%     ]));

Layers_Custom= dlnetwork(layerGraph([ ...
    sequenceInputLayer(InputSize,"Name","sequence_Encoder"), ...
    fullyConnectedLayer(HiddenSizes(1),"Name","Layer_To_Replace")
    ]));


%%

% FilterSize=InputSize(2)/2;

Layers_AutoEncoder=[];
Layers_AutoEncoder = [fullyConnectedLayer(HiddenSizes(1),"Name",'fc_Encoder')];

FilterSize = InputSize(2);
% StrideSize = InputSize(3);
FilterFactor = 2;
StrideFactor = FilterFactor;


this_StrideSize_Decoder = round(InputSize(2)/(FilterFactor^(length(HiddenSizes))));

FilterSize = FilterSize./(FilterFactor.^(1:length(HiddenSizes)));
FilterSize = ceil(FilterSize);
StrideSize = FilterSize./(StrideFactor);
StrideSize = ceil(StrideSize);
StrideSize = ceil(StrideSize*0+StrideFactor);

StrideSize_Decoder = StrideSize;

%%
% ceil(InputSize(2)/(FilterSize*(1/FilterFactor)*(1/StrideFactor)))
% Size_DecoderBottleNeck = FilterSize*(1/FilterFactor)^(NumStacks)
% 
% Layers_AutoEncoder = [
%         fullyConnectedLayer(HiddenSizes(end),"Name",'fc_Encoder')
%         softplusLayer("Name",'activation_Encoder')
%         fullyConnectedLayer(HiddenSizes(1),"Name",'fc_Decoder')
%         functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_BottleNeck")
%         ];
Layers_AutoEncoder = [
        fullyConnectedLayer(HiddenSizes(end),"Name",'fc_Encoder')
        softplusLayer("Name",'activation_Encoder')
        functionLayer(@(X) dlarray(X,"CBTSS"),Formattable=true,Acceleratable=true,Name="Function_BottleNeck")
        transposedConv2dLayer([NumChannels,FilterSize(end)],NumAreas,"Name","Convolution_BottleNeck")
        ];
%         transposedConv2dLayer([2,2],NumAreas,"Name","Convolution_BottleNeck")
% fullyConnectedLayer()

for stidx=NumStacks:-1:1
    this_HiddenSize=HiddenSizes(stidx);

    this_Encoder_LayerName=sprintf("name_Encoder_%d",stidx);
    this_Decoder_LayerName=sprintf("name_Decoder_%d",stidx);

    this_Encoder_ConvolutionalName=sprintf("convolutional_Encoder_%d",stidx);
    this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx);
    this_Decoder_ConvolutionalName=sprintf("convolutional_Decoder_%d",stidx);
    this_Decoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Decoder_%d",stidx);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    % this_Encoder_DepthToSpaceName=sprintf("depthtospace_Encoder_%d",stidx);

    this_Encoder_FullyConnectedName=sprintf("fc_Encoder_%d",stidx);
    this_Encoder_ActivationName=sprintf("activation_Encoder_%d",stidx);
    
    this_Decoder_FullyConnectedName=sprintf("fc_Decoder_%d",stidx);
    this_Decoder_ActivationName=sprintf("activation_Decoder_%d",stidx);

    % convolution2dLayer([1,FilterSize],this_HiddenSize,"Name",this_Encoder_ConvolutionalName,"Padding",'same')

    this_FilterSize = FilterSize(stidx);
    this_StrideSize = StrideSize(stidx);
    % StrideSize = round(FilterSize/StrideFactor);
    this_StrideSize_Decoder = StrideSize_Decoder(stidx);
    
    this_Layer_Encoder = [
        groupedConvolution2dLayer([1,this_FilterSize],this_HiddenSize,'channel-wise',"Name",this_Encoder_ConvolutionalName,"Padding",'same','Stride',[1,this_StrideSize])
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Encoder_PointWiseConvolutionalName,"Padding",'same')
        reluLayer("Name",this_Encoder_ActivationName)];
    % Add 1x1 convolution over the corresponding channels to reduce the
    % channels back to the number of areas?
    % this_Layer_Decoder = [];
    % this_Layer_Decoder = [
    %     transposedConv2dLayer([1,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[1,this_StrideSize_Decoder],"Cropping","same","Name",this_Decoder_ConvolutionalName)
    %     groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same')
    %     reluLayer("Name",this_Decoder_ActivationName)];
    this_Layer_Decoder = [
        transposedConv2dLayer([1,this_FilterSize],this_HiddenSize*NumAreas,"Stride",[1,this_StrideSize_Decoder],"Cropping","same","Name",this_Decoder_ConvolutionalName)
        groupedConvolution2dLayer([1,1],1,NumAreas,"Name",this_Decoder_PointWiseConvolutionalName,"Padding",'same')
        crop2dLayer('centercrop','Name',this_Decoder_CropName)
        reluLayer("Name",this_Decoder_ActivationName)];

    Layers_AutoEncoder=[
        this_Layer_Encoder
        Layers_AutoEncoder
        this_Layer_Decoder];

end

if ~isempty(Layers_AutoEncoder)
Layers_Custom = replaceLayer(Layers_Custom,'Layer_To_Replace',Layers_AutoEncoder);
end

%%
this_Decoder_CropName = sprintf("crop_Decoder_%d",1);
Layers_Custom = connectLayers(Layers_Custom,Layers_Custom.Layers(1).Name,this_Decoder_CropName + "/ref");

for stidx = 2:NumStacks
    this_Encoder_PointWiseConvolutionalName=sprintf("point-wise_convolutional_Encoder_%d",stidx-1);
    this_Decoder_CropName = sprintf("crop_Decoder_%d",stidx);
    Layers_Custom = connectLayers(Layers_Custom,this_Encoder_PointWiseConvolutionalName,this_Decoder_CropName + "/ref");
end

% Layers_Custom = connectLayers(Layers_Custom,this_Encoder_PointWiseConvolutionalName,[this_Decoder_CropName '/ref'])

%%
Layers_Custom_func = cgg_selectAutoEncoder(ModelName,InputSize,HiddenSizes,NumWindows,DataFormat);
% Layers_Custom_func = cgg_generateLayersForConvolutionalEncoder(InputSize,HiddenSizes,LatentSize);
% Layers_Custom_func = cgg_generateLayersForReccurentEncoder(InputSize,HiddenSizes,NumWindows,DataFormat);
% Layers_Custom_func = removeLayers(Layers_Custom_func,{Layers_Custom_func.Layers(33:44).Name});
NetBase= initialize(Layers_Custom_func);

if wantClassifier
Layers_Classifier = cgg_selectClassifier(ClassifierName,NumClasses,LossType,'ClassifierHiddenSize',ClassifierHiddenSize);
NetFull = cgg_constructClassifierNetwork_v2(NetBase,Layers_Classifier);
else
    NetFull = NetBase;
end
% InputNet= initialize(Layers_Custom);
InputNet= initialize(NetFull);

% LastLayerIDX = 10;
% Remove_Layers = [1:20,22:43];
% InputSize_Modified = [100];
% 
% InputNet_Modified = removeLayers(InputNet,{InputNet.Layers(Remove_Layers).Name});
% InputNet_Modified = addLayers(InputNet_Modified,sequenceInputLayer(InputSize_Modified,"Name","sequence_Encoder"));
% InputNet_Modified = connectLayers(InputNet_Modified,"sequence_Encoder","activation_Encoder");
% 
% X_TEST_Modified=randn(100,7,10);
% X_TEST_Modified(1,1,1) = 0;
% X_TEST_Modified = dlarray(X_TEST_Modified,'CBT');
% 
% InputNet_Modified = initialize(InputNet_Modified);

%%

% X_TEST(1,1,1,1,1)=1000;
% InputNet_Modified = cgg_resetState(InputNet_Modified);
% OutputNames_Modified={InputNet_Modified.Layers(:).Name};
% OutputExample_Modified=cell(1,length(OutputNames_Modified));
% [OutputExample_Modified{:}]=forward(InputNet_Modified,X_TEST_Modified,Outputs=OutputNames_Modified);

OutputNames=cellfun(@(x) [x '/out'],{InputNet.Layers(:).Name},'UniformOutput',false);
OutputExample=cell(1,length(OutputNames));
[OutputExample{:}]=forward(InputNet,X_TEST,Outputs=OutputNames);

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

plot([OutputTable_Cell{:,7}])
pause(Pause_Time);
close all

% sel_Channel = 1:6;
% aaaa = squeeze(extractdata(OutputExample{IDX}(1,1,sel_Channel,1,1)));

% %%
% 
% OutputTable_Cell_Modified = cell(length(OutputExample_Modified),5);
% for IDX = 1:length(OutputNames_Modified)
%     OutputTable_Cell_Modified{IDX,1} = OutputNames_Modified{IDX};
%     OutputTable_Cell_Modified{IDX,2} = IDX;
%     OutputTable_Cell_Modified{IDX,3} = OutputExample_Modified{IDX}.dims;
%     OutputTable_Cell_Modified{IDX,4} = size(OutputExample_Modified{IDX});
%     OutputTable_Cell_Modified{IDX,5} = numel(OutputExample_Modified{IDX});
%     OutputTable_Cell_Modified{IDX,6} = [min(extractdata(OutputExample_Modified{IDX}(:))),max(extractdata(OutputExample_Modified{IDX}(:)))];
%     % OutputTable_Cell{IDX} = {OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))};
% % disp({OutputNames{IDX},IDX,OutputExample{IDX}.dims, size(OutputExample{IDX}),prod(size(OutputExample{IDX}))})
% end
% 
% OutputTable_Modified = table(OutputTable_Cell_Modified);

%%

% GradientValues = workerGradients.Value(WeightIDX);
% for gidx = 1:length(GradientValues)
%   MeanThresholdGradient(iteration,gidx) = mean(GradientValues{gidx},"all");
%   STDThresholdGradient(iteration,gidx) = std(GradientValues{gidx},[],"all");
% end



% %%
% 
% NumTrials = 100;
% Split = ceil(rand(1)*NumTrials);
% ClassNumber = 3;
% MatchType = 'macroF1';
% 
% TrueValue = randi(ClassNumber,[NumTrials,1]);
% Prediction = randi(ClassNumber,[NumTrials,1]);
% TrueValue_1 = TrueValue(1:Split);
% TrueValue_2 = TrueValue(Split+1:NumTrials);
% Prediction_1 = Prediction(1:Split);
% Prediction_2 = Prediction(Split+1:NumTrials);
% ClassNames = {1:ClassNumber};
% 
% Num_1 = length(TrueValue_1);
% Num_2 = length(TrueValue_2);
% 
% Weight_1 = Num_1/NumTrials;
% Weight_2 = Num_2/NumTrials;
% 
% Accuracy = cgg_calcAllAccuracyTypes(TrueValue,Prediction,ClassNames,MatchType);
% Accuracy_1 = cgg_calcAllAccuracyTypes(TrueValue_1,Prediction_1,ClassNames,MatchType);
% Accuracy_2 = cgg_calcAllAccuracyTypes(TrueValue_2,Prediction_2,ClassNames,MatchType);
% Accuracy_12 = Weight_1*Accuracy_1+Weight_2*Accuracy_2;

% %%
% 
% groupSize = 3;
% totalIndices = 20;
% cellArray = cgg_getIndicesIntoGroups(groupSize,totalIndices);
% disp(cellArray);
% 
% 
% %%
% 
% % Define your indices
% indices = 1:20;
% 
% % Define the size of each group
% groupSize = 3;
% 
% % Calculate the number of full groups
% numFullGroups = floor(numel(indices) / groupSize);
% 
% % Calculate the number of remaining indices
% numRemainingIndices = rem(numel(indices), groupSize);
% 
% % Initialize a cell array to store the groups
% cellArray = cell(1, numFullGroups + (numRemainingIndices > 0));
% 
% % Loop over full groups
% for i = 1:numFullGroups
%     % Get indices for the current group
%     startIdx = (i - 1) * groupSize + 1;
%     endIdx = i * groupSize;
%     cellArray{i} = indices(startIdx:endIdx);
% end
% 
% % Add remaining indices as a separate group
% if numRemainingIndices > 0
%     startIdx = numFullGroups * groupSize + 1;
%     cellArray{end} = indices(startIdx:end);
% end
% 
% % Display the cell array
% disp(cellArray);
% 
% 
% %%
% 
% clc; clear; close all;
% 
% PlotLineWidth = 3;
% FontSizeLabel = 20;
% 
% NumProbabilities = 100;
% 
% NumIter = 1000;
% NumTargets = 10000;
% 
% Probabilities = linspace(0,1,NumProbabilities);
% 
% Accuracy_Overall_MostCommon = NaN(1,NumProbabilities);
% Accuracy_Overall_Stratified = NaN(1,NumProbabilities);
% Balanced_Accuracy_Overall_Stratified = NaN(1,NumProbabilities);
% Balanced_Accuracy_Overall_MostCommon = NaN(1,NumProbabilities);
% 
% for pidx = 1:NumProbabilities
% 
% % Probability_Target = 0.8;
% % Probability_Prediction = 0.8;
% 
% Probability_Target = Probabilities(pidx);
% Probability_Prediction = Probabilities(pidx);
% 
% Accuracy_All_Stratified = NaN(1,NumIter);
% Accuracy_All_MostCommon = NaN(1,NumIter);
% Balanced_Accuracy_All_Stratified = NaN(1,NumIter);
% Balanced_Accuracy_All_MostCommon = NaN(1,NumIter);
% Accuracy_1_Stratified = NaN(1,NumIter);
% Accuracy_0_Stratified = NaN(1,NumIter);
% Accuracy_1_MostCommon = NaN(1,NumIter);
% Accuracy_0_MostCommon = NaN(1,NumIter);
% Prediction_Probability_All = NaN(1,NumIter);
% 
% Target = rand(NumTargets,1) < Probability_Target;
% 
% Class_1 = Target == 1;
% Class_0 = Target == 0;
% 
% parfor idx=1:NumIter
% 
% Prediction_Stratified = rand(NumTargets,1) < Probability_Prediction;
% Prediction_MostCommon = ones(NumTargets,1) * round(Probability_Target);
% 
% IsCorrect_Stratified = Prediction_Stratified == Target;
% IsCorrect_MostCommon = Prediction_MostCommon == Target;
% 
% Accuracy_1_Stratified(idx) = sum(IsCorrect_Stratified(Class_1))/sum(Class_1);
% Accuracy_0_Stratified(idx) = sum(IsCorrect_Stratified(Class_0))/sum(Class_0);
% Accuracy_1_MostCommon(idx) = sum(IsCorrect_MostCommon(Class_1))/sum(Class_1);
% Accuracy_0_MostCommon(idx) = sum(IsCorrect_MostCommon(Class_0))/sum(Class_0);
% 
% Accuracy_All_Stratified(idx) = sum(IsCorrect_Stratified)/length(IsCorrect_Stratified);
% Accuracy_All_MostCommon(idx) = sum(IsCorrect_MostCommon)/length(IsCorrect_MostCommon);
% Balanced_Accuracy_All_Stratified(idx) = mean([Accuracy_1_Stratified(idx),Accuracy_0_Stratified(idx)]);
% Balanced_Accuracy_All_MostCommon(idx) = mean([Accuracy_1_MostCommon(idx),Accuracy_0_MostCommon(idx)]);
% 
% Prediction_Probability_All(idx) = sum(Prediction_Stratified)/length(Prediction_Stratified);
% 
% end
% 
% Accuracy_Overall_Stratified(pidx) = mean(Accuracy_All_Stratified);
% Accuracy_Overall_MostCommon(pidx) = mean(Accuracy_All_MostCommon);
% Balanced_Accuracy_Overall_Stratified(pidx) = mean(Balanced_Accuracy_All_Stratified);
% Balanced_Accuracy_Overall_MostCommon(pidx) = mean(Balanced_Accuracy_All_MostCommon);
% Target_Probability = sum(Target)/length(Target);
% Prediction_Probability = mean(Prediction_Probability_All);
% end
% 
% plot(Probabilities,Accuracy_Overall_Stratified,"DisplayName","Accuracy - Stratified","LineWidth",PlotLineWidth);
% hold on
% plot(Probabilities,Accuracy_Overall_MostCommon,"DisplayName","Accuracy - Most Common","LineWidth",PlotLineWidth);
% plot(Probabilities,Balanced_Accuracy_Overall_Stratified,"DisplayName","Balanced Accuracy - Stratified","LineWidth",PlotLineWidth);
% plot(Probabilities,Balanced_Accuracy_Overall_MostCommon,"DisplayName","Balanced Accuracy - Most Common","LineWidth",PlotLineWidth);
% hold off
% legend
% 
% xlabel('Class 1 Frequency','FontSize',FontSizeLabel);
% ylabel('Accuracy','FontSize',FontSizeLabel)
% 
% ylim([0.45,1]);
% 
% %% Cohen Testing
% 
% clc; clear; close all;
% 
% NumTargets = 100;
% Ground_Truth_Distribution = [1,1000,10000];
% 
% PredictionType = "Good Biased"; % "Good Biased", "Good", "Stratified", "Most Common"
% 
% GoodPrediction_Percent = 0.98;
% 
% GoodPrediction_Amount = round(GoodPrediction_Percent*NumTargets);
% BadPrediction_Amount = round((1-GoodPrediction_Percent)*NumTargets);
% 
% Ground_Truth_Distribution = round(Ground_Truth_Distribution/sum(Ground_Truth_Distribution)*NumTargets);
% 
% NumGround_Truth = sum(Ground_Truth_Distribution);
% NumClasses = numel(Ground_Truth_Distribution);
% Probability_Ground_Truth = Ground_Truth_Distribution/NumGround_Truth;
% 
% Ground_Truth = [];
% 
% for cidx = 1:NumClasses
% Ground_Truth = [Ground_Truth;ones(Ground_Truth_Distribution(cidx),1)*(cidx-1)];
% end
% 
% Prediction_Good_Biased = Ground_Truth;
% Prediction_Good_Biased(1:BadPrediction_Amount) = (randi(3,BadPrediction_Amount,1)-1);
% 
% Permutation_Ground_Truth = randperm(NumGround_Truth);
% 
% Ground_Truth = Ground_Truth(Permutation_Ground_Truth);
% Prediction_Good_Biased = Prediction_Good_Biased(Permutation_Ground_Truth);
% 
% Prediction_Stratified = Ground_Truth(randperm(NumGround_Truth));
% Prediction_MostCommon = ones(NumGround_Truth,1) * mode(Ground_Truth);
% Prediction_Good = Ground_Truth;
% Prediction_Good(1:BadPrediction_Amount) = Prediction_Good(randperm(BadPrediction_Amount));
% 
% switch PredictionType
%     case "Good Biased"
%         this_Prediciton = Prediction_Good_Biased;
%     case "Good"
%         this_Prediciton = Prediction_Good;
%     case "Stratified"
%         this_Prediciton = Prediction_Stratified;
%     case "Most Common"
%         this_Prediciton = Prediction_MostCommon;
% end
% 
% Chance_Probability = 0;
% 
% for idx = 1:length(Ground_Truth_Distribution)
% Chance_Probability = Chance_Probability+sum(this_Prediciton==(idx-1))*sum(Ground_Truth==(idx-1));
% end
% 
% Chance_Probability = Chance_Probability/(NumGround_Truth^2);
% 
% ConfusionMatrix = confusionmat(Ground_Truth,this_Prediciton);
% 
% Accuracy = trace(ConfusionMatrix)/sum(ConfusionMatrix(:));
% 
% Kappa_C = trace(ConfusionMatrix);
% Kappa_S = sum(ConfusionMatrix(:));
% Kappa_P = sum(ConfusionMatrix,2);
% Kappa_T = sum(ConfusionMatrix,1);
% 
% Cohens_Kappa_cgg = (Accuracy-Chance_Probability)/(1-Chance_Probability);
% Cohens_Kappa = (Kappa_C*Kappa_S-Kappa_T*Kappa_P)/(Kappa_S*Kappa_S-Kappa_T*Kappa_P);
% 
% [FullClassCM] = cgg_calcClassConfusionMatrix(Ground_Truth,this_Prediciton,{0:NumClasses});
% LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);
% 
% BalancedAccuracy_Rescaled = (LabelMetrics.MacroRecall-1/NumClasses)/(1-1/NumClasses);
% 
% 
% % Chance_Probability_Varying = NaN(NumGround_Truth+1,1);
% % 
% % for pidx = 1:NumGround_Truth*4
% % 
% % Prediction_Varying_Distribution = [(pidx-1),1,NumTargets*2];
% % Prediction_Varying_Distribution = round(Prediction_Varying_Distribution/sum(Prediction_Varying_Distribution)*NumTargets);
% % 
% % Prediction_Varying = [];
% % 
% % for cidx = 1:NumClasses
% % Prediction_Varying = [Prediction_Varying;ones(Prediction_Varying_Distribution(cidx),1)*(cidx-1)];
% % end
% % 
% % this_Prediciton = Prediction_Varying;
% % 
% % Chance_Probability = 0;
% % 
% % for idx = 1:length(Ground_Truth_Distribution)
% % Chance_Probability = Chance_Probability+sum(this_Prediciton==(idx-1))*sum(Ground_Truth==(idx-1));
% % end
% % 
% % Chance_Probability = Chance_Probability/(NumGround_Truth^2);
% % Chance_Probability_Varying(pidx) = Chance_Probability;
% % end
% % 
% % plot(Chance_Probability_Varying)
% 
