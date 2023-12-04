function [TrainingDatastore,TestingDatastore,Training_IDX,Testing_IDX] = cgg_getTrainingTestingSplits(Datastore,Partition,Fold)
%CGG_GETTRAININGTESTINGSPLITS Summary of this function goes here
%   Detailed explanation goes here

Training_IDX=training(Partition,Fold);
Testing_IDX=test(Partition,Fold);

TrainingDatastore=subset(Datastore,Training_IDX);
TestingDatastore=subset(Datastore,Testing_IDX);

end

