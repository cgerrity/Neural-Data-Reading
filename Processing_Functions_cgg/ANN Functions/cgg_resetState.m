function InputNetwork = cgg_resetState(InputNetwork)
%CGG_RESETSTATE Summary of this function goes here
%   Detailed explanation goes here
State = InputNetwork.State;
InputNetwork=resetState(InputNetwork);
InputNetwork = cgg_updateState(InputNetwork,State);
end

