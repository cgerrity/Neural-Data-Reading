function Outputs = cgg_applyFunctionToProcessedAreasFromSession(InFunction,DataDir,Areas,NumOutputs)
%CGG_APPLYFUNCTIONTOPROCESSEDAREASFROMSESSION Summary of this function goes here
%   Detailed explanation goes here

NumAreas = length(Areas);
rng('shuffle');
AreaIndices = 1:NumAreas;
AreaIndices = AreaIndices(randperm(NumAreas));

Outputs = cell(NumOutputs,NumAreas);

for aidx=1:NumAreas
    this_AreaIndex = AreaIndices(aidx);
    this_Area=Areas(this_AreaIndex);
    this_Data = cgg_getProcessedTrialsForSessionForSingleArea(...
        DataDir,this_Area);
    [Outputs{:,this_AreaIndex}] = InFunction(this_Data,this_Area);
end

end

