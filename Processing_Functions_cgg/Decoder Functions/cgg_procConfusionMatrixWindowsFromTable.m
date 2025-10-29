function [CM,Accuracy,MeanAccuracy] = cgg_procConfusionMatrixWindowsFromTable(CM_Table,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXWINDOWSFROMTABLE Summary of this function goes here
%   Detailed explanation goes here


VariableNames=CM_Table.Properties.VariableNames;

WindowIndices=contains(VariableNames,'Window');
WindowNames=VariableNames(WindowIndices);

NumWindows=numel(WindowNames);

%%

Par_CM = cell(NumWindows,1);
Par_Accuracy = cell(NumWindows,1);
Par_MeanAccuracy = cell(NumWindows,1);

this_varargin_Parallel = parallel.pool.Constant(varargin);
parfor widx=1:NumWindows
    this_varargin = this_varargin_Parallel.Value;
    this_WindowName=WindowNames{widx};
    [Par_CM{widx},Par_Accuracy{widx},Par_MeanAccuracy{widx}] = ...
        cgg_procConfusionMatrixFromTable(CM_Table,ClassNames,...
        'PredictionColumn',this_WindowName,this_varargin{:});
end

%%

for widx=1:NumWindows
    % this_WindowName=WindowNames{widx};
    % [this_CM,this_Accuracy,this_MeanAccuracy] = ...
    %     cgg_procConfusionMatrixFromTable(CM_Table,ClassNames,...
    %     'PredictionColumn',this_WindowName,varargin{:});
    this_CM = Par_CM{widx};
    this_Accuracy = Par_Accuracy{widx};
    this_MeanAccuracy = Par_MeanAccuracy{widx};
    if widx==1
        CM=zeros([size(this_CM),NumWindows]);
        Accuracy=zeros([length(this_Accuracy),NumWindows]);
        MeanAccuracy=zeros(1,NumWindows);
    end

    if numel(size(CM))==3
    CM(:,:,widx)=this_CM;
    else
    CM(:,:,:,widx)=this_CM;
    end
    Accuracy(:,widx)=this_Accuracy;
    MeanAccuracy(widx)=this_MeanAccuracy;

end


%%
end

