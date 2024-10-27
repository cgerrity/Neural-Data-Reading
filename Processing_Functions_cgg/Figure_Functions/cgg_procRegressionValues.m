function cgg_procRegressionValues(InData,AreaIDX,MatchArray,InIncrement,AreaNames,VariableInformation,InSavePathNameExt)
%CGG_PROCREGRESSIONVALUES Summary of this function goes here
%   Detailed explanation goes here

[P_Value,R_Value,P_Value_Coefficients,CoefficientNames,R_Value_Adjusted,B_Value_Coefficients,R_Correlation,P_Correlation,Mean_Value] = cgg_procTrialVariableRegression(InData,MatchArray,InIncrement);

CoefficientNames = cgg_setRegressionVariableNames(CoefficientNames,VariableInformation);

SaveVariables={P_Value,R_Value,P_Value_Coefficients,CoefficientNames,R_Value_Adjusted,B_Value_Coefficients,R_Correlation,P_Correlation,Mean_Value};
SaveVariablesName={'P_Value','R_Value','P_Value_Coefficients','CoefficientNames','R_Value_Adjusted','B_Value_Coefficients','R_Correlation','P_Correlation','Mean_Value'};

SavePathNameExt=sprintf(InSavePathNameExt,AreaNames{AreaIDX});

cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);

end

