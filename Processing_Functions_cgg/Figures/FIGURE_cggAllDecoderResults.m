
clc; clear; close all;
%% Parameters

EpochName = 'Decision';
Decoders = {'Logistic','SVM','Gaussian-Logistic','Gaussian-SVM','NaiveBayes'};
% Decoders = {'Logistic'};
% DataWidth = [25,50,75,100,125,150,175,200];
DataWidth = 50;
WindowStride = 50;
wantSubset = true;
wantZeroFeatureDetector = false;
ARModelOrder = 10;

FilterColumn={'Gain','Loss'};

% [FullTable,cfg] = cgg_getResultsPlotsParameters(Epoch,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder);
[FullTable,cfg] = cgg_getResultsPlotsParameters_v2(EpochName,'Decoders',Decoders,'wantSubset',wantSubset,'wantZeroFeatureDetector',wantZeroFeatureDetector,'ARModelOrder',ARModelOrder,'DataWidth',DataWidth,'WindowStride',WindowStride,'FilterColumn',FilterColumn);

%% Overall Accuracy

cgg_plotOverallAccuracy(FullTable,cfg);

%% Split Accuracy

cgg_plotSplitAccuracy(FullTable,cfg);

%% Overall Windowed Accuracy

cgg_plotWindowedAccuracy(FullTable,cfg);

%% Split Windowed Accuracy

cgg_plotSplitWindowedAccuracy(FullTable,cfg);

%% Overall Importance Analysis

% cgg_plotOverallImportanceAnalysis;

%% Split Importance Analysis

% cgg_plotSplitImportanceAnalysis
