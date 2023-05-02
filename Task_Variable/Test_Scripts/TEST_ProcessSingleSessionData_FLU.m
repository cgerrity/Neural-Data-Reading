% clear; clc; close all;

% [trialData, blockData] = ProcessSingleSessionData_FLU;
%%
exptType='FLU';
% dataFolder=['/Volumes/gerritcg''','s home/Data_Neural_gerritcg/Fr_Probe_02_22-05-09_009_01/Session13__09_05_2022__09_32_46'];
gazeArgs='TX300';

% [trialData, blockData] = ProcessSingleSessionData_FLU('exptType',exptType,'dataFolder',dataFolder,'gazeArgs',gazeArgs);
[trialData, blockData] = ProcessSingleSessionData_FLU('exptType',exptType,'gazeArgs',gazeArgs);
% [trialData, blockData] = ProcessSingleSubjectData_FLU('exptType',exptType,'dataFolder',dataFolder,'gazeArgs',gazeArgs);

folder_name = 'Wo_Probe_01_23-02-23_008_01';
session_file = 'Session39__23_02_2023__10_34_03';
data_path = ['/Volumes/','Womelsdorf Lab','/DATA_neural/Wotan/Wotan_FLToken_Probe_01'];
Area = 1; %1 = ACC, 2 = CD
MnkID = 1; %1 = Frey


proccessed_path = ['/Volumes/gerritcg''','s home/Data_Neural_gerritcg/Wotan_FLToken_Probe_01/Wo_Probe_01_23-02-23_008_01'];

% folder_name = 'Fr_Probe_02_22-05-09_009_01';
% session_file = 'Session13__09_05_2022__09_32_46';
% data_path = ['/Volumes/gerritcg''','s home/Data_Neural_gerritcg'];
% Area = 1; %1 = ACC, 2 = CD
% MnkID = 1; %1 = Frey

[TrialDATA, BlockDATA]  = singlesession_data_LT3(folder_name, session_file, data_path,proccessed_path, Area, MnkID);

%% Histogram

NumTrials=height(trialData);
TrialDuration_Minimum=10; % Seconds over which a trial is considered a bad trial

this_session_fixation_durations=[];

for tidx=1:NumTrials
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
        for gidx=1:length(this_trial_objectduration)
            this_objecttype=this_trial_objecttype{gidx, 1};
            
            if this_objecttype==1||this_objecttype==2||this_objecttype==3
            this_objectduration=this_trial_objectduration{gidx, 1};
            this_session_fixation_durations=cat(1,this_session_fixation_durations,this_objectduration);
            end
        end
    end
    
end

this_session_fixation_durations(this_session_fixation_durations>0.7)=[];

histogram(this_session_fixation_durations,25);

xlabel('Time (Sec)');
ylabel('Count');

%%
trialDefsFolder=[dataFolder, filesep, 'ProcessedData', filesep, 'TrialDefs.mat'];
load(trialDefsFolder);

%%

TrialNumber=trialData.TrialCounter;
TrialInBlock=trialData.TrialInBlock;
AbortCode=trialData.AbortCode;
SelectedObjectID=trialData.SelectedObjectID;
CorrectTrial=trialData.PositiveFbObtained;
TrialsFromLP=trialData.TrialsFromLP;

trialVariables=struct();

for tidx=1:length(TrialNumber)
    
    trialVariables(tidx).TrialNumber=TrialNumber(tidx);
    trialVariables(tidx).TrialInBlock=TrialInBlock(tidx);
    trialVariables(tidx).AbortCode=AbortCode(tidx);
    trialVariables(tidx).CorrectTrial=CorrectTrial(tidx);
    trialVariables(tidx).TrialsFromLP=TrialsFromLP(tidx);
    
    this_trialDef=trialDefs{tidx};
    this_RelevantStims=this_trialDef.RelevantStims;
    
    this_SelectedObjectID=SelectedObjectID{tidx};
    
    for sidx=1:length(this_RelevantStims)
        this_StimID=this_RelevantStims(sidx).StimID;
        if strcmp(this_StimID,this_SelectedObjectID)
            this_SelectedObjectDimVals=this_RelevantStims(sidx).StimDimVals;
        end
    end

    trialVariables(tidx).SelectedObjectDimVals=this_SelectedObjectDimVals;
    
end


%%

NumDim=5;
MaxFeatures=10;

ObjectValuesCount=zeros(NumDim,MaxFeatures);

