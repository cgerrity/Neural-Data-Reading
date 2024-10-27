function PlotTable = cgg_getFullFigureDataForVariableToData(InputCell,varargin)
%CGG_GETFULLFIGUREDATAFORVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Model_Variable = CheckVararginPairs('Model_Variable', "", varargin{:});
else
if ~(exist('Model_Variable','var'))
Model_Variable="";
end
end

if isfunction
AreaNames = CheckVararginPairs('AreaNames', {"ACC", "PFC", "CD"}, varargin{:});
else
if ~(exist('AreaNames','var'))
AreaNames={"ACC", "PFC", "CD"};
end
end

if isfunction
WantPaperFormat = CheckVararginPairs('WantPaperFormat', true, varargin{:});
else
if ~(exist('WantPaperFormat','var'))
WantPaperFormat=true;
end
end

if isfunction
WantDecisionCentered = CheckVararginPairs('WantDecisionCentered', false, varargin{:});
else
if ~(exist('WantDecisionCentered','var'))
WantDecisionCentered=false;
end
end

%%

%%
Time_Offset = 0;
if WantPaperFormat
cfg_Paper = PLOTPARAMETERS_cgg_plotPlotStyle('WantPaperFormat',WantPaperFormat,'WantDecisionCentered',WantDecisionCentered);
Time_Offset=cfg_Paper.Time_Offset;
end

%%

Model_Variable = string(Model_Variable);

TableVariables = [["PlotData", "cell"]; ...
    ["Area", "string"]; ...
    ["Monkey", "string"]; ...
    ["Model_Variable", "string"]];

NumVariables = size(TableVariables,1);
PlotTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

PlotTableIDX = 0;

%%
for cidx = 1:length(InputCell)
InputTable = InputCell{cidx};
this_AreaName = string(AreaNames{cidx});
[MonkeyNamesIDX,MonkeyNames] = findgroups(InputTable.MonkeyName);
this_PlotData = cgg_getFigureDataForVariableToData(InputTable,'Time_Offset',Time_Offset,varargin{:});

PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,"All",Model_Variable};

for midx = 1:length(MonkeyNames)
this_InputTable = InputTable(MonkeyNamesIDX == midx, :);
this_PlotData = cgg_getFigureDataForVariableToData(this_InputTable,'Time_Offset',Time_Offset,varargin{:});
PlotTableIDX = PlotTableIDX + 1;
PlotTable(PlotTableIDX,:) = ...
    {{this_PlotData},this_AreaName,MonkeyNames(midx),Model_Variable};
end

end



end

