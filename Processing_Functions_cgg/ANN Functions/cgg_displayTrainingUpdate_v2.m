function cgg_displayTrainingUpdate_v2(data,NumEpochs,numWorkers,monitor,stopTrainingQueue,varargin)
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

if strcmp(monitor.LossTransform,"LogLoss")
lossTraining=log(lossTraining);
lossValidation=log(lossValidation);
end

updateInformation(monitor,'Loss',lossTraining);
updateInformation(monitor,'Epoch',epoch + " of " + NumEpochs);
updateInformation(monitor,'Workers',numWorkers);
updateInformation(monitor,'Iteration',iteration);
updateInformation(monitor,'LearningRate',learningrate);

if HasClassifier
    updateInformation(monitor,'Classification_Loss',Loss_Classification);
end
if HasReconstruction
    updateInformation(monitor,'Reconstruction_Loss',Loss_Reconstruction);
end
if IsVariational
    updateInformation(monitor,'KL_Loss',Loss_KL);
end

if UpdateValidation

    if HasClassifier
        updatePlot(monitor,'LossTraining',[iteration,lossTraining]);
        updatePlot(monitor,'AccuracyTraining',[iteration,accuracyTrain]);
        updatePlot(monitor,'LossValidation',[iteration,lossValidation]);
        updatePlot(monitor,'AccuracyValidation',[iteration,accuracyValidation]);
        updatePlot(monitor,'MajorityClass',[iteration,majorityclass]);
        updatePlot(monitor,'RandomChance',[iteration,randomchance]);
    else
        updatePlot(monitor,'LossTraining',[iteration,lossTraining]);
        updatePlot(monitor,'LossValidation',[iteration,lossValidation]);
    end
else

    if HasClassifier
        updatePlot(monitor,'LossTraining',[iteration,lossTraining]);
        updatePlot(monitor,'AccuracyTraining',[iteration,accuracyTrain]);
        updatePlot(monitor,'MajorityClass',[iteration,majorityclass]);
        updatePlot(monitor,'RandomChance',[iteration,randomchance]);
    else
        updatePlot(monitor,'LossTraining',[iteration,lossTraining]);
    end
end

monitor.Progress = 100 * epoch/NumEpochs;

if monitor.Stop
    send(stopTrainingQueue,true);
end

updateTime(monitor)

drawnow;
end

