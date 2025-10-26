function MaxGradSize = cgg_getAccumulationSizeForCurrentSystem(AccumulationInformation)
%CGG_GETACCUMULATIONSIZEFORCURRENTSYSTEM Summary of this function goes here
%   Detailed explanation goes here


if isstruct(AccumulationInformation)
    AccumulationInformation = struct2table(AccumulationInformation);
end
if istable(AccumulationInformation)
    AccumulationInformation = dictionary(AccumulationInformation.SystemName,AccumulationInformation.MaxBatchSize);
end

%%

GPUTable = gpuDeviceTable();

GPUNames = GPUTable.Name;

if isempty(GPUNames)
    GPUNames = "CPU";
end

%%

MaxGradSize = AccumulationInformation(GPUNames);

[MaxGradSize,GPUNameIDX] = min(MaxGradSize);
MaxGradSystemName = GPUNames(GPUNameIDX);

fprintf('*** Using Maximum Gradient Accumulation Batch Size of %d for System: %s\n',MaxGradSize,MaxGradSystemName);

end

