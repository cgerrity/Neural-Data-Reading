function [IsProcessed,Processing_Information,...
    Processing_InformationPathNameExt] = cgg_checkProcessedGeneral(...
    FieldName,VarName,Processing_InformationName,cfg)
%CGG_CHECKPROCESSEDGENERAL Summary of this function goes here
%   Detailed explanation goes here
TargetDir=cfg.path;
Processing_InformationNameExt=[Processing_InformationName '.mat'];
Processing_InformationPathNameExt=[TargetDir filesep Processing_InformationNameExt];

if exist(Processing_InformationPathNameExt,'file')
    m_Processing_Information = matfile(Processing_InformationPathNameExt,'Writable',true);
    Processing_Information=m_Processing_Information.(VarName);
    if isfield(Processing_Information,FieldName)
    IsProcessed=Processing_Information.(FieldName);
    else
    IsProcessed=false;    
    end
else
    IsProcessed=false;
    m_Processing_Information = matfile(Processing_InformationPathNameExt,'Writable',true);
    Processing_Information.(FieldName)=IsProcessed;
    m_Processing_Information.(VarName)=Processing_Information;
end

end

