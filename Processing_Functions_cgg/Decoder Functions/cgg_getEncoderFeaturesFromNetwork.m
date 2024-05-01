function [FeatureVector] = cgg_getEncoderFeaturesFromNetwork(InNetwork,Input)
%CGG_GETENCODERFEATURESFROMNETWORK Summary of this function goes here
%   Detailed explanation goes here


% create encoder form trained network
encoder = network;
% Define topology
encoder.numInputs = 1;
encoder.numLayers = 1;
encoder.inputConnect(1,1) = 1;
encoder.outputConnect = 1;
encoder.biasConnect = 1;
% Set values for labels
encoder.name = 'Encoder';
encoder.layers{1}.name = 'Encoder';
% Copy parameters from input network
encoder.inputs{1}.size = InNetwork.inputs{1}.size;
encoder.layers{1}.size = InNetwork.layers{1}.size;
encoder.layers{1}.transferFcn = InNetwork.layers{1}.transferFcn;
encoder.IW{1,1} = InNetwork.IW{1,1};
encoder.b{1} = InNetwork.b{1};
% Set a training function
encoder.trainFcn = InNetwork.trainFcn;
% Set the input
encoderStruct = struct(encoder);
networkStruct = struct(InNetwork);
encoderStruct.inputs{1} = networkStruct.inputs{1};
encoder = network(encoderStruct);
% extract features from net
FeatureVector = encoder(Input);


end

