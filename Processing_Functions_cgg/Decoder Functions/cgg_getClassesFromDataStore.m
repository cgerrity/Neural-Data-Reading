function [ClassNames,NumClasses,ClassPercent,ClassCounts,Values] = cgg_getClassesFromDataStore(DataStore,varargin)
%CGG_GETCLASSESFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
TargetDataStoreIDX = CheckVararginPairs('TargetDataStoreIDX', 2, varargin{:});
else
if ~(exist('TargetDataStoreIDX','var'))
TargetDataStoreIDX=2;
end
end

% NumClasses=[];

TargetDataStore=DataStore.UnderlyingDatastores{TargetDataStoreIDX};

NumDimensions=length(preview(TargetDataStore));

% evalc('NumClasses=gather(tall(TargetDataStore));');

if isa(gcp('nocreate'), 'parallel.ThreadPool')
NumClasses = readall(TargetDataStore,UseParallel=false);
else
NumClasses = readall(TargetDataStore,UseParallel=true);
end
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

Values = NumClasses;
ClassCounts=cell(1,NumDimensions);
ClassNames=cell(1,NumDimensions);
ClassPercent=cell(1,NumDimensions);
for fdidx=1:NumDimensions
    this_NumClasses = NumClasses(:,fdidx);
    [ClassCounts{fdidx},ClassNames{fdidx},ClassPercent{fdidx}]=groupcounts(this_NumClasses);
% ClassNames{fdidx}=unique(NumClasses(:,fdidx));
end
NumClasses=cellfun(@(x) length(x),ClassNames);

end

