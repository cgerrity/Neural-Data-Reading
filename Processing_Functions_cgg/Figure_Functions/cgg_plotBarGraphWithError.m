function [b_Plot,b_Error,InFigure] = cgg_plotBarGraphWithError(Values,ValueNames,varargin)
%CGG_PLOTBARGRAPH Summary of this function goes here
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

if isfunction
ErrorCapSize = CheckVararginPairs('ErrorCapSize', 10, varargin{:});
else
if ~(exist('ErrorCapSize','var'))
ErrorCapSize=10;
end
end

if isfunction
ColorOrder = CheckVararginPairs('ColorOrder', '', varargin{:});
else
if ~(exist('ColorOrder','var'))
ColorOrder='';
end
end

if isfunction
wantCI = CheckVararginPairs('wantCI', false, varargin{:});
else
if ~(exist('wantCI','var'))
wantCI=false;
end
end

if isfunction
wantSTD = CheckVararginPairs('wantSTD', false, varargin{:});
else
if ~(exist('wantSTD','var'))
wantSTD=false;
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

if isfunction
ErrorMetric = CheckVararginPairs('ErrorMetric', '', varargin{:});
else
if ~(exist('ErrorMetric','var'))
ErrorMetric='';
end
end

if isfunction
IsGrouped = CheckVararginPairs('IsGrouped', false, varargin{:});
else
if ~(exist('IsGrouped','var'))
IsGrouped=false;
end
end

if isfunction
GroupNames = CheckVararginPairs('GroupNames', {}, varargin{:});
else
if ~(exist('GroupNames','var'))
GroupNames={};
end
end

if isfunction
WantLegend = CheckVararginPairs('WantLegend', false, varargin{:});
else
if ~(exist('WantLegend','var'))
WantLegend=false;
end
end

if isfunction
SignificanceTable = CheckVararginPairs('SignificanceTable', [], varargin{:});
else
if ~(exist('SignificanceTable','var'))
SignificanceTable=[];
end
end

if isfunction
SignificanceFontSize = CheckVararginPairs('SignificanceFontSize', 6, varargin{:});
else
if ~(exist('SignificanceFontSize','var'))
SignificanceFontSize=6;
end
end

if isfunction
WantBarNames = CheckVararginPairs('WantBarNames', true, varargin{:});
else
if ~(exist('WantBarNames','var'))
WantBarNames=true;
end
end

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
BarWidth = CheckVararginPairs('BarWidth', [], varargin{:});
else
if ~(exist('BarWidth','var'))
BarWidth=[];
end
end

if isfunction
WantScatter = CheckVararginPairs('WantScatter', false, varargin{:});
else
if ~(exist('WantScatter','var'))
WantScatter=false;
end
end

% --- New Customizations for NeurIPS Scatter ---
if isfunction
WantNeurIPSScatter = CheckVararginPairs('WantNeurIPSScatter', false, varargin{:});
else
if ~(exist('WantNeurIPSScatter','var'))
WantNeurIPSScatter=false;
end
end

if isfunction
ScatterJitter = CheckVararginPairs('ScatterJitter', 0.15, varargin{:});
else
if ~(exist('ScatterJitter','var'))
ScatterJitter=0.15;
end
end

if isfunction
ScatterAlpha = CheckVararginPairs('ScatterAlpha', 0.6, varargin{:});
else
if ~(exist('ScatterAlpha','var'))
ScatterAlpha=0.6;
end
end

if isfunction
MeanLineWidth = CheckVararginPairs('MeanLineWidth', 2, varargin{:});
else
if ~(exist('MeanLineWidth','var'))
MeanLineWidth=2;
end
end

if isfunction
WantErrorBars = CheckVararginPairs('WantErrorBars', true, varargin{:});
else
if ~(exist('WantErrorBars','var'))
WantErrorBars=true;
end
end
% ----------------------------------------------

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

if isfunction
MarkerSize = CheckVararginPairs('MarkerSize', 12, varargin{:});
else
if ~(exist('MarkerSize','var'))
MarkerSize=12;
end
end

if isfunction
WantReducedX_Labels = CheckVararginPairs('WantReducedX_Labels', false, varargin{:});
else
if ~(exist('WantReducedX_Labels','var'))
WantReducedX_Labels=false;
end
end

% --- Default NeurIPS Color Palette (Okabe-Ito) ---
if WantNeurIPSScatter && isempty(ColorOrder)
    % Accessible, professional colorblind-friendly palette
    ColorOrder = [
        0.000, 0.447, 0.698; % Blue
        0.835, 0.369, 0.000; % Vermillion
        0.000, 0.620, 0.451; % Bluish Green
        0.902, 0.624, 0.000; % Orange
        0.337, 0.706, 0.914; % Sky Blue
        0.800, 0.475, 0.655; % Reddish Purple
        0.941, 0.894, 0.259; % Yellow
        0.300, 0.300, 0.300  % Dark Gray
    ];
