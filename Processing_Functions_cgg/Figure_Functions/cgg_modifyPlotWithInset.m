function axInset = cgg_modifyPlotWithInset(axMain, plotFunc, plotArgs, insetPos)
% cgg_modifyPlotWithInset Adds a customizable inset plot to an existing main axes.
%
% Inputs:
%   axMain   - Handle to the main axes (use gca for current axes).
%   plotFunc - Function handle for the inset plot (e.g., @histogram, @plot).
%   plotArgs - Cell array of arguments for the plot function (e.g., {X, Y}).
%   insetPos - [left, bottom, width, height] as fractions (0 to 1) relative 
%              to the main axes. Example: [0.6 0.6 0.3 0.3] puts a 30% 
%              sized inset in the top right.
%
% Outputs:
%   axInset  - Handle to the newly created inset axes.

    % 1. Set defaults for missing arguments
    if nargin < 4 || isempty(insetPos)
        insetPos = [0.65, 0.65, 0.3, 0.3]; % Default to top-right
    end
    if nargin < 1 || isempty(axMain)
        axMain = gca;
    end
    if ~iscell(plotArgs)
        plotArgs = {plotArgs}; % Ensure plotArgs is a cell array
    end

    % 2. Get main axes position
    % Using InnerPosition keeps the inset relative to the actual plot area,
    % ignoring the space taken up by axis labels and titles.
    mainPos = axMain.InnerPosition;

    % 3. Calculate inset position as a fraction of the main axes
    left   = mainPos(1) + mainPos(3) * insetPos(1);
    bottom = mainPos(2) + mainPos(4) * insetPos(2);
    width  = mainPos(3) * insetPos(3);
    height = mainPos(4) * insetPos(4);

    % 4. Create the inset axes
    % Using axMain.Parent ensures it attaches to the correct figure/panel
    axInset = axes('Parent', axMain.Parent, 'Position', [left bottom width height]);
    
    % Optional: Add a box and background color so it stands out from the main plot
    box(axInset, 'on');
    axInset.Color = [0.95 0.95 0.95]; % Light gray background

    % 5. Generate the plot inside the inset
    % feval executes the function handle, passing the inset axes as the first target
    feval(plotFunc, axInset, plotArgs{:});

end