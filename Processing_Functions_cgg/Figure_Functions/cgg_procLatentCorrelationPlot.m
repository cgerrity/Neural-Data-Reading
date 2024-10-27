function CorrelationTable = cgg_procLatentCorrelationPlot(Correlation,P_Value,varargin)
%CGG_PROCLATENTCORRELATIONPLOT Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
LMVariable = CheckVararginPairs('LMVariable', '', varargin{:});
else
if ~(exist('LMVariable','var'))
LMVariable='';
end
end

%%

if ~iscell(Correlation)
    Correlation = {Correlation};
end
if ~iscell(P_Value)
    P_Value = {P_Value};
end

NumFolds = min([length(Correlation),length(P_Value)]);

[NumLatent,NumSamples] = size(Correlation{1});

%%
PlotInformation = struct();
PlotInformation.PlotVariable = 'Correlation';
PlotInformation.SignificanceMimimum = [];
PlotInformation.SamplingRate = [];
PlotInformation.WantSignificant = true;

ValueRange = 'All';

%%

Proportion_Fold = NaN(NumFolds, NumSamples);
Correlation_Fold = NaN(NumFolds, NumSamples);

for fidx = 1:NumFolds

this_Correlation = Correlation{fidx};
this_P_Value = P_Value{fidx};

InputTable = table(this_Correlation,this_P_Value, ...
    'VariableNames',{'R_Correlation','P_Correlation'});

[SignificantCorrelation,SignificantValues] = ...
cgg_getSignificantValuesFromTable(InputTable,PlotInformation, ...
SignificanceValue,ValueRange);

%%
DataTransform = '';
[this_Proportion_Fold,~,~,~] = ...
    cgg_getMeanSTDSeries(SignificantValues, ...
    'SignificanceValue',SignificanceValue, ...
    'DataTransform',DataTransform,'NumSamples',NumSamples);

DataTransform={@(x) atanh(x),@(x) tanh(x)}; % Fisher Z Transform
[this_Correlation_Fold,~,~,~] = ...
    cgg_getMeanSTDSeries(abs(SignificantCorrelation), ...
    'SignificanceValue',SignificanceValue, ...
    'DataTransform',DataTransform,'NumSamples',NumSamples);

Proportion_Fold(fidx,:) = this_Proportion_Fold;
Correlation_Fold(fidx,:) = this_Correlation_Fold;
end

%%
DataTransform = '';
[Proportion,Proportion_STD,Proportion_STE,Proportion_CI] = ...
    cgg_getMeanSTDSeries(Proportion_Fold, ...
    'SignificanceValue',SignificanceValue, ...
    'DataTransform',DataTransform,'NumSamples',NumSamples);

DataTransform={@(x) atanh(x),@(x) tanh(x)}; % Fisher Z Transform
[CorrelationStrength,CorrelationStrength_STD,CorrelationStrength_STE, ...
    CorrelationStrength_CI] = ...
    cgg_getMeanSTDSeries(abs(Correlation_Fold), ...
    'SignificanceValue',SignificanceValue, ...
    'DataTransform',DataTransform,'NumSamples',NumSamples);

%%

VariableNames = {'Proportion','Proportion_STD','Proportion_STE', ...
    'Proportion_CI','Correlation','Correlation_STD', ...
    'Correlation_STE','Correlation_CI','LMVariable','LatentSize'};

CorrelationTable = table({Proportion},{Proportion_STD}, ...
    {Proportion_STE},{Proportion_CI},{CorrelationStrength}, ...
    {CorrelationStrength_STD},{CorrelationStrength_STE}, ...
    {CorrelationStrength_CI},string(LMVariable),NumLatent, ...
    'VariableNames',VariableNames);

end

