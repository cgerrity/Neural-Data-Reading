function MonitorTable = cgg_generateAllMonitors(cfg_Monitor,Run)
%CGG_GENERATEALLMONITORS Summary of this function goes here
%   Detailed explanation goes here

if exist("cfg_Monitor","var")
if ~isstruct(cfg_Monitor)
    cfg_Monitor = struct();
end
else
    cfg_Monitor = struct();
end

if ~(isfield(cfg_Monitor,'LossType'))
cfg_Monitor.LossType = 'Regression';
end

if ~(isfield(cfg_Monitor,'LogLoss'))
cfg_Monitor.LogLoss = false;
end

if ~(isfield(cfg_Monitor,'WantKLLoss'))
cfg_Monitor.WantKLLoss = false;
end

if ~(isfield(cfg_Monitor,'WantReconstructionLoss'))
cfg_Monitor.WantReconstructionLoss = true;
end

if ~(isfield(cfg_Monitor,'WantClassificationLoss'))
cfg_Monitor.WantClassificationLoss = true;
end

if ~(isfield(cfg_Monitor,'SaveDir'))
cfg_Monitor.SaveDir = pwd;
end

if ~(isfield(cfg_Monitor,'NumAreas'))
cfg_Monitor.NumAreas = 6;
end

if ~(isfield(cfg_Monitor,'Time_Start'))
cfg_Monitor.Time_Start = -1.5;
end

if ~(isfield(cfg_Monitor,'Time_End'))
cfg_Monitor.Time_End = 1.5;
end

if ~(isfield(cfg_Monitor,'SamplingRate'))
cfg_Monitor.SamplingRate = 1000;
end

if ~(isfield(cfg_Monitor,'DataWidth'))
cfg_Monitor.DataWidth = 100;
end
cfg_Monitor.DataWidth_Seconds = ...
    cfg_Monitor.DataWidth/cfg_Monitor.SamplingRate;

if ~(isfield(cfg_Monitor,'WindowStride'))
cfg_Monitor.WindowStride = 50;
end
cfg_Monitor.WindowStride_Seconds = ...
    cfg_Monitor.WindowStride/cfg_Monitor.SamplingRate;

if ~(isfield(cfg_Monitor,'NumWindows'))
Time = cfg_Monitor.Time_Start:1/cfg_Monitor.SamplingRate:...
    cfg_Monitor.Time_End;
cfg_Monitor.NumWindows = floor((length(Time)-cfg_Monitor.DataWidth)...
    /cfg_Monitor.WindowStride)+1;
end

if ~(isfield(cfg_Monitor,'NumDimensions'))
cfg_Monitor.NumDimensions = 4;
end

if ~(isfield(cfg_Monitor,'WantProgressMonitor'))
cfg_Monitor.WantProgressMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantExampleMonitor'))
cfg_Monitor.WantExampleMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantComponentMonitor'))
cfg_Monitor.WantComponentMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantAccuracyMonitor'))
    cfg_Monitor.WantAccuracyMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantWindowMonitor'))
    cfg_Monitor.WantWindowMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantReconstructionMonitor'))
    cfg_Monitor.WantReconstructionMonitor = true;
end

if ~(isfield(cfg_Monitor,'WantGradientMonitor'))
cfg_Monitor.WantGradientMonitor = true;
end

if ~(isfield(cfg_Monitor,'AccuracyMeasures'))
cfg_Monitor.AccuracyMeasures = {'combinedaccuracy'};
end

if ~(isfield(cfg_Monitor,'NumWorkers'))
cfg_Monitor.NumWorkers = 1;
end

if ~(isfield(cfg_Monitor,'NumEpochs'))
cfg_Monitor.NumEpochs = 1;
end

%%

if cfg_Monitor.WantClassificationLoss
    cfg_Monitor.WantAccuracyMonitor = true;
else
    cfg_Monitor.WantAccuracyMonitor = false;
end

if cfg_Monitor.WantClassificationLoss
    cfg_Monitor.WantWindowMonitor = true;
else
    cfg_Monitor.WantWindowMonitor = false;
end

