function RemovalTable = cgg_makeRemovalTable(NumChannels,NumAreas,LatentSize,BadChannelTable,varargin)
%CGG_MAKEREMOVALTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
RemovalType = CheckVararginPairs('RemovalType', 'Channel', varargin{:});
else
if ~(exist('RemovalType','var'))
RemovalType='Channel';
end
end

if isfunction
NumRemoved = CheckVararginPairs('NumRemoved', 1, varargin{:});
else
if ~(exist('NumRemoved','var'))
NumRemoved=1;
end
end

if isfunction
NumEntries = CheckVararginPairs('NumEntries', 348, varargin{:});
else
if ~(exist('NumEntries','var'))
NumEntries=348;
end
end

if isfunction
MustIncludeTable = CheckVararginPairs('MustIncludeTable', [], varargin{:});
else
if ~(exist('MustIncludeTable','var'))
MustIncludeTable=[];
end
end

if isfunction
Probe_Areas = CheckVararginPairs('Probe_Areas', [], varargin{:});
else
if ~(exist('Probe_Areas','var'))
Probe_Areas=[];
end
end

if isfunction
LatentNames = CheckVararginPairs('LatentNames', [], varargin{:});
else
if ~(exist('LatentNames','var'))
LatentNames=[];
end
end

%%

ChannelIndices = 1:NumChannels;
AreaIndices = 1:NumAreas;
ChannelMustInclude = [];
AreaMustInclude = [];

ChannelTable = combinations(AreaIndices,ChannelIndices);
if ~isempty(BadChannelTable)
[~,BadChannelIndices,~] = intersect(ChannelTable,BadChannelTable);
ChannelTable(BadChannelIndices,:) = [];
end
if ~isempty(MustIncludeTable)
MustIncludeTable_Channel = MustIncludeTable(:,["ChannelIndices","AreaIndices"]);
[~,MustIncludeIndices,~] = intersect(ChannelTable,MustIncludeTable_Channel);
ChannelTable(MustIncludeIndices,:) = [];
ChannelMustInclude = MustIncludeTable_Channel.ChannelIndices;
AreaMustInclude = MustIncludeTable_Channel.AreaIndices;
ChannelMustInclude(isnan(ChannelMustInclude)) = [];
AreaMustInclude(isnan(AreaMustInclude)) = [];
end

%%

LatentIndices = 1:LatentSize;
LatentTable = combinations(LatentIndices);
LatentMustInclude = [];

if ~isempty(MustIncludeTable)
MustIncludeTable_Latent = MustIncludeTable(:,"LatentIndices");
[~,MustIncludeIndices,~] = intersect(LatentTable,MustIncludeTable_Latent);
LatentTable(MustIncludeIndices,:) = [];
LatentMustInclude = MustIncludeTable_Latent.LatentIndices;
LatentMustInclude(isnan(LatentMustInclude)) = [];
end
%% FIXME

if isempty(Probe_Areas)
cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2('');
Probe_Order=cfg_param.Probe_Order;
[Probe_Dimensions,Probe_Areas,~,~] = cgg_getProbeDimensions(Probe_Order);
Probe_Areas = Probe_Areas';
end

if isempty(LatentNames)
    LatentSplitIDX = round(LatentSize/2);
    LatentValues = [1;2];
    LatentRemovalNameIndices = [ones([1,LatentSplitIDX])*LatentValues(1),ones([1,LatentSplitIDX])*LatentValues(2)];
    LatentNames = {'Mean';'STD'};
    LatentRemovalNameIndices = LatentRemovalNameIndices(1:LatentSize);
end
%%

switch RemovalType
    case 'Channel'
        NumOptions = height(ChannelTable);
        % NumOptions = NumChannels*NumAreas;
        if NumRemoved > NumOptions
            RemovalTable = NaN;
            return
        elseif strcmp(NumRemoved,"All")
            NumRemoved = NumOptions;
        end
        RemovalIndices = cgg_getCombinations(1:NumOptions, NumRemoved, NumEntries);
        NumEntries = size(RemovalIndices,1);
        AllChannels = ChannelTable.ChannelIndices;
        AllAreas = ChannelTable.AreaIndices;
        ChannelRemovalIndices = AllChannels(RemovalIndices);
        AreaRemovalIndices = AllAreas(RemovalIndices);
        % [ChannelRemovalIndices,AreaRemovalIndices] = ind2sub([NumChannels,NumAreas],RemovalIndices);
        
        if NumEntries == 1
        AreaRemovalIndices = AreaRemovalIndices';
        ChannelRemovalIndices = ChannelRemovalIndices';
        end
        ChannelRemovalIndices = [repmat(ChannelMustInclude',[NumEntries,1]),ChannelRemovalIndices];
        AreaRemovalIndices = [repmat(AreaMustInclude',[NumEntries,1]),AreaRemovalIndices];
        NumRemoved = size(ChannelRemovalIndices,2);
        AreaNames = Probe_Areas(Probe_Dimensions(AreaRemovalIndices));
        if NumEntries == 1
        AreaNames = AreaNames';
        end
        LatentRemovalIndices = NaN(NumEntries,NumRemoved);
        LatentRemovalNames = repmat({'None'},[NumEntries,NumRemoved]);
    case 'Latent'
        NumOptions = height(LatentTable);
        if NumRemoved > NumOptions
            RemovalTable = NaN;
            return
        elseif strcmp(NumRemoved,"All")
            NumRemoved = NumOptions;
        end
        RemovalIndices = cgg_getCombinations(1:NumOptions, NumRemoved, NumEntries);
        NumEntries = size(RemovalIndices,1);
        AllLatent = LatentTable.LatentIndices;
        LatentRemovalIndices = AllLatent(RemovalIndices);

        if NumEntries == 1
        LatentRemovalIndices = LatentRemovalIndices';
        end
        LatentRemovalIndices = [repmat(LatentMustInclude',[NumEntries,1]),LatentRemovalIndices];
        NumRemoved = size(LatentRemovalIndices,2);
        LatentRemovalNames = LatentNames(LatentRemovalNameIndices(LatentRemovalIndices));

        if NumEntries == 1
        LatentRemovalNames = LatentRemovalNames';
        end

        ChannelRemovalIndices = NaN(NumEntries,NumRemoved);
        AreaRemovalIndices = NaN(NumEntries,NumRemoved);
        AreaNames = repmat({'None'},[NumEntries,NumRemoved]);
end


%%

ChannelRemovalIndices = num2cell(ChannelRemovalIndices,2);
AreaRemovalIndices = num2cell(AreaRemovalIndices,2);
LatentRemovalIndices = num2cell(LatentRemovalIndices,2);
AreaNames = num2cell(AreaNames,2);
LatentRemovalNames = num2cell(LatentRemovalNames,2);

%%

ChannelRemovalIndices = [{NaN(1,NumRemoved)};ChannelRemovalIndices];
AreaRemovalIndices = [{NaN(1,NumRemoved)};AreaRemovalIndices];
LatentRemovalIndices = [{NaN(1,NumRemoved)};LatentRemovalIndices];
AreaNames = [{repmat({'None'},[1,NumRemoved])};AreaNames];
LatentRemovalNames = [{repmat({'None'},[1,NumRemoved])};LatentRemovalNames];

%%

RemovalTable = table(AreaRemovalIndices,...
    ChannelRemovalIndices,LatentRemovalIndices,AreaNames,LatentRemovalNames,'VariableNames',...
    {'AreaRemoved','ChannelRemoved','LatentRemoved','AreaNames','LatentNames'});

end
