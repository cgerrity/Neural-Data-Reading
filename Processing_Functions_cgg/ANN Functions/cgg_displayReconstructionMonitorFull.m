function cgg_displayReconstructionMonitorFull(InputNet,TrainingMbq,ValidationMbq,ClassNames,OutputInformation,Iteration,monitor)
%CGG_DISPLAYRECONSTRUCTIONMONITORFULL Summary of this function goes here
%   Detailed explanation goes here
% isfunction=exist('varargin','var');

%%
reset(ValidationMbq);
reset(TrainingMbq);

NumShuffle = randi(10);

for idx = 1:NumShuffle
shuffle(ValidationMbq);
shuffle(TrainingMbq);
end

[XValidation,TValidation] = next(ValidationMbq);
[XTraining,TTraining] = next(TrainingMbq);

%%

NumClassifiers=length(OutputInformation.Classifier);
% NumReconstruction=length(OutputInformation.Reconstruction);

AllOutputNames=[OutputInformation.Classifier, OutputInformation.Reconstruction];

NumOutputs=length(AllOutputNames);
Y_Training=cell(NumOutputs,1);
Y_Validation=cell(NumOutputs,1);

InputNet=resetState(InputNet);
[Y_Training{:},~] = predict(InputNet,XTraining,Outputs=AllOutputNames);
InputNet=resetState(InputNet);
[Y_Validation{:},~] = predict(InputNet,XValidation,Outputs=AllOutputNames);

Y_Classification_Training=Y_Training(1:NumClassifiers);
Y_Reconstruction_Training=Y_Training{NumClassifiers+1:end};
Y_Classification_Validation=Y_Validation(1:NumClassifiers);
Y_Reconstruction_Validation=Y_Validation{NumClassifiers+1:end};

%%

NumReconstructionMonitorExamples = 1;

T_Reconstruction_Training = XTraining;
T_Reconstruction_Validation = XValidation;
T_Classification_Training = TTraining;
T_Classification_Validation = TValidation;

for idx = 1:NumReconstructionMonitorExamples

disp(idx);
cgg_displayReconstructionMonitor(monitor,Y_Classification_Training,Y_Reconstruction_Training,T_Classification_Training,T_Reconstruction_Training,Y_Classification_Validation,Y_Reconstruction_Validation,T_Classification_Validation,T_Reconstruction_Validation,ClassNames,Iteration);
end

end

