
clc; clear; close all;

%% Parameters

NumTargets = 10;
Ground_Truth_Distribution = [10,10,80];

PredictionType = "Good Biased"; % "Good Biased", "Good", "Stratified", "Most Common"

GoodPrediction_Percent = 0.8;


%% Generate Data

Ground_Truth_Distribution = round(Ground_Truth_Distribution/sum(Ground_Truth_Distribution)*NumTargets);

NumGround_Truth = sum(Ground_Truth_Distribution);
NumClasses = numel(Ground_Truth_Distribution);
Probability_Ground_Truth = Ground_Truth_Distribution/NumGround_Truth;

Ground_Truth = [];

ClassNames = {1:NumClasses};

for cidx = 1:NumClasses
Ground_Truth = [Ground_Truth;ones(Ground_Truth_Distribution(cidx),1)*ClassNames{1}(cidx)];
end

Permutation_Ground_Truth = randperm(NumGround_Truth);
[~,ReversePermutation_Ground_Truth] = sort(Permutation_Ground_Truth);
Ground_Truth = Ground_Truth(Permutation_Ground_Truth);

%% Predictions

Prediction_Good_Amount = round(GoodPrediction_Percent*NumTargets);
Prediction_Bad_Amount = round((1-GoodPrediction_Percent)*NumTargets);

Prediction_Good_Biased = Ground_Truth(ReversePermutation_Ground_Truth);
Prediction_Good_Biased(1:Prediction_Bad_Amount) = ClassNames{1}(randi(3,Prediction_Bad_Amount,1));

Prediction_Good_Biased = Prediction_Good_Biased(Permutation_Ground_Truth);

Prediction_Stratified = Ground_Truth(randperm(NumGround_Truth));
Prediction_MostCommon = ones(NumGround_Truth,1) * mode(Ground_Truth);
Prediction_Good = Ground_Truth;
Prediction_Good(1:Prediction_Bad_Amount) = Prediction_Good(randperm(Prediction_Bad_Amount));

switch PredictionType
    case "Good Biased"
        this_Prediciton = Prediction_Good_Biased;
    case "Good"
        this_Prediciton = Prediction_Good;
    case "Stratified"
        this_Prediciton = Prediction_Stratified;
    case "Most Common"
        this_Prediciton = Prediction_MostCommon;
end

%% Cohen's Kappa

Chance_Probability = 0;

for idx = 1:length(Ground_Truth_Distribution)
Chance_Probability = Chance_Probability+sum(this_Prediciton==(idx-1))*sum(Ground_Truth==(idx-1));
end

Chance_Probability = Chance_Probability/(NumGround_Truth^2);

ConfusionMatrix = confusionmat(Ground_Truth,this_Prediciton);

Accuracy = trace(ConfusionMatrix)/sum(ConfusionMatrix(:));

Kappa_C = trace(ConfusionMatrix);
Kappa_S = sum(ConfusionMatrix(:));
Kappa_P = sum(ConfusionMatrix,2);
Kappa_T = sum(ConfusionMatrix,1);

Cohens_Kappa_cgg = (Accuracy-Chance_Probability)/(1-Chance_Probability);
Cohens_Kappa = (Kappa_C*Kappa_S-Kappa_T*Kappa_P)/(Kappa_S*Kappa_S-Kappa_T*Kappa_P);

%% Balanced Accuracy

[FullClassCM] = cgg_calcClassConfusionMatrix(Ground_Truth,this_Prediciton,ClassNames);
LabelMetrics = cgg_calcAllLabelMetrics(FullClassCM);

[FullClassCM_Stratified] = cgg_calcClassConfusionMatrix(Ground_Truth,Prediction_Stratified,ClassNames);
LabelMetrics_Stratified = cgg_calcAllLabelMetrics(FullClassCM_Stratified);

BalancedAccuracy_Prediction = LabelMetrics.MacroRecall;
BalancedAccuracy_RandomChance = LabelMetrics_Stratified.MacroRecall;

BalancedAccuracy_Rescaled = (BalancedAccuracy_Prediction-BalancedAccuracy_RandomChance)/(1-BalancedAccuracy_RandomChance);

% %%
% 
% NumProbabilities = 1000;
% 
% NumIter = 100;
% NumTargets = 1000;
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
% plot(Probabilities,Accuracy_Overall_Stratified,"DisplayName","Accuracy - Stratified");
% hold on
% plot(Probabilities,Accuracy_Overall_MostCommon,"DisplayName","Accuracy - Most Common");
% plot(Probabilities,Balanced_Accuracy_Overall_Stratified,"DisplayName","Balanced Accuracy - Stratified");
% plot(Probabilities,Balanced_Accuracy_Overall_MostCommon,"DisplayName","Balanced Accuracy - Most Common");
% hold off
% legend
% 
% ylim([0.45,1]);

%% Cohen Testing


