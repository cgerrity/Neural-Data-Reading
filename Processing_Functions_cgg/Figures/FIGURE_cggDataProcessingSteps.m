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
probe_area_ACC='ACC_001';
probe_area_CD='CD_001';
Activity_Type='WideBand';

Start_Time=0;
End_Time=0.25;

Alignment_Type='Decision';
Smooth_Factor=10;

Sel_Trial=5;
Sel_Channel=1:64;

Count_Sel_Trial=10;
rereference_type='median';


%%

rect_bandfreqs = [ 750 5000 ];
rect_lowpassfreq = 300;
rect_samprate = 1000;

want_quiet=false;

feedtype = 'no';
if exist('want_quiet', 'var')
  if ~want_quiet
    feedtype = 'text';
  end
end

%%

[~,~,SessionName,ExperimentName,...
    outdatadir_EventInformation,outdatadir_FrameInformation] = ...
    cgg_generateAllNeuralDataFolders('inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[outdatadir_WideBand_ACC,outdatadir_LFP_ACC,outdatadir_Spike_ACC,...
    outdatadir_MUA_ACC] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area_ACC);

[outdatadir_WideBand_CD,outdatadir_LFP_CD,outdatadir_Spike_CD,...
    outdatadir_MUA_CD] = cgg_generateNeuralDataFolders(...
    outdatadir,SessionName,ExperimentName,probe_area_CD);

[cfg_outplotdir_ACC] = cgg_generateNeuralPlottingFoldersforProcessing(outdatadir,...
    SessionName,ExperimentName,probe_area_ACC,Activity_Type);

[cfg_outplotdir_CD] = cgg_generateNeuralPlottingFoldersforProcessing(outdatadir,...
    SessionName,ExperimentName,probe_area_CD,Activity_Type);

%%

rectrialdefs=load([outdatadir filesep ExperimentName filesep ...
    SessionName filesep 'Trial_Information' filesep ...
    'Trial_Definition_' SessionName]);
rectrialdefs=rectrialdefs.rectrialdefs;

NumTrials=length(rectrialdefs);

%%

fullfilename_ACC=[outdatadir_WideBand_ACC filesep Activity_Type '_Trial_%d.mat'];

fullfilename_CD=[outdatadir_WideBand_CD filesep Activity_Type '_Trial_%d.mat'];

recdata_wideband_ACC=load(sprintf(fullfilename_ACC,Sel_Trial));
recdata_wideband_ACC=recdata_wideband_ACC.this_recdata_wideband;

recdata_wideband_CD=load(sprintf(fullfilename_CD,Sel_Trial));
recdata_wideband_CD=recdata_wideband_CD.this_recdata_wideband;

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

% Produce rectified activity signal.

filtconfigband = struct( 'bpfilter', 'yes', 'bpfilttype', 'but', ...
  'bpfreq', [ min(rect_bandfreqs), max(rect_bandfreqs) ] );
rectconfig = struct('rectify', 'yes');
filtconfiglow = struct( ...
  'lpfilter', 'yes', 'lpfilttype', 'but', 'lpfreq', rect_lowpassfreq );
resampleconfig = struct( 'resamplefs', rect_samprate, 'detrend', 'no' );

filtconfigband.feedback = feedtype;
rectconfig.feedback = feedtype;
filtconfiglow.feedback = feedtype;
resampleconfig.feedback = feedtype;


% FIXME - We can group some of these calls, but that requires detailed
% knowledge of the order in which FT applies preprocessing operations.
% Do them individually for safety's sake.

recdata_bandpass_ACC = ft_preprocessing(filtconfigband, recdata_wideband_ACC);
recdata_rectify_ACC = ft_preprocessing(rectconfig, recdata_bandpass_ACC);
recdata_lowpass_ACC = ft_preprocessing(filtconfiglow, recdata_rectify_ACC);
recdata_resample_ACC = ft_resampledata(resampleconfig, recdata_lowpass_ACC);

recdata_bandpass_CD = ft_preprocessing(filtconfigband, recdata_wideband_CD);
recdata_rectify_CD = ft_preprocessing(rectconfig, recdata_bandpass_CD);
recdata_lowpass_CD = ft_preprocessing(filtconfiglow, recdata_rectify_CD);
recdata_resample_CD = ft_resampledata(resampleconfig, recdata_lowpass_CD);

