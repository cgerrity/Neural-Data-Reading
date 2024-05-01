function [b_Plot] = cgg_plotBarGraphWithError(Values,ValueNames,varargin)
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
PlotTitle = CheckVararginPairs('PlotTitle', sprintf('%s over Time',Y_Name), varargin{:});
else
if ~(exist('PlotTitle','var'))
PlotTitle=sprintf('%s over Time',Y_Name);
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

%%
ValueNames_Cat = categorical(ValueNames);
ValueNames_Cat = reordercats(ValueNames_Cat,ValueNames);

%%
NumBars=length(Values);

Bar_Mean=NaN(1,NumBars);
Bar_STD=NaN(1,NumBars);
Bar_Count=NaN(1,NumBars);

ValueNames_Resized=cell(1,NumBars);

for bidx=1:NumBars
    this_Values=Values{bidx};
    Bar_Mean(bidx)=mean(this_Values,"omitnan");
    Bar_STD(bidx)=std(this_Values,[],"omitnan");
    Bar_Count(bidx)=sum(~isnan(this_Values));

    ValueNames_Resized{bidx}=['{\' sprintf(['fontsize{%d}' ValueNames{bidx} '}'],X_TickFontSize)];

end

Bar_STE=Bar_STD./sqrt(Bar_Count);

ts = tinv(0.975,Bar_Count-1);
BarCI = ts.*Bar_STE;

%%

b_Plot=bar(ValueNames_Cat,Bar_Mean);
b_Plot.FaceColor="flat";

if ~isempty(ColorOrder)
b_Plot.CData=ColorOrder;
end

xticklabels(ValueNames_Resized);

hold on

this_ErrorMetric=Bar_STE;
if wantCI
    this_ErrorMetric=BarCI;
end

b_Error = errorbar(1:NumBars,Bar_Mean,this_ErrorMetric,this_ErrorMetric,'LineWidth',ErrorLineWidth,'CapSize',ErrorCapSize);
b_Error.Color = [0 0 0];                            
b_Error.LineStyle = 'none';  
hold off

% xlabel(InVariableName,'FontSize',X_Name_Size);
% ylabel('Number of Trials','FontSize',Y_Name_Size);

% title('Count of Each Type','FontSize',Title_Size);



end

