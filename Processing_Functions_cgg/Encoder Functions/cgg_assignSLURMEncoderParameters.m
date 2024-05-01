function [Fold,cfg_Out] = cgg_assignSLURMEncoderParameters(cfg,cfgSLURM)
%CGG_ASSIGNSLURMENCODERPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

VariableNames = fieldnames(cfgSLURM);

% VariableNames = TableSLURM.Properties.VariableNames;

cfg_Out = cfg;

for pidx = 1:numel(VariableNames)
    this_VariableName = VariableNames{pidx};
    cfg_Out.(this_VariableName) = cfgSLURM.(this_VariableName);
    % 
    % this_VariableName = VariableNames{pidx};
    % this_Variable = TableSLURM{1,VariableNames{pidx}};
    % this_Variable = this_Variable{1};
    % if iscell(this_Variable)
    %     this_Variable = this_Variable{1};
    % end
    % cfg_Out.(this_VariableName) = this_Variable;
end

Fold = cfg_Out.Fold;

end