if cfg_Monitor.WantReconstructionLoss
    cfg_Monitor.WantReconstructionMonitor = true;
else
    cfg_Monitor.WantReconstructionMonitor = false;
end

%%

stopTrainingQueue = parallel.pool.DataQueue;

%%

NumAccuracyMeasures = length(cfg_Monitor.AccuracyMeasures);

%%

TableVariables = [["Name", "string"]; ...
        ["Monitor", "cell"]; ...
		["UpdateFunction", "cell"]; ...
        ["ParallelUpdateFunction", "cell"]; ...
		["SaveFunction", "cell"]; ...
        ["MonitorValueUpdateFunction", "cell"]; ...
        ["DataNames", "cell"]; ...
        ["DataIdentifier", "string"]; ...
        ["UpdateEachIteration", "logical"]];

NumVariables = size(TableVariables,1);

MonitorTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

TableIDX = 0;

%% Progress Monitor
if cfg_Monitor.WantProgressMonitor
for midx = 1:NumAccuracyMeasures
    TableIDX = TableIDX + 1;
    this_AccuracyMeasure = cfg_Monitor.AccuracyMeasures{midx};
[Monitor,DataNames] = cgg_generateProgressMonitor_v4(...
    'LossType',cfg_Monitor.LossType,'LogLoss',cfg_Monitor.LogLoss,...
    'WantKLLoss',cfg_Monitor.WantKLLoss,'WantReconstructionLoss',...
    cfg_Monitor.WantReconstructionLoss,'WantClassificationLoss',...
    cfg_Monitor.WantClassificationLoss,'SaveDir',cfg_Monitor.SaveDir,...
    'SaveTerm',this_AccuracyMeasure,'MatchType',this_AccuracyMeasure,...
    'Run',Run);

Name = sprintf("Progress Monitor - %s",this_AccuracyMeasure);

UpdateFcn = @(data) cgg_displayTrainingUpdate_v2(data,cfg_Monitor.NumEpochs,...
    cfg_Monitor.NumWorkers,Monitor,stopTrainingQueue);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = string(this_AccuracyMeasure);

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;

end
end

%% Example Monitor

if cfg_Monitor.WantExampleMonitor
% TableIDX = TableIDX + 1;
% Monitor = cgg_generateExampleMonitor('SaveDir',cfg_Monitor.SaveDir);
% 
% % UpdateFcn = @(data) cgg_displayExampleMonitor(...);
% 
% % dataQueue = parallel.pool.DataQueue;
% % afterEach(dataQueue,UpdateFcn);
% % ParallelUpdateFcn = @(data) send(dataQueue,data);
% 
% SaveFcn = @(IsOptimal) savePlot(Example_monitor,IsOptimal);
% DataNames = cell(0);
% 
% DataNames{1} = 'epoch';
% DataNames{2} = 'iteration';
% DataNames{3} = 'learningrate';
% DataNames{4} = 'lossTraining';
% DataNames{5} = 'lossValidation';
% DataNames{6} = 'accuracyTrain';
% DataNames{7} = 'accuracyValidation';
% DataNames{8} = 'majorityclass';
% DataNames{9} = 'randomchance';
% DataNames{10} = 'Loss_Reconstruction';
% DataNames{11} = 'Loss_KL';
% DataNames{12} = 'Loss_Classification';
% 
% DataIdentifier = string(this_AccuracyMeasure);
% 
% this_Monitor = cell(1,NumVariables);
% 
% this_Monitor{:,1} = {Monitor};
% this_Monitor{:,2} = {UpdateFcn};
% this_Monitor{:,3} = {ParallelUpdateFcn};
% this_Monitor{:,4} = {SaveFcn};
% 
% this_TableRange = TableIDX;
% 
% MonitorTable(this_TableRange,:) = this_Monitor;
end


%% Component Monitor

if cfg_Monitor.WantComponentMonitor

    if cfg_Monitor.WantReconstructionLoss
