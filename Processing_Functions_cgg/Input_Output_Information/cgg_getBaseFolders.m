function [inputfolder_base,outputfolder_base,temporaryfolder_base,...
    Current_System] = cgg_getBaseFolders(varargin)
%CGG_GETBASEFOLDERS Summary of this function goes here
%   Detailed explanation goes here


[~,Environment_Variables]=system('env');
Environment_Variables=splitlines(Environment_Variables);
Root_Directory=split(Environment_Variables(startsWith(Environment_Variables,"PATH")),'/');
Root_Directory=Root_Directory{2};
Current_User=split(Environment_Variables(startsWith(Environment_Variables,"USER")),'=');
Current_User=Current_User{2};

switch Root_Directory
    case "usr"
        Current_System="Personal Computer";
        % If not me I'm not sure how someone will want to access the files.
        % Add a new case here for a new user
        switch Current_User
            case 'cgerrity'
        inputfolder_base='/Volumes/Womelsdorf Lab';
        outputfolder_base='/Volumes/gerritcg''s home';
        temporaryfolder_base='/Volumes/gerritcg''s home';
            case 'newuser'
        inputfolder_base='/Volumes/Womelsdorf Lab'; 
        % Folder where 'Data_neural' is accessed from your computer
        outputfolder_base='/Volumes/gerritcg''s home';
        % Folder where you would like all of the processing to go
        temporaryfolder_base='/Volumes/gerritcg''s home';   
        % Folder where any temporary files shoudl go
        end
    case "data"
        Current_System="TEBA";
        inputfolder_base='/data';
        outputfolder_base=['/data/users/',Current_User];
        temporaryfolder_base=['/data/users/',Current_User];
    case "accre"
        Current_System="ACCRE";
        inputfolder_base=['/home/',Current_User];
        outputfolder_base=['/home/',Current_User];
        temporaryfolder_base=['/nobackup/user/',Current_User];
end

end

