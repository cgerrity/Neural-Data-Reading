function [TruePositives,TotalObservations,Accuracy] = cgg_getStatisticsFromSingleConfusionMatrix(ConfusionMatrix)
%CGG_GETACCURACYFROMSINGLECONFUSIONMATRIX Summary of this function goes here
%   Detailed explanation goes here


TruePositives = trace(ConfusionMatrix);
TotalObservations = sum(ConfusionMatrix(:));
Accuracy = TruePositives/TotalObservations;

end

