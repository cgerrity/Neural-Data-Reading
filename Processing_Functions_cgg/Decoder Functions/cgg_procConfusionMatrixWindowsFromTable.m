function [CM,Accuracy,MeanAccuracy] = cgg_procConfusionMatrixWindowsFromTable(CM_Table,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXWINDOWSFROMTABLE Summary of this function goes here
%   Detailed explanation goes here


VariableNames=CM_Table.Properties.VariableNames;

WindowIndices=contains(VariableNames,'Window');
WindowNames=VariableNames(WindowIndices);

NumWindows=numel(WindowNames);

for widx=1:NumWindows
    this_WindowName=WindowNames{widx};
    [this_CM,this_Accuracy,this_MeanAccuracy] = ...
        cgg_procConfusionMatrixFromTable(CM_Table,ClassNames,...
        'PredictionColumn',this_WindowName,varargin{:});
    if widx==1
        CM=zeros([size(this_CM),NumWindows]);
        Accuracy=zeros([length(this_Accuracy),NumWindows]);
        MeanAccuracy=zeros(1,NumWindows);
    end

    CM(:,:,:,widx)=this_CM;
    Accuracy(:,widx)=this_Accuracy;
    MeanAccuracy(widx)=this_MeanAccuracy;

end


%%
end

