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
End_Time=0.5;

Alignment_Type='Decision';
Smooth_Factor=250;

Sel_Trial=5;
Sel_Channel=1:64;


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

%%

WideBand_ACC=recdata_wideband_ACC.trial{1};
WideBand_CD=recdata_wideband_CD.trial{1};

Bandpass_ACC=recdata_bandpass_ACC.trial{1};
Bandpass_CD=recdata_bandpass_CD.trial{1};

Rectify_ACC=recdata_rectify_ACC.trial{1};
Rectify_CD=recdata_rectify_CD.trial{1};

Lowpass_ACC=recdata_lowpass_ACC.trial{1};
Lowpass_CD=recdata_lowpass_CD.trial{1};

Resample_ACC=recdata_resample_ACC.trial{1};
Resample_CD=recdata_resample_CD.trial{1};


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

%%

[~,Start_IDX_WideBand]=min(abs(Time_WideBand_ACC-Start_Time));
[~,End_IDX_WideBand]=min(abs(Time_WideBand_ACC-End_Time));

this_Time_WideBand_ACC=Time_WideBand_ACC(Start_IDX_WideBand:End_IDX_WideBand);
this_Time_WideBand_CD=Time_WideBand_CD(Start_IDX_WideBand:End_IDX_WideBand);

this_WideBand_ACC=WideBand_ACC(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);
this_WideBand_CD=WideBand_CD(Sel_Channel,Start_IDX_WideBand:End_IDX_WideBand);

[~,Start_IDX_Bandpass]=min(abs(Time_Bandpass_ACC-Start_Time));
[~,End_IDX_Bandpass]=min(abs(Time_Bandpass_ACC-End_Time));

this_Time_Bandpass_ACC=Time_Bandpass_ACC(Start_IDX_Bandpass:End_IDX_Bandpass);
this_Time_Bandpass_CD=Time_Bandpass_CD(Start_IDX_Bandpass:End_IDX_Bandpass);

this_Bandpass_ACC=Bandpass_ACC(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);
this_Bandpass_CD=Bandpass_CD(Sel_Channel,Start_IDX_Bandpass:End_IDX_Bandpass);

[~,Start_IDX_Rectify]=min(abs(Time_Rectify_ACC-Start_Time));
[~,End_IDX_Rectify]=min(abs(Time_Rectify_ACC-End_Time));

this_Time_Rectify_ACC=Time_Rectify_ACC(Start_IDX_Rectify:End_IDX_Rectify);
this_Time_Rectify_CD=Time_Rectify_CD(Start_IDX_Rectify:End_IDX_Rectify);

this_Rectify_ACC=Rectify_ACC(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);
this_Rectify_CD=Rectify_CD(Sel_Channel,Start_IDX_Rectify:End_IDX_Rectify);

[~,Start_IDX_Lowpass]=min(abs(Time_Lowpass_ACC-Start_Time));
[~,End_IDX_Lowpass]=min(abs(Time_Lowpass_ACC-End_Time));

this_Time_Lowpass_ACC=Time_Lowpass_ACC(Start_IDX_Lowpass:End_IDX_Lowpass);
this_Time_Lowpass_CD=Time_Lowpass_CD(Start_IDX_Lowpass:End_IDX_Lowpass);

this_Lowpass_ACC=Lowpass_ACC(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);
this_Lowpass_CD=Lowpass_CD(Sel_Channel,Start_IDX_Lowpass:End_IDX_Lowpass);

[~,Start_IDX_Resample]=min(abs(Time_Resample_ACC-Start_Time));
[~,End_IDX_Resample]=min(abs(Time_Resample_ACC-End_Time));

this_Time_Resample_ACC=Time_Resample_ACC(Start_IDX_Resample:End_IDX_Resample);
this_Time_Resample_CD=Time_Resample_CD(Start_IDX_Resample:End_IDX_Resample);

this_Resample_ACC=Resample_ACC(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);
this_Resample_CD=Resample_CD(Sel_Channel,Start_IDX_Resample:End_IDX_Resample);

%%

PlotDir_ACC=cfg_outplotdir_ACC.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;
PlotDir_CD=cfg_outplotdir_CD.outdatadir.Experiment.Session.Plots.Area.Activity.Processing_Steps;

%% WideBand Plotting

YLim_WideBand=[-100,100];
YName_WideBand='WideBand Activity (\muV)';
Title_WideBand='WideBand Activity';
SaveName_WideBand='Data_Processing_WideBand_Channel_%s';

cgg_plotDataProcessingSteps(this_WideBand_ACC,this_Time_WideBand_ACC,...
    'Time (s)',YName_WideBand,Title_WideBand,YLim_WideBand,0,...
    PlotDir_ACC.WideBand,SaveName_WideBand);
cgg_plotDataProcessingSteps(this_WideBand_CD,this_Time_WideBand_CD,...
    'Time (s)',YName_WideBand,Title_WideBand,YLim_WideBand,0,...
    PlotDir_CD.WideBand,SaveName_WideBand);

%%
% 
% fig_WideBand_ACC=figure;
% plot(this_Time_WideBand_ACC,this_WideBand_ACC);
% 
% fig_Bandpass_ACC=figure;
% plot(this_Time_Bandpass_ACC,this_Bandpass_ACC);
% 
% fig_Rectify_ACC=figure;
% plot(this_Time_Rectify_ACC,this_Rectify_ACC);
% 
% fig_Lowpass_ACC=figure;
% plot(this_Time_Lowpass_ACC,this_Lowpass_ACC);
% 
% fig_Resample_ACC=figure;
% plot(this_Time_Resample_ACC,this_Resample_ACC);
% 
% fig_WideBand_CD=figure;
% plot(this_Time_WideBand_CD,this_WideBand_CD);
% 
% fig_Bandpass_CD=figure;
% plot(this_Time_Bandpass_CD,this_Bandpass_CD);
% 
% fig_Rectify_CD=figure;
% plot(this_Time_Rectify_CD,this_Rectify_CD);
% 
% fig_Lowpass_CD=figure;
% plot(this_Time_Lowpass_CD,this_Lowpass_CD);
% 
% fig_Resample_CD=figure;
% plot(this_Time_Resample_CD,this_Resample_CD);

% [NumChannels_ACC,NumSamples_ACC,~]=size(Segmented_ACC);

