%% FIGURE_cggChannelCorrelations


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
All_probe_area={'ACC_001','ACC_002','CD_001','CD_002','PFC_001'};
Activity_Type='WideBand';

% Sel_Trial=[100];
Count_Sel_Trial=30;

%%

[~,~,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation] = ...
    cgg_generateAllNeuralDataFolders('inputfolder',inputfolder,...
    'outdatadir',outdatadir);

rectrialdefs=load([outdatadir filesep ExperimentName filesep ...
    SessionName filesep 'Trial_Information' filesep ...
    'Trial_Definition_' SessionName]);
rectrialdefs=rectrialdefs.rectrialdefs;

NumTrials=length(rectrialdefs);
Trial_Permutation=randperm(NumTrials);
% Sel_Trial=randi(NumTrials,1,Count_Sel_Trial);
Sel_Trial=Trial_Permutation(1:Count_Sel_Trial);
Sel_Trial=sort(Sel_Trial);

%%

for aidx=1:length(All_probe_area)
    
    probe_area=All_probe_area{aidx};
    
[outdatadir_WideBand,outdatadir_LFP,outdatadir_Spike,...
    outdatadir_MUA] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area);

[cfg_outplotdir] = cgg_generateNeuralPlottingFoldersforProcessing(outdatadir,...
    SessionName,ExperimentName,probe_area,Activity_Type);

%%
% tic
fullfilename=[outdatadir_WideBand filesep Activity_Type '_Trial_%d.mat'];
% this_Data=[];
this_Data=cell(1,Count_Sel_Trial);
parfor tidx=1:length(Sel_Trial)
    this_tidx=Sel_Trial(tidx);
recdata_wideband=load(sprintf(fullfilename,this_tidx));
recdata_wideband=recdata_wideband.this_recdata_wideband;

this_Data{tidx}=recdata_wideband.trial{1};

% this_Data=[this_Data,recdata_wideband.trial{1}];
end

this_Data=cell2mat(this_Data);
% toc
%%
InData=this_Data;
InArea=probe_area;
InTrials=Sel_Trial;
InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Correlation;
InSaveName='Channel_Correlations_Mapped_%s_%s';
%%
cgg_plotChannelCorrelations(InData,InArea,InTrials,InSavePlotCFG,InSaveName)

%% K-Means
InData=this_Data;
InArea=probe_area;
InTrials=Sel_Trial;
InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Correlation;
InSaveName='Channel_Clustering_%s_Mapped_Clusters_%d_%s';

%%
cgg_plotChannelClusteringAlongProbe(InData,InArea,InTrials,InSavePlotCFG,InSaveName)

end
