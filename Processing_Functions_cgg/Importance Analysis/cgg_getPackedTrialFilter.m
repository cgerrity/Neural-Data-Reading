function [TrialFilter,TrialFilter_Value] = cgg_getPackedTrialFilter(TrialFilter,TrialFilter_Value,PackState)
%CGG_GETPACKEDTRIALFILTER Summary of this function goes here
%   Detailed explanation goes here

SplitPattern = " & ";

%%
switch PackState
    case 'Unpack'
        TrialFilter = string(TrialFilter);
        if contains(TrialFilter,SplitPattern)
            if size(TrialFilter,1) == 1
                TrialFilter = string(split(TrialFilter,SplitPattern))';
            else
                TrialFilter = string(split(TrialFilter,SplitPattern));
            end
        end
        if iscell(TrialFilter_Value)
            TrialFilter_Value = cell2mat(TrialFilter_Value);
        end
    case 'Pack'
        TrialFilter = string(TrialFilter);
        if contains(TrialFilter,SplitPattern)
            TrialFilter = string(TrialFilter);
        else
            TrialFilter = join(TrialFilter,SplitPattern);
        end
        if ~iscell(TrialFilter_Value)
            TrialFilter_Value = num2cell(TrialFilter_Value,2);
        end
end

