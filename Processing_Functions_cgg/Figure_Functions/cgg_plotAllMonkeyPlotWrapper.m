function cgg_plotAllMonkeyPlotWrapper(PlotFunc,InputTable)
%CGG_PLOTALLMONKEYPLOTWRAPPER Summary of this function goes here
%   Detailed explanation goes here

PlotFunc(InputTable,'');

[MonkeyNamesIDX,MonkeyNames] = findgroups(InputTable.MonkeyName);

for midx = 1:length(MonkeyNames)
    this_InputTable = InputTable(MonkeyNamesIDX == midx, :);
    AdditionalTerm = sprintf('%s_',MonkeyNames{midx});
    PlotFunc(this_InputTable,AdditionalTerm);
end
end

