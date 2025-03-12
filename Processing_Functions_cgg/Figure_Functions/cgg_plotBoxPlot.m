function [b_Plot,InFigure] = cgg_plotBoxPlot(Data,DataNames,DataGroup,varargin)
%CGG_PLOTBOXPLOT Summary of this function goes here
%   Detailed explanation goes here
%% Varargin Options

isfunction=exist('varargin','var');

if isfunction
X_Name = CheckVararginPairs('X_Name', 'Time (s)', varargin{:});
else
if ~(exist('X_Name','var'))
X_Name='Time (s)';
end
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', 'Value', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='Value';
end
end

if isfunction
% PlotTitle = CheckVararginPairs('PlotTitle', sprintf('%s over Time',Y_Name), varargin{:});
PlotTitle = CheckVararginPairs('PlotTitle', '', varargin{:});
else
if ~(exist('PlotTitle','var'))
% PlotTitle=sprintf('%s over Time',Y_Name);
PlotTitle='';
end
end

if isfunction
YRange = CheckVararginPairs('YRange', '', varargin{:});
else
if ~(exist('YRange','var'))
YRange='';
end
end

if isfunction
X_TickFontSize = CheckVararginPairs('X_TickFontSize', 11, varargin{:});
else
if ~(exist('X_TickFontSize','var'))
X_TickFontSize=11;
end
end

if isfunction
ErrorLineWidth = CheckVararginPairs('ErrorLineWidth', 1, varargin{:});
else
if ~(exist('ErrorLineWidth','var'))
ErrorLineWidth=1;
end
end

% if isfunction
% ErrorCapSize = CheckVararginPairs('ErrorCapSize', 10, varargin{:});
% else
% if ~(exist('ErrorCapSize','var'))
% ErrorCapSize=10;
% end
% end

if isfunction
ColorOrder = CheckVararginPairs('ColorOrder', '', varargin{:});
else
if ~(exist('ColorOrder','var'))
ColorOrder='';
end
end

% if isfunction
% wantCI = CheckVararginPairs('wantCI', false, varargin{:});
% else
% if ~(exist('wantCI','var'))
% wantCI=false;
% end
% end

% if isfunction
% SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
% else
% if ~(exist('SignificanceValue','var'))
% SignificanceValue=0.05;
% end
% end

% if isfunction
% ErrorMetric = CheckVararginPairs('ErrorMetric', '', varargin{:});
% else
% if ~(exist('ErrorMetric','var'))
% ErrorMetric='';
% end
% end

% if isfunction
% IsGrouped = CheckVararginPairs('IsGrouped', false, varargin{:});
% else
% if ~(exist('IsGrouped','var'))
% IsGrouped=false;
% end
% end

% if isfunction
% GroupNames = CheckVararginPairs('GroupNames', {}, varargin{:});
% else
% if ~(exist('GroupNames','var'))
% GroupNames={};
% end
% end

