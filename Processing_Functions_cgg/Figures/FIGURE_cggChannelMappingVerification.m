%% FIGURE_cggChannelCorrelations

want_ui_selection=false;
probe_mapping='mapped';

Total_Time=0.1; %min

NumPlots=10;
NumTimeSegments=10;

% Monkey_Name='Wotan';
% ExperimentName='Wotan_FLToken_Probe_01';
% SessionName='Wo_Probe_01_23-02-13_003_01';

%%

if want_ui_selection
[inputfolder,outdatadir,SessionName,ExperimentName] = ...
    cgg_ioInputOutputDirectories;
else
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

inputfolder=[inputfolder_base '/DATA_neural/' Monkey_Name filesep ...
    ExperimentName filesep SessionName];
outdatadir=[outputfolder_base '/Data_Neural_gerritcg'];
end

%%

[ folders_openephys, ~, ~, ~ ] = ...
  euUtil_getExperimentFolders(inputfolder);

folder_record = folders_openephys{1};

rechdr = ft_read_header( folder_record, 'headerformat', 'nlFT_readHeader' );

%% Select a time in the begining, middle, and end
start_idx=NaN(NumTimeSegments,1);
for widx=1:NumTimeSegments
start_idx(widx)=round(rechdr.nSamples*(widx/(1+NumTimeSegments)));
end
end_idx=round(start_idx+Total_Time*60*rechdr.Fs);
start_idx=max(start_idx,1);
end_idx=min(end_idx,rechdr.nSamples);

this_rectrialdefs=[start_idx,end_idx,start_idx*0];
%%
preproc_config_rec = struct( ...
  'headerfile', folder_record, 'datafile', folder_record, ...
  'headerformat', 'nlFT_readHeader', 'dataformat', 'nlFT_readDataDouble', ...
  'trl', this_rectrialdefs, 'detrend', 'yes', 'feedback', 'text' );

[ chanmap_rec_mapped chanmap_rec_unmapped chanmap_rec_recorded ] = ...
  cgg_euUtil_getLabelChannelMap_OEv5(inputfolder, folder_record);
have_chanmap = ~isempty(chanmap_rec_mapped);

cfg=PARAMETERS_cgg_proc_NeuralDataPreparation('SessionName',SessionName);

notch_filter_freqs = cfg.notch_filter_freqs;
notch_filter_bandwidth = cfg.notch_filter_bandwidth;
probe_selection=cfg.probe_selection;
probe_area=cfg.probe_area;
lfp_maxfreq=cfg.lfp_maxfreq;
lfp_samprate=cfg.lfp_samprate;
spike_minfreq=cfg.spike_minfreq;
rect_bandfreqs=cfg.rect_bandfreqs;
rect_lowpassfreq=cfg.rect_lowpassfreq;
rect_samprate=cfg.rect_samprate;

% probe_selection={1:128};
% probe_area={'All'};

%%

for aidx=1:length(probe_area)
    
    this_probe_area=probe_area{aidx};
    this_probe_selection=probe_selection{aidx};
    
    [cfg_outplotdir] = cgg_generateChannelMappingFolders(this_probe_area,'inputfolder',inputfolder,'outdatadir',outdatadir);
    
    switch probe_mapping
        case 'recorded'
            this_channel_map = chanmap_rec_recorded;
        case 'unmapped'
            this_channel_map = chanmap_rec_unmapped;
        case 'mapped'
            this_channel_map = chanmap_rec_mapped;
        otherwise
            this_channel_map = chanmap_rec_mapped;
    end

preproc_config_rec.channel = ...
  ft_channelselection( this_channel_map(this_probe_selection), rechdr.label, {} );

%%
% Wrapping this to suppress the annoying banner.
ft_defaults;
        
% Suppress spammy Field Trip notifications.
ft_notice('off');
ft_info('off');
ft_warning('off');

% Suppress Matlab warnings (the NPy library generates these).
oldwarnstate = warning('off');

% Limit the number of channels LoopUtil will load into memory at a time.
% 30 ksps double-precision data takes up about 1 GB per channel-hour.
nlFT_setMemChans(8);

