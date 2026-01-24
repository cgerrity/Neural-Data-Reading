% VERIFY_TARGET_VALUE_CATEGORIES
% This script visualizes the output of classification functions
% to ensure binning occurs correctly.

sel_Variable = "Value Difference"; % "Target Value", "Target Prediction Error", "Value Difference"
NumBins = 3;
RangeType='EqualCount'; % 'EqualCount', 'EqualValue'

% 1. Load Data
if ~exist('Identifiers_Table', 'var')
    if exist('Gemini_Matlab_Table.mat', 'file')
        fprintf('Loading Identifiers_Table_New from file...\n');
        LoadedData = load('Gemini_Matlab_Table.mat', 'Identifiers_Table_New');
        if isfield(LoadedData, 'Identifiers_Table_New')
            Identifiers_Table = LoadedData.Identifiers_Table_New;
        elseif isfield(LoadedData, 'Identifiers_Table')
            Identifiers_Table = LoadedData.Identifiers_Table;
        else
            error('Could not find Identifiers_Table or Identifiers_Table_New in the .mat file.');
        end
    else
        error('Gemini_Matlab_Table.mat not found.');
    end
end

% 2. Run the calculation function
switch sel_Variable
    case 'Target Value'
        TableVariable = "Value RL Target";
        ExpPattern = "Staircase (Monotonic)";
        try
            [Categories, ~] = cgg_calcTargetValueCategories(Identifiers_Table,'NumBins',NumBins,'RangeType',RangeType);
        catch ME
            error('Function cgg_calcTargetValueCategories failed: %s', ME.message);
        end
        
    case 'Target Prediction Error'
        TableVariable = "Prediction Error Target";
        ExpPattern = "V-Shape (Absolute Value)";
        try
            [Categories, ~] = cgg_calcTargetPredictionErrorCategory(Identifiers_Table,'NumBins',NumBins,'RangeType',RangeType);
        catch ME
            error('Function cgg_calcTargetPredictionErrorCategory failed: %s', ME.message);
        end
        
    case 'Value Difference'
        TableVariable = "Value RL Difference";
        ExpPattern = "V-Shape (Assumed)"; 
        try
            [Categories, ~] = cgg_calcValueDifferenceCategory(Identifiers_Table,'NumBins',NumBins,'RangeType',RangeType);
        catch ME
            error('Function cgg_calcValueDifferenceCategory failed: %s', ME.message);
        end
end

% --- Dynamic Category Setup ---
numCats = max(Categories);
if numCats < 2
    numCats = 1; % Fallback if data is sparse, though usually at least 2 or 3
end

% Define Labels based on count
if numCats == 2
    CategoryLabels = {'Low', 'High'};
elseif numCats == 3
    CategoryLabels = {'Low', 'Medium', 'High'};
else
    % Create cell array of strings: "1", "2", "3", ...
    CategoryLabels = arrayfun(@num2str, 1:numCats, 'UniformOutput', false);
end

% Define Colors
plotColors = parula(numCats); 

% 3. Visualize Figure 1: Scatter Plot
uniqueDims = unique(Identifiers_Table.Dimensionality);
numDims = length(uniqueDims);

figure('Name', ['Verification Scatter: ' char(sel_Variable)], 'Color', 'w');

for i = 1:numDims
    thisDim = uniqueDims(i);
    
    if ~ismember(TableVariable, Identifiers_Table.Properties.VariableNames)
         error('Column "%s" not found in Identifiers_Table.', TableVariable);
    end
    
    idx = Identifiers_Table.Dimensionality == thisDim;
    vals = Identifiers_Table.(TableVariable)(idx);
    cats = Categories(idx);
    
    validMask = cats > 0;
    vals = vals(validMask);
    cats = cats(validMask);
    
    % Dynamic Count Subtitle
    countStr = [];
    for c = 1:numCats
        n = sum(cats == c);
        lbl = CategoryLabels{c};
        if c == 1
            countStr = sprintf('%s=%d', lbl, n);
        else
            countStr = sprintf('%s | %s=%d', countStr, lbl, n);
        end
    end
    countTotal = length(cats);
    
    subplot(numDims, 1, i);
    scatter(vals, cats, 25, cats, 'filled');
    
    if ismember(sel_Variable, ["Target Prediction Error", "Value Difference"])
        xline(0, '--r', 'Zero', 'Alpha', 0.5);
    end
    
    title(sprintf('Dim: %d (N=%d)', thisDim, countTotal), 'FontWeight', 'bold');
    subtitle(countStr);
    ylabel('Category');
    xlabel(TableVariable, 'Interpreter', 'none');
    
    ylim([0.5 numCats + 0.5]);
    yticks(1:numCats);
    yticklabels(CategoryLabels);
    
    grid on;
    colormap(plotColors);
    caxis([1 numCats]);
