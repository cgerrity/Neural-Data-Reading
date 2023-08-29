function [rectrialdefs_corrected,BadTrials] = cgg_procIdentifyBadTrialNumbers(rectrialdefs)
%CGG_PROCIDENTIFYBADTRIALNUMBERS Summary of this function goes here
%   Detailed explanation goes here

%%
% Every Trial has a unique Trial Index, but Trial Number only increments
% after a valid trial. Trial Index >= TrialNumber under valid number
% scheme.
TrialNumber=rectrialdefs(:,7);
TrialIndex=rectrialdefs(:,8);

% The Difference should always be monotonically non-decreasing
TrialDifference=abs(TrialIndex-TrialNumber);

% plot(TrialDifference)

%%

Monotonic_Array=TrialDifference;

Continue_Removal=true;

IDX_logical_Aggregate=false(size(Monotonic_Array));

while Continue_Removal

Difference_Array=[diff(Monotonic_Array);0];

IDX_logical=Difference_Array < 0;
IDX_logical_plus_1=circshift(IDX_logical,1);

Monotonic_Array_tmp=Monotonic_Array;
Monotonic_Array_tmp(IDX_logical)=Monotonic_Array(IDX_logical_plus_1);

Monotonic_Array=Monotonic_Array_tmp;

IDX_logical_Aggregate=IDX_logical_Aggregate | IDX_logical;

Continue_Removal=any(IDX_logical);

end

BadTrials=IDX_logical_Aggregate;
rectrialdefs_corrected=rectrialdefs(BadTrials,:);

end

