function cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir,varargin)
%CGG_GATHERIMAGESFROMALLSESSIONS Summary of this function goes here
%   Detailed explanation goes here

%% Example
% Activity='LFP';
% ActivitySubFolders={'Correlation'};
% ImageName='Channel_Identification_Mapped_Clusters_%s.pdf';

% Activity='LFP';
% ActivitySubFolders={'Channel_Mapping'};
% ImageName='Channel_Correlations_Mapped_Time_10_Segments_35_Zoomx1_%s.pdf';

% TargetDir='/Volumes/gerritcg''s home/Data_Neural_gerritcg';

%%
isfunction=exist('varargin','var');

if isfunction
[cfg] = cgg_generateSessionAggregationFolders('TargetDir',TargetDir,...
    'Activity',Activity,'ActivitySubFolders',ActivitySubFolders,...
    varargin{:});
else
    Existence_Array = [exist('TargetDir','var'), ...
        exist('Activity','var'), exist('ActivitySubFolders','var')];
    Existence_Value = bi2de(Existence_Array, 'left-msb');
    
    switch Existence_Value
        case 7 % TargetDir, Activity, ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Activity',Activity,...
                'ActivitySubFolders',ActivitySubFolders);
        case 6 % TargetDir, Activity, ~ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,'Activity',Activity);
        case 5 % TargetDir, ~Activity, ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir,...
                'ActivitySubFolders',ActivitySubFolders);
        case 4 % TargetDir, ~Activity, ~ActivitySubFolders
            [cfg] = cgg_generateSessionAggregationFolders(...
                'TargetDir',TargetDir);
        case 3 % ~TargetDir, Activity, ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Activity',Activity,...
                'ActivitySubFolders',ActivitySubFolders);
        case 2 % ~TargetDir, Activity, ~ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'Activity',Activity);
        case 1 % ~TargetDir, ~Activity, ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders(...
                'ActivitySubFolders',ActivitySubFolders);
        case 0 % ~TargetDir, ~Activity, ~ActivitySubFolders
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
        otherwise
            [cfg, TargetDir] = cgg_generateSessionAggregationFolders;
    end % End for what directory variables are in the workspace currently
end % End for whether this is being called within a function

%%

[cfg_Session] = DATA_cggAllSessionInformationConfiguration;

%%

for sidx=1:length(cfg_Session)
    SessionDir=cfg_Session(sidx).SessionFolder;
if isfunction
cgg_gatherImageFromSingleSession(SessionDir,Activity,...
    ActivitySubFolders,ImageName,cfg.TargetDir.path,varargin{:});
else
cgg_gatherImageFromSingleSession(SessionDir,Activity,...
    ActivitySubFolders,ImageName,cfg.TargetDir.path);
end
end


end

