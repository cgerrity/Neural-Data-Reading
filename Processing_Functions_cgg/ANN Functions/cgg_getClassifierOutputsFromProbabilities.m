function [Loss,CM_Table] = cgg_getClassifierOutputsFromProbabilities(T,Y,ClassNames,DataNumber,InLoss,InCM_Table,Normalization_Factor,varargin)
%CGG_GETCLASSIFIEROUTPUTSFROMPROBABILITIES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantLoss = CheckVararginPairs('wantLoss', true, varargin{:});
else
if ~(exist('wantLoss','var'))
wantLoss=true;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', cell(0), varargin{:});
else
if ~(exist('Weights','var'))
Weights=cell(0);
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
NumTimeSteps = CheckVararginPairs('NumTimeSteps', size(Y{1},finddim(Y{1},"T")), varargin{:});
else
if ~(exist('NumTimeSteps','var'))
NumTimeSteps=size(Y{1},finddim(Y{1},"T"));
end
end

if isfunction
NumTrials = CheckVararginPairs('NumBatches', size(Y{1},finddim(Y{1},"B")), varargin{:});
else
if ~(exist('NumBatches','var'))
NumTrials=size(Y{1},finddim(Y{1},"B"));
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
WantGradient = CheckVararginPairs('WantGradient', false, varargin{:});
else
if ~(exist('WantGradient','var'))
WantGradient=false;
end
end

%%

[Window_Prediction,Window_TrueValue,Loss] = cgg_getPredictionFromClassifierProbabilities(T,Y,ClassNames,'wantLoss',wantLoss,'Weights',Weights,'IsQuaddle',IsQuaddle,'LossType',LossType,'NumTimeSteps',NumTimeSteps,'NumBatches',NumTrials);

if ~WantGradient
    Loss = cgg_extractData(Loss);
end

%%
Window_TrueValue_Table = permute(Window_TrueValue,[2,3,1]);
Window_TrueValue_Table = Window_TrueValue_Table(:,1,:);
Window_TrueValue_Table = squeeze(Window_TrueValue_Table);
Window_Prediction_Table = permute(Window_Prediction,[2,3,1]);

if NumTrials == 1
    Window_TrueValue_Table = Window_TrueValue_Table';
end

DataNumber = cgg_extractData(DataNumber);
DataNumber = diag(diag(DataNumber));

%%

for widx=1:NumTimeSteps
    this_WindowName=sprintf('Window_%d',widx);
    this_Window_Prediction = squeeze(Window_Prediction_Table(:,widx,:));

    if NumTrials == 1
    this_Window_Prediction = this_Window_Prediction';
    end
    if widx==1
    CM_Table = table(DataNumber,Window_TrueValue_Table,...
  this_Window_Prediction,'VariableNames',{'DataNumber','TrueValue',this_WindowName});
    else
    CM_Table.(this_WindowName)=this_Window_Prediction;
    end
end

if any(isempty(InLoss)) || any(isnan(InLoss))
% Loss = cellfun(@(y) y*Normalization_Factor,Loss,"UniformOutput",false);
Loss = Loss.*Normalization_Factor;
else
% Loss = cellfun(@(x,y) x+y*Normalization_Factor,InLoss,Loss,"UniformOutput",false);
Loss = InLoss + Loss.*Normalization_Factor;
end

%%

if istable(InCM_Table) || ~isnan(InLoss)
CM_Table = [InCM_Table; CM_Table];
end

end

