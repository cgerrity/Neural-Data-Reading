function CoderBlock_Name = cgg_generateCoderBlockName(Coder,AreaIDX,FilterNumber,Level)
%CGG_GENERATECODERBLOCKNAME Summary of this function goes here
%   Detailed explanation goes here
CoderBlock_Name = sprintf("_%s",Coder);

if ~isnan(AreaIDX)
    CoderBlock_Name = sprintf("%s_Area-%d",CoderBlock_Name,AreaIDX);
end

if ~isnan(FilterNumber)
    CoderBlock_Name = sprintf("%s_Filter-%d",CoderBlock_Name,FilterNumber);
end

if ~isnan(Level)
    CoderBlock_Name = sprintf("%s_Layer-%d",CoderBlock_Name,Level);
end
end

