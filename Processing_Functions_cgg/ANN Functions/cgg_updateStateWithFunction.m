function StateOut = cgg_updateStateWithFunction(State1,State2,Func)
%CGG_UPDATESTATEWITHFUNCTION Summary of this function goes here
%   Detailed explanation goes here


StateOut = State1;

TrainedIDX = contains(State1.Parameter,"Trained");

StateOut(TrainedIDX,:) = dlupdate(Func,State1(TrainedIDX,:),State2(TrainedIDX,:));

end

