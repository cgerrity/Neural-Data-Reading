function [ClassPlots,AggregateBar] = cgg_plotSingleClassificationProbability(PlotData,Time,InTiled_Plot,SubTiled_Plot,InTiledIDX,SubTiledIDX,InSpan,LastDim,TrueFeature,varargin)
%CGG_PLOTCLASSIFICATIONPROBABILITIES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantAggregateBar = CheckVararginPairs('WantAggregateBar', false, varargin{:});
else
if ~(exist('WantAggregateBar','var'))
WantAggregateBar=false;
end
end

%%

Line_Width_ProgressMonitor = 1;
Line_Width_True = 3;

%% Classification Proability

if istable(PlotData)
    NumClasses = height(PlotData);
elseif iscell(PlotData)
    NumClasses = length(PlotData);
else
    NumClasses = size(PlotData,2);
end

nexttile(InTiled_Plot,InTiledIDX,InSpan);
SubTiled_Plot.Layout.Tile = InTiledIDX;

nexttile(SubTiled_Plot,SubTiledIDX,[1,1]);

ClassPlots = cell(1,NumClasses);

%%

this_Data = PlotData{:,"Data"};
Name = PlotData{:,"Name"};
MaximumData = max(cellfun(@max, this_Data,'UniformOutput',true));

if MaximumData > 0.5
    UpperLimit = 1;
elseif MaximumData > 0.25
    UpperLimit = 0.5;
elseif MaximumData > 0.1
    UpperLimit = 0.25;
elseif MaximumData > 0.01
    UpperLimit = 0.1;
elseif MaximumData > 0.001
    UpperLimit = 0.01;
else
    UpperLimit = 1;
end

% if iscell(this_Data)
%     this_Data = this_Data{1};
% end
% if iscell(this_Name)
%     this_Name = this_Name{1};
% end

if iscell(TrueFeature)
TrueFeature = TrueFeature{1};
end
if isnumeric(TrueFeature)
TrueFeature = num2str(TrueFeature);
end

%%

this_Name = Name(1);
if iscell(this_Name)
this_Name = this_Name{1};
end
if isnumeric(this_Name)
this_Name = num2str(this_Name);
end

this_Line_Width = Line_Width_ProgressMonitor;
% disp({this_Name,TrueFeature,isequal(this_Name,TrueFeature)})
if isequal(this_Name,TrueFeature)
this_Line_Width = Line_Width_True;
end

p_ClassTraining=plot(Time,this_Data{1},'DisplayName',this_Name,'LineWidth',this_Line_Width);

ClassPlots{1} = p_ClassTraining;

% Axes_ClassPlots = gca;

hold on
for cidx = 2:NumClasses

this_Name = Name(cidx);
if iscell(this_Name)
this_Name = this_Name{1};
end
if isnumeric(this_Name)
this_Name = num2str(this_Name);
end

this_PlotData = this_Data{cidx};

this_Line_Width = Line_Width_ProgressMonitor;
% disp({this_Name,TrueFeature,isequal(this_Name,TrueFeature)})
if isequal(this_Name,TrueFeature)
this_Line_Width = Line_Width_True;
end

p_ClassTraining=plot(Time,this_PlotData,'DisplayName',this_Name,'LineWidth',this_Line_Width);

ClassPlots{cidx} = p_ClassTraining;

end

hold off

set(gca,'YTick',[]);
% set(Axes_ClassPlots,'YTick',[]);

% if ~(LastDim && cidx == NumClasses)
if ~(LastDim)
set(gca,'XTick',[]);
% set(Axes_ClassPlots,'XTick',[]);
end

ylim([0,UpperLimit]);
xlim([min(Time),max(Time)]);

this_legend = legend;
this_legend.Location = "northwest";

MainAxis = gca;