%% Rereferencing

% ACC
[Connected_Channels_ACC,Disconnected_Channels_ACC,is_any_previously_rereferenced_ACC] = cgg_getDisconnectedChannels(NumTrials,...
    Count_Sel_Trial,fullfilename_ACC);

Message_Rereferencing_ACC=sprintf('--- Disconnected Channels for Area: %s are:',probe_area_ACC);
for didx=1:length(Disconnected_Channels_ACC)
    if didx<length(Disconnected_Channels_ACC)
    Message_Rereferencing_ACC=sprintf([Message_Rereferencing_ACC ' %d,'],Disconnected_Channels_ACC(didx));
    else
    Message_Rereferencing_ACC=sprintf([Message_Rereferencing_ACC ' %d'],Disconnected_Channels_ACC(didx));
    end
end

disp(Message_Rereferencing_ACC);

cfg_rereference_ACC=[];
cfg_rereference_ACC.reref='yes';
cfg_rereference_ACC.refchannel=Connected_Channels_ACC; %All Good Channels
cfg_rereference_ACC.refmethod=rereference_type;

% CD
[Connected_Channels_CD,Disconnected_Channels_CD,is_any_previously_rereferenced_CD] = cgg_getDisconnectedChannels(NumTrials,...
    Count_Sel_Trial,fullfilename_CD);

Message_Rereferencing_CD=sprintf('--- Disconnected Channels for Area: %s are:',probe_area_CD);
for didx=1:length(Disconnected_Channels_CD)
    if didx<length(Disconnected_Channels_CD)
    Message_Rereferencing_CD=sprintf([Message_Rereferencing_CD ' %d,'],Disconnected_Channels_CD(didx));
    else
    Message_Rereferencing_CD=sprintf([Message_Rereferencing_CD ' %d'],Disconnected_Channels_CD(didx));
    end
end

disp(Message_Rereferencing_CD);

cfg_rereference_CD=[];
cfg_rereference_CD.reref='yes';
cfg_rereference_CD.refchannel=Connected_Channels_CD; %All Good Channels
cfg_rereference_CD.refmethod=rereference_type;

recdata_wideband_reref_ACC = ft_preprocessing(cfg_rereference_ACC, recdata_wideband_ACC);
recdata_bandpass_reref_ACC = ft_preprocessing(filtconfigband, recdata_wideband_reref_ACC);
recdata_rectify_reref_ACC = ft_preprocessing(rectconfig, recdata_bandpass_reref_ACC);
recdata_lowpass_reref_ACC = ft_preprocessing(filtconfiglow, recdata_rectify_reref_ACC);
recdata_resample_reref_ACC = ft_resampledata(resampleconfig, recdata_lowpass_reref_ACC);

recdata_wideband_reref_CD = ft_preprocessing(cfg_rereference_CD, recdata_wideband_CD);
recdata_bandpass_reref_CD = ft_preprocessing(filtconfigband, recdata_wideband_reref_CD);
recdata_rectify_reref_CD = ft_preprocessing(rectconfig, recdata_bandpass_reref_CD);
recdata_lowpass_reref_CD = ft_preprocessing(filtconfiglow, recdata_rectify_reref_CD);
recdata_resample_reref_CD = ft_resampledata(resampleconfig, recdata_lowpass_reref_CD);

%%

WideBand_ACC=recdata_wideband_ACC.trial{1};
WideBand_CD=recdata_wideband_CD.trial{1};
WideBand_Reref_ACC=recdata_wideband_reref_ACC.trial{1};
WideBand_Reref_CD=recdata_wideband_reref_CD.trial{1};

Bandpass_ACC=recdata_bandpass_ACC.trial{1};
Bandpass_CD=recdata_bandpass_CD.trial{1};
Bandpass_Reref_ACC=recdata_bandpass_reref_ACC.trial{1};
Bandpass_Reref_CD=recdata_bandpass_reref_CD.trial{1};

