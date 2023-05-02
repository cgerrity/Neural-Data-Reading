function arraySelection = TableSelector(dataTable, varName, func)
%allows a function to be applied to a variable in a table. Meant for use
%with the Hierarchical Analysis scripts.

dataArray = dataTable.(varName);
arraySelection = func(dataArray);
