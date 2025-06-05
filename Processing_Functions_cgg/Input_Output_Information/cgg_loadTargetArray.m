function Target = cgg_loadTargetArray(FileName,varargin)
%CGG_LOADDATAARRAY Summary of this function goes here
%   Detailed explanation goes here

% Name-Value Options are: CorrectTrial, PreviousTrialCorrect, Dimension,
% Dimensionality, Gain, Loss, Learned, ProbeProcessing, TrialChosen,
% SessionName, AllTargets

Target=load(FileName);
Target=Target.Target;

%% Quaddle Dimensions in experiment

FeatureDimensions = [1,2,3,5];

%%

isfunction=exist('varargin','var');

if isfunction
CorrectTrial = CheckVararginPairs('CorrectTrial', false, varargin{:});
else
if ~(exist('CorrectTrial','var'))
CorrectTrial=false;
end
end

if isfunction
PreviousTrialCorrect = CheckVararginPairs('PreviousTrialCorrect', false, varargin{:});
else
if ~(exist('PreviousTrialCorrect','var'))
PreviousTrialCorrect=false;
end
end

if isfunction
Dimension = CheckVararginPairs('Dimension', '', varargin{:});
else
if ~(exist('Dimension','var'))
Dimension=[];
end
end

if isfunction
Dimensionality = CheckVararginPairs('Dimensionality', false, varargin{:});
else
if ~(exist('Dimensionality','var'))
Dimensionality=false;
end
end

if isfunction
Gain = CheckVararginPairs('Gain', false, varargin{:});
else
if ~(exist('Gain','var'))
Gain=false;
end
end

if isfunction
Loss = CheckVararginPairs('Loss', false, varargin{:});
else
if ~(exist('Loss','var'))
Loss=false;
end
end

if isfunction
Learned = CheckVararginPairs('Learned', false, varargin{:});
else
if ~(exist('Learned','var'))
Learned=false;
end
end

if isfunction
ProbeProcessing = CheckVararginPairs('ProbeProcessing', false, varargin{:});
else
if ~(exist('ProbeProcessing','var'))
ProbeProcessing=false;
end
end

if isfunction
TargetFeature = CheckVararginPairs('TargetFeature', false, varargin{:});
else
if ~(exist('TargetFeature','var'))
TargetFeature=false;
end
end

if isfunction
ReactionTime = CheckVararginPairs('ReactionTime', false, varargin{:});
else
if ~(exist('ReactionTime','var'))
ReactionTime=false;
end
end

if isfunction
TrialChosen = CheckVararginPairs('TrialChosen', '', varargin{:});
else
if ~(exist('TrialChosen','var'))
TrialChosen=[];
end
end

if isfunction
TrialsFromLP = CheckVararginPairs('TrialsFromLP', false, varargin{:});
else
if ~(exist('TrialsFromLP','var'))
TrialsFromLP=false;
end
end

if isfunction
TrialsFromLPCategory = CheckVararginPairs('TrialsFromLPCategory', false, varargin{:});
else
if ~(exist('TrialsFromLPCategory','var'))
TrialsFromLPCategory=false;
end
end

if isfunction
TrialsFromLPCategoryFine = CheckVararginPairs('TrialsFromLPCategoryFine', false, varargin{:});
else
if ~(exist('TrialsFromLPCategoryFine','var'))
TrialsFromLPCategoryFine=false;
end
end

if isfunction
SharedFeatureCoding = CheckVararginPairs('SharedFeatureCoding', false, varargin{:});
else
if ~(exist('SharedFeatureCoding','var'))
SharedFeatureCoding=false;
end
end

if isfunction
SharedFeature = CheckVararginPairs('SharedFeature', false, varargin{:});
else
if ~(exist('SharedFeature','var'))
SharedFeature=false;
end
end

if isfunction
SessionName = CheckVararginPairs('SessionName', '', varargin{:});
else
if ~(exist('SessionName','var'))
SessionName=[];
end
end

if isfunction
Block = CheckVararginPairs('Block', false, varargin{:});
else
if ~(exist('Block','var'))
Block=false;
end
end

if isfunction
DataNumber = CheckVararginPairs('DataNumber', false, varargin{:});
else
if ~(exist('DataNumber','var'))
DataNumber=false;
end
end

