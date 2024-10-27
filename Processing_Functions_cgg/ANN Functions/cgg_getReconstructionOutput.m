function [Y_Reconstruction,Y_Mean,Y_logSigmaSq] = ...
    cgg_getReconstructionOutput(Y_Encoded,Decoder,wantPredict)
%CGG_GETDECODER Summary of this function goes here
%   Detailed explanation goes here

OutputNames_Decoder = Decoder.OutputNames;
NumOutputs_Decoder = length(OutputNames_Decoder);

Decoder=resetState(Decoder);
    Y_Decoded=cell(NumOutputs_Decoder,1);
if wantPredict
    [Y_Decoded{:},~] = predict(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
else
    [Y_Decoded{:},~] = forward(Decoder,Y_Encoded,Outputs=OutputNames_Decoder);
end
if any(contains(OutputNames_Decoder,'mean')) && any(contains(OutputNames_Decoder,'log-variance'))
Y_Mean = Y_Decoded{contains(OutputNames_Decoder,'mean')};
Y_logSigmaSq = Y_Decoded{contains(OutputNames_Decoder,'log-variance')};
else
    Y_Mean = [];
    Y_logSigmaSq = [];
end
Y_Reconstruction = Y_Decoded{contains(OutputNames_Decoder,'Decoder')};
end

