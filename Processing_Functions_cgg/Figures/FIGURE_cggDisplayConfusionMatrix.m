

clc; clear; close all;


%%

NumSamples = 1000;

NumClasses = 4;
ClassFrequency = [0.1,0.2,0.3,0.4];

ClassFrequency = ClassFrequency./ sum(ClassFrequency);

[~,MostCommonClass] = max(ClassFrequency);

Classes = strings(1,NumClasses);
TrueLabels = cell(1,NumClasses);

for cidx = 1:NumClasses
Classes(cidx) = sprintf("Class %d",cidx);
TrueLabels{cidx} = cidx*ones(1,NumSamples*ClassFrequency(cidx));
end

TrueLabels = cell2mat(TrueLabels);
ClassNames = {Classes};

RandomPrediction = randi(NumClasses,size(TrueLabels));
MostCommonPrediction = ones(size(TrueLabels))*MostCommonClass;
NonUniformRandomPrediction = TrueLabels(randperm(NumSamples));

TrueLabels = Classes(TrueLabels)';
RandomPrediction = Classes(RandomPrediction)';
MostCommonPrediction = Classes(MostCommonPrediction)';
NonUniformRandomPrediction = Classes(NonUniformRandomPrediction)';

figure;
confusionchart(TrueLabels,RandomPrediction,"RowSummary","row-normalized");
title('Random');
figure;
confusionchart(TrueLabels,MostCommonPrediction,"RowSummary","row-normalized");
title('Most Common');
figure;
confusionchart(TrueLabels,NonUniformRandomPrediction,"RowSummary","row-normalized");
title('Random Same Frequency');

CM_Random = confusionmat(TrueLabels,RandomPrediction);
CM_MostCommon = confusionmat(TrueLabels,MostCommonPrediction);
CM_NonUniformRandom = confusionmat(TrueLabels,NonUniformRandomPrediction);


[Accuracy_Random] = cgg_calcMacroRecall(TrueLabels,RandomPrediction,ClassNames);
[Accuracy_MostCommon] = cgg_calcMacroRecall(TrueLabels,MostCommonPrediction,ClassNames);
[Accuracy_NonUniformRandom] = cgg_calcMacroRecall(TrueLabels,NonUniformRandomPrediction,ClassNames);
