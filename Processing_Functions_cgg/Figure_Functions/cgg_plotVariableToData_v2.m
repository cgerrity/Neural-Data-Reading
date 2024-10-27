function cgg_plotVariableToData_v2(InputTable,SignificanceValue,AreaName,PlotInformation,Plotcfg,varargin)
%CGG_PLOTVARIABLETODATA Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
AdditionalTerm = CheckVararginPairs('AdditionalTerm', '', varargin{:});
else
if ~(exist('AdditionalTerm','var'))
AdditionalTerm='';
end
end

if isfunction
InFigure = CheckVararginPairs('InFigure', '', varargin{:});
else
if ~(exist('InFigure','var'))
InFigure='';
end
end


%%
if isfield(PlotInformation,'NeighborhoodSize')
    if ~isempty(PlotInformation.NeighborhoodSize)
        WantNeighborhood = true;
    else
        WantNeighborhood = false;
    end
else
    WantNeighborhood = false;
end

if isfield(PlotInformation,'WantCoverage')
    WantCoverage = PlotInformation.WantCoverage;
else
    WantCoverage = false;
end
%%
if WantNeighborhood
    %%
    PlotDataFunc = @(x) cgg_getPlotDataForVariableToData(x,SignificanceValue,AreaName,PlotInformation);
    PlotValue_SingleFunc = @(x) squeeze(x.PlotValue_Single);
    NeighborhoodFunc = @(x) PlotValue_SingleFunc(PlotDataFunc(x));
    NeighborhoodSize = PlotInformation.NeighborhoodSize;
    OutputTable = cgg_addTableNeighborhoodColumn(InputTable,NeighborhoodSize,NeighborhoodFunc);
    % Name_NeighborhoodTable = sprintf("NeighborhoodSize_%d",NeighborhoodSize);
    % PlotValue_Single = OutputTable.(Name_NeighborhoodTable)';

    PlotData = cgg_getPlotDataForVariableToData(OutputTable,SignificanceValue,AreaName,PlotInformation);
else
PlotData = cgg_getPlotDataForVariableToData(InputTable,SignificanceValue,AreaName,PlotInformation);
end

%%

X_Name = 'Time (s)';

%%

Time_Start = PlotInformation.Time_Start;
Time_End = PlotInformation.Time_End;
SamplingRate = PlotInformation.SamplingRate;
DataWidth = PlotInformation.DataWidth;
WindowStride = PlotInformation.WindowStride;
DataWidth=DataWidth/SamplingRate;
WindowStride=WindowStride/SamplingRate;

PlotParameters = PlotInformation.PlotParameters;
% PlotValue_CoverageAmount = PlotInformation.PlotValue_CoverageAmount;

Time_Start=Time_Start + PlotParameters.Time_Offset;
Time_End=Time_End + PlotParameters.Time_Offset;

YLimits = PlotParameters.Limit_ChannelProportion;
XLimits = PlotParameters.Limit_Time;

Y_Tick_Size = PlotParameters.Tick_Size_ChannelProportion;
X_Tick_Size = PlotParameters.Tick_Size_Time;

Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);
X_Ticks = XLimits(1):X_Tick_Size:XLimits(2);

WantTitle = PlotParameters.WantTitle;

Y_TickDir = PlotParameters.TickDir_ChannelProportion;
X_TickDir = PlotParameters.TickDir_Time;

wantDecisionIndicators = PlotParameters.wantDecisionIndicators;
wantSubPlot = PlotParameters.wantSubPlot;
wantFeedbackIndicators = PlotParameters.wantFeedbackIndicators;
DecisionIndicatorLabelOrientation = ...
    PlotParameters.DecisionIndicatorLabelOrientation;
wantIndicatorNames = PlotParameters.wantIndicatorNames;
wantPaperSized = PlotParameters.wantPaperSized;

PlotVariable = PlotInformation.PlotVariable;
PlotType = PlotInformation.PlotType;

%%
% if isfield(PlotInformation,'WantBar')
%     WantBar = PlotInformation.WantBar;
% else
%     WantBar = false;
% end

%%

PlotTitle_Significance = PlotData.PlotTitle_Significance;
PlotTitle_Model = PlotData.PlotTitle_Model;
PlotNames = PlotData.PlotNames;
WantLegend = PlotData.WantLegend;
Y_Name = PlotData.Y_Name;
DataTransform = PlotData.DataTransform;
PlotValue = PlotData.PlotValue;
PlotError = PlotData.PlotError;
PlotValue_Bar = PlotData.PlotValue_Time;
NumPlots = PlotData.NumPlots;
HasMultiplePlots = PlotData.HasMultiplePlots;
PlotValue_Channel = PlotData.PlotValue_Channel;
% PlotValue_Time = PlotData.PlotValue_Time;

