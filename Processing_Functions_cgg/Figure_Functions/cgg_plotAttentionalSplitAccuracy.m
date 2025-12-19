function cgg_plotAttentionalSplitAccuracy(FullTable,cfg,varargin)
%CGG_PLOTATTENTIONALSPLITWINDOWEDACCURACY Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end

if isfunction
MaxSplits = CheckVararginPairs('MaxSplits', 30, varargin{:});
else
if ~(exist('MaxSplits','var'))
MaxSplits=30;
end
end

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
cfg.SplitExtraSaveTerm = cgg_setNaming(cfg.SplitExtraSaveTerm,'SurroundDeliminator',{'[',']'});

for seidx = 1:height(FullTable)

AttentionalTable=FullTable{seidx,"Attentional Table"}{1};

this_cfg = cfg;
this_cfg.MatchType=cfg.MatchType_Attention;
this_cfg.Subset = FullTable.Properties.RowNames{seidx};
this_cfg.LoopTitle = FullTable.Properties.RowNames{seidx};

MatchType = '';
% if strcmp(cfg.MatchType,'Scaled-BalancedAccuracy')
%     MatchType = '_BA';
% elseif strcmp(cfg.MatchType,'Scaled-MicroAccuracy')
%     MatchType = '_MA';
% end

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
% this_cfg.ExtraSaveTerm=[cfg.LoopType cfg.ExtraSaveTerm];
% this_cfg.LoopType = sprintf('Attentional_%s%s','All',MatchType);
this_cfg.ExtraSaveTerm='Attentional';
this_cfg.LoopType = sprintf('%s',MatchType);

cgg_plotOverallAccuracy(AttentionalTable,this_cfg,'cfg_OverwritePlot',cfg_OverwritePlot);

Split_Table=FullTable{seidx,cfg_Names.TableNameSplit_Table}{1};
SplitNames = Split_Table.Properties.RowNames;
NumSplits = length(SplitNames);

for sidx = 1:NumSplits
this_SplitName = SplitNames{sidx};
this_cfg.PlotTitle=this_SplitName;
this_cfg.LoopTitle = this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
this_SplitName = cgg_setNaming(this_SplitName,'SurroundDeliminator',{'(',')'});
% this_cfg.ExtraSaveTerm='Attentional';
this_cfg.ExtraSaveTerm=sprintf('Attentional%s',this_SplitName);
% this_cfg.LoopType=sprintf('%s%s',this_SplitName,MatchType);
this_cfg.LoopType=sprintf('%s',cfg.SplitExtraSaveTerm);
this_AttentionalTable=Split_Table{sidx,"Attentional Table"}{1};
% this_cfg.LoopTitle = this_SplitName;

[this_AttentionalTable] = cgg_getAttentionalPlotNames(this_AttentionalTable);

if sidx == 1
AttentionalNames = this_AttentionalTable.Properties.RowNames;
AttentionalTableSwapped = cell(1,length(AttentionalNames));
end

for aidx = 1:length(AttentionalNames)
    this_tmpTable = this_AttentionalTable(AttentionalNames{aidx},:);
    % this_tmpTable.Properties.RowNames{1} = this_SplitName;
    this_tmpTable.Properties.RowNames{1} = SplitNames{sidx};
    AttentionalTableSwapped{aidx} = [AttentionalTableSwapped{aidx};this_tmpTable];
end
if NumSplits<MaxSplits
cgg_plotOverallAccuracy(this_AttentionalTable,this_cfg,'IsAttentional',true,'cfg_OverwritePlot',cfg_OverwritePlot);
end
end

for aidx = 1:length(AttentionalTableSwapped)

this_SplitName = AttentionalNames{aidx};
this_cfg.PlotTitle=this_SplitName;
this_cfg.LoopTitle = this_SplitName;
this_SplitName = replace(this_SplitName,' ','-');
this_SplitName = replace(this_SplitName,'/','-');
this_SplitName = cgg_setNaming(this_SplitName,'SurroundDeliminator',{'{','}'});
this_cfg.ExtraSaveTerm=sprintf('Attentional%s',this_SplitName);
this_cfg.LoopType=sprintf('%s',cfg.SplitExtraSaveTerm);
% this_AttentionalTable=AttentionalTableSwapped{aidx};
this_AttentionalTable=AttentionalTable{aidx,"Split Table"}{1};

cgg_plotOverallAccuracy(this_AttentionalTable,this_cfg,'IsAttentional',true,'cfg_OverwritePlot',cfg_OverwritePlot);
end

end

end

