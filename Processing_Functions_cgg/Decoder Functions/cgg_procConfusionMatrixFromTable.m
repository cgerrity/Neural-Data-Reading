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

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
Weights = CheckVararginPairs('Weights', [], varargin{:});
else
if ~(exist('Weights','var'))
Weights=[];
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
% [~,NumIterations]=size(CM_Table{1,PredictionIndices(1)});
[NumIterations,~]=size(CM_Table{1,PredictionIndices(1)});
end

Accuracy=NaN(NumIterations,1);

if iscell(ClassNames)
CM=zeros(2,2,NumIterations);
else
CM=zeros(length(ClassNames),length(ClassNames),NumIterations);
end

TrueValue=CM_Table.TrueValue;

if all(~strcmp(FilterColumn,'All') & ~strcmp(FilterColumn,'Target Feature'))
    FilterRowIDX=all((CM_Table{:,FilterColumn}==FilterValue),2);
    TrueValue=TrueValue(FilterRowIDX,:);
end

if any(strcmp(FilterColumn,'Target Feature'))
    SelectDimension=CM_Table.('Target Feature');
    TrueValue=TrueValue(sub2ind(size(TrueValue),1:size(TrueValue,1),SelectDimension'))';
    MatchType='exact';
end

[NumInstances,NumDimension]=size(TrueValue);

%%
for idx=1:NumIterations

    if iscell(ClassNames)
        this_Full_CM=zeros(2);
    else
    this_Full_CM=zeros(length(ClassNames));
    end

    if hasIterationColumn
    this_idx=IterationValues(idx);
    IterationRowIDX = CM_Table.IterationNumber==this_idx;
    this_CM_Table=CM_Table(IterationRowIDX,:);
        if isempty(Weights)
            this_Weights = Weights;
        else
            this_Weights = Weights(IterationRowIDX,:);
        end
    else
    this_CM_Table=CM_Table;
    this_Weights = Weights;
    end

    if all(~strcmp(FilterColumn,'All') & ~strcmp(FilterColumn,'Target Feature'))
        % this_CM_Table=...
        % this_CM_Table((this_CM_Table.(FilterColumn)==FilterValue),:);
        this_CM_Table=this_CM_Table(FilterRowIDX,:);
        if isempty(Weights)
            this_Weights = Weights;
        else
            this_Weights = this_Weights(FilterRowIDX,:);
        end
        % fprintf('??? Debug 1-> CM Table Rows: %d Weights Rows: %d\n',height(this_CM_Table),size(this_Weights,1));
    end

    NumPredictions=numel(PredictionIndices);

    CombinedPrediction=NaN(NumInstances*NumPredictions,NumDimension);
    CombinedTrueValue=NaN(NumInstances*NumPredictions,NumDimension);

    for pidx=1:NumPredictions
        this_PredictionIndex=PredictionIndices(pidx);
        this_Prediction=this_CM_Table{:,this_PredictionIndex};

        % if hasIterationColumn
        % this_Prediction=this_CM_Table{:,this_PredictionIndex};
        % else
        % this_Prediction=this_CM_Table{:,this_PredictionIndex};
        % this_Prediction=this_Prediction{:,idx};
        % end

        CombinedIndices_Start=NumInstances*(pidx-1)+1;
        CombinedIndices_End=NumInstances*(pidx);

        CombinedIndices=CombinedIndices_Start:CombinedIndices_End;

        if any(strcmp(FilterColumn,'Target Feature'))
%             this_Prediction=this_Prediction(:,SelectDimension);
            this_Prediction=this_Prediction(sub2ind(size(this_Prediction),1:size(this_Prediction,1),SelectDimension'))';
        end

        CombinedPrediction(CombinedIndices,:)=this_Prediction;
        CombinedTrueValue(CombinedIndices,:)=TrueValue;

    end

    if isfunction
        WeightIDX = find(strcmp(varargin,'Weights'));
        WeightRemovalIDX = [WeightIDX,WeightIDX+1];
        varargin(WeightRemovalIDX) = [];
        % fprintf('??? Debug 2-> True Value Rows: %d Prediction Rows: %d Weights Rows: %d\n',size(CombinedTrueValue,1),size(CombinedPrediction,1),size(this_Weights,1));
    [Accuracy(idx)] = cgg_calcAllPerformanceMetrics(...
    CombinedTrueValue,CombinedPrediction,ClassNames,'MatchType',...
    MatchType,'IsQuaddle',IsQuaddle,'Weights',this_Weights,varargin{:});
    else
    [Accuracy(idx)] = cgg_calcAllPerformanceMetrics(...
    CombinedTrueValue,CombinedPrediction,ClassNames,'MatchType',...
    MatchType,'IsQuaddle',IsQuaddle);
    end

    % [Accuracy(idx)] = cgg_calcAllAccuracyTypes(CombinedTrueValue,CombinedPrediction,ClassNames,MatchType);

    % switch MatchType
    %     case 'exact'
    %         if iscell(ClassNames)
    %             this_CM_tmp=CombinedTrueValue==CombinedPrediction;
    %             this_CM_tmp=all(this_CM_tmp,2);
    %             this_CM=[sum(this_CM_tmp==1),0;sum(this_CM_tmp==0),0];
    %         else
    %             this_CM = confusionmat(CombinedTrueValue,...
    %                 CombinedPrediction,'Order',ClassNames);
    %         end
    %             this_Full_CM = this_CM;
    % 
    %             TruePositives = trace(this_Full_CM);
    %             TotalObservations = sum(this_Full_CM(:));
    %             Accuracy(idx) = TruePositives/TotalObservations;
    % 
    %             CM(:,:,idx)=this_Full_CM;
    % 
    %     case 'macroaccuracy'
    %         [Accuracy(idx)] = cgg_calcMacroAccuracy(CombinedTrueValue,CombinedPrediction,ClassNames);
    %     case 'combinedaccuracy'
    %         [Accuracy(idx)] = cgg_calcCombinedAccuracy(CombinedTrueValue,CombinedPrediction,ClassNames);
    %     otherwise
    % end
end

MeanAccuracy=mean(Accuracy);

end