disp('.. Reading wideband recorder data.');
recdata_wideband = ft_preprocessing( preproc_config_rec );

disp('.. Performing notch filtering (recorder).');
recdata_wideband = euFT_doBrickNotchRemoval( ...
  recdata_wideband, notch_filter_freqs, notch_filter_bandwidth );

%%

if have_chanmap
  newlabels = nlFT_mapChannelLabels( recdata_wideband.label, ...
    chanmap_rec_mapped, chanmap_rec_unmapped );
  newlabels_unmapped = nlFT_mapChannelLabels( recdata_wideband.label, ...
    chanmap_rec_unmapped, chanmap_rec_unmapped );
  newlabels_recorded = nlFT_mapChannelLabels( recdata_wideband.label, ...
    chanmap_rec_recorded, chanmap_rec_unmapped );

  badmask = strcmp(newlabels, '');
  if sum(badmask) > 0
    disp('###  Couldn''t map all recorder labels!');
    newlabels(badmask) = {'bogus'};
  end

  % Figure out new order for channels after remapping saved order 
  [newlabels_in_order,newlabels_order]=sort(newlabels);
  [newlabels_in_order_unmapped,newlabels_order_unmapped]=...
      sort(newlabels_unmapped);
  [newlabels_in_order_recorded,newlabels_order_recorded]=...
      sort(newlabels_recorded);
  % There are at least three places where the labels are stored.
  % Update all copies.
%   recdata_wideband.oldlabel=newlabels;
  recdata_wideband.label = recdata_wideband.label(newlabels_order);
  recdata_wideband.label_in_order = newlabels_in_order;
  recdata_wideband.old_label = preproc_config_rec.channel;
%   recdata_wideband.hdr.label = newlabels_in_order;
%   rechdr.label = newlabels_in_order;
  
  
  this_trial_count=length(recdata_wideband.trial);
  recdata_wideband_tmp=recdata_wideband;
  
  for ttidx=1:this_trial_count
      
      recdata_wideband.trial{ttidx}=...
          recdata_wideband_tmp.trial{ttidx}(newlabels_order,:);
      recdata_wideband_unmapped.trial{ttidx}=...
          recdata_wideband_tmp.trial{ttidx}(newlabels_order_unmapped,:);
      recdata_wideband_recorded.trial{ttidx}=...
          recdata_wideband_tmp.trial{ttidx}(newlabels_order_recorded,:);
  end

end

    [ recdata_lfp, recdata_spike, recdata_activity ] = ...
        euFT_getDerivedSignals( recdata_wideband, lfp_maxfreq, ...
        lfp_samprate, spike_minfreq, rect_bandfreqs, rect_lowpassfreq, ...
        rect_samprate, false);

%%
this_Data=cell(1);
this_Data_unmapped=cell(1);
this_Data_recorded=cell(1);
for tidx=1:length(recdata_wideband.trial)
this_Data{tidx}=recdata_wideband.trial{tidx};
this_Data_unmapped{tidx}=recdata_wideband_unmapped.trial{tidx};
this_Data_recorded{tidx}=recdata_wideband_recorded.trial{tidx};
end
this_Data=cell2mat(this_Data);
this_Data_unmapped=cell2mat(this_Data_unmapped);
this_Data_recorded=cell2mat(this_Data_recorded);

