function PlotData = cgg_getFigureDataForVariableToData(InputTable,varargin)
%CGG_GETFIGUREDATAFORVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
SignificanceMimimum = CheckVararginPairs('SignificanceMimimum', [], varargin{:});
else
if ~(exist('SignificanceMimimum','var'))
SignificanceMimimum=[];
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
NumIter = CheckVararginPairs('NumIter', 1000, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=1000;
end
end

if isfunction
SamplingRate = CheckVararginPairs('SamplingRate', 1000, varargin{:});
else
if ~(exist('SamplingRate','var'))
SamplingRate=1000;
end
end

if isfunction
Time_ROI = CheckVararginPairs('Time_ROI', [], varargin{:});
else
if ~(exist('Time_ROI','var'))
Time_ROI=[];
end
end

% if isfunction
% ROINames = CheckVararginPairs('ROINames', {}, varargin{:});
% else
% if ~(exist('ROINames','var'))
% ROINames={};
% end
% end

if isfunction
Time_Offset = CheckVararginPairs('Time_Offset', 0, varargin{:});
else
if ~(exist('Time_Offset','var'))
Time_Offset=0;
end
end

if isfunction
Time_Start = CheckVararginPairs('Time_Start', -1.5, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=-1.5;
end
end

if isfunction
Time_End = CheckVararginPairs('Time_End', 1.5, varargin{:});
else
if ~(exist('Time_End','var'))
Time_End=1.5;
end
end

if isfunction
NeighborhoodSize = CheckVararginPairs('NeighborhoodSize', 30, varargin{:});
else
if ~(exist('NeighborhoodSize','var'))
NeighborhoodSize=30;
end
end

%%
this_InputTable = InputTable;
NaNValues = all(isnan(this_InputTable.P_Value),2);
this_InputTable(NaNValues,:) = [];

%%

NumData = height(this_InputTable);

Time_Start = Time_Start + Time_Offset;
Time_End = Time_End + Time_Offset;

Time = Time_Start:1/SamplingRate:Time_End;
NumSamples = length(Time);

%%

PlotInformation = struct();
PlotInformation.WantSignificant = true;
PlotInformation.PlotVariable = 'Correlation';
PlotInformation.SignificanceMimimum = SignificanceMimimum;
PlotInformation.SamplingRate = SamplingRate;

[R_Value_All,SignificantValues_All] = cgg_getSignificantValuesFromTable(this_InputTable,PlotInformation,SignificanceValue,'All');
[~,SignificantValues_Positive] = cgg_getSignificantValuesFromTable(this_InputTable,PlotInformation,SignificanceValue,'Positive');
[~,SignificantValues_Negative] = cgg_getSignificantValuesFromTable(this_InputTable,PlotInformation,SignificanceValue,'Negative');

PlotInformation.PlotVariable = 'Model';
[~,SignificantValues_Model] = cgg_getSignificantValuesFromTable(this_InputTable,PlotInformation,SignificanceValue,'All');

PlotInformation.PlotVariable = 'Coefficient';
PlotInformation.WantSignificant = false;
[Beta_Values,~] = cgg_getSignificantValuesFromTable(this_InputTable,PlotInformation,SignificanceValue,'All');

%%

[Dim1,~] = size(SignificantValues_All);
if Dim1 == NumSamples
SignificantValues_All = SignificantValues_All';
R_Value_All = R_Value_All';
end
[Dim1,~] = size(SignificantValues_Positive);
if Dim1 == NumSamples
SignificantValues_Positive = SignificantValues_Positive';
end
[Dim1,~] = size(SignificantValues_Negative);
if Dim1 == NumSamples
SignificantValues_Negative = SignificantValues_Negative';
end
[Dim1,~] = size(SignificantValues_Model);
if Dim1 == NumSamples
SignificantValues_Model = SignificantValues_Model';
end
[Dim1,~,~] = size(Beta_Values);
if Dim1 == NumSamples
Beta_Values = permute(Beta_Values,[2,1,3]);
end

%%
DataTransform={@(x) atanh(x),@(x) tanh(x)}; % Fisher Z Transform
[CorrelationAll,CorrelationAll_STD,CorrelationAll_STE,CorrelationAll_CI] = ...
    cgg_getMeanSTDSeries(abs(R_Value_All),'NumSamples',NumSamples,'DataTransform',DataTransform);

[Beta,Beta_STD,Beta_STE,Beta_CI] = ...
    cgg_getMeanSTDSeries(Beta_Values,'NumSamples',NumSamples);

%%

[ProportionAll,All_STD,All_STE,All_CI] = ...
    cgg_getMeanSTDSeries(SignificantValues_All,'NumSamples',NumSamples);

[ProportionPositive,Positive_STD,Positive_STE,Positive_CI] = ...
    cgg_getMeanSTDSeries(SignificantValues_Positive,'NumSamples',NumSamples);

[ProportionNegative,Negative_STD,Negative_STE,Negative_CI] = ...
    cgg_getMeanSTDSeries(SignificantValues_Negative,'NumSamples',NumSamples);

[ProportionModel,Model_STD,Model_STE,Model_CI] = ...
    cgg_getMeanSTDSeries(SignificantValues_Model,'NumSamples',NumSamples);

%%

if isempty(Time_ROI)
Time_ROI = [Time_Start,Time_End];
% ROINames = {'All'};
end

% this_ROI = struct

[~,ProportionAll_ROI,All_ROI_STD,All_ROI_STE,All_ROI_CI] = ...
    cgg_procROIValues(SignificantValues_All,Time_ROI,Time,NumData);
[ProportionPositive_Series_ROI,ProportionPositive_ROI,Positive_ROI_STD,Positive_ROI_STE,Positive_ROI_CI] = ...
    cgg_procROIValues(SignificantValues_Positive,Time_ROI,Time,NumData);
[ProportionNegative_Series_ROI,ProportionNegative_ROI,Negative_ROI_STD,Negative_ROI_STE,Negative_ROI_CI] = ...
    cgg_procROIValues(SignificantValues_Negative,Time_ROI,Time,NumData);

%%

All_ROI_T = ProportionAll_ROI/All_ROI_STE;

All_ROI_P_Value = tcdf(-abs(All_ROI_T),NumData-1) + tcdf(abs(All_ROI_T),NumData-1,'upper');

%% ROI Difference

ProportionDifference_Series_ROI = ProportionPositive_Series_ROI - ProportionNegative_Series_ROI;

[ProportionDifference,ProportionDifference_STD,ProportionDifference_STE,ProportionDifference_CI] = ...
    cgg_getMeanSTDSeries(ProportionDifference_Series_ROI,'NumSamples',1);

%%

if ~isempty(NeighborhoodSize)

%% Proportion Significant
    PlotInformation.PlotVariable = 'Correlation';
SignificantValues_Positive_Func = @(x) cgg_getSignificantValuesFromTable(x,PlotInformation,SignificanceValue,'Positive');
OutputGet_Positive_Func = @(x) cgg_getOutput(x,SignificantValues_Positive_Func,2);
% ROI_Positive_Func = @(x) cgg_procROIValues(OutputGet_Positive_Func(x),Time_ROI,Time,height(x));
ROI_Positive_Func = @(x) mean(cgg_procROIValues(OutputGet_Positive_Func(x),Time_ROI,Time,height(x)));

SignificantValues_Negative_Func = @(x) cgg_getSignificantValuesFromTable(x,PlotInformation,SignificanceValue,'Negative');
OutputGet_Negative_Func = @(x) cgg_getOutput(x,SignificantValues_Negative_Func,2);
% ROI_Negative_Func = @(x) cgg_procROIValues(OutputGet_Negative_Func(x),Time_ROI,Time,height(x));
ROI_Negative_Func = @(x) mean(cgg_procROIValues(OutputGet_Negative_Func(x),Time_ROI,Time,height(x)));

%% Correlation Strength
PlotInformation.PlotVariable = 'Correlation';
Correlation_Positive_Func = @(x) cgg_getSignificantValuesFromTable(x,PlotInformation,SignificanceValue,'Positive');
OutputCorrelation_Positive_Func = @(x) DataTransform{1}(cgg_getOutput(x,Correlation_Positive_Func,1));
ROI_Correlation_Positive_Func = @(x) mean(cgg_procROIValues(OutputCorrelation_Positive_Func(x),Time_ROI,Time,height(x)));

Correlation_Negative_Func = @(x) cgg_getSignificantValuesFromTable(x,PlotInformation,SignificanceValue,'Negative');
OutputCorrelation_Negative_Func = @(x) DataTransform{1}(cgg_getOutput(x,Correlation_Negative_Func,1));
ROI_Correlation_Negative_Func = @(x) mean(cgg_procROIValues(OutputCorrelation_Negative_Func(x),Time_ROI,Time,height(x)));

%%
NeighborhoodFunc = @(x) {ROI_Positive_Func(x),ROI_Negative_Func(x),ROI_Correlation_Positive_Func(x),ROI_Correlation_Negative_Func(x)};

NeighborhoodValue = cgg_getTableNeighborhood(this_InputTable,NeighborhoodSize,NeighborhoodFunc);

%%
SmallTolerance = 0.00000001;
HomogeneityIndex_Func = @(x) (x{1}-x{2})/(x{1}+x{2}+SmallTolerance);
HomogeneityIndex_Correlation_Func = @(x) (x{3}-abs(x{4}))/(x{3}+abs(x{4})+SmallTolerance);

HomogeneityIndex = cellfun(@(x) HomogeneityIndex_Func(x),NeighborhoodValue,"UniformOutput",true);
HomogeneityIndex_Correlation = cellfun(@(x) HomogeneityIndex_Correlation_Func(x),NeighborhoodValue,"UniformOutput",true);

ConfidenceRange = cgg_getSignTest(HomogeneityIndex,'NumIter',NumIter,'SignificanceValue',SignificanceValue);
ConfidenceRange_Correlation = cgg_getSignTest(HomogeneityIndex_Correlation,'NumIter',NumIter,'SignificanceValue',SignificanceValue);

HomogeneityIndex_Data = HomogeneityIndex;
HomogeneityIndex_Correlation_Data = HomogeneityIndex_Correlation;

[HomogeneityIndex,HomogeneityIndex_STD,HomogeneityIndex_STE,HomogeneityIndex_CI] = ...
    cgg_getMeanSTDSeries(HomogeneityIndex,'NumSamples',1);
[HomogeneityIndex_Correlation,HomogeneityIndex_Correlation_STD,HomogeneityIndex_Correlation_STE,HomogeneityIndex_Correlation_CI] = ...
    cgg_getMeanSTDSeries(HomogeneityIndex_Correlation,'NumSamples',1);

HomogeneityIndex_T = HomogeneityIndex/HomogeneityIndex_STE;
HomogeneityIndex_Correlation_T = HomogeneityIndex_Correlation/HomogeneityIndex_Correlation_STE;

HomogeneityIndex_P_Value = tcdf(-abs(HomogeneityIndex_T),NumData-1) + tcdf(abs(HomogeneityIndex_T),NumData-1,'upper');
HomogeneityIndex_Correlation_P_Value = tcdf(-abs(HomogeneityIndex_Correlation_T),NumData-1) + tcdf(abs(HomogeneityIndex_Correlation_T),NumData-1,'upper');

else
HomogeneityIndex = [];
HomogeneityIndex_Data = [];
HomogeneityIndex_STD = [];
HomogeneityIndex_STE = [];
HomogeneityIndex_CI = [];
HomogeneityIndex_P_Value = [];
ConfidenceRange = [];

HomogeneityIndex_Correlation = [];
HomogeneityIndex_Correlation_Data = [];
HomogeneityIndex_Correlation_STD = [];
HomogeneityIndex_Correlation_STE = [];
HomogeneityIndex_Correlation_CI = [];
HomogeneityIndex_Correlation_P_Value = [];
ConfidenceRange_Correlation = [];
end

%%

PlotData = struct();
PlotData.CorrelationAll = CorrelationAll;
PlotData.CorrelationAll_STD = CorrelationAll_STD;
PlotData.CorrelationAll_STE = CorrelationAll_STE;
PlotData.CorrelationAll_CI = CorrelationAll_CI;
PlotData.ProportionAll = ProportionAll;
PlotData.All_STD = All_STD;
PlotData.All_STE = All_STE;
PlotData.All_CI = All_CI;
PlotData.ProportionPositive = ProportionPositive;
PlotData.Positive_STD = Positive_STD;
PlotData.Positive_STE = Positive_STE;
PlotData.Positive_CI = Positive_CI;
PlotData.ProportionNegative = ProportionNegative;
PlotData.Negative_STD = Negative_STD;
PlotData.Negative_STE = Negative_STE;
PlotData.Negative_CI = Negative_CI;
PlotData.ProportionAll_ROI = ProportionAll_ROI;
PlotData.All_ROI_STD = All_ROI_STD;
PlotData.All_ROI_STE = All_ROI_STE;
PlotData.All_ROI_CI = All_ROI_CI;
PlotData.All_ROI_P_Value = All_ROI_P_Value;
PlotData.ProportionPositive_ROI = ProportionPositive_ROI;
PlotData.Positive_ROI_STD = Positive_ROI_STD;
PlotData.Positive_ROI_STE = Positive_ROI_STE;
PlotData.Positive_ROI_CI = Positive_ROI_CI;
PlotData.ProportionNegative_ROI = ProportionNegative_ROI;
PlotData.Negative_ROI_STD = Negative_ROI_STD;
PlotData.Negative_ROI_STE = Negative_ROI_STE;
PlotData.Negative_ROI_CI = Negative_ROI_CI;
PlotData.ProportionDifference_Series_ROI = ProportionDifference_Series_ROI;
PlotData.ProportionDifference = ProportionDifference;
PlotData.ProportionDifference_STD = ProportionDifference_STD;
PlotData.ProportionDifference_STE = ProportionDifference_STE;
PlotData.ProportionDifference_CI = ProportionDifference_CI;
PlotData.HomogeneityIndex = HomogeneityIndex;
PlotData.HomogeneityIndex_STD = HomogeneityIndex_STD;
PlotData.HomogeneityIndex_STE = HomogeneityIndex_STE;
PlotData.HomogeneityIndex_CI = HomogeneityIndex_CI;
PlotData.HomogeneityIndex_P_Value = HomogeneityIndex_P_Value;
PlotData.HomogeneityIndex_Data = HomogeneityIndex_Data;
PlotData.HomogeneityIndex_Correlation = HomogeneityIndex_Correlation;
PlotData.HomogeneityIndex_Correlation_STD = HomogeneityIndex_Correlation_STD;
PlotData.HomogeneityIndex_Correlation_STE = HomogeneityIndex_Correlation_STE;
PlotData.HomogeneityIndex_Correlation_CI = HomogeneityIndex_Correlation_CI;
PlotData.HomogeneityIndex_Correlation_P_Value = HomogeneityIndex_Correlation_P_Value;
PlotData.HomogeneityIndex_Correlation_Data = HomogeneityIndex_Correlation_Data;
PlotData.ProportionModel = ProportionModel;
PlotData.Model_STD = Model_STD;
PlotData.Model_STE = Model_STE;
PlotData.Model_CI = Model_CI;
PlotData.Beta = Beta;
PlotData.Beta_STD = Beta_STD;
PlotData.Beta_STE = Beta_STE;
PlotData.Beta_CI = Beta_CI;
PlotData.NumData = NumData;
PlotData.ConfidenceRange = ConfidenceRange;
PlotData.ConfidenceRange_Correlation = ConfidenceRange_Correlation;
%%

    % function Output = getOutput(Input,Func,OutputNumber)
    %     Output_tmp = cell(1,OutputNumber);
    %     [Output_tmp{:}] = Func(Input);
    %     Output = Output_tmp{OutputNumber};
    % end

end

