function LPCategory = cgg_calcTrialsFromLPCategories(TrialsFromLP,WantFine)
%CGG_CALCTRIALSFROMLPCATEGORIES Summary of this function goes here
%   Detailed explanation goes here

if WantFine
    LPRanges = [-Inf,-1000,-20,-15,-10,-5,-4,-3,-2,-1,0,1,2,3,4,5,6,7,8,9,10,12,15,18,20,30,Inf];
else
    LPRanges = [-Inf,-1000,-5,0,10,20,Inf];
end

% [aa,aaa,aaaa] = histcounts(TrialsFromLP,LPRanges);
[LPCategory,~] = discretize(TrialsFromLP,LPRanges);

% if isinf(TrialsFromLP)
%     LPCategory = 1;
% elseif TrialsFromLP < LPRanges(2)
%      LPCategory = 2;
% elseif TrialsFromLP < LPRanges(3)
%      LPCategory = 3;
% elseif TrialsFromLP < LPRanges(4)
%      LPCategory = 4;
% elseif TrialsFromLP < LPRanges(5)
%      LPCategory = 5;
% % elseif TrialsFromLP < LPRanges(6)
% %      LPCategory = 6;
% % elseif TrialsFromLP < LPRanges(7)
% %      LPCategory = 7;
% % elseif TrialsFromLP < LPRanges(8)
% %      LPCategory = 8;
% else
%      LPCategory = 6;
% end





end

