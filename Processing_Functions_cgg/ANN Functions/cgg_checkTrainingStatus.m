function [ResultFull,ResultAutoencoder] = cgg_checkTrainingStatus(cfg_Network,varargin)
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

ResultFull = NaN;
ResultAutoencoder = NaN;

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
        ResultAutoencoder = AutoEncoder_CurrentEpoch;
    else
        ResultAutoencoder = min(AutoEncoder_CurrentEpoch/NumEpochsAutoEncoder*100,100);
    end
    fprintf(AutoEncoder_Message,ResultAutoencoder);
end

if exist('FullNetwork_CurrentIteration','var')
    FullNetwork_CurrentEpoch = FullNetwork_CurrentIteration.Epoch;
    if isempty(NumEpochsFull)
        ResultFull = FullNetwork_CurrentEpoch;
    else
        ResultFull = min(FullNetwork_CurrentEpoch/NumEpochsFull*100,100);
    end
        fprintf(FullNetwork_Message,ResultFull);
end
end