end
sgtitle(['Verification Scatter: ' char(sel_Variable)]);

% 4. Visualize Figure 2: Colored Histogram
figure('Name', ['Verification Histogram: ' char(sel_Variable)], 'Color', 'w');

for i = 1:numDims
    thisDim = uniqueDims(i);
    subplot(numDims, 1, i);
    hold on;
    
    idx = Identifiers_Table.Dimensionality == thisDim;
    vals = Identifiers_Table.(TableVariable)(idx);
    cats = Categories(idx);
    validMask = cats > 0;
    vals = vals(validMask);
    cats = cats(validMask);
    
    if isempty(vals)
        continue;
    end

    numBins = 50; 
    binEdges = linspace(min(vals), max(vals), numBins);
    
    % Loop through categories dynamically
    for c = 1:numCats
        histogram(vals(cats==c), binEdges, ...
            'FaceColor', plotColors(c,:), ...
            'EdgeColor', 'none', ...
            'FaceAlpha', 0.7);
    end
    
    % Draw boundary lines
    [sortedVals, sortIdx] = sort(vals);
    sortedCats = cats(sortIdx);
    changeIdx = find(diff(sortedCats) ~= 0);
    for k = 1:length(changeIdx)
        cIdx = changeIdx(k);
        boundaryVal = (sortedVals(cIdx) + sortedVals(cIdx+1)) / 2;
        xline(boundaryVal, '--k', 'LineWidth', 1.5, 'Alpha', 0.8);
    end
    
    if ismember(sel_Variable, ["Target Prediction Error", "Value Difference"])
        xline(0, '-r', 'Zero', 'LineWidth', 1);
    end

    hold off;
    title(sprintf('Dim: %d Distribution', thisDim), 'FontWeight', 'bold');
    ylabel('Frequency');
    grid on;
end
sgtitle(['Category Boundaries: ' char(sel_Variable)]);

