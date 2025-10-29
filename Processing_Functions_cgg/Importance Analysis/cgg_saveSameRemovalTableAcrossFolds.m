function cgg_saveSameRemovalTableAcrossFolds(RemovalTable,Folds,cfg_Epoch,RemovalType,SessionName,SaveTerm,varargin)
%CGG_SAVESAMEREMOVALTABLEACROSSFOLDS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
PauseMaximum = CheckVararginPairs('PauseMaximum', 20, varargin{:});
else
if ~(exist('PauseMaximum','var'))
PauseMaximum=20;
end
end

% EpochDir_Main = cgg_getDirectory(cfg_Epoch.TargetDir,'Epoch');
EpochDir_Results = cgg_getDirectory(cfg_Epoch.ResultsDir,'Epoch');

% cgg_saveRemovalTable(RemovalTable,Folds,cfg_Epoch.Results,RemovalType,SessionName,SaveTerm);
cgg_saveRemovalTable(RemovalTable,Folds,EpochDir_Results,RemovalType,SessionName,SaveTerm);

TablesMatch = false;

while ~TablesMatch
    pause(randi(PauseMaximum));
    
TablesMatch = cgg_resetRemovalTablesAcrossFolds(cfg_Epoch, ...
    RemovalType,SessionName,SaveTerm,Folds);
% fprintf('Tables Match %d (cgg_saveSameRemovalTableAcrossFolds) \n',TablesMatch);
end

end

