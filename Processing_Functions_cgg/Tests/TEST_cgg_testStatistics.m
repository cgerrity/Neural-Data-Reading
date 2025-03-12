clc; clear; close all;

%%

NumSamples_1 = 2000;
NumSamples_2 = 2000;

True_Proportion_Positive_1 = 0.3;
True_Proportion_Negative_1 = 0.2;
True_Proportion_Positive_2 = 0.5;
True_Proportion_Negative_2 = 0.4;


Sample_Propotions_1 = [True_Proportion_Positive_1,True_Proportion_Negative_1,...
    1-True_Proportion_Positive_1-True_Proportion_Negative_1];
Sample_Propotions_2 = [True_Proportion_Positive_2,True_Proportion_Negative_2,...
    1-True_Proportion_Positive_2-True_Proportion_Negative_2];

Data_1 = mnrnd(NumSamples_1,Sample_Propotions_1,1);
Data_2 = mnrnd(NumSamples_2,Sample_Propotions_2,1);

Count_Positive_1 = Data_1(1);
Count_Negative_1 = Data_1(2);
Count_Positive_2 = Data_2(1);
Count_Negative_2 = Data_2(2);

Proportion_Positive_1 = Count_Positive_1/NumSamples_1;
Proportion_Negative_1 = Count_Negative_1/NumSamples_1;
Proportion_Positive_2 = Count_Positive_2/NumSamples_2;
Proportion_Negative_2 = Count_Negative_2/NumSamples_2;

Proportion_Overall_1 = (Count_Positive_1+Count_Negative_1)/NumSamples_1;
STE_Overall_1 = sqrt(Proportion_Overall_1 * (1 - Proportion_Overall_1) * (1/Count_Positive_1 + 1/Count_Negative_1));
Proportion_Overall_2 = (Count_Positive_2+Count_Negative_2)/NumSamples_2;
STE_Overall_2 = sqrt(Proportion_Overall_2 * (1 - Proportion_Overall_2) * (1/Count_Positive_2 + 1/Count_Negative_2));

Z_Overall_1 = (Count_Positive_1/NumSamples_1 - Count_Negative_1/NumSamples_1) / STE_Overall_1;
Z_Overall_2 = (Count_Positive_2/NumSamples_2 - Count_Negative_2/NumSamples_2) / STE_Overall_2;

P_Value_1 = 2 * (1 - normcdf(abs(Z_Overall_1)));  % Two-tailed test
P_Value_2 = 2 * (1 - normcdf(abs(Z_Overall_2)));  % Two-tailed test

Proportion_Difference_1 = Proportion_Positive_1 - Proportion_Negative_1;
Proportion_Difference_2 = Proportion_Positive_2 - Proportion_Negative_2;

STE_Overall = sqrt((Proportion_Positive_1 * (1 - Proportion_Positive_1) + ...
    Proportion_Negative_1 * (1 - Proportion_Negative_1)) / NumSamples_1 + ...
    (Proportion_Positive_2 * (1 - Proportion_Positive_2) + ...
    Proportion_Negative_2 * (1 - Proportion_Negative_2)) / NumSamples_2);

Z_Overall = (Proportion_Difference_1 - Proportion_Difference_2) / STE_Overall;

P_Value = 2 * (1 - normcdf(abs(Z_Overall)));  % Two-tailed test

[P_Value_func,Z_Value_func] = cgg_procDifferenceOfDifferencesProportionTest(Proportion_Positive_1,Proportion_Negative_1,Proportion_Positive_2,Proportion_Negative_2,NumSamples_1,NumSamples_2);

%%



%%

MeanNumPoints = 10;
NumObservations = 200;
WantRandomNumPoints = false;
STDSample = 10;
NumBoot = 10000;
Rho = 0.5;

BinEdges = linspace(-STDSample*3,STDSample*3,MeanNumPoints);

Rho_Matrix = diag(diag(ones(NumObservations)))+...
    triu(ones(NumObservations),1)*Rho+...
    tril(ones(NumObservations),-1)*Rho;

SamplePoints = cell(NumObservations,1);
NumPoints = NaN(NumObservations,1);

for oidx = 1:NumObservations
    if WantRandomNumPoints
        this_NumPoints = poissrnd(MeanNumPoints);
    else
        this_NumPoints = MeanNumPoints;
    end
NumPoints(oidx) = this_NumPoints;
SamplePoints{oidx} = randn(this_NumPoints,1)*STDSample;
end
AllSamplePoints = cell2mat(SamplePoints);

%%

SampleMean = NaN(1,NumObservations);
SampleSTD = NaN(1,NumObservations);
SampleSTE = NaN(1,NumObservations);
% Distribution_BootMean = cell(1,NumObservations);
Distribution_BootMean = NaN(NumBoot,NumObservations);

for oidx = 1:NumObservations

this_Mean = mean(SamplePoints{oidx},"all");
this_STD = std(SamplePoints{oidx},1,"all");
this_NumPoints = NumPoints(oidx);
this_STE = this_STD/sqrt(this_NumPoints);

