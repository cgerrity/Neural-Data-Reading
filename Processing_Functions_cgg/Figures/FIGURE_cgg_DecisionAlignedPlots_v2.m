%% FIGURE_cgg_DecisiionAlignedPlots_v2


Current_Folder_Names=split(pwd,filesep);

if strcmp(Current_Folder_Names{2},'data')||strcmp(Current_Folder_Names{2},'tmp')
isTEBA=true;
inputfolder_base='/data';
outputfolder_base='/data/users/gerritcg';
else
isTEBA=false;
inputfolder_base='/Volumes/Womelsdorf Lab';
outputfolder_base='/Volumes/gerritcg''s home';
end

inputfolder=[inputfolder_base '/DATA_neural/Wotan/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];
outdatadir=[outputfolder_base '/Data_Neural_gerritcg'];
probe_area='ACC_001';
Activity_Type='MUA';
Alignment_Type='Decision';
Smooth_Factor=250;


%%
Frame_Event_Selection = 'SelectObject';
Frame_Event_Selection_Location = 'END';
Window_Before_Data = 1.5;
Window_After_Data = 1.5;

[Start_IDX_Data,End_IDX_Data] = cgg_getTimeSegments_v2(...
    'inputfolder',inputfolder,'outdatadir',outdatadir,...
    'Activity_Type',Activity_Type,...
    'Frame_Event_Selection',Frame_Event_Selection,...
    'Frame_Event_Selection_Location',Frame_Event_Selection_Location,...
    'Frame_Event_Window_Before',Window_Before_Data,...
    'Frame_Event_Window_After',Window_After_Data);

Frame_Event_Selection = 'Blink';
Frame_Event_Selection_Location = 'START';
Window_Before_Baseline = 0;
Window_After_Baseline = 0.5;

[Start_IDX_Base,End_IDX_Base] = cgg_getTimeSegments_v2(...
    'inputfolder',inputfolder,'outdatadir',outdatadir,...
    'Activity_Type',Activity_Type,...
    'Frame_Event_Selection',Frame_Event_Selection,...
    'Frame_Event_Selection_Location',Frame_Event_Selection_Location,...
    'Frame_Event_Window_Before',Window_Before_Baseline,...
    'Frame_Event_Window_After',Window_After_Baseline);

%%

[~,~,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation] = ...
    cgg_generateAllNeuralDataFolders('inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[outdatadir_WideBand,outdatadir_LFP,outdatadir_Spike,...
    outdatadir_MUA] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area);

[cfg_outplotdir] = cgg_generateNeuralPlottingFolders_v2(outdatadir,...
    SessionName,ExperimentName,probe_area,Activity_Type,Alignment_Type);

%%

fullfilename=[outdatadir_MUA filesep Activity_Type '_Trial_%d.mat'];

% [Segmented_Data,TrialNumbers_Data] = cgg_getAllTrialDataFromTimeSegments(Start_IDX_Data,End_IDX_Data,fullfilename,'inputfolder',inputfolder,...
%     'outdatadir',outdatadir);
% 
% [Segmented_Baseline,TrialNumbers_Baseline] = cgg_getAllTrialDataFromTimeSegments(Start_IDX_Base,End_IDX_Base,fullfilename,'inputfolder',inputfolder,...
%     'outdatadir',outdatadir);

[Norm_Segmented_Data,Norm_Segmented_Baseline,...
    TrialNumbers_Data,TrialNumbers_Baseline,Segmented_Data_Unsmoothed,Segmented_Data_Smoothed,Segmented_Baseline_Smoothed,Segmented_Data_Smoothed_Norm] = ...
    cgg_procFullTrialPreparation(Start_IDX_Data,End_IDX_Data,...
    Start_IDX_Base,End_IDX_Base,fullfilename,Smooth_Factor,'inputfolder',inputfolder,'outdatadir',outdatadir);

this_Selected_Data=Segmented_Data_Smoothed;
this_Selected_Baseline=Segmented_Baseline_Smoothed;

