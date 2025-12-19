function cgg_plotOverallAccuracy(FullTable,cfg,varargin)
%CGG_PLOTOVERALLACCURACY Summary of this function goes here
%   Detailed explanation goes here
isfunction=exist('varargin','var');

if isfunction
IsAttentional = CheckVararginPairs('IsAttentional', false, varargin{:});
else
if ~(exist('IsAttentional','var'))
IsAttentional=false;
end
end

if isfunction
IsBlock = CheckVararginPairs('IsBlock', false, varargin{:});
else
if ~(exist('IsBlock','var'))
IsBlock=false;
end
end

if isfunction
IsLabelClass = CheckVararginPairs('IsLabelClass', false, varargin{:});
else
if ~(exist('IsLabelClass','var'))
IsLabelClass=false;
end
end

if isfunction
cfg_OverwritePlot = CheckVararginPairs('cfg_OverwritePlot', struct(), varargin{:});
else
if ~(exist('cfg_OverwritePlot','var'))
cfg_OverwritePlot=struct();
end
end
%%
cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle;
cfg_Names = NAMEPARAMETERS_cgg_nameVariables;

Line_Width = cfg_Plotting.Line_Width;
Error_Line_Width = cfg_Plotting.Error_Line_Width;

X_Name_Size = cfg_Plotting.X_Name_Size;
Y_Name_Size = cfg_Plotting.Y_Name_Size;
Title_Size = cfg_Plotting.Title_Size;
SubTitle_Size = cfg_Plotting.SubTitle_Size;

Label_Size = cfg_Plotting.Label_Size;
Legend_Size = cfg_Plotting.Legend_Size;

RangeFactorUpper = cfg_Plotting.RangeFactorUpper;
RangeFactorLower = cfg_Plotting.RangeFactorLower;

RangeAccuracyUpper = cfg_Plotting.RangeAccuracyUpper;
RangeAccuracyLower = cfg_Plotting.RangeAccuracyLower;

ErrorCapSize = cfg_Plotting.ErrorCapSize;

Tick_Size = 2;

BarWidth  = 12;

Y_Upper=0;
Y_Lower=1;
Y_Limit_Set = [0,0.35];
Y_Tick_Label_Size = 36;
Y_Tick_Size = 0.05;

switch IsLabelClass
    case 'Label'
    Y_Limit_Set = [-0.05,0.4];
    Y_Tick_Size = 0.2;
    case 'Class'
    Y_Limit_Set = [-0.5,1];
    Y_Tick_Size = 0.25;
end

%%
% TimeCut = [];
OverwritePlotFolder = '';
% Line_Width_Indicator = [];
FigureSizeOverwrite = [];
AccuracyCut = [];
OverwriteYTickSize = [];
WantSubTitle = [];
wantCI = true;

% if isfield(cfg_OverwritePlot,'TimeCut')
% TimeCut = cfg_OverwritePlot.TimeCut;
% end
if isfield(cfg_OverwritePlot,'PlotFolder')
OverwritePlotFolder = cfg_OverwritePlot.PlotFolder;
end
% if isfield(cfg_OverwritePlot,'Line_Width_Indicator')
% Line_Width_Indicator = cfg_OverwritePlot.Line_Width_Indicator;
% end
if isfield(cfg_OverwritePlot,'BarFigureSizeOverwrite')
FigureSizeOverwrite = cfg_OverwritePlot.BarFigureSizeOverwrite;
end
if isfield(cfg_OverwritePlot,'BarAccuracyCut')
AccuracyCut = cfg_OverwritePlot.BarAccuracyCut;
end
if isfield(cfg_OverwritePlot,'BarYTickSize')
OverwriteYTickSize = cfg_OverwritePlot.BarYTickSize;
end
if isfield(cfg_OverwritePlot,'WantSubTitle')
WantSubTitle = cfg_OverwritePlot.WantSubTitle;
end
if isfield(cfg_OverwritePlot,'wantCI')
wantCI = cfg_OverwritePlot.wantCI;
end
%%
WantCombined = any(ismember('Session Number', FullTable.Properties.VariableNames));
PlotSubTitle = '';
IsGrouped = false;
NumSessions = [];
if WantCombined
    NumSessions = cellfun(@(x) length(x),FullTable.("Session Number"));
    IsGrouped = all(diff(NumSessions) == 0);
    if IsGrouped
        PlotSubTitle = sprintf('[N = %d]',NumSessions(1));
    end
    if IsAttentional
    Y_Limit_Set = [0,0.5];
    Y_Tick_Size = 0.25;
    else
    Y_Limit_Set = [0,0.2];
    Y_Tick_Size = 0.05;
    end
    switch IsLabelClass
    case 'Label'
    Y_Limit_Set = [-0.05,0.4];
    Y_Tick_Size = 0.2;
    case 'Class'
    Y_Limit_Set = [-0.5,1];
    Y_Tick_Size = 0.25;
    end
    % CountPerSample = FullTable.NumSessions;
