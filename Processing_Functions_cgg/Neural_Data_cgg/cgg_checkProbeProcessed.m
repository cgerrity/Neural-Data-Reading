function IsProbeProcessed = cgg_checkProbeProcessed(Probe_Area,cfg)
%CGG_CHECKPROBEPROCESSED Summary of this function goes here
%   Detailed explanation goes here
TargetDir=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Target.path;
ProbeProcessing_SaveName='Probe_Processing_Information.mat';
ProbeProcessing_SaveNameFull=[TargetDir filesep ProbeProcessing_SaveName];

if exist(ProbeProcessing_SaveNameFull,'file')
    m_Probe = matfile(ProbeProcessing_SaveNameFull,'Writable',true);
    ProbeProcessing=m_Probe.ProbeProcessing;
    IsProbeProcessed=ProbeProcessing.(Probe_Area);
else
    IsProbeProcessed=false;
end

end

