function cgg_saveValidationCMTable(CM_Table,IsOptimal,SaveDir)
%CGG_SAVECMTABLEFROMNETWORK Summary of this function goes here
%   Detailed explanation goes here

if IsOptimal
    if istable(CM_Table)
CMTableSaveVariables={CM_Table};
CMTableSaveVariablesName={'CM_Table'};
CMTableSavePathNameExt = [SaveDir filesep 'CM_Table_Validation.mat'];
cgg_saveVariableUsingMatfile(CMTableSaveVariables,CMTableSaveVariablesName,CMTableSavePathNameExt);
    end
end

end

