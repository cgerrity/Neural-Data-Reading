function [ClassNames,NumClasses] = cgg_getClassesFromDataStore(DataStore)
%CGG_GETCLASSESFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

NumClasses=[];

TargetDataStore=DataStore.UnderlyingDatastores{2};

NumDimensions=length(preview(TargetDataStore));

evalc('NumClasses=gather(tall(TargetDataStore));');
if iscell(NumClasses)
if isnumeric(NumClasses{1})
    [Dim1,Dim2]=size(NumClasses{1});
    [Dim3,Dim4]=size(NumClasses);
if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
    NumClasses=NumClasses';
end
    NumClasses=cell2mat(NumClasses);
    [Dim1,Dim2]=size(NumClasses);
if Dim1<Dim2
    NumClasses=NumClasses';
end
end
end

ClassNames=cell(1,NumDimensions);
for fdidx=1:NumDimensions
ClassNames{fdidx}=unique(NumClasses(:,fdidx));
end
NumClasses=cellfun(@(x) length(x),ClassNames);

end

