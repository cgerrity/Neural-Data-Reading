function cgg_saveAllMonitors(MonitorTable,IsOptimal,SaveAll)
%CGG_SAVEALLMONITORS Summary of this function goes here
%   Detailed explanation goes here

if SaveAll

NumMonitors = height(MonitorTable);

SaveFunctions = MonitorTable{:,"SaveFunction"};
for midx = 1:NumMonitors

% MonitorTable{midx,"SaveFunction"}{1};
MonitorValueUpdateFunction = SaveFunctions{midx};
MonitorValueUpdateFunction(IsOptimal);
end

end

end

