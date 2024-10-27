function PlotData = cgg_getPlotDataForVariableToData(InputTable,SignificanceValue,AreaName,PlotInformation)
%CGG_GETPLOTDATAFORVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here
PlotData = struct();

%%

PlotVariable = PlotInformation.PlotVariable;
PlotParameters = PlotInformation.PlotParameters;

%%

SignificanceMimimum = PlotInformation.SignificanceMimimum;
SignificanceSamples = SignificanceMimimum*PlotInformation.SamplingRate;

%%
if PlotInformation.WantProportionSignificant
PlotTitle_Significance = ' Proportion Significant';
if PlotInformation.WantSplitPositiveNegative
YLimits = PlotParameters.Limit_ChannelProportion_Small;
PlotData.YLimits = YLimits;
end
else
PlotTitle_Significance = '';
YLimits = NaN;
Y_Ticks = NaN; 
PlotData.YLimits = YLimits;
PlotData.Y_Ticks = Y_Ticks;
end
PlotTitle_Model = sprintf('%s%s for %s',PlotVariable,PlotTitle_Significance,AreaName);

%%

if PlotInformation.WantDifference
YLimits = NaN;
Y_Ticks = NaN; 
PlotData.YLimits = YLimits;
PlotData.Y_Ticks = Y_Ticks;
end

%%

switch PlotVariable
    case 'Model'
        P_Value = InputTable{:,"P_Value"};
        R_Value = InputTable{:,"R_Value_Adjusted"};
        PlotNames = {''};
        WantLegend = false;
        Y_Name = {'Explained Variance'};
        DataTransform='';
    case 'Coefficient'
        P_Value=InputTable{:,"P_Value_Coefficients"};
        R_Value = InputTable{:,"B_Value_Coefficients"};
        PlotNames = PlotInformation.CoefficientNames;
        WantLegend = true;
        Y_Name = {'Beta Value'};
        DataTransform='';
    case 'Correlation'
        P_Value=InputTable{:,"P_Correlation"};
        R_Value = InputTable{:,"R_Correlation"};
        PlotNames = {''};
        WantLegend = false;
        Y_Name = {'Correlation'};
        DataTransform={@(x) atanh(x),@(x) tanh(x)}; % Fisher Z Transform
    otherwise
end

%%
NumChannels = height(InputTable);
[Dim_1,Dim_2] = size(P_Value);
NumSamples = Dim_1;
if Dim_1 == NumChannels
    NumSamples = Dim_2;
end
NumWindows = NumSamples;

%%

P_Value_Positive = P_Value;
P_Value_Negative = P_Value;
R_Value_Positive = R_Value;
R_Value_Negative = R_Value;
P_Value_Positive(R_Value_Positive < 0) = NaN;
P_Value_Negative(R_Value_Negative > 0) = NaN;
R_Value_Positive(R_Value_Positive < 0) = NaN;
R_Value_Negative(R_Value_Negative > 0) = NaN;

if PlotInformation.WantSplitPositiveNegative
    PlotNames = {'Positive','Negative'};
    WantLegend = true;
end

P_Value_NaN=isnan(P_Value);
P_Value_Positive_NaN=isnan(P_Value_Positive);
P_Value_Negative_NaN=isnan(P_Value_Negative);

SignificantValues = P_Value < SignificanceValue;
SignificantValues_Positive = P_Value_Positive < SignificanceValue;
SignificantValues_Negative = P_Value_Negative < SignificanceValue;

if ~isempty(SignificanceSamples)
    Significance_SE = ones(1,SignificanceSamples);
SignificantValues = imopen(SignificantValues,Significance_SE);
SignificantValues_Positive = imopen(SignificantValues_Positive,Significance_SE);
SignificantValues_Negative = imopen(SignificantValues_Negative,Significance_SE);
end

% If Want Significant Values
if PlotInformation.WantSignificant
    R_Value(~SignificantValues)=NaN;
    R_Value_Positive(~SignificantValues) = NaN;
    R_Value_Negative(~SignificantValues) = NaN;
end

SignificantValues = double(SignificantValues);
SignificantValues(P_Value_NaN) = NaN;
R_Value(P_Value_NaN) = NaN;

SignificantValues_Positive = double(SignificantValues_Positive);
SignificantValues_Positive(P_Value_NaN) = NaN;
R_Value_Positive(P_Value_Positive_NaN) = NaN;

SignificantValues_Negative = double(SignificantValues_Negative);
SignificantValues_Negative(P_Value_NaN) = NaN;
R_Value_Negative(P_Value_Negative_NaN) = NaN;

% [R_Value,SignificantValues] = cgg_getSignificantValuesFromTable(InputTable,PlotInformation,SignificanceValue,'');
% [R_Value_Positive,SignificantValues_Positive] = cgg_getSignificantValuesFromTable(InputTable,PlotInformation,SignificanceValue,'Positive');
% [R_Value_Negative,SignificantValues_Negative] = cgg_getSignificantValuesFromTable(InputTable,PlotInformation,SignificanceValue,'Negative');

%%

if strcmp(PlotVariable,'Correlation')
    R_Value_Negative = abs(R_Value_Negative);
end

PlotError = '';

if PlotInformation.WantProportionSignificant
    DataTransform='';
    if PlotInformation.WantSplitPositiveNegative
        if PlotInformation.WantDifference
            [PlotValue,PlotError] = cgg_getDifferenceSeries(SignificantValues_Positive,SignificantValues_Negative,NumSamples);
        else
            PlotValue = cat(3,SignificantValues_Positive,SignificantValues_Negative);
        end
    else
    PlotValue = SignificantValues;
    end
    Y_Name = {'Proportion of','Significant Channels'};
