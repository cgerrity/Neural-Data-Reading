clc; clear; close all;
%%
PathNameExt = '/Users/cgerrity/Downloads/FeatureValues_RLWMModelValues_01 (2).mat';
load(PathNameExt);
%%

this_Block = 5;
this_Session = 2;
this_Monkey = 1;
WantLog = false;

switch this_Monkey
    case 1
        this_Data = MATData1;
    case 2
        this_Data = MATData2;
    otherwise
        this_Data = MATData1;
end

BlockIDs = this_Data.blocknumindx;
SessionNames = this_Data.datasetname;

UniqueSessionNames = unique(SessionNames);
this_SessionName = UniqueSessionNames{this_Session};
SelectedSessionIndices = strcmp(SessionNames,this_SessionName);
UniqueBlockIds = unique(BlockIDs(SelectedSessionIndices));
SelectedBlockIndices = BlockIDs == UniqueBlockIds(this_Block);

RowIndices = find(SelectedBlockIndices & SelectedSessionIndices);
%%

% RowIndices = 280:314; % 1-D 
% RowIndices = 250:279; % 1-D 
% RowIndices = 1:30; % 2-D 
% RowIndices = 31:65; % 3-D 
% RowIndices = 66:99; % 2-D 
% RowIndices = 100:133; % 2-D 
% RowIndices = 168:198; % 3-D 
% RowIndices = 199:249; % 3-D 



%%
this_ChosenValue = this_Data.Value_ObjectChosen_RL(RowIndices,:);
this_NotChosenValue = this_Data.Value_ObjectsNotChosen_RL(RowIndices,:);
this_IDs = this_Data.featureID(RowIndices,:);
this_R = this_Data.R(:,RowIndices);
this_PEChosen = this_Data.PE_ObjectChosen(RowIndices,:);
this_PENotChosen = this_Data.PE_ObjectsNotChosen(RowIndices,:);

%%
RowIndices_TEST = 1:2000;
BlockIDs = this_Data.blocknumindx(RowIndices_TEST,:);
SessionNames = this_Data.datasetname(RowIndices_TEST,:);
FeatureIDs = this_Data.featureID(RowIndices_TEST,:);
ValueChosen = this_Data.Value_ObjectChosen_RL(RowIndices_TEST,:);
ValueNotChosen = this_Data.Value_ObjectsNotChosen_RL(RowIndices_TEST,:);
PEChosen = this_Data.PE_ObjectChosen(RowIndices_TEST,:);
PENotChosen = this_Data.PE_ObjectsNotChosen(RowIndices_TEST,:);

[TargetData, DistractorData] = cgg_getCorrectedVariables(BlockIDs, SessionNames, FeatureIDs, ValueChosen, ValueNotChosen, PEChosen, PENotChosen);
%%

AllIDs = unique(this_IDs);
AllIDs(AllIDs == 0) = [];
NumFeatures = length(AllIDs);
Dimensionality = round(NumFeatures/3);

ActiveChosen = 1:Dimensionality;
ActiveNotChosen = 1:round(2*Dimensionality);
first_vals = Dimensionality + ActiveChosen;
second_vals = first_vals + Dimensionality;
stacked = [first_vals; second_vals];
ActiveNotChosenFull = stacked(:)';

% ActiveNotChosen = 1:round(2*NumFeatures/3);
% ActiveNotChosenFull = ActiveNotChosen + length(ActiveChosen);

%%
EmptyIDs = all(this_IDs == 0,1);
EmptyChosenValues = true(1,3);
EmptyChosenValues(ActiveChosen) = false;
EmptyNotChosenValues = true(1,6);
EmptyNotChosenValues(ActiveNotChosen) = false;

% EmptyChosenValues = all(this_ChosenValue == 0,1);
% EmptyNotChosenValues = max(find(~all(this_NotChosenValue == 0,1)))+1:6;
TargetID = all(diff(this_IDs,2) == 0,1);
TargetID = this_IDs(1,TargetID);
TargetID(TargetID == 0) = [];
TargetIDX = AllIDs == TargetID;
%%
this_ChosenValue(:,EmptyChosenValues) = [];
this_NotChosenValue(:,EmptyNotChosenValues) = [];
this_PEChosen(:,EmptyChosenValues) = [];
this_PENotChosen(:,EmptyNotChosenValues) = [];
this_LogChosenValue = log(this_ChosenValue);
this_LogNotChosenValue = log(this_NotChosenValue);
% this_AllValues = cat(2,this_ChosenValue,this_NotChosenValue);

