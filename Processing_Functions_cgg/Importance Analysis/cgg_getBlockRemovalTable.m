function RemovalTable = cgg_getBlockRemovalTable(NumChannels,NumAreas,LatentSize,BadChannelTable,RemovalType)
%CGG_GETBLOCKREMOVALTABLE Summary of this function goes here
%   Detailed explanation goes here

% %%
% NumChannels = 58;
% NumAreas = 6;
% LatentSize = 500;
% BadChannelTable = [];
% 
% %%
% RemovalType = 'Channel';

%%
NumRemoved = 'All';
MustIncludeTable = [];
NumEntries = 1;

RemovalTable_AllRemoved = cgg_makeRemovalTable(NumChannels,NumAreas,...
    LatentSize,BadChannelTable,'RemovalType',RemovalType,...
    'NumRemoved',NumRemoved,'NumEntries',NumEntries,...
    'MustIncludeTable',MustIncludeTable);
RemovalTable_AllRemoved = RemovalTable_AllRemoved(2,:);

%%
AreaNames = RemovalTable_AllRemoved.AreaNames{1};
LatentNames = RemovalTable_AllRemoved.LatentNames{1};
ChannelRemoved = RemovalTable_AllRemoved.ChannelRemoved{1};
AreaRemoved = RemovalTable_AllRemoved.AreaRemoved{1};
LatentRemoved = RemovalTable_AllRemoved.LatentRemoved{1};
%%
switch RemovalType
    case 'Channel'
        BlockNames_Unique = unique(AreaNames);
    case 'Latent'
        BlockNames_Unique = unique(LatentNames);
    otherwise
        BlockNames_Unique = unique(AreaNames);
end

% Initialize a cell array to store all combinations
NumUniqueNames = length(BlockNames_Unique);
NumCombinations = sum(arrayfun(@(x) nchoosek(NumUniqueNames, x),1:NumUniqueNames));
AllCombinations = cell(1,NumCombinations);
AllCombinations_Counter = 0;

% Iterate through all possible lengths (from 1 to the length of v)
for cidx = 1:length(BlockNames_Unique)
    % Get combinations of length k
    this_Combination = nchoosek(BlockNames_Unique, cidx);
    
    % Convert the matrix of combinations into a cell array of row vectors
    % This makes it easier to store combinations of different lengths
    for i = 1:size(this_Combination, 1)
        AllCombinations_Counter = AllCombinations_Counter + 1;
        AllCombinations{AllCombinations_Counter} = this_Combination(i, :); 
    end
end

NumCombinations = length(AllCombinations);
%%
ChannelRemovalIndices = cell(NumCombinations,1);
AreaRemovalIndices = cell(NumCombinations,1);
LatentRemovalIndices = cell(NumCombinations,1);
AreaRemovalNames = cell(NumCombinations,1);
LatentRemovalNames = cell(NumCombinations,1);
%%

for cidx = 1:length(AllCombinations)

switch RemovalType
    case 'Channel'
        Removal_Indices = ismember(AreaNames,AllCombinations{cidx});
    case 'Latent'
        Removal_Indices = ismember(LatentNames,AllCombinations{cidx});
    otherwise
        Removal_Indices = ismember(AreaNames,AllCombinations{cidx});
end

this_AreaRemovalIndices = AreaRemoved(Removal_Indices);
this_ChannelRemovalIndices = ChannelRemoved(Removal_Indices);
this_LatentRemovalIndices = LatentRemoved(Removal_Indices);
this_AreaNames = AreaNames(Removal_Indices);
this_LatentNames = LatentNames(Removal_Indices);

ChannelRemovalIndices(cidx) = num2cell(this_ChannelRemovalIndices,2);
AreaRemovalIndices(cidx) = num2cell(this_AreaRemovalIndices,2);
LatentRemovalIndices(cidx) = num2cell(this_LatentRemovalIndices,2);
AreaRemovalNames(cidx) = num2cell(this_AreaNames,2);
LatentRemovalNames(cidx) = num2cell(this_LatentNames,2);

% this_RemovalTable = table(AreaRemovalIndices,...
%     ChannelRemovalIndices,LatentRemovalIndices,this_AreaNames,'VariableNames',...
%     {'AreaRemoved','ChannelRemoved','LatentRemoved','AreaNames'});
% 
% RemovalTable = [RemovalTable;this_RemovalTable];
end

RemovalTable = table(AreaRemovalIndices,...
    ChannelRemovalIndices,LatentRemovalIndices,AreaRemovalNames,LatentRemovalNames,'VariableNames',...
    {'AreaRemoved','ChannelRemoved','LatentRemoved','AreaNames','LatentNames'});