else
    if PlotInformation.WantSplitPositiveNegative
        if PlotInformation.WantDifference
            [PlotValue,PlotError] = cgg_getDifferenceSeries(R_Value_Positive,R_Value_Negative,NumSamples);
        else
            PlotValue = cat(3,R_Value_Positive,R_Value_Negative);
        end
    else
    PlotValue = R_Value;
    end
end

%%
if PlotInformation.WantDifference
WantLegend = false;
Y_Name{1} = ['Difference of ' Y_Name{1}];
end

%%

if strcmp(PlotVariable,'Coefficient') && PlotInformation.WantSplitPositiveNegative
    NumPlots = length(PlotInformation.CoefficientNames);
    HasMultiplePlots = true;
else
    NumPlots = 1;
    HasMultiplePlots = false;
end

%%
if isfield(PlotInformation,'TimeSelection')
Time_Start = PlotInformation.Time_Start;
Time_End = PlotInformation.Time_End;
Time_Start=Time_Start + PlotParameters.Time_Offset;
Time_End=Time_End + PlotParameters.Time_Offset;
Time = linspace(Time_Start,Time_End,NumWindows);

TimeSelection_Start = PlotInformation.TimeSelection(1);
TimeSelection_End = PlotInformation.TimeSelection(2);

[~,TimeSelection_StartIDX] = min(abs(Time - TimeSelection_Start));
[~,TimeSelection_EndIDX] = min(abs(Time - TimeSelection_End));

TimeSelectionRange = TimeSelection_StartIDX:TimeSelection_EndIDX;

PlotValue = PlotValue(:,TimeSelectionRange,:);
if ~isempty(PlotError)
PlotError = PlotError(TimeSelectionRange,:);
end
Time_Start = TimeSelection_Start;
Time_End = TimeSelection_End;
PlotData.Time_Start = Time_Start;
PlotData.Time_End = Time_End;

end

%%

Dim_First = 1;
Dim_Second = 2;
PlotValue_Time = mean(PlotValue,Dim_First,"omitmissing");
PlotValue_Channel = mean(PlotValue,Dim_Second,"omitmissing");
PlotValue_Single = mean(PlotValue_Time,Dim_Second,"omitmissing");

CountPerSample_Time=sum(~isnan(PlotValue_Time),Dim_Second);
CountPerSample_Time(CountPerSample_Time==0)=NaN;
PlotValue_STD_Time = std(PlotValue_Time,[],Dim_Second,"omitnan");
PlotValue_STE_Time = PlotValue_STD_Time./sqrt(CountPerSample_Time);
ts = tinv(1-SignificanceValue/2,CountPerSample_Time-1);
PlotValue_Single_CI_Time = ts.*PlotValue_STE_Time;

CountPerSample_Channel=sum(~isnan(PlotValue_Channel),Dim_First);
CountPerSample_Channel(CountPerSample_Channel==0)=NaN;
PlotValue_STD_Channel = std(PlotValue_Channel,[],Dim_First,"omitnan");
PlotValue_STE_Channel = PlotValue_STD_Channel./sqrt(CountPerSample_Channel);
ts = tinv(1-SignificanceValue/2,CountPerSample_Channel-1);
PlotValue_Single_CI_Channel = ts.*PlotValue_STE_Channel;

PlotData.PlotValue_Time = squeeze(PlotValue_Time);
PlotData.PlotValue_Channel = squeeze(PlotValue_Channel)';
PlotData.PlotValue_Single = PlotValue_Single;
PlotData.PlotValue_Single_CI_Time = squeeze(PlotValue_Single_CI_Time);
PlotData.PlotValue_Single_CI_Channel = squeeze(PlotValue_Single_CI_Channel);


%%
PlotValue_CoverageAmount = PlotInformation.PlotValue_CoverageAmount;

PlotValue_Coverage = PlotValue_Single > PlotValue_CoverageAmount; 
%%
if isfield(PlotInformation,'NeighborhoodSize')
    NeighborhoodSize = PlotInformation.NeighborhoodSize;
else
    NeighborhoodSize = [];
end

PlotData.PlotValue_Neighborhood = [];
PlotData.PlotValue_Coverage = [];
Name_NeighborhoodTable = sprintf("NeighborhoodSize_%d",NeighborhoodSize);
if ismember(Name_NeighborhoodTable,InputTable.Properties.VariableNames)
    PlotValue_Neighborhood = InputTable.(Name_NeighborhoodTable);
    if iscell(PlotValue_Neighborhood)
        Size_Set = size(PlotValue_Neighborhood);
        Size_Data = size(PlotValue_Neighborhood{1});

        if ~(Size_Set(1) == 1)
            PlotValue_Neighborhood = PlotValue_Neighborhood';
        end
        if Size_Data(2) == 1
            PlotValue_Neighborhood = cell2mat(PlotValue_Neighborhood);
        end
    end
    PlotData.PlotValue_Neighborhood = PlotValue_Neighborhood;
    PlotValue_Coverage = PlotValue_Neighborhood > PlotValue_CoverageAmount; 
    PlotData.PlotValue_Coverage = PlotValue_Coverage;
end

%%

PlotData.PlotTitle_Significance = PlotTitle_Significance;
PlotData.PlotTitle_Model = PlotTitle_Model;
PlotData.PlotNames = PlotNames;
PlotData.WantLegend = WantLegend;
PlotData.Y_Name = Y_Name;
PlotData.DataTransform = DataTransform;
PlotData.PlotValue = PlotValue;
PlotData.PlotError = PlotError;
PlotData.NumPlots = NumPlots;
PlotData.HasMultiplePlots = HasMultiplePlots;


end

