
clc; clear; close all;

%%


NumChannels = 4;
DataWidth = 10;
NumWindows = 4;
NumAreas = 2;
NumExamples = 3;

DataFormat='SSCBT';

% NumNaNChannels = 4;

%%

% NaNChannel = randi(NumChannels,NumNaNChannels,1);
% NaNArea = randi(NumAreas,NumNaNChannels,1);

NaNChannel = 1;
NaNArea = 1;

InputSize = [NumChannels,DataWidth,NumAreas];
%% NaN Channels are Correct

X = zeros([InputSize,NumExamples,NumWindows]);
Y = ones([InputSize,NumExamples,NumWindows]);
X(NaNChannel,:,NaNArea,:,:) = NaN;
Y(NaNChannel,:,NaNArea,:,:) = 0;

% Mask_NaN = ~isnan(X_Zeroes);
% 
% X_Zeroes(Mask_NaN) = 0;

X = dlarray(X,DataFormat);
Y = dlarray(Y,DataFormat);
Mask_NaN = ~isnan(X);

Loss_NaNCorrect_Mask = 0.5*l2loss(Y,X,Mask=Mask_NaN);
X(~Mask_NaN) = 0;
Loss_NaNCorrect_NoMask = 0.5*l2loss(Y,X);

%% NaN Channels are Incorrect

X = ones([InputSize,NumExamples,NumWindows]);
Y = ones([InputSize,NumExamples,NumWindows]);
X(NaNChannel,:,NaNArea,:,:) = NaN;

% Mask_NaN = ~isnan(X_Zeroes);
% 
% X_Zeroes(Mask_NaN) = 0;

X = dlarray(X,DataFormat);
Y = dlarray(Y,DataFormat);
Mask_NaN = ~isnan(X);

Loss_NaNIncorrect_Mask = 0.5*l2loss(Y,X,Mask=Mask_NaN);
X(~Mask_NaN) = 0;
Loss_NaNIncorrect_NoMask = 0.5*l2loss(Y,X);
LossMSE_NaNIncorrect = mse(Y,X);

fprintf("NaN Correct No Mask: %f\n",extractdata(Loss_NaNCorrect_NoMask));
fprintf("NaN Correct Mask: %f\n",extractdata(Loss_NaNCorrect_Mask));
fprintf("NaN Incorrect No Mask: %f\n",extractdata(Loss_NaNIncorrect_NoMask));
fprintf("NaN Incorrect Mask: %f\n",extractdata(Loss_NaNIncorrect_Mask));
