function cgg_displayWindowMonitor(monitor,data)
%CGG_DISPLAYWINDOWMONITOR Summary of this function goes here
%   Detailed explanation goes here

iteration = data{1};

accuracyTraining = data{2};
accuracyValidation = data{3};

if any(~isnan(accuracyTraining))
    updatePlot(monitor,"AccuracyTraining",{iteration,accuracyTraining});
end

if any(~isnan(accuracyValidation))
    updatePlot(monitor,"AccuracyValidation",{iteration,accuracyValidation});
end

end

