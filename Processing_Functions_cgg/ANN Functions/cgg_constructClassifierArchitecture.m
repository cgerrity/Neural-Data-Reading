function Classifier = cgg_constructClassifierArchitecture(NumClasses,varargin)
%CGG_CONSTRUCTCLASSIFIERARCHITECTURE Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
ClassifierName = CheckVararginPairs('ClassifierName', 'Deep LSTM', varargin{:});
else
if ~(exist('ClassifierName','var'))
ClassifierName='Deep LSTM';
end
end

if isfunction
ClassifierHiddenSize = CheckVararginPairs('ClassifierHiddenSize', [25,10,5], varargin{:});
else
if ~(exist('ClassifierHiddenSize','var'))
ClassifierHiddenSize=[25,10,5];
end
end

if isfunction
LossType = CheckVararginPairs('LossType', 'CrossEntropy', varargin{:});
else
if ~(exist('LossType','var'))
LossType='CrossEntropy';
end
end

if isfunction
HiddenSizeBottleNeck = CheckVararginPairs('HiddenSizeBottleNeck', 25, varargin{:});
else
if ~(exist('HiddenSizeBottleNeck','var'))
HiddenSizeBottleNeck=25;
end
end

%%
Classifier_NoInput = cgg_selectClassifier(ClassifierName,NumClasses,LossType,'ClassifierHiddenSize',ClassifierHiddenSize);

% %%
% Classifier = cell(1,length(Classifier_NoInput));
% 
% for didx = 1:length(NumClasses)
% this_LayerName_Input=sprintf("Input_Dim_%d",didx);
% InputClassifier = sequenceInputLayer(HiddenSizeBottleNeck,"Name",this_LayerName_Input);
% 
% this_Classifier = addLayers(Classifier_NoInput{didx},InputClassifier);
% this_Classifier = connectLayers(this_Classifier,this_LayerName_Input,...
%     this_Classifier.Layers(1).Name);
% 
% this_Classifier = dlnetwork(this_Classifier);
% Classifier{didx} = this_Classifier;
% end

%%

Input_LayerName="Input_Classifier";
InputClassifier = sequenceInputLayer(HiddenSizeBottleNeck,"Name",Input_LayerName);
Classifier = layerGraph(InputClassifier);

for didx = 1:length(NumClasses)

Classifier = addLayers(Classifier,Classifier_NoInput{didx}.Layers);

Classifier = connectLayers(Classifier,Input_LayerName,...
    Classifier_NoInput{didx}.Layers(1).Name);
end

Classifier = dlnetwork(Classifier);

%%

% ClassNames = {[0],[0,1,2,3],[0,1,2,3],[0,1,2,3]};
% NumBatches = 10;
% % NumWindows = 1;
% 
% T = NaN([length(NumClasses),NumBatches,1]);
% 
% for didx = 1:length(ClassNames)
% this_ClassNames = ClassNames{didx};
% T(didx,:,:) = randi(length(this_ClassNames),[1,NumBatches,NumWindows]);
% T(didx,:,:) = ClassNames{didx}(T(didx,:,:));
% end
% 
% T = dlarray(T,'CBT');

end

