function RemovalTable = cgg_getRemovalTableFromRanking(IA_Table,varargin)
%CGG_GETREMOVALTABLEFROMRANKING Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
BaselineArea = CheckVararginPairs('BaselineArea', NaN, varargin{:});
else
if ~(exist('BaselineArea','var'))
BaselineArea=NaN;
end
end

if isfunction
BaselineChannel = CheckVararginPairs('BaselineChannel', NaN, varargin{:});
else
if ~(exist('BaselineChannel','var'))
BaselineChannel=NaN;
end
end

if isfunction
BaselineLatent = CheckVararginPairs('BaselineLatent', NaN, varargin{:});
else
if ~(exist('BaselineLatent','var'))
BaselineLatent=NaN;
end
end

%%

Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(IA_Table, ...
    BaselineArea,BaselineChannel,BaselineLatent);
RemovalTable_Baseline = IA_Table(Baseline_IDX,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);

IA_Table(Baseline_IDX,:) = [];

ChannelRemoval = IA_Table.ChannelRemoved;
AreaRemoval = IA_Table.AreaRemoved;
LatentRemoval = IA_Table.LatentRemoved;
AreaNames = IA_Table.AreaNames;

%%
RemovalTable = IA_Table(1,["AreaRemoved","ChannelRemoved","LatentRemoved","AreaNames"]);

for hidx = 2:height(IA_Table)

    this_ChannelRemoval = ChannelRemoval(1:hidx,:)';
    this_AreaRemoval = AreaRemoval(1:hidx,:)';
    this_LatentRemoval = LatentRemoval(1:hidx,:)';
    
    this_ChannelRemoval = {[this_ChannelRemoval{:}]};
    this_AreaRemoval = {[this_AreaRemoval{:}]};
    this_LatentRemoval = {[this_LatentRemoval{:}]};
    this_AreaNames = {AreaNames(1:hidx,:)'};

    this_Removal = table(this_AreaRemoval,this_ChannelRemoval, ...
        this_LatentRemoval,this_AreaNames, ...
        'VariableNames',["AreaRemoved","ChannelRemoved", ...
        "LatentRemoved","AreaNames"]);

    RemovalTable = [RemovalTable;this_Removal];

end

RemovalTable = [RemovalTable_Baseline;RemovalTable];

end

