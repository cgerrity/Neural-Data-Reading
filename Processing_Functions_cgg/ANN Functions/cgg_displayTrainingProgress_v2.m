function cgg_displayTrainingProgress_v2(data,numEpochs,numWorkers,monitor,stopTrainingQueue)

monitor.Status = "Running";

epoch = data(1);
loss = data(2);
iteration = data(3);
learningrate = data(4);
lossValidation = data(5);

if ~isempty(monitor.Info(strcmp(monitor.Info,"LossType")))
loss=log(loss);
lossValidation=log(lossValidation);
end

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