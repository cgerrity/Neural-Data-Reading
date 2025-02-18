clc; clear; close all;

%%



NumSamples = 10000;
Dim = 40;
DimBig = 10;
BigFactor = 0.001;

% RotationAngle = 45;
%%

sigma = randn(Dim);
sigma(1:(Dim-DimBig),1:(Dim-DimBig)) = sigma(1:(Dim-DimBig),1:(Dim-DimBig)).^1*BigFactor;
sigma = sigma*sigma.';
R = chol(sigma);
Data = randn(NumSamples,Dim)*R;

%%
% Rotation_Matrix = rotz(RotationAngle);
% Rotation_Matrix(3,:) = [];
% Rotation_Matrix(:,3) = [];
% Data_Rot = Data*Rotation_Matrix;
%%

[Data_coeff,Data_score,Data_latent,Data_tsquared,Data_explained,...
    Data_mu] = pca(Data);

plot(cumsum(Data_explained)/sum(Data_explained));


ParticipationRatio = sum(Data_explained).^2/sum(Data_explained.^2);