function cgg_updateSessionTargetStructure(UpdateFunction,Epoch,inputfolder,outdatadir)
%CGG_UPDATESESSIONTARGETSTRUCTURE Summary of this function goes here
%   Detailed explanation goes here

[cfg] = cgg_generateEpochFolders(Epoch,'inputfolder',inputfolder,'outdatadir',outdatadir);

TargetPath=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
TargetPathNameExt=[TargetPath filesep 'Target_Information.mat'];

m_Target=matfile(TargetPathNameExt,"Writable",false);
Target=m_Target.Target;

NewTarget=UpdateFunction(Target);

TargetSaveVariables={NewTarget};
TargetSaveVariablesName={'Target'};

cgg_saveVariableUsingMatfile(TargetSaveVariables,TargetSaveVariablesName,TargetPathNameExt);


end

