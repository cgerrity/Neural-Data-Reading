function [PermuteDimensions,ReshapeSize] = cgg_getPCALayerInformation(X,varargin)
%CGG_GETPCALAYERINFORMATION Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantPerTime = CheckVararginPairs('WantPerTime', true, varargin{:});
else
if ~(exist('WantPerTime','var'))
WantPerTime=true;
end
end

% if isfunction
% SelectTime = CheckVararginPairs('SelectTime', 1, varargin{:});
% else
% if ~(exist('SelectTime','var'))
% SelectTime=1;
% end
% end

FormatInformation = cgg_getDataFormatInformation(X);

T = FormatInformation.Size.Time;
B = FormatInformation.Size.Batch;
S = prod(FormatInformation.Size.Spatial);
C = FormatInformation.Size.Channel;

% Indices = repmat({':'}, 1, length(size(X)));

if WantPerTime
    PermuteDimensions = [FormatInformation.Dimension.Batch,...
                         FormatInformation.Dimension.Spatial,...
                         FormatInformation.Dimension.Channel,...
                         FormatInformation.Dimension.Time];
    ReshapeSize = [B, S*C];
    % Indices{FormatInformation.Dimension.Time} = SelectTime;
else
    PermuteDimensions = [FormatInformation.Dimension.Batch,...
                         FormatInformation.Dimension.Time,...
                         FormatInformation.Dimension.Spatial,...
                         FormatInformation.Dimension.Channel];
    ReshapeSize = [B*T, S*C];

end

% permutedData = permute(X, PermuteDimensions);
% reshapedData = reshape(permutedData, ReshapeSize);
end

