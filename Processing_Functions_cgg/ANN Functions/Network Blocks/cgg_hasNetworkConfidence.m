function HasConfidence = cgg_hasNetworkConfidence(Network)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
% Network; Can be Encoder, Decoder, Classifier, ...

% OutputNames_Classifier = OutputNames_Classifier(~contains(OutputNames_Classifier,'TrialConfidence'));

HasConfidence = any(contains(Network.OutputNames,'Confidence'));
end