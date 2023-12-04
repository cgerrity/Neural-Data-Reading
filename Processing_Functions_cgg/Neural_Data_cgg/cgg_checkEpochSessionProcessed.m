function [IsProcessed,Processing_Information,...
    Processing_InformationPathNameExt] = ...
    cgg_checkEpochSessionProcessed(cfg,varargin)
%CGG_CHECKEPOCHSESSIONPROCESSED Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
    SessionFinished = CheckVararginPairs('SessionFinished', NaN, varargin{:});
else
    SessionFinished = NaN;
end

cfg_tmp=cfg.outdatadir.Experiment.Session.Epoched_Data.Epoch.Processing;
Processing_InformationName='Session_Processing_Information';
FieldName='SessionProcessed';
VarName='SessionProcessing';

[IsProcessed,Processing_Information,Processing_InformationPathNameExt] ...
    = cgg_checkProcessedGeneral(FieldName,VarName,...
    Processing_InformationName,cfg_tmp);

if ~isnan(SessionFinished)
    m_Processing_Information = matfile(Processing_InformationPathNameExt,'Writable',true);
    Processing_Information.(FieldName)=SessionFinished;
    m_Processing_Information.(VarName)=Processing_Information;
end

end

