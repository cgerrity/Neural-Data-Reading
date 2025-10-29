function [cfg] = DATA_cggAllSessionInformationConfiguration_v2
%DATA_CGGALLSESSIONINFORMATIONCONFIGURATION Summary of this function goes here
%   Detailed explanation goes here

cfg=struct([]);
%%Ig_VU595_07_2023-03-14_A
% Define the first session configuration
Monkey_Name = 'Igor';
ExperimentName = 'IDED_DBC_AH_AN/VU595_DBC';
SessionName = 'Ig_VU595_03_2023-03-08_A';
LearningModelName = 'Ig_VU595_07_2023-03-14_001';

[inputfolder, outdatadir, temporarydir, ~] = ...
    cgg_getBaseFoldersFromSessionInformation(Monkey_Name, ...
    ExperimentName, SessionName);

this_FieldNum = length(cfg) + 1;
cfg(this_FieldNum).inputfolder = inputfolder;
cfg(this_FieldNum).outdatadir = outdatadir;
cfg(this_FieldNum).temporarydir = temporarydir;
cfg(this_FieldNum).Monkey_Name = Monkey_Name;
cfg(this_FieldNum).ExperimentName = ExperimentName;
cfg(this_FieldNum).SessionName = SessionName;
cfg(this_FieldNum).LearningModelName = LearningModelName;
cfg(this_FieldNum).SessionFolder = [outdatadir filesep ExperimentName ...
        filesep SessionName];

end

