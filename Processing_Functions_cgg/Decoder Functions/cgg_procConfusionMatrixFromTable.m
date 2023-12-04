function [CM,Accuracy,MeanAccuracy] = cgg_procConfusionMatrixFromTable(CM_Table,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXFROMTABLE Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
PredictionColumn = CheckVararginPairs('PredictionColumn', 'All', varargin{:});
else
if ~(exist('PredictionColumn','var'))
PredictionColumn='All';
end
end

if isfunction
FilterColumn = CheckVararginPairs('FilterColumn', 'All', varargin{:});
else
if ~(exist('FilterColumn','var'))
FilterColumn='All';
end
end

if isfunction
FilterValue = CheckVararginPairs('FilterValue', NaN, varargin{:});
else
if ~(exist('FilterValue','var'))
FilterValue=NaN;
end
end

%%

VariableNames=CM_Table.Properties.VariableNames;

if strcmp(PredictionColumn,'All')
PredictionIndices=contains(VariableNames,'Window');
else
PredictionIndices=matches(VariableNames,PredictionColumn);
end
PredictionIndices=find(PredictionIndices==1);

hasIterationColumn = any(strcmp(VariableNames,'IterationNumber'));

if hasIterationColumn

if ~(hasIterationColumn)
    CM_Table.IterationNumber(:)=1;
end

IterationValues=unique(CM_Table.IterationNumber);

NumIterations=length(IterationValues);

else
[~,NumIterations]=size(CM_Table{1,PredictionIndices(1)});
end

Accuracy=NaN(NumIterations,1);

CM=zeros(length(ClassNames),length(ClassNames),NumIterations);

TrueValue=CM_Table.TrueValue;

%%
for idx=1:NumIterations
    this_Full_CM=zeros(length(ClassNames));

    if hasIterationColumn
    this_idx=IterationValues(idx);

    this_CM_Table=CM_Table(CM_Table.IterationNumber==this_idx,:);
    else
    this_CM_Table=CM_Table;
    end

    if ~strcmp(FilterColumn,'All')
        this_CM_Table=...
        this_CM_Table(:,this_CM_Table.(FilterColumn)==FilterValue);
    end

    NumPredictions=numel(PredictionIndices);

    for pidx=1:NumPredictions
        this_PredictionIndex=PredictionIndices(pidx);
        if hasIterationColumn
        this_Prediction=this_CM_Table{:,this_PredictionIndex};
        else
        this_Prediction=this_CM_Table{:,this_PredictionIndex}.Variables;
        this_Prediction=this_Prediction(:,idx);
        end

        this_CM = confusionmat(TrueValue,this_Prediction,'Order',ClassNames);
        this_Full_CM = this_Full_CM+this_CM;
    end

    TruePositives = trace(this_Full_CM);
    TotalObservations = sum(this_Full_CM(:));
    Accuracy(idx) = TruePositives/TotalObservations;

    CM(:,:,idx)=this_Full_CM;

end

MeanAccuracy=mean(Accuracy);

end

