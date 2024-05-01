clc; clear; close all;

Epoch = 'Decision';
FoldStart = 1; FoldEnd = 10;
NumFolds = numel(FoldStart:FoldEnd); 
SamplingFrequency=1000;

%%

cfg_Sessions = DATA_cggAllSessionInformationConfiguration;

cfg_Decoder = PARAMETERS_cgg_procSimpleDecoders_v2;

cfg_Processing = PARAMETERS_cgg_procFullTrialPreparation_v2(Epoch);

DataWidth = cfg_Decoder.DataWidth/SamplingFrequency;
WindowStride = cfg_Decoder.WindowStride/SamplingFrequency;

Decoders = cfg_Decoder.Decoder;
NumDecoders = length(Decoders);

if strcmp(Epoch,'Decision')
    Time_Start = -cfg_Processing.Window_Before_Data;
else
    Time_Start = 0;
end

outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;

for didx=1:NumDecoders
for fidx=FoldStart:FoldEnd

    Fold = fidx;
    Decoder = Decoders{didx};

cfg = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',Epoch,'Decoder',Decoder,'Fold',Fold);

Decoding_Dir = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Fold.path;

Accuracy_NameExt = sprintf('%s_Accuracy.mat',Decoder);

Accuracy_PathNameExt = [Decoding_Dir filesep Accuracy_NameExt];

m_Accuracy = matfile(Accuracy_PathNameExt,'Writable',false);
Accuracy(didx,fidx,:) = m_Accuracy.Accuracy;
Window_Accuracy(didx,fidx,:) = m_Accuracy.Window_Accuracy;

end
end

InSavePlotCFG = cfg.TargetDir.Aggregate_Data.Epoched_Data.Epoch.Decoding.Decoder.Plots;

%%

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

Tick_Size = 2;

[~,~,NumIterations]=size(Accuracy);

XValues=1:NumIterations;
YValues=Accuracy;

Decoders_Cat = categorical(Decoders);
Decoders_Cat = reordercats(Decoders_Cat,Decoders);

fig_activity=figure;
fig_activity.WindowState='maximized';
fig_activity.PaperSize=[20 10];

PlotColor(1,:)=[0 0.4470 0.7410];
PlotColor(2,:)=[0.8500 0.3250 0.0980];
PlotColor(3,:)=[0.9290 0.6940 0.1250];
PlotColor(4,:)=[0.4940 0.1840 0.5560];
PlotColor(5,:)=[0.4660 0.6740 0.1880];

p_Mean = NaN(1,NumDecoders);
p_Error = NaN(1,NumDecoders);

hold on
for didx=1:NumDecoders
[this_p_Mean,this_p_Error] = cgg_plotLinePlotWithShadedError(XValues,squeeze(YValues(didx,:,:)),PlotColor(didx,:));

    this_p_Mean.LineWidth = Line_Width;
    this_p_Mean.DisplayName = Decoders{didx};

    p_Mean(didx)=this_p_Mean;
    p_Error(didx)=this_p_Error;

end

hold off

legend(p_Mean,'Location','best','FontSize',Legend_Size);

xlabel('Iteration','FontSize',X_Name_Size);
ylabel('Accuracy','FontSize',Y_Name_Size);
Accuracy_Title=sprintf('Accuracy over %d Iterations and %d Folds',NumIterations,NumFolds);
title(Accuracy_Title,'FontSize',Title_Size);

xticks([1,Tick_Size:Tick_Size:NumIterations]);