end
if isfield(cfg,'IA_Type')
    if isempty(PlotSubTitle)
        PlotSubTitle = sprintf('%s',cfg.IA_Type);
    else
        PlotSubTitle = sprintf('%s %s',cfg.IA_Type,PlotSubTitle);
    end
end

if ~isempty(WantSubTitle)
    if ~WantSubTitle
        PlotSubTitle = '';
    end
end

if ~isempty(OverwriteYTickSize)
Y_Tick_Size = OverwriteYTickSize;
end


%%

% Decoders=FullTable.Properties.RowNames;
LoopNames=FullTable.Properties.RowNames;

% [NumDecoders,~]=size(FullTable);
[NumLoops,~]=size(FullTable);

WantReducedX_Labels = false;
if NumLoops > 30
WantReducedX_Labels = true;
Error_Line_Width = 1;
end

BarWidth = max([NumLoops,BarWidth]);

if NumLoops > 12
    X_Tick_Label_Size = 24;
    ErrorCapSize = ErrorCapSize*(12/NumLoops);
elseif IsAttentional
    X_Tick_Label_Size = 24;
else
    X_Tick_Label_Size = Y_Tick_Label_Size;
end

%%
cfg.LoopType = cgg_setNaming(cfg.LoopType);
ExtraSaveTerm = cgg_setNaming(cfg.ExtraSaveTerm);

% RandomChance=cfg.RandomChance;
% MostCommon=cfg.MostCommon;
% Stratified=cfg.Stratified;

Accuracy_All=FullTable.(cfg_Names.TableNameAccuracy);

% Decoders_Cat = categorical(Decoders);
% Decoders_Cat = reordercats(Decoders_Cat,Decoders);

LoopNames_Cat = categorical(LoopNames);
LoopNames_Cat = reordercats(LoopNames_Cat,LoopNames);

% fig_accuracy=figure;
% fig_accuracy.Units="normalized";
% fig_accuracy.Position=[0,0,1,1];
% fig_accuracy.Units="inches";
% fig_accuracy.PaperUnits="inches";
% PlotPaperSize=fig_accuracy.Position;
% PlotPaperSize(1:2)=[];
% fig_accuracy.PaperSize=PlotPaperSize;

if NumLoops<8
PlotColor(1,:)=[0 0.4470 0.7410];
PlotColor(2,:)=[0.8500 0.3250 0.0980];
PlotColor(3,:)=[0.9290 0.6940 0.1250];
PlotColor(4,:)=[0.4940 0.1840 0.5560];
PlotColor(5,:)=[0.4660 0.6740 0.1880];
PlotColor(6,:)=[0.3010 0.7450 0.9330];
PlotColor(7,:)=[0.6350 0.0780 0.1840];
else
PlotColor=turbo(NumLoops);
end
% p_Mean = gobjects(NumDecoders+1,1);
% p_Error = gobjects(NumDecoders,1);
p_Mean = gobjects(NumLoops+1,1);
p_Error = gobjects(NumLoops,1);

% InvalidPlots = false(NumDecoders,1);
InvalidPlots = false(NumLoops,1);



