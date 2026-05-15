function cgg_plotParameterSweep(Incfg,varargin)
%CGG_PLOTPARAMETERSWEEP Summary of this function goes here
%   Detailed explanation goes here

%% Varargin Options

isfunction=exist('varargin','var');

% if isfunction
% WantValidation = CheckVararginPairs('WantValidation', false, varargin{:});
% else
% if ~(exist('WantValidation','var'))
% WantValidation=false;
% end
% end

% if isfunction
% WantAggregate = CheckVararginPairs('WantAggregate', false, varargin{:});
% else
% if ~(exist('WantAggregate','var'))
% WantAggregate=false;
% end
% end

if isfunction
KeepAllFields = CheckVararginPairs('KeepAllFields', true, varargin{:});
else
if ~(exist('KeepAllFields','var'))
KeepAllFields=true;
end
end

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

% ErrorCapSize = cfg_Plotting.ErrorCapSize;

ErrorCapSize = 20;

Tick_Size = 2;

Y_Upper=0;
Y_Lower=1;
Y_Limit_Set = [0,0.25];
Y_Tick_Label_Size = 36;
Y_Tick_Size = 0.05;

LabelAngle = 45;
WantFinished = false;
% WantValidation = false; 
BarWidth  = 12;

%%

% if WantValidation
%     ValidationName = 'Validation';
% else
% ValidationName = 'Testing';
% end
% if WantAggregate
%     MetricType = 'Aggregate';
% else
%     MetricType = 'Peak';
% end
if WantFinished
    FinishedName = 'Finished';
else
FinishedName = 'UnFinished';
end

ListWantAggregate = [true,false];
ListWantValidation = [true,false];

%%
MatchType = Incfg.MatchType;
IsQuaddle = Incfg.IsQuaddle;
cfg = Incfg.cfg;

Epoch = Incfg.Epoch;
TargetDir = cfg.TargetDir.path;
ResultsDir = cfg.ResultsDir.path;

%%
if contains(Epoch,'Synthetic_Easy')
    Y_Limit_Set = [0,1];
end
%%

cfg_Plot = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',Epoch,'PlotFolder','Parameter Sweep New v2');
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
    'Gradient Threshold','Decoder Loss Type','Layers','Initial Units',...
    'Classification Weight','KL Weight','Reconstruction Weight','Session'};
% CurrentCases = {'Model','Classification Weight','KL Weight','Reconstruction Weight'};
% CurrentCases = {'Session'};
CurrentCases = {'Stratification','MultipleInstanceLearningType','Has Loss Weighting','Is Augmented','Dynamic Parameters'};
% CurrentCases = {'Model'};
% CurrentCases = {'Gradient Accumulation Size'};

for wvidx = 1:length(ListWantValidation)
    WantValidation = ListWantValidation(wvidx);
if WantValidation
    ValidationName = 'Validation';
else
    ValidationName = 'Testing';
end
for waidx = 1:length(ListWantAggregate)
    WantAggregate = ListWantAggregate(waidx);
if WantAggregate
    MetricType = 'Aggregate';
else
    MetricType = 'Peak';
end
%%
for cidx = 1:length(CurrentCases)
SweepType = CurrentCases{cidx};
fprintf('*** Plotting Parameter Sweep for %s using %s metric on %s set\n',...
    string(SweepType),MetricType,ValidationName);

[SweepName,SweepNameIgnore] = PARAMETERS_cggEncoderParameterSweep(SweepType);
if ~isempty(SweepNameIgnore)
SweepNameIgnore(end+1) = "NumEpochsSession";
SweepNameIgnore(end+1) = "NumEpochsFull";
else
SweepNameIgnore = "NumEpochsSession";
SweepNameIgnore(end+1) = "NumEpochsFull";
end

[SweepAccuracyPeak,SweepAccuracyAggregate,~,SweepAllNames,RunTable,...
    BestRunTable] = ...
    cgg_procParameterSweepTable(SweepName,SweepNameIgnore, ...
    cfg,'MatchType',MatchType, ...
    'IsQuaddle',IsQuaddle,'RunTable',RunTable, ...
    'BestRunTable',BestRunTable,'WantFinished',WantFinished, ...
    'WantValidation',WantValidation,'Epoch',Epoch, ...
    'KeepAllFields',KeepAllFields);


if WantAggregate
    SweepAccuracy = SweepAccuracyAggregate;
else
    SweepAccuracy = SweepAccuracyPeak;