for tidx=1:length(trialVariables)
    this_ObjectValues=trialVariables(tidx).SelectedObjectDimVals;
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
        for didx=1:NumDim
            this_onehotmat = this_ObjectValues == 1:max(this_ObjectValues);
            this_onehotmat = padarray(this_onehotmat,[NumDim,MaxFeatures],0,'post');
            this_onehotmat = this_onehotmat(1:NumDim,1:MaxFeatures);
            ObjectValuesCount=ObjectValuesCount+this_onehotmat;
        end
    end

end


figure;
ObjectValuesCount_Names=categorical({'Shape','Pattern','Color','Texture','Arms'});
ObjectValuesCount_Names=reordercats(ObjectValuesCount_Names,{'Shape','Pattern','Color','Texture','Arms'});
bar(ObjectValuesCount_Names,ObjectValuesCount);


%%

All_Trials_Data_Single_Valid=[];
This_Trial_Counter_Valid=0;

NumTrials=500;

for tidx=1:NumTrials-1
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
        This_Trial_Counter_Valid=This_Trial_Counter_Valid+1;
        All_Trials_Data_Single_Valid(This_Trial_Counter_Valid,:)=All_Trials_Data_Single(tidx,:);
    end
    
end

All_Trials_Data_Single_Valid_Mean=mean(All_Trials_Data_Single_Valid,1);
All_Trials_Data_Single_Valid_STD=std(All_Trials_Data_Single_Valid,0,1)/sqrt(This_Trial_Counter_Valid);

All_Trials_Blank_Period_Mean=mean(All_Trials_Data_Single_Valid,'all');
All_Trials_Blank_Period_STD=std(All_Trials_Data_Single_Valid,0,'all');

%%
figure;

This_Trial_Counter=0;
This_Trial_Counter_Correct=0;
This_Trial_Counter_Error=0;

All_Trials_Data_Frame_Correct=[];
All_Trials_Data_Frame_Error=[];
All_Trials_Data_Single_Valid_Correct=[];
All_Trials_Data_Single_Valid_Error=[];

for tidx=1:length(All_Trials_Data)
    this_CorrectTrial=trialVariables(tidx).CorrectTrial{:};
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
        This_Trial_Counter=This_Trial_Counter+1;
        if strcmp(this_CorrectTrial,'True')
            This_Trial_Counter_Correct=This_Trial_Counter_Correct+1;
            All_Trials_Data_Frame_Correct(This_Trial_Counter_Correct,:)=(All_Trials_Data_Frame(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
            All_Trials_Data_Single_Valid_Correct(This_Trial_Counter_Correct,:)=(All_Trials_Data_Single(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
        else
            This_Trial_Counter_Error=This_Trial_Counter_Error+1;
            All_Trials_Data_Frame_Error(This_Trial_Counter_Error,:)=(All_Trials_Data_Frame(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
            All_Trials_Data_Single_Valid_Error(This_Trial_Counter_Error,:)=(All_Trials_Data_Single(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
        end
        
    end

end

All_Trials_Data_Frame_Correct_Mean=mean(All_Trials_Data_Frame_Correct,1);
All_Trials_Data_Frame_Correct_STD=std(All_Trials_Data_Frame_Correct,0,1)/sqrt(This_Trial_Counter_Correct);
All_Trials_Data_Frame_Error_Mean=mean(All_Trials_Data_Frame_Error,1);
All_Trials_Data_Frame_Error_STD=std(All_Trials_Data_Frame_Error,0,1)/sqrt(This_Trial_Counter_Error);
All_Trials_Time_Frame_Mean=mean(All_Trials_Time_Frame(1:4,:),1);
% 
% 

All_Trials_Data_Single_Valid_Correct_Mean=mean(All_Trials_Data_Single_Valid_Correct,1);
All_Trials_Data_Single_Valid_Correct_STD=std(All_Trials_Data_Single_Valid_Correct,0,1)/sqrt(This_Trial_Counter_Correct);
All_Trials_Data_Single_Valid_Error_Mean=mean(All_Trials_Data_Single_Valid_Error,1);
All_Trials_Data_Single_Valid_Error_STD=std(All_Trials_Data_Single_Valid_Error,0,1)/sqrt(This_Trial_Counter_Error);
All_Trials_Time_Single_Valid_Mean=mean(All_Trials_Time_Single(1:4,:),1);

Smooth_Factor=300;

All_Trials_Data_Frame_Correct_Mean_smoothed=smoothdata(All_Trials_Data_Frame_Correct_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Correct_Mean_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Frame_Correct_Mean+All_Trials_Data_Frame_Correct_STD,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Correct_Mean_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Frame_Correct_Mean-All_Trials_Data_Frame_Correct_STD,'movmean',Smooth_Factor);

All_Trials_Data_Frame_Error_Mean_smoothed=smoothdata(All_Trials_Data_Frame_Error_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Error_Mean_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Frame_Error_Mean+All_Trials_Data_Frame_Error_STD,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Error_Mean_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Frame_Error_Mean-All_Trials_Data_Frame_Error_STD,'movmean',Smooth_Factor);

All_Trials_Data_Single_Valid_Correct_smoothed=smoothdata(All_Trials_Data_Single_Valid_Correct_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Single_Valid_Correct_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Single_Valid_Correct_Mean+All_Trials_Data_Single_Valid_Correct_STD,'movmean',Smooth_Factor);
All_Trials_Data_Single_Valid_Correct_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Single_Valid_Correct_Mean-All_Trials_Data_Single_Valid_Correct_STD,'movmean',Smooth_Factor);

All_Trials_Data_Single_Valid_Error_smoothed=smoothdata(All_Trials_Data_Single_Valid_Error_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Single_Valid_Error_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Single_Valid_Error_Mean+All_Trials_Data_Single_Valid_Error_STD,'movmean',Smooth_Factor);
All_Trials_Data_Single_Valid_Error_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Single_Valid_Error_Mean-All_Trials_Data_Single_Valid_Error_STD,'movmean',Smooth_Factor);

hold on

plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Correct_Mean_smoothed,'Color','#0072BD','LineWidth',4);
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Correct_Mean_smoothed_STD_UPPER,'Color','#0072BD','LineStyle',':','LineWidth',2);
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Correct_Mean_smoothed_STD_LOWER,'Color','#0072BD','LineStyle',':','LineWidth',2);

plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Error_Mean_smoothed,'Color','#D95319','LineWidth',4);
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Error_Mean_smoothed_STD_UPPER,'Color','#D95319','LineStyle',':','LineWidth',2);
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Error_Mean_smoothed_STD_LOWER,'Color','#D95319','LineStyle',':','LineWidth',2);

