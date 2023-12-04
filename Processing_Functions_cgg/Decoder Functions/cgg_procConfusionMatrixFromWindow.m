function OutCM = cgg_procConfusionMatrixFromWindow(CM_Cell,WindowNumber)
%CGG_PROCCONFUSIONMATRIXFROMWINDOW Summary of this function goes here
%   Detailed explanation goes here

this_CM=cellfun(@(x) cgg_procConfusionMatrixWindowCheck(x,WindowNumber),CM_Cell,'UniformOutput',false);
this_CM=this_CM(~cellfun(@(x) isempty(x),this_CM));
this_CM=this_CM';
OutCM=cell2mat(this_CM);


end

