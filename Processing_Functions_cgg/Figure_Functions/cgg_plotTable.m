function InFigure = cgg_plotTable(InputTable,TableTitle)
%CGG_PLOTTABLE Summary of this function goes here
%   Detailed explanation goes here
% Sample data

%%
% Sample table creation
% data = table({'A'; 'B'; 'C'}, [10; 15; 20], [3.5; 7.2; 5.1], ...
%              'VariableNames', {'Label', 'Count', 'Value'});

% Create a new figure
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;

% Define the table title
% TableTitle = 'Sample Data Table';

% Get the table dimensions
[numRows, numCols] = size(InputTable);

% Plot the table's column headers
for col = 1:numCols
    % Plot each column name centered
    text(col, numRows + 1, InputTable.Properties.VariableNames{col}, ...
         'HorizontalAlignment', 'center', 'FontWeight', 'bold');
end

% Plot the table data
for row = 1:numRows
    for col = 1:numCols
        % Extract data from table and plot it centered
        cellData = InputTable{row, col};  % Extract data from table
        if iscell(cellData)
            cellData = cellData{1};  % Extract content if it's a cell array
        end
        text(col, numRows - row + 1, num2str(cellData), 'HorizontalAlignment', 'center');
    end
end

% Add a centered title above the table
titleXPosition = (numCols + 1) / 2;  % Calculate the x position to center the title
text(titleXPosition, numRows + 2, TableTitle, 'HorizontalAlignment', 'center', ...
     'FontSize', 12, 'FontWeight', 'bold');

% Adjust axis limits and remove ticks
xlim([0 numCols + 1]);
ylim([0 numRows + 3]);  % Increase ylim to accommodate title
set(gca, 'XTick', [], 'YTick', []);
axis off;


end

