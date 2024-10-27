function cgg_updateAllMonitors(MonitorTable,Monitor_Values,UpdateAll)
%CGG_UPDATEALLMONITORS Summary of this function goes here
%   Detailed explanation goes here

NumMonitors = height(MonitorTable);

for midx = 1:NumMonitors
    UpdateEachIteration=MonitorTable{midx,"UpdateEachIteration"};
    if UpdateEachIteration || UpdateAll
MonitorValueUpdateFunction=MonitorTable{midx,"MonitorValueUpdateFunction"}{1};
MonitorValueUpdateFunction(Monitor_Values);
    end
end

end

