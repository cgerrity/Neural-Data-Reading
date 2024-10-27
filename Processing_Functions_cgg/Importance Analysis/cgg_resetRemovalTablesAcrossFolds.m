function TablesMatch = cgg_resetRemovalTablesAcrossFolds(EpochDir, ...
    RemovalType,SessionName,SaveTerm,Folds)
%CGG_RESETREMOVALTABLESACROSSFOLDS Summary of this function goes here
%   Detailed explanation goes here
IANameExt = sprintf('IA_Table%s.mat',SaveTerm);
IAPathNameExt = fullfile(EpochDir.Results,'Analysis','Importance Analysis',RemovalType,'Fold %d',SessionName,IANameExt);
[NewRemovalTable,TablesMatch] = cgg_checkRemovalTablesAcrossFolds(IAPathNameExt,Folds);
% fprintf('Tables Match %d (cgg_resetRemovalTablesAcrossFolds) \n',TablesMatch);
if ~TablesMatch
cgg_saveRemovalTable(NewRemovalTable,Folds,EpochDir.Results, ...
    RemovalType,SessionName,SaveTerm,'ResetAnalysis',~TablesMatch);
fprintf('!!! Reseting analysis due to mismatched Removal Tables\n');
end

end

