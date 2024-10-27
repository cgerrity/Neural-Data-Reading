function cfg_Monitor = cgg_generateMonitorCFG(cfg_Encoder,Encoder,Decoder,Classifier,varargin)
%CGG_GENERATEMONITORCFG Summary of this function goes here
%   Detailed explanation goes here

if exist("cfg_Monitor","var")
if ~isstruct(cfg_Monitor)
    cfg_Monitor = struct();
end
else
    cfg_Monitor = struct();
end

isfunction=exist('varargin','var');

this_VarName = 'LogLoss';
if isfunction
this_Var = CheckVararginPairs(this_VarName, [], varargin{:});
else
if ~(exist(this_VarName,'var'))
this_Var=[];
end
end
if ~isempty(this_Var)
cfg_Monitor.(this_VarName) = this_Var;
end

this_VarName = 'SaveDir';
if isfunction
this_Var = CheckVararginPairs(this_VarName, [], varargin{:});
else
if ~(exist(this_VarName,'var'))
this_Var=[];
end
end
if ~isempty(this_Var)
cfg_Monitor.(this_VarName) = this_Var;
end

this_VarName = 'NumEpochs';
if isfunction
this_Var = CheckVararginPairs(this_VarName, [], varargin{:});
else
if ~(exist(this_VarName,'var'))
this_Var=[];
end
end
if ~isempty(this_Var)
cfg_Monitor.(this_VarName) = this_Var;
end

%%

HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);
IsVariational = false;

NumDimensions = [];

if HasDecoder
IsVariational = any(contains(Decoder.OutputNames,'/mean')) && ...
    any(contains(Decoder.OutputNames,'/log-variance'));
LossType = 'Regression';
end
if HasClassifier
LossType = 'Classification';
NumDimensions = length(Classifier.OutputNames);
else
    NumDimensions = 0;
end

[~,InputSize] = cgg_getNetworkIOSize(Encoder,'Input');

NumAreas = InputSize(3);
DataWidth = InputSize(2);


cfg_Monitor.LossType = LossType;
cfg_Monitor.WantKLLoss = IsVariational;
cfg_Monitor.WantReconstructionLoss = HasDecoder;
cfg_Monitor.WantClassificationLoss = HasClassifier;
cfg_Monitor.NumAreas = NumAreas;
cfg_Monitor.DataWidth = DataWidth;

if ~isempty(NumDimensions)
cfg_Monitor.NumDimensions = NumDimensions;
end

%%

this_VarName = 'Time_Start';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'Time_End';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'SamplingRate';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WindowStride';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'NumWindows';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantProgressMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantExampleMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantComponentMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantAccuracyMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantWindowMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantReconstructionMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'WantGradientMonitor';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end
this_VarName = 'AccuracyMeasures';
if isfield(cfg_Encoder,this_VarName)
cfg_Monitor.(this_VarName) = cfg_Encoder.(this_VarName);
end

end