[NumChannels,NumSamples_Data,~]=size(this_Selected_Data);
[~,NumSamples_Baseline,~]=size(this_Selected_Baseline);

%%
exptType='FLU';
dataFolder=[inputfolder_base '/DATA_neural/Wotan/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01/Session39__23_02_2023__10_34_03'];
gazeArgs='TX300';
outdatadir_LT=[outputfolder_base '/Data_Neural_gerritcg/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];

[trialData, blockData] = ProcessSingleSessionData_FLU('exptType',exptType,'gazeArgs',gazeArgs,'outdatadir',outdatadir_LT,'dataFolder',dataFolder);

folder_name = 'Wo_Probe_01_23-02-23_008_01';
session_file = 'Session39__23_02_2023__10_34_03';
data_path = [inputfolder_base '/DATA_neural/Wotan/Wotan_FLToken_Probe_01'];
Area = 1; %1 = ACC, 2 = CD
MnkID = 1; %1 = Frey

proccessed_path = [outputfolder_base '/Data_Neural_gerritcg/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];

[TrialDATA, BlockDATA]  = cgg_singlesession_data_LT3(folder_name, session_file, data_path,proccessed_path, Area, MnkID);
%%
trialDefsFolder=[proccessed_path, filesep, 'ProcessedData', filesep, 'TrialDefs.mat'];
load(trialDefsFolder);
%%

Performance_Window=5;

TrialNumber=trialData.TrialCounter;
TrialInBlock=trialData.TrialInBlock;
AbortCode=trialData.AbortCode;
SelectedObjectID=trialData.SelectedObjectID;
CorrectTrial=trialData.PositiveFbObtained;
TrialsFromLP=trialData.TrialsFromLP;
TrialTime=trialData.TrialTime;
Block=trialData.Block;

IsTrialCorrect=strcmp(CorrectTrial,{'True'});

trialVariables=struct();

for tidx=1:length(TrialNumber)
    
    trialVariables(tidx).TrialNumber=TrialNumber(tidx);
    trialVariables(tidx).TrialInBlock=TrialInBlock(tidx);
    trialVariables(tidx).AbortCode=AbortCode(tidx);
    trialVariables(tidx).CorrectTrial=CorrectTrial(tidx);
    trialVariables(tidx).TrialsFromLP=TrialsFromLP(tidx);
    trialVariables(tidx).TrialTime=TrialTime(tidx);
    trialVariables(tidx).Block=Block(tidx);
    
    this_Perfromance=NaN;

    if TrialInBlock(tidx)<Performance_Window
        this_Perfromance=sum(IsTrialCorrect(tidx-TrialInBlock(tidx)+1:tidx))/Performance_Window;
    else
        this_Perfromance=sum(IsTrialCorrect(tidx-Performance_Window+1:tidx))/Performance_Window;
    end
    
    trialVariables(tidx).Performance=this_Perfromance;
    
    this_trialDef=trialDefs{tidx};
    this_RelevantStims=this_trialDef.RelevantStims;
    this_Token_Gain=this_trialDef.TokenRewardsPositive.NumTokens;
    this_Token_Loss=this_trialDef.TokenRewardsNegative.NumTokens;
    
    this_SelectedObjectID=SelectedObjectID{tidx};
    this_SelectedObjectID_idx=str2double(regexp(this_SelectedObjectID,'\d*','Match'));
    
    if isempty(this_SelectedObjectID_idx)
        this_SelectedObjectDimVals=[];
    else
        this_SelectedObjectDimVals=this_RelevantStims(this_SelectedObjectID_idx).StimDimVals;
    end
    
    this_NumDimensions=length(this_SelectedObjectDimVals);
    this_ObjectNumZeroDim=sum(this_SelectedObjectDimVals==0);
    
    this_trialDimensionality=this_NumDimensions-this_ObjectNumZeroDim;

    trialVariables(tidx).SelectedObjectDimVals=this_SelectedObjectDimVals;
    trialVariables(tidx).Dimensionality=this_trialDimensionality;
    trialVariables(tidx).Gain=this_Token_Gain;
    trialVariables(tidx).Loss=this_Token_Loss;
    
    Previous_Trial=NaN;
    
    if tidx>1
        Previous_Trial=CorrectTrial(tidx-1);
    end
    
    trialVariables(tidx).PreviousTrialCorrect=Previous_Trial;
end

%%

SelectedObjectDimVals_AllTrials=[trialVariables(:).SelectedObjectDimVals];

NumFeatureDim=min(size(SelectedObjectDimVals_AllTrials));

FeatureValues=cell(1,NumFeatureDim);

for didx=1:NumFeatureDim
    
    this_FeatureValues=unique(SelectedObjectDimVals_AllTrials(didx,:));
    this_FeatureValues(this_FeatureValues==0)=[];
    FeatureValues{didx}=this_FeatureValues;
    
end

FeatureValues_Names=categorical({'Shape','Pattern','Color','Texture','Arms'});

NumAllFeatures=9;

All_FeatureDimensions={2,2,2,3,3,3,5,5,5};
All_FeatureValues={2,7,8,4,6,8,1,7,10};

for fidx=1:NumAllFeatures
this_FeatureDimension=All_FeatureDimensions{fidx};
this_FeatureValue=All_FeatureValues{fidx};

this_TrialCondition=cell(1,length(trialVariables));
for tidx=1:length(trialVariables)
this_FeatureVector=trialVariables(tidx).SelectedObjectDimVals;
if ~(isempty(this_FeatureVector))

    this_TrialCondition{tidx}=this_FeatureVector(this_FeatureDimension);
else
    this_TrialCondition{tidx}=[];
end  
end
TrialCondition_Feature{fidx}=this_TrialCondition;
MatchValue_Feature{fidx}=this_FeatureValue;

end


%%
PLOTPARAMETERS_FIGURE_cgg_DecisionAlignedPlots;

%%

Time_Data=linspace(-Window_Before_Data,Window_After_Data,NumSamples_Data);
Time_Baseline=linspace(-Window_Before_Baseline,Window_After_Baseline,NumSamples_Baseline);
%%

NumFigures=length(MatchValue_All);

for fidx=1:NumFigures
this_TrialCondition=TrialCondition_All{fidx};
this_MatchValue=MatchValue_All{fidx};

NumMultiplePlot=length(this_MatchValue);
%%

MatchData=cell(1);
MatchBaseline=cell(1);

for midx=1:NumMultiplePlot
[MatchData{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition{midx},this_MatchValue{midx},TrialVariableTrialNumber,this_Selected_Data,TrialNumbers_Data);
[MatchBaseline{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition{midx},this_MatchValue{midx},TrialVariableTrialNumber,this_Selected_Baseline,TrialNumbers_Baseline);
end
%%

if fidx>1
MatchData_Rewarded=cell(1);
MatchBaseline_Rewarded=cell(1);

MatchData_Unrewarded=cell(1);
MatchBaseline_Unrewarded=cell(1);

for midx=1:NumMultiplePlot
    
[this_TrialCondition_Rewarded,this_MatchValue_Rewarded] = cgg_addTrialCriteria(this_TrialCondition{midx},this_MatchValue{midx},Single_TrialCondition_Rewarded,Single_MatchValue_Rewarded);
[this_TrialCondition_Unrewarded,this_MatchValue_Unrewarded] = cgg_addTrialCriteria(this_TrialCondition{midx},this_MatchValue{midx},Single_TrialCondition_Unrewarded,Single_MatchValue_Unrewarded);
    
[MatchData_Rewarded{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition_Rewarded,this_MatchValue_Rewarded,TrialVariableTrialNumber,this_Selected_Data,TrialNumbers_Data);
[MatchBaseline_Rewarded{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition_Rewarded,this_MatchValue_Rewarded,TrialVariableTrialNumber,this_Selected_Baseline,TrialNumbers_Baseline);

[MatchData_Unrewarded{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition_Unrewarded,this_MatchValue_Unrewarded,TrialVariableTrialNumber,this_Selected_Data,TrialNumbers_Data);
[MatchBaseline_Unrewarded{midx}] = cgg_getSeparateTrialsByCriteria_v2(this_TrialCondition_Unrewarded,this_MatchValue_Unrewarded,TrialVariableTrialNumber,this_Selected_Baseline,TrialNumbers_Baseline);
end
end
%%

% FullBaseline=0;

Mean_Norm_InData=cell(1);
Mean_Norm_InBaseline=cell(1);
STD_ERROR_Norm_InData=cell(1);
STD_ERROR_Norm_InBaseline=cell(1);
for midx=1:NumMultiplePlot
[Mean_Norm_InData{midx},Mean_Norm_InBaseline{midx},...
    STD_ERROR_Norm_InData{midx},STD_ERROR_Norm_InBaseline{midx}] = ...
    cgg_procTrialNormalization_v2(MatchData{midx},MatchBaseline{midx},FullBaseline);
end

%%

if fidx>1

Mean_Norm_InData_Rewarded=cell(1);
Mean_Norm_InBaseline_Rewarded=cell(1);
STD_ERROR_Norm_InData_Rewarded=cell(1);
STD_ERROR_Norm_InBaseline_Rewarded=cell(1);
for midx=1:NumMultiplePlot
[Mean_Norm_InData_Rewarded{midx},Mean_Norm_InBaseline_Rewarded{midx},...
    STD_ERROR_Norm_InData_Rewarded{midx},STD_ERROR_Norm_InBaseline_Rewarded{midx}] = ...
    cgg_procTrialNormalization_v2(MatchData_Rewarded{midx},MatchBaseline_Rewarded{midx},FullBaseline);
end

Mean_Norm_InData_Unrewarded=cell(1);
Mean_Norm_InBaseline_Unrewarded=cell(1);
STD_ERROR_Norm_InData_Unrewarded=cell(1);
STD_ERROR_Norm_InBaseline_Unrewarded=cell(1);
for midx=1:NumMultiplePlot
[Mean_Norm_InData_Unrewarded{midx},Mean_Norm_InBaseline_Unrewarded{midx},...
    STD_ERROR_Norm_InData_Unrewarded{midx},STD_ERROR_Norm_InBaseline_Unrewarded{midx}] = ...
    cgg_procTrialNormalization_v2(MatchData_Unrewarded{midx},MatchBaseline_Unrewarded{midx},FullBaseline);
end

Mean_Norm_InData_Separate=[Mean_Norm_InData_Rewarded,Mean_Norm_InData_Unrewarded];
Mean_Norm_InBaseline_Separate=[Mean_Norm_InBaseline_Rewarded,Mean_Norm_InBaseline_Unrewarded];
STD_ERROR_Norm_InData_Separate=[STD_ERROR_Norm_InData_Rewarded,STD_ERROR_Norm_InData_Unrewarded];
STD_ERROR_Norm_InBaseline_Separate=[STD_ERROR_Norm_InBaseline_Rewarded,STD_ERROR_Norm_InBaseline_Unrewarded];

end



%%

InData_Legend_Name=InData_Legend_Name_All{fidx};
InBaseline_Legend_Name=InBaseline_Legend_Name_All{fidx};
InData_X_Name=InData_X_Name_All{fidx};
InBaseline_X_Name=InBaseline_X_Name_All{fidx};
InData_Title=InData_Title_All{fidx};
InBaseline_Title=InBaseline_Title_All{fidx};
InYLim=InYLim_All{fidx};
InYLim=[-3,3];
Smooth_Factor=Smooth_Factor_All{fidx};
Smooth_Factor=1;
InSavePlotCFG=InSavePlotCFG_All{fidx};
InSaveName=InSaveName_All{fidx};
InSaveDescriptor=InSaveDescriptor_All{fidx};
Plot_Colors=Plot_Colors_All{fidx};

InData_Title_Rewarded=[InData_Title ' (Rewarded Trials)'];
InData_Title_Unrewarded=[InData_Title ' (Unrewarded Trials)'];
InData_Title_Combined=[InData_Title ' (All Trials)'];

InBaseline_Title_Rewarded=[InBaseline_Title ' (Rewarded Trials)'];
InBaseline_Title_Unrewarded=[InBaseline_Title ' (Unrewarded Trials)'];
InBaseline_Title_Combined=[InBaseline_Title ' (All Trials)'];

InData_Legend_Name_Separate=cell(1);
InBaseline_Legend_Name_Separate=cell(1);
InSaveDescriptor_Separate=cell(1);
for midx=1:NumMultiplePlot
InData_Legend_Name_Separate{midx}=[InData_Legend_Name{midx}, ' (Rewarded)'];
InData_Legend_Name_Separate{midx+NumMultiplePlot}=[InData_Legend_Name{midx}, ' (Unrewarded)'];
InBaseline_Legend_Name_Separate{midx}=[InBaseline_Legend_Name{midx}, ' (Rewarded)'];
InBaseline_Legend_Name_Separate{midx+NumMultiplePlot}=[InBaseline_Legend_Name{midx}, ' (Unrewarded)'];
InSaveDescriptor_Separate{midx}=[InSaveDescriptor{midx}, '_Rewarded'];
InSaveDescriptor_Separate{midx+NumMultiplePlot}=[InSaveDescriptor{midx}, '_Unrewarded'];
end

if fidx>1
%% Rewarded

cgg_plotSelectTrialConditions(Mean_Norm_InData_Rewarded,...
    Mean_Norm_InBaseline_Rewarded,STD_ERROR_Norm_InData_Rewarded,...
    STD_ERROR_Norm_InBaseline_Rewarded,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Rewarded,...
    InBaseline_Title_Rewarded,InYLim,Smooth_Factor,InSavePlotCFG.Rewarded,InSaveName,'Plot_Colors',Plot_Colors);

cgg_plotAllTrialConditions(Mean_Norm_InData_Rewarded,Mean_Norm_InBaseline_Rewarded,...
    STD_ERROR_Norm_InData_Rewarded,STD_ERROR_Norm_InBaseline_Rewarded,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Rewarded,InBaseline_Title_Rewarded,...
    InYLim,Smooth_Factor,InSavePlotCFG.Rewarded,InSaveName,InSaveDescriptor);

%% Unrewarded

cgg_plotSelectTrialConditions(Mean_Norm_InData_Unrewarded,...
    Mean_Norm_InBaseline_Unrewarded,STD_ERROR_Norm_InData_Unrewarded,...
    STD_ERROR_Norm_InBaseline_Unrewarded,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Unrewarded,...
    InBaseline_Title_Unrewarded,InYLim,Smooth_Factor,InSavePlotCFG.Unrewarded,InSaveName,'Plot_Colors',Plot_Colors);

cgg_plotAllTrialConditions(Mean_Norm_InData_Unrewarded,Mean_Norm_InBaseline_Unrewarded,...
    STD_ERROR_Norm_InData_Unrewarded,STD_ERROR_Norm_InBaseline_Unrewarded,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Unrewarded,InBaseline_Title_Unrewarded,...
    InYLim,Smooth_Factor,InSavePlotCFG.Unrewarded,InSaveName,InSaveDescriptor);

%% Separate

cgg_plotSelectTrialConditions(Mean_Norm_InData_Separate,...
    Mean_Norm_InBaseline_Separate,STD_ERROR_Norm_InData_Separate,...
    STD_ERROR_Norm_InBaseline_Separate,Time_Data,Time_Baseline,...
    InData_Legend_Name_Separate,InBaseline_Legend_Name_Separate,...
    InData_X_Name,InBaseline_X_Name,InData_Title,...
    InBaseline_Title,InYLim,Smooth_Factor,InSavePlotCFG.Separate,InSaveName,'Plot_Colors',Plot_Colors);

cgg_plotAllTrialConditions(Mean_Norm_InData_Separate,Mean_Norm_InBaseline_Separate,...
    STD_ERROR_Norm_InData_Separate,STD_ERROR_Norm_InBaseline_Separate,Time_Data,Time_Baseline,...
    InData_Legend_Name_Separate,InBaseline_Legend_Name_Separate,...
    InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,...
    InYLim,Smooth_Factor,InSavePlotCFG.Separate,InSaveName,InSaveDescriptor_Separate);


%% Combined

cgg_plotSelectTrialConditions(Mean_Norm_InData,...
    Mean_Norm_InBaseline,STD_ERROR_Norm_InData,...
    STD_ERROR_Norm_InBaseline,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Combined,...
    InBaseline_Title_Combined,InYLim,Smooth_Factor,InSavePlotCFG.Combined,InSaveName,'Plot_Colors',Plot_Colors);

cgg_plotAllTrialConditions(Mean_Norm_InData,Mean_Norm_InBaseline,...
    STD_ERROR_Norm_InData,STD_ERROR_Norm_InBaseline,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Combined,InBaseline_Title_Combined,...
    InYLim,Smooth_Factor,InSavePlotCFG.Combined,InSaveName,InSaveDescriptor);

else 
%% Combined

cgg_plotSelectTrialConditions(Mean_Norm_InData,...
    Mean_Norm_InBaseline,STD_ERROR_Norm_InData,...
    STD_ERROR_Norm_InBaseline,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title,...
    InBaseline_Title,InYLim,Smooth_Factor,InSavePlotCFG,InSaveName,'Plot_Colors',Plot_Colors);

cgg_plotAllTrialConditions(Mean_Norm_InData,Mean_Norm_InBaseline,...
    STD_ERROR_Norm_InData,STD_ERROR_Norm_InBaseline,Time_Data,Time_Baseline,...
    InData_Legend_Name,InBaseline_Legend_Name,...
    InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,...
    InYLim,Smooth_Factor,InSavePlotCFG,InSaveName,InSaveDescriptor);    
end

end
%% Regrression Analysis

% 1 indicates the trial is valid. 0 indicates the trial is not valid
[MatchArray_Input] = cgg_getTrialIndexByCriteria(TrialCondition_Baseline,MatchValue_Baseline);

% 1 indicates the trial is rewarded. 0 indicates the trial is not rewarded
[MatchArray_Rewarded] = cgg_getTrialIndexByCriteria(TrialCondition_Rewarded,MatchValue_Rewarded);

% 1 indicates the trial occurs after the learning point. 0 indicates the
% trial occurs after the learning point
[MatchArray_Learned] = cgg_getTrialIndexByCriteria(TrialCondition_Learned,MatchValue_Learned);

% 1 indicates the trial has 2 dimensional objects. 0 indicates the trial
% does not have 2 dimensional objects
[MatchArray_Attention_2] = cgg_getTrialIndexByCriteria(TrialCondition_Attention_3,MatchValue_Attention_2);

% 1 indicates the trial has 3 dimensional objects. 0 indicates the trial
% does not have 3 dimensional objects
[MatchArray_Attention_3] = cgg_getTrialIndexByCriteria(TrialCondition_Attention_3,MatchValue_Attention_3);

% 0 in MatchArray_Attention_2 and MatchArray_Attention_3 indicates the
% object has 1 dimension

% 1 indicates the trial has a gain of 3 tokens. 0 indicates the trial has a
% gain of 2 tokens
[MatchArray_Gain] = cgg_getTrialIndexByCriteria(TrialCondition_Gain,MatchValue_Gain);

% 1 indicates the trial has a loss of 3 tokens. 0 indicates the trial has a
% loss of 1 token.
[MatchArray_Loss] = cgg_getTrialIndexByCriteria(TrialCondition_Loss,MatchValue_Loss);

% 1 indicates the previous trial was rewarded. 0 indicates the previous
% trial was not rewarded
[MatchArray_Previous] = cgg_getTrialIndexByCriteria(TrialCondition_Previous_1,MatchValue_Previous_1);

for fidx=1:NumAllFeatures
    
    % 1 indicates the feature was part of the chosen object. 0 indicates
    % the feature was not part of the chosen object
    [MatchArray_Chosen{fidx}] = cgg_getTrialIndexByCriteria(TrialCondition_Chosen{fidx},MatchValue_Chosen{fidx});
    
    % 0 in MatchArray_Chosen{1:3} indicates there is no feature for the
    % first dimension
    % 0 in MatchArray_Chosen{4:6} indicates there is no feature for the
    % second dimension
    % 0 in MatchArray_Chosen{7:9} indicates there is no feature for the
    % third dimension
    
end

MatchArray_Full=NaN(length(MatchArray_Rewarded),1);

MatchArray_Full(:,1)=MatchArray_Rewarded;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Learned;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Attention_2;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Attention_3;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Gain;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Loss;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full(:,NumCondArray+1)=MatchArray_Previous;

[~,NumCondArray]=size(MatchArray_Full);

% for fidx=1:NumAllFeatures-1
% MatchArray_Full(:,fidx+NumCondArray)=MatchArray_Chosen{fidx};
% end

MatchArray_Full_Ones=MatchArray_Full;
[~,NumCondArray]=size(MatchArray_Full);
MatchArray_Full_Ones(:,1+NumCondArray)=MatchArray_Input;

%%

[FitData,TrialNumbers_Data_NotFound,TrialNumbers_Condition_NotFound] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,this_Selected_Data,TrialNumbers_Data);
[FitBaseline,TrialNumbers_Data_NotFound_Baseline,TrialNumbers_Condition_NotFound_Baseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,this_Selected_Baseline,TrialNumbers_Baseline);

% [FitData_Norm_Mean,FitBaseline_Norm_Mean,~,~,FitData_Norm,FitBaseline_Norm] = ...
%     cgg_procTrialNormalization_v2(FitData,FitBaseline,FullBaseline);

this_FitaData=FitData;
this_FitBaseline=FitBaseline;

[NumChannels,NumSamplesData,NumValidTrials]=size(this_FitaData);
[NumChannels,NumSamplesBaseline,NumValidTrials]=size(this_FitBaseline);
Regress_Period=1;
% this_Match_Array=[MatchArray_Rewarded,ones(size(MatchArray_Rewarded))];
this_Match_Array=MatchArray_Full;

[NumTrialsMatchArray,NumMatchArray]=size(this_Match_Array);

this_Match_Array_Ones=[this_Match_Array,ones(NumTrialsMatchArray,1)];

P_Value_Data=NaN(NumChannels,NumSamplesData,1);
R_Value_Data=NaN(NumChannels,NumSamplesData,1);

MatchArray_Fit=this_Match_Array((MatchArray_Input==1)&(~TrialNumbers_Condition_NotFound),:);
MatchArray_Fit_Ones=this_Match_Array_Ones((MatchArray_Input==1)&(~TrialNumbers_Condition_NotFound),:);


%%

parfor sidx=1:NumSamplesData
%     sidx=2000;
    
this_DataSection_Start=sidx-floor(Regress_Period/2);
this_DataSection_End=sidx+floor(Regress_Period/2)-(rem(Regress_Period, 2) == 0);

if this_DataSection_Start<1
    this_DataSection_Start=1;
end
if this_DataSection_End>NumSamplesData
    this_DataSection_End=NumSamplesData;
end

this_DataSection=this_DataSection_Start:this_DataSection_End;

FitData_sel=this_FitaData(:,this_DataSection,:);

FitData_sel=mean(FitData_sel,2);

FitData_sel=squeeze(FitData_sel);

for cidx=1:NumChannels
%         cidx=39;

this_Channel=cidx;

FitData_sel_channel=diag(diag(FitData_sel(this_Channel,:)));

% [b,bint,r,rint,stats] = regress(FitData_sel_channel,MatchArray_Fit_Ones);

mdl = fitlm(MatchArray_Fit,FitData_sel_channel,'CategoricalVars',1:NumMatchArray);

mdl_summary=anova(mdl,'summary');

P_Value_Data(cidx,sidx)=mdl_summary.pValue(2);

% P_Value_Data(cidx,sidx)=stats(3);
R_Value_Data(cidx,sidx)=mdl.Rsquared.Ordinary;

end

sidx

end

%%%

P_Value_Baseline=NaN(NumChannels,NumSamplesBaseline,1);
R_Value_Baseline=NaN(NumChannels,NumSamplesBaseline,1);

parfor sidx=1:NumSamplesBaseline
    
    
this_BaselineSection_Start=sidx-floor(Regress_Period/2);
this_BaselineSection_End=sidx+floor(Regress_Period/2)-(rem(Regress_Period, 2) == 0);

if this_BaselineSection_Start<1
    this_BaselineSection_Start=1;
end
if this_BaselineSection_End>NumSamplesBaseline
    this_BaselineSection_End=NumSamplesBaseline;
end

this_BaselineSection=this_BaselineSection_Start:this_BaselineSection_End;

FitBaseline_sel=this_FitBaseline(:,this_BaselineSection,:);

FitBaseline_sel=mean(FitBaseline_sel,2);

FitBaseline_sel=squeeze(FitBaseline_sel);

for cidx=1:NumChannels
    


this_Channel=cidx;

FitBaseline_sel_channel=diag(diag(FitBaseline_sel(this_Channel,:)));

% [b,bint,r,rint,stats] = regress(FitBaseline_sel_channel,MatchArray_Fit_Ones);

mdl = fitlm(MatchArray_Fit,FitBaseline_sel_channel,'CategoricalVars',1:NumMatchArray);

mdl_summary=anova(mdl,'summary');

P_Value_Baseline(cidx,sidx)=mdl_summary.pValue(2);

% P_Value_Baseline(cidx,sidx)=stats(3);
R_Value_Baseline(cidx,sidx)=mdl.Rsquared.Ordinary;

end

sidx

end

%%%

InData_X_Name=InData_X_Name_All{1};
InBaseline_X_Name=InBaseline_X_Name_All{1};

InData_Title_P='Significance from Regression';
InBaseline_Title_P=InData_Title_P;
InData_Title_R='R^2 Value from Regression';
InBaseline_Title_R=InData_Title_R;
InData_Title_Plog='-log(P Value)';
InBaseline_Title_Plog=InData_Title_Plog;

InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;

InSaveName_P='Significance_Decision_Aligned_All_Regressors_Low_Significance';
InSaveName_R='R_Squared_Decision_Aligned_All_Regressors_Low_Significance';
InSaveName_Plog='PLog_Decision_Aligned_All_Regressors_Low_Significance';

InSaveDescriptor='';

Significance_Value=0.01;

InP_ValueData=P_Value_Data;
InP_ValueBaseline=P_Value_Baseline;
InData_Time=Time_Data;
InBaseline_Time=Time_Baseline;


InData_Title=InData_Title_P;
InBaseline_Title=InBaseline_Title_P;

InSaveName=InSaveName_P;

cgg_plotAllTrialSignificance(P_Value_Data,P_Value_Baseline,Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_P,InBaseline_Title_P,InSavePlotCFG,InSaveName_P,InSaveDescriptor,Significance_Value);

cgg_plotAllTrialRValue(R_Value_Data,R_Value_Baseline,Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_R,InBaseline_Title_R,InSavePlotCFG,InSaveName_R,InSaveDescriptor,Significance_Value);

cgg_plotAllTrialRValue(-log(P_Value_Data),-log(P_Value_Baseline),Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_Plog,InBaseline_Title_Plog,InSavePlotCFG,InSaveName_Plog,InSaveDescriptor,Significance_Value);

% save("April_10_2023","P_Value");

