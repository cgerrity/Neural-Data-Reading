function HasIndividualDynamicParameters = cgg_hasIndividualDynamicParameters(ClassParameters,DynamicStructName)
%CGG_HASINDIVIDUALDYNAMICPARAMETERS Summary of this function goes here
%   Detailed explanation goes here

DynamicFieldNames = fieldnames(ClassParameters.(DynamicStructName));
HasIndividualDynamicParameters = ...
    ~any(strcmp(DynamicFieldNames,"EpochPoints")) || ...
    ~any(strcmp(DynamicFieldNames,"MagnitudePoints"));
end