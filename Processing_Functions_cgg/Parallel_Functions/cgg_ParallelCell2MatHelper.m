function OutputArray = cgg_ParallelCell2MatHelper(OutputArray,StartIDX,EndIDX,Data,IDX)
%CGG_PARALLELCELL2MATHELPER Summary of this function goes here
%   Detailed explanation goes here

OutputArray(StartIDX(IDX):EndIDX(IDX),:)=Data{IDX};

end

