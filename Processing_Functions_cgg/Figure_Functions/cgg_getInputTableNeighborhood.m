function OutInputTable = cgg_getInputTableNeighborhood(InputTable,PlotInformation,varargin)
%CGG_GETINPUTTABLENEIGHBORHOOD Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NumIter = CheckVararginPairs('NumIter', '', varargin{:});
else
if ~(exist('NumIter','var'))
NumIter='';
end
end

%%
if isfield(PlotInformation,'NeighborhoodSize')
    if ~isempty(PlotInformation.NeighborhoodSize)
    NeighborhoodSize = PlotInformation.NeighborhoodSize;
    else
        NeighborhoodSize = NaN;
    end
else
    NeighborhoodSize = NaN;
end

if ~isnan(NeighborhoodSize)
ChannelNumbers = unique(InputTable.ChannelNumbers);

if isempty(NumIter)
    CenterChannelLoop = length(ChannelNumbers);
else
    CenterChannelLoop = NumIter;
end

OutInputTable = [];
for cidx = 1:CenterChannelLoop
    if isempty(NumIter)
        this_CenterChannel = ChannelNumbers(cidx);
    else
        this_CenterChannel = ChannelNumbers(randi(length(ChannelNumbers)));
    end

this_Neighborhood = (this_CenterChannel-NeighborhoodSize):(this_CenterChannel+NeighborhoodSize);
this_InputTable = ...
    groupfilter(InputTable,"AreaSessionName",...
    @(x) ismember(x,this_Neighborhood),"ChannelNumbers");
OutInputTable = [OutInputTable; this_InputTable];
end

else
OutInputTable = InputTable;
end

end

