function [TrialBinCell,TrialBinName] = cgg_calcTrialsFromLPMultipleCategories(Identifiers_Table)
%CGG_CALCTRIALSFROMLPMULTIPLECATEGORIES Summary of this function goes here
%   Detailed explanation goes here
%%
Start_Trial = -20;
End_Trial = 30;
Trial_Window = 10;

if isempty(Identifiers_Table)
    TrialsFromLP = [];
else
TrialsFromLP = Identifiers_Table.("Trials From Learning Point");
end
%%
Total_Bins = (End_Trial-Start_Trial + 1)-(Trial_Window - 1);
this_Range = NaN(Total_Bins,Trial_Window);

TrialBinName = cell(Total_Bins + 3,1);
% this_Counter = 0;
% for idx = Start_Trial:1:End_Trial
%     this_Counter = this_Counter + 1;
% this_Range(this_Counter,:) = idx:1:(idx + Trial_Window-1);
% end
for idx = 1:Total_Bins
    this_Start = (idx-1) + Start_Trial;
this_Range(idx,:) = (1:Trial_Window) - 1 + this_Start;

TrialBinName{idx+2} = sprintf("(%d) to (%d)",this_Range(idx,1),this_Range(idx,Trial_Window));
end

Total_Bins = Total_Bins + 3;
TrialBinName{1} = 'Not Learned';
TrialBinName{2} = sprintf("fewer than (%d)",Start_Trial);
TrialBinName{Total_Bins} = sprintf("more than (%d)",End_Trial);

TrialBin = false(length(TrialsFromLP),Total_Bins);

for idx = 1:Total_Bins
    if idx == 1
    this_TrialBin = isinf(TrialsFromLP);
    elseif idx == 2
    this_TrialBin = TrialsFromLP < Start_Trial & ~isinf(TrialsFromLP);
    elseif idx == Total_Bins
    this_TrialBin = TrialsFromLP > End_Trial;
    else
    this_TrialBin = ismember(TrialsFromLP,this_Range(idx-2,:));
    end
    TrialBin(:,idx) = this_TrialBin;
end

% plot(sum(TrialBin,1))
TrialBinCell = arrayfun(@(p) find(TrialBin(p,:)), (1:size(TrialBin,1))', 'UniformOutput', false);
end