% if this_NumPoints > 1
% Distribution_BootMean(:,oidx) = bootstrp(NumBoot,@(x)mean(x),SamplePoints{oidx},Options=statset(UseParallel=true));
% % BootSTE = std(bootstrp(NumBoot,@(x)mean(x),SampleMean,Options=statset(UseParallel=true)));
% else
% Distribution_BootMean(:,oidx) = SamplePoints{oidx};
% end
SampleMean(oidx) = this_Mean;
SampleSTD(oidx) = this_STD;
SampleSTE(oidx) = this_STE;
% fprintf('%.3f\t\t%.3f\n',std(Distribution_BootMean{oidx}),SampleSTE(oidx))
% fprintf('%.3f\n',std(Distribution_BootMean(:,oidx),[])-SampleSTE(oidx))
end

% %%
% % BootAddition = ((1:NumObservations)-1)*NumBoot;
% Distribution_FullBootMean = NaN(NumBoot,1);
% for bidx = 1:NumBoot
% 
%     % BootIDX = randi([1,NumBoot],[1,NumObservations])+BootAddition;    
%     this_SampleMeans = NaN(1,NumObservations);
%     for oidx = 1:NumObservations
%     % this_Sample = SamplePoints{oidx};
%     % this_Sample = this_Sample(randi([1,length(this_Sample)],1));
%     % this_SampleMeans(oidx) = this_Sample;
% 
%     this_Sample = SamplePoints{oidx};
%     this_Sample = this_Sample(randi([1,length(this_Sample)],[1,NumBoot]));
%     this_SampleMeans(oidx) = mean(this_Sample);
%     end
% 
%     this_SampleMeans = this_SampleMeans(randi([1,length(this_SampleMeans)],1));
% 
% Distribution_FullBootMean(bidx) = mean(this_SampleMeans);
% end
% histogram(Distribution_FullBootMean)

%%
PropagationMean = mean(SampleMean);
% PropagationSTD = sqrt(mean(SampleSTD.^2));
PropagationSTD = sqrt(((1/NumObservations))*mean((SampleSTD'*SampleSTD).*Rho_Matrix,'all'));
% PropagationSTE = sqrt(mean(SampleSTE.^2));
% PropagationSTE = sqrt(((1/NumObservations))*mean((SampleSTE'*SampleSTE).*Rho_Matrix,'all'));
PropagationSTE = sqrt(sum((SampleSTE'*SampleSTE).*Rho_Matrix,'all')*((1/NumObservations)));

%%
AllMean = mean(AllSamplePoints);
AllSTD = std(AllSamplePoints);
AllSTE = AllSTD/sqrt(length(AllSamplePoints));

%%
NonPropagationMean = mean(SampleMean);
NonPropagationSTD = std(SampleMean);
NonPropagationSTE = NonPropagationSTD/sqrt(length(SampleMean));

%%
TestMean = mean(SampleMean);
TestSTD = sqrt(PropagationSTD.^2 + NonPropagationSTD.^2);
TestSTE = sqrt(PropagationSTE.^2 + NonPropagationSTE.^2);

%%
Test2Mean = mean(SampleMean);
Test2STD = sqrt(PropagationSTD.^2 + 2*((1/NumObservations)^2)*(1*1));
Test2STE = sqrt(PropagationSTE.^2 + NonPropagationSTE.^2);

%%
BootMean = mean(SampleMean);
if length(SampleMean) > 1
BootSTD = mean(bootstrp(NumBoot,@(x)std(x),SampleMean,Options=statset(UseParallel=true)));
BootSTE = std(bootstrp(NumBoot,@(x)mean(x),SampleMean,Options=statset(UseParallel=true)));
else
BootSTD = NaN;
BootSTE = NaN;  
end
%%

fprintf('\t\t\tMean\t\tSTD\t\tSTE\n');
fprintf('All:\t\t\t%.3f\t\t%.3f\t\t%.3f\n',AllMean,AllSTD,AllSTE);
fprintf('Test:\t\t\t%.3f\t\t%.3f\t\t%.3f\n',TestMean,TestSTD,TestSTE);
% fprintf('Test2:\t\t\t%.3f\t\t%.3f\t\t%.3f\n',Test2Mean,Test2STD,Test2STE);
% fprintf('Boot:\t\t\t%.3f\t\t%.3f\t\t%.3f\n',BootMean,BootSTD,BootSTE);
fprintf('Propagation:\t\t%.3f\t\t%.3f\t\t%.3f\n',PropagationMean,PropagationSTD,PropagationSTE);
fprintf('Non Propagation:\t%.3f\t\t%.3f\t\t%.3f\n',NonPropagationMean,NonPropagationSTD,NonPropagationSTE);

histogram(AllSamplePoints,BinEdges,'Normalization','pdf','FaceAlpha',0.3,'DisplayName','All');
hold on
histogram(SampleMean,BinEdges,'Normalization','pdf','FaceAlpha',0.3,'DisplayName','Group');
% hold off
% histogram(Distribution_FullBootMean,BinEdges,'Normalization','pdf','FaceAlpha',0.3,'DisplayName','Boot');
hold off
legend

