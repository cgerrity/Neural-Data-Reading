function [inputfolder,outdatadir,isTEBA] = ...
    cgg_getBaseFoldersFromSessionInformation(Monkey_Name,...
    ExperimentName,SessionName)
%CGG_GETBASEFOLDERSFROMSESSIONINFORMATION Summary of this function goes here
%   Detailed explanation goes here

Current_Folder_Names=split(pwd,filesep);

if strcmp(Current_Folder_Names{2},'data')||strcmp(Current_Folder_Names{2},'tmp')
isTEBA=true;
inputfolder_base='/data';
outputfolder_base='/data/users/gerritcg';
else
isTEBA=false;
inputfolder_base='/Volumes/Womelsdorf Lab';
outputfolder_base='/Volumes/gerritcg''s home';
end

inputfolder=[inputfolder_base '/DATA_neural/' Monkey_Name filesep ...
    ExperimentName filesep SessionName];
outdatadir=[outputfolder_base '/Data_Neural_gerritcg'];

end