if isfunction
AllTargets = CheckVararginPairs('AllTargets', false, varargin{:});
else
if ~(exist('AllTargets','var'))
AllTargets=false;
end
end

% Learning Model Targets

if isfunction
PredictionError = CheckVararginPairs('PredictionError', false, varargin{:});
else
if ~(exist('PredictionError','var'))
PredictionError=false;
end
end

if isfunction
ChoiceProbability = CheckVararginPairs('ChoiceProbability', false, varargin{:});
else
if ~(exist('ChoiceProbability','var'))
ChoiceProbability=false;
end
end

if isfunction
OtherValue = CheckVararginPairs('OtherValue', '', varargin{:});
else
if ~(exist('OtherValue','var'))
OtherValue='';
end
end

%%

if ~isempty(Dimension)
TargetType='Dimension';
elseif CorrectTrial
TargetType='CorrectTrial';
elseif PreviousTrialCorrect
TargetType='PreviousTrialCorrect';
elseif Dimensionality
TargetType='Dimensionality';
elseif Gain
TargetType='Gain';
elseif Loss
TargetType='Loss';
elseif Learned
TargetType='Learned';
elseif ProbeProcessing
TargetType='ProbeProcessing';
elseif TargetFeature
TargetType='TargetFeature';
elseif ReactionTime
TargetType='ReactionTime';
elseif ~isempty(TrialChosen)
TargetType='TrialChosen';
elseif TrialsFromLP
TargetType='TrialsFromLP';
elseif TrialsFromLPCategory
TargetType='TrialsFromLPCategory';
elseif TrialsFromLPCategoryFine
TargetType='TrialsFromLPCategoryFine';
elseif SharedFeatureCoding
TargetType='SharedFeatureCoding';
elseif SharedFeature
TargetType='SharedFeature';
elseif ~isempty(SessionName)
TargetType='SessionName';
elseif Block
TargetType='Block';
elseif DataNumber
TargetType='DataNumber';
elseif PredictionError
TargetType='PredictionError';
elseif ChoiceProbability
TargetType='ChoiceProbability';
elseif ~isempty(OtherValue)
TargetType='OtherValue';
else
TargetType='AllTargets'; AllTargets=true;
end

%% Target Value Selection
% Selecting One Dimension

if ~isempty(Dimension)||AllTargets
this_Dimension_Each=Target.SelectedObjectDimVals;
this_Dimension_Each=this_Dimension_Each(FeatureDimensions);
end

% Selecting Correct vs Error

if CorrectTrial||AllTargets
% this_CorrectTrial=strcmp(Target.CorrectTrial{1},'True');
this_CorrectTrial=strcmp(Target.CorrectTrial,'True');
end

% Selecting Correct vs Error on Previous Trial

if PreviousTrialCorrect||AllTargets
    if iscell(Target.PreviousTrialCorrect)
    this_PreviousTrialCorrect=strcmp(Target.PreviousTrialCorrect{1},'True');
    elseif ischar(Target.PreviousTrialCorrect)
    this_PreviousTrialCorrect=strcmp(Target.PreviousTrialCorrect,'True');
    else
    this_PreviousTrialCorrect=false;
    end
end

% Selecting Dimensionality (Difficulty)

if Dimensionality||AllTargets
this_Dimensionality=Target.Dimensionality;
end

% Selecting Gain

if Gain||AllTargets
this_Gain=Target.Gain;
end

% Selecting Loss

if Loss||AllTargets
this_Loss=Target.Loss;
end

% Selecting Learned

if Learned||AllTargets
this_TrialsFromLP=Target.TrialsFromLP;
this_Learned = this_TrialsFromLP>-1;
if isnan(this_TrialsFromLP)
this_Learned=-1;
end
end

% Selecting Probe Processing Information

if ProbeProcessing||AllTargets
this_ProbeProcessing=Target.ProbeProcessing;
end

% Selecting Target Feature Dimension

if TargetFeature||AllTargets
this_TargetFeature=Target.TargetFeature;
end

% Selecting Reaction Time

if ReactionTime||AllTargets
this_ReactionTime=Target.ReactionTime;
end

% Selecting Is Trial Chosen

if ~isempty(TrialChosen)||AllTargets
if isfield(Target,'TrialChosen')
this_TrialChosen = Target.TrialChosen;
else
this_TrialChosen = true;
end
end

