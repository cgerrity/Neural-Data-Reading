function CoderBlocks = cgg_constructSimpleCoder(HiddenSize,varargin)
%CGG_CONSTRUCTSIMPLECODER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Coder = CheckVararginPairs('Coder', 'Encoder', varargin{:});
else
if ~(exist('Coder','var'))
Coder='Encoder';
end
end

NumLevels = length(HiddenSize);

CoderBlocks = [];

for lidx = 1:NumLevels
    this_Level = lidx;
    switch Coder
        case 'BottleNeck'
            if NumLevels == 1
                this_Level = NaN;
            end
    end
    
this_CoderBlock = cgg_generateSimpleBlock(HiddenSize(lidx),this_Level,varargin{:});

switch Coder
    case 'Decoder'
        CoderBlocks = [this_CoderBlock
                 CoderBlocks];
    otherwise
        CoderBlocks = [CoderBlocks
                         this_CoderBlock];
end

end

end

