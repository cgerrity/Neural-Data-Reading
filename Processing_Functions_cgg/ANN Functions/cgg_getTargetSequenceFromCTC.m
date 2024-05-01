function [TargetSequence,TargetProbabilities_New] = cgg_getTargetSequenceFromCTC(TargetProbabilities,DimClassNames)
%CGG_GETTARGETSEQUENCEFROMCTC Summary of this function goes here
%   Detailed explanation goes here

BlankProbabilities=TargetProbabilities(end,:,:);
TargetProbabilities_New=TargetProbabilities(1:end-1,:,:);

Target_Decoded = squeeze(onehotdecode(TargetProbabilities,[DimClassNames;-1],1,'single'));
TargetSequence=Target_Decoded;

%%
% Sequences with all blank outputs are the first class
Target_Blank = TargetSequence==-1;
Target_AllBlank=all(Target_Blank,2);
TargetSequence(Target_AllBlank)=DimClassNames(1);

%%
% Sequences with the first value as blank should be the first non blank
% value to the right
Target_Blank = TargetSequence==-1;
Target_FirstBlank = Target_Blank(:,1);
Target_Shifted_Right=TargetSequence;

while any(Target_FirstBlank)

    Target_Shifted_Right=circshift(Target_Shifted_Right,-1,2);

    TargetSequence(Target_FirstBlank)=Target_Shifted_Right(Target_FirstBlank);

    Target_Blank = TargetSequence==-1;
    Target_FirstBlank = Target_Blank(:,1);
end

%%
% Sequences with blank values should be the value to the left.
Target_Blank = TargetSequence==-1;
Target_Shifted_Left=TargetSequence;

while any(Target_Blank,"all")

    Target_Shifted_Left=circshift(Target_Shifted_Left,1,2);

    TargetSequence(Target_Blank)=Target_Shifted_Left(Target_Blank);

    Target_Blank = TargetSequence==-1;
end

%%
% Assign the probability of the blank values to the corresponding new value
for cidx=1:length(DimClassNames)
    this_BlankIDX=TargetSequence==DimClassNames(cidx);

    this_TargetProbabilities_New=TargetProbabilities_New(cidx,this_BlankIDX);
    this_BlankProbabilities=BlankProbabilities(1,this_BlankIDX);

    this_TargetProbabilities_New=this_TargetProbabilities_New+this_BlankProbabilities;
    TargetProbabilities_New(cidx,this_BlankIDX)=this_TargetProbabilities_New;
end

TargetSequence=double(TargetSequence);
end

