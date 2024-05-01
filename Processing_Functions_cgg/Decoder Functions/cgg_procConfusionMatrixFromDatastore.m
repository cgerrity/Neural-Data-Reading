function [Window_Accuracy,Accuracy,Window_CM,Full_CM,CM_Cell,CM_Table] = cgg_procConfusionMatrixFromDatastore(InDatastore,Mdl,ClassNames,varargin)
%CGG_PROCCONFUSIONMATRIXFROMDATASTORE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
DimensionNumber = CheckVararginPairs('DimensionNumber', 1, varargin{:});
else
if ~(exist('DimensionNumber','var'))
DimensionNumber=1;
end
end

NumDatastore=numpartitions(InDatastore);

% DataNumber=cell(1,NumDatastore);

wantTable=true;
%%
parfor didx=1:NumDatastore
    this_tmp_Datastore=partition(InDatastore,NumDatastore,didx);
    this_Values=read(this_tmp_Datastore);
    % reset(this_tmp_Datastore);
    % [~,~,this_DataNumber] = cgg_getTrialVariablesFromDatastore(this_tmp_Datastore,'Data Number');
    FileName=this_tmp_Datastore.UnderlyingDatastores{1}.Files;
    [this_DataNumber,~] = cgg_getNumberFromFileName(FileName);
    % this_DataNumber=DataNumber{didx};
    this_X=this_Values{1};
    [NumWindows,~]=size(this_X);
%     this_Y=repmat(this_Values{2},[NumWindows,1]);

    for widx=1:NumWindows

    Y_predicted = predict(Mdl,this_X(widx,:));
%     CM_Cell{widx}(didx,:) = [this_Values{2},Y_predicted];

    CM_Cell{didx}{widx,1} = [this_Values{2}(DimensionNumber),Y_predicted,this_DataNumber];

    end

end
%%

if wantTable
CM_Table = cgg_gatherConfusionMatrixCellToTable(CM_Cell);
end

MaxNumWindows=max(cellfun(@(x) length(x),CM_Cell));
Full_CM=zeros(length(ClassNames));
Window_Accuracy = NaN(1,MaxNumWindows);
Window_CM = cell(1,MaxNumWindows);

for widx=1:MaxNumWindows

    % this_CM=cellfun(@(x) cgg_procConfusionMatrixWindowCheck(x,widx),CM_Cell,'UniformOutput',false);
    % this_CM=this_CM(~cellfun(@(x) isempty(x),this_CM));
    % this_CM=this_CM';
    % this_CM=cell2mat(this_CM);

    this_CM = cgg_procConfusionMatrixFromWindow(CM_Cell,widx);

    this_CM = confusionmat(this_CM(:,1),this_CM(:,2),'Order',ClassNames);

    TruePositives = trace(this_CM);
    TotalObservations = sum(this_CM(:));
    Window_Accuracy(widx) = TruePositives/TotalObservations;
    Full_CM = Full_CM+this_CM;
    Window_CM{widx} = this_CM;
end

TruePositives = trace(Full_CM);
TotalObservations = sum(Full_CM(:));
Accuracy = TruePositives/TotalObservations;

end

