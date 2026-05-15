function TEST_cgg_runAutoEncoder()
%TEST_CGG_RUNAUTOENCODER Summary of this function goes here
%   Detailed explanation goes here

%%
[DifferentVariables,~] = cgg_compareStruct(...
    PARAMETERS_cgg_runAutoEncoder('ParameterSetName','Prior Optimal'), ...
    PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2());

assert(isempty(DifferentVariables), sprintf('Compatibility Test 1 Failed: cgg_runAutoEncoder(''ParameterSetName'',''Prior Optimal'') produces different configuration than PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2'));

%%
[DifferentVariables,~] = cgg_compareStruct(...
    PARAMETERS_cgg_runAutoEncoder('ParameterSetName','Prior Optimal'), ...
    PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2('Epoch','Decision'));

assert(isempty(DifferentVariables), sprintf('Compatibility Test 2 Failed: cgg_runAutoEncoder(''ParameterSetName'',''Prior Optimal'') produces different configuration than PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2(''Epoch'',''Decision'')'));

%%
[DifferentVariables,~] = cgg_compareStruct(...
    PARAMETERS_cgg_runAutoEncoder('ParameterSetName','Prior Optimal','Epoch','Decision'), ...
    PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2('Epoch','Decision'));

assert(isempty(DifferentVariables), sprintf('Compatibility Test 3 Failed: cgg_runAutoEncoder(''ParameterSetName'',''Prior Optimal'',''Epoch'',''Decision'') produces different configuration than PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2(''Epoch'',''Decision'')'));
end