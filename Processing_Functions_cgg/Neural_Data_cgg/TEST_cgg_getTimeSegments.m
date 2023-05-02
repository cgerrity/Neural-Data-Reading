%% Test of cgg_getTimeSegments


Current_Folder_Names=split(pwd,filesep);

if strcmp(Current_Folder_Names{2},'data')
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
probe_area='CD_001';
Activity_Type='MUA';


%%
Frame_Event_Selection = 'SelectObject';
Frame_Event_Selection_Location = 'END';
Window_Before_Data = 1;
Window_After_Data = 1.5;

% [Start_IDX_Ana,End_IDX_Ana] = cgg_getTimeSegments(...
%     'inputfolder',inputfolder,'outdatadir',outdatadir,'probe_area',...
%     probe_area,'Frame_Event_Selection',Frame_Event_Selection,...
%     'Frame_Event_Selection_Location',Frame_Event_Selection_Location,...
%     'Frame_Event_Window_Before',Frame_Event_Window_Before_Ana,...
%     'Frame_Event_Window_After',Frame_Event_Window_After_Ana);

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

% [Start_IDX_Base,End_IDX_Base] = cgg_getTimeSegments(...
%     'inputfolder',inputfolder,'outdatadir',outdatadir,'probe_area',...
%     probe_area,'Frame_Event_Selection',Frame_Event_Selection,...
%     'Frame_Event_Selection_Location',Frame_Event_Selection_Location,...
%     'Frame_Event_Window_Before',Frame_Event_Window_Before_Baseline,...
%     'Frame_Event_Window_After',Frame_Event_Window_After_Baseline);

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

[outplotdir_WideBand,outplotdir_LFP,outplotdir_Spike,...
    outplotdir_MUA,cfg_outplotdir] = cgg_generateNeuralPlottingFolders(...
    outdatadir,SessionName,ExperimentName,probe_area);

%%

fullfilename=[outdatadir_MUA filesep 'MUA_Trial_%d.mat'];

