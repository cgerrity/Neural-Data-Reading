function Name = cgg_setNaming(Name)
%CGG_SETNAMING Summary of this function goes here
%   Detailed explanation goes here
if ~isempty(Name)
    Name = replace(Name,' ','-');
if startsWith(Name,'_')
    if ischar(Name)
    Name(1) = [];
    elseif isstring(Name)
    Name{1}(1) = [];
    end
end
    Name = replace(Name,'_','-');
    if ischar(Name)
    Name = ['_' Name];
    elseif isstring(Name)
    Name = "_" + Name;
    end
    
end

end

