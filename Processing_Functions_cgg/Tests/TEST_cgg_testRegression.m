

clc; clear; close all;


%%

NumExamples = 5000;


Regression_Classes = [-3,2,8,5];
Regression_Conditions = [-11,-13];
Regression_Background = 100;

Regression_Trials_Class = randi(length(Regression_Classes),[NumExamples,1]);
Regression_Trials_Class = Regression_Classes(Regression_Trials_Class)';

Regression_Trials_Conditions = randi(length(Regression_Conditions),[NumExamples,1]);
Regression_Trials_Conditions = Regression_Conditions(Regression_Trials_Conditions)';


Regression_Trials = randn([NumExamples,1]);
Regression_Trials = Regression_Trials+Regression_Trials_Class;
Regression_Trials = Regression_Trials+Regression_Trials_Conditions;
Regression_Trials = Regression_Trials+Regression_Background;

Regression_Trials_No_Mean = Regression_Trials - mean(Regression_Trials);

%%

Data_Table=table(Regression_Trials_Class,Regression_Trials,'VariableNames',{'Class','Y'});
Data_Table_All=table(Regression_Trials_Class,Regression_Trials_Conditions,Regression_Trials,'VariableNames',{'Class','Condition','Y'});
Data_Table_All.Class = nominal(Data_Table_All.Class);
Data_Table_All.Condition = nominal(Data_Table_All.Condition);
% Data_Table=splitvars(Data_Table);

%%

Data_Table_No_Mean=table(Regression_Trials_Class,Regression_Trials_Conditions,Regression_Trials_No_Mean,'VariableNames',{'Class','Condition','Y'});
Data_Table_No_Mean.Class = nominal(Data_Table_No_Mean.Class);
Data_Table_No_Mean.Condition = nominal(Data_Table_No_Mean.Condition);

%%
histogram(Regression_Trials,50);

Model_LME_All = fitlme(Data_Table_All,'Y ~ 1 + Class + (1 | Condition)');
% Model_LME_All = fitlme(Data_Table_All,'Y ~ 1 + Class + (1 | Class) + (1 | Condition)','DummyVarCoding','effects');

Model_GLME_All = fitglme(Data_Table_All,'Y ~ 1 + Class + Condition');

Model = fitlm(Data_Table_All,'Y ~ 1 + Class + Condition','CategoricalVars',1:2);
Model_No_Mean = fitlm(Data_Table_No_Mean,'Y ~ 1 + Class + Condition','CategoricalVars',1:2);
% Model_Full = fitlm(Data_Table_All,'Y ~ 1 + Class + Condition','CategoricalVars',1:2,'DummyVarCoding','full');

% Model = fitlme(Regression_Trials_Class,Regression_Trials,"CategoricalVars",true(1,1));

%%

aaa = Model_No_Mean.Coefficients.Estimate;

aaaaa = aaa-aaa(1);


%% BootStrap Testing

clc; clear; close all;

NumSamples = 200;
SignificanceValue = 0.05;
CenterValue = 0.3;
Sample_STD = 1;
NumIter = 1000;

Samples = randn([1,NumSamples])*Sample_STD+CenterValue;
Mean = mean(Samples);
STD = std(Samples);
STE = STD/sqrt(NumSamples);
T = tinv(1-SignificanceValue/2,NumSamples-1);
CI = [Mean-T.*STE;Mean+T.*STE];


% Bootstrap

% Bootstrap = NaN(1,NumIter);

[Bootstrap,~] = bootstrp(NumIter,@mean,Samples);

% for idx = 1:NumIter
% this_Bootstrap = Samples(randi(NumSamples,[1,NumSamples]));
% this_Bootstrap_Mean = mean(this_Bootstrap);
% Bootstrap(idx) = this_Bootstrap_Mean;
% end

% figure;
% histogram(Bootstrap)
% title('Bootstrap');

ci = bootci(NumIter,{@mean,Samples},'Type','bca');
ci_cper = bootci(NumIter,{@mean,Samples},'Type','cper');
ci_per = bootci(NumIter,{@mean,Samples},'Type','per');

% P_Value = Bootstrap 

Negative_Samples = (Samples > 0)*2-1;
Sign_Bootstrap = NaN(1,NumIter);
this_Bootstrap = Samples;

parfor idx = 1:NumIter
Negative_Samples_Shuffled = randi(2,[1,NumSamples])*2-3;
% this_Bootstrap = Samples(randi(NumSamples,[1,NumSamples]));
% Negative_Samples = (this_Bootstrap > 0)*2-1;
% Negative_Samples_Shuffled = Negative_Samples(randperm(length(Negative_Samples)));
Sign_Shifted_Samples = this_Bootstrap.*(Negative_Samples_Shuffled);
Sign_Bootstrap(idx) = mean(Sign_Shifted_Samples);
end

P_Value = sum(abs(Sign_Bootstrap) > abs(Mean))/NumIter;
P = [prctile(Sign_Bootstrap,2.5),prctile(Sign_Bootstrap,97.5)];

% figure;
% histogram(Sign_Bootstrap)
% title('Signed Bootstrap');


observed_mean_homogeneity = mean(Samples);

shuffled_means = zeros(NumIter, 1);

parfor i = 1:NumIter
    shuffled_signs = sign(randn(size(Samples)));
    shuffled_indices = Samples .* shuffled_signs;
    shuffled_means(i) = mean(shuffled_indices);
end

confidence_interval = prctile(shuffled_means, [2.5, 97.5]);

fprintf('Observed mean homogeneity index: %.3f\n', observed_mean_homogeneity);
fprintf('95%% Confidence interval: [%.3f, %.3f]\n', confidence_interval(1), confidence_interval(2));

if observed_mean_homogeneity < confidence_interval(1) || observed_mean_homogeneity > confidence_interval(2)
    fprintf('The observed homogeneity index is significant at the 95%% level.\n');
else
    fprintf('The observed homogeneity index is not significant at the 95%% level.\n');
end

% figure;
% histogram(shuffled_means)
% title('AI Version');

ConfidenceRange = cgg_getSignTest(Samples,'NumIter',NumIter,'SignificanceValue',SignificanceValue);

fprintf('95%% Confidence interval Difference: [%.3f, %.3f]\n', confidence_interval(1)-P(1), confidence_interval(2)-P(2));

%%

% Define categories
categories = {'Chosen Feature', 'Outcome', 'Previous Trial Effect', 'Dimensionality', 'Motivation', 'Learning Model Variable'};

% Create a random matrix for the sake of the example (replace with actual data)
dataMatrix = rand(length(categories))+diag(diag(ones(length(categories))))*4;
dataMatrix(1,2:end) = dataMatrix(1,2:end)+3.5;
dataMatrix = dataMatrix./max(dataMatrix(:));

% Create the heatmap
figure;
h = heatmap(categories, categories, dataMatrix);

% Set the x and y axis labels
h.XLabel = 'Testing';
h.YLabel = 'Training';

% Display title (optional)
h.Title = 'Mock-up Heat Map example';