%% FIGURE_cgg_DecisiionAlignedPlots_v3


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

%%

[Output] = cgg_procFullTrialPreparation_v2('inputfolder',inputfolder,...
    'outdatadir',outdatadir);

%%

cfg_param = PARAMETERS_cgg_procFullTrialPreparation_v2;

probe_area=cfg_param.probe_area;
Activity_Type=cfg_param.Activity_Type;
Alignment_Type='Decision';

[~,~,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation] = ...
    cgg_generateAllNeuralDataFolders('inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[cfg_outplotdir] = cgg_generateNeuralPlottingFolders_v2(outdatadir,...
    SessionName,ExperimentName,probe_area,Activity_Type,Alignment_Type);

%%

this_Selected_Data=Output(2).Trials;
this_Selected_Baseline=Output(3).Trials;

TrialNumbers_Data=Output(2).TrialNumber;
TrialNumbers_Baseline=Output(3).TrialNumber;

[NumChannels,NumSamples_Data,~]=size(this_Selected_Data);
[~,NumSamples_Baseline,~]=size(this_Selected_Baseline);

%%

[trialVariables] = cgg_getTrialVariables('inputfolder',inputfolder,'outdatadir',outdatadir);

TrialVariableTrialNumber=[trialVariables(:).TrialNumber];

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

Window_Before_Data=cfg_param.Window_Before_Data;
Window_After_Data=cfg_param.Window_After_Data;
Window_Before_Baseline=cfg_param.Window_Before_Baseline;
Window_After_Baseline=cfg_param.Window_After_Baseline;


Time_Data=linspace(-Window_Before_Data,Window_After_Data,NumSamples_Data);
Time_Baseline=linspace(-Window_Before_Baseline,Window_After_Baseline,NumSamples_Baseline);

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

% 1 indicates the trial has 1 dimensional objects. 2 indicates the trial
% has 2 dimensional objects. 3 indicates the trial has 3 dimensional
% objects.
MatchArray_Attention=ones(size(MatchArray_Attention_2))+MatchArray_Attention_2+MatchArray_Attention_3*2;

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
% MatchArray_Full(:,NumCondArray+1)=MatchArray_Attention;
% [~,NumCondArray]=size(MatchArray_Full);
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

MatchArray_Fit=this_Match_Array((MatchArray_Input==1)&(~TrialNumbers_Condition_NotFound),:);
MatchArray_Fit_Ones=this_Match_Array_Ones((MatchArray_Input==1)&(~TrialNumbers_Condition_NotFound),:);



%%

[P_Value_Data,R_Value_Data,P_Value_Coefficients_Data,CoefficientNames_Data] = cgg_procTrialVariableRegression(this_FitaData,MatchArray_Fit);
[P_Value_Baseline,R_Value_Baseline,P_Value_Coefficients_Baseline,CoefficientNames_Baseline] = cgg_procTrialVariableRegression(this_FitBaseline,MatchArray_Fit);

%%

InData_X_Name=InData_X_Name_All{1};
InBaseline_X_Name=InBaseline_X_Name_All{1};

InData_Title_P='Significance from Regression';
InBaseline_Title_P=InData_Title_P;
InData_Title_R='R^2 Value from Regression';
InBaseline_Title_R=InData_Title_R;
InData_Title_Plog='-log(P Value)';
InBaseline_Title_Plog=InData_Title_Plog;

% Model_Regressors='Rewarded';
Model_Regressors='All_Regressors';
% Current_Regressor_Name={'Intercept','Rewarded','Learned','Attention','Gain','Loss','Previous','Model'};
Current_Regressor_Name={'Intercept','Rewarded','Learned','Attention_2','Attention_3','Gain','Loss','Previous','Model'};
% Current_Regressor_Name={'Intercept','Rewarded','Model'};

InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;

% Regressor_Array=2;
Regressor_Array=1:length(Current_Regressor_Name);
Significance_Array=[0.05,0.01,0.001];
Length_Array=[1,10,20];

