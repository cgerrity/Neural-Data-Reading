function cgg_gatherMatVariableFromAllSessions(MatNameExt,TargetName,SessionSubDir,SubAreaDir,Folder,SubFolder,varargin)
%CGG_GATHERMATVARIABLEFROMALLSESSIONS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

%%

[cfg_Session] = DATA_cggAllSessionInformationConfiguration;

%%

for sidx=1:length(cfg_Session)
    SessionDir=cfg_Session(sidx).SessionFolder;
    TargetDir=cfg_Session(sidx).outdatadir;
if isfunction
cgg_gatherMatVariableFromSingleSession(MatNameExt,TargetName,SessionDir,SessionSubDir,SubAreaDir,Folder,SubFolder,TargetDir,varargin{:})
else
cgg_gatherMatVariableFromSingleSession(MatNameExt,TargetName,SessionDir,SessionSubDir,SubAreaDir,Folder,SubFolder,TargetDir)
end
end

end

