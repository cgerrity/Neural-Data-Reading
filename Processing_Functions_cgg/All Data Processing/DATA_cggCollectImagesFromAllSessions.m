
clc; clear; close all;

TargetDir='/Volumes/gerritcg''s home/Data_Neural_gerritcg';

Activity='LFP';
ActivitySubFolders={'Correlation'};
ImageName='Channel_Identification_Mapped_Clusters_%s.pdf';

cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);

Activity='LFP';
ActivitySubFolders={'Channel_Mapping'};
ImageName='Channel_Correlations_Mapped_Time_10_Segments_35_Zoomx1_%s.pdf';

cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);

%%

Activity='WideBand';
ActivitySubFolders={'Activity Example'};
ImageName='Channel_Verification_%s_3_1_Group.pdf';

cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);

Activity='MUA';
cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);

Activity='Spike';
cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);

Activity='LFP';
cgg_gatherImagesFromAllSessions(Activity,ActivitySubFolders,ImageName,TargetDir);