% for ridx=1:length(Regressor_Array)
%     for sidx=1:length(Significance_Array)
%         for lidx=1:length(Length_Array)
% 
% sel_Current_Regressor=Regressor_Array(ridx);
% sel_Significance=Significance_Array(sidx);
% sel_Length=Length_Array(lidx);
% 
% Significance_Value=sel_Significance;
% Minimum_Length=sel_Length;
% 
% this_Current_Regressor_Name=Current_Regressor_Name{sel_Current_Regressor};
% Significance_Value_Name=replace(sprintf('%0.3f',Significance_Value),'0.','');
% 
% InSaveName_P=sprintf('Significance_Decision_Aligned_%s_Regressors_%s_Minimum_Length_%d_Significance_%s',this_Current_Regressor_Name,Model_Regressors,Minimum_Length,Significance_Value_Name);
% InSaveName_R=sprintf('R_Squared_Decision_Aligned_%s',Model_Regressors);
% InSaveName_Plog=sprintf('PLog_Decision_Aligned_%s',Model_Regressors);
% InSaveName_SigFrac=sprintf('Significant_Fraction_Decision_Aligned_%s_Regressors_%s_Minimum_Length_%d_Significance_%s',this_Current_Regressor_Name,Model_Regressors,Minimum_Length,Significance_Value_Name);
% 
% InSaveDescriptor='';
% 
% % InP_ValueData=P_Value_Data;
% if ~isequal(this_Current_Regressor_Name,'Model')
% InP_ValueData=P_Value_Coefficients_Data(:,:,sel_Current_Regressor);
% InP_ValueBaseline=P_Value_Coefficients_Baseline(:,:,sel_Current_Regressor);
% else
% InP_ValueData=P_Value_Data;
% InP_ValueBaseline=P_Value_Baseline;
% end
% % InP_ValueBaseline=P_Value_Baseline;
% % InP_ValueBaseline=P_Value_Coefficients_Baseline(:,:,sel_Current_Regressor);
% InData_Time=Time_Data;
% InBaseline_Time=Time_Baseline;
% 
% 
% InData_Title=InData_Title_P;
% InBaseline_Title=InBaseline_Title_P;
% 
% InSaveName=InSaveName_P;
% InArea=probe_area;
% InRegressor=this_Current_Regressor_Name;
% InModel=Model_Regressors;
% Connected_Channels=Output(2).Connected_Channels;
% 
% cgg_plotAllTrialSignificance(InP_ValueData,InP_ValueBaseline,Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_P,InBaseline_Title_P,probe_area,this_Current_Regressor_Name,Model_Regressors,InSavePlotCFG,InSaveName_P,InSaveDescriptor,Significance_Value,Minimum_Length,'Connected_Channels',Connected_Channels);
% 
% cgg_plotSignificanceAcrossTime(InP_ValueData,InP_ValueBaseline,Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,'Fraction of Significant Channels',probe_area,this_Current_Regressor_Name,Model_Regressors,InSavePlotCFG,InSaveName_SigFrac,Significance_Value,Minimum_Length,'Connected_Channels',Connected_Channels);
%         end
%     end
% end
% %
% 
% cgg_plotAllTrialRValue(R_Value_Data,R_Value_Baseline,Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_R,InBaseline_Title_R,Model_Regressors,InSavePlotCFG,InSaveName_R,InSaveDescriptor,Significance_Value,'Connected_Channels',Connected_Channels);
% 
% cgg_plotAllTrialRValue(-log(P_Value_Data),-log(P_Value_Baseline),Time_Data,Time_Baseline,InData_X_Name,InBaseline_X_Name,InData_Title_Plog,InBaseline_Title_Plog,Model_Regressors,InSavePlotCFG,InSaveName_Plog,InSaveDescriptor,Significance_Value,'Connected_Channels',Connected_Channels);