end
% -------------------------------------------------

%%
ValueNames_Cat = categorical(ValueNames);
ValueNames_Cat = reordercats(ValueNames_Cat,ValueNames);

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

if IsGrouped
    % NumGroups = length(Values{1});
    NumGroups = length(Values);
else
    NumGroups = 1;
end


% NumBars=length(Values);
if IsGrouped
NumBars=length(Values{1});
else
NumBars=length(Values);
end

% Bar_Mean=NaN(NumBars,NumGroups);
% Bar_STD=NaN(NumBars,NumGroups);
% Bar_Count=NaN(NumBars,NumGroups);
% Bar_ErrorMetric=NaN(NumBars,NumGroups);

Bar_Mean=NaN(NumGroups,NumBars);
Bar_STD=NaN(NumGroups,NumBars);
Bar_Count=NaN(NumGroups,NumBars);
Bar_ErrorMetric=NaN(NumGroups,NumBars);

% ValueNames_Resized=cell(1,NumBars);
ValueNames_Resized=cell(1,NumGroups);

% for bidx=1:NumBars
%     this_Values=Values{bidx};
%     Bar_Mean(bidx)=mean(this_Values,"omitnan");
%     Bar_STD(bidx)=std(this_Values,[],"omitnan");
%     Bar_Count(bidx)=sum(~isnan(this_Values));
% 
%     if IsGrouped
%         Bar_Mean(bidx,:) = this_Values;
%         if ~isempty(ErrorMetric)
%         Bar_ErrorMetric(bidx,:) = ErrorMetric{bidx};
%         end
%     end
% 
%     ValueNames_Resized{bidx}=['{\' sprintf(['fontsize{%d}' ValueNames{bidx} '}'],X_TickFontSize)];
% 
% end

% for gidx=1:NumGroups
for vidx=1:length(Values)
    this_Values=Values{vidx};
    % Bar_Mean(gidx)=mean(this_Values,"omitnan");
    % Bar_STD(gidx)=std(this_Values,[],"omitnan");
    % Bar_Count(gidx)=sum(~isnan(this_Values));

    if IsGrouped
        Bar_Mean(vidx,:) = this_Values;
        if ~isempty(ErrorMetric)
        Bar_ErrorMetric(vidx,:) = ErrorMetric{vidx};
        end
    else
        Bar_Mean(vidx)=mean(this_Values,"omitnan");
        Bar_STD(vidx)=std(this_Values,[],"omitnan");
        Bar_Count(vidx)=sum(~isnan(this_Values));
    end

    ValueNames_Resized{vidx}=['{\' sprintf(['fontsize{%d}' ValueNames{vidx} '}'],X_TickFontSize)];

end

%%
if WantReducedX_Labels
NumValues = length(ValueNames_Resized);
    for vidx = 1:NumValues
        if vidx ~=1 && vidx ~=round(NumValues/2) && vidx ~= NumValues
            ValueNames_Resized{vidx} = '';
        end
    end
end

%%

Bar_STE=Bar_STD./sqrt(Bar_Count);
Bar_STE(Bar_Count==1) = NaN;

ts = tinv(1-SignificanceValue/2,Bar_Count-1);
BarCI = ts.*Bar_STE;

%%
this_BarWidth = 0.8;
if ~isempty(BarWidth)
this_BarWidth = (0.95/BarWidth)*(NumBars);
end
%%

b_Plot=bar(ValueNames_Cat,Bar_Mean,this_BarWidth);
Num_b_Plot = length(b_Plot);
% if NumBars == 1
%     Num_b_Plot = NumBars;
% end
for bidx = 1:Num_b_Plot
b_Plot(bidx).FaceColor="flat";
if WantScatter || WantNeurIPSScatter
b_Plot(bidx).FaceColor="none";
b_Plot(bidx).LineStyle="none";
end
if WantNeurIPSScatter
b_Plot(bidx).EdgeColor="none"; % Ensure no bar outlines are drawn
end
b_Plot(bidx).Horizontal=WantHorizontal;
end

if ~isempty(ColorOrder)
    numColors = size(ColorOrder, 1);
    if IsGrouped
        for bidx = 1:Num_b_Plot
        cIdx = mod(bidx-1, numColors) + 1;
        b_Plot(bidx).CData=repmat(ColorOrder(cIdx,:),[NumGroups,1]);
        end
    else
        for bidx = 1:NumBars
        cIdx = mod(bidx-1, numColors) + 1;
        b_Plot.CData(bidx,:)=repmat(ColorOrder(cIdx,:),[NumGroups,1]);
        end
    end
