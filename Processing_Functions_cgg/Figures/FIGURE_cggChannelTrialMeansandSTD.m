%% FIGURE_cggChannelTrialMeansandSTD


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

[Segmented_Baseline,TrialNumbers_Baseline] = cgg_getAllTrialDataFromTimeSegments(Start_IDX_Base,End_IDX_Base,fullfilename,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[NumChannels,NumSamples_Baseline,~]=size(Segmented_Baseline);

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

Time_Baseline=linspace(-Window_Before_Baseline,Window_After_Baseline,NumSamples_Baseline);

[MatchBaseline] = cgg_getSeparateTrialsByCriteria_v2(TrialCondition_Baseline,MatchValue_Baseline,TrialVariableTrialNumber,Segmented_Baseline,TrialNumbers_Baseline);

%%
cgg_plotSelectMeanValues(MatchBaseline,'Baseline Mean',...
    'Trial','Mean Across Trials',[0.25,0.25],...
    InSavePlotCFG_Global.Mean_Values,'Mean_Value_Decision_Aligned_Channel_%s')
%%
cgg_plotAllMeanValues(MatchBaseline,'Baseline Mean',...
    'Trial','Mean Across Trials',[1.5,1.5],...
    InSavePlotCFG_Global.Mean_Values,'Mean_Value_Decision_Aligned_Channel_%s');