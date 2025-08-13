function cgg_deleteNetworks(cfg_Network,varargin)
%CGG_DELETENETWORKS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Optimality = CheckVararginPairs('Optimality', 'Optimal', varargin{:});
else
if ~(exist('Optimality','var'))
Optimality='Optimal';
end
end

%%

Encoding_Dir = cgg_getDirectory(cfg_Network,'Classifier');
AutoEncoding_Dir = cgg_getDirectory(cfg_Network,'AutoEncoderInformation');

%%
AutoEncoder_EncoderSavePathNameExt = ...
    sprintf([AutoEncoding_Dir filesep 'Encoder-%s.mat'],Optimality);
AutoEncoder_DecoderSavePathNameExt = ...
    sprintf([AutoEncoding_Dir filesep 'Decoder-%s.mat'],Optimality);

FullNetwork_EncoderSavePathNameExt = ...
    sprintf([Encoding_Dir filesep 'Encoder-%s.mat'],Optimality);
FullNetwork_DecoderSavePathNameExt = ...
    sprintf([Encoding_Dir filesep 'Decoder-%s.mat'],Optimality);
FullNetwork_ClassifierSavePathNameExt = ...
    sprintf([Encoding_Dir filesep 'Classifier-%s.mat'],Optimality);

%%

if isfile(FullNetwork_EncoderSavePathNameExt)
    delete(FullNetwork_EncoderSavePathNameExt);
end
if isfile(FullNetwork_DecoderSavePathNameExt)
    delete(FullNetwork_DecoderSavePathNameExt);
end
if isfile(FullNetwork_ClassifierSavePathNameExt)
    delete(FullNetwork_ClassifierSavePathNameExt);
end
if isfile(AutoEncoder_EncoderSavePathNameExt)
    delete(AutoEncoder_EncoderSavePathNameExt);
end
if isfile(AutoEncoder_DecoderSavePathNameExt)
    delete(AutoEncoder_DecoderSavePathNameExt);
end

end