xline(0);

hold off

xlabel('Time from Decision(sec)');
ylabel('Normalized Activity');
title('Rewarded vs Unrewarded Trials');

figure;

hold on

plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Correct_smoothed,'Color','#0072BD','LineWidth',4);
plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Correct_smoothed_STD_UPPER,'Color','#0072BD','LineStyle',':','LineWidth',2);
plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Correct_smoothed_STD_LOWER,'Color','#0072BD','LineStyle',':','LineWidth',2);

plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Error_smoothed,'Color','#D95319','LineWidth',4);
plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Error_smoothed_STD_UPPER,'Color','#D95319','LineStyle',':','LineWidth',2);
plot(All_Trials_Time_Single_Valid_Mean,All_Trials_Data_Single_Valid_Error_smoothed_STD_LOWER,'Color','#D95319','LineStyle',':','LineWidth',2);

xline(0);

hold off

xlabel('Time from Start of Trial (sec)');
ylabel('Normalized Activity');
title('Rewarded vs Unrewarded Trials');
%%

sel_trial=215;

DEMO_trial=smoothdata((recdata_activity.trial{sel_trial}-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD,'movmean',Smooth_Factor);
DEMO_time=recdata_activity.time{sel_trial};
DEMO_time_offsets=this_data_struct.trialinfo(sel_trial,3);

DEMO_TrialEpoch=gameframedata.TrialEpoch(gameframedata.TrialCounter==sel_trial);
DEMO_recTime=gameframedata.recTime(gameframedata.TrialCounter==sel_trial)-DEMO_time_offsets;

DEMO_objectselection=strcmp(DEMO_TrialEpoch,'SelectObject');

DEMO_objectselection_indices=find(DEMO_objectselection==1);

DEMO_frameNum=length(DEMO_TrialEpoch);

DEMO_selectobject_time=DEMO_recTime(DEMO_objectselection_indices(1):DEMO_objectselection_indices(end));
DEMO_decision_time=DEMO_recTime(DEMO_objectselection_indices(end)+1:DEMO_frameNum);
DEMO_start_time=DEMO_recTime(1:DEMO_objectselection_indices(1)-1);

figure;

DEMO_trial_max=max(DEMO_trial);
DEMO_trial_min=min(DEMO_trial);

DEMO_offset=DEMO_trial_min-(DEMO_trial_max-DEMO_trial_min)*0.1;

hold on
plot(DEMO_time,DEMO_trial,'LineWidth',4);

plot(DEMO_start_time,DEMO_offset*ones(size(DEMO_start_time)),'LineWidth',16);
plot(DEMO_selectobject_time,DEMO_offset*ones(size(DEMO_selectobject_time)),'LineWidth',16);
plot(DEMO_decision_time,DEMO_offset*ones(size(DEMO_decision_time)),'LineWidth',16);

xline(DEMO_start_time(1));
xline(DEMO_decision_time(end));

hold off

legend('Activity','Trial Start','Object Selection','Feedback and Reward')

xlabel('Time from Stimulus Onset (sec)');
ylabel('Normalized Activity');
title('Example Trial');

ylim([DEMO_offset-(DEMO_trial_max-DEMO_trial_min)*0.1,DEMO_trial_max]);
%% Learning
figure;

This_Trial_Counter_Learning=0;
This_Trial_Counter_Before_Learning=0;
This_Trial_Counter_After_Learning=0;

All_Trials_Data_Frame_Before_Learning=[];
All_Trials_Data_Frame_After_Learning=[];

for tidx=1:length(All_Trials_Data)
    this_LearnTrial=trialVariables(tidx).TrialsFromLP;
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)&&~(isnan(this_LearnTrial))
        This_Trial_Counter_Learning=This_Trial_Counter_Learning+1;
        if this_LearnTrial>-1
            This_Trial_Counter_Before_Learning=This_Trial_Counter_Before_Learning+1;
            All_Trials_Data_Frame_Before_Learning(This_Trial_Counter_Before_Learning,:)=(All_Trials_Data_Frame(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
        else
            This_Trial_Counter_After_Learning=This_Trial_Counter_After_Learning+1;
            All_Trials_Data_Frame_After_Learning(This_Trial_Counter_After_Learning,:)=(All_Trials_Data_Frame(tidx,:)-All_Trials_Blank_Period_Mean)/All_Trials_Blank_Period_STD;
        end
        
    end

end

All_Trials_Data_Frame_Before_Learning_Mean=mean(All_Trials_Data_Frame_Before_Learning,1);
All_Trials_Data_Frame_Before_Learning_STD=std(All_Trials_Data_Frame_Before_Learning,0,1)/sqrt(This_Trial_Counter_Before_Learning);
All_Trials_Data_Frame_After_Learning_Mean=mean(All_Trials_Data_Frame_After_Learning,1);
All_Trials_Data_Frame_After_Learning_STD=std(All_Trials_Data_Frame_After_Learning,0,1)/sqrt(This_Trial_Counter_After_Learning);
All_Trials_Time_Frame_Mean=mean(All_Trials_Time_Frame(1:4,:),1);
% 
% 

Smooth_Factor=300;

All_Trials_Data_Frame_Before_Learning_Mean_smoothed=smoothdata(All_Trials_Data_Frame_Before_Learning_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Before_Learning_Mean_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Frame_Before_Learning_Mean+All_Trials_Data_Frame_Before_Learning_STD,'movmean',Smooth_Factor);
All_Trials_Data_Frame_Before_Learning_Mean_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Frame_Before_Learning_Mean-All_Trials_Data_Frame_Before_Learning_STD,'movmean',Smooth_Factor);

All_Trials_Data_Frame_After_Learning_Mean_smoothed=smoothdata(All_Trials_Data_Frame_After_Learning_Mean,'movmean',Smooth_Factor);
All_Trials_Data_Frame_After_Learning_Mean_smoothed_STD_UPPER=smoothdata(All_Trials_Data_Frame_After_Learning_Mean+All_Trials_Data_Frame_After_Learning_STD,'movmean',Smooth_Factor);
All_Trials_Data_Frame_After_Learning_Mean_smoothed_STD_LOWER=smoothdata(All_Trials_Data_Frame_After_Learning_Mean-All_Trials_Data_Frame_After_Learning_STD,'movmean',Smooth_Factor);

hold on

plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Before_Learning_Mean_smoothed,'Color','#0072BD');
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Before_Learning_Mean_smoothed_STD_UPPER,'Color','#0072BD','LineStyle',':');
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_Before_Learning_Mean_smoothed_STD_LOWER,'Color','#0072BD','LineStyle',':');

plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_After_Learning_Mean_smoothed,'Color','#D95319');
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_After_Learning_Mean_smoothed_STD_UPPER,'Color','#D95319','LineStyle',':');
plot(All_Trials_Time_Frame_Mean,All_Trials_Data_Frame_After_Learning_Mean_smoothed_STD_LOWER,'Color','#D95319','LineStyle',':');

hold off

xlabel('Time from Decision(sec)');
ylabel('Normalized Activity');
title('Before and After Learning');

%%
figure;

This_Trial_Counter=0;
This_Trial_Counter_Correct=0;
This_Trial_Counter_Error=0;

All_Trials_Data_Single_Correct=[];
All_Trials_Data_Single_Error=[];

for tidx=1:length(All_Trials_Data)
    this_CorrectTrial=trialVariables(tidx).CorrectTrial{:};
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)
        This_Trial_Counter=This_Trial_Counter+1;
        if strcmp(this_CorrectTrial,'True')
            This_Trial_Counter_Correct=This_Trial_Counter_Correct+1;
            All_Trials_Data_Single_Correct(This_Trial_Counter_Correct,:)=All_Trials_Data_Single(tidx,:);
        else
            This_Trial_Counter_Error=This_Trial_Counter_Error+1;
            All_Trials_Data_Single_Error(This_Trial_Counter_Error,:)=All_Trials_Data_Single(tidx,:);
        end
        
    end

