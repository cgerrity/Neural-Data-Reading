function InTable = cgg_addSignificantAccuracyTableValues(InTable,AccuracyTable,SessionIDX,IsSignificant)
%CGG_ADDSIGNIFICANTACCURACYTABLEVALUES Summary of this function goes here
%   Detailed explanation goes here


Window_Accuracy = AccuracyTable.('Window Accuracy'){1};
Accuracy = AccuracyTable.('Accuracy'){1};

if IsSignificant
InTable.('Window Accuracy') = {[InTable.('Window Accuracy'){1};Window_Accuracy]};
InTable.('Accuracy') = {[InTable.('Accuracy'){1};Accuracy]};
InTable.('Session Number') = {[InTable.('Session Number'){1}; SessionIDX]};
end

end

