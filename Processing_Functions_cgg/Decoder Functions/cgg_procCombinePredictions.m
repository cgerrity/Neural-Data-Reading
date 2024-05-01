function CM_Table = cgg_procCombinePredictions(CM_Table_Cell,varargin)
%CGG_PROCQUADDLEINTERPRETER Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantZeroFeatureDetector = CheckVararginPairs('wantZeroFeatureDetector', false, varargin{:});
else
if ~(exist('wantZeroFeatureDetector','var'))
wantZeroFeatureDetector=false;
end
end

%%

[NumDimensions,~]=size(CM_Table_Cell);
[NumData,~]=size(CM_Table_Cell{1});

DataNumbers=CM_Table_Cell{1}.DataNumber;

ColumnNames=CM_Table_Cell{1}.Properties.VariableNames;
% WindowIndices=find(contains(ColumnNames,'Window')==1);
% WindowNames=ColumnNames(WindowIndices);
% NumWindows=length(WindowIndices);

WindowPredictionIndices=find(matches(ColumnNames,"Window_"+digitsPattern)==1);
WindowConfidenceIndices=find(matches(ColumnNames,"Window_"+digitsPattern+"_Confidence")==1);

WindowPredictionNames=ColumnNames(WindowPredictionIndices);
WindowConfidenceNames=ColumnNames(WindowConfidenceIndices);
NumWindows=length(WindowPredictionIndices);

%%

CM_Cell=cell(1,NumData);

parfor tidx=1:NumData
this_DataNumber=DataNumbers(tidx);
this_CM_Table=[];
for widx=1:NumWindows
%     this_WindowName=WindowNames{widx};

    this_WindowPredictionName=WindowPredictionNames{widx};
    this_WindowConfidenceName=WindowConfidenceNames{widx};

    this_ClassNames=cell(NumDimensions,1);
    this_ClassPrediction=NaN(1,NumDimensions);
    this_ClassConfidence=cell(NumDimensions,1);
    this_TrueValue=NaN(1,NumDimensions);
    for didx=1:NumDimensions

    this_Prediction_Table=CM_Table_Cell{didx};

    this_ClassNames{didx}=this_Prediction_Table{tidx,"ClassNames"};
    this_TrueValue(didx)=this_Prediction_Table{tidx,"TrueValue"};
%     this_ClassConfidence{didx}=this_Prediction_Table{tidx,this_WindowName};
    this_ClassPrediction(didx)=this_Prediction_Table{tidx,this_WindowPredictionName};
    this_ClassConfidence{didx}=this_Prediction_Table{tidx,this_WindowConfidenceName};

    end % End Dimension Iteration

    [this_Prediction] = cgg_procQuaddleInterpreter(this_ClassPrediction,this_ClassNames,this_ClassConfidence,wantZeroFeatureDetector);

        if widx==1
        this_CM_Table = table(this_DataNumber,this_TrueValue,...
          this_Prediction,'VariableNames',{'DataNumber','TrueValue',this_WindowPredictionName});
%         this_CM_Table = table(this_DataNumber,this_TrueValue,...
%           this_ClassPrediction,this_Prediction,'VariableNames',{'DataNumber','TrueValue',this_WindowPredictionName,this_WindowConfidenceName});
        else
        this_CM_Table.(this_WindowPredictionName)=this_Prediction;
%         this_CM_Table.(this_WindowPredictionName)=this_ClassPrediction;
%         this_CM_Table.(this_WindowConfidenceName)=this_Prediction;
        end

end % End Window Iteration

CM_Cell{tidx}=this_CM_Table;


end % End Trial Iteration

%%

%%
clear('CM_Table');
for didx=1:NumData
this_Prediction_Table=CM_Cell{didx};
if exist('CM_Table','var')
CM_Table = cgg_getCombineTablesWithMissingColumns(CM_Table,this_Prediction_Table);
else
CM_Table=this_Prediction_Table;
end
end

end

