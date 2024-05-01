function displayTrainingProgress(data,numEpochs,numWorkers,monitor,stopTrainingQueue)

epoch = data(1);
loss = data(2);
iteration = data(3);
learningrate = data(4);
lossValidation = data(5);

updateInfo(monitor,Loss=loss,Epoch=epoch + " of " + numEpochs, ...
    Workers= numWorkers,...
    Iteration=string(iteration),...
    LearningRate=learningrate);

if isnan(lossValidation)

recordMetrics(monitor,iteration, ...
            LossTraining=loss);
else

recordMetrics(monitor,iteration, ...
            LossTraining=loss,...
            LossValidation=lossValidation);
end

monitor.Progress = 100 * epoch/numEpochs;

if monitor.Stop
    send(stopTrainingQueue,true);
end

end