end
%%
this_X_Tick_Label_Size = Y_Tick_Label_Size;
this_SweepAllNames = SweepAllNames;
BarTitle = SweepType;
this_Y_Limit_Set = Y_Limit_Set;
this_BarWidth = BarWidth;
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
        this_BarWidth = max([length(this_SweepAllNames),BarWidth]);
    case 'Model'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'Multi-Filter')) = "Multi-Filter";
        if find(BestIDX) == find(contains(SweepAllNames,'Multi-Filter'))
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
        end
        % IndicesSorted = cgg_sortModelNamesForParameterSweep(this_SweepAllNames);
        [~,IndicesSorted] = sort(cellfun(@(x) mean(x), SweepAccuracy));
        this_SweepAllNames = this_SweepAllNames(IndicesSorted);
        SweepAccuracy = SweepAccuracy(IndicesSorted);
    case 'Variational'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Variational";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "Not Variational";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
     case 'Data Normalization'
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
        this_BarWidth = max([length(this_SweepAllNames),BarWidth]);
    case 'Initial Learning Rate'
        this_Y_Limit_Set = [0,0.25];
    case 'Session'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Subset";
        this_SweepAllNames = cgg_setSessionNamesForParameterSweep(this_SweepAllNames);
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
        this_BarWidth = max([length(this_SweepAllNames),BarWidth]);
        SweepType = sprintf('%s ~ %s',SweepType,datetime('today'));
        this_X_Tick_Label_Size = 12;
    case 'Stratification'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Hierarchical";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Data Augmentation'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Hierarchical";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Is Augmented'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Augmented";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Has Loss Weighting'
        BestIDX = contains(SweepAllNames,'*');
        this_SweepAllNames = SweepAllNames;
        this_SweepAllNames(contains(SweepAllNames,'true')) = "Loss Weighting";
        this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
    case 'Dynamic Parameters'
        % BestIDX = contains(SweepAllNames,'*');
        % this_SweepAllNames = SweepAllNames;
        % this_SweepAllNames(contains(SweepAllNames,'true')) = "Loss Weighting";
        % this_SweepAllNames(contains(SweepAllNames,'false')) = "None";
        % this_SweepAllNames(BestIDX) = this_SweepAllNames(BestIDX) + "*";
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

wantCI = false;
wantSTD = true;
WantScatter = true;
WantNeurIPSScatter = true;
WantErrorBars = false;

% disp(isempty(ColorOrder))
[b_Plot] = cgg_plotBarGraphWithError(SweepAccuracy,this_SweepAllNames,'X_TickFontSize',this_X_Tick_Label_Size,'ErrorLineWidth',Line_Width,'ErrorCapSize',ErrorCapSize,'wantCI',wantCI,'LabelAngle',LabelAngle,'InFigure',InFigure,'X_Name','','BarWidth',this_BarWidth,'wantSTD',wantSTD,'WantScatter',WantScatter,'WantNeurIPSScatter',WantNeurIPSScatter,'WantErrorBars',WantErrorBars);

title(BarTitle,'FontSize',Title_Size);

Y_Name = 'Accuracy';
if contains(MatchType,'Scaled')
Y_Name = {'Scaled', 'Balanced Accuracy'};
end

if ~iscell(Y_Name)
    Y_Name = {Y_Name};
end

if iscell(Y_Name)
    Y_Label = cell(1,length(Y_Name));
    for idx = 1:length(Y_Name)
    Y_Label{idx} = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name{idx});
    end
% else
    % Y_Label = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name);
end
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

for pidx = 1:length(this_SweepAllNames)
this_Label = InFigure.Children.XTickLabel{pidx};
this_LabelName = extractBefore(extractAfter(this_Label,'}'),'}');
this_CharLength = round(length(this_LabelName)/2);
this_Blank = repmat(' ',[1,this_CharLength]);
this_BlankLabel = replace(this_Label,this_LabelName,this_Blank);
this_SampleSizeName = sprintf('[N = %d]',length(SweepAccuracy{pidx}));
this_XTickLabel = sprintf('%s\\newline%s{%s}',this_Label,this_BlankLabel,this_SampleSizeName);
InFigure.Children.XTickLabel{pidx} = this_XTickLabel;
end

%%

PlotNameExt = sprintf('Parameter-Sweep_%s_%s_%s_%s.pdf',FinishedName,ValidationName,MetricType,SweepType);
PlotPathNameExt = fullfile(SavePath,PlotNameExt);
exportgraphics(InFigure,PlotPathNameExt,'ContentType','vector');

close all
end
end
end

end

