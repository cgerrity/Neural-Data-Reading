function IsSessionProcessed = cgg_checkSessionProcessed(SessionName,cfg)
%CGG_CHECKPROBEPROCESSED Summary of this function goes here
%   Detailed explanation goes here
TargetDir=cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Processing.path;
SessionProcessing_SaveName='Session_Processing_Information.mat';
SessionProcessing_SaveNameFull=[TargetDir filesep SessionProcessing_SaveName];

if exist(SessionProcessing_SaveNameFull,'file')
    m_Session = matfile(SessionProcessing_SaveNameFull,'Writable',true);
    SessionProcessing=m_Session.SessionProcessing;
    if isfield(SessionProcessing,SessionName)
    IsSessionProcessed=SessionProcessing.(SessionName);
    else
    IsSessionProcessed=false;    
    end
else
    IsSessionProcessed=false;
end

end

