function monitor = cgg_generateProgressMonitor_v2(varargin)
%CGG_GENERATEPROGRESSMONITOR Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
LossType = CheckVararginPairs('LossType', 'Classification', varargin{:});
else
if ~(exist('LossType','var'))
LossType='Classification';
end
end

if isfunction
LogLoss = CheckVararginPairs('LogLoss', false, varargin{:});
else
if ~(exist('LogLoss','var'))
LogLoss=false;
end
end

if isfunction
WantKLLoss = CheckVararginPairs('WantKLLoss', false, varargin{:});
else
if ~(exist('WantKLLoss','var'))
WantKLLoss=false;
end
end

if isfunction
WantClassificationLoss = CheckVararginPairs('WantClassificationLoss', false, varargin{:});
else
if ~(exist('WantClassificationLoss','var'))
WantClassificationLoss=false;
end
end

if isfunction
WantReconstructionLoss = CheckVararginPairs('WantReconstructionLoss', false, varargin{:});
else
if ~(exist('WantReconstructionLoss','var'))
WantReconstructionLoss=false;
end
end

%%

switch LossType
    case 'Classification'
        MetricNames=["MajorityClass","RandomChance","LossTraining","LossValidation","AccuracyTraining","AccuracyValidation"];
    case 'Regression'
        MetricNames=["LossTraining","LossValidation"];
    otherwise
end


monitor = trainingProgressMonitor( ...
    Metrics=MetricNames, ...
    XLabel="Iteration");

Title_Loss="Loss";
if LogLoss
Title_Loss="Log_Loss";
end

groupSubPlot(monitor,Title_Loss,["LossTraining","LossValidation"]);

if strcmp(LossType,'Classification')
groupSubPlot(monitor,"Accuracy",["MajorityClass","RandomChance","AccuracyTraining","AccuracyValidation"]);
end

monitor.Info = "Workers";
monitor.Info = [monitor.Info, "ExecutionEnvironment", "LearningRate"];
monitor.Info = [monitor.Info, "Epoch","Iteration"];

if LogLoss
monitor.Info = [monitor.Info, "LossType"];
end
monitor.Info = [monitor.Info, "Loss"];

if WantKLLoss
    monitor.Info=[monitor.Info, "KL_Loss"];
end
if WantReconstructionLoss
    monitor.Info=[monitor.Info, "Reconstruction_Loss"];
end
if WantClassificationLoss
    monitor.Info=[monitor.Info, "Classification_Loss"];
end

monitor.Status = "Configuring";
monitor.Progress = 0;

executionEnvironment = "auto";

if LogLoss
updateInfo(monitor,LossType="Log");
end

if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    updateInfo(monitor,ExecutionEnvironment="GPU");
else
    updateInfo(monitor,ExecutionEnvironment="CPU");
end

drawnow;
end

