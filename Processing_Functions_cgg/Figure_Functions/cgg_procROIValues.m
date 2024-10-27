function [Data_ROI_Time,Data_ROI,Data_ROI_STD,Data_ROI_STE,Data_ROI_CI] = ...
    cgg_procROIValues(Data,Time_ROI,Time,NumData)
%CGG_PROCROIVALUES Summary of this function goes here
%   Detailed explanation goes here

Time_ROI_Start = Time_ROI(1);
Time_ROI_End = Time_ROI(2);

[~,Time_ROI_StartIDX] = min(abs(Time - Time_ROI_Start));
[~,Time_ROI_EndIDX] = min(abs(Time - Time_ROI_End));

Time_ROI_Range = Time_ROI_StartIDX:Time_ROI_EndIDX;
NumSamples_ROI = length(Time_ROI_Range);

[Dim1,~] = size(Data);

if Dim1 == NumData
    Data_ROI_Full = Data(:,Time_ROI_Range,:);
else
    Data_ROI_Full = Data(Time_ROI_Range,:,:);
end

[Data_ROI_Time,~,~,~] = ...
    cgg_getMeanSTDSeries(Data_ROI_Full,'NumSamples',NumSamples_ROI);
[Data_ROI,Data_ROI_STD,Data_ROI_STE,Data_ROI_CI] = ...
    cgg_getMeanSTDSeries(Data_ROI_Time,'NumSamples',1);

end

