function [inputfolder,outdatadir,temporarydir,Current_System] = ...
    cgg_getBaseFoldersFromSessionInformation(Monkey_Name,...
    ExperimentName,SessionName,varargin)
%CGG_GETBASEFOLDERSFROMSESSIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

% Current_Folder_Names=split(pwd,filesep);

[inputfolder_base,outputfolder_base,temporaryfolder_base,...
    Current_System] = cgg_getBaseFolders(varargin{:});


% if strcmp(Current_Folder_Names{2},'data')||strcmp(Current_Folder_Names{2},'tmp')
% isTEBA=true;
% isACCRE=false;
% inputfolder_base='/data';
% outputfolder_base='/data/users/gerritcg';
% elseif strcmp(Current_Folder_Names{2},'panfs')||contains(Current_Folder_Names{2},'accrepfs')
% isTEBA=false;
% isACCRE=true;
% inputfolder_base='/home/gerritcg';
% outputfolder_base='/nobackup/user/gerritcg';
% else
% isTEBA=false;
% isACCRE=false;
% inputfolder_base='/Volumes/Womelsdorf Lab';
% outputfolder_base='/Volumes/gerritcg''s home';
% end

inputfolder=[inputfolder_base '/DATA_neural/' Monkey_Name filesep ...
    ExperimentName filesep SessionName];
outdatadir=[outputfolder_base '/Data_Neural'];
temporarydir=[temporaryfolder_base '/Data_Neural'];

end

