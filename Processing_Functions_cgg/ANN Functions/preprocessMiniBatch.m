function [X,Y,numObs] = preprocessMiniBatch(XCell,YCell)

numObs = numel(YCell);

% Preprocess predictors.
X = preprocessMiniBatchPredictors(XCell);

% Extract class data from cell and concatenate.
Y = cat(2,YCell{1:end});

% One-hot encode classes.
Y = onehotencode(Y,1);

end