%%
InData=this_Data;
% InArea=this_probe_area;
% InTrials=1;
% InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Channel_Mapping;
% % InSaveName='Channel_Correlations_Mapped_Time_%s_%s';
% InSaveName=[sprintf('Channel_Correlations_Mapped_Time_%u',Total_Time*100), '_%s_%s'];
% %%
% cgg_plotChannelCorrelations(InData,InArea,InTrials,InSavePlotCFG,InSaveName)
% %%
% InData=this_Data_unmapped;
% InArea=this_probe_area;
% InTrials=1;
% InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Channel_Mapping;
% % InSaveName='Channel_Correlations_Mapped_Time_%s_%s';
% InSaveName=[sprintf('Channel_Correlations_Unmapped_Time_%u',Total_Time*100), '_%s_%s'];
% %%
% cgg_plotChannelCorrelations(InData,InArea,InTrials,InSavePlotCFG,InSaveName)
% %%
% InData=this_Data_recorded;
% InArea=this_probe_area;
% InTrials=1;
% InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Channel_Mapping;
% % InSaveName='Channel_Correlations_Mapped_Time_%s_%s';
% InSaveName=[sprintf('Channel_Correlations_Recorded_Time_%u',Total_Time*100), '_%s_%s'];
% %%
% cgg_plotChannelCorrelations(InData,InArea,InTrials,InSavePlotCFG,InSaveName)
% 
% %% K-Means
% InData=this_Data;
% InArea=this_probe_area;
% InTrials=1;
% InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Correlation;
% InSaveName='Channel_Clustering_%s_Mapped_Clusters_%d_%s';
% 
% %%
% cgg_plotChannelClusteringAlongProbe(InData,InArea,InTrials,InSavePlotCFG,InSaveName)


% %%
% % NumGroups=10;
% NumReplicates=10; %10
% InDistance='sqeuclidean';
% 
% Start_Group=2;
% End_Group=5;
% NumIterations=length(Start_Group:End_Group);
% 
% Connected_Channels_iter=cell(1,NumIterations);
% Disconnected_Channels_iter=cell(1,NumIterations);
% 
% for idx=Start_Group:End_Group
% NumGroups=idx;
% [Group_Labels,~,~] = cgg_procChannelClustering(InData,NumGroups,NumReplicates,InDistance);
% 
% NumChannels=length(Group_Labels);
% Disconnected_IDX_iter=Group_Labels(NumChannels-4:NumChannels);
% % Connected_IDX=mode(Group_Labels);
% 
% All_Channels=1:NumChannels;
% 
% % Connected_Channels=All_Channels(~ismember(Group_Labels,Disconnected_IDX));
% % Disconnected_Channels=All_Channels(ismember(Group_Labels,Disconnected_IDX));
% Connected_Channels_iter{idx-Start_Group+1}=All_Channels(~ismember(Group_Labels,Disconnected_IDX_iter));
% Disconnected_Channels_iter{idx-Start_Group+1}=All_Channels(ismember(Group_Labels,Disconnected_IDX_iter));
% end
% 
% Disconnected_Count=cell2mat(Disconnected_Channels_iter);
% Disconnected_Possible = unique(Disconnected_Count)';
% Disconnected_Histogram = [Disconnected_Possible,...
%     histc(Disconnected_Count(:),Disconnected_Possible)];
% 
% Disconnected_IDX=Disconnected_Possible(Disconnected_Histogram(:,2)/NumIterations>0.5);
% 
% Connected_Channels{aidx}=All_Channels(~Disconnected_IDX);
% Disconnected_Channels{aidx}=All_Channels(Disconnected_IDX);
% 
% 


%%

for sidx=1:NumTimeSegments
for pidx=1:NumPlots
sel_tidx=sidx;
Start_IDX=1+3000*(pidx-1);
End_IDX=3000*(pidx);

InData=recdata_wideband.trial{sel_tidx}(:,Start_IDX:End_IDX);
InData_Time=recdata_wideband.time{sel_tidx}(Start_IDX:End_IDX);
X_Name='Time (s)';
Y_Name='';
InData_Title='Verification of Channel Activity';
InYLim=[min(InData(:)),max(InData(:))]*0.5;
Channel_Group=1:64;
InSavePlotCFG=cfg_outplotdir.outdatadir.Experiment.Session.Plots.Area.Activity.Activity_Example;
InSaveName=[sprintf('Channel_Verification_%s_%d_%d',this_probe_area,sidx,pidx),'_%s'];
InSaveArea=this_probe_area;

cgg_plotDataProcessingStepsInGroups(InData,InData_Time,X_Name,Y_Name,InData_Title,InYLim,Channel_Group,InSavePlotCFG,InSaveName,InSaveArea)
end
end

end
