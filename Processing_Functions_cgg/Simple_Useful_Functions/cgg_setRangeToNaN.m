function Output = cgg_setRangeToNaN(Input,RangeType)
%CGG_SETRANGETONAN Summary of this function goes here
%   Detailed explanation goes here

Output = Input;

switch RangeType
    case 'Positive'
        if Input < 0 
            Output = NaN;
        end
    case 'Negative'
        if Input > 0 
            Output = NaN;
        end
    otherwise
end


end