% Selecting Trials from Learning Point

if TrialsFromLP||AllTargets
this_TrialsFromLP=Target.TrialsFromLP;
if isnan(this_TrialsFromLP)
this_TrialsFromLP=-Inf;
end
end

% Selecting Trials from Learning Point Category

if TrialsFromLPCategory||AllTargets
this_TrialsFromLP=Target.TrialsFromLP;
if isnan(this_TrialsFromLP)
this_TrialsFromLP=-Inf;
end
this_TrialsFromLPCategory = cgg_calcTrialsFromLPCategories(this_TrialsFromLP,false);
end

% Selecting Fine Grain Trials from Learning Point Category

if TrialsFromLPCategoryFine||AllTargets
this_TrialsFromLP=Target.TrialsFromLP;
if isnan(this_TrialsFromLP)
this_TrialsFromLP=-Inf;
end
this_TrialsFromLPCategoryFine = cgg_calcTrialsFromLPCategories(this_TrialsFromLP,true);
end

% Selecting Shared Feature Coding

if SharedFeatureCoding||AllTargets
this_SharedFeatureCoding=Target.SharedFeatureCoding;
end

% Selecting Shared Feature

if SharedFeature||AllTargets
this_SharedFeature=Target.SharedFeature;
end

% Selecting Session Name

if ~isempty(SessionName)||AllTargets
this_SessionName = Target.SessionName;
end

% Selecting Block Number

if Block||AllTargets
this_Block=Target.Block;
end

% Selecting Data Number

if DataNumber||AllTargets
    [~,TargetName,~]=fileparts(FileName);
this_DataNumber = str2num(extractAfter(TargetName,'_'));
end

% Selecting Prediction Error

if PredictionError
this_PredictionError=Target.PE_ObjectChosen;
end

% Selecting Choice Probability

if ChoiceProbability
this_ChoiceProbability=Target.ChoiceProbability_ObjectChosen_WM_RL_CMB;
end

% Selecting Other Value

if ~isempty(OtherValue)
this_OtherValue=Target.(OtherValue);
end

%% Assigning the Target

switch TargetType
    case 'Dimension'
        Target = this_Dimension_Each(Dimension);
    case 'CorrectTrial'
        Target = this_CorrectTrial;
    case 'PreviousTrialCorrect'
        Target = this_PreviousTrialCorrect;
    case 'Dimensionality'
        Target = this_Dimensionality;
    case 'Gain'
        Target = this_Gain;
    case 'Loss'
        Target = this_Loss;
    case 'Learned'
        Target = this_Learned;
    case 'ProbeProcessing'
        Target = this_ProbeProcessing;
    case 'TargetFeature'
        Target = this_TargetFeature;
    case 'ReactionTime'
        Target = this_ReactionTime;
    case 'TrialChosen'
        Target = this_TrialChosen;
    case 'TrialsFromLP'
        Target = this_TrialsFromLP;
    case 'TrialsFromLPCategory'
        Target = this_TrialsFromLPCategory;
    case 'TrialsFromLPCategoryFine'
        Target = this_TrialsFromLPCategoryFine;
    case 'SharedFeatureCoding'
        Target = this_SharedFeatureCoding;
    case 'SharedFeature'
        Target = this_SharedFeature;
    case 'SessionName'
        Target = this_SessionName;
    case 'Block'
        Target = this_Block;
    case 'DataNumber'
        Target = this_DataNumber;
    case 'PredictionError'
        Target = this_PredictionError;
    case 'ChoiceProbability'
        Target = this_ChoiceProbability;
    case 'OtherValue'
        Target = this_OtherValue;
    case 'AllTargets'
        Target=cell(1,2);
        [Target{1},Target{2}] = cgg_procDataSegmentationGroups(this_Dimension_Each,this_CorrectTrial,this_PreviousTrialCorrect,this_Dimensionality,this_Gain,this_Loss,this_Learned,this_ProbeProcessing,this_TargetFeature,this_ReactionTime,this_TrialChosen,this_SessionName,this_Block,this_DataNumber,this_SharedFeatureCoding,this_TrialsFromLP,this_TrialsFromLPCategory,this_TrialsFromLPCategoryFine);
    otherwise
end

%%

end