% Values=cell(NumDecoders,1);
% ColorOrder=cell(NumDecoders,1);
% Values=cell(NumLoops,1);
ColorOrder=cell(NumLoops,1);
% %%
% hold on
% % for didx=1:NumDecoders
% for lidx=1:NumLoops
% 
%     this_Accuracy=Accuracy_All{lidx};
% 
%     if ~isempty(this_Accuracy)
% 
% [NumFolds,NumIterations]=size(this_Accuracy);
% 
% Y_Value_Final=this_Accuracy(:,NumIterations);
% 
Values=FullTable.Accuracy;
% 
% XValues=1:NumIterations;
% YValues=this_Accuracy;
% 
% [this_p_Mean,this_p_Error] = cgg_plotLinePlotWithShadedError(XValues,YValues,PlotColor(lidx,:));
% 
%     this_p_Mean.LineWidth = Line_Width;
%     % this_p_Mean.DisplayName = Decoders{lidx};
%     this_p_Mean.DisplayName = LoopNames{lidx};
% 
%     ColorOrder{lidx}=this_p_Mean.Color;
% 
%     p_Mean(lidx)=this_p_Mean;
%     p_Error(lidx)=this_p_Error;
%     else
%         InvalidPlots(lidx)=true;
%     end
% 
%     Y_Upper=max([Y_Upper;YValues(:)]);
%     Y_Lower=min([Y_Lower;YValues(:)]);
% 
% end
% 
% YLimLower=Y_Lower*(1-RangeFactorLower);
% YLimUpper=Y_Upper*(1+RangeFactorUpper);
% 
% YLimLower=max([0,YLimLower]);
% YLimUpper=min([1,YLimUpper]);
% 
% YLimLower=RangeAccuracyLower;
% YLimUpper=RangeAccuracyUpper;
% 
% % p_Random=yline(RandomChance);
% % p_MostCommon=yline(MostCommon);
% % p_Stratified=yline(Stratified);
% 
% % p_MostCommon.LineWidth = Line_Width;
% % p_Random.LineWidth = Line_Width;
% % p_Stratified.LineWidth = Line_Width;
% % p_MostCommon.DisplayName = 'Most Common';
% % p_Random.DisplayName = 'Random Chance';
% % p_Stratified.DisplayName = 'Stratified';
% 
% % p_Mean(NumDecoders+1)=p_Random;
% % p_Mean(NumLoops+1)=p_MostCommon;
% % p_Mean(NumLoops+2)=p_Random;
% % p_Mean(NumLoops+3)=p_Stratified;
% 
% hold off
% 
% p_Mean(InvalidPlots)=[];
% p_Error(InvalidPlots)=[];
% 
% % ValueNames=Decoders;
ValueNames=LoopNames;


% 
% % Values{NumDecoders+1}=RandomChance;
% % ValueNames{NumDecoders+1}='Random Chance';
% % ColorOrder{NumDecoders+1}=p_Random.Color;
% 
% Values(InvalidPlots)=[];
% ValueNames(InvalidPlots)=[];
% ColorOrder(InvalidPlots)=[];
% ColorOrder=cell2mat(ColorOrder);
% 
% legend(p_Mean,'Location','best','FontSize',Legend_Size);
% 
% Y_Name = 'Accuracy';
% if contains(cfg.MatchType,'Scaled')
% Y_Name = 'Normalized Accuracy';
% end
% 
% xlabel('Iteration','FontSize',X_Name_Size);
% ylabel(Y_Name,'FontSize',Y_Name_Size);
% Accuracy_Title=sprintf('Accuracy over %d Iterations and %d Folds',NumIterations,NumFolds);
% title(Accuracy_Title,'FontSize',Title_Size);
% 
% xticks([1,Tick_Size:Tick_Size:NumIterations]);
% ylim([YLimLower,YLimUpper]);
% ylim([0,1]);

%%
cfg_Sessions = DATA_cggAllSessionInformationConfiguration;
outdatadir=cfg_Sessions(1).outdatadir;
TargetDir=outdatadir;
ResultsDir=cfg_Sessions(1).temporarydir;
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',cfg.TargetDir,...
%     'Epoch',cfg.Epoch,'Accuracy',true);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
%     'Epoch',cfg.Epoch,'Accuracy',true);