Rectify_ACC=recdata_rectify_ACC.trial{1};
Rectify_CD=recdata_rectify_CD.trial{1};
Rectify_Reref_ACC=recdata_rectify_reref_ACC.trial{1};
Rectify_Reref_CD=recdata_rectify_reref_CD.trial{1};

Lowpass_ACC=recdata_lowpass_ACC.trial{1};
Lowpass_CD=recdata_lowpass_CD.trial{1};
Lowpass_Reref_ACC=recdata_lowpass_reref_ACC.trial{1};
Lowpass_Reref_CD=recdata_lowpass_reref_CD.trial{1};

Resample_ACC=recdata_resample_ACC.trial{1};
Resample_CD=recdata_resample_CD.trial{1};
Resample_Reref_ACC=recdata_resample_reref_ACC.trial{1};
Resample_Reref_CD=recdata_resample_reref_CD.trial{1};

Average_ACC=smoothdata(Resample_ACC,2,'movmean',Smooth_Factor);
Average_CD=smoothdata(Resample_CD,2,'movmean',Smooth_Factor);
Average_Reref_ACC=smoothdata(Resample_Reref_ACC,2,'movmean',Smooth_Factor);
Average_Reref_CD=smoothdata(Resample_Reref_CD,2,'movmean',Smooth_Factor);

Time_WideBand_ACC=recdata_wideband_ACC.time{1};
Time_WideBand_CD=recdata_wideband_CD.time{1};

Time_Bandpass_ACC=recdata_bandpass_ACC.time{1};
Time_Bandpass_CD=recdata_bandpass_CD.time{1};

Time_Rectify_ACC=recdata_rectify_ACC.time{1};
Time_Rectify_CD=recdata_rectify_CD.time{1};

Time_Lowpass_ACC=recdata_lowpass_ACC.time{1};
Time_Lowpass_CD=recdata_lowpass_CD.time{1};

Time_Resample_ACC=recdata_resample_ACC.time{1};
Time_Resample_CD=recdata_resample_CD.time{1};

Time_Average_ACC=Time_Resample_ACC;
Time_Average_CD=Time_Resample_CD;

%%

[~,Start_IDX_WideBand]=min(abs(Time_WideBand_ACC-Start_Time));
[~,End_IDX_WideBand]=min(abs(Time_WideBand_ACC-End_Time));

this_Time_WideBand_ACC=Time_WideBand_ACC(Start_IDX_WideBand:End_IDX_WideBand);
this_Time_WideBand_CD=Time_WideBand_CD(Start_IDX_WideBand:End_IDX_WideBand);

this_WideBand_ACC=WideBand_ACC(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);
this_WideBand_CD=WideBand_CD(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);
this_WideBand_Reref_ACC=WideBand_Reref_ACC(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);
this_WideBand_Reref_CD=WideBand_Reref_CD(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);

[~,Start_IDX_Bandpass]=min(abs(Time_Bandpass_ACC-Start_Time));
[~,End_IDX_Bandpass]=min(abs(Time_Bandpass_ACC-End_Time));

this_Time_Bandpass_ACC=Time_Bandpass_ACC(Start_IDX_Bandpass:End_IDX_Bandpass);
this_Time_Bandpass_CD=Time_Bandpass_CD(Start_IDX_Bandpass:End_IDX_Bandpass);

this_Bandpass_ACC=Bandpass_ACC(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);
this_Bandpass_CD=Bandpass_CD(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);
this_Bandpass_Reref_ACC=Bandpass_Reref_ACC(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);
this_Bandpass_Reref_CD=Bandpass_Reref_CD(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);

[~,Start_IDX_Rectify]=min(abs(Time_Rectify_ACC-Start_Time));
[~,End_IDX_Rectify]=min(abs(Time_Rectify_ACC-End_Time));

this_Time_Rectify_ACC=Time_Rectify_ACC(Start_IDX_Rectify:End_IDX_Rectify);
this_Time_Rectify_CD=Time_Rectify_CD(Start_IDX_Rectify:End_IDX_Rectify);

this_Rectify_ACC=Rectify_ACC(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);
this_Rectify_CD=Rectify_CD(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);
this_Rectify_Reref_ACC=Rectify_Reref_ACC(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);
this_Rectify_Reref_CD=Rectify_Reref_CD(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);

