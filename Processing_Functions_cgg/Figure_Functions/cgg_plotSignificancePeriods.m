function cgg_plotSignificancePeriods(timeVec, dataMatrix, alpha, varargin)
% CGG_PLOTSIGNIFICANCEPERIODS Draws horizontal lines indicating significant periods
%
% Inputs:
%   timeVec    - 1xN time vector
%   dataMatrix - SxN data matrix (S observations, N time points)
%   alpha      - significance level (e.g., 0.05 for p < 0.05)
%   varargin   - optional parameters:
%                'baseline', value - test against specific baseline (default: 0)
%                'lineColor', color - color for significance lines (default: 'red')
%                'lineWidth', width - width of significance lines (default: 3)
%                'barStyle', 'continuous'/'individual' - continuous lines or individual bars (default: 'continuous')
%                'level', integer - which level to draw the bar (1=top, 2=second, etc.) (default: 1)

% Parse optional inputs
p = inputParser;
addParameter(p, 'baseline', 0, @isnumeric);
addParameter(p, 'lineColor', 'red', @(x) ischar(x) || isnumeric(x) || isstring(x));
addParameter(p, 'lineWidth', 3, @isnumeric);
addParameter(p, 'barStyle', 'continuous', @(x) ismember(x, {'continuous', 'individual'}));
addParameter(p, 'level', 1, @(x) isnumeric(x) && x >= 1 && mod(x,1) == 0);
addParameter(p, 'testType', 'different', @(x) ismember(x, {'different', 'greater', 'less'}));
addParameter(p, 'YLim', ylim, @(x)isnumeric(x) && ~isscalar(x));
parse(p, varargin{:});

baseline = p.Results.baseline;
lineColor = p.Results.lineColor;
lineWidth = p.Results.lineWidth;
barStyle = p.Results.barStyle;
level = p.Results.level;
testType = p.Results.testType;
YLim = p.Results.YLim;

% Convert testType to MATLAB ttest tail parameter
switch testType
    case 'different'
        tail = 'both';
    case 'greater'
        tail = 'right';
    case 'less'
        tail = 'left';
end

% Validate inputs
if size(timeVec, 1) ~= 1
    error('timeVec must be a 1xN vector');
end
if size(dataMatrix, 2) ~= length(timeVec)
    error('dataMatrix columns must match timeVec length');
end

% Perform t-tests at each time point
[S, N] = size(dataMatrix);
pValues = zeros(1, N);

for i = 1:N
    if S > 1
        [~, pValues(i)] = ttest(dataMatrix(:, i), baseline, 'Tail', tail);
    else
        warning('Only one observation per time point - cannot perform t-test');
        pValues(i) = 1;
    end
end

% Determine significant time points
significant = pValues < alpha;

% Check if we need to hold the current plot
wasHolding = ishold;
if ~wasHolding
    hold on;
end

% Get current axis limits
ylims = YLim;
yRange = ylims(2) - ylims(1);

LineSpacingPercent = 0.5;

LineWidthY = cgg_getLineWidthToPlotUnits(lineWidth, yRange, 'Y');
% Calculate position for this significance level - very close spacing
% barSpacing = 0.002 * yRange;  % Extremely small spacing between levels
barSpacing = LineWidthY*(1 + LineSpacingPercent);  % Extremely small spacing between levels
topOffset = 0.001 * yRange;   % Tiny offset from very top

% Position for this level (level 1 starts at the very top)
% signifY = ylims(2) - topOffset + (level - 1) * barSpacing;
signifY = ylims(2) - topOffset - (level-1) * barSpacing;

% Draw significance indicators
if any(significant)
    if strcmp(barStyle, 'individual')
        % Draw individual vertical bars for each significant time point
        sigTimes = timeVec(significant);
        for i = 1:length(sigTimes)
            plot([sigTimes(i), sigTimes(i)], [signifY, signifY + 0.002 * yRange], ...
                 'Color', lineColor, 'LineWidth', lineWidth);
        end
    else
        % Draw continuous horizontal lines for significant periods
        diffSig = diff([false, significant, false]);
        startIdx = find(diffSig == 1);
        endIdx = find(diffSig == -1) - 1;
        
        for i = 1:length(startIdx)
            xStart = timeVec(startIdx(i));
            xEnd = timeVec(endIdx(i));
            
            % Draw horizontal line with uniform thickness
            plot([xStart, xEnd], [signifY, signifY], ...
                 'Color', lineColor, 'LineWidth', lineWidth);
        end
    end
    
    % % Expand y-axis minimally to accommodate this level
    % requiredYTop = signifY + 0.003 * yRange;
    % currentYLims = ylim;
    % if requiredYTop > currentYLims(2)
    %     ylim([ylims(1), requiredYTop]);
    % end
end

% Restore hold state
if ~wasHolding
    hold off;
end

end