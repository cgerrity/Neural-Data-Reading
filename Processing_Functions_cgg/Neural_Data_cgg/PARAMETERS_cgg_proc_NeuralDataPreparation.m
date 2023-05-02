function cfg = PARAMETERS_cgg_proc_NeuralDataPreparation


% This script includes the Parameters for cgg_proc_NeuralDataPreparation.
% The parameters are explained and default values are included.

%% Trial Cutting Information

% This string determines what the 0 point will be when aligning the trials.
% It willl only affect the time vectors for each trial. It will not affect
% how long a trial is or what the cut events are.
trial_align_evcode = 'FixCentralCueStart';

% This is how much padding we want before 'TrlStart' and after 'TrlEnd'.
% The default is 1 second because information will be included in the
% following and preceding trials and overlap isn't necessary
padtime = 1; % Time in seconds

%% Data Processiong Information

% Narrow-band frequencies to filter out.

% We have power line peaks at 60 Hz and its harmonics, and also often
% have a peak at around 600 Hz and its harmonics.

notch_filter_freqs = [ 60, 120, 180 ];
notch_filter_bandwidth = 2.0;

% Frequency cutoffs for getting the LFP, spike, and rectified signals.

% The LFP signal is low-pass filtered and downsampled. Typical features are
% in the range of 2 Hz to 200 Hz.

lfp_maxfreq = 300;
lfp_samprate = 1000;

% The spike signal is high-pass filtered. Typical features have a time scale
% of 1 ms or less, but there's often a broad tail lasting several ms.

spike_minfreq = 100;

% The rectified signal is a measure of spiking activity. The signal is
% band-pass filtered, then rectified (absolute value), then low-pass filtered
% at a frequency well below the lower corner, then downsampled.

rect_bandfreqs = [ 750 5000 ];
rect_lowpassfreq = 300;
rect_samprate = lfp_samprate;


% Nominal frequency for reading gaze data.

% As long as this is higher than the device's sampling rate (300-600 Hz),
% it doesn't really matter what it is.
% The gaze data itself is non-uniformly sampled.

gaze_samprate = lfp_samprate;


%% Probe Information

% Probe Mapping. This will determine what the reference mapping is for the
% following sections. The options are unmapped, mapped, and recorded.
% unmapped is the probe channels with no mapping applied. Mapped is the
% probe channels with the channel mapping selected in the folder applied.
% This mapping can be added later and marked with "_correct" to be used as
% this mapping. Lastly, recorded can be chosen which uses the mapping that
% was used when the recording took place. As long as channel mapping is
% active it will remap this channel to the mapped position. Probe mapping
% will not have an effect if all the contacts for a probe are selected
% since they will all be remapped together.

probe_mapping='recorded'; %unmapped, mapped, recorded

% This vector will determine what the probes that are being used are. Here
% the probes are 64 channel NeuroNexus probes and there are only 2 of them.
% The first 64 channels are one probe and the second 64 channels are
% another probe. If a single channel is desired then single_channel will 
% select the channel that will be used for analysis. The function should be
% run using each of the probes and can save them separately depending on
% which area they represent.
% first_probe=1:64;
% second_probe=65:128;
% single_channel=1;
first_probe=65:128;
second_probe=1:64;
third_probe=193:256;
fourth_probe=321:384;
fifth_probe=257:320;
single_channel=1;

% This variable determines which probe will be used for analysis. Use a
% cell array with all the probe locations that are being looked at.
probe_selection={first_probe,second_probe,third_probe,fourth_probe,...
    fifth_probe};

% This variable determines what the probe area is and uses it for saving
% the data and organizing it by area. For the naming choose an area then a
% three digit number. (ACC_###, CD_###, PFC_###)

% first_probe_area='ACC_001';
% second_probe_area='CD_001';
% single_channel_area='SINGLE_001';

first_probe_area='ACC_001';
second_probe_area='ACC_002';
third_probe_area='PFC_001';
fourth_probe_area='CD_001';
fifth_probe_area='CD_002';

% Use a cell array with all the probe locations that are being looked at.
probe_area={first_probe_area,second_probe_area,third_probe_area,...
    fourth_probe_area,fifth_probe_area};


%% Boolean Decision Section


% This boolean determines whether the channels will be remapped. If the
% channels are already recorded in the proper order than this should be set
% to false. If the channel mapping is correct for the recording and the
% value is set to true it will still remain correct. The channel mapping
% that is used is the one with "*correct*" or the first channel mapping
% listed.
want_channel_remap = true;

% This boolean determines whether the artifact rejection UI will appear.
% This uses the FieldTrip function "ft_rejectvisual". For this function it
% will likely not be necessary so it should be set to false.

want_artifact_rejection = false;


%%

w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end


end

%
% This is the end of the file.