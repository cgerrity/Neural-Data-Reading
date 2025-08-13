function SetSweepNames = cgg_setSessionNamesForParameterSweep(SweepNames)
%CGG_SETSESSIONNAMESFORPARAMETERSWEEP Summary of this function goes here
%   Detailed explanation goes here

SetSweepNames = SweepNames;
%%
[cfg] = DATA_cggAllSessionInformationConfiguration;


AllSessionNames = replace({cfg.SessionName},'-','_');
AllMonkeyNames = {cfg.Monkey_Name};

[MonkeyNames,~,MonkeyNamesIDX] = unique(AllMonkeyNames);
for midx = 1:length(MonkeyNames)
    this_MonkeyName = MonkeyNames{midx};
    this_MonkeyNamesIDX = MonkeyNamesIDX == midx;
    this_MonkeySessionNumber = cumsum(this_MonkeyNamesIDX);
    this_MonkeySessionName = compose([this_MonkeyName(1:2) '-%d'],this_MonkeySessionNumber);
AllMonkeyNames(this_MonkeyNamesIDX) = this_MonkeySessionName(this_MonkeyNamesIDX);
end

%%



for sidx = 1:length(SetSweepNames)
this_SweepName = SetSweepNames(sidx);
this_IDX = contains(AllSessionNames,this_SweepName);
if any(this_IDX)
this_SetSweepName = AllMonkeyNames{this_IDX};
SetSweepNames(sidx) = this_SetSweepName;
end
end


end