TableIDX = TableIDX + 1;
SaveTerm = 'Reconstruction';
[Monitor,DataNames] = cgg_generateComponentProgressMonitor(...
    'WantKLLoss',false,'WantReconstructionLoss',...
    cfg_Monitor.WantReconstructionLoss,'WantClassificationLoss',...
    false,'SaveDir',cfg_Monitor.SaveDir,...
    'NumAreas',cfg_Monitor.NumAreas,...
    'NumDimensions',cfg_Monitor.NumDimensions,'SaveTerm',SaveTerm,...
    'Run',Run);

Name = "Component Monitor - Reconstruction";

UpdateFcn = @(data) cgg_displayTrainingLossComponentUpdate(data,Monitor);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = "Reconstruction";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
    end

    if cfg_Monitor.WantKLLoss
TableIDX = TableIDX + 1;
SaveTerm = 'KL';
[Monitor,DataNames] = cgg_generateComponentProgressMonitor(...
    'WantKLLoss',cfg_Monitor.WantKLLoss,'WantReconstructionLoss',...
    false,'WantClassificationLoss',...
    false,'SaveDir',cfg_Monitor.SaveDir,...
    'NumAreas',cfg_Monitor.NumAreas,...
    'NumDimensions',cfg_Monitor.NumDimensions,'SaveTerm',SaveTerm, ...
    'Run',Run);

Name = "Component Monitor - KL";

UpdateFcn = @(data) cgg_displayTrainingLossComponentUpdate(data,Monitor);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = "KL";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
    end
    if cfg_Monitor.WantClassificationLoss
TableIDX = TableIDX + 1;
SaveTerm = 'Classification';
[Monitor,DataNames] = cgg_generateComponentProgressMonitor(...
    'WantKLLoss',false,'WantReconstructionLoss',false, ...
    'WantClassificationLoss',cfg_Monitor.WantClassificationLoss,...
    'SaveDir',cfg_Monitor.SaveDir,...
    'NumAreas',cfg_Monitor.NumAreas,...
    'NumDimensions',cfg_Monitor.NumDimensions,'SaveTerm',SaveTerm, ...
    'Run',Run);

Name = "Component Monitor - Classification";

UpdateFcn = @(data) cgg_displayTrainingLossComponentUpdate(data,Monitor);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = "Classification";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
    end

end

%% Window Monitor

if cfg_Monitor.WantWindowMonitor
for midx = 1:NumAccuracyMeasures
    TableIDX = TableIDX + 1;
    this_AccuracyMeasure = cfg_Monitor.AccuracyMeasures{midx};
[Monitor,DataNames] = cgg_generateFullAccuracyProgressMonitor(...
    'SaveDir',cfg_Monitor.SaveDir,'Time_Start',cfg_Monitor.Time_Start,...
    'DataWidth',cfg_Monitor.DataWidth_Seconds,...
    'WindowStride',cfg_Monitor.WindowStride_Seconds,...
    'NumWindows',cfg_Monitor.NumWindows,...
    'SamplingRate',cfg_Monitor.SamplingRate,...
    'SaveTerm',this_AccuracyMeasure,'MatchType',this_AccuracyMeasure, ...
    'Run',Run);

Name = sprintf("Window Monitor %s",this_AccuracyMeasure);

UpdateFcn = @(data) cgg_displayWindowMonitor(Monitor,data);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = string(this_AccuracyMeasure);

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;

end
end

%% Reconstruction Monitor

if cfg_Monitor.WantReconstructionMonitor
TableIDX = TableIDX + 1;
[Monitor,DataNames] = ...
    cgg_generateFullReconstructionAndClassificationMonitor(...
    'SaveDir',cfg_Monitor.SaveDir,'Time_Start',cfg_Monitor.Time_Start,...
    'DataWidth',cfg_Monitor.DataWidth_Seconds,...
    'WindowStride',cfg_Monitor.WindowStride_Seconds,...
    'NumWindows',cfg_Monitor.NumWindows,...
    'SamplingRate',cfg_Monitor.SamplingRate,...
    'NumDimensions',cfg_Monitor.NumDimensions,'Run',Run);

Name = "Reconstruction Monitor";

