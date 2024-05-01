function cgg_plotSplitAccuracy(FullTable,cfg)
%CGG_PLOTSPLITACCURACY Summary of this function goes here
%   Detailed explanation goes here

cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Split_Table=FullTable{1,cfg_Names.TableNameSplit_Table}{1};

cfg.ExtraSaveTerm=['_' cfg.LoopType '_' cfg.LoopNames{1} cfg.ExtraSaveTerm];
cfg.LoopType=[cfg.SplitExtraSaveTerm];

cgg_plotOverallAccuracy(Split_Table,cfg);

%%

cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'Accuracy',true);
cfg_Plot.ResultsDir=cfg_tmp.TargetDir;

SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
SaveName=['Accuracy_Over_Iterations' cfg.ExtraSaveTerm '_Type_' cfg.LoopType];

SaveNameExt=[SaveName '.pdf'];

SavePathNameExt=[SavePath filesep SaveNameExt];

delete(SavePathNameExt);

end