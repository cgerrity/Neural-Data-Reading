function Data_Table = cgg_procSingleSessionLearningModelVariables(FieldsToRemove,cfg)
%CGG_PROCSINGLESESSIONLEARNINGMODELVARIABLES Summary of this function goes here
%   Detailed explanation goes here

LM_Data_Cell = cgg_getLearningModelVariables(FieldsToRemove);

LearningModelName = cfg.LearningModelName;

Data_Table = [];

for didx = 1:length(LM_Data_Cell)
InData = LM_Data_Cell{didx};
this_Data_Table = cgg_procLearningModelVariables(InData,LearningModelName);
Data_Table = [Data_Table; this_Data_Table];
end

end

