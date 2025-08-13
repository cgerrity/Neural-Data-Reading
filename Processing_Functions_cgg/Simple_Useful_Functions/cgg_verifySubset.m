function [Subset,wantSubset] = cgg_verifySubset(Subset,wantSubset)
%CGG_VERIFYSUBSET Summary of this function goes here
%   Detailed explanation goes here

if ~isempty(Subset)
    if islogical(Subset)
        wantSubset = Subset;
    elseif strcmp(Subset,'All')
        wantSubset = false;
    elseif strcmp(Subset,'true')
        Subset = true;
    elseif strcmp(Subset,'Subset')
        Subset = true;
    else
        wantSubset = true;
    end
else
    Subset = wantSubset;
end

end

