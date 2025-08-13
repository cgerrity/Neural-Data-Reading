function cfg = NAMEPARAMETERS_cgg_nameVariables(varargin)
%PARAMETERS_CGG_GETDISCONNECTEDCHANNELS Summary of this function goes here
%   Detailed explanation goes here

% Important Note: Variable Name does not change. Allowable changes are to
% the value of the variable. All functions call the specified field name.

%% Model Names
% These are the names in the model variable table for the different types
% of models. The ZeroFeature and Feature names are for the model where the
% presence of a non-zero feature are detected first (ZeroFeature) then the
% second model determines the non-zero feature.
ZeroFeatureTableName='ZeroFeature';
FeatureTableName='Feature';
% All referes to the model where each feature is decoded in addition to the
% zero feature.
AllTableName='All';

%% Accuracy Metric Names
% Metrics for the different accuracy metrics that are calculated and stored
% in a table

TableNameAccuracy='Accuracy';
TableNameWindow_Accuracy='Window Accuracy';
TableNameCM_Table='CM Table';
TableNameSplit_Table='Split Table';

%% Extra Save Term
% These are the extra terms added to the save name for the decoding
% results. Subset indicates the results are performed on a subset of the
% data. ZeroFeature indicates that the results use the zero feature
% decoder model. AR indicates that the input is transformed by AR modeling.
% Stride refers to the number of samples that are passed when moving the
% window along the data. Width refers to how many samples are used in the
% input to the decoder.

ExtraSaveTermDecoders='Decoder_%s';

ExtraSaveTermSubset='Subset';
ExtraSaveTermZeroFeature='ZeroFeature';
ExtraSaveTermAR='AR_%d';

ExtraSaveTermWindowStride='Stride_%d';
ExtraSaveTermDataWidth='Width_%d';

% ExtraSaveTermFilterColumn='Split';
ExtraSaveTermFilterColumn='';

%% Epoch Names
% Names for the different epochs for the data

Epoch_Decision='Decision';
Epoch_1='Epoch_1';
Epoch_2='Epoch_2';
Epoch_3='Epoch_3';

%% Loop Types
% Names for the different Loops for the accuracy results data

LoopDecoder='Decoder';
LoopAR='AR';
LoopProcessing='Processing';
LoopSubset='Subset';
LoopDataWidth='DataWidth';
LoopWindowStride='WindowStride';
LoopMatchType='MatchType';
LoopBest='Best';
LoopUnknown='LoopTypeUnknown';

%% Loop Titles
% Titles for the different looping options
LoopTitleDecoder='Decoder';
LoopTitleAR='AR Model Parameters';
LoopTitleProcessing='Processing Options';
LoopTitleSubset='Subset';
LoopTitleDataWidth='Data Width';
LoopTitleWindowStride='Window Stride';
LoopTitleMatchType='Match Type';
LoopTitleBest='Best Model';
LoopTitleUnknown='Loop Type Unknown';

%%
w = whos;
for a = 1:length(w) 
cfg.(w(a).name) = eval(w(a).name); 
end




end