thisPlotFolder = 'Network Results';

if IsBlock
    thisPlotFolder = 'Block IA';
elseif IsLabelClass
    thisPlotFolder = 'Label-Class';
elseif ~isempty(OverwritePlotFolder)
    thisPlotFolder = OverwritePlotFolder;
end

cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
    'Epoch',cfg.Epoch,'PlotFolder',thisPlotFolder,'PlotSubFolder',cfg.Subset);
cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder',thisPlotFolder,'PlotSubFolder',cfg.Subset);
cfg_Plot.ResultsDir=cfg_tmp.TargetDir;

% if IsBlock
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Block IA','PlotSubFolder',cfg.Subset);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Block IA','PlotSubFolder',cfg.Subset);
% cfg_Plot.ResultsDir=cfg_tmp.TargetDir;
% else
% cfg_Plot = cgg_generateDecodingFolders('TargetDir',TargetDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',cfg.Subset);
% cfg_tmp = cgg_generateDecodingFolders('TargetDir',ResultsDir,...
%     'Epoch',cfg.Epoch,'PlotFolder','Network Results','PlotSubFolder',cfg.Subset);
% cfg_Plot.ResultsDir=cfg_tmp.TargetDir;
% end

% drawnow;
% 
% % SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
SavePath = cgg_getDirectory(cfg_Plot.ResultsDir,'SubFolder_1');
% SaveName=['Accuracy_Over_Iterations' ExtraSaveTerm '_Type_' cfg.LoopType];
% 
% SaveNameExt=[SaveName '.pdf'];
% 
% SavePathNameExt=[SavePath filesep SaveNameExt];
% 
% saveas(fig_accuracy,SavePathNameExt,'pdf');
% 
% close all

%% Bar Graph

fig_accuracy_bar=figure;
if isempty(FigureSizeOverwrite)
fig_accuracy_bar.Units="normalized";
fig_accuracy_bar.Position=[0,0,0.5,1];
else
fig_accuracy_bar.Units="inches";
fig_accuracy_bar.Position=[0,0,FigureSizeOverwrite];
end
fig_accuracy_bar.Units="inches";
fig_accuracy_bar.PaperUnits="inches";
PlotPaperSize=fig_accuracy_bar.Position;
PlotPaperSize(1:2)=[];
fig_accuracy_bar.PaperSize=PlotPaperSize;
drawnow;

LabelAngle = 30;
ColorOrder = PlotColor;
if length(ValueNames) == 6
ColorOrder = cfg_Plotting.Rainbow;
end
% disp(isempty(ColorOrder))
[b_Plot] = cgg_plotBarGraphWithError(Values,ValueNames,'ColorOrder',ColorOrder,'X_TickFontSize',X_Tick_Label_Size,'ErrorLineWidth',Error_Line_Width,'ErrorCapSize',ErrorCapSize,'wantCI',wantCI,'LabelAngle',LabelAngle,'InFigure',fig_accuracy_bar,'X_Name','','BarWidth',BarWidth,'WantReducedX_Labels',WantReducedX_Labels);
drawnow;
if ~IsGrouped && ~isempty(NumSessions)
for pidx = 1:length(fig_accuracy_bar.Children.XTickLabel)
    this_Label = fig_accuracy_bar.Children.XTickLabel{pidx};
    this_LabelName = extractBefore(extractAfter(this_Label,'}'),'}');
    this_CharLength = round(length(this_LabelName)/2);
    this_Blank = repmat(' ',[1,this_CharLength]);
    this_BlankLabel = replace(this_Label,this_LabelName,this_Blank);
    this_SampleSizeName = sprintf('[N = %d]',NumSessions(pidx));
    this_XTickLabel = sprintf('%s\\newline%s{%s}',this_Label,this_BlankLabel,this_SampleSizeName);
    fig_accuracy_bar.Children.XTickLabel{pidx} = this_XTickLabel;
end
end

% p_MostCommon=yline(MostCommon,"-",'Most Common');
% p_Random=yline(RandomChance,"-",'Random Chance');
% p_MostCommon.LineWidth = Line_Width;
% p_Random.LineWidth = Line_Width;
% 
% p_MostCommon.LabelOrientation = 'horizontal';
% p_MostCommon.LabelVerticalAlignment = 'middle';
% p_MostCommon.LabelHorizontalAlignment = 'left';
% p_MostCommon.FontSize = Label_Size;
% p_Random.LabelOrientation = 'horizontal';
% p_Random.LabelVerticalAlignment = 'middle';
% p_Random.LabelHorizontalAlignment = 'left';
% p_Random.FontSize = Label_Size;

% Y_Name = 'Accuracy';
% if contains(cfg.MatchType,'Scaled')
% Y_Name = 'Scaled Balanced Accuracy';
% end
if contains(cfg.MatchType,'Scaled')
Y_Name = {'Scaled', 'Balanced Accuracy'};
if contains(cfg.MatchType,'MicroAccuracy')
Y_Name{2} = 'Accuracy';
end
end



if iscell(Y_Name)
    Y_Label = cell(length(Y_Name),1);
for yidx = 1:length(Y_Name)
    Y_Label{yidx} = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name{yidx});
