

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

aaaaa = aaa-aaa(1)
