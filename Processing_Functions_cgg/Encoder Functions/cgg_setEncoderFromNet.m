function Encoder_Full_Ex = cgg_setEncoderFromNet(Encoder_Full_Ex,AutoEncoder_Cell)
%CGG_GENERATEAUTOENCODERFROMNET Summary of this function goes here
%   Detailed explanation goes here

NumStacks=numel(AutoEncoder_Cell);

Encoder_Full=Encoder_Full_Ex;

wb = getwb(Network);
[b,IW,LW] = separatewb(Network,wb);

wb=formwb(AutoEncoder,b,IW,LW);

AutoEncoder = setwb(AutoEncoder,wb);

end

