function Output = cgg_setRangeToNaN(Input,RangeType)
%CGG_SETRANGETONAN Summary of this function goes here
%   Detailed explanation goes here

Output = Input;

for eidx = 1:numel(Output)
switch RangeType
    case 'Positive'
        if Input(eidx) < 0 
            Output(eidx) = NaN;
        end
    case 'Negative'
        if Input(eidx) > 0 
            Output(eidx) = NaN;
        end
    otherwise
end
end


end

