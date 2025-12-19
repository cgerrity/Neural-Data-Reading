function CellInput = cgg_changeFieldFromVarargin(CellInput,FieldName,NewVariable)
%CGG_CHANGEFIELDFROMVARARGIN Summary of this function goes here
%   Detailed explanation goes here

FieldIDX = cellfun(@(x) isequal(x,FieldName),CellInput);
FieldIDX = circshift(FieldIDX,1);
if any(FieldIDX)
CellInput{FieldIDX} = NewVariable;
else
CellInput{end + 1} = FieldName;
CellInput{end + 1} = NewVariable;
end
end

