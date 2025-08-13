function InputNetwork = cgg_updateState(InputNetwork,State)
%CGG_UPDATESTATE Summary of this function goes here
%   Detailed explanation goes here

TrainedIDX = contains(State.Parameter,"Trained");
InputNetwork.State.Value(TrainedIDX) = State.Value(TrainedIDX);
end

