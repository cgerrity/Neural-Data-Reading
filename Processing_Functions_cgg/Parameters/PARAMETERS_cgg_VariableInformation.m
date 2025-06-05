function VariableInformation = PARAMETERS_cgg_VariableInformation(VariableSet)
%PARAMETERS_CGG_REGRESSIONVARIABLES Summary of this function goes here
%   Detailed explanation goes here

TableVariables = [["Numeric Label", "double"]; ...
    ["Label", "string"]; ...
    ["Description", "string"]];

NumVariables = size(TableVariables,1);
VariableInformation = table('Size',[0,NumVariables],... 
	    'VariableNames', TableVariables(:,1),...
	    'VariableTypes', TableVariables(:,2));


switch VariableSet
    case 'Chosen Feature'
        VariableInformation(1,:) = {1,"Shape","text"};
        VariableInformation(2,:) = {2,"Pattern","text"};
        VariableInformation(3,:) = {3,"Color","text"};
        VariableInformation(4,:) = {4,"Arms","text"};
    case 'Shared Feature'
        VariableInformation(1,:) = {1,"EC-Shared","text"};
        VariableInformation(2,:) = {2,"EC-NonShared","text"};
        VariableInformation(3,:) = {3,"EE-Shared","text"};
        VariableInformation(4,:) = {4,"EE-NonShared","text"};
        VariableInformation(5,:) = {5,"CC-Shared","text"};
        VariableInformation(6,:) = {6,"CC-NonShared","text"};
        VariableInformation(7,:) = {7,"CE-Shared","text"};
        VariableInformation(8,:) = {8,"CE-NonShared","text"};
        VariableInformation(9,:) = {9,"First","text"};
    case 'Previous Trial Effect'
        VariableInformation(1,:) = {1,"EE","text"};
        VariableInformation(2,:) = {2,"EC","text"};
        VariableInformation(3,:) = {3,"CE","text"};
        VariableInformation(4,:) = {4,"CC","text"};
    case 'Prediction Error'
        VariableInformation(1,:) = {1,"Prediction Error","text"};
    case 'Positive Prediction Error'
        VariableInformation(1,:) = {1,"Positive Prediction Error","text"};
    case 'Negative Prediction Error'
        VariableInformation(1,:) = {1,"Negative Prediction Error","text"};
    case 'Absolute Prediction Error'
        VariableInformation(1,:) = {1,"Absolute Prediction Error","text"};
    case 'Outcome'
        VariableInformation(1,:) = {1,"Correct","text"};
        VariableInformation(2,:) = {0,"Error","text"};
    case 'Error Trace'
        VariableInformation(1,:) = {1,"Error Trace","text"};
    case 'Choice Probability WM'
        VariableInformation(1,:) = {1,"Choice Probability WM","text"};
    case 'Choice Probability RL'
        VariableInformation(1,:) = {1,"Choice Probability RL","text"};
    case 'Choice Probability CMB'
        VariableInformation(1,:) = {1,"Choice Probability CMB","text"};
    case 'Value RL'
        VariableInformation(1,:) = {1,"Value RL","text"};
    case 'Value WM'
        VariableInformation(1,:) = {1,"High","text"};
        VariableInformation(2,:) = {0.333333,"Low","text"};
    case 'WM Weight'
        VariableInformation(1,:) = {1,"WM Weight","text"};
    case 'Dimension'
        VariableInformation(1,:) = {1,"Unknown","text"};
    case 'Trial Outcome'
        VariableInformation(1,:) = {1,"Correct","text"};
        VariableInformation(2,:) = {0,"Error","text"};
    case 'Adaptive Beta'
        VariableInformation(1,:) = {1,"Adaptive beta","text"};
    case 'Prediction Error Category'
        VariableInformation(1,:) = {1,"Low","text"};
        VariableInformation(2,:) = {2,"Medium","text"};
        VariableInformation(3,:) = {3,"High","text"};
        VariableInformation(4,:) = {0,"Unlearned","text"};
    case 'ZZZZZZZ'
        VariableInformation(1,:) = {1,"ZZZZZZZ","text"};
    otherwise
        VariableInformation(1,:) = {1,"All Targets","text"};
end



end

