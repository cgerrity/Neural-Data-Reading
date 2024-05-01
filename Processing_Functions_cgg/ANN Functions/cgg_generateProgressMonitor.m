function monitor = cgg_generateProgressMonitor(varargin)
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

groupSubPlot(monitor,"Loss",["LossTraining","LossValidation"]);

if strcmp(LossType,'Classification')
groupSubPlot(monitor,"Accuracy",["MajorityClass","RandomChance","AccuracyTraining","AccuracyValidation"]);
end

monitor.Info = ["LearningRate","Epoch","Iteration","Loss","Workers","ExecutionEnvironment"];

monitor.Status = "Configuring";
monitor.Progress = 0;

executionEnvironment = "auto";

if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    updateInfo(monitor,ExecutionEnvironment="GPU");
else
    updateInfo(monitor,ExecutionEnvironment="CPU");
end

drawnow;
end

