function cfg = cgg_generateAnalysisFolders(EpochDir,varargin)
%CGG_GENERATEANALYSISFOLDERS Summary of this function goes here
%   Detailed explanation goes here

cfg=struct();

cfg.EpochDir.path=EpochDir;

AnalysisType = CheckVararginPairs('AnalysisType', '', varargin{:});
AnalysisTypeSubField = CheckVararginPairs('AnalysisTypeSubField', '', varargin{:});
Fold = CheckVararginPairs('Fold', '', varargin{:});
Session = CheckVararginPairs('Session', '', varargin{:});
%% Analysis Folder

% Make the Analysis folder name
cfg_tmp=cfg.EpochDir;
[cfg_tmp,~] = cgg_generateFolderAndPath('Analysis','Analysis',cfg_tmp);
cfg.EpochDir=cfg_tmp;

%%

if ~isempty(AnalysisType)
% Make the Analysis Type folder name
cfg_tmp=cfg.EpochDir.Analysis;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisType,'AnalysisType',cfg_tmp);
cfg.EpochDir.Analysis=cfg_tmp;

if ~isempty(AnalysisTypeSubField)
% Make the Analysis Type Sub Field folder name
cfg_tmp=cfg.EpochDir.Analysis.AnalysisType;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisTypeSubField,'AnalysisTypeSubField',cfg_tmp);
cfg.EpochDir.Analysis.AnalysisType=cfg_tmp;

if ~isempty(Fold)
% Make the Fold folder name
FoldName = sprintf('Fold %d',Fold);
cfg_tmp=cfg.EpochDir.Analysis.AnalysisType.AnalysisTypeSubField;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp);
cfg.EpochDir.Analysis.AnalysisType.AnalysisTypeSubField=cfg_tmp;

if ~isempty(Session)
% Make the Session folder name
cfg_tmp=cfg.EpochDir.Analysis.AnalysisType.AnalysisTypeSubField.Fold;
[cfg_tmp,~] = cgg_generateFolderAndPath(Session,'Session',cfg_tmp);
cfg.EpochDir.Analysis.AnalysisType.AnalysisTypeSubField.Fold=cfg_tmp;

end % End for whether to make the Session Folder
end % End for whether to make the Fold Folder
end % End for whether to make the Analysis Type Sub Field Folder

if ~isempty(Fold) && isempty(AnalysisTypeSubField)
% Make the Fold folder name
FoldName = sprintf('Fold %d',Fold);
cfg_tmp=cfg.EpochDir.Analysis.AnalysisType;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp);
cfg.EpochDir.Analysis.AnalysisType=cfg_tmp;

if ~isempty(Session)
% Make the Session folder name
cfg_tmp=cfg.EpochDir.Analysis.AnalysisType.Fold;
[cfg_tmp,~] = cgg_generateFolderAndPath(Session,'Session',cfg_tmp);
cfg.EpochDir.Analysis.AnalysisType.Fold=cfg_tmp;

end % End for whether to make the Session Folder
end % End for whether to make the Fold Folder
end % End for whether to make the Analysis Type Folder



end

