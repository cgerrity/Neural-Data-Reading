function cgg_checkTrainingStatus(cfg_Network,varargin)
%CGG_CHECKTRAININGSTATUS Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
NumEpochsAutoEncoder = CheckVararginPairs('NumEpochsAutoEncoder', [], varargin{:});
else
if ~(exist('NumEpochsAutoEncoder','var'))
NumEpochsAutoEncoder=[];
end
end

if isfunction
NumEpochsFull = CheckVararginPairs('NumEpochsFull', [], varargin{:});
else
if ~(exist('NumEpochsFull','var'))
NumEpochsFull=[];
end
end

%%

if isempty(NumEpochsAutoEncoder)
    AutoEncoder_Message = '\t*** Current Autoencoder Training is at Epoch: %d \n\n';
else
    AutoEncoder_Message = '\t*** Current Autoencoder Training Progress is %.2f%% \n\n';
end
if isempty(NumEpochsAutoEncoder)
    FullNetwork_Message = '\t*** Current Full Network Training is at Epoch: %d \n\n';
else
    FullNetwork_Message = '\t*** Current Full Network Training Progress is %.2f%% \n\n';
end

%%

Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderInformation');

%%
AutoEncoder_CurrentIterationSavePathNameExt = [AutoEncoding_Dir ...
    filesep 'CurrentIteration.mat'];
FullNetwork_CurrentIterationSavePathNameExt = [Encoding_Dir ...
    filesep 'CurrentIteration.mat'];

%%

if isfile(AutoEncoder_CurrentIterationSavePathNameExt)
    AutoEncoder_CurrentIteration = load(AutoEncoder_CurrentIterationSavePathNameExt);
end
if isfile(FullNetwork_CurrentIterationSavePathNameExt)
    FullNetwork_CurrentIteration = load(FullNetwork_CurrentIterationSavePathNameExt);
end

%%
if exist('AutoEncoder_CurrentIteration','var')
    AutoEncoder_CurrentEpoch = AutoEncoder_CurrentIteration.Epoch;
    if isempty(NumEpochsAutoEncoder)
        fprintf(AutoEncoder_Message,AutoEncoder_CurrentEpoch);
    else
        AutoEncoder_Percent = min(AutoEncoder_CurrentEpoch/NumEpochsAutoEncoder*100,100);
        fprintf(AutoEncoder_Message,AutoEncoder_Percent);
    end
end

if exist('FullNetwork_CurrentIteration','var')
    FullNetwork_CurrentEpoch = FullNetwork_CurrentIteration.Epoch;
    if isempty(NumEpochsFull)
        fprintf(FullNetwork_Message,FullNetwork_CurrentEpoch);
    else
        FullNetwork_Percent = min(FullNetwork_CurrentEpoch/NumEpochsFull*100,100);
        fprintf(FullNetwork_Message,FullNetwork_Percent);
    end
end
end