if WantNeighborhood
PlotValue_Channel = PlotData.PlotValue_Neighborhood;
end

if WantCoverage
PlotValue_Bar = PlotData.PlotValue_Coverage';
end

if isfield(PlotData,'Time_Start')
Time_Start = PlotData.Time_Start;
end
if isfield(PlotData,'Time_End')
Time_End = PlotData.Time_End;
end
if isfield(PlotData,'YLimits')
YLimits = PlotData.YLimits;
end
if isfield(PlotData,'Y_Ticks')
Y_Ticks = PlotData.Y_Ticks;
end

%%
for pidx = 1:NumPlots

if ~isempty(InFigure)
    
elseif wantPaperSized
InFigure=figure;
InFigure.Units="inches";
InFigure.Position=[0,0,3,3];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
clf(InFigure);
else
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';
clf(InFigure);
end

%%

if HasMultiplePlots
this_PlotValueIDX = [pidx,pidx+NumPlots];
this_PlotValue = PlotValue(:,:,this_PlotValueIDX);
this_PlotVariable = PlotInformation.CoefficientNames{pidx};
this_PlotValue_Channel = PlotValue_Channel(:,this_PlotValueIDX);
this_PlotValue_Bar = PlotValue_Bar(this_PlotValueIDX,:);
% this_PlotValue_Time = PlotValue_Time(:,:,this_PlotValueIDX);
else
this_PlotValue = PlotValue;
this_PlotVariable = PlotVariable;
this_PlotValue_Channel = PlotValue_Channel;
this_PlotValue_Bar = PlotValue_Bar;
% this_PlotValue_Time = PlotValue_Time;
end

%%

switch PlotType
    case 'Swarm'
        PlotNames_Cat = categorical(PlotNames);
        PlotNames_Cat = reordercats(PlotNames_Cat,PlotNames);
        PlotValue_X = repmat(PlotNames_Cat,size(this_PlotValue_Channel,2),1)';
        swarmchart(PlotValue_X',this_PlotValue_Channel','filled');
        if ~any(isnan(YLimits))
        ylim(YLimits);
        ylim([0,1]);
        end
    case 'Histogram'
        BinWidth = 0.025;
        LineWidth = 3;
        this_PlotValue = (this_PlotValue_Channel(1,:)-this_PlotValue_Channel(2,:))./(this_PlotValue_Channel(1,:)+this_PlotValue_Channel(2,:));
        histogram(this_PlotValue,"BinWidth",BinWidth,"Normalization","probability");
        xlim([-1,1]);
        ylim([0,0.2]);
        this_Mean = mean(this_PlotValue,"all","omitmissing");
        % disp(this_Mean);
        xline(this_Mean,'LineWidth',LineWidth);
    case 'Scatter'
        scatter(this_PlotValue_Channel(1,:),this_PlotValue_Channel(2,:));
        axis square
        xlim([0,1]);
        ylim([0,1]);
        xlabel(PlotNames{1});
        ylabel(PlotNames{2});
    case 'Bar'
        this_HistPlotValue = squeeze(num2cell(this_PlotValue_Bar,1));
        wantCI = true;
        ColorOrder = [0,0.4470,7410;0.8500,0.3250,0.0980];
        [b_Plot] = cgg_plotBarGraphWithError(this_HistPlotValue,PlotNames,'X_Name','','Y_Name',Y_Name,'PlotTitle',PlotTitle_Model,'YRange',YLimits,'wantCI',wantCI,'SignificanceValue',SignificanceValue,'ColorOrder',ColorOrder);
    case 'Line'
        [~,~,~] = cgg_plotTimeSeriesPlot(this_PlotValue,...
        'Time_Start',Time_Start,'Time_End',Time_End,...
        'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
        'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
        'PlotTitle',PlotTitle_Model,'PlotNames',PlotNames,...
        'wantDecisionIndicators',wantDecisionIndicators,...
        'wantSubPlot',wantSubPlot,...
        'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
        'wantFeedbackIndicators',wantFeedbackIndicators,...
        'wantIndicatorNames',wantIndicatorNames,...
        'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
        'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
        'DataTransform',DataTransform,'ErrorMetric',PlotError);
    
    if ~any(isnan(YLimits))
    ylim(YLimits);
    end
    if ~any(isnan(XLimits))
    xlim(XLimits);
    end
    if ~WantTitle
    title('');
    end
    if ~WantLegend
    legend('off');
    end

end

