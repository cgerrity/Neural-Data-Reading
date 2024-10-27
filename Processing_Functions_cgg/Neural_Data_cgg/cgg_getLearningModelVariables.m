function LM_Data_Cell = cgg_getLearningModelVariables(FieldsToRemove)
%CGG_PROCSINGLESESSIONLEARNINGMODELVARIABLES Summary of this function goes here
%   Detailed explanation goes here

LMNameExt = 'FeatureValues_RLWMModelValues_01.mat';

[~,outputfolder_LM,~,~] = ...
    cgg_getBaseFolders('WantTEBA',true);

outputfolder_LM = [outputfolder_LM filesep 'Data_Neural'];

LMPathNameExt = [outputfolder_LM filesep 'Learning_Model_Variables' ...
    filesep LMNameExt];

m_LM = matfile(LMPathNameExt,"Writable",false);

LM_FieldNames = fieldnames(m_LM);
DataIDX = contains(LM_FieldNames,'Data');
LM_Data_FieldNames = LM_FieldNames(DataIDX);
NumData = length(LM_Data_FieldNames);

LM_Data_Cell = cell(1,NumData);

for didx = 1:NumData
    this_LM_Data = m_LM.(LM_Data_FieldNames{didx});
    this_LM_Data = rmfield(this_LM_Data,FieldsToRemove);
LM_Data_Cell{didx} = this_LM_Data;
end

end

