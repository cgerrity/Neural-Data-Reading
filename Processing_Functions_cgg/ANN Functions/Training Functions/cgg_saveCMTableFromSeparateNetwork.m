function cgg_saveCMTableFromSeparateNetwork(LossFunction,...
    Encoder,Decoder,Classifier,LossInformation,WeightKL_Anneal,...
    IsOptimal,SaveDir)
%CGG_SAVECMTABLEFROMNETWORK Summary of this function goes here
%   Detailed explanation goes here

if IsOptimal
    fprintf('   *** Obtaining Test Measures for Optimal Network\n'); tic;
    if ~isempty(Classifier)
[~,CM_Table,~,~] = LossFunction(Encoder,Decoder,Classifier,...
    LossInformation,WeightKL_Anneal);

CMTableSaveVariables={CM_Table};
CMTableSaveVariablesName={'CM_Table'};
CMTableSavePathNameExt = [SaveDir filesep 'CM_Table.mat'];
cgg_saveVariableUsingMatfile(CMTableSaveVariables,CMTableSaveVariablesName,CMTableSavePathNameExt);
    end
    fprintf('   >>> Obtaining Test Measures for Optimal Network took %.3f seconds\n',toc);
end

end

