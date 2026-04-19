function UpdateableParameters = cgg_getUpdateableParameters(ClassParameters,DynamicStructName,varargin)
%CGG_GETUPDATEABLEPARAMETERS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
CurrentValuePrefix = CheckVararginPairs('CurrentValuePrefix', "Current", varargin{:});
else
if ~(exist('CurrentValuePrefix','var'))
CurrentValuePrefix="Current";
end
end

%%

if isempty(fieldnames(ClassParameters.(DynamicStructName)))
    UpdateableParameters = {};
    return
end
HasIndividualDynamicParameters = ...
    cgg_hasIndividualDynamicParameters(ClassParameters,DynamicStructName);

if HasIndividualDynamicParameters
    UpdateableParameters = ...
        fieldnames(ClassParameters.(DynamicStructName));
else
    AllProperties = properties(ClassParameters);
    UpdateableParameters = ...
        AllProperties(contains(AllProperties,CurrentValuePrefix));
    UpdateableParameters = erase(UpdateableParameters,CurrentValuePrefix);
    UpdateableParameters = erase(UpdateableParameters,...
        ClassParameters.CommonParameterName);
end

end