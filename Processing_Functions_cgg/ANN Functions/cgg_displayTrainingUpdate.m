function cgg_displayTrainingUpdate(data,NumEpochs,numWorkers,monitor,stopTrainingQueue,varargin)
%CGG_DISPLAYTRAININGUPDATE Summary of this function goes here
%   Detailed explanation goes here
monitor.Status = "Running";

epoch = data(1);
iteration = data(2);
learningrate = data(3);

lossTraining = data(4);
lossValidation = data(5);

accuracyTrain = data(6);
accuracyValidation = data(7);

majorityclass = data(8);
randomchance = data(9);

Loss_Reconstruction = data(10);
Loss_KL = data(11);
Loss_Classification = data(12);

%%

IsVariational=~isnan(Loss_KL);
HasClassifier=~isnan(Loss_Classification);
HasReconstruction=~isnan(Loss_Reconstruction);
UpdateValidation=~isnan(lossValidation);

%%

if ~isempty(monitor.Info(strcmp(monitor.Info,"LossType")))
lossTraining=log(lossTraining);
lossValidation=log(lossValidation);
end

updateInfo(monitor,Loss=lossTraining,Epoch=epoch + " of " + NumEpochs, ...
    Workers= numWorkers,...
    Iteration=string(iteration),...
    LearningRate=learningrate);

if HasClassifier
updateInfo(monitor, ...
    Classification_Loss=Loss_Classification);
end
if HasReconstruction
updateInfo(monitor, ...
    Reconstruction_Loss= Loss_Reconstruction);
end
if IsVariational
updateInfo(monitor, ...
    KL_Loss=Loss_KL);
end

if UpdateValidation

    if HasClassifier
        recordMetrics(monitor,iteration, ...
            LossTraining=lossTraining, ...
            AccuracyTraining=accuracyTrain, ...
            LossValidation=lossValidation, ...
            AccuracyValidation=accuracyValidation, ...
            MajorityClass=majorityclass, ...
            RandomChance=randomchance);
    else
        recordMetrics(monitor,iteration, ...
            LossTraining=lossTraining, ...
            LossValidation=lossValidation);
    end
else

    if HasClassifier
        recordMetrics(monitor,iteration, ...
            LossTraining=lossTraining, ...
            AccuracyTraining=accuracyTrain, ...
            MajorityClass=majorityclass, ...
            RandomChance=randomchance);
    else
        recordMetrics(monitor,iteration, ...
            LossTraining=lossTraining);
    end
end

monitor.Progress = 100 * epoch/NumEpochs;

if monitor.Stop
    send(stopTrainingQueue,true);
end

drawnow;
end