% Chance_Probability_Varying = NaN(NumGround_Truth+1,1);
% 
% for pidx = 1:NumGround_Truth*4
% 
% Prediction_Varying_Distribution = [(pidx-1),1,NumTargets*2];
% Prediction_Varying_Distribution = round(Prediction_Varying_Distribution/sum(Prediction_Varying_Distribution)*NumTargets);
% 
% Prediction_Varying = [];
% 
% for cidx = 1:NumClasses
% Prediction_Varying = [Prediction_Varying;ones(Prediction_Varying_Distribution(cidx),1)*(cidx-1)];
% end
% 
% this_Prediciton = Prediction_Varying;
% 
% Chance_Probability = 0;
% 
% for idx = 1:length(Ground_Truth_Distribution)
% Chance_Probability = Chance_Probability+sum(this_Prediciton==(idx-1))*sum(Ground_Truth==(idx-1));
% end
% 
% Chance_Probability = Chance_Probability/(NumGround_Truth^2);
% Chance_Probability_Varying(pidx) = Chance_Probability;
% end
% 
% plot(Chance_Probability_Varying)

%% Balanced Accuracy Confidence Intervals

NumSamples = 1000;
NumSamples_z = 100;
NumSamples_BS = 100;

CountFactor = 10;

BootStrapFactor = CountFactor;

Positive_Accuracy = 0.9;
Negative_Accuracy = 0.2;

NumPositive = 2;
NumNegative = 1;

% NumPositive = 1;
% NumNegative = 1;

TP_Full = binornd(NumPositive,Positive_Accuracy,1,CountFactor);
FN_Full = NumPositive - TP_Full;
TN_Full = binornd(NumNegative,Negative_Accuracy,1,CountFactor);
FP_Full = NumNegative - TN_Full;

TP = sum(TP_Full);
FN = sum(FN_Full);
TN = sum(TN_Full);
FP = sum(FP_Full);

% TP = 40;
% FP = 8;
% TN = 2;
% FN = 5;
% 
% TP = TP*CountFactor;
% FP = FP*CountFactor;
% TN = TN*CountFactor;
% FN = FN*CountFactor;

x_value = linspace(0,1,NumSamples);
z_value = linspace(0,1,NumSamples_z);
x_value_BS = linspace(0,1,NumSamples_BS);

% PP = (1/(beta(TP+1,FN+1))).*(x_value.^TP).*((1-x_value).^FN);
% PN = (1/(beta(TN+1,FP+1))).*(x_value.^TN).*((1-x_value).^FP);

PA = @(x,C,I) (1/(beta(C+1,I+1))).*(x.^C).*((1-x).^I).*(x>=0).*(x<=1);
% PA = @(x,C,I) (1/(beta(C+1,I+1))).*(x.^C).*((1-x).^I);
P_Mean = @(C,I) (C+1)/(C+I+2);

% PB_1 = @(x,tp,fp,fn,tn) PA(2*(x-z_value),tp+1,fn+1);
% PB_2 = @(x,tp,fp,fn,tn) PA(2*z_value,tn+1,fp+1);

% PB_1 = @(x,tp,fp,fn,tn) PA(2*(x-z_value),tp+1,fn+1);
% PB_2 = @(x,tp,fp,fn,tn) PA(2*z_value,tn+1,fp+1);

% PB_1(this_x,TP,FP,FN,TN)

PB_1 = @(x,tp,fp,fn,tn) betapdf(2*(x-z_value),tp+2,fn+2);
PB_2 = @(x,tp,fp,fn,tn) betapdf(2*z_value,tn+2,fp+2);

% PB = @(x,tp,fp,fn,tn) sum(PA(2*(x-z_value),tp+1,fn+1).*PA(2*z_value,tn+1,fp+1)*(1/NumSamples_z));
PB = @(x,tp,fp,fn,tn) sum(PB_1(x,tp,fp,fn,tn).*PB_2(x,tp,fp,fn,tn)*(1/NumSamples_z));

PP = betapdf(x_value,TP+1,FN+1);
PN = betapdf(x_value,TN+1,FP+1);

PP_Mean = sum(x_value.*PP*(1/NumSamples));
PN_Mean = sum(x_value.*PN*(1/NumSamples));

SmallFactor = 0;

PP_12 = betapdf(x_value,TP+SmallFactor,FN+SmallFactor);
PN_12 = betapdf(x_value,TN+SmallFactor,FP+SmallFactor);

PP_12_Mean = sum(x_value.*PP_12*(1/NumSamples));
PN_12_Mean = sum(x_value.*PN_12*(1/NumSamples));

PP_hm = PA(x_value,TP,FN);
PN_hm = PA(x_value,TN,FP);

BalancedAccuracy_Fold = (1/2)*((TP_Full./(TP_Full+FN_Full))+(TN_Full./(TN_Full+FP_Full)));

NumIter = 10000;
BalancedAccuracy_Fold_BS_Mean = NaN(1,NumIter);

