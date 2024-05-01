function cgg_displayTrainingProgressClassifier(data,numEpochs,numWorkers,monitor,stopTrainingQueue,varargin)

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

updateInfo(monitor,Loss=loss,Epoch=epoch + " of " + numEpochs, ...
    Workers= numWorkers,...
    Iteration=string(iteration),...
    LearningRate=learningrate);

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