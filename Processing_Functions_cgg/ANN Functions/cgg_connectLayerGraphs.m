function LG_Connected = cgg_connectLayerGraphs(LG_1,LG_2,varargin)
%CGG_CONNECTLAYERGRAPHS Summary of this function goes here
%   Detailed explanation goes here

SourceHint = CheckVararginPairs('SourceHint', '', varargin{:});
DestinationHint = CheckVararginPairs('DestinationHint', '', varargin{:});

LG_Connected = cgg_combineLayerGraphs(LG_1,LG_2);

[~,Source,~,~] = cgg_identifyUnconnectedLayers(LG_1);
[Destination,~,~,~] = cgg_identifyUnconnectedLayers(LG_2);

SourceIDX = find(contains(Source,SourceHint));
DestinationIDX = find(contains(Destination,DestinationHint));

if isempty(SourceIDX)
    SourceIDX = 1;
else
    SourceIDX = SourceIDX(1);
end
if isempty(DestinationIDX)
    DestinationIDX = 1;
else
    DestinationIDX = DestinationIDX(1);
end

% [~,Source] = cgg_identifyUnconnectedLayers(LG_1);
% [Destination,~] = cgg_identifyUnconnectedLayers(LG_2);

% Source = [Source{1} '/out'];
% Destination = [Destination{1} '/in'];

Source = Source{SourceIDX};
Destination = Destination{DestinationIDX};

LG_Connected = connectLayers(LG_Connected,Source,Destination);

end

