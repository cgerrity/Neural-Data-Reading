function cgg_saveNetworks(Encoder,Decoder,Classifier,WantSaveNet,NetworkPath,IsOptimal)
%CGG_SAVENETWORKS Summary of this function goes here
%   Detailed explanation goes here

if ~WantSaveNet
    return
end

OptimalSaveTerm = '-Optimal';
CurrentSaveTerm = '-Current';

HasDecoder = ~isempty(Decoder);
HasClassifier = ~isempty(Classifier);

try
    Encoder=Encoder{1};
catch
end
Encoder=resetState(Encoder);

EncoderNameExt = sprintf('Encoder%s.mat',CurrentSaveTerm);
EncoderPathNameExt = [NetworkPath filesep EncoderNameExt];
cgg_saveVariableUsingMatfile({Encoder},{'Encoder'},EncoderPathNameExt);
if IsOptimal
EncoderNameExt = sprintf('Encoder%s.mat',OptimalSaveTerm);
EncoderPathNameExt = [NetworkPath filesep EncoderNameExt];
cgg_saveVariableUsingMatfile({Encoder},{'Encoder'},EncoderPathNameExt);
end

if HasDecoder
    try
        Decoder=Decoder{1};
    catch
    end
    Decoder=resetState(Decoder);
    DecoderNameExt = sprintf('Decoder%s.mat',CurrentSaveTerm);
    DecoderPathNameExt = [NetworkPath filesep DecoderNameExt];
    cgg_saveVariableUsingMatfile({Decoder},{'Decoder'},DecoderPathNameExt);
    if IsOptimal
    DecoderNameExt = sprintf('Decoder%s.mat',OptimalSaveTerm);
    DecoderPathNameExt = [NetworkPath filesep DecoderNameExt];
    cgg_saveVariableUsingMatfile({Decoder},{'Decoder'},DecoderPathNameExt);
    end
end

if HasClassifier
    try
        Classifier=Classifier{1};
    catch
    end
    Classifier=resetState(Classifier);
    ClassifierNameExt = sprintf('Classifier%s.mat',CurrentSaveTerm);
    ClassifierPathNameExt = [NetworkPath filesep ClassifierNameExt];
    cgg_saveVariableUsingMatfile({Classifier},{'Classifier'},ClassifierPathNameExt);
    if IsOptimal
    ClassifierNameExt = sprintf('Classifier%s.mat',OptimalSaveTerm);
    ClassifierPathNameExt = [NetworkPath filesep ClassifierNameExt];
    cgg_saveVariableUsingMatfile({Classifier},{'Classifier'},ClassifierPathNameExt);
    end
end

end

