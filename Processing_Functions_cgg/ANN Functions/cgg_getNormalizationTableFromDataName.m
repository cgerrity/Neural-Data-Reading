function NormalizationTable = cgg_getNormalizationTableFromDataName(FileName,varargin)
%CGG_GETNORMALIZATIONTABLEFROMDATANAME Summary of this function goes here

isfunction=exist('varargin','var');

if isfunction
NormalizationInformation = CheckVararginPairs('NormalizationInformation', '', varargin{:});
else
if ~(exist('NormalizationInformation','var'))
NormalizationInformation='';
end
end
%   Detailed explanation goes here

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

%%

%%
Time_Mat = NaN(1,100);
Time_Load = NaN(1,100);
for idx = 1:100
SessionName = Session_List{randi(length(Session_List))};
tic
m_NormalizationInformation=matfile(NormalizationInformationPathNameExt,"Writable",false);
NormalizationInformation=m_NormalizationInformation.NormalizationInformation;
NormalizationTable = NormalizationInformation.(SessionName);
Time_Mat(idx) = toc;

tic
NormalizationInformation_2 = load(NormalizationInformationPathNameExt);
NormalizationInformation_2 = NormalizationInformation_2.NormalizationInformation;
NormalizationTable_2 = NormalizationInformation_2.(SessionName);
Time_Load(idx) = toc;

end

disp(mean(Time_Mat));
disp(mean(Time_Load));

end