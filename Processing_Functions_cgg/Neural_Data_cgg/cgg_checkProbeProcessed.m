function IsProbeProcessed = cgg_checkProbeProcessed(Probe_Area,cfg)
%CGG_CHECKPROBEPROCESSED Summary of this function goes here
%   Detailed explanation goes here
% ProcessingDir=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing.path;
% ProbeProcessing_SaveName='Probe_Processing_Information.mat';
% ProbeProcessing_SaveNameFull=[ProcessingDir filesep ProbeProcessing_SaveName];
% 
% if exist(ProbeProcessing_SaveNameFull,'file')
%     m_Probe = matfile(ProbeProcessing_SaveNameFull,'Writable',true);
%     ProbeProcessing=m_Probe.ProbeProcessing;
%     IsProbeProcessed=ProbeProcessing.(Probe_Area);
% else
%     IsProbeProcessed=false;
% end

cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing;
Processing_InformationName='Probe_Processing_Information';
FieldName=Probe_Area;
VarName='ProbeProcessing';

[IsProbeProcessed,Processing_Information,Processing_InformationPathNameExt] ...
    = cgg_checkProcessedGeneral(FieldName,VarName,...
    Processing_InformationName,cfg_tmp);


end

