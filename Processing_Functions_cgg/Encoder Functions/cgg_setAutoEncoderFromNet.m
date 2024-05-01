function AutoEncoder = cgg_setAutoEncoderFromNet(AutoEncoder_Stack,Network)
%CGG_GENERATEAUTOENCODERFROMNET Summary of this function goes here
%   Detailed explanation goes here

AutoEncoder=AutoEncoder_Stack;

wb = getwb(Network);
[b,IW,LW] = separatewb(Network,wb);

wb=formwb(AutoEncoder,b,IW,LW);

AutoEncoder = setwb(AutoEncoder,wb);

end

