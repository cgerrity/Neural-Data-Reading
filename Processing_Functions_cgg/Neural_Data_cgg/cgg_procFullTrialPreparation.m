function [Norm_Segmented_Data,Norm_Segmented_Baseline,...
    TrialNumbers_Data,TrialNumbers_Baseline,Segmented_Data_Unsmoothed,Segmented_Data_Smoothed,Segmented_Baseline_Smoothed,Segmented_Data_Smoothed_Norm] = ...
    cgg_procFullTrialPreparation(Start_IDX_Data,End_IDX_Data,...
    Start_IDX_Base,End_IDX_Base,fullfilename,Smooth_Factor,varargin)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

% Get the directories needed depending on whether this is called as a
% function or as a script for testing
if isfunction
[cfg] = cgg_generateNeuralDataFoldersTopLevel(varargin{:});
elseif (exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',...
    inputfolder,'outdatadir',outdatadir);
elseif (exist('inputfolder','var'))&&~(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('inputfolder',inputfolder);
elseif ~(exist('inputfolder','var'))&&(exist('outdatadir','var'))
[cfg] = cgg_generateNeuralDataFoldersTopLevel('outdatadir',outdatadir);
else
[cfg] = cgg_generateNeuralDataFoldersTopLevel;
end

inputfolder=cfg.inputfolder;
outdatadir=cfg.outdatadir;

%%

[Segmented_Data,TrialNumbers_Data,Segmented_Data_Unsmoothed] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX_Data,End_IDX_Data,fullfilename,Smooth_Factor,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

[Segmented_Baseline,TrialNumbers_Baseline] = cgg_getAllTrialDataFromTimeSegments_v2(Start_IDX_Base,End_IDX_Base,fullfilename,Smooth_Factor,'inputfolder',inputfolder,...
    'outdatadir',outdatadir);

Segmented_Data_Smoothed=Segmented_Data(:,:,:);
Segmented_Baseline_Smoothed=Segmented_Baseline(:,:,:);
%%

[~,~,NumTrials]=size(Segmented_Data);

Norm_Segmented_Data=nan(size(Segmented_Data));
Norm_Segmented_Baseline=nan(size(Segmented_Baseline));

for tidx=1:NumTrials
    this_InData=Segmented_Data(:,:,tidx);
    this_InBaseline=Segmented_Baseline(:,:,tidx);
    
    % Normalize each trial by its respective baseline period
[~,~,~,~,Norm_InData,Norm_InBaseline] = cgg_procTrialNormalization_v2(...
    this_InData,this_InBaseline,this_InBaseline);

Norm_Segmented_Data(:,:,tidx)=Norm_InData;
Norm_Segmented_Baseline(:,:,tidx)=Norm_InBaseline;

end

Segmented_Data_Smoothed_Norm=Norm_Segmented_Data(1,:,:);
end