[~,Start_IDX_Lowpass]=min(abs(Time_Lowpass_ACC-Start_Time));
[~,End_IDX_Lowpass]=min(abs(Time_Lowpass_ACC-End_Time));

this_Time_Lowpass_ACC=Time_Lowpass_ACC(Start_IDX_Lowpass:End_IDX_Lowpass);
this_Time_Lowpass_CD=Time_Lowpass_CD(Start_IDX_Lowpass:End_IDX_Lowpass);

this_Lowpass_ACC=Lowpass_ACC(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);
this_Lowpass_CD=Lowpass_CD(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);
this_Lowpass_Reref_ACC=Lowpass_Reref_ACC(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);
this_Lowpass_Reref_CD=Lowpass_Reref_CD(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);

[~,Start_IDX_Resample]=min(abs(Time_Resample_ACC-Start_Time));
[~,End_IDX_Resample]=min(abs(Time_Resample_ACC-End_Time));

this_Time_Resample_ACC=Time_Resample_ACC(Start_IDX_Resample:End_IDX_Resample);
this_Time_Resample_ACC=linspace(Start_Time,End_Time,length(this_Time_Resample_ACC));
this_Time_Resample_CD=Time_Resample_CD(Start_IDX_Resample:End_IDX_Resample);
this_Time_Resample_CD=linspace(Start_Time,End_Time,length(this_Time_Resample_CD));

this_Resample_ACC=Resample_ACC(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);
this_Resample_CD=Resample_CD(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);
this_Resample_Reref_ACC=Resample_Reref_ACC(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);
this_Resample_Reref_CD=Resample_Reref_CD(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);

[~,Start_IDX_Average]=min(abs(Time_Average_ACC-Start_Time));
[~,End_IDX_Average]=min(abs(Time_Average_ACC-End_Time));

this_Time_Average_ACC=Time_Average_ACC(Start_IDX_Average:End_IDX_Average);
this_Time_Average_ACC=linspace(Start_Time,End_Time,length(this_Time_Average_ACC));
this_Time_Average_CD=Time_Average_CD(Start_IDX_Average:End_IDX_Average);
this_Time_Average_CD=linspace(Start_Time,End_Time,length(this_Time_Average_CD));

this_Average_ACC=Average_ACC(Sel_Channel,Start_IDX_Average:End_IDX_Average);
this_Average_CD=Average_CD(Sel_Channel,Start_IDX_Average:End_IDX_Average);
this_Average_Reref_ACC=Average_Reref_ACC(Sel_Channel,Start_IDX_Average:End_IDX_Average);
this_Average_Reref_CD=Average_Reref_CD(Sel_Channel,Start_IDX_Average:End_IDX_Average);

%%

PlotDir_ACC=cfg_outplotdir_ACC.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
PlotDir_CD=cfg_outplotdir_CD.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;

%% WideBand Plotting