for idx = 1:NumIter
this_BalancedAccuracy_Fold = BalancedAccuracy_Fold(randi(CountFactor,BootStrapFactor,1));
BalancedAccuracy_Fold_BS_Mean(idx) = mean(this_BalancedAccuracy_Fold);
end

BalancedAccuracy_Fold_BS = histcounts(BalancedAccuracy_Fold_BS_Mean,x_value_BS,"Normalization","pdf");

BalancedAccuracy_Fold_BS = [BalancedAccuracy_Fold_BS,0];


BalancedAccuracy_Fold_Mean = mean(BalancedAccuracy_Fold);
BalancedAccuracy_Fold_STD = std(BalancedAccuracy_Fold);
BalancedAccuracy_Fold_STE = BalancedAccuracy_Fold_STD/sqrt(CountFactor);

BalancedAccuracy_Fold_Distribution = normpdf(x_value,BalancedAccuracy_Fold_Mean,BalancedAccuracy_Fold_STE);

% PP_hm = PA(x_value,TP,FN)*1/(NumSamples);
% PN_hm = PA(x_value,TN,FP)*1/(NumSamples);

PBalanced = NaN(1,NumSamples);

for xidx = 1:NumSamples
    this_x = x_value(xidx);
    PBalanced(xidx) = PB(this_x,TP,FP,FN,TN);
end

PBalanced = PBalanced/(sum(PBalanced*(1/NumSamples)));

PBalanced_Mean = sum(x_value.*PBalanced*(1/NumSamples));
PBalanced_Cumulative = cumsum(PBalanced);
[~,PBalanced_Median] = min(abs(PBalanced_Cumulative-0.5));
PBalanced_Median = x_value(PBalanced_Median);
[Max_PBalanced,PBalanced_Mode] = max(PBalanced);
PBalanced_Mode = x_value(PBalanced_Mode);

% P_Mean(TP,FN)

plot(x_value,PP,"DisplayName",'PP');
hold on
plot(x_value,PN,"DisplayName",'PN');
plot(x_value,PP_12,"DisplayName",'PP_12');
plot(x_value,PN_12,"DisplayName",'PN_12');
plot(x_value,PBalanced,"DisplayName",'PBalanced','LineWidth',2);
plot(x_value,BalancedAccuracy_Fold_Distribution,"DisplayName",'CV Balanced','LineWidth',2);
plot(x_value_BS,BalancedAccuracy_Fold_BS,"DisplayName",'BootStrap Balanced','LineWidth',1);

legend;

xline(PBalanced_Mean,'-','PBalanced','LineWidth',1);
xline(BalancedAccuracy_Fold_Mean,'-','CV','LineWidth',1);

hold off

ylim([0,Max_PBalanced*1.2]);

disp({PBalanced_Mean,BalancedAccuracy_Fold_Mean,(PBalanced_Mean-BalancedAccuracy_Fold_Mean)*100});

% PB = @(x,z) 

%%

height = 6;
width = 6;
channels = 3;
observations = 1;
time = 4;

Y = rand(height,width,channels,observations);
Y = dlarray(Y,'SSCB');

targets = ones(height,width,channels,observations);

loss = mse(Y,targets);

% loss_perchannel = dlarray(0);
loss_perchannel = [];
for cidx = 1:channels
loss_perchannel(cidx) = extractdata(mse(Y(:,:,cidx,:,:),targets(:,:,cidx,:,:)));
% loss_perchannel(cidx) = mse(Y(:,:,cidx,:,:),targets(:,:,cidx,:,:));
end

% loss_perchannel_scalar=extractdata(loss_perchannel);

loss_perchannel_normalized = loss_perchannel./loss_perchannel_scalar;
loss_perchannel_rescaled = loss_perchannel_normalized * mean(loss_perchannel_scalar);

loss_rescaled = sum(loss_perchannel_rescaled);

disp(loss);
disp(loss_rescaled);

%%


clc; clear; close all;

NumDataPoints = 100;
Window_Median = 50;
Threshold_Outlier = 1;

NumOutliers_Generated = 25;
Mean_Outlier = 100;

X_Data = 1:NumDataPoints;
Y_Data = randn(1,NumDataPoints);

Permutation_Outlier = randperm(NumDataPoints);
Outlier_Generated_IDX = Permutation_Outlier(1:NumOutliers_Generated);
Y_Data(Outlier_Generated_IDX) = randn(1,NumOutliers_Generated)*Mean_Outlier;

Outlier_IDX = isoutlier(Y_Data,"movmedian",Window_Median,2,"ThresholdFactor",Threshold_Outlier);
NumOutliers = sum(Outlier_IDX);

X_Outlier = X_Data(Outlier_IDX);
Y_Outlier = Y_Data(Outlier_IDX);

plot(X_Data,Y_Data);

hold on
scatter(X_Outlier,Y_Outlier);
hold off




