function is_rereferenced = cgg_checkFTRereference(InFTData)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

is_rereferenced=false;
is_last=false;

this_cfg=InFTData.cfg;

while ne(is_last,true)
    if isequal(this_cfg.reref,'yes')
        is_rereferenced=true;
    end
    this_cfg=this_cfg.previous;
    is_last=~isstruct(this_cfg);
end
end

