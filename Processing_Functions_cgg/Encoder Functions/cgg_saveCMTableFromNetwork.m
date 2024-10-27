function cgg_saveCMTableFromNetwork(InDatastore,InputNet,ClassNames,Encoding_Dir,varargin)
%CGG_SAVECMTABLEFROMNETWORK Summary of this function goes here
%   Detailed explanation goes here

[CM_Table] = cgg_procPredictionsFromDatastoreNetwork(InDatastore,InputNet,ClassNames,varargin{:});

CMTableSaveVariables={CM_Table};
CMTableSaveVariablesName={'CM_Table'};
% CMTableSaveVariables={CM_Table,ClassNames};
% CMTableSaveVariablesName={'CM_Table','ClassNames'};
CMTableSavePathNameExt = [Encoding_Dir filesep 'CM_Table.mat'];
cgg_saveVariableUsingMatfile(CMTableSaveVariables,CMTableSaveVariablesName,CMTableSavePathNameExt);

end

