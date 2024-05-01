function Accuracy = cgg_loadAccuracy(Accuracy_PathNameExt)
%CGG_GETPRIORACCURACY Summary of this function goes here
%   Detailed explanation goes here

Accuracy=[];
if isfile(Accuracy_PathNameExt)
m_Accuracy = matfile(Accuracy_PathNameExt,'Writable',true);
Accuracy = m_Accuracy.Accuracy;
Accuracy=diag(diag(Accuracy));
Accuracy=Accuracy';
end

end

