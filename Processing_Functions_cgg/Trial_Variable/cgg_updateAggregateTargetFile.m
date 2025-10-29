function cgg_updateAggregateTargetFile(TargetPathNameExt,UpdateFunction)
%CGG_UPDATEAGGREGATETARGETFILE Summary of this function goes here
%   Detailed explanation goes here

Target = load(TargetPathNameExt);
Target = Target.Target;

DataNumber = cgg_loadTargetArray(TargetPathNameExt,'DataNumber',true);
Target.DataNumber = DataNumber;

NewTarget = UpdateFunction(Target);

TargetSaveVariables={NewTarget};
TargetSaveVariablesName={'Target'};

cgg_saveVariableUsingMatfile(TargetSaveVariables,TargetSaveVariablesName,TargetPathNameExt);

end