end
else
    Y_Label = sprintf('{\\fontsize{%d}%s}',Y_Name_Size,Y_Name);
end
% ylabel(Y_Name,'FontSize',Y_Name_Size);
ylabel(Y_Label);

% Bar_Title=sprintf('Accuracy of %s over %d Folds',cfg.LoopTitle,NumFolds);

if isfield(cfg,'LoopTitle') && ~isempty(cfg.LoopTitle)
PlotTitle = cfg.LoopTitle;
end

if iscell(PlotTitle)
    Title_Label = cell(1,length(PlotTitle));
    for tidx = 1:length(PlotTitle)
        Title_Label{tidx} = sprintf('{\\fontsize{%d}%s}',Title_Size,PlotTitle{tidx});
    end
else
    Title_Label = sprintf('\\fontsize{%d}%s',Title_Size,PlotTitle);
end

if ~isempty(PlotTitle)
title(Title_Label);
end

% if isfield(cfg,'LoopTitle') && ~isempty(cfg.LoopTitle)
% Bar_Title=sprintf('%s',cfg.LoopTitle);
% title(Bar_Title,'FontSize',Title_Size);
% end

if IsGrouped
subtitle(PlotSubTitle,'FontSize',SubTitle_Size);
end

% ylim([0,Y_Upper*(1+RangeFactorUpper)]);
% ylim([YLimLower,YLimUpper]);
% ylim([0,1]);
YLimits = Y_Limit_Set;
ylim(YLimits);

Current_Axis = gca;
Current_Axis.YAxis.FontSize=Y_Tick_Label_Size;
Y_Ticks = YLimits(1):Y_Tick_Size:YLimits(2);

if ~(isempty(Y_Ticks) || any(isnan(Y_Ticks)))
yticks(Y_Ticks);
end

if ~isempty(AccuracyCut)
ylim(AccuracyCut);
end


%%
drawnow;
% fprintf("Pausing For Bar\n");
% pause(30);
% SavePath=cfg_Plot.ResultsDir.Aggregate_Data.Epoched_Data.Epoch.Plots.Accuracy.path;
% SaveName=['Accuracy_Overall' ExtraSaveTerm '_Type_' cfg.LoopType];
% SaveName=['Peak-Accuracy' ExtraSaveTerm cfg.LoopType];

% SaveName=['Peak-Accuracy' cfg.LoopType ExtraSaveTerm];
SaveName="Peak-Accuracy" + string(cfg.LoopType) + string(ExtraSaveTerm);

% SaveNameExt=[SaveName '.pdf'];
SaveNameExt=SaveName + ".pdf";

% SavePathNameExt=[SavePath filesep SaveNameExt];
SavePathNameExt=fullfile(SavePath, SaveNameExt);

exportgraphics(fig_accuracy_bar,SavePathNameExt,'ContentType','vector');
% saveas(fig_accuracy_bar,SavePathNameExt,'pdf');

close(fig_accuracy_bar);
% close all

end

