function cgg_saveAllMonitors(MonitorTable,IsOptimal,SaveAll)
%CGG_SAVEALLMONITORS Summary of this function goes here
%   Detailed explanation goes here

if SaveAll

NumMonitors = height(MonitorTable);

for midx = 1:NumMonitors

MonitorValueUpdateFunction=MonitorTable{midx,"SaveFunction"}{1};
MonitorValueUpdateFunction(IsOptimal);
end

end

end

