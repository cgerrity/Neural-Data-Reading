function OutputArray = cgg_ParallelCell2Mat(CountPerCell,WidthAll,Data)
%CGG_PARALLELCELL2MAT Summary of this function goes here
%   Detailed explanation goes here
    OutputArray=NaN(sum(CountPerCell),WidthAll);
    StartIDX=[1;cumsum(CountPerCell)+1];
    StartIDX(end)=[];
    EndIDX=StartIDX-1+CountPerCell;

    parfor eidx=1:length(CountPerCell)
        OutputArray = cgg_ParallelCell2MatHelper(OutputArray,StartIDX,EndIDX,Data,eidx);
    end
end