end

if ~isempty(GroupNames)
for bidx = 1:Num_b_Plot
b_Plot(bidx).DisplayName=GroupNames{bidx};
end
end

if WantHorizontal
    yticklabels(ValueNames_Resized);
    ytickangle(LabelAngle);
else
    xticklabels(ValueNames_Resized);
    xtickangle(LabelAngle);
end

if ~WantBarNames
if WantHorizontal
    yticklabels([]);
else
    xticklabels([]);
end
end

hold on

this_ErrorMetric=Bar_STE;
if wantCI
    this_ErrorMetric=BarCI;
elseif wantSTD
    this_ErrorMetric=Bar_STD;
end

if ~isempty(ErrorMetric)
this_ErrorMetric = Bar_ErrorMetric;
end

if IsGrouped
Bar_Top = NaN(Num_b_Plot, NumGroups);
for bidx = 1:Num_b_Plot
    Bar_Top(bidx,:) = b_Plot(bidx).XEndPoints;
end
else
Bar_Top = NaN(NumBars, NumGroups);
for bidx = 1:NumBars
    Bar_Top(bidx,:) = b_Plot.XEndPoints(bidx);
end
end

% if NumBars > 1
% Bar_Difference = abs(mean(Bar_Top(:,1)-Bar_Top(:,2)));
% disp(Bar_Top)
% else
% Bar_Difference = abs(mean(Bar_Top(1)-Bar_Top(2)));
% end