% if WantNeighborhood
%     PlotValue_Single = cell2mat(PlotValue_Single);
%     PlotNames_Cat = categorical(PlotNames);
%     PlotNames_Cat = reordercats(PlotNames_Cat,PlotNames);
%     PlotValue_X = repmat(PlotNames_Cat,size(PlotValue_Single,2),1)';
%     swarmchart(PlotValue_X',PlotValue_Single','filled');
%     % this_OutputTable = OutputTable(end,:);
%     % disp(this_OutputTable.AreaSessionName)
%     % disp(this_OutputTable.ChannelNumbers)
%     % disp(this_OutputTable.(Name_NeighborhoodTable){1})
%     % disp([min(PlotValue_Single,[],2),max(PlotValue_Single,[],2)]);
%     if ~any(isnan(YLimits))
%     ylim(YLimits);
%     ylim([0,1]);
%     end
% 
% if isfield(PlotInformation,'WantScatter')
%     WantScatter = PlotInformation.WantScatter;
%     WantCoverage = false;
% else
%     WantScatter = false;
% end
% 
%     % if WantCoverage
%     %     PlotValue_LargeCluster = cell(2,1);
%     % PlotValueCoverage = PlotValue_Single > PlotValue_CoverageAmount; 
%     % PlotValue_LargeCluster{1} = PlotValueCoverage(1,:);
%     % PlotValue_LargeCluster{2} = PlotValueCoverage(2,:);
%     % wantCI = true;
%     % ColorOrder = [0,0.4470,7410;0.8500,0.3250,0.0980];
%     % [b_Plot] = cgg_plotBarGraphWithError(PlotValue_LargeCluster,PlotNames,'X_Name','','Y_Name',Y_Name,'PlotTitle',PlotTitle_Model,'YRange',YLimits,'wantCI',wantCI,'SignificanceValue',SignificanceValue,'ColorOrder',ColorOrder);
%     % end
%     if WantScatter
%         scatter(PlotValue_Single(1,:),PlotValue_Single(2,:));
%         axis square
%         xlim([0,1]);
%         ylim([0,1]);
%         xlabel('Positive');
%         ylabel('Negative');
%     end
% 
% elseif WantBar
%     this_HistPlotValue = squeeze(num2cell(this_PlotValue_Bar,1));
% wantCI = true;
% ColorOrder = [0,0.4470,7410;0.8500,0.3250,0.0980];
% [b_Plot] = cgg_plotBarGraphWithError(this_HistPlotValue,PlotNames,'X_Name','','Y_Name',Y_Name,'PlotTitle',PlotTitle_Model,'YRange',YLimits,'wantCI',wantCI,'SignificanceValue',SignificanceValue,'ColorOrder',ColorOrder);
% 
% else
% 
% [~,~,~] = cgg_plotTimeSeriesPlot(this_PlotValue,...
%     'Time_Start',Time_Start,'Time_End',Time_End,...
%     'SamplingRate',SamplingRate,'DataWidth',DataWidth,...
%     'WindowStride',WindowStride,'X_Name',X_Name,'Y_Name',Y_Name,...
%     'PlotTitle',PlotTitle_Model,'PlotNames',PlotNames,...
%     'wantDecisionIndicators',wantDecisionIndicators,...
%     'wantSubPlot',wantSubPlot,...
%     'DecisionIndicatorLabelOrientation',DecisionIndicatorLabelOrientation,...
%     'wantFeedbackIndicators',wantFeedbackIndicators,...
%     'wantIndicatorNames',wantIndicatorNames,...
%     'Y_Ticks',Y_Ticks,'X_Ticks',X_Ticks,...
%     'Y_TickDir',Y_TickDir,'X_TickDir',X_TickDir,...
%     'DataTransform',DataTransform,'ErrorMetric',PlotError);
% 
% if ~any(isnan(YLimits))
% ylim(YLimits);
% end
% if ~any(isnan(XLimits))
% xlim(XLimits);
% end
% if ~WantTitle
% title('');
% end
% if ~WantLegend
% legend('off');
% end
% 
% end
%%

ExtraTerm = sprintf('%s%s',PlotInformation.ExtraTerm,AdditionalTerm);

if isstruct(Plotcfg)
    PlotSignificanceName = replace(PlotTitle_Significance,' ' ,'_');
    PlotName=sprintf('%s%s%s_%s',ExtraTerm,this_PlotVariable,PlotSignificanceName,AreaName);
    PlotPath=Plotcfg.path;
    PlotPathName=[PlotPath filesep PlotName];
    saveas(InFigure,[PlotPathName, '.fig']);
    exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');
    InFigure = [];
    close all
end

end % End pidx: Iteration through the plots
end

