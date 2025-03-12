clc; clear; close all;

%% Parameters

NumTargets = 10000;
Ground_Truth_Distribution = [10;10;80];

GroundTruth_FullDistribution = cell(0); IDX = 0;
IDX = IDX + 1; GroundTruth_FullDistribution{IDX} = [100;10;10;50];
IDX = IDX + 1; GroundTruth_FullDistribution{IDX} = [100;20;10;30];
IDX = IDX + 1; GroundTruth_FullDistribution{IDX} = [100;10;10;50];
IDX = IDX + 1; GroundTruth_FullDistribution{IDX} = 1;

% NumPredictionIndices = 1000;
%%

IsQuaddle = true;
MatchType_1 = 'Scaled-BalancedAccuracy';
% MatchType = 'BalancedAccuracy';
MatchType_2 = 'Scaled-macroaccuracy';
% MatchType = 'macroaccuracy';
% MatchType = 'Scaled-exact';
% MatchType = 'exact';

Weights = zeros(NumTargets,IDX);
Weights(:,1) = 1;

Weight_Temp = diag(ones(1,4));
Weight_Temp(1,1) = 1/2;
Weight_Temp(1,2) = 1/2;
Weight_Random = randi(4,[NumTargets,1]);
Weights = Weight_Temp(Weight_Random,:);

%%

% GoodPrediction_Percent_Range = linspace(0,1,NumPredictionIndices);
% PerformanceMetric_Range = NaN(NumPredictionIndices,1);

% parfor pidx = 1:NumPredictionIndices

GoodPrediction_Percent = 0.8;
% GoodPrediction_Percent = GoodPrediction_Percent_Range(pidx);

%% Generate Data

Ground_Truth_Count = round(Ground_Truth_Distribution/sum(Ground_Truth_Distribution)*NumTargets);
GroundTruth_FullCount = cellfun(@(x) ceil(x/sum(x)*NumTargets),GroundTruth_FullDistribution,'UniformOutput',false);

Prediction_Bad_Amount = round((1-GoodPrediction_Percent)*NumTargets);

NumLabels = length(GroundTruth_FullCount);
GroundTruth = cell(1,NumLabels);
Prediction = cell(1,NumLabels);
ClassNames = cell(1,NumLabels);

for lidx = 1:NumLabels
this_GroundTruth_Count = GroundTruth_FullCount{lidx};
this_NumClasses = numel(this_GroundTruth_Count);

this_ClassNames = 0:(this_NumClasses-1);

this_GroundTruth = [];
for cidx = 1:this_NumClasses
this_GroundTruth = [this_GroundTruth;ones(this_GroundTruth_Count(cidx),1)*this_ClassNames(cidx)];
end
this_GroundTruth = this_GroundTruth(1:NumTargets);

this_Permutation = randperm(NumTargets);
[~,this_ReversePermutation] = sort(this_Permutation);
this_GroundTruth = this_GroundTruth(this_Permutation);

this_BadIDX = 1:NumTargets;
this_BadIDX = this_BadIDX(randperm(NumTargets));
this_BadIDX = this_BadIDX(1:Prediction_Bad_Amount);

this_Prediction = this_GroundTruth;
% this_BadPrediction = this_Prediction(this_BadIDX);
% this_BadPrediction = this_BadPrediction(randperm(Prediction_Bad_Amount));
this_BadPrediction = randi([0,this_NumClasses-1],Prediction_Bad_Amount,1);
this_Prediction(this_BadIDX) = this_BadPrediction;

GroundTruth{lidx} = this_GroundTruth;
Prediction{lidx} = this_Prediction;
ClassNames{lidx} = this_ClassNames;
end

TrueValue = cell2mat(GroundTruth);
Prediction = cell2mat(Prediction);

%%

NeutralIDX = TrueValue==0;
Weights(NeutralIDX) = 0;

%%


PerformanceMetric_1 = cgg_calcAllPerformanceMetrics(...
    TrueValue,Prediction,ClassNames,'IsQuaddle',IsQuaddle,'MatchType',MatchType_1,'Weights',Weights);

PerformanceMetric_2 = cgg_calcAllPerformanceMetrics(...
    TrueValue,Prediction,ClassNames,'IsQuaddle',IsQuaddle,'MatchType',MatchType_2,'Weights',Weights);
% PerformanceMetric_Range(pidx) = PerformanceMetric;
% end



%%

% plot(GoodPrediction_Percent_Range,PerformanceMetric_Range)