UpdateFcn = @(data) cgg_displayReconstructionAndClassificationMonitor(...
    data,Monitor);

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(IsOptimal) calcMonitorUpdate(Monitor,IsOptimal);
DataValuesFcn = @(IsOptimal) generateData(Monitor,...
    MonitorUpdateFcn(IsOptimal));
Monitor_ValueUpdate = @(IsOptimal) ...
    UpdateFcn(DataValuesFcn(IsOptimal));

MonitorUpdateFcn = @(Monitor_Values) ...
    updateCurrentMonitor_Value(Monitor,Monitor_Values);

SaveFcn = @(IsOptimal) Monitor_ValueUpdate(IsOptimal);

DataIdentifier = "";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
% this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,6} = {MonitorUpdateFcn};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
end

%% Gradient Monitor

if cfg_Monitor.WantGradientMonitor

    if cfg_Monitor.WantEncoderGradient 
TableIDX = TableIDX + 1;
SaveTerm = '-Encoder';
[Monitor,DataNames] = cgg_generateGradientMonitor(...
    'SaveDir',cfg_Monitor.SaveDir,'SaveTerm',SaveTerm,'Run',Run);

Name = sprintf("Gradient Monitor  - %s","Encoder");

UpdateFcn = @(data) updatePlot(Monitor,...
    data{1},data{2},data{3},data{4},data{5});

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = "Encoder";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;

    end

if cfg_Monitor.WantReconstructionLoss && cfg_Monitor.WantDecoderGradient 
TableIDX = TableIDX + 1;
SaveTerm = '-Decoder';
[Monitor,DataNames] = cgg_generateGradientMonitor(...
    'SaveDir',cfg_Monitor.SaveDir,'SaveTerm',SaveTerm,'Run',Run);

Name = sprintf("Gradient Monitor  - %s","Decoder");

UpdateFcn = @(data) updatePlot(Monitor,...
    data{1},data{2},data{3},data{4},data{5});

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = "Decoder";

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
end

if cfg_Monitor.WantClassificationLoss
    for didx = 1:cfg_Monitor.NumDimensions
TableIDX = TableIDX + 1;
SaveTerm = sprintf('-Classifier-Dimension-%d',didx);
[Monitor,DataNames] = cgg_generateGradientMonitor(...
    'SaveDir',cfg_Monitor.SaveDir,'SaveTerm',SaveTerm,'Run',Run);

Name = sprintf("Gradient Monitor  - Classifier-Dimension-%d",didx);

UpdateFcn = @(data) updatePlot(Monitor,...
    data{1},data{2},data{3},data{4},data{5});

dataQueue = parallel.pool.DataQueue;
afterEach(dataQueue,UpdateFcn);
ParallelUpdateFcn = @(data) send(dataQueue,data);

MonitorUpdateFcn = @(Monitor_Values) calcMonitorUpdate(Monitor,Monitor_Values);
DataValuesFcn = @(Monitor_Values) generateData(Monitor,...
    MonitorUpdateFcn(Monitor_Values));
Monitor_ValueUpdate = @(Monitor_Values) ...
    UpdateFcn(DataValuesFcn(Monitor_Values));

SaveFcn = @(IsOptimal) savePlot(Monitor,IsOptimal);

DataIdentifier = sprintf("Classifier-Dimension-%d",didx);

UpdateEachIteration = true;

this_Monitor = cell(1,NumVariables);
this_Monitor(:,1) = {Name};
this_Monitor{:,2} = {Monitor};
this_Monitor{:,3} = {UpdateFcn};
this_Monitor{:,4} = {ParallelUpdateFcn};
this_Monitor{:,5} = {SaveFcn};
this_Monitor{:,6} = {Monitor_ValueUpdate};
this_Monitor{:,7} = {DataNames};
this_Monitor(:,8) = {DataIdentifier};
this_Monitor(:,9) = {UpdateEachIteration};

this_TableRange = TableIDX;

MonitorTable(this_TableRange,:) = this_Monitor;
    end
end

end
%% Accuracy Monitor

% Monitor_Accuracy = cgg_generateAccuracyMonitor(varargin);

end

