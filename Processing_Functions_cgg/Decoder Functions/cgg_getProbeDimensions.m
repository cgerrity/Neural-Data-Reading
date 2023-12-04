function [Probe_Dimensions,Probe_Areas,Probe_Total,Same_Areas] = cgg_getProbeDimensions(Probe_Order)
%CGG_GETPROBEDIMENSIONS Summary of this function goes here
%   Detailed explanation goes here


Probe_Names=extractBefore(Probe_Order,'_');

Probe_Total=length(Probe_Names);

[Probe_Areas,~,Probe_Dimensions]=unique(Probe_Names,'stable');

Same_Areas = cell(length(Probe_Areas),1);

for aidx=1:length(Probe_Areas)
Same_Areas{aidx} = find(Probe_Dimensions==aidx);
end

end