% 5. Visualize Figure 3: Learning Curve Alignment (Banded with Stacked Marginals)
AlignVariable = "Trials From Learning Point";
if ismember(AlignVariable, Identifiers_Table.Properties.VariableNames)
    f3 = figure('Name', ['Verification Alignment: ' char(sel_Variable)], 'Color', 'w');
    f3.Position(4) = f3.Position(4) * 1.5; 
    
    for i = 1:numDims
        thisDim = uniqueDims(i);
        
        hSub = subplot(numDims, 1, i);
        pos = hSub.Position;
        delete(hSub); 
        
        margin = 0.015;
        histSize = 0.15 * pos(4);
        if histSize < 0.06, histSize = 0.06; end
        
        mainX = pos(1) + histSize + margin;
        mainY = pos(2) + histSize + margin;
        mainW = pos(3) - histSize - margin;
        mainH = pos(4) - histSize - margin;
        
        posMain   = [mainX, mainY, mainW, mainH];
        posLeft   = [pos(1), mainY, histSize, mainH];
        posBottom = [mainX, pos(2), mainW, histSize];
        
        axMain   = axes('Position', posMain);
        axLeft   = axes('Position', posLeft);
        axBottom = axes('Position', posBottom);
        
        dimIdx = Identifiers_Table.Dimensionality == thisDim;
        yData = Identifiers_Table.(TableVariable)(dimIdx);
        xData = Identifiers_Table.(AlignVariable)(dimIdx);
        cData = Categories(dimIdx);
        
        validIdx = ~isnan(yData) & ~isnan(xData) & cData > 0 & ~isinf(xData);
        yData = yData(validIdx);
        xData = xData(validIdx);
        cData = cData(validIdx);
        
        if isempty(yData)
            title(axMain, sprintf('Dim: %d (No Data)', thisDim));
            continue;
        end
        
        xLims = [min(xData)-1, max(xData)+1];
        yLims = [min(yData), max(yData)];
        rY = range(yLims); if rY==0, rY=1; end
        yLims = [yLims(1)-0.1*rY, yLims(2)+0.1*rY];

        nBins = 40;

        % --- 1. Left Histogram (Y-Distribution - STACKED) ---
        axes(axLeft); hold on;
        edgesY = linspace(yLims(1), yLims(2), nBins);
        centersY = (edgesY(1:end-1) + edgesY(2:end)) / 2;
        
        % Build Matrix for Stacked Bar (rows = category)
        countsY_Mat = zeros(numCats, length(centersY));
        for c = 1:numCats
             countsY_Mat(c, :) = histcounts(yData(cData==c), edgesY);
        end
                   
        bLeft = barh(centersY, countsY_Mat', 'stacked');
        for k=1:numCats
            bLeft(k).FaceColor = plotColors(k,:); 
            bLeft(k).EdgeColor = 'none'; 
        end
        
        set(axLeft, 'XDir', 'reverse');
        ylim(axLeft, yLims);
        set(axLeft, 'YAxisLocation', 'right', 'XTick', [], 'YTick', []); 
        linkaxes([axMain, axLeft], 'y');
        hold off;
        
        % --- 2. Bottom Histogram (X-Distribution - STACKED) ---
        axes(axBottom); hold on;
        edgesX = linspace(xLims(1), xLims(2), nBins);
        centersX = (edgesX(1:end-1) + edgesX(2:end)) / 2;
        
        countsX_Mat = zeros(numCats, length(centersX));
        for c = 1:numCats
             countsX_Mat(c, :) = histcounts(xData(cData==c), edgesX);
        end
        
        bBottom = bar(centersX, countsX_Mat', 'stacked');
        for k=1:numCats
            bBottom(k).FaceColor = plotColors(k,:); 
            bBottom(k).EdgeColor = 'none'; 
        end
        
        set(axBottom, 'YDir', 'reverse');
        xlim(axBottom, xLims);
        set(axBottom, 'XAxisLocation', 'top', 'YTick', [], 'XTick', []); 
        linkaxes([axMain, axBottom], 'x');
        hold off;
        
        % --- 3. Main Plot ---
        axes(axMain); hold on;
        
        % Draw Background Bands
        for catIdx = 1:numCats
            catColor = plotColors(catIdx, :);
            
            negVals = yData(cData == catIdx & yData < 0);
            if ~isempty(negVals)
                yLow = min(negVals); yHigh = max(negVals);
                patch([xLims(1) xLims(2) xLims(2) xLims(1)], ...
                      [yLow yLow yHigh yHigh], ...
                      catColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            end
            
            posVals = yData(cData == catIdx & yData >= 0);
            if ~isempty(posVals)
                yLow = min(posVals); yHigh = max(posVals);
                patch([xLims(1) xLims(2) xLims(2) xLims(1)], ...
                      [yLow yLow yHigh yHigh], ...
                      catColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            end
        end
        
        % Calculate Mean/SEM
        [uTrials, ~, uIdx] = unique(xData);
        meanVals = zeros(size(uTrials));
        semVals = zeros(size(uTrials));
        markerColors = zeros(length(uTrials), 3);
        
        for k = 1:length(uTrials)
             thisVal = yData(uIdx == k);
             meanVals(k) = mean(thisVal);
             semVals(k) = std(thisVal) / sqrt(length(thisVal));
             
             % Color marker by nearest approximate category
             [~, nearestIdx] = min(abs(yData - meanVals(k)));
             if ~isempty(nearestIdx)
                catOfMean = cData(nearestIdx(1));
                markerColors(k, :) = plotColors(catOfMean, :);
             else
                markerColors(k, :) = [0 0 0];
             end
        end
        
        plot(uTrials, meanVals, '-', 'Color', [0.4 0.4 0.4], 'LineWidth', 1.5);
        errorbar(uTrials, meanVals, semVals, '.', 'Color', [0.4 0.4 0.4], 'CapSize', 0);
        scatter(uTrials, meanVals, 30, markerColors, 'filled', 'MarkerEdgeColor', 'k');
        
        xline(0, '--k', 'Learning Point', 'LabelVerticalAlignment', 'bottom');
        
        hold off;
        
        title(axMain, sprintf('Dim: %d Learning Curve', thisDim), 'FontWeight', 'bold');
        ylabel(axMain, ['Mean ' char(TableVariable)], 'Interpreter', 'none');
        xlabel(axMain, 'Trials From Learning Point');
        grid(axMain, 'on');
        xlim(axMain, xLims);
        ylim(axMain, yLims);
    end
    sgtitle(['Learning Alignment: ' char(sel_Variable)]);
else
    warning('Column "%s" not found. Figure 3 skipped.', AlignVariable);
end