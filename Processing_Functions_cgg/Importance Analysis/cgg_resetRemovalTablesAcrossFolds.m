function TablesMatch = cgg_resetRemovalTablesAcrossFolds(cfg_Epoch, ...
    RemovalType,SessionName,SaveTerm,Folds)
%CGG_RESETREMOVALTABLESACROSSFOLDS Summary of this function goes here
%   Detailed explanation goes here
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');
IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
% IAPathNameExt = fullfile(cfg_Epoch.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IANameExt);
IAPathNameExt = fullfile(EpochDir_Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IANameExt);
[NewRemovalTable,TablesMatch] = cgg_checkRemovalTablesAcrossFolds(IAPathNameExt,Folds);
% fprintf('Tables Match %d (cgg_resetRemovalTablesAcrossFolds) \n',TablesMatch);
if ~TablesMatch
% cgg_saveRemovalTable(NewRemovalTable,Folds,cfg_Epoch.Results, ...
%     RemovalType,SessionName,SaveTerm,'ResetAnalysis',~TablesMatch);
cgg_saveRemovalTable(NewRemovalTable,Folds,EpochDir_Results, ...
    RemovalType,SessionName,SaveTerm,'ResetAnalysis',~TablesMatch);
fprintf('!!! Reseting analysis due to mismatched Removal Tables\n');
end

end

