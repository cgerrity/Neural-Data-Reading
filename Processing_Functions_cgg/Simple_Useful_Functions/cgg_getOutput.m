function Output = cgg_getOutput(Input,Func,OutputNumber,varargin)
%CGG_GETOUTPUT Summary of this function goes here
%   Detailed explanation goes here
MultiInput = CheckVararginPairs('MultiInput', false, varargin{:});
Output_tmp = cell(1,OutputNumber);
if MultiInput
    [Output_tmp{:}] = Func(Input{:});
else
[Output_tmp{:}] = Func(Input);
end
Output = Output_tmp{OutputNumber};
end

