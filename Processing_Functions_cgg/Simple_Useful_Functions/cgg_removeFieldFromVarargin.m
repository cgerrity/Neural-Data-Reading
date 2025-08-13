function CellInput = cgg_removeFieldFromVarargin(CellInput,FieldName)
%CGG_REMOVEFIELDFROMVARARGIN Summary of this function goes here
%   Detailed explanation goes here

FieldIDX = cellfun(@(x) isequal(x,FieldName),CellInput);
FieldIDX = FieldIDX | circshift(FieldIDX,1);
CellInput(FieldIDX) = [];
end

