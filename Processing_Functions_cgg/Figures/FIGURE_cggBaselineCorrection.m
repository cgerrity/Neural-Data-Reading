%% FIGURE_cggBaselineCorrection


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
Smooth_Factor=200;


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

[Segmented_Baseline,TrialNumbers_Baseline] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX_Base,End_IDX_Base,fullfilename,Smooth_Factor,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

this_Selected_Baseline=Segmented_Baseline;

[NumChannels,NumSamples_Baseline,~]=size(this_Selected_Baseline);

%%

Time_Baseline=linspace(-Window_Before_Baseline,Window_After_Baseline,NumSamples_Baseline);


%%

InBaseline=this_Selected_Baseline;
% Detrend_Baseline=NaN(size(InBaseline));
% 
% if verLessThan('matlab','9.5')
% Mean_Baseline=squeeze(mean(InBaseline(:,:,:),2));
% STD_Baseline=squeeze(std(InBaseline(:,:,:),0,2));
% else
% Mean_Baseline=squeeze(mean(InBaseline,2));
% STD_Baseline=squeeze(std(InBaseline,0,2));
% end
% 
% for cidx=1:NumChannels
% sel_channel=cidx;
% this_Baseline_Mean=Mean_Baseline(sel_channel,:);
% 
% this_y=[];
% this_x=[];
% 
% this_y=diag(diag(this_Baseline_Mean));
% this_x=diag(diag(TrialNumbers_Baseline)); % 1:NumTrials or use TrialNumbers_Baseline
% this_x=[this_x,ones(size(this_x))];
% 
% [this_Coefficients,~,~,~,~] = regress(this_y,this_x);
% 
% this_Baseline_Fit=this_x*this_Coefficients;
% 
% for tidx=1:length(TrialNumbers_Baseline)
% Detrend_Baseline(sel_channel,:,tidx)=InBaseline(sel_channel,:,tidx)-this_Baseline_Fit(tidx);
% end
% end

[Detrend_Data,Detrend_Baseline] = cgg_procDetrendFromBaseline(InBaseline,InBaseline,TrialNumbers_Baseline);

%%
InSavePlotCFG_Global=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Alignment;

cgg_plotSelectMeanValues(Detrend_Baseline,'Detrend Baseline Mean',...
    'Trial','Mean Across Trials',[0.25,0.25],...
    InSavePlotCFG_Global.Mean_Values,'Mean_Value_Decision_Aligned_Detrend_Channel_%s')

