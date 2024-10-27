function [Gradients,loss,LossValues] = cgg_calcNetworkLossFromDataStore(net,DataStore,DataFormat,LossFunction,varargin)
%CGG_CALCNETWORKLOSSFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
maxworkerMiniBatchSize = CheckVararginPairs('maxworkerMiniBatchSize', 10, varargin{:});
else
if ~(exist('maxworkerMiniBatchSize','var'))
maxworkerMiniBatchSize=10;
end
end
% 
% NumTrials = numpartions(DataStore_Training);
% 
% numWorkers = ceil(NumTrials/maxworkerMiniBatchSize);
% 
% workerMiniBatchSize = floor(NumTrials ./ repmat(numWorkers,1,numWorkers));
% 

NumTrials = numpartions(DataStore_Training);

workerMbq = minibatchqueue(DataStore,...
        MiniBatchSize=maxworkerMiniBatchSize,...
        MiniBatchFormat=DataFormat);

Iteration = 0;

while hasdata(workerMbq) && ~stopRequest

    Iteration = Iteration + 1;

    net=resetState(net);

    % Read a mini-batch of data.
    [workerX,workerT] = next(workerMbq);
    workerMiniBatchSize = size(workerT,finddim(workerT,"B"));
    workerNormalizationFactor = workerMiniBatchSize./NumTrials;

    [workerLoss,workerGradients,~,workerAccuracy,workerLossReconstruction,workerLossClassification,workerLossKL,workerWindow_Accuracy,workerCombined_Accuracy_Measure,workerClassifierOutput] = dlfeval(LossFunction,net,workerX,workerT);

    if Iteration>1
        % Aggregate the losses on all workers.
        loss = loss + workerNormalizationFactor*extractdata(workerLoss);
        LossReconstruction = LossReconstruction + workerNormalizationFactor*extractdata(workerLossReconstruction{1});
        LossClassification = LossClassification + workerNormalizationFactor*extractdata(workerLossClassification{1});
        LossKL = LossKL + workerNormalizationFactor*extractdata(workerLossKL{1});

        UnweigtedLossReconstruction = UnweigtedLossReconstruction + workerNormalizationFactor*extractdata(workerLossReconstruction{2});
        UnweigtedLossClassification = UnweigtedLossClassification + workerNormalizationFactor*extractdata(workerLossClassification{2});
        UnweigtedLossKL = UnweigtedLossKL + workerNormalizationFactor*extractdata(workerLossKL{2});

        % Aggregate the gradients on all workers.
        Gradients.Value = dlupdate(@cgg_aggregateGradients,workerGradients.Value,{workerNormalizationFactor},Gradients.Value);

        Window_TrueValue = cat(2,Window_TrueValue,workerClassifierOutput{1});
        Window_Prediction = cat(2,Window_TrueValue,workerClassifierOutput{2});
    else
        % Aggregate the losses on all workers.
        loss = workerNormalizationFactor*extractdata(workerLoss);
        LossReconstruction = workerNormalizationFactor*extractdata(workerLossReconstruction{1});
        LossClassification = workerNormalizationFactor*extractdata(workerLossClassification{1});
        LossKL = workerNormalizationFactor*extractdata(workerLossKL{1});

        UnweigtedLossReconstruction = workerNormalizationFactor*extractdata(workerLossReconstruction{2});
        UnweigtedLossClassification = workerNormalizationFactor*extractdata(workerLossClassification{2});
        UnweigtedLossKL = workerNormalizationFactor*extractdata(workerLossKL{2});

        % Aggregate the gradients on all workers.
        Gradients = workerGradients;
        Gradients.Value = dlupdate(@cgg_aggregateGradients,workerGradients.Value,{workerNormalizationFactor},NaN);

        Window_TrueValue = workerClassifierOutput{1};
        Window_Prediction = workerClassifierOutput{2};
    end


end

LossValues = {LossReconstruction,UnweigtedLossReconstruction;LossClassification,UnweigtedLossClassification;LossKL,UnweigtedLossKL};


end

