function DebugCounter = cgg_displayDebugMessage(WantDebugDisplay,DebugCounter)
%CGG_DISPLAYDEBUGMESSAGE Summary of this function goes here
%   Detailed explanation goes here

if WantDebugDisplay
fprintf('??? Debug Statement #%d\n',DebugCounter);
DebugCounter = DebugCounter + 1;
end
end