YLim_WideBand=[-100,100];
YName_WideBand='WideBand Activity (\muV)';
Title_WideBand='WideBand Activity';
SaveName_WideBand_ACC=[sprintf('Data_Processing_WideBand_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_WideBand_CD=[sprintf('Data_Processing_WideBand_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_WideBand_Reref='WideBand Activity (Rereferenced)';
SaveName_WideBand_Reref_ACC=[sprintf('Data_Processing_WideBand_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_WideBand_Reref_CD=[sprintf('Data_Processing_WideBand_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_WideBand_ACC,this_Time_WideBand_ACC,...
    'Time (s)',YName_WideBand,Title_WideBand,YLim_WideBand,0,...
    PlotDir_ACC.WideBand,SaveName_WideBand_ACC,'ACC');
cgg_plotDataProcessingSteps(this_WideBand_CD,this_Time_WideBand_CD,...
    'Time (s)',YName_WideBand,Title_WideBand,YLim_WideBand,0,...
    PlotDir_CD.WideBand,SaveName_WideBand_CD,'CD');
cgg_plotDataProcessingSteps(this_WideBand_Reref_ACC,this_Time_WideBand_ACC,...
    'Time (s)',YName_WideBand,Title_WideBand_Reref,YLim_WideBand,0,...
    PlotDir_ACC.WideBand,SaveName_WideBand_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_WideBand_Reref_CD,this_Time_WideBand_CD,...
    'Time (s)',YName_WideBand,Title_WideBand_Reref,YLim_WideBand,0,...
    PlotDir_CD.WideBand,SaveName_WideBand_Reref_CD,'CD');

%% Bandpass Plotting

YLim_Bandpass=[-50,50];
YName_Bandpass='Bandpass Activity (\muV)';
Title_Bandpass='Bandpass Activity';
SaveName_Bandpass_ACC=[sprintf('Data_Processing_Bandpass_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Bandpass_CD=[sprintf('Data_Processing_Bandpass_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_Bandpass_Reref='Bandpass Activity (Rereferenced)';
SaveName_Bandpass_Reref_ACC=[sprintf('Data_Processing_Bandpass_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Bandpass_Reref_CD=[sprintf('Data_Processing_Bandpass_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_Bandpass_ACC,this_Time_Bandpass_ACC,...
    'Time (s)',YName_Bandpass,Title_Bandpass,YLim_Bandpass,0,...
    PlotDir_ACC.Bandpass,SaveName_Bandpass_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Bandpass_CD,this_Time_Bandpass_CD,...
    'Time (s)',YName_Bandpass,Title_Bandpass,YLim_Bandpass,0,...
    PlotDir_CD.Bandpass,SaveName_Bandpass_CD,'CD');
cgg_plotDataProcessingSteps(this_Bandpass_Reref_ACC,this_Time_Bandpass_ACC,...
    'Time (s)',YName_Bandpass,Title_Bandpass_Reref,YLim_Bandpass,0,...
    PlotDir_ACC.Bandpass,SaveName_Bandpass_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Bandpass_Reref_CD,this_Time_Bandpass_CD,...
    'Time (s)',YName_Bandpass,Title_Bandpass_Reref,YLim_Bandpass,0,...
    PlotDir_CD.Bandpass,SaveName_Bandpass_Reref_CD,'CD');

%% Rectify Plotting

YLim_Rectify=[0,50];
YName_Rectify='Rectified Activity (\muV)';
Title_Rectify='Rectified Activity';
SaveName_Rectify_ACC=[sprintf('Data_Processing_Rectify_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Rectify_CD=[sprintf('Data_Processing_Rectify_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_Rectify_Reref='Rectified Activity (Rereferenced)';
SaveName_Rectify_Reref_ACC=[sprintf('Data_Processing_Rectify_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Rectify_Reref_CD=[sprintf('Data_Processing_Rectify_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_Rectify_ACC,this_Time_Rectify_ACC,...
    'Time (s)',YName_Rectify,Title_Rectify,YLim_Rectify,0,...
    PlotDir_ACC.Rectify,SaveName_Rectify_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Rectify_CD,this_Time_Rectify_CD,...
    'Time (s)',YName_Rectify,Title_Rectify,YLim_Rectify,0,...
    PlotDir_CD.Rectify,SaveName_Rectify_CD,'CD');
cgg_plotDataProcessingSteps(this_Rectify_Reref_ACC,this_Time_Rectify_ACC,...
    'Time (s)',YName_Rectify,Title_Rectify_Reref,YLim_Rectify,0,...
    PlotDir_ACC.Rectify,SaveName_Rectify_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Rectify_Reref_CD,this_Time_Rectify_CD,...
    'Time (s)',YName_Rectify,Title_Rectify_Reref,YLim_Rectify,0,...
    PlotDir_CD.Rectify,SaveName_Rectify_Reref_CD,'CD');

%% Lowpass Plotting

YLim_Lowpass=[0,10];
YName_Lowpass='Lowpass Activity (\muV)';
Title_Lowpass='Lowpass Activity';
SaveName_Lowpass_ACC=[sprintf('Data_Processing_Lowpass_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Lowpass_CD=[sprintf('Data_Processing_Lowpass_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_Lowpass_Reref='Lowpass Activity (Rereferenced)';
SaveName_Lowpass_Reref_ACC=[sprintf('Data_Processing_Lowpass_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Lowpass_Reref_CD=[sprintf('Data_Processing_Lowpass_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_Lowpass_ACC,this_Time_Lowpass_ACC,...
    'Time (s)',YName_Lowpass,Title_Lowpass,YLim_Lowpass,0,...
    PlotDir_ACC.Lowpass,SaveName_Lowpass_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Lowpass_CD,this_Time_Lowpass_CD,...
    'Time (s)',YName_Lowpass,Title_Lowpass,YLim_Lowpass,0,...
    PlotDir_CD.Lowpass,SaveName_Lowpass_CD,'CD');
cgg_plotDataProcessingSteps(this_Lowpass_Reref_ACC,this_Time_Lowpass_ACC,...
    'Time (s)',YName_Lowpass,Title_Lowpass_Reref,YLim_Lowpass,0,...
    PlotDir_ACC.Lowpass,SaveName_Lowpass_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Lowpass_Reref_CD,this_Time_Lowpass_CD,...
    'Time (s)',YName_Lowpass,Title_Lowpass_Reref,YLim_Lowpass,0,...
    PlotDir_CD.Lowpass,SaveName_Lowpass_Reref_CD,'CD');

%% Resample Plotting

YLim_Resample=[0,10];
YName_Resample='Resample Activity (\muV)';
Title_Resample='Resample Activity';
SaveName_Resample_ACC=[sprintf('Data_Processing_Resample_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Resample_CD=[sprintf('Data_Processing_Resample_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_Resample_Reref='Resample Activity (Rereferenced)';
SaveName_Resample_Reref_ACC=[sprintf('Data_Processing_Resample_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Resample_Reref_CD=[sprintf('Data_Processing_Resample_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_Resample_ACC,this_Time_Resample_ACC,...
    'Time (s)',YName_Resample,Title_Resample,YLim_Resample,0,...
    PlotDir_ACC.Resample,SaveName_Resample_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Resample_CD,this_Time_Resample_CD,...
    'Time (s)',YName_Resample,Title_Resample,YLim_Resample,0,...
    PlotDir_CD.Resample,SaveName_Resample_CD,'CD');
cgg_plotDataProcessingSteps(this_Resample_Reref_ACC,this_Time_Resample_ACC,...
    'Time (s)',YName_Resample,Title_Resample_Reref,YLim_Resample,0,...
    PlotDir_ACC.Resample,SaveName_Resample_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Resample_Reref_CD,this_Time_Resample_CD,...
    'Time (s)',YName_Resample,Title_Resample_Reref,YLim_Resample,0,...
    PlotDir_CD.Resample,SaveName_Resample_Reref_CD,'CD');

%% Average Plotting

YLim_Average=[0,10];
YName_Average='Average Activity (\muV)';
Title_Average='Average Activity';
SaveName_Average_ACC=[sprintf('Data_Processing_Average_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Average_CD=[sprintf('Data_Processing_Average_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
Title_Average_Reref='Average Activity (Rereferenced)';
SaveName_Average_Reref_ACC=[sprintf('Data_Processing_Average_Reref_ACC_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];
SaveName_Average_Reref_CD=[sprintf('Data_Processing_Average_Reref_CD_Trial_%s_Channel_',num2str(Sel_Trial)) '%s'];

cgg_plotDataProcessingSteps(this_Average_ACC,this_Time_Average_ACC,...
    'Time (s)',YName_Average,Title_Average,YLim_Average,0,...
    PlotDir_ACC.Average,SaveName_Average_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Average_CD,this_Time_Average_CD,...
    'Time (s)',YName_Average,Title_Average,YLim_Average,0,...
    PlotDir_CD.Average,SaveName_Average_CD,'CD');
cgg_plotDataProcessingSteps(this_Average_Reref_ACC,this_Time_Average_ACC,...
    'Time (s)',YName_Average,Title_Average_Reref,YLim_Average,0,...
    PlotDir_ACC.Average,SaveName_Average_Reref_ACC,'ACC');
cgg_plotDataProcessingSteps(this_Average_Reref_CD,this_Time_Average_CD,...
    'Time (s)',YName_Average,Title_Average_Reref,YLim_Average,0,...
    PlotDir_CD.Average,SaveName_Average_Reref_CD,'CD');