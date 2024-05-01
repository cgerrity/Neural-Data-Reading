function ExtraSaveTerm = cgg_generateExtraSaveTerm(varargin)
%CGG_GENERATEEXTRASAVETERM Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantSubset = CheckVararginPairs('wantSubset', false, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
end
end

if isfunction
wantZeroFeatureDetector = CheckVararginPairs('wantZeroFeatureDetector', false, varargin{:});
else
if ~(exist('wantZeroFeatureDetector','var'))
wantZeroFeatureDetector=false;
end
end

if isfunction
ARModelOrder = CheckVararginPairs('ARModelOrder', '', varargin{:});
else
if ~(exist('ARModelOrder','var'))
ARModelOrder='';
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', '', varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth='';
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', '', varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride='';
end
end

if isfunction
Decoders = CheckVararginPairs('Decoders', '', varargin{:});
else
if ~(exist('Decoders','var'))
Decoders='';
end
end

if isfunction
FilterColumn = CheckVararginPairs('FilterColumn', '', varargin{:});
else
if ~(exist('FilterColumn','var'))
FilterColumn='';
end
end

%% Parameters
cfg_NameParameters = NAMEPARAMETERS_cgg_nameVariables;

ExtraSaveTermDecoders=cfg_NameParameters.ExtraSaveTermDecoders;

ExtraSaveTermSubset=cfg_NameParameters.ExtraSaveTermSubset;
ExtraSaveTermZeroFeature=cfg_NameParameters.ExtraSaveTermZeroFeature;
ExtraSaveTermAR=cfg_NameParameters.ExtraSaveTermAR;

ExtraSaveTermWindowStride=cfg_NameParameters.ExtraSaveTermWindowStride;
ExtraSaveTermDataWidth=cfg_NameParameters.ExtraSaveTermDataWidth;

ExtraSaveTermFilterColumn=cfg_NameParameters.ExtraSaveTermFilterColumn;

%%
if iscell(Decoders)
    NumDecoders=length(Decoders);
    if NumDecoders==1
        Decoders=Decoders{1};
    end
else
    NumDecoders=1;
end

%%
ExtraSaveTerm='';

if ~isempty(Decoders) && ~(NumDecoders>1)
ExtraSaveTerm=[ExtraSaveTerm '_' sprintf(ExtraSaveTermDecoders,Decoders)];
end
if ~isempty(WindowStride) && ~(length(WindowStride)>1)
ExtraSaveTerm=[ExtraSaveTerm '_' sprintf(ExtraSaveTermWindowStride,WindowStride)];
end
if ~isempty(DataWidth) && ~(length(DataWidth)>1)
ExtraSaveTerm=[ExtraSaveTerm '_' sprintf(ExtraSaveTermDataWidth,DataWidth)];
end
if wantSubset && ~(length(wantSubset)>1)
ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermSubset];
end
if wantZeroFeatureDetector && ~(length(wantZeroFeatureDetector)>1)
ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermZeroFeature];
end
if ~isempty(ARModelOrder) && ~(length(ARModelOrder)>1)
ExtraSaveTerm=[ExtraSaveTerm '_' sprintf(ExtraSaveTermAR,ARModelOrder)];
% ExtraSaveTerm=[ExtraSaveTerm '_' 'AR'];
end
if ~isempty(FilterColumn)
ExtraSaveTerm=[ExtraSaveTerm '_' ExtraSaveTermFilterColumn ...
    sprintf('_%s',string(FilterColumn))];
end

end

