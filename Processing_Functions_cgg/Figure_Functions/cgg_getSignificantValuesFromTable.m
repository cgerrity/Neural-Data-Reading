function [R_Value,SignificantValues] = cgg_getSignificantValuesFromTable(InputTable,PlotInformation,SignificanceValue,ValueRange)
%CGG_GETSIGNIFICANTVALUESFROMTABLE Summary of this function goes here
%   Detailed explanation goes here


PlotVariable = PlotInformation.PlotVariable;
SignificanceMimimum = PlotInformation.SignificanceMimimum;
SignificanceSamples = SignificanceMimimum*PlotInformation.SamplingRate;

%%

switch PlotVariable
    case 'Model'
        P_Value = InputTable{:,"P_Value"};
        R_Value = InputTable{:,"R_Value_Adjusted"};
    case 'Coefficient'
        P_Value=InputTable{:,"P_Value_Coefficients"};
        R_Value = InputTable{:,"B_Value_Coefficients"};
    case 'Correlation'
        P_Value=InputTable{:,"P_Correlation"};
        R_Value = InputTable{:,"R_Correlation"};
    otherwise
end

%%
RemovedChannels=isnan(P_Value);

%%

switch ValueRange
    case 'Positive'
        P_Value(R_Value < 0) = NaN;
        R_Value(R_Value < 0) = NaN;
    case 'Negative'
        P_Value(R_Value > 0) = NaN;
        R_Value(R_Value > 0) = NaN;
    otherwise
end



%%

% P_Value_NaN=isnan(P_Value);

SignificantValues = P_Value < SignificanceValue;

if ~isempty(SignificanceSamples)
    Significance_SE = ones(1,SignificanceSamples);
    SignificantValues = imopen(SignificantValues,Significance_SE);
end

if PlotInformation.WantSignificant
    R_Value(~SignificantValues)=NaN;
end

% Removed Channels should be NaN for the significant values since they
% should not be counted at all, whereas not significant values should be
% zero since they should be included but represent not significant values.
SignificantValues = double(SignificantValues);
SignificantValues(RemovedChannels) = NaN;
R_Value(RemovedChannels) = NaN;

end

