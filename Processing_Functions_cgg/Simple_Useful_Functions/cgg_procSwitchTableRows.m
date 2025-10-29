function OutTable = cgg_procSwitchTableRows(InTable, InVariable, OutVariable)
%CGG_PROCSWITCHTABLEROWS Summary of this function goes here
%   This function takes in a table that has a variable that is a table and
%   switches the rows between the two. For example a split table may have
%   rows for 1-D, 2-D, and 3-D each with an attentional table that has
%   Target, Distractor (Correct), and Distractor (Error). This function
%   would swap them so the new table would have rows Target, Distractor
%   (Correct), and Distractor (Error) with a column for a table that has
%   rows 1-D, 2-D, and 3-D

InRowNames = InTable.Properties.RowNames;
NumInRows = length(InRowNames);

for iridx = 1:NumInRows
    this_SwitchTable=InTable{iridx,OutVariable}{1};

    if iridx == 1
        OutRowNames = this_SwitchTable.Properties.RowNames;
        OutTable = cell(length(OutRowNames),1);
    end

    for oridx = 1:length(OutRowNames)
        this_tmpTable = this_SwitchTable(OutRowNames{oridx},:);
        this_tmpTable.Properties.RowNames{1} = InRowNames{iridx};
        OutTable{oridx} = [OutTable{oridx};this_tmpTable];
    end

end

OutTable = table(OutTable,'VariableNames',InVariable,'RowNames',OutRowNames);
end