end

All_Trials_Data_Single_Correct_Mean=mean(All_Trials_Data_Single_Correct,1);
All_Trials_Data_Single_Correct_STD=std(All_Trials_Data_Single_Correct,0,1)/sqrt(This_Trial_Counter_Correct);
All_Trials_Data_Single_Error_Mean=mean(All_Trials_Data_Single_Error,1);
All_Trials_Data_Single_Error_STD=std(All_Trials_Data_Single_Error,0,1)/sqrt(This_Trial_Counter_Error);
All_Trials_Time_Single_Mean=mean(All_Trials_Time_Single,1);
% 
% 
plot(All_Trials_Time_Single_Mean,smoothdata(All_Trials_Data_Single_Correct_Mean,'movmean',100),...
    All_Trials_Time_Single_Mean,smoothdata(All_Trials_Data_Single_Error_Mean,'movmean',100)) 

%%
figure;

This_Trial_Counter_Learning=0;
This_Trial_Counter_Before_Learning=0;
This_Trial_Counter_After_Learning=0;

All_Trials_Data_Single_Before_Learning=[];
All_Trials_Data_Single_After_Learning=[];

for tidx=1:length(All_Trials_Data)
    this_LearnTrial=trialVariables(tidx).TrialsFromLP;
    
    this_trial=trialData(tidx,:);
    this_abortcode=this_trial.AbortCode;
    this_trialduration=this_trial.TrialTime;
    this_trial_objectduration=TrialDATA.GazeObjectsDuration{tidx, 1};
    this_trial_objecttype=TrialDATA.GazeObjectsType{tidx, 1};
    
    if (this_abortcode==0)&&(this_trialduration<TrialDuration_Minimum)&&~(isnan(this_LearnTrial))
        This_Trial_Counter=This_Trial_Counter+1;
        if this_LearnTrial>-1
            This_Trial_Counter_Before_Learning=This_Trial_Counter_Before_Learning+1;
            All_Trials_Data_Single_Before_Learning(This_Trial_Counter_Before_Learning,:)=All_Trials_Data_Single(tidx,:);
        else
            This_Trial_Counter_After_Learning=This_Trial_Counter_After_Learning+1;
            All_Trials_Data_Single_After_Learning(This_Trial_Counter_After_Learning,:)=All_Trials_Data_Single(tidx,:);
        end
        
    end

end

All_Trials_Data_Single_Before_Learning_Mean=mean(All_Trials_Data_Single_Before_Learning,1);
All_Trials_Data_Single_Before_Learning_STD=std(All_Trials_Data_Single_Before_Learning,0,1)/sqrt(This_Trial_Counter_Before_Learning);
All_Trials_Data_Single_After_Learning_Mean=mean(All_Trials_Data_Single_After_Learning,1);
All_Trials_Data_Single_After_Learning_STD=std(All_Trials_Data_Single_After_Learning,0,1)/sqrt(This_Trial_Counter_After_Learning);
All_Trials_Time_Single_Mean=mean(All_Trials_Time_Single,1);
% 
% 
plot(All_Trials_Time_Single_Mean,smoothdata(All_Trials_Data_Single_Before_Learning_Mean,'movmean',30),...
    All_Trials_Time_Single_Mean,smoothdata(All_Trials_Data_Single_After_Learning_Mean,'movmean',30)) 