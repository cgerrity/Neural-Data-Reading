function [Output,State] = cgg_procNetworkPass(Input,Network,varargin)
%CGG_PROCNETWORKPASS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
WantPredict = CheckVararginPairs('WantPredict', true, varargin{:});
else
if ~(exist('WantPredict','var'))
WantPredict=true;
end
end

if isfunction
OutputNames = CheckVararginPairs('OutputNames', [], varargin{:});
else
if ~(exist('OutputNames','var'))
OutputNames=[];
end
end


% Network=resetState(Network);
Network=cgg_resetState(Network);
if WantPredict
    if ~isempty(OutputNames)
        Output=cell(length(OutputNames),1);
        [Output{:},State] = predict(Network,Input,Outputs=OutputNames);
    else
        [Output,State] = predict(Network,Input);
    end
else
    if ~isempty(OutputNames)
        Output=cell(length(OutputNames),1);
        [Output{:},State] = forward(Network,Input,Outputs=OutputNames);
    else
        [Output,State] = forward(Network,Input);
    end
end

end

