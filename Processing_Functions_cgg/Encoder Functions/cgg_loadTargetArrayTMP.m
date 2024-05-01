function Target = cgg_loadTargetArrayTMP(FileName,ClassNames)
%CGG_LOADTARGETARRAYTMP Summary of this function goes here
%   Detailed explanation goes here
Target=load(FileName);
Target=Target.Target;

Target = onehotencode(Target,1,'ClassNames',ClassNames);

end

