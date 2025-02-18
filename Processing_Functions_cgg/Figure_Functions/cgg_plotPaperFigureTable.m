function HomogenietyTable = cgg_plotPaperFigureTable(PlotTable,PlotPath,NeighborhoodSize,varargin)
%CGG_PLOTPAPERFIGURETABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
ROIName = CheckVararginPairs('ROIName', '', varargin{:});
else
if ~(exist('ROIName','var'))
ROIName='';
end
end


TableVariables = [["Mean ACC", "double"]; ...
    ["STE ACC", "double"]; ...
    ["P Value ACC", "double"]; ...
    ["Mean CD", "double"]; ...
    ["STE CD", "double"]; ...
    ["P Value CD", "double"]; ...
    ["Mean Difference", "double"]; ...
    ["P Value Difference", "double"]; ...
    ["Monkey", "string"]];

NumVariables = size(TableVariables,1);
HomogenietyTable = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));

[~,MonkeyNames] = findgroups(PlotTable.Monkey);
NumMonkeys = length(MonkeyNames);
for midx = 1:NumMonkeys
HomogenietyTable{midx,"Monkey"} = MonkeyNames(midx);
end

ACCIndices = strcmp(PlotTable{:,"Area"},"ACC");
CDIndices = strcmp(PlotTable{:,"Area"},"CD");

[MonkeyNamesIDX,MonkeyNames] = findgroups(PlotTable.Monkey);

%%

for midx = 1:length(MonkeyNames)
    this_MonkeyName = MonkeyNames(midx);
    MonkeyIndices = MonkeyNamesIDX == midx;
    ACCIDX = MonkeyIndices & ACCIndices;
    CDIDX = MonkeyIndices & CDIndices;
    PlotTable_ACC = PlotTable(ACCIDX,:);
    PlotTable_CD = PlotTable(CDIDX,:);

    PlotData_ACC = PlotTable_ACC.PlotData;
    PlotData_CD = PlotTable_CD.PlotData;
    PlotData_ACC = PlotData_ACC{1};
    PlotData_CD = PlotData_CD{1};

    this_MonkeyIDX = strcmp(HomogenietyTable{:,"Monkey"},this_MonkeyName);
    
    HomogeneityIndex_ACC = PlotData_ACC.HomogeneityIndex;
    HomogeneityIndex_STE_ACC = PlotData_ACC.HomogeneityIndex_STE;
    NumData_ACC = PlotData_ACC.NumData;

    HomogeneityIndex_CD = PlotData_CD.HomogeneityIndex;
    HomogeneityIndex_STE_CD = PlotData_CD.HomogeneityIndex_STE;
    NumData_CD = PlotData_CD.NumData;

    HomogenietyTable{this_MonkeyIDX,"Mean ACC"} = HomogeneityIndex_ACC;
    HomogenietyTable{this_MonkeyIDX,"STE ACC"} = HomogeneityIndex_STE_ACC;
    HomogenietyTable{this_MonkeyIDX,"P Value ACC"} = PlotData_ACC.HomogeneityIndex_P_Value;

    HomogenietyTable{this_MonkeyIDX,"Mean CD"} = HomogeneityIndex_CD;
    HomogenietyTable{this_MonkeyIDX,"STE CD"} = HomogeneityIndex_STE_CD;
    HomogenietyTable{this_MonkeyIDX,"P Value CD"} = PlotData_CD.HomogeneityIndex_P_Value;

    HomogenietyTable{this_MonkeyIDX,"Mean Difference"} = HomogeneityIndex_ACC - HomogeneityIndex_CD;

    this_T = (HomogeneityIndex_ACC-HomogeneityIndex_CD)/sqrt(HomogeneityIndex_STE_ACC^2+HomogeneityIndex_STE_CD^2);
    this_DF = ((HomogeneityIndex_STE_ACC^2+HomogeneityIndex_STE_CD^2)^2)/(((HomogeneityIndex_STE_ACC^2)^2)/(NumData_ACC-1)+((HomogeneityIndex_STE_CD^2)^2)/(NumData_CD-1));

    this_P_Value = tcdf(-abs(this_T),this_DF) + tcdf(abs(this_T),this_DF,'upper');

    HomogenietyTable{this_MonkeyIDX,"P Value Difference"} = this_P_Value;

end

HomogenietyTable = movevars(HomogenietyTable,'Monkey','Before',1);

InFigure = cgg_plotTable(HomogenietyTable,'Homogeneity Index');
if ~isempty(ROIName)
    ROIName = sprintf("-%s",ROIName);
end
PlotName=sprintf('Homogeneity_Table-Neighborhood_%s%d',ROIName,NeighborhoodSize);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

end

