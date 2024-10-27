function DataLimits = cgg_getPlotRangeFromData(InData,RangeFactor,OutlierWindow,Threshold)
%CGG_GETPLOTRANGEFROMDATA Summary of this function goes here
%   Detailed explanation goes here

MostRecentAmount = 100;

if iscell(InData)
    GoodData = cellfun(@(x) x(~isoutlier(x,"movmedian",OutlierWindow,2,"ThresholdFactor",Threshold)),InData,'UniformOutput',false);
    if length(GoodData) > MostRecentAmount
    GoodData = cellfun(@(x) x(end-MostRecentAmount:end),GoodData,'UniformOutput',false);
    end
    GoodData = [GoodData{:}];
else
    GoodData = InData(~isoutlier(InData,"movmedian",OutlierWindow,2,"ThresholdFactor",Threshold));
    if length(GoodData) > MostRecentAmount
    GoodData = GoodData(end-MostRecentAmount:end);
    end
end

Range = range(GoodData);
if Range <= 0
Range = 0.00001;
end

Max = max(GoodData);
Min = min(GoodData);
RangeAddition = Range*RangeFactor;
DataLimits = [Min-RangeAddition,Max+RangeAddition];

end

