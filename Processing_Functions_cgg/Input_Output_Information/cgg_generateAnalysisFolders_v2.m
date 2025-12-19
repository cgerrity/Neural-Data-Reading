function cfg = cgg_generateAnalysisFolders_v2(EpochDir,varargin)
%CGG_GENERATEANALYSISFOLDERS Summary of this function goes here
%   Detailed explanation goes here

cfg=struct();

cfg.Epoch.path=EpochDir;

AnalysisType = CheckVararginPairs('AnalysisType', '', varargin{:});

AnalysisTypeSubField = CheckVararginPairs('AnalysisTypeSubField', '', varargin{:}); % e.g. 'Importance Analysis'
Fold = CheckVararginPairs('Fold', '', varargin{:});
Session = CheckVararginPairs('Session', '', varargin{:});
AnalysisTypeSubSubField = CheckVararginPairs('AnalysisTypeSubSubField', '', varargin{:});
WantDirectory = CheckVararginPairs('WantDirectory', true, varargin{:});

%%


%% Analysis Folder

% Make the Analysis folder name
cfg_tmp=cfg.Epoch;
[cfg_tmp,~] = cgg_generateFolderAndPath('Analysis','Analysis',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch=cfg_tmp;

%%

if ~isempty(AnalysisType)
% Make the Analysis Type folder name
cfg_tmp=cfg.Epoch.Analysis;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisType,'AnalysisType',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis=cfg_tmp;

if ~isempty(AnalysisTypeSubField)
% Make the Analysis Type Sub Field folder name
cfg_tmp=cfg.Epoch.Analysis.AnalysisType;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisTypeSubField,'AnalysisTypeSubField',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType=cfg_tmp;

if ~isempty(Session)
% Make the Session folder name
cfg_tmp=cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField;
[cfg_tmp,~] = cgg_generateFolderAndPath(Session,'Session',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField=cfg_tmp;

if ~isempty(AnalysisTypeSubSubField)
% Make the Analysis Type Sub Field folder name
cfg_tmp=cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisTypeSubSubField,'AnalysisTypeSubSubField',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField.Session=cfg_tmp;

if ~isempty(Fold)
% Make the Fold folder name
FoldName = sprintf('Fold %d',Fold);
cfg_tmp=cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField.Session.AnalysisTypeSubSubField;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField.Session.AnalysisTypeSubSubField=cfg_tmp;

end % End for whether to make the Fold Folder
end % End for whether to make the Analysis Type Sub Sub Field Folder
else
if ~isempty(AnalysisTypeSubSubField)
% Make the Analysis Type Sub Field folder name
cfg_tmp=cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField;
[cfg_tmp,~] = cgg_generateFolderAndPath(AnalysisTypeSubSubField,'AnalysisTypeSubSubField',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType.AnalysisTypeSubField=cfg_tmp;
end % End for whether to make the Analysis Type Sub Sub Field Folder
end % End for whether to make the Session Folder
end % End for whether to make the Analysis Type Sub Field Folder

if ~isempty(Session) && isempty(AnalysisTypeSubField)
% Make the Session folder name
cfg_tmp=cfg.Epoch.Analysis.AnalysisType;
[cfg_tmp,~] = cgg_generateFolderAndPath(Session,'Session',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType=cfg_tmp;

if ~isempty(Fold)
% Make the Fold folder name
FoldName = sprintf('Fold %d',Fold);
cfg_tmp=cfg.Epoch.Analysis.AnalysisType.Session;
[cfg_tmp,~] = cgg_generateFolderAndPath(FoldName,'Fold',cfg_tmp,'WantDirectory',WantDirectory);
cfg.Epoch.Analysis.AnalysisType.Session=cfg_tmp;

end % End for whether to make the Fold Folder
end % End for whether to make the Session Folder
end % End for whether to make the Analysis Type Folder



end

