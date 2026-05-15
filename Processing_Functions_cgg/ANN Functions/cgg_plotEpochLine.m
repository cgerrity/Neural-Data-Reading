function p_xline = cgg_plotEpochLine(Epoch,Iteration,varargin)
%CGG_PLOTEPOCHLINE Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
EpochFrequency = CheckVararginPairs('EpochFrequency', 25, varargin{:});
else
if ~(exist('EpochFrequency','var'))
EpochFrequency=25;
end
end

if isfunction
PlotAxes = CheckVararginPairs('PlotAxes', [], varargin{:});
else
if ~(exist('PlotAxes','var'))
PlotAxes=[];
end
end


%%
LineSpecification = ":";
LineAlpha = 0.5;

%%

if mod(Epoch,EpochFrequency)==0

    hold on;
    
    if ~isempty(PlotAxes)
        this_LegendString = PlotAxes.Legend.String;
p_xline = xline(PlotAxes,Iteration,LineSpecification,string(Epoch), ...
    'LabelHorizontalAlignment','center', ...
    'LabelVerticalAlignment','bottom', ...
    'Alpha',LineAlpha, ...
    'LabelOrientation','horizontal');
        PlotAxes.Legend.String = this_LegendString;
    else
        this_Legend = legend();
        this_LegendString = this_Legend.String;
p_xline = xline(Iteration,LineSpecification,string(Epoch), ...
    'LabelHorizontalAlignment','center', ...
    'LabelVerticalAlignment','bottom', ...
    'Alpha',LineAlpha, ...
    'LabelOrientation','horizontal');
        this_Legend.String = this_LegendString;
    end
hold off;

end

end