% %%
% 
% All_Channels=1:NumChannels;
% Good_Channels=false(NumChannels,1);
% Good_Channels(Connected_Channels)=true;
% 
% ridx=2;
% Significance_Value=0.01;
% Minimum_Length=10;
% 
% sel_Current_Regressor=Regressor_Array(ridx);
% 
% InP_ValueData=P_Value_Coefficients_Data(:,:,sel_Current_Regressor);
% 
% [this_Significant_Data] = cgg_procSignificanceOverChannels(InP_ValueData,Significance_Value,Minimum_Length);
% 
% this_Channel_Significant=any(this_Significant_Data,2)&Good_Channels;
% 
% this_setListData=All_Channels(this_Channel_Significant);
% 
% fig_activity=figure;
% % figure(fig_activity);
% imagesc(this_Significant_Data)
% fig_activity.CurrentAxes.YDir='normal';

%%

Significance_Value=0.05;
Minimum_Length=10;
Connected_Channels=Output(2).Connected_Channels;

All_Channels=1:NumChannels;
Good_Channels=false(NumChannels,1);
Good_Channels(Connected_Channels)=true;

% setListData=cell(length(Current_Regressor_Name)-2,1);

[Significant_Data] = cgg_procSignificanceOverChannels(P_Value_Coefficients_Data(:,:,2:8),Significance_Value,Minimum_Length);

Channel_Significant=any(Significant_Data,2)&Good_Channels;

Channel_TaskModulated=any(Channel_Significant,3);
Channel_Significant_None=(~Channel_TaskModulated);

Channel_Significant_Rewarded=Channel_Significant(:,:,1)&Good_Channels;
Channel_Significant_Learned=Channel_Significant(:,:,2)&Good_Channels;
Channel_Significant_Attention=Channel_Significant(:,:,3)|Channel_Significant(:,:,4)&Good_Channels;
% Channel_Significant_Attention=Channel_Significant(:,:,3)&Good_Channels;
Channel_Significant_Motivation=Channel_Significant(:,:,5)|Channel_Significant(:,:,6)&Good_Channels;
Channel_Significant_Previous=Channel_Significant(:,:,7)&Good_Channels;

setListData_Rewarded=All_Channels(Channel_Significant_Rewarded);
setListData_Learned=All_Channels(Channel_Significant_Learned);
setListData_Attention=All_Channels(Channel_Significant_Attention);
setListData_Motivation=All_Channels(Channel_Significant_Motivation);
setListData_Previous=All_Channels(Channel_Significant_Previous);
setListData_Disconnected=All_Channels(~Good_Channels);
setListData_None=All_Channels(Channel_Significant_None);

setListData=cell(5,1);
setListData_Bad=cell(2,1);

setListData{1}=setListData_Rewarded;
setListData{2}=setListData_Learned;
setListData{3}=setListData_Attention;
setListData{4}=setListData_Motivation;
setListData{5}=setListData_Previous;
setListData_Bad{1}=setListData_Disconnected;
setListData_Bad{2}=setListData_None;

setLabels = ["Rewarded"; "Learned"; "Attention"; "Motivation"; "Previous"];
setLabels_Bad = ["Disconnected"; "None"];


% %%
% setListData_loop=cell(length(Current_Regressor_Name)-2,1);
% for ridx=2:length(Current_Regressor_Name)-1
% 
% sel_Current_Regressor=Regressor_Array(ridx);
% 
% InP_ValueData=P_Value_Coefficients_Data(:,:,sel_Current_Regressor);
% 
% [this_Significant_Data] = cgg_procSignificanceOverChannels(InP_ValueData,Significance_Value,Minimum_Length);
% 
% this_Channel_Significant=any(this_Significant_Data,2);
% 
% this_setListData=All_Channels(this_Channel_Significant);
% 
% setListData_loop{ridx-1} = this_setListData;
% 
% end

%%

% setLabels = ["Rewarded"; "Learned"; "Attention_2"; "Attention_3"; "Gain"; "Loss"; "Previous"];
h = vennEulerDiagram(setListData, 'drawProportional', true, 'SetLabels', setLabels);
h.ShowIntersectionCounts = true;

%%
% figure;
% h_Bad = vennEulerDiagram(setListData_Bad, 'drawProportional', true, 'SetLabels', setLabels_Bad);
% h_Bad.ShowIntersectionCounts = true;

