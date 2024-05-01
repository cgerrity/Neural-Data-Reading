function Outputs = cgg_applyFunctionToProcessedAreasFromSession(InFunction,DataDir,Areas,NumOutputs)
%CGG_APPLYFUNCTIONTOPROCESSEDAREASFROMSESSION Summary of this function goes here
%   Detailed explanation goes here

NumAreas = length(Areas);

Outputs = cell(NumOutputs,NumAreas);

for aidx=1:NumAreas
    this_Area=Areas(aidx);
    this_Data = cgg_getProcessedTrialsForSessionForSingleArea(...
        DataDir,this_Area);
    [Outputs{:,aidx}] = InFunction(this_Data,this_Area);
end

end