if isfunction
WantLegend = CheckVararginPairs('WantLegend', false, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=false;
end
end

% if isfunction
% SignificanceTable = CheckVararginPairs('SignificanceTable', [], varargin{:});
% else
% if ~(exist('SignificanceTable','var'))
% SignificanceTable=[];
% end
% end

% if isfunction
% SignificanceFontSize = CheckVararginPairs('SignificanceFontSize', 6, varargin{:});
% else
% if ~(exist('SignificanceFontSize','var'))
% SignificanceFontSize=6;
% end
% end

% if isfunction
% WantBarNames = CheckVararginPairs('WantBarNames', true, varargin{:});
% else
% if ~(exist('WantBarNames','var'))
% WantBarNames=true;
% end
% end

if isfunction
WantHorizontal = CheckVararginPairs('WantHorizontal', false, varargin{:});
else
if ~(exist('WantHorizontal','var'))
WantHorizontal=false;
end
end

if isfunction
Legend_Size = CheckVararginPairs('Legend_Size', [], varargin{:});
else
if ~(exist('Legend_Size','var'))
Legend_Size=[];
end
end

if isfunction
LabelAngle = CheckVararginPairs('LabelAngle', 0, varargin{:});
else
if ~(exist('LabelAngle','var'))
LabelAngle=0;
end
end

if isfunction
InFigure = CheckVararginPairs('InFigure', [], varargin{:});
else
if ~(exist('InFigure','var'))
InFigure=[];
end
end

if isfunction
wantPaperSized = CheckVararginPairs('wantPaperSized', false, varargin{:});
else
if ~(exist('wantPaperSized','var'))
wantPaperSized=false;
end
end

if isfunction
BoxWidth = CheckVararginPairs('BoxWidth', [], varargin{:});
else
if ~(exist('BoxWidth','var'))
BoxWidth=[];
end
end

% if isfunction
% WantScatter = CheckVararginPairs('WantScatter', false, varargin{:});
% else
% if ~(exist('WantScatter','var'))
% WantScatter=false;
% end
% end

if isfunction
ConfidenceRange = CheckVararginPairs('ConfidenceRange', '', varargin{:});
else
if ~(exist('ConfidenceRange','var'))
ConfidenceRange='';
end
end

if isfunction
ConfidenceColor = CheckVararginPairs('ConfidenceColor', [200,200,200]/255, varargin{:});
else
if ~(exist('ConfidenceColor','var'))
ConfidenceColor=[200,200,200]/255;
end
end

if isfunction
ConfidenceColor_FaceAlpha = CheckVararginPairs('ConfidenceColor_FaceAlpha', 1, varargin{:});
else
if ~(exist('ConfidenceColor_FaceAlpha','var'))
ConfidenceColor_FaceAlpha=1;
end
end

if isfunction
ConfidenceColor_EdgeAlpha = CheckVararginPairs('ConfidenceColor_EdgeAlpha', 0, varargin{:});
else
if ~(exist('ConfidenceColor_EdgeAlpha','var'))
ConfidenceColor_EdgeAlpha=0;
end
end

% if isfunction
% MarkerSize = CheckVararginPairs('MarkerSize', 12, varargin{:});
% else
% if ~(exist('MarkerSize','var'))
% MarkerSize=12;
% end
% end

if isfunction
DataNames_Order = CheckVararginPairs('DataNames_Order', [], varargin{:});
else
if ~(exist('DataNames_Order','var'))
DataNames_Order=[];
end
end

if isfunction
DataGroup_Order = CheckVararginPairs('DataGroup_Order', [], varargin{:});
else
if ~(exist('DataGroup_Order','var'))
DataGroup_Order=[];
end
end
%%

%%

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
% DataNames = repmat({'Absolute Prediction Error';'WM Weight';'Choice Probability'},[100,1]);
% DataGroup = repmat({'ACC';'CD'},[150,1]);
% 
% DataNames_Order = {'Choice Probability','WM Weight','Absolute Prediction Error'};
% DataGroup_Order = {'ACC','CD'};

%%
if ~isempty(DataNames_Order)
DataNames = categorical(DataNames, ...
    DataNames_Order,'Ordinal',true);
else
DataNames = categorical(DataNames);
end

if ~isempty(DataGroup_Order)
DataGroup = categorical(DataGroup, ...
    DataGroup_Order,'Ordinal',true);
else
DataGroup = categorical(DataGroup);
end

% DataNames = categorical(DataNames);
% DataGroup = categorical(DataGroup);

%%

%%

NumGroups = length(unique(DataGroup));
NumNames = length(unique(DataNames));

%%

b_Plot=boxchart(DataNames,Data,'GroupByColor',DataGroup,'Notch','on');


DataNames_Resized = b_Plot(1).Parent.XTickLabel;

for didx = 1:length(DataNames_Resized)
DataNames_Resized{didx}=['{\' sprintf(['fontsize{%d}' DataNames_Resized{didx} '}'],X_TickFontSize)];
end

%% Change Box Width
this_BoxWidth = 0.8;
if ~isempty(BoxWidth)
this_BoxWidth = (0.95/BoxWidth)*(NumNames);
end

for bidx = 1:NumGroups
    b_Plot(bidx).BoxWidth=this_BoxWidth;
end
%% Remove Whiskers
for bidx = 1:NumGroups
    b_Plot(bidx).WhiskerLineStyle = 'none';
end
%% Make Horizontal

if WantHorizontal
    for bidx = 1:NumGroups
        b_Plot(bidx).Orientation='horizontal';
    end
    yticklabels(DataNames_Resized);
    ytickangle(LabelAngle);
else
    xticklabels(DataNames_Resized);
    xtickangle(LabelAngle);
end

%% Change Colors
if ~isempty(ColorOrder)

    for bidx = 1:NumGroups
    b_Plot(bidx).BoxFaceColor=ColorOrder(bidx,:);
    b_Plot(bidx).MarkerColor=ColorOrder(bidx,:);
    end
end

%% Label Axes

if ~isempty(Y_Name)
ylabel(Y_Name);
end

if ~isempty(X_Name)
xlabel(X_Name);
end

if ~isempty(PlotTitle)
title(PlotTitle);
end

%% Adjust Range

if ~isempty(YRange)

if WantHorizontal
    xlim(YRange);
else
    ylim(YRange);
end
end

%% Adjust Line Width


for bidx = 1:NumGroups
    b_Plot(bidx).LineWidth=ErrorLineWidth;
end

%% Confidence Range

if ~isempty(ConfidenceRange)

    hold on
    Bar_Difference = 100;

    fig = gca;
    YLimits_Bar = fig.YLim;
    ylim(YLimits_Bar);
    
    drawnow;

    Bar_Top = NaN(NumGroups,NumNames);
    for gidx = 1:NumGroups
    Bar_Top(gidx,:) = (1:NumNames) + (1/(NumGroups+1))*(gidx)-0.5;
    end
    UpperValue_Confidence = max(Bar_Top(:))+Bar_Difference;
    LowerValue_Confidence = min(Bar_Top(:))-Bar_Difference;
    if WantHorizontal
Patch_Y=[LowerValue_Confidence;Bar_Top(:);UpperValue_Confidence;UpperValue_Confidence;flipud(Bar_Top(:));LowerValue_Confidence];
Confidence_Negative = cell2mat(cellfun(@(x) x(:,1),ConfidenceRange,'UniformOutput',false));
Confidence_Positive = cell2mat(cellfun(@(x) x(:,2),ConfidenceRange,'UniformOutput',false));
Patch_X=[Confidence_Negative(1);Confidence_Negative;Confidence_Negative(end);Confidence_Positive(end);flipud(Confidence_Positive);Confidence_Positive(end)];
    else
Confidence_Negative = cell2mat(cellfun(@(x) x(:,1),ConfidenceRange,'UniformOutput',false));
Confidence_Positive = cell2mat(cellfun(@(x) x(:,2),ConfidenceRange,'UniformOutput',false));
Patch_Y=[Confidence_Negative(1);Confidence_Negative;Confidence_Negative(end);Confidence_Positive(end);flipud(Confidence_Positive);Confidence_Positive(end)];
Patch_X=[LowerValue_Confidence;Bar_Top(:);UpperValue_Confidence;UpperValue_Confidence;flipud(Bar_Top(:));LowerValue_Confidence];
    end

    % disp(Patch_X);
    % disp(Patch_Y);
    p_Confidence=patch(Patch_X,Patch_Y,'r');
    p_Confidence.FaceColor=ConfidenceColor;
    p_Confidence.EdgeColor=ConfidenceColor;
    p_Confidence.FaceAlpha=ConfidenceColor_FaceAlpha;
    p_Confidence.EdgeAlpha=ConfidenceColor_EdgeAlpha;
    set(gca,'children',flipud(get(gca,'children')))

    hold off
end

%% Adjust Legend

if WantLegend
    if isempty(Legend_Size)
        legend(b_Plot,'Location','best');
    else
        legend(b_Plot,'Location','best','FontSize',Legend_Size);
    end
end

end

