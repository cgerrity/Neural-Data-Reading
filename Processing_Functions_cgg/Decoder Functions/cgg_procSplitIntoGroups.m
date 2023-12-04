function [MaintainSplit,FurtherSplit] = cgg_procSplitIntoGroups(Identifiers,IdentifierName,SplitNames,NumFolds)
%CGG_PROCSPLITINTOGROUPS Summary of this function goes here
%   Detailed explanation goes here


NumSplits=numel(SplitNames);
NumSamples=numel(Identifiers);

Category=NaN(NumSamples,NumSplits);
Classes=cell(1);
NumPerClass=NaN(1,NumSplits);

this_DataNumberIDX=strcmp(IdentifierName,"Data Number");
DataNumber=cellfun(@(x) x(this_DataNumberIDX),Identifiers,'UniformOutput',true);
DataNumber=diag(diag(DataNumber))';


for idx=1:NumSplits
    this_SplitName=SplitNames(idx);
    this_IdentifiersIDX=strcmp(IdentifierName,this_SplitName);
    this_Identifier=cellfun(@(x) x(this_IdentifiersIDX),Identifiers,'UniformOutput',true);
    
    this_Classes=unique(this_Identifier);

    Category(:,idx)=this_Identifier;
    Classes{idx}=this_Classes;
    NumPerClass(idx)=numel(this_Classes);
end

C=Classes;
[C{end:-1:1}] = ndgrid(C{end:-1:1});
Possible_Categories = reshape(cat(numel(C),C{:}),[],numel(C));
Categories_IDX=NaN(1,NumSamples);

for sidx=1:NumSamples
this_Category=Category(sidx,:);
Categories_IDX(sidx)=find(all(Possible_Categories==this_Category,2));
end

[NumCategories,~]=size(Possible_Categories);

Possible_Category_DataNumber=cell(NumCategories,1);
Possible_Category_Count=NaN(NumCategories,1);

% SplitCounter=0;

for cidx=1:NumCategories
    this_Possible_Category_IDX=find(Categories_IDX==cidx);
    this_Possible_Category_Count=numel(this_Possible_Category_IDX);
    this_Possible_Category_DataNumber=DataNumber(this_Possible_Category_IDX);

    Possible_Category_Count(cidx)=this_Possible_Category_Count;
    Possible_Category_DataNumber{cidx}=this_Possible_Category_DataNumber;
    % if this_Possible_Category_Count>NumFolds
    %     SplitCounter=SplitCounter+1;
    %     FurtherSplit{SplitCounter}=this_Possible_Category_IDX;

end


FurtherSplit=Possible_Category_DataNumber(Possible_Category_Count>NumFolds);
MaintainSplit=[Possible_Category_DataNumber{Possible_Category_Count<=NumFolds}];
%%
end

