function cgg_plotLabelClassAccuracy(FullTable,cfg,varargin)
%CGG_PLOTLABELCLASSACCURACY Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
IsAttentional = CheckVararginPairs('IsAttentional', false, varargin{:});
else
if ~(exist('IsAttentional','var'))
IsAttentional=false;
end
end

if isfunction
SubsetName = CheckVararginPairs('SubsetName', '', varargin{:});
else
if ~(exist('SubsetName','var'))
SubsetName='';
end
end

if isfunction
WantSameSessionNumbers = CheckVararginPairs('WantSameSessionNumbers', true, varargin{:});
else
if ~(exist('WantSameSessionNumbers','var'))
WantSameSessionNumbers=true;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end

cfg.LoopType = cgg_setNaming(cfg.LoopType);
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);

%%
SessionNumbers = [];
if WantSameSessionNumbers && any(ismember(FullTable.Properties.VariableNames,"Session Number"))
SessionNumbers = FullTable.("Session Number"){1};
end

%%

for sidx = 1:height(FullTable)

if isfield(cfg,'PlotTitle')
    cfg.LoopTitle = cfg.PlotTitle;
else
    cfg.LoopTitle = FullTable.Properties.RowNames{sidx};
end
    %% Labels
LabelTable=FullTable{sidx,"Label Table"}{1};
if ~isempty(SessionNumbers)
LabelTable.("Session Number") = repmat({SessionNumbers},[height(LabelTable),1]);
end
this_cfg = cfg;
this_cfg.IA_Type = '<Labels>';

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Labels",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end

cgg_plotOverallAccuracy(LabelTable,this_cfg,'IsLabelClass','Label','IsAttentional',IsAttentional,'cfg_OverwritePlot',cfg_OverwritePlot);

    %% Class
ClassTable=FullTable{sidx,"Class Table"}{1};

LineStyleIDX = contains(ClassTable.Properties.RowNames,"Class 0");
LineStyle = strings(height(ClassTable),1);
LineStyle(LineStyleIDX) = ":";
this_cfg_OverwritePlot = cfg_OverwritePlot;
this_cfg_OverwritePlot.LineStyle = LineStyle;

if ~isempty(SessionNumbers)
ClassTable.("Session Number") = repmat({SessionNumbers},[height(ClassTable),1]);
end
this_cfg = cfg;
this_cfg.IA_Type = '<Classes>';

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming("Classes",'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end

cgg_plotOverallAccuracy(ClassTable,this_cfg,'IsLabelClass','Class','IsAttentional',IsAttentional,'cfg_OverwritePlot',this_cfg_OverwritePlot);

    %% Class Per Label
    LabelNames = LabelTable.Properties.RowNames;
    NumLabels = length(LabelNames);
    for lidx = 1:NumLabels
    LabelName = LabelNames{lidx};
this_ClassTable=ClassTable(contains(ClassTable.Properties.RowNames,LabelName),:);
this_ClassNames = this_ClassTable.Properties.RowNames;
this_ClassNames = extractAfter(this_ClassNames,sprintf("%s ~ ",LabelName));
this_ClassTable.Properties.RowNames = this_ClassNames;

LineStyleIDX = contains(this_ClassTable.Properties.RowNames,"Class 0");
LineStyle = strings(height(this_ClassTable),1);
LineStyle(LineStyleIDX) = ":";
this_cfg_OverwritePlot = cfg_OverwritePlot;
this_cfg_OverwritePlot.LineStyle = LineStyle;

if ~isempty(SessionNumbers)
this_ClassTable.("Session Number") = repmat({SessionNumbers},[height(this_ClassTable),1]);
end
this_cfg = cfg;
this_cfg.IA_Type = sprintf('<%s Classes>',LabelName);

this_cfg.ExtraSaveTerm = string(this_cfg.LoopType) + string(this_cfg.ExtraSaveTerm);
this_cfg.LoopType = cgg_setNaming(sprintf("%s-Classes",LabelName),'SurroundDeliminator',{'<','>'});
if isempty(SubsetName)
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
else
this_cfg.Subset = SubsetName;
end

cgg_plotOverallAccuracy(this_ClassTable,this_cfg,'IsLabelClass','Class','IsAttentional',IsAttentional,'cfg_OverwritePlot',this_cfg_OverwritePlot);
    end
end

end

