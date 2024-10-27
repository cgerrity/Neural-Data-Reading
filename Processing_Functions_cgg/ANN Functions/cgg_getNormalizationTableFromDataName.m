function NormalizationTable = cgg_getNormalizationTableFromDataName(FileName)
%CGG_GETNORMALIZATIONTABLEFROMDATANAME Summary of this function goes here
%   Detailed explanation goes here

[FileNumber,NumberWidth] = cgg_getNumberFromFileName(FileName);

[DataDir,~,~]=fileparts(FileName);
[EpochDir,~,~]=fileparts(DataDir);
TargetPath = [EpochDir filesep 'Target'];

TargetNameExt_TMP = sprintf('Target_%%0%dd.mat',NumberWidth);

TargetNameExt = sprintf(TargetNameExt_TMP,FileNumber);

TargetPathNameExt = [TargetPath filesep TargetNameExt];

SessionName = cgg_loadTargetArray(TargetPathNameExt,'SessionName',true);

NormalizationInformationPath = [EpochDir filesep 'Normalization Information'];
NormalizationInformationPathNameExt = [NormalizationInformationPath filesep 'NormalizationInformation.mat'];

m_NormalizationInformation=matfile(NormalizationInformationPathNameExt,"Writable",false);
NormalizationInformation=m_NormalizationInformation.NormalizationInformation;
NormalizationTable = NormalizationInformation.(SessionName);

end

