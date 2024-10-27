function LPCategory = cgg_calcTrialsFromLPCategories(TrialsFromLP)
%CGG_CALCTRIALSFROMLPCATEGORIES Summary of this function goes here
%   Detailed explanation goes here

LPRanges = [-Inf,-5,0,10,20];


if isinf(TrialsFromLP)
    LPCategory = 1;
elseif TrialsFromLP < LPRanges(2)
     LPCategory = 2;
elseif TrialsFromLP < LPRanges(3)
     LPCategory = 3;
elseif TrialsFromLP < LPRanges(4)
     LPCategory = 4;
elseif TrialsFromLP < LPRanges(5)
     LPCategory = 5;
% elseif TrialsFromLP < LPRanges(6)
%      LPCategory = 6;
% elseif TrialsFromLP < LPRanges(7)
%      LPCategory = 7;
% elseif TrialsFromLP < LPRanges(8)
%      LPCategory = 8;
else
     LPCategory = 6;
end





end