% --- SCATTER PLOTTING LOGIC (NeurIPS Style) ---
if WantNeurIPSScatter && ~IsGrouped
    % Generate fallback colormap if none provided
    fallbackColors = lines(length(Values));
    
    for vidx = 1:length(Values)
        this_Values = Values{vidx};
        
        % Remove NaNs for plotting
        this_Values(isnan(this_Values)) = [];
        
        % Grab position of the current bar
        X_center = Bar_Top(vidx);
        
        % Determine color
        if ~isempty(ColorOrder)
            pColor = ColorOrder(mod(vidx-1, size(ColorOrder,1))+1, :);
        else
            pColor = fallbackColors(vidx, :); 
        end
        
        % Jitter values horizontally (or vertically if WantHorizontal)
        X_jittered = X_center + (rand(size(this_Values)) - 0.5) * ScatterJitter;
        
        if WantHorizontal
            % Scatter Data points
            scatter(this_Values, X_jittered, MarkerSize*2, pColor, 'filled', ...
                'MarkerFaceAlpha', ScatterAlpha, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
            % Mean Line (solid black bar representing the mean over the jitter width)
            plot([Bar_Mean(vidx) Bar_Mean(vidx)], [X_center - ScatterJitter, X_center + ScatterJitter], ...
                'Color', [0.15 0.15 0.15], 'LineWidth', MeanLineWidth, 'HandleVisibility', 'off');
        else
            % Scatter Data points
            scatter(X_jittered, this_Values, MarkerSize*2, pColor, 'filled', ...
                'MarkerFaceAlpha', ScatterAlpha, 'MarkerEdgeColor', 'none', 'HandleVisibility', 'off');
            % Mean Line (solid black bar representing the mean over the jitter width)
            plot([X_center - ScatterJitter, X_center + ScatterJitter], [Bar_Mean(vidx) Bar_Mean(vidx)], ...
                'Color', [0.15 0.15 0.15], 'LineWidth', MeanLineWidth, 'HandleVisibility', 'off');
        end
    end
end
% ----------------------------------------------


Bar_Difference = 1;

aaa = gca;
YLimits_Bar = aaa.YLim;
ylim(YLimits_Bar);

drawnow;

UpperValue_Confidence = max(Bar_Top(:))+Bar_Difference;
LowerValue_Confidence = min(Bar_Top(:))-Bar_Difference;

if WantHorizontal
ErrorBar_X = Bar_Mean;
ErrorBar_Y = Bar_Top';
ErrorBar_Orientation = "horizontal";
if ~isempty(ConfidenceRange)
Patch_Y=[LowerValue_Confidence;Bar_Top(:);UpperValue_Confidence;UpperValue_Confidence;flipud(Bar_Top(:));LowerValue_Confidence];
Confidence_Negative = cell2mat(cellfun(@(x) x(:,1),ConfidenceRange,'UniformOutput',false));
Confidence_Positive = cell2mat(cellfun(@(x) x(:,2),ConfidenceRange,'UniformOutput',false));
Patch_X=[Confidence_Negative(1);Confidence_Negative;Confidence_Negative(end);Confidence_Positive(end);flipud(Confidence_Positive);Confidence_Positive(end)];
end
else
ErrorBar_X = Bar_Top';
ErrorBar_Y = Bar_Mean;
ErrorBar_Orientation = "vertical";
if ~isempty(ConfidenceRange)
Confidence_Negative = cell2mat(cellfun(@(x) x(:,1),ConfidenceRange,'UniformOutput',false));
Confidence_Positive = cell2mat(cellfun(@(x) x(:,2),ConfidenceRange,'UniformOutput',false));
Patch_Y=[Confidence_Negative(1);Confidence_Negative;Confidence_Negative(end);Confidence_Positive(end);flipud(Confidence_Positive);Confidence_Positive(end)];
Patch_X=[LowerValue_Confidence;Bar_Top(:);UpperValue_Confidence;UpperValue_Confidence;flipud(Bar_Top(:));LowerValue_Confidence];
end
end

b_Error = [];
if WantErrorBars
    b_Error = errorbar(ErrorBar_X,ErrorBar_Y,this_ErrorMetric,this_ErrorMetric,ErrorBar_Orientation,'LineWidth',ErrorLineWidth,'CapSize',ErrorCapSize);
    
    for bidx = 1:Num_b_Plot
    b_Error(bidx).Color=[0 0 0];
    b_Error(bidx).LineStyle='none';
    
    if WantNeurIPSScatter
        % Clean NeurIPS look: Don't put a marker point on the error bar 
        % since we already plotted a beautiful mean line and scatter.
        b_Error(bidx).Marker='none';
    elseif WantScatter
        b_Error(bidx).Marker='.';
        b_Error(bidx).MarkerSize=MarkerSize;
        if ~isempty(ColorOrder)
            cIdx = mod(bidx-1, size(ColorOrder, 1)) + 1;
            b_Error(bidx).MarkerEdgeColor=ColorOrder(cIdx,:);
            b_Error(bidx).MarkerFaceColor=ColorOrder(cIdx,:);
        end
    end
    end
end

if ~isempty(ConfidenceRange)
% disp(Patch_X);
% disp(Patch_Y);
p_Confidence=patch(Patch_X,Patch_Y,'r');
p_Confidence.FaceColor=ConfidenceColor;
p_Confidence.EdgeColor=ConfidenceColor;
p_Confidence.FaceAlpha=ConfidenceColor_FaceAlpha;
p_Confidence.EdgeAlpha=ConfidenceColor_EdgeAlpha;
set(gca,'children',flipud(get(gca,'children')))
end

hold off

if ~isempty(GroupNames) && WantScatter && WantErrorBars
for bidx = 1:Num_b_Plot
b_Error(bidx).DisplayName=GroupNames{bidx};
end
end

if ~isempty(SignificanceTable)
cgg_plotSignificanceBar(b_Plot,b_Error,SignificanceTable,'SignificanceFontSize',SignificanceFontSize,'WantHorizontal',WantHorizontal,'YRange',YRange);
end

if ~isempty(Y_Name)
ylabel(Y_Name);
end

if ~isempty(X_Name)
xlabel(X_Name);
end

if ~isempty(PlotTitle)
title(PlotTitle);
end

if ~isempty(YRange)
if WantHorizontal
    xlim(YRange);
else
    ylim(YRange);
end
end

if ~isempty(GroupNames) && WantLegend
    if (WantScatter || WantNeurIPSScatter) && WantErrorBars
        legend_target = b_Error;
    else
        legend_target = b_Plot;
    end
    
    if isempty(Legend_Size)
        legend(legend_target,'Location','best');
    else
        legend(legend_target,'Location','best','FontSize',Legend_Size);
    end
end

% xlabel(InVariableName,'FontSize',X_Name_Size);
% ylabel('Number of Trials','FontSize',Y_Name_Size);
% title('Count of Each Type','FontSize',Title_Size);

% --- NEURIPS PUBLICATION AESTHETICS ---
% This block ensures the plot has the clean, academic look favored by ML venues
if WantNeurIPSScatter
    set(gca, 'Box', 'off', ...                 % Remove outer box
             'TickDir', 'out', ...             % Ticks point outward
             'TickLength', [.015 .015], ...    % Slightly smaller ticks
             'LineWidth', 1.2, ...             % Thicker, clearer axes
             'XMinorTick', 'off', ...
             'YMinorTick', 'off', ...
             'YGrid', 'on', ...                % Turn on horizontal grid lines for readability
             'GridColor', [0.85 0.85 0.85], ...% Subtle, light grey grid lines
             'GridAlpha', 0.6);
    if WantHorizontal
        set(gca, 'YGrid', 'off', 'XGrid', 'on');
    end
end
% --------------------------------------

end

