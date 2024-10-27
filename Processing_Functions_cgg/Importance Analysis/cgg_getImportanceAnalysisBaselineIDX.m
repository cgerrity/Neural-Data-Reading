function Baseline_IDX = cgg_getImportanceAnalysisBaselineIDX(IA_Table, ...
    BaselineArea,BaselineChannel,BaselineLatent)
%CGG_GETIMPORTANCEANALYSISBASELINEIDX Summary of this function goes here
%   Detailed explanation goes here


if isnan(BaselineArea)
% BaselineAreaIDX = isnan(IA_Table.AreaRemoved);
BaselineAreaIDX = cellfun(@(x) all(isnan(x)),IA_Table.AreaRemoved);
else
% BaselineAreaIDX = all(IA_Table.AreaRemoved == BaselineArea,2);
BaselineAreaIDX = cellfun(@(x) all(x == BaselineArea),IA_Table.AreaRemoved);
end

if isnan(BaselineChannel)
% BaselineChannelIDX = isnan(IA_Table.ChannelRemoved);
BaselineChannelIDX = cellfun(@(x) all(isnan(x)),IA_Table.ChannelRemoved);
else
% BaselineChannelIDX = all(IA_Table.ChannelRemoved == BaselineChannel,2);
BaselineChannelIDX = cellfun(@(x) all(x == BaselineChannel),IA_Table.ChannelRemoved);
end

if isnan(BaselineLatent)
% BaselineLatentIDX = isnan(IA_Table.LatentRemoved);
BaselineLatentIDX = cellfun(@(x) all(isnan(x)),IA_Table.LatentRemoved);
else
% BaselineLatentIDX = all(IA_Table.LatentRemoved == BaselineLatent,2);
BaselineLatentIDX = cellfun(@(x) all(x == BaselineLatent),IA_Table.LatentRemoved);
end

Baseline_IDX = BaselineAreaIDX & BaselineChannelIDX & BaselineLatentIDX;
end

