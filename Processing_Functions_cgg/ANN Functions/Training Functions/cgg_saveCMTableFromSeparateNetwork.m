function cgg_saveCMTableFromSeparateNetwork(LossFunction,...
    Encoder,Decoder,Classifier,LossInformation,IsOptimal,SaveDir)
%CGG_SAVECMTABLEFROMNETWORK Summary of this function goes here
%   Detailed explanation goes here

if IsOptimal
    if ~isempty(Classifier)
[~,CM_Table,~] = LossFunction(Encoder,Decoder,Classifier,LossInformation);

CMTableSaveVariables={CM_Table};
CMTableSaveVariablesName={'CM_Table'};
CMTableSavePathNameExt = [SaveDir filesep 'CM_Table.mat'];
cgg_saveVariableUsingMatfile(CMTableSaveVariables,CMTableSaveVariablesName,CMTableSavePathNameExt);
    end
end

end

