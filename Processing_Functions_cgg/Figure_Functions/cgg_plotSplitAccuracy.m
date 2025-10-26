function cgg_plotSplitAccuracy(FullTable,cfg)
%CGG_PLOTSPLITACCURACY Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;
cfg.LoopType = cgg_setNaming(cfg.LoopType);
% cfg.LoopNames{1} = cgg_setNaming(cfg.LoopNames{1});
cfg.ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);
cfg.SplitExtraSaveTerm = cgg_setNaming(cfg.SplitExtraSaveTerm,'SurroundDeliminator',{'[',']'});

for sidx = 1:height(FullTable)
Split_Table=FullTable{sidx,cfg_Names.TableNameSplit_Table}{1};

this_cfg = cfg;

% cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
% this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.LoopNames{1} this_cfg.ExtraSaveTerm];
this_cfg.ExtraSaveTerm=[this_cfg.LoopType this_cfg.ExtraSaveTerm];
this_cfg.LoopType=cfg.SplitExtraSaveTerm;
this_cfg.Subset = FullTable.Properties.RowNames{sidx};
this_cfg.LoopTitle = FullTable.Properties.RowNames{sidx};

cgg_plotOverallAccuracy(Split_Table,this_cfg);
end

%%

% cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
%     'Epoch',cfg.Epoch,'Accuracy',true);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
%     'Epoch',cfg.Epoch,'Accuracy',true);
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',Subset);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',Subset);
% cfg_Plot.ResultsDir=cfg_tmp.TargetDir;
% 
% SavePath = cgg_getDirectory(cfg_Plot.ResultsDir,'PlotSubFolder_1');
% 
% % SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
% SaveName=['Accuracy_Over_Iterations' cfg.ExtraSaveTerm '_Type_' cfg.LoopType];
% 
% SaveNameExt=[SaveName '.pdf'];
% 
% SavePathNameExt=[SavePath filesep SaveNameExt];
% 
% delete(SavePathNameExt);

end