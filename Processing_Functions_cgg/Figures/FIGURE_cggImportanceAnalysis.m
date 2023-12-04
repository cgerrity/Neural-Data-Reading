
clc; clear; close all;

Epoch = 'Decision';
Decoder = 'Linear';
NumFolds = 1; FoldStart = 1; FoldEnd = 10;
NumRankings = 8;
SmoothFactor = 3;
NumRankings_All = [8,16,32,64];
SmoothFactor_All = [1,3,5,10];

%%

DecoderType = Decoder;

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

DataWidth = cfg_Decoder.DataWidth/1000;
WindowStride = cfg_Decoder.WindowStride/1000;

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

for fidx=FoldStart:FoldEnd

    Fold = fidx;

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;
LinearImportance_NameExt = 'Linear_Importance.mat';
LinearImportance_PathNameExt = [Decoding_Dir filesep LinearImportance_NameExt];

m_LinearImportance = matfile(LinearImportance_PathNameExt,'Writable',false);
% IA_Window_Accuracy = m_LinearImportance.IA_Window_Accuracy;
% IA_Accuracy = m_LinearImportance.IA_Accuracy;
Difference_Window_Accuracy(:,:,:,fidx) = m_LinearImportance.Difference_Window_Accuracy;
Difference_Accuracy(:,:,fidx) = m_LinearImportance.Difference_Accuracy;

end

% Difference_Accuracy = mean(Difference_Accuracy,3);
% Difference_Window_Accuracy = mean(Difference_Window_Accuracy,4);

% Difference_Accuracy(:,:,1:4)=[];
% Difference_Window_Accuracy(:,:,:,1:4)=[];

Difference_Accuracy = -Difference_Accuracy;
Difference_Window_Accuracy = -Difference_Window_Accuracy;

InSavePlotCFG = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Plots;
%%
% cgg_plotImportanceAnalysis(Difference_Accuracy,Decoder,InSavePlotCFG);

for nidx=1:length(NumRankings_All)
    for sidx=1:length(SmoothFactor_All)
        NumRankings=NumRankings_All(nidx);
        SmoothFactor=SmoothFactor_All(sidx);
cgg_plotImportanceAnalysisRanking(Difference_Accuracy,NumRankings,Time_Start,DataWidth,WindowStride,SmoothFactor,DecoderType,InSavePlotCFG)
    end
end
