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

Bar_STE=Bar_STD./sqrt(Bar_Count);

ts = tinv(1-SignificanceValue/2,Bar_Count-1);
BarCI = ts.*Bar_STE;

%%

b_Plot=bar(ValueNames_Cat,Bar_Mean);
Num_b_Plot = length(b_Plot);
% if NumBars == 1
%     Num_b_Plot = NumBars;
% end
for bidx = 1:Num_b_Plot
b_Plot(bidx).FaceColor="flat";
b_Plot(bidx).Horizontal=WantHorizontal;
end

if ~isempty(ColorOrder)
    if IsGrouped
        for bidx = 1:Num_b_Plot
        b_Plot(bidx).CData=repmat(ColorOrder(bidx,:),[NumGroups,1]);
        end
    else
        for bidx = 1:NumBars
        b_Plot.CData(bidx,:)=repmat(ColorOrder(bidx,:),[NumGroups,1]);
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

if WantHorizontal
ErrorBar_X = Bar_Mean;
ErrorBar_Y = Bar_Top';
ErrorBar_Orientation = "horizontal";
else
ErrorBar_X = Bar_Top';
ErrorBar_Y = Bar_Mean;
ErrorBar_Orientation = "vertical";
end

b_Error = errorbar(ErrorBar_X,ErrorBar_Y,this_ErrorMetric,this_ErrorMetric,ErrorBar_Orientation,'LineWidth',ErrorLineWidth,'CapSize',ErrorCapSize);

for bidx = 1:Num_b_Plot
b_Error(bidx).Color=[0 0 0];
b_Error(bidx).LineStyle='none';
end
hold off

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
    if isempty(Legend_Size)
        legend(b_Plot,'Location','best');
    else
        legend(b_Plot,'Location','best','FontSize',Legend_Size);
    end
end

% xlabel(InVariableName,'FontSize',X_Name_Size);
% ylabel('Number of Trials','FontSize',Y_Name_Size);

% title('Count of Each Type','FontSize',Title_Size);

end

