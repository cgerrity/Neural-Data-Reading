function newData = ReshapeForLMM(oldData, ivName, varargin)

%{
Converts a nSubject X nObservations repeated-measures matrix into
table with all observations 

Inputs - 
oldData - nSubject X nObvservations repeated measures matrix. Each row is a
subject, each column is an observation.
ivName - name of the independent variable
varargin - pairs of predictor names and levels. First item in pair is the
name of the predictor, second is a 1 X nObservations (or nObservations X 1)
vector or cell array, containing the levels of the predictor variable

Outputs -
newData = table where column 1 = IV, column 2 = Subject numbers, remaining
columns = predictors
%}

nS = size(oldData,1);
nObs = size(oldData,2);

newData = table(reshape(oldData',[],1), 'variablenames', {ivName});

if strcmpi(varargin{1}, 'subjects')
    predictorStart = 3;
    subjs = varargin{2};
    if size(subjs,1) > 1 && size(subjs,2) == 1
        subjs = subjs';
    end
else
    predictorStart = 1;
    subjs = 1:nS;
end

newData = [newData table(reshape(repmat(subjs,nObs,1),[],1), 'variablenames', {'Subject'})];
newData.Subject = categorical(newData.Subject);


for i = predictorStart:2:length(varargin)
    predictor = varargin{i+1};
    if size(predictor,2) > 1 && size(predictor,1) == 1
        predictor = repmat(reshape(predictor,[],1),nS,1);
    else
        predictor = repmat(predictor,nS,1);
    end
    newData = [newData table(predictor, 'variablenames', {varargin{i}})];
end
