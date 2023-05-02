function newTable = TableConcatVarControl(table1, table2, varargin)


%rename any columns
columnRenames = CheckVararginPairs('ColumnRenames', [], varargin{:});

if ~isempty(columnRenames)
    if ~iscell(columnRenames) || length(columnRenames) ~= 2
        error('ColumnRenames must be a cell array of length 2.');
    elseif length(columnRenames{1}) ~= length(columnRenames{2})
        error('The two cells in ColumnRenames must have the same number of elements.');
    end
    
    for iCol = 1:length(columnRenames{1})
        if ~ischar(columnRenames{1}(iCol)) || ~isstring(columnRenames{1}(iCol))
            error(['Item ' num2str(iCol) ' in ColumnRenames cell #1 must be a character or string but it is not.']);
        end
        if ~ischar(columnRenames{2}(iCol)) || ~isstring(columnRenames{2}(iCol))
            error(['Item ' num2str(iCol) ' in ColumnRenames cell #2 must be a character or string but it is not.']);
        end
        changeCol1 = find(ismember(table1.Properties.VariableNames, columnRenames{1}(iCol)));
        if (~isempty(changeCol1))
            table1.Properties.VariableNames{changeCol1} = columnRenames{2}(iCol);
        end
        changeCol2 = find(ismember(table2.Properties.VariableNames, columnRenames{1}(iCol)));
        if (~isempty(changeCol2))
            table2.Properties.VariableNames{changeCol2} = columnRenames{2}(iCol);
        end
    end
end

%force desired variables to be numeric
ensureNumeric = CheckVararginPairs('EnsureNumeric', [], varargin{:});
if ~isempty(ensureNumeric)
    table1 = ConvertTableVarsToNumeric(table1, ensureNumeric);
    table2 = ConvertTableVarsToNumeric(table2, ensureNumeric);
end

[table1, table2] = MatchVariables(table1, table2);
newTable = [table1; table2];
%add any missing variables in either table

% 
% 
% try
%     newTable = [table1; table2];
% catch ME
%     switch ME.identifier
%         case 'MATLAB:table:vertcat:SizeMismatch'
%             vars1 = table1.Properties.VariableNames;
%             vars2 = table2.Properties.VariableNames;
%             
%             %             if length(vars1) == 54 && length(vars2) == 65
%             %                 newVar1 = nan(height(table1), 1);
%             %                 newVar2 = nan(height(table2), 1);
%             %                 table1 = [table1(:,2:49) table(newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, 'variableNames', table2.Properties.VariableNames(49:57)), ...
%             %                     table1(:,50) table(newVar1, newVar1, newVar1, newVar1, 'variableNames', table2.Properties.VariableNames([59:61 63])), ...
%             %                     table1(:,51:end)];
%             %                 table2 = [table2(:,[1:61 63]) table(newVar2, 'variableNames', table1.Properties.VariableNames(66)) table2(:,[64 62 65])];
%             %
%             %             else
%             for i = 1:max([length(vars1) length(vars2)])
%                 %                     if length(vars1) == 56 && length(vars2) == 68
%                 %                         newVar1 = nan(height(table1), 1);
%                 %                         newVar2 = nan(height(table2), 1);
%                 %                         table1 = [table1(:,1:51) table(newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, newVar1, 'variablenames', table2.Properties.VariableNames(52:60)), ...
%                 %                             table1(:,52) table(newVar1, newVar1, newVar1, newVar1, 'variablenames', table2.Properties.VariableNames([62:64 66])) table1(:,53:end)];
%                 %                         table2 = [table2(:,[1:64 66]) table(newVar2, 'variablenames', table1.Properties.VariableNames(66)) table2(:,[67 65 68])];
%                 %                     else
%                 if ~isequal(vars1{i}, vars2{i})
%                     if i == length(vars1)
%                     elseif i == length(vars2)
%                     elseif isequal(vars1{i}, vars2{i+1})
%                         if isnumeric(table2.(vars2{i}))
%                             newVar = nan(height(table1), 1);
%                         elseif iscell(table2.(vars2{i}))
%                             newVar = cell(height(table1),1);
%                         end
%                         table1 = [table1(:,1:i-1), table(newVar, 'variablenames', {vars2{i}}), table1(:,i:end)];
%                         vars1 = table1.Properties.VariableNames;
%                     elseif isequal(vars2{i}, vars1{i+1})
%                         vars2 = [vars2(1:i) vars1{i+1} vars2(i+1:end)];
%                         if isnumeric(table1.(vars1{i}))
%                             newVar = nan(height(table2), 1);
%                         elseif iscell(table1.(vars1{i}))
%                             newVar = cell(height(table2),1);
%                         end
%                         table2 = [table2(:,1:i-1), table(newVar, 'variablenames', {vars1{i}}), table2(:,i:end)];
%                         vars2 = table2.Properties.VariableNames;
%                     end
%                 end
%                 %                 end
%             end
%             newTable = [table1; table2];
%         otherwise
%             disp(ME.identifier);
%             disp(ME.message);
%             error('Problem with table concatenation');
%     end
% end
% 
% function matchedTable = matchTableVar(goodTable, badTable, varIndex)
% 
% 
% function matchedTable = AddEmptyVarToTable(goodTable, badTable, varIndex)