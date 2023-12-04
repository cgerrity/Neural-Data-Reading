function Output = cgg_procConfusionMatrixWindowCheck(InCell,IDX)
%CGG_PROCCONFUSIONMATRIXWINDOWCHECK Summary of this function goes here
%   Detailed explanation goes here

try
Output=InCell{IDX};
catch
Output=[];
end

end

