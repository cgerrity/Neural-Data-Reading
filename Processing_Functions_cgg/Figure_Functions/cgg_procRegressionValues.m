function cgg_procRegressionValues(InData,AreaIDX,MatchArray,InIncrement,AreaNames,InSavePathNameExt)
%CGG_PROCREGRESSIONVALUES Summary of this function goes here
%   Detailed explanation goes here

[P_Value,R_Value,P_Value_Coefficients,CoefficientNames,R_Value_Adjusted,B_Value_Coefficients] = cgg_procTrialVariableRegression(InData,MatchArray,InIncrement);

SaveVariables={P_Value,R_Value,P_Value_Coefficients,CoefficientNames,R_Value_Adjusted,B_Value_Coefficients};
SaveVariablesName={'P_Value','R_Value','P_Value_Coefficients','CoefficientNames','R_Value_Adjusted','B_Value_Coefficients'};

SavePathNameExt=sprintf(InSavePathNameExt,AreaNames{AreaIDX});

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end

