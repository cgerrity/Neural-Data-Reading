function [OutputInformation,OutputAdditionalInformation] = cgg_getNetworkOutputInformation(InputNet)
%CGG_GETNETWORKOUTPUTINFORMATION Summary of this function goes here
%   Detailed explanation goes here
%%

OutputNames_All=InputNet.OutputNames;

OutputNames_Mean=string(OutputNames_All(contains(OutputNames_All,'mean')));
OutputNames_LogVar=string(OutputNames_All(contains(OutputNames_All,'log-variance')));
OutputNames_Classifier=string(OutputNames_All(contains(OutputNames_All,'Dim')));
OutputNames_Reconstruction=string(OutputNames_All(contains(OutputNames_All,'reshape') | contains(OutputNames_All,'Output')));
OutputNames_TrialConfidence=string(OutputNames_All(contains(OutputNames_All,'TrialConfidence')));
OutputNames_TaskConfidence=string(OutputNames_All(contains(OutputNames_All,'TaskConfidence')));

OutputInformation=struct();
OutputInformation.Mean=OutputNames_Mean;
OutputInformation.LogVar=OutputNames_LogVar;
OutputInformation.Classifier=OutputNames_Classifier;
OutputInformation.Reconstruction=OutputNames_Reconstruction;
OutputInformation.TrialConfidence=OutputNames_TrialConfidence;
OutputInformation.TaskConfidence=OutputNames_TaskConfidence;

IsVariational=true;
if isempty(OutputNames_Mean) && isempty(OutputNames_LogVar)
IsVariational=false;
end

HasClassifier=~isempty(OutputNames_Classifier);
HasReconstruction=~isempty(OutputNames_Reconstruction);

if any(contains(OutputNames_Classifier,'CTC'))
    LossType='CTC';
elseif HasClassifier
    LossType='Classification';
elseif HasReconstruction
    LossType='Regression';
else
    LossType='None';
end

HasConfidence = cgg_hasNetworkConfidence(InputNet);

OutputAdditionalInformation = struct();
OutputAdditionalInformation.IsVariational = IsVariational;
OutputAdditionalInformation.HasClassifier = HasClassifier;
OutputAdditionalInformation.HasReconstruction = HasReconstruction;
OutputAdditionalInformation.LossType = LossType;
OutputAdditionalInformation.HasConfidence = HasConfidence;


end

