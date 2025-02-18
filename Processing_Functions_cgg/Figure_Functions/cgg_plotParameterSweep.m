function cgg_plotParameterSweep(Incfg)
%CGG_PLOTPARAMETERSWEEP Summary of this function goes here
%   Detailed explanation goes here


%%
cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Line_Width = cfg_Plotting.Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

RangeAccuracyUpper = cfg_Plotting.RangeAccuracyUpper;
RangeAccuracyLower = cfg_Plotting.RangeAccuracyLower;

ErrorCapSize = cfg_Plotting.ErrorCapSize;

Tick_Size = 2;

Y_Upper=0;
Y_Lower=1;
Y_Limit_Set = [0,0.2];
Y_Tick_Label_Size = 36;
Y_Tick_Size = 0.05;

LabelAngle = 45;
WantFinished = false;
WantValidation = true; 
BarWidth  = 12;

%%

if WantValidation
    ValidationName = 'Validation';
else
ValidationName = 'Testing';
end
if WantFinished
    FinishedName = 'Finished';
else
FinishedName = 'UnFinished';
end

%%
MatchType = Incfg.MatchType;
IsQuaddle = Incfg.IsQuaddle;
cfg = Incfg.cfg;

Epoch = Incfg.Epoch;
TargetDir = cfg.TargetDir.path;
ResultsDir = cfg.ResultsDir.path;
%%

cfg_Plot = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Parameter Sweep');
cfg_Plot.ResultsDir=cfg_Plot.TargetDir;


SavePath=cgg_getDirectory(cfg_Plot.ResultsDir,'PlotFolder');

%%
RunTable = [];
BestRunTable = [];
CurrentCases = {'Classifier Hidden Size','Classifier','Data Width', ...
    'Hidden Size','Initial Learning Rate','Variational','L_2 Factor', ...
    'Batch Size','Model','Data Augmentation','Unsupervised Epochs', ...
    'Optimizer','Normalization','Weighted Loss','Stride', ...
    'Gradient Accumulation Size','Loss Weights','Bottleneck Depth','Dropout', ...
    'Gradient Threshold','Decoder Loss Type'};



%%
for cidx = 1:length(CurrentCases)
SweepType = CurrentCases{cidx};
disp(SweepType);

[SweepName,SweepNameIgnore] = PARAMETERS_cggEncoderParameterSweep(SweepType);
if ~isempty(SweepNameIgnore)
SweepNameIgnore(end+1) = "NumEpochsSession";
SweepNameIgnore(end+1) = "NumEpochsFull";
else
SweepNameIgnore = "NumEpochsSession";
SweepNameIgnore(end+1) = "NumEpochsFull";
end

[SweepAccuracy,~,SweepAllNames,RunTable,BestRunTable] = ...
    cgg_procParameterSweepTable(SweepName,SweepNameIgnore,...
    cfg,'MatchType',MatchType,'IsQuaddle',IsQuaddle, ...
    'RunTable',RunTable,'BestRunTable',BestRunTable, ...
    'WantFinished',WantFinished,'WantValidation',WantValidation);


%%
this_X_Tick_Label_Size = Y_Tick_Label_Size;
this_SweepAllNames = SweepAllNames;
BarTitle = SweepType;
this_Y_Limit_Set = Y_Limit_Set;
switch SweepType
    case 'Classifier Hidden Size'
        this_X_Tick_Label_Size = 22;
    case 'Classifier'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'LSTM')) = "LSTM";
        this_SweepAllNames(contains(SweepAllNames,'GRU')) = "GRU";
        this_SweepAllNames(contains(SweepAllNames,'Feedforward')) = "Feedforward";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Hidden Size'
        this_X_Tick_Label_Size = 22;
    case 'Model'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'Multi-Filter')) = "Multi-Filter";
        if find(BestIDX) == find(contains(SweepAllNames,'Multi-Filter'))
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
        end
    case 'Variational'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Variational";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "Not Variational";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
     case 'Data Augmentation'
        this_X_Tick_Label_Size = 12;
    case 'Normalization'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Layer Normalized";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Weighted Loss'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'[]')) = "None";
        this_SweepAllNames(contains(SweepAllNames,'Inverse')) = "Inverse";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Loss Weights'
        BarTitle  = {'Loss Weights','(Recontruction:Classification:Variational)'};
    case 'Initial Learning Rate'
        this_Y_Limit_Set = [0,0.25];
end

%%
InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,0.5,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;

% disp(isempty(ColorOrder))
[b_Plot] = cgg_plotBarGraphWithError(SweepAccuracy,this_SweepAllNames,'X_TickFontSize',this_X_Tick_Label_Size,'ErrorLineWidth',Line_Width,'ErrorCapSize',ErrorCapSize,'wantCI',true,'LabelAngle',LabelAngle,'InFigure',InFigure,'X_Name','','BarWidth',BarWidth);

title(BarTitle,'FontSize',Title_Size);

Y_Name = 'Accuracy';
if contains(MatchType,'Scaled')
Y_Name = 'Scaled Balanced Accuracy';
end
Y_Label = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name);
% ylabel(Y_Name,'FontSize',Y_Name_Size);
ylabel(Y_Label);

YLimits = this_Y_Limit_Set;
ylim(YLimits);

Current_Axis = gca;
Current_Axis.YAxis.FontSize=Y_Tick_Label_Size;
Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);

if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
yticks(Y_Ticks);
end

PlotNameExt = sprintf('Parameter-Sweep_%s_%s_%s.pdf',FinishedName,ValidationName,SweepType);
PlotPathNameExt = fullfile(SavePath,PlotNameExt);
exportgraphics(InFigure,PlotPathNameExt,'ContentType','vector');

close all
end


end

