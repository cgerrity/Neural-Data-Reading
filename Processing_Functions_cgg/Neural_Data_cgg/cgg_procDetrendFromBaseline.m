function [Detrend_Data,Detrend_Baseline] = cgg_procDetrendFromBaseline(InData,InBaseline,TrialNumbers)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
Detrend_Data=NaN(size(InData));
Detrend_Baseline=NaN(size(InBaseline));

[NumChannels,~,~]=size(InBaseline);

if verLessThan('matlab','9.5')
Mean_Baseline=squeeze(mean(InBaseline(:,:,:),2));
STD_Baseline=squeeze(std(InBaseline(:,:,:),0,2));
else
Mean_Baseline=squeeze(mean(InBaseline,2));
STD_Baseline=squeeze(std(InBaseline,0,2));
end

for cidx=1:NumChannels
sel_channel=cidx;
this_Baseline_Mean=Mean_Baseline(sel_channel,:);

this_y=[];
this_x=[];

this_y=diag(diag(this_Baseline_Mean));
this_x=diag(diag(TrialNumbers)); % 1:NumTrials or use TrialNumbers_Baseline
this_x=[this_x,ones(size(this_x))];

[this_Coefficients,~,~,~,~] = regress(this_y,this_x);

this_Baseline_Fit=this_x*this_Coefficients;

for tidx=1:length(TrialNumbers)
Detrend_Baseline(sel_channel,:,tidx)=InBaseline(sel_channel,:,tidx)-this_Baseline_Fit(tidx);
Detrend_Data(sel_channel,:,tidx)=InData(sel_channel,:,tidx)-this_Baseline_Fit(tidx);
end
end

end

