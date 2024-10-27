function OutNames = cgg_setRegressionVariableNames(CoefficientNames,VariableInformation)
%CGG_SETREGRESSIONVARIABLENAMES Summary of this function goes here
%   Detailed explanation goes here

OutNames = CoefficientNames;

InterceptIDX = strcmp(CoefficientNames,'(Intercept)');

if any(InterceptIDX)
OutNames{InterceptIDX} = "Intercept";
end

if height(VariableInformation) == 1
    OutNames{~InterceptIDX} = VariableInformation.Label;
end

OutNames_Char = cellfun(@char,OutNames,"UniformOutput",false);
VariableIDX = extractAfter(OutNames_Char,"_");
VariableIDX = cellfun(@str2num,VariableIDX,"UniformOutput",false);

for vidx = 1:length(VariableIDX)
    this_VariableIDX = VariableIDX{vidx};
    if ~isempty(this_VariableIDX)

        this_VariableLabel = VariableInformation{VariableInformation.('Numeric Label') == this_VariableIDX,"Label"};

        if ~isempty(this_VariableLabel)
        OutNames{vidx} = this_VariableLabel;
        end
    end
end

OutNames = cellfun(@char,OutNames,"UniformOutput",false);

end

