function [Accuracy_Current,Window_Accuracy,CM_Table] = cgg_procTestingResults(InDatastore,Mdl,varargin)
%CGG_PROCTESTINGRESULTS Summary of this function goes here
%   Detailed explanation goes here


isfunction=exist('varargin','var');

if isfunction
ClassNames = CheckVararginPairs('ClassNames', [], varargin{:});
else
if ~(exist('ClassNames','var'))
ClassNames=[];
end
end

if isfunction
NumIter = CheckVararginPairs('NumIter', 4, varargin{:});
else
if ~(exist('NumIter','var'))
NumIter=4;
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
Accuracy_Prior = CheckVararginPairs('Accuracy_Prior', [], varargin{:});
else
if ~(exist('Accuracy_Prior','var'))
Accuracy_Prior=[];
end
end

if isfunction
SavePathNameExt = CheckVararginPairs('SavePathNameExt', '', varargin{:});
else
if ~(exist('SavePathNameExt','var'))
SavePathNameExt='';
end
end

%% Parameters
cfg_NameParameters = NAMEPARAMETERS_cgg_nameVariables;

ZeroFeatureTableName=cfg_NameParameters.ZeroFeatureTableName;
FeatureTableName=cfg_NameParameters.FeatureTableName;
AllTableName=cfg_NameParameters.AllTableName;

%%

% IsModelCell=iscell(Mdl);
% IsModelTable=istable(Mdl);

[NumDimensions,~]=size(Mdl);
ModelTypes=Mdl.Properties.VariableNames;

wantZeroFeatureDetector=false;
if contains(ModelTypes,ZeroFeatureTableName) ...
        && contains(ModelTypes,FeatureTableName)
wantZeroFeatureDetector = true;
end

%%

if isempty(ClassNames)

    NumClasses=[];
    evalc('NumClasses=gather(tall(InDatastore.UnderlyingDatastores{2}));');

    if iscell(NumClasses)
        if isnumeric(NumClasses{1})

            [Dim1,Dim2]=size(NumClasses{1});
            [Dim3,Dim4]=size(NumClasses);

            if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
                NumClasses=NumClasses';
            end

            NumClasses=cell2mat(NumClasses);
            [Dim1,Dim2]=size(NumClasses);

            if Dim1<Dim2
                NumClasses=NumClasses';
            end
        end
    end

    ClassNames=cell(1,NumDimensions);
    for fdidx=1:NumDimensions
        ClassNames{fdidx}=unique(NumClasses(:,fdidx));
    end

end

%%

wantSave=~isempty(SavePathNameExt);

%%

CM_Table_Cell_Iter=cell(NumDimensions,NumIter);

for fdidx=1:NumDimensions
    for idx=1:NumIter
        if wantZeroFeatureDetector
            this_MdlZero=Mdl{fdidx,ZeroFeatureTableName};
            this_MdlZero=this_MdlZero{1};
            this_MdlFeature=Mdl{fdidx,FeatureTableName};
            this_MdlFeature=this_MdlFeature{1};
            [CM_Table_Cell_Iter{fdidx,idx}] = cgg_procPredictionsFromDatastore(InDatastore,{this_MdlZero,this_MdlFeature},ClassNames{fdidx},'DimensionNumber',fdidx);
        else
            this_MdlAll=Mdl{fdidx,AllTableName};
            this_MdlAll=this_MdlAll{1};
            [CM_Table_Cell_Iter{fdidx,idx}] = cgg_procPredictionsFromDatastore(InDatastore,this_MdlAll,ClassNames{fdidx},'DimensionNumber',fdidx);
        end
    end
end

%%

CM_Table_Iter=cell(1,NumIter);

for idx=1:NumIter
    CM_Table_Iter{idx} = cgg_procCombinePredictions(CM_Table_Cell_Iter(:,idx),'wantZeroFeatureDetector',wantZeroFeatureDetector);
end

%%

[CM_Table] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table_Iter);
[~,~,Accuracy_Current] = cgg_procConfusionMatrixFromTable(CM_Table,ClassNames,'MatchType',MatchType);
[~,~,Window_Accuracy] = cgg_procConfusionMatrixWindowsFromTable(CM_Table,ClassNames,'MatchType',MatchType);

if isempty(Accuracy_Prior)
Accuracy_Prior = cgg_loadAccuracy(SavePathNameExt);
end

Accuracy=[Accuracy_Prior,Accuracy_Current];

%%

if wantSave
    SaveVariables={Accuracy,Window_Accuracy,CM_Table};
    SaveVariablesName={'Accuracy','Window_Accuracy','CM_Table'};
    % SavePathNameExt=DecoderAccuracy_PathNameExt;
    cgg_saveVariableUsingMatfile(SaveVariables,SaveVariablesName,SavePathNameExt);
end

end