%%

this_AllValues = zeros(size(this_IDs));
this_AllValues(:,ActiveChosen) = this_ChosenValue;
this_AllValues(:,ActiveNotChosenFull) = this_NotChosenValue;

this_AllPEs = zeros(size(this_IDs));
this_AllPEs(:,ActiveChosen) = this_PEChosen;
this_AllPEs(:,ActiveNotChosenFull) = this_PENotChosen;

%%

this_Indices = cell(NumFeatures,1);
% this_IndicesChosen = cell(NumFeatures,1);
% this_IndicesNotChosen = cell(NumFeatures,1);
% this_Indices = NaN(size(this_IDs));

for fidx = 1:NumFeatures
    this_IDMatch = this_IDs == AllIDs(fidx);
    this_Indices{fidx} = this_IDs == AllIDs(fidx);
    % this_IndicesChosen{fidx} = this_IDMatch(:,ActiveChosen);
    % this_IndicesNotChosen{fidx} = this_IDMatch(:,ActiveNotChosenFull);
end

%%

% this_Index_15 = this_IDs == 15;
% this_Index_13 = this_IDs == 13;
% this_Index_11 = this_IDs == 11;
%%
% this_Index_11(:,[1,4:9]) = [];
% this_Index_13(:,[1,4:9]) = [];
%%

NumRows = length(RowIndices);

this_Values = cell(NumFeatures,1);
this_PEs = cell(NumFeatures,1);

for fidx = 1:NumFeatures
    this_Value = NaN(NumRows,1);
    this_PE = NaN(NumRows,1);
for idx = 1:NumRows
    this_Value(idx) = this_AllValues(idx,this_Indices{fidx}(idx,:));
    this_PE(idx) = this_AllPEs(idx,this_Indices{fidx}(idx,:));
end
if WantLog
this_Value = log(this_Value);
this_PE = log(this_PE);
end
this_Values{fidx} = this_Value;
this_PEs{fidx} = this_PE;
end

TargetValues = this_Values{TargetIDX};
TargetPE = this_PEs{TargetIDX};
DistractorValues = this_Values(~TargetIDX);
DistractorPE = this_PEs(~TargetIDX);
%%


% this_Value_15 = NaN(NumRows,1);
% this_Value_13 = NaN(NumRows,1);
% this_Value_11 = NaN(NumRows,1);
% for idx = 1:NumRows
% this_Value_15(idx) = this_ChosenValue(idx,1);
% this_Value_13(idx) = this_NotChosenValue(idx,this_Index_13(idx,:));
% this_Value_11(idx) = this_NotChosenValue(idx,this_Index_11(idx,:));
% end

%%
figure;
plot(1:NumRows,this_Values{1}, "DisplayName",num2str(AllIDs(1)),"LineWidth",2,"LineStyle",":");
hold on;
plot(1:NumRows,this_Values{2}, "DisplayName",num2str(AllIDs(2)),"LineWidth",2,"LineStyle",":");
for fidx = 3:NumFeatures
plot(1:NumRows,this_Values{fidx}, "DisplayName",num2str(AllIDs(fidx)),"LineWidth",2);
end
hold off;
legend;
title('Value');

figure;
plot(1:NumRows,this_PEs{1}, "DisplayName",num2str(AllIDs(1)),"LineWidth",2,"LineStyle",":");
hold on;
plot(1:NumRows,this_PEs{2}, "DisplayName",num2str(AllIDs(2)),"LineWidth",2,"LineStyle",":");
for fidx = 3:NumFeatures
plot(1:NumRows,this_PEs{fidx}, "DisplayName",num2str(AllIDs(fidx)),"LineWidth",2);
end
hold off;
legend;
title('Prediction Error');