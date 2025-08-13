function NormalizationTable = cgg_getNormalizationTableFromDataName(FileName,varargin)
%CGG_GETNORMALIZATIONTABLEFROMDATANAME Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
NormalizationInformation = CheckVararginPairs('NormalizationInformation', '', varargin{:});
else
if ~(exist('NormalizationInformation','var'))
NormalizationInformation='';
end
end

[FileNumber,NumberWidth] = cgg_getNumberFromFileName(FileName);

[DataDir,~,~]=fileparts(FileName);
[EpochDir,~,~]=fileparts(DataDir);
TargetPath = [EpochDir filesep 'Target'];

TargetNameExt_TMP = sprintf('Target_%%0%dd.mat',NumberWidth);

TargetNameExt = sprintf(TargetNameExt_TMP,FileNumber);

TargetPathNameExt = [TargetPath filesep TargetNameExt];

SessionName = cgg_loadTargetArray(TargetPathNameExt,'SessionName',true);

if ~isempty(NormalizationInformation)
NormalizationTable = NormalizationInformation.(SessionName);
    return
end

NormalizationInformationPath = [EpochDir filesep 'Normalization Information'];
NormalizationInformationPathNameExt = [NormalizationInformationPath filesep 'NormalizationInformation.mat'];

% m_NormalizationInformation=matfile(NormalizationInformationPathNameExt,"Writable",false);
% NormalizationInformation=m_NormalizationInformation.NormalizationInformation;
% NormalizationTable = NormalizationInformation.(SessionName);

NormalizationInformation = load(NormalizationInformationPathNameExt);
NormalizationInformation = NormalizationInformation.NormalizationInformation;
NormalizationTable = NormalizationInformation.(SessionName);

end