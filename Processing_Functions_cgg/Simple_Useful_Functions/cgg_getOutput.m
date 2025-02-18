function Output = cgg_getOutput(Input,Func,OutputNumber)
%CGG_GETOUTPUT Summary of this function goes here
%   Detailed explanation goes here
Output_tmp = cell(1,OutputNumber);
[Output_tmp{:}] = Func(Input);
Output = Output_tmp{OutputNumber};
end

