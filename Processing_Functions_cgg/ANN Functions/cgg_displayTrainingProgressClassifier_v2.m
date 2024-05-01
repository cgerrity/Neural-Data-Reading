function cgg_displayTrainingProgressClassifier_v2(data,numEpochs,numWorkers,monitor,stopTrainingQueue,varargin)

monitor.Status = "Running";

epoch = data(1);
loss = data(2);
iteration = data(3);
accuracyTrain = data(4);
learningrate = data(5);

lossValidation = data(6);
accuracyValidation = data(7);

majorityclass = data(8);
randomchance = data(9);

Loss_Reconstruction = data(10);
Loss_KL = data(11);
Loss_Classification = data(12);

if ~isempty(monitor.Info(strcmp(monitor.Info,"LossType")))
loss=log(loss);
lossValidation=log(lossValidation);
end

updateInfo(monitor,Loss=loss,Epoch=epoch + " of " + numEpochs, ...
    Workers= numWorkers,...
    Iteration=string(iteration),...
    LearningRate=learningrate);

if ~isempty(monitor.Info(strcmp(monitor.Info,"KL_Loss")))
updateInfo(monitor, ...
    Reconstruction_Loss= Loss_Reconstruction,...
    KL_Loss=Loss_KL,...
    Classification_Loss=Loss_Classification);
end

if isnan(lossValidation)

recordMetrics(monitor,iteration, ...
            LossTraining=loss, ...
            AccuracyTraining=accuracyTrain, ...
            MajorityClass=majorityclass, ...
            RandomChance=randomchance);
else

recordMetrics(monitor,iteration, ...
            LossTraining=loss, ...
            AccuracyTraining=accuracyTrain, ...
            LossValidation=lossValidation, ...
            AccuracyValidation=accuracyValidation, ...
            MajorityClass=majorityclass, ...
            RandomChance=randomchance);
end

monitor.Progress = 100 * epoch/numEpochs;

if monitor.Stop
    send(stopTrainingQueue,true);
end

drawnow;

end