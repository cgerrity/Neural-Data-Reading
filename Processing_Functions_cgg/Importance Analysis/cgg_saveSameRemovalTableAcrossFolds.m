function cgg_saveSameRemovalTableAcrossFolds(RemovalTable,Folds,EpochDir,RemovalType,SessionName,SaveTerm,varargin)
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


cgg_saveRemovalTable(RemovalTable,Folds,EpochDir.Results,RemovalType,SessionName,SaveTerm);

TablesMatch = false;

while ~TablesMatch
    pause(randi(PauseMaximum));
    
TablesMatch = cgg_resetRemovalTablesAcrossFolds(EpochDir, ...
    RemovalType,SessionName,SaveTerm,Folds);
% fprintf('Tables Match %d (cgg_saveSameRemovalTableAcrossFolds) \n',TablesMatch);
end

end

