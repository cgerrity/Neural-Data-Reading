function [Detrend_Data,Detrend_Baseline] = cgg_procDetrendFromBaseline(InData,InBaseline,TrialNumbers_Data,TrialNumbers_Baseline)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

IsCell_Data=iscell(InData);
IsCell_Baseline=iscell(InBaseline);

if IsCell_Baseline
    Mean_Baseline=cell2mat((cellfun(@(x) mean(x,2),InBaseline,'UniformOutput',false))');
    STD_Baseline=cell2mat((cellfun(@(x) std(x,0,2),InBaseline,'UniformOutput',false))');
    
    [NumChannels,~]=size(Mean_Baseline);
    
    Detrend_Data=cell(size(InData));
    Detrend_Baseline=cell(size(InBaseline));
else
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
end

this_x=diag(diag(TrialNumbers_Baseline)); % 1:NumTrials or use TrialNumbers_Baseline
this_x=[this_x,ones(size(this_x))];

for cidx=1:NumChannels
sel_channel=cidx;
this_Baseline_Mean=Mean_Baseline(sel_channel,:);

this_y=diag(diag(this_Baseline_Mean));

[this_Coefficients,~,~,~,~] = regress(this_y,this_x);

this_Baseline_Fit=this_x*this_Coefficients;

for tidx=1:length(TrialNumbers_Baseline)
    if IsCell_Baseline
        Detrend_Baseline{tidx}(sel_channel,:)=InBaseline{tidx}(sel_channel,:)-this_Baseline_Fit(tidx);
    else
        Detrend_Baseline(sel_channel,:,tidx)=InBaseline(sel_channel,:,tidx)-this_Baseline_Fit(tidx);
    end
end

for tidx=1:length(TrialNumbers_Data)
        this_TrialNumberData=TrialNumbers_Data(tidx);
        this_Baseline_Fit = [this_TrialNumberData,1]*this_Coefficients;
    if IsCell_Data
        Detrend_Data{tidx}(sel_channel,:)=InData{tidx}(sel_channel,:)-this_Baseline_Fit;
    else
        Detrend_Data(sel_channel,:,tidx)=InData(sel_channel,:,tidx)-this_Baseline_Fit;
    end  
end

end

end