%% Aggregate Bar in top right
AggregateBar = [];
if WantAggregateBar
    axMain = MainAxis;
    this_fig = ancestor(axMain, 'figure');
    
    % 0. Identify and remove any previous aggregate bars for THIS specific axes
    existing_insets = findobj(this_fig, 'Type', 'axes', 'Tag', 'AggregateBarInset');
    for i = 1:length(existing_insets)
        if isequal(existing_insets(i).UserData, axMain)
            delete(existing_insets(i));
        end
    end

    % 1. Calculate the aggregated confidence for each class
    aggConf = zeros(1, NumClasses);
    catNames = strings(1, NumClasses);
    barColors = zeros(NumClasses, 3);
    
    for cidx = 1:NumClasses
        % Extract name safely for categorical axis labels
        tmp_Name = Name(cidx);
        if iscell(tmp_Name), tmp_Name = tmp_Name{1}; end
        if isnumeric(tmp_Name), tmp_Name = num2str(tmp_Name); end
        catNames(cidx) = string(tmp_Name);
        
        % Aggregate by taking the mean across the time series
        % Using (:) ensures it works regardless of vector orientation
        aggConf(cidx) = sum(this_Data{cidx}(:), 'omitnan');
        
        % Extract the corresponding line color
        barColors(cidx, :) = ClassPlots{cidx}.Color;
    end
    
    % 2. Normalize so the sum equals 1
    totalConf = sum(aggConf);
    if totalConf > 1
        aggConf = aggConf / totalConf;
    end
    
    % 3. Create categorical array for x-axis, locking in the order
    this_cats = categorical(catNames, catNames);

    % 4. Add the inset bar chart (handling nested TiledChartLayouts safely)
    % Force MATLAB to resolve the tiled layout geometry before reading positions
    drawnow;

    % Start with the main axes position (normalized, relative to its immediate parent)
    axMain.Units = 'normalized';
    this_mainPos = axMain.Position; 
    currObj = axMain.Parent;

    % Traverse up the layout hierarchy to compute absolute normalized coordinates 
    % relative to the figure. This bypasses getpixelposition bugs in nested layouts.
    while ~isempty(currObj) && ~isequal(currObj, this_fig)
        % Retrieve parent position
    
        if isprop(currObj, 'OuterPosition')
            currObj.Units = "normalized";
            parentPos = currObj.OuterPosition;
        elseif isprop(currObj, 'Position')
            currObj.Units = "normalized";
            parentPos = currObj.Position;
        elseif isprop(currObj, 'InnerPosition')
            currObj.Units = "normalized";
            parentPos = currObj.InnerPosition;
        else
            parentPos = [0, 0, 1, 1];
        end
        
        % Convert this_mainPos into the parent's coordinate space
        this_mainPos(1) = parentPos(1) + this_mainPos(1) * parentPos(3);
        this_mainPos(2) = parentPos(2) + this_mainPos(2) * parentPos(4);
        this_mainPos(3) = this_mainPos(3) * parentPos(3);
        this_mainPos(4) = this_mainPos(4) * parentPos(4);
        
        currObj = currObj.Parent;
    end

    % Calculate the inset size and placement (top right of the plot box)
    % Increased height slightly so the bars don't get squished by the text
    this_insetWidth = this_mainPos(3) * 0.075;
    this_insetHeight = this_mainPos(4) * 0.45;
    
    % Place it at the top right, with a tiny margin from the borders
    this_left = this_mainPos(1) + this_mainPos(3) - this_insetWidth - 0.005;
    this_bottom = this_mainPos(2) + this_mainPos(4) - this_insetHeight - 0.005;

    % Create axes as a child of the figure to overlay correctly using absolute normalized units
    % We apply a unique Tag and store axMain in UserData to identify it later
    axInset = axes('Parent', this_fig, 'Units', 'normalized', ...
        'Position', [this_left, this_bottom, this_insetWidth, this_insetHeight], ...
        'Tag', 'AggregateBarInset', 'UserData', axMain);
    
    % Plot the bar chart directly
    this_bar = bar(axInset, this_cats, aggConf);
    
    % 5. Apply the line colors to the bars
    this_bar.FaceColor = 'flat';
    this_bar.CData = barColors;
    
    % 6. Highlight the true class with a thicker edge
    trueIdx = find(catNames == string(TrueFeature));
    if ~isempty(trueIdx)
        trueIdx = trueIdx(1); % In case of any duplicate names, take the first
        hold(axInset, 'on');
        
        % Create an array that only has the true class's bar height
        highlightConf = zeros(size(aggConf));
        highlightConf(trueIdx) = aggConf(trueIdx);
        
        % Overlay a transparent bar with a thicker edge
        hHighlight = bar(axInset, this_cats, highlightConf);
        hHighlight.FaceColor = 'none'; % Make it hollow
        hHighlight.EdgeColor = barColors(trueIdx, :); % Match the class color
        hHighlight.LineWidth = 2; % Thicker edge to match the true line
        
        hold(axInset, 'off');
    end
    
    % Optional: Format the inset axes for better readability
    % title(axInset, 'Aggregated', 'FontSize', 7, 'Margin', 1);
    ylim(axInset, [0, 1]);
    
    % Remove ticks and labels to prevent them from crushing the actual bars
    % in very short/wide subplot dimensions
    axInset.XTickLabel = []; 
    axInset.YTick = [];
    axInset.XAxis.TickLength = [0 0];
    axInset.YAxis.TickLength = [0 0];
    
    axInset.FontSize = 7;
    box(axInset, 'on');
    axInset.Color = [0.95 0.95 0.95];

    AggregateBar = axInset;
end

end