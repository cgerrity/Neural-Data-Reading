function [NetworkType,DropoutPercent] = cgg_getClassifierPropertiesFromName(ClassifierName)
%CGG_GETCLASSIFIERPROPERTIESFROMNAME Summary of this function goes here
%   Detailed explanation goes here



if contains(ClassifierName,'GRU')
    NetworkType = 'GRU';
elseif contains(ClassifierName,'LSTM')
    NetworkType = 'LSTM';
elseif contains(ClassifierName,'Feedforward')
    NetworkType = 'Feedforward';
elseif contains(ClassifierName,'Logistic')
    NetworkType = 'Logistic';
else
    NetworkType = 'Unknown';
    fprintf("!!! Unknown Classifier NetworkType. \n")
end

if contains(ClassifierName,'Dropout')
    DropoutString = extractAfter(ClassifierName,'Dropout');
    PercentString = regexp(DropoutString, '\d+\.?\d*', 'match', 'once'); % Extracts all numbers as a string array
    DropoutPercent = str2double(PercentString); 
else
    DropoutPercent = 0;
    fprintf("!!! Unknown Dropout Percent. Setting Dropout to 0. \n")
end

end