[Segmented_Data,TrialNumbers_Data] = cgg_getAllTrialDataFromTimeSegments(Start_IDX_Data,End_IDX_Data,fullfilename,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[Segmented_Baseline,TrialNumbers_Baseline] = cgg_getAllTrialDataFromTimeSegments(Start_IDX_Base,End_IDX_Base,fullfilename,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[NumChannels,NumSamples_Data,~]=size(Segmented_Data);
[~,NumSamples_Baseline,~]=size(Segmented_Baseline);

%%

% trial_file_name
% 
% outdatafile_TrialInformation=...
%    sprintf([outdatadir_TrialInformation filesep ...
%    'Trial_Definition_%s.mat'],SessionName);
% 
% [AllDataFT] = cgg_gatherTrialsIntoOneVariable(trial_file_name,outdatafile_TrialInformation,StartTrial,EndTrial)

%%
exptType='FLU';
dataFolder=[inputfolder_base '/DATA_neural/Wotan/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01/Session39__23_02_2023__10_34_03'];
gazeArgs='TX300';
outdatadir_LT=[outputfolder_base '/Data_Neural_gerritcg/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];

% [trialData, blockData] = ProcessSingleSessionData_FLU('exptType',exptType,'dataFolder',dataFolder,'gazeArgs',gazeArgs);
[trialData, blockData] = ProcessSingleSessionData_FLU('exptType',exptType,'gazeArgs',gazeArgs,'outdatadir',outdatadir_LT,'dataFolder',dataFolder);
% [trialData, blockData] = ProcessSingleSubjectData_FLU('exptType',exptType,'dataFolder',dataFolder,'gazeArgs',gazeArgs);

folder_name = 'Wo_Probe_01_23-02-23_008_01';
session_file = 'Session39__23_02_2023__10_34_03';
data_path = [inputfolder_base '/DATA_neural/Wotan/Wotan_FLToken_Probe_01'];
Area = 1; %1 = ACC, 2 = CD
MnkID = 1; %1 = Frey

proccessed_path = [outputfolder_base '/Data_Neural_gerritcg/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];

% folder_name = 'Fr_Probe_02_22-05-09_009_01';
% session_file = 'Session13__09_05_2022__09_32_46';
% data_path = ['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'];
% Area = 1; %1 = ACC, 2 = CD
% MnkID = 1; %1 = Frey

[TrialDATA, BlockDATA]  = singlesession_data_LT3(folder_name, session_file, data_path,proccessed_path, Area, MnkID);
%%
trialDefsFolder=[proccessed_path, filesep, 'ProcessedData', filesep, 'TrialDefs.mat'];
load(trialDefsFolder);
%%

TrialNumber=trialData.TrialCounter;
TrialInBlock=trialData.TrialInBlock;
AbortCode=trialData.AbortCode;
SelectedObjectID=trialData.SelectedObjectID;
CorrectTrial=trialData.PositiveFbObtained;
TrialsFromLP=trialData.TrialsFromLP;
TrialTime=trialData.TrialTime;

trialVariables=struct();

for tidx=1:length(TrialNumber)
    
    trialVariables(tidx).TrialNumber=TrialNumber(tidx);
    trialVariables(tidx).TrialInBlock=TrialInBlock(tidx);
    trialVariables(tidx).AbortCode=AbortCode(tidx);
    trialVariables(tidx).CorrectTrial=CorrectTrial(tidx);
    trialVariables(tidx).TrialsFromLP=TrialsFromLP(tidx);
    trialVariables(tidx).TrialTime=TrialTime(tidx);
    
    this_trialDef=trialDefs{tidx};
    this_RelevantStims=this_trialDef.RelevantStims;
    
    this_SelectedObjectID=SelectedObjectID{tidx};
    this_SelectedObjectID_idx=str2double(regexp(this_SelectedObjectID,'\d*','Match'));
    
    if isempty(this_SelectedObjectID_idx)
        this_SelectedObjectDimVals=[];
    else
        this_SelectedObjectDimVals=this_RelevantStims(this_SelectedObjectID_idx).StimDimVals;
    end
    
    
%     for sidx=1:length(this_RelevantStims)
%         this_StimID=this_RelevantStims(sidx).StimID;
%         if strcmp(this_StimID,this_SelectedObjectID)
%             this_SelectedObjectDimVals=this_RelevantStims(sidx).StimDimVals;
%         else
%             this_SelectedObjectDimVals=[];
%         end
%     end

    trialVariables(tidx).SelectedObjectDimVals=this_SelectedObjectDimVals;
    
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


%%
TrialDuration_Minimum=10;
TrialVariableTrialNumber=[trialVariables(:).TrialNumber];
NumTrialVariable=length(TrialVariableTrialNumber);

TrialCondition=cell(NumTrialVariable,1);

TrialCondition(:,1)={trialVariables(:).AbortCode};
TrialCondition(:,2)={trialVariables(:).TrialTime};
TrialCondition(:,2)=cellfun(@(x){~isempty(x) && x >= TrialDuration_Minimum}, TrialCondition(:,2));
TrialCondition(:,3)=[trialVariables(:).CorrectTrial];

MatchValue=cell(1);
MatchValue{1,1}=0;
MatchValue{1,2}=0;
MatchValue{1,3}='True';

MatchValue_UnRewarded=MatchValue;
MatchValue_UnRewarded{1,3}='False';

MatchValue_Multiple=cell(1);
TrialCondition_Multiple=cell(1);

MatchValue_Multiple{1}=MatchValue;
MatchValue_Multiple{2}=MatchValue_UnRewarded;
TrialCondition_Multiple{1}=TrialCondition;
TrialCondition_Multiple{2}=TrialCondition;

TrialCondition_Baseline=cell(NumTrialVariable,1);
TrialCondition_Baseline(:,1:2)=TrialCondition(:,1:2);
MatchValue_Baseline=cell(1);
MatchValue_Baseline{1,1}=0;
MatchValue_Baseline{1,2}=0;

NumMultiplePlot=length(MatchValue_Multiple);
%%
% [MatchArray] = cgg_getTrialIndexByCriteria(TrialCondition,MatchValue);

% [MatchData] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition,MatchValue,TrialVariableTrialNumber,Segmented_Data,TrialNumbers_Data);
% [MatchBaseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition,MatchValue,TrialVariableTrialNumber,Segmented_Baseline,TrialNumbers_Baseline);

MatchData_Multiple=cell(1);
MatchBaseline_Multiple=cell(1);

for midx=1:NumMultiplePlot
[MatchData_Multiple{midx}] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Multiple{midx},MatchValue_Multiple{midx},TrialVariableTrialNumber,Segmented_Data,TrialNumbers_Data);
[MatchBaseline_Multiple{midx}] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Multiple{midx},MatchValue_Multiple{midx},TrialVariableTrialNumber,Segmented_Baseline,TrialNumbers_Baseline);
end

[FullBaseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,Segmented_Baseline,TrialNumbers_Baseline);

% [Mean_Norm_InData,Mean_Norm_InBaseline,...
%     STD_ERROR_Norm_InData,STD_ERROR_Norm_InBaseline] = ...
%     cgg_procTrialNormalization_v2(MatchData,MatchBaseline,FullBaseline);

Mean_Norm_InData_Multiple=cell(1);
Mean_Norm_InBaseline_Multiple=cell(1);
STD_ERROR_Norm_InData_Multiple=cell(1);
STD_ERROR_Norm_InBaseline_Multiple=cell(1);
for midx=1:NumMultiplePlot
[Mean_Norm_InData_Multiple{midx},Mean_Norm_InBaseline_Multiple{midx},...
    STD_ERROR_Norm_InData_Multiple{midx},STD_ERROR_Norm_InBaseline_Multiple{midx}] = ...
    cgg_procTrialNormalization_v2(MatchData_Multiple{midx},MatchBaseline_Multiple{midx},FullBaseline);
end

Time_Data=linspace(-Window_Before_Data,Window_After_Data,NumSamples_Data);
Time_Baseline=linspace(-Window_Before_Baseline,Window_After_Baseline,NumSamples_Baseline);

%%

InData_Legend_Name='Rewarded';
InBaseline_Legend_Name='Rewarded';
InData_X_Name='Time From Decision(sec)';
InBaseline_X_Name='Time From Start of Trial(sec)';
InData_Title='Rewarded Trials Channel:%d';
InBaseline_Title='Rewarded Trials Channel:%d';
InYLim=[-0.2,0.2];
Smooth_Factor=250;
InSaveName=[cfg_outplotdir.outdatadir_MUA_Decision_Error_Status_All ...
    filesep 'Correct_vs_Incorrect_Decision_Aligned_Channel_%d'];

InData_Legend_Name_Multiple={'Rewarded','Unrewarded'};
InBaseline_Legend_Name_Multiple={'Rewarded','Unrewarded'};
InData_Title_Multiple='Rewarded vs Unrewarded Trials Channel:%d';
InBaseline_Title_Multiple='Rewarded vs Unrewarded Trials Channel:%d';

Plot_Colors_Multiple={'#0072BD','#D95319'};

% cgg_plotSelectTrialConditions(Mean_Norm_InData,Mean_Norm_InBaseline,...
%     STD_ERROR_Norm_InData,STD_ERROR_Norm_InBaseline,...
%     Time_Data,Time_Baseline,InData_Legend_Name,InBaseline_Legend_Name,...
%     InData_X_Name,InBaseline_X_Name,InData_Title,InBaseline_Title,...
%     InYLim,Smooth_Factor,InSaveName)

cgg_plotSelectTrialConditions(Mean_Norm_InData_Multiple,...
    Mean_Norm_InBaseline_Multiple,STD_ERROR_Norm_InData_Multiple,...
    STD_ERROR_Norm_InBaseline_Multiple,Time_Data,Time_Baseline,...
    InData_Legend_Name_Multiple,InBaseline_Legend_Name_Multiple,...
    InData_X_Name,InBaseline_X_Name,InData_Title_Multiple,...
    InBaseline_Title_Multiple,InYLim,Smooth_Factor,InSaveName,'Plot_Colors',Plot_Colors_Multiple)

%%
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

%%
Start_IDX=Start_IDX_Data;
End_IDX=End_IDX_Data;
Start_IDX_Baseline=Start_IDX_Base;
End_IDX_Baseline=End_IDX_Base;
trial_file_name=[outdatadir_MUA filesep 'MUA_Trial_%d.mat'];
TrialCondition=this_TrialCondition;
MatchValue=this_FeatureValue;
TrialCount=length(TrialNumber)-1;
TrialDuration_Minimum=10; % Seconds over which a trial is considered a bad trial

Window_Before_Data=Window_Before_Data;
Window_After_Data=Window_After_Data;
Window_Before_Baseline=Window_Before_Baseline;
Window_After_Baseline=Window_After_Baseline;


% [All_Trials_Baseline,All_Trials_Data_Match,...
%     All_Trials_Data_NotMatch,All_Trials_Baseline_Match,...
%     All_Trials_Baseline_NotMatch,Trial_Counter_Match,...
%     Trial_Counter_NotMatch] = cgg_getSeparateTrialsByCriteria(...
%     Start_IDX,End_IDX,Start_IDX_Baseline,End_IDX_Baseline,...
%     trial_file_name,trialData,TrialCondition,MatchValue,TrialCount,...
%     TrialDuration_Minimum);

[Data_Match_Norm_Mean{fidx},...
    Data_NotMatch_Norm_Mean{fidx},...
    Baseline_Match_Norm_Mean{fidx},...
    Baseline_NotMatch_Norm_Mean{fidx},...
    Data_Match_Norm_STD_ERROR{fidx},...
    Data_NotMatch_Norm_STD_ERROR{fidx},...
    Baseline_Match_Norm_STD_ERROR{fidx},...
    Baseline_NotMatch_Norm_STD_ERROR{fidx},...
    Time_Data{fidx},Time_Baseline{fidx}] = cgg_procTrialNormalization(...
    Start_IDX,End_IDX,Start_IDX_Baseline,End_IDX_Baseline,...
    trial_file_name,trialData,TrialCondition,MatchValue,TrialCount,...
    TrialDuration_Minimum,Window_Before_Data,Window_After_Data,...
    Window_Before_Baseline,Window_After_Baseline);


%%
All_Trials_Data_Match_Norm_Mean=Data_Match_Norm_Mean{fidx};
All_Trials_Data_NotMatch_Norm_Mean=Data_NotMatch_Norm_Mean{fidx};
All_Trials_Baseline_Match_Norm_Mean=Baseline_Match_Norm_Mean{fidx};
All_Trials_Baseline_NotMatch_Norm_Mean=Baseline_NotMatch_Norm_Mean{fidx};
All_Trials_Data_Match_Norm_STD_ERROR=Data_Match_Norm_STD_ERROR{fidx};
All_Trials_Data_NotMatch_Norm_STD_ERROR=Data_NotMatch_Norm_STD_ERROR{fidx};
All_Trials_Baseline_Match_Norm_STD_ERROR=Baseline_Match_Norm_STD_ERROR{fidx};
All_Trials_Baseline_NotMatch_Norm_STD_ERROR=Baseline_NotMatch_Norm_STD_ERROR{fidx};
All_Time_Data=Time_Data{fidx};
All_Time_Baseline=Time_Baseline{fidx};

%%

% %%
% 
% This_Trial_Counter=0;
% This_Trial_Counter_Correct=0;
% This_Trial_Counter_Error=0;
% 
% All_Trials_Data_Frame_Correct=[];
% All_Trials_Data_Frame_Error=[];
% All_Trials_Data_Single_Valid_Correct=[];
% All_Trials_Data_Single_Valid_Error=[];
% All_Trials_Baseline=[];
% 
% TrialDuration_Minimum=10; % Seconds over which a trial is considered a bad trial
% 
% for tidx=1:length(TrialNumber)-1
%     this_CorrectTrial=trialVariables(tidx).CorrectTrial{:};
%     
%     this_trial=trialData(tidx,:);
%     this_abortcode=this_trial.AbortCode;
%     this_trialduration=this_trial.TrialTime;
%     this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
%     this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
%     
%     if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
%     %
%     This_Trial_Counter=This_Trial_Counter+1;
%        this_trial_MUA_file_name=...
%        sprintf([outdatadir_MUA filesep 'MUA_Trial_%d.mat'],tidx);
%    disp(tidx)
%     m_MUA = load(this_trial_MUA_file_name);
%     this_data_struct=m_MUA.this_recdata_activity;
%     %
%     this_Start_IDX_Ana=Start_IDX_Ana(tidx);
%     this_End_IDX_Ana=End_IDX_Ana(tidx);
%     this_Start_IDX_Base=Start_IDX_Base(tidx);
%     this_End_IDX_Base=End_IDX_Base(tidx);
%     
%     this_Data_Ana=this_data_struct.trial{1}(:,this_Start_IDX_Ana:this_End_IDX_Ana);
%     this_Data_Base=this_data_struct.trial{1}(:,this_Start_IDX_Base:this_End_IDX_Base);
%     this_Time_Ana=this_data_struct.time{1}(:,this_Start_IDX_Ana:this_End_IDX_Ana);
%     this_Time_Base=this_data_struct.time{1}(:,this_Start_IDX_Base:this_End_IDX_Base);
%     
%     All_Trials_Baseline(:,:,This_Trial_Counter)=this_Data_Base;
% 
%         if strcmp(this_CorrectTrial,'True')
%             This_Trial_Counter_Correct=This_Trial_Counter_Correct+1;
%             All_Trials_Data_Frame_Correct(:,:,This_Trial_Counter_Correct)=this_Data_Ana;
%             All_Trials_Data_Single_Valid_Correct(:,:,This_Trial_Counter_Correct)=this_Data_Base;
%         else
%             This_Trial_Counter_Error=This_Trial_Counter_Error+1;
%             All_Trials_Data_Frame_Error(:,:,This_Trial_Counter_Error)=this_Data_Ana;
%             All_Trials_Data_Single_Valid_Error(:,:,This_Trial_Counter_Error)=this_Data_Base;
%         end
%     
%     end
% end

% %%
% All_Trials_Baseline_Mean=mean(All_Trials_Baseline,[2 3]);
% All_Trials_Baseline_STD=std(All_Trials_Baseline,0,[2 3]);
% 
% All_Trials_Ana_Correct_Norm=(All_Trials_Data_Frame_Correct-All_Trials_Baseline_Mean)./All_Trials_Baseline_STD;
% All_Trials_Ana_Error_Norm=(All_Trials_Data_Frame_Error-All_Trials_Baseline_Mean)./All_Trials_Baseline_STD;
% All_Trials_Baseline_Correct_Norm=(All_Trials_Data_Single_Valid_Correct-All_Trials_Baseline_Mean)./All_Trials_Baseline_STD;
% All_Trials_Baseline_Error_Norm=(All_Trials_Data_Single_Valid_Error-All_Trials_Baseline_Mean)./All_Trials_Baseline_STD;
% 
% All_Trials_Data_Match_Norm_Mean=mean(All_Trials_Ana_Correct_Norm,3);
% All_Trials_Data_NotMatch_Norm_Mean=mean(All_Trials_Ana_Error_Norm,3);
% All_Trials_Baseline_Match_Norm_Mean=mean(All_Trials_Baseline_Correct_Norm,3);
% All_Trials_Baseline_NotMatch_Norm_Mean=mean(All_Trials_Baseline_Error_Norm,3);
% 
% All_Trials_Data_Match_Norm_STD_ERROR=std(All_Trials_Ana_Correct_Norm,0,3)/sqrt(This_Trial_Counter_Correct);
% All_Trials_Data_NotMatch_Norm_STD_ERROR=std(All_Trials_Ana_Error_Norm,0,3)/sqrt(This_Trial_Counter_Error);
% All_Trials_Baseline_Match_Norm_STD_ERROR=std(All_Trials_Baseline_Correct_Norm,0,3)/sqrt(This_Trial_Counter_Correct);
% All_Trials_Baseline_NotMatch_Norm_STD_ERROR=std(All_Trials_Baseline_Error_Norm,0,3)/sqrt(This_Trial_Counter_Error);
% 
% All_Time_Data=linspace(-Frame_Event_Window_Before_Ana,...
%     Frame_Event_Window_After_Ana,...
%     length(All_Trials_Data_Match_Norm_Mean));
% All_Time_Baseline=linspace(-Frame_Event_Window_Before_Baseline,...
%     Frame_Event_Window_After_Baseline,...
%     length(All_Trials_Baseline_Match_Norm_Mean));

%%% Plotting


Smooth_Factor=256;

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

% aaaaaa.fig=fig_activity;

figure(fig_activity);

[NumChannels,~]=size(All_Trials_Data_Match_Norm_Mean);

for cidx=1:NumChannels
    
    clf(fig_activity);

sel_channel=cidx;

subplot(1,2,2);


this_Data_Match=All_Trials_Data_Match_Norm_Mean(sel_channel,:);
this_Data_Match_STD=All_Trials_Data_Match_Norm_STD_ERROR(sel_channel,:);
this_Data_Match_Upper=All_Trials_Data_Match_Norm_Mean(sel_channel,:)+this_Data_Match_STD;
this_Data_Match_Lower=All_Trials_Data_Match_Norm_Mean(sel_channel,:)-this_Data_Match_STD;

this_Data_NotMatch=All_Trials_Data_NotMatch_Norm_Mean(sel_channel,:);
this_Data_NotMatch_STD=All_Trials_Data_NotMatch_Norm_STD_ERROR(sel_channel,:);
this_Data_NotMatch_Upper=All_Trials_Data_NotMatch_Norm_Mean(sel_channel,:)+this_Data_NotMatch_STD;
this_Data_NotMatch_Lower=All_Trials_Data_NotMatch_Norm_Mean(sel_channel,:)-this_Data_NotMatch_STD;

this_Data_Match=smoothdata(this_Data_Match,'movmean',Smooth_Factor);
this_Data_Match_Upper=smoothdata(this_Data_Match_Upper,'movmean',Smooth_Factor);
this_Data_Match_Lower=smoothdata(this_Data_Match_Lower,'movmean',Smooth_Factor);

this_Data_NotMatch=smoothdata(this_Data_NotMatch,'movmean',Smooth_Factor);
this_Data_NotMatch_Upper=smoothdata(this_Data_NotMatch_Upper,'movmean',Smooth_Factor);
this_Data_NotMatch_Lower=smoothdata(this_Data_NotMatch_Lower,'movmean',Smooth_Factor);



hold on

p_Data_Match=plot(All_Time_Data,this_Data_Match,'Color','#0072BD','LineWidth',4,'DisplayName', 'Chosen');
plot(All_Time_Data,this_Data_Match_Upper,'Color','#0072BD','LineStyle',':','LineWidth',2);
plot(All_Time_Data,this_Data_Match_Lower,'Color','#0072BD','LineStyle',':','LineWidth',2);

p_Data_NotMatch=plot(All_Time_Data,this_Data_NotMatch,'Color','#D95319','LineWidth',4,'DisplayName', 'Unchosen');
plot(All_Time_Data,this_Data_NotMatch_Upper,'Color','#D95319','LineStyle',':','LineWidth',2);
plot(All_Time_Data,this_Data_NotMatch_Lower,'Color','#D95319','LineStyle',':','LineWidth',2);

xline(0);

hold off

xlabel('Time from Decision(sec)');
ylabel('Normalized Activity');
this_Title_Data=sprintf(...
    'Chosen vs Unchosen Trials Channel:%d Dimension:%d Feature:%d',...
    sel_channel,this_FeatureDimension,this_FeatureValue);
title(this_Title_Data);
legend([p_Data_Match,p_Data_NotMatch]);

ylim([-0.2,0.2]);

% figure;
subplot(1,2,1);

this_Baseline_Match=All_Trials_Baseline_Match_Norm_Mean(sel_channel,:);
this_Baseline_Match_STD=All_Trials_Baseline_Match_Norm_STD_ERROR(sel_channel,:);
this_Baseline_Match_Upper=All_Trials_Baseline_Match_Norm_Mean(sel_channel,:)+this_Baseline_Match_STD;
this_Baseline_Match_Lower=All_Trials_Baseline_Match_Norm_Mean(sel_channel,:)-this_Baseline_Match_STD;

this_Baseline_NotMatch=All_Trials_Baseline_NotMatch_Norm_Mean(sel_channel,:);
this_Baseline_NotMatch_STD=All_Trials_Baseline_NotMatch_Norm_STD_ERROR(sel_channel,:);
this_Baseline_NotMatch_Upper=All_Trials_Baseline_NotMatch_Norm_Mean(sel_channel,:)+this_Baseline_NotMatch_STD;
this_Baseline_NotMatch_Lower=All_Trials_Baseline_NotMatch_Norm_Mean(sel_channel,:)-this_Baseline_NotMatch_STD;

this_Baseline_Match=smoothdata(this_Baseline_Match,'movmean',Smooth_Factor);
this_Baseline_Match_Upper=smoothdata(this_Baseline_Match_Upper,'movmean',Smooth_Factor);
this_Baseline_Match_Lower=smoothdata(this_Baseline_Match_Lower,'movmean',Smooth_Factor);

this_Baseline_NotMatch=smoothdata(this_Baseline_NotMatch,'movmean',Smooth_Factor);
this_Baseline_NotMatch_Upper=smoothdata(this_Baseline_NotMatch_Upper,'movmean',Smooth_Factor);
this_Baseline_NotMatch_Lower=smoothdata(this_Baseline_NotMatch_Lower,'movmean',Smooth_Factor);

hold on

p_Baseline_Match=plot(All_Time_Baseline,this_Baseline_Match,'Color','#0072BD','LineWidth',4,'DisplayName', 'Chosen');
plot(All_Time_Baseline,this_Baseline_Match_Upper,'Color','#0072BD','LineStyle',':','LineWidth',2);
plot(All_Time_Baseline,this_Baseline_Match_Lower,'Color','#0072BD','LineStyle',':','LineWidth',2);

p_Baseline_NotMatch=plot(All_Time_Baseline,this_Baseline_NotMatch,'Color','#D95319','LineWidth',4,'DisplayName', 'Unchosen');
plot(All_Time_Baseline,this_Baseline_NotMatch_Upper,'Color','#D95319','LineStyle',':','LineWidth',2);
plot(All_Time_Baseline,this_Baseline_NotMatch_Lower,'Color','#D95319','LineStyle',':','LineWidth',2);

xline(0);

hold off

xlabel('Time from Start of Trial (sec)');
ylabel('Normalized Activity');
this_Title_Baseline=sprintf(...
    'Chosen vs Unchosen Trials Channel:%d Dimension:%d Feature:%d',...
    sel_channel,this_FeatureDimension,this_FeatureValue);
title(this_Title_Baseline);
legend([p_Baseline_Match,p_Baseline_NotMatch]);

ylim([-0.2,0.2]);
drawnow;

this_figure_save_name=sprintf(...
    [cfg_outplotdir.outdatadir_MUA_Decision_Error_Status_Feature{fidx} ...
    filesep 'Chosen_vs_Unchosen_Decision_Aligned_Channel_%d_Dimension_%d_Feature_%d'],...
    sel_channel,this_FeatureDimension,this_FeatureValue);

saveas(fig_activity,this_figure_save_name,'pdf');

end

end
