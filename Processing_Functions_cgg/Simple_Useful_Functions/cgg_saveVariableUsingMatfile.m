function cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt)
%CGG_SAVEVARIABLEUSINGMATFILE Summary of this function goes here
%   Detailed explanation goes here

NumVariables=numel(SaveVariablesName);

[SavePath,SaveName,SaveExt] = fileparts(SavePathNameExt);

SaveTMPName=[SaveName '_tmp'];

SaveTMPPathNameExt=[SavePath filesep SaveTMPName SaveExt];

m_Save = matfile(SaveTMPPathNameExt,'Writable',true);

for vidx=1:NumVariables
m_Save.(SaveVariablesName{vidx})=SaveVariables{vidx};
end

if isfile(SavePathNameExt)
delete(SavePathNameExt);
end

movefile(SaveTMPPathNameExt,SavePathNameExt);

end

