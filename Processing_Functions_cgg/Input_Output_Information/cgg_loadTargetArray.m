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
TrialChosen = CheckVararginPairs('TrialChosen', '', varargin{:});
else
if ~(exist('TrialChosen','var'))
TrialChosen=[];
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
elseif ~isempty(TrialChosen)
TargetType='TrialChosen';
elseif ~isempty(SessionName)
TargetType='SessionName';
elseif DataNumber
TargetType='DataNumber';
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
this_CorrectTrial=strcmp(Target.CorrectTrial{1},'True');
end

% Selecting Correct vs Error on Previous Trial

if PreviousTrialCorrect||AllTargets
    if iscell(Target.PreviousTrialCorrect)
    this_PreviousTrialCorrect=strcmp(Target.PreviousTrialCorrect{1},'True');
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
TrialsFromLP=Target.TrialsFromLP;
this_Learned = TrialsFromLP>-1;
end

% Selecting Probe Processing Information

if ProbeProcessing||AllTargets
this_ProbeProcessing=Target.ProbeProcessing;
end

% Selecting Is Trial Chosen

if ~isempty(TrialChosen)||AllTargets
if isfield(Target,'TrialChosen')
this_TrialChosen = Target.TrialChosen;
else
this_TrialChosen = true;
end
end

% Selecting Session Name

if ~isempty(SessionName)||AllTargets
this_SessionName = Target.SessionName;
end

% Selecting Data Number

if DataNumber||AllTargets
    [~,TargetName,~]=fileparts(FileName);
this_DataNumber = str2num(extractAfter(TargetName,'_'));
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
    case 'TrialChosen'
        Target = this_TrialChosen;
    case 'SessionName'
        Target = this_SessionName;
    case 'DataNumber'
        Target = this_DataNumber;
    case 'AllTargets'
        Target=cell(1,2);
        [Target{1},Target{2}] = cgg_procDataSegmentationGroups(this_Dimension_Each,this_CorrectTrial,this_PreviousTrialCorrect,this_Dimensionality,this_Gain,this_Loss,this_Learned,this_ProbeProcessing,this_TrialChosen,this_SessionName,this_DataNumber);
    otherwise
end

%%

end

