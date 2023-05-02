function [Mean_Norm_InData,Mean_Norm_InBaseline,...
    STD_ERROR_Norm_InData,STD_ERROR_Norm_InBaseline,Norm_InData,...
    Norm_InBaseline] = cgg_procTrialNormalization_v2(InData,...
    InBaseline,FullBaseline)
%CGG_PROCTRIALNORMALIZATION Summary of this function goes here
%   Detailed explanation goes here


% [NumChannels,NumSamples,Trial_Counter]=size(InData);
[~,~,Trial_Counter]=size(InData);

if verLessThan('matlab','9.5')
Mean_FullBaseline=mean(FullBaseline(:,:),2);
STD_FullBaseline=std(FullBaseline(:,:),0,2);
else
Mean_FullBaseline=mean(FullBaseline,[2 3]);
STD_FullBaseline=std(FullBaseline,0,[2 3]);
end

if all(STD_FullBaseline==0)
Norm_InData=(InData-Mean_FullBaseline);
Norm_InBaseline=(InBaseline-Mean_FullBaseline);
else
Norm_InData=(InData-Mean_FullBaseline)./STD_FullBaseline;
Norm_InBaseline=(InBaseline-Mean_FullBaseline)./STD_FullBaseline;
end

Mean_Norm_InData=mean(Norm_InData,3);
Mean_Norm_InBaseline=mean(Norm_InBaseline,3);

STD_ERROR_Norm_InData=std(Norm_InData,0,3)/sqrt(Trial_Counter);
STD_ERROR_Norm_InBaseline=std(InBaseline,0,3)/sqrt(Trial_Counter);

end

