function ThresholdTable = cgg_getNullThreshold(EpochDir,Folds,cfg_Encoder,varargin)
%CGG_GETNULLTHRESHOLD Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', 'Subset', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName='Subset';
end
end

if isfunction
SetType = CheckVararginPairs('SetType', 'Testing', varargin{:});
else
if ~(exist('SetType','var'))
SetType='Testing';
end
end

if isfunction
Alpha = CheckVararginPairs('Alpha', 0.05, varargin{:});
else
if ~(exist('Alpha','var'))
Alpha=0.05;
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', 'All', varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter='All';
end
end

if isfunction
TargetFilter = CheckVararginPairs('TargetFilter', 'Overall', varargin{:});
else
if ~(exist('TargetFilter','var'))
TargetFilter='Overall';
end
end

NumFolds = length(Folds);
this_Percentile = (1-Alpha)*100; 
% One tail since only care about if accuracy is higher not lower

TableVariables = [["Fold", "double"]; ...
    ["Threshold", "double"]];

NumVariables = size(TableVariables,1);
ThresholdTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

for fidx = 1:NumFolds
    Fold = Folds(fidx);
    [Training,Validation,Testing,~] = cgg_getDatastore(EpochDir.Main,SessionName,Fold,cfg_Encoder);
    
    switch SetType
        case 'Training'
            DataStore = Training;
        case 'Validation'
            DataStore = Validation;
        case 'Testing'
            DataStore = Testing;
        otherwise
            DataStore = Testing;
    end

    [ClassNames,~,~,~,TrueValue] = cgg_getClassesFromDataStore(DataStore);
    [Distribution] = cgg_getBaselineAccuracyDistribution(TrueValue,ClassNames,MatchType,IsQuaddle,varargin{:});
    
    this_Threshold = prctile(Distribution(1,:),this_Percentile);

    ThresholdTable(Fold,:) = {Fold,this_Threshold};
end

end

