function cellArray = cgg_getIndicesIntoGroups(groupSize, totalIndices)
    % Calculate the number of full groups
    numFullGroups = floor(totalIndices / groupSize);

    % Calculate the number of remaining indices
    numRemainingIndices = rem(totalIndices, groupSize);

    % Initialize a cell array to store the groups
    cellArray = cell(1, numFullGroups + (numRemainingIndices > 0));

    % Loop over full groups
    for i = 1:numFullGroups
        % Get indices for the current group
        startIdx = (i - 1) * groupSize + 1;
        endIdx = i * groupSize;
        cellArray{i} = startIdx:endIdx;
    end

    % Add remaining indices as a separate group
    if numRemainingIndices > 0
        startIdx = numFullGroups * groupSize + 1;
        cellArray{end} = startIdx:totalIndices;
    end
end
