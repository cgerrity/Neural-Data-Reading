function [net] = trainCustomTrainingParallel(InputNet,InDataStore,DataFormat)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

net=InputNet;

if canUseGPU
    executionEnvironment = "gpu";
    numberOfGPUs = gpuDeviceCount("available");
    pool = parpool(numberOfGPUs);
else
    executionEnvironment = "cpu";
    pool = gcp;
end

numWorkers = pool.NumWorkers;

numEpochs = 20;
miniBatchSize = 128;
velocity = [];

if executionEnvironment == "gpu"
     miniBatchSize = miniBatchSize .* numWorkers;
end

workerMiniBatchSize = floor(miniBatchSize ./ repmat(numWorkers,1,numWorkers));
remainder = miniBatchSize - sum(workerMiniBatchSize);
workerMiniBatchSize = workerMiniBatchSize + [ones(1,remainder) zeros(1,numWorkers-remainder)];

batchNormLayers = arrayfun(@(l)isa(l,"nnet.cnn.layer.BatchNormalizationLayer"),net.Layers);
batchNormLayersNames = string({net.Layers(batchNormLayers).Name});
state = net.State;
isBatchNormalizationStateMean = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedMean";
isBatchNormalizationStateVariance = ismember(state.Layer,batchNormLayersNames) & state.Parameter == "TrainedVariance";

monitor = trainingProgressMonitor( ...
    Metrics="TrainingLoss", ...
    Info=["Epoch" "Workers"], ...
    XLabel="Iteration");

spmd
    stopTrainingEventQueue = parallel.pool.DataQueue;
end
stopTrainingQueue = stopTrainingEventQueue{1};

dataQueue = parallel.pool.DataQueue;
displayFcn = @(x) displayTrainingProgress(x,numEpochs,numWorkers,monitor,stopTrainingQueue);
afterEach(dataQueue,displayFcn)

spmd
    % Partition the datastore.
    workerImds = partition(InDataStore,numWorkers,spmdIndex);

    % Create minibatchqueue using partitioned datastore on each worker.
    workerMbq = minibatchqueue(workerImds,2,...
        MiniBatchSize=workerMiniBatchSize(spmdIndex),...
        MiniBatchFormat=DataFormat);

    workerVelocity = velocity;
    epoch = 0;
    iteration = 0;
    stopRequest = false;

    while epoch < numEpochs && ~stopRequest
        epoch = epoch + 1;
        shuffle(workerMbq);

        % Loop over mini-batches.
        while spmdReduce(@and,hasdata(workerMbq)) && ~stopRequest
            iteration = iteration + 1;

            % Read a mini-batch of data.
            [workerX,workerT] = next(workerMbq);

            % Evaluate the model loss and gradients on the worker.
            [workerLoss,workerGradients,workerState] = dlfeval(@modelLoss,net,workerX,workerT);

            % Aggregate the losses on all workers.
            workerNormalizationFactor = workerMiniBatchSize(spmdIndex)./miniBatchSize;
            loss = spmdPlus(workerNormalizationFactor*cgg_extractData(workerLoss));

            % Aggregate the network state on all workers.
            net.State = aggregateState(workerState,workerNormalizationFactor,...
                isBatchNormalizationStateMean,isBatchNormalizationStateVariance);

            % Aggregate the gradients on all workers.
            workerGradients.Value = dlupdate(@aggregateGradients,workerGradients.Value,{workerNormalizationFactor});

            % Update the network parameters using the SGDM optimizer.
            [net,workerVelocity] = sgdmupdate(net,workerGradients,workerVelocity);
        end

        % Stop training if the Stop button has been clicked.
        stopRequest = spmdPlus(stopTrainingEventQueue.QueueLength);

        % Send training progress information to the client.
        if spmdIndex == 1
            data = [epoch loss iteration];
            send(dataQueue,gather(data));
        end
    end

end

end

