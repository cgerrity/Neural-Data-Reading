function data_width = cgg_getLineWidthToPlotUnits(LineWidth, DataRange, AxesType)
    % line_width_points: line width in points
    % axis_range: range of data on the axis (max - min)
    % axis_position_normalized: normalized size of axis (0-1)
    
    % Get figure size in points (assuming 72 points per inch)
    fig = gcf;
    FigureUnits = fig.Units;
    fig.Units = 'points';
    fig_pos = get(fig, 'Position'); % [left bottom width height] in points
    % fprintf('Figure units: %s\n',fig.Units);
    % fprintf('Figure Width: %.2f\n',fig_pos(3));
    % fprintf('Figure Height: %.2f\n',fig_pos(4));
    fig.Units = FigureUnits;

    ax = gca;
    AxesUnits = fig.Units;
    ax.Units = 'normalized';
    ax_pos = get(ax, 'Position'); % [left bottom width height] normalized
    ax.Units = AxesUnits;
    
    % Calculate data units per point
    switch AxesType
        case 'X'
            FigIDX = 3;
            AxesIDX = 3;
        case 'Y'
            FigIDX = 4;
            AxesIDX = 4;
        otherwise
            FigIDX = 3;
            AxesIDX = 3;
    end
    axis_size_points = fig_pos(FigIDX) * ax_pos(AxesIDX); % for x-axis
    data_units_per_point = DataRange / axis_size_points;

    % Convert line width to data units
    data_width = LineWidth * data_units_per_point;
end