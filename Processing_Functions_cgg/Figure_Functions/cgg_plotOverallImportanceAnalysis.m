function cgg_plotOverallImportanceAnalysis(RemovalPlotTable,cfg,varargin)
%CGG_PLOTOVERALLIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Legend_Size = CheckVararginPairs('Legend_Size', 18, varargin{:});
else
if ~(exist('Legend_Size','var'))
Legend_Size=18;
end
end

if isfunction
Y_Name = CheckVararginPairs('Y_Name', 'Scaled Balanced Accuracy', varargin{:});
else
if ~(exist('Y_Name','var'))
Y_Name='Scaled Balanced Accuracy';
end
end

if isfunction
YLimits = CheckVararginPairs('YLimits', [0,0.18], varargin{:});
else
if ~(exist('YLimits','var'))
YLimits=[0,0.2];
end
end

if isfunction
Y_Name_Area = CheckVararginPairs('Y_Name_Area', 'Percent of Channels from Area', varargin{:});
else
if ~(exist('Y_Name_Area','var'))
Y_Name_Area='Percent of Channels from Area';
end
end

if isfunction
Y_Name_AreaRelative = CheckVararginPairs('Y_Name_AreaRelative', 'Percent Relative to Mean', varargin{:});
else
if ~(exist('Y_Name_AreaRelative','var'))
Y_Name_AreaRelative='Percent Relative to Mean';
end
end

if isfunction
YLimits_Area = CheckVararginPairs('YLimits_Area', [-0.08,0.08], varargin{:});
else
if ~(exist('YLimits_Area','var'))
YLimits_Area=[-0.08,0.08];
end
end

if isfunction
SmoothWindow = CheckVararginPairs('SmoothWindow', [NaN,NaN], varargin{:});
else
if ~(exist('SmoothWindow','var'))
SmoothWindow=[NaN,NaN];
end
end

if isfunction
SmoothWindow_Area = CheckVararginPairs('SmoothWindow_Area', [0,10], varargin{:});
else
if ~(exist('SmoothWindow_Area','var'))
SmoothWindow_Area=[0,10];
end
end

% if isfunction
% TimeOffset = CheckVararginPairs('TimeOffset', 0, varargin{:});
% else
% if ~(exist('TimeOffset','var'))
% TimeOffset=0;
% end
% end

if isfunction
YLimits_Time = CheckVararginPairs('YLimits_Time', [-1,1], varargin{:});
else
if ~(exist('YLimits_Time','var'))
YLimits_Time=[-0.5,1];
end
end

if isfunction
Y_Name_Time = CheckVararginPairs('Y_Name_Time', 'Time (s)', varargin{:});
else
if ~(exist('Y_Name_Time','var'))
Y_Name_Time='Time (s)';
end
end

% if isfunction
% SmoothWindow_Time = CheckVararginPairs('SmoothWindow_Time', [0,10], varargin{:});
% else
% if ~(exist('SmoothWindow_Time','var'))
% SmoothWindow_Time=[0,10];
% end
% end

if isfunction
WantCI = CheckVararginPairs('WantCI', false, varargin{:});
else
if ~(exist('WantCI','var'))
WantCI=false;
end
end

X_Name = 'Number of Channels Removed';

[RemovalTypeIDX,RemovalType] = findgroups(RemovalPlotTable{:,"Removal Type"});
NumRemovalTypes = length(RemovalType);

%%

Time_Start = cfg.Time_Start;
SamplingRate = cfg.SamplingFrequency;
DataWidth = cfg.DataWidth/SamplingRate;
WindowStride = cfg.WindowStride/SamplingRate;
Tick_Size_Time = 0.5;

% Time_Start_Adjusted = Time_Start+DataWidth/2+TimeOffset;

% Time = cgg_getTime(cfg.Time_Start,cfg.SamplingFrequency,cfg.DataWidth,cfg.WindowStride,cfg.NumWindows,TimeOffset);

%%
for ridx = 1:NumRemovalTypes

    %%

this_RemovalType = RemovalType(ridx);
this_RemovalTypeIDX = RemovalTypeIDX == ridx;
this_RemovalTypeTable = RemovalPlotTable(this_RemovalTypeIDX,:);

[NameIDX,Names] = findgroups(this_RemovalTypeTable{:,"Name"});
NumNames = length(Names);

Plot_X = cell(1,NumNames);
Plot_Y = cell(1,NumNames);
Plot_Error = cell(1,NumNames);
PlotNames = cell(1,NumNames);

Plot_WindowAccuracy = cell(1,NumNames);
Plot_WindowAccuracyTime = cell(1,NumNames);
Plot_WindowAccuracyTime_Error = cell(1,NumNames);

SingleAreaPlotNames = this_RemovalTypeTable{1,"Area Names"};
SingleAreaPlotNames = SingleAreaPlotNames{1};
NumAreas = length(SingleAreaPlotNames);

cfg_Plotting = PLOTPARAMETERS_cgg_plotPlotStyle();
PlotColors = cell(1,NumAreas);

for aidx = 1:NumAreas
    this_Area = SingleAreaPlotNames{aidx};
    this_PlotColorName = sprintf('Color_%s',this_Area);
    PlotColors{aidx} = hex2rgb(cfg_Plotting.(this_PlotColorName));
end

AreaRelativePlot_Y = cell(NumAreas,NumNames);
AreaPlot_Y = cell(NumAreas,NumNames);
AreaPlot_X = cell(NumAreas,NumNames);
AreaPlot_Error = cell(NumAreas,NumNames);
AreaPlotNames = cell(NumAreas,NumNames);

% AreaPlot_Y = cell(1,NumAreas*NumNames);
% AreaPlot_X = cell(1,NumAreas*NumNames);
% AreaPlot_Error = cell(1,NumAreas*NumNames);
% AreaPlotNames = cell(1,NumAreas*NumNames);

for nidx = 1:NumNames

this_Name = Names(nidx);
this_NameIDX = NameIDX == nidx;
this_NameTable = RemovalPlotTable(this_NameIDX,:);

this_X = this_NameTable.("Units Removed");
this_Y = this_NameTable.Accuracy;
if WantCI
this_Error = this_NameTable.("Error CI");
else
this_Error = this_NameTable.("Error STE");
end

this_WindowAccuracy = this_NameTable.("Window Accuracy");
% [~,this_WindowAccuracyMaxIDX] = max(this_WindowAccuracy,[],2);
% NumWindows = size(this_WindowAccuracy,2);
% this_Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
% this_Time = Time;

% this_WindowAccuracyMaxTime = this_Time(this_WindowAccuracyMaxIDX);
% this_WindowAccuracyMaxTime = this_WindowAccuracyMaxTime';

this_WindowAccuracyMaxTime = this_NameTable.("Peak Time");
if WantCI
this_WindowAccuracyMaxTime_Error = this_NameTable.("Peak Time CI");
else
this_WindowAccuracyMaxTime_Error = this_NameTable.("Peak Time STE");
end


% if ~any(isnan(SmoothWindow_Time))
% this_WindowAccuracyMaxTime = smoothdata(this_WindowAccuracyMaxTime,1,"gaussian",SmoothWindow_Time);
% end

if ~any(isnan(SmoothWindow))
this_Y = smoothdata(this_Y,1,"gaussian",SmoothWindow);
this_Error = smoothdata(this_Error,1,"gaussian",SmoothWindow);
end

Plot_X{nidx} = this_X;
Plot_Y{nidx} = this_Y;
Plot_Error{nidx} = this_Error;
PlotNames{nidx} = this_Name;

Plot_WindowAccuracy{nidx} = this_WindowAccuracy;
Plot_WindowAccuracyTime{nidx} = this_WindowAccuracyMaxTime;
Plot_WindowAccuracyTime_Error{nidx} = this_WindowAccuracyMaxTime_Error;

this_AreaRelativePlot_Y = this_NameTable.("Area Relative Percent");
this_AreaPlot_Y = this_NameTable.("Area Percent");

if ~any(isnan(SmoothWindow_Area))
this_AreaRelativePlot_Y = smoothdata(this_AreaRelativePlot_Y,1,"gaussian",SmoothWindow_Area);
this_AreaPlot_Y = smoothdata(this_AreaPlot_Y,1,"gaussian",SmoothWindow_Area);
end

for aidx = 1:NumAreas
    this_AreaName = SingleAreaPlotNames{aidx};
    % this_IDX = (nidx-1)*NumAreas + aidx;
    AreaRelativePlot_Y{aidx,nidx} = this_AreaRelativePlot_Y(:,aidx);
    AreaPlot_Y{aidx,nidx} = this_AreaPlot_Y(:,aidx);
    AreaPlot_X{aidx,nidx} = this_X;
    AreaPlot_Error{aidx,nidx} = NaN(size(this_X));
    AreaPlotNames{aidx,nidx} = sprintf('%s - %s',this_AreaName,this_Name);
    % AreaPlot_Y{this_IDX} = this_AreaPlot_Y(:,aidx);
    % AreaPlot_X{this_IDX} = this_X;
    % AreaPlot_Error{this_IDX} = NaN(size(this_X));
    % AreaPlotNames{this_IDX} = sprintf('%s - %s',this_AreaName,this_Name);
end


%%

this_PlotTitle = sprintf('%s Area Ranking',this_RemovalType);

[InFigure,~,~] = cgg_plotLinePlot(AreaPlot_X(:,nidx),AreaRelativePlot_Y(:,nidx),'ErrorMetric',AreaPlot_Error(:,nidx),'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name_AreaRelative,'PlotNames',SingleAreaPlotNames,'Legend_Size',Legend_Size,'PlotColors',PlotColors);

if ~any(isnan(YLimits_Area))
ylim(YLimits_Area);
end

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Area-Ranking_%s_%s',this_RemovalType,this_Name);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

%%

this_PlotTitle = sprintf('%s Area Ranking',this_RemovalType);

[InFigure,~,~] = cgg_plotLinePlot(AreaPlot_X(:,nidx),AreaPlot_Y(:,nidx),'ErrorMetric',AreaPlot_Error(:,nidx),'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name_Area,'PlotNames',SingleAreaPlotNames,'Legend_Size',Legend_Size,'PlotColors',PlotColors);

ylim([0,1]);

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Absolute-Area-Ranking_%s_%s',this_RemovalType,this_Name);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

%%

[InFigure,~,~] = cgg_plotHeatMapOverTime(Plot_WindowAccuracy{nidx},'Time_Start',Time_Start,'SamplingRate',SamplingRate,'DataWidth',DataWidth,'WindowStride',WindowStride,'Y_Name',X_Name,'Z_Name',Y_Name,'PlotTitle','Importance Analysis','ZLimits',YLimits,'Y_Ticks',NaN,'YRange',Plot_X{nidx},'Y_TickLabel',NaN,'Tick_Size_Time',Tick_Size_Time);

% hold on
% Plot_Z = ones(size(this_WindowAccuracyMaxTime));
% Plot_Z = Plot_Z*YLimits(2)*1.2;
% plot3(this_WindowAccuracyMaxTime',Plot_X{nidx},Plot_Z,'LineWidth',2,'Color','k');
% hold off

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Accuracy-Over-Time_%s_%s',this_RemovalType,this_Name);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all
end
%%

this_PlotTitle = sprintf('%s Importance Analysis',this_RemovalType);

[InFigure,~,~] = cgg_plotLinePlot(Plot_X,Plot_Y,'ErrorMetric',Plot_Error,'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name,'PlotNames',PlotNames,'Legend_Size',Legend_Size);
ylim(YLimits);

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Importance-Analysis_%s',this_RemovalType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

%%

this_PlotTitle = sprintf('%s Area Ranking',this_RemovalType);

AreaPlot_X = reshape(AreaPlot_X,[],1);
AreaRelativePlot_Y = reshape(AreaRelativePlot_Y,[],1);
AreaPlot_Y = reshape(AreaPlot_Y,[],1);
AreaPlot_Error = reshape(AreaPlot_Error,[],1);
AreaPlotNames = reshape(AreaPlotNames,[],1);

PlotColors_Multiple = cell(1,NumAreas*NumNames);
    LightenFactor = 0.25;
    for nidx = 1:NumNames
        for aidx = 1:NumAreas
        this_idx = NumAreas*(nidx-1) + aidx;
    this_Color = PlotColors{aidx};
    this_LightenedColor = this_Color*LightenFactor + (1-LightenFactor);
    if nidx == 1
        this_LightenedColor = this_Color;
    end
    PlotColors_Multiple{this_idx} = this_LightenedColor;
        end
    end

[InFigure,~,~] = cgg_plotLinePlot(AreaPlot_X,AreaRelativePlot_Y,'ErrorMetric',AreaPlot_Error,'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name_AreaRelative,'PlotNames',AreaPlotNames,'Legend_Size',Legend_Size,'PlotColors',PlotColors_Multiple);

if ~any(isnan(YLimits_Area))
ylim(YLimits_Area);
end

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Area-Ranking_%s',this_RemovalType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

%%

[InFigure,~,~] = cgg_plotLinePlot(AreaPlot_X,AreaPlot_Y,'ErrorMetric',AreaPlot_Error,'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name_Area,'PlotNames',AreaPlotNames,'Legend_Size',Legend_Size,'PlotColors',PlotColors_Multiple);

ylim([0,1]);

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Absolute-Area-Ranking_%s',this_RemovalType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

%%

this_PlotTitle = sprintf('%s Peak Accuracy Time',this_RemovalType);

[InFigure,~,~] = cgg_plotLinePlot(Plot_X,Plot_WindowAccuracyTime,'ErrorMetric',Plot_WindowAccuracyTime_Error,'PlotTitle',this_PlotTitle,'X_Name',X_Name,'Y_Name',Y_Name_Time,'PlotNames',PlotNames,'Legend_Size',Legend_Size);
if ~any(isnan(YLimits_Time))
ylim(YLimits_Time);
end

%%

cfg_Results = cgg_generateDecodingFolders('TargetDir',cfg.ResultsDir,...
    'Epoch',cfg.Epoch,'PlotFolder','Analysis','PlotSubFolder','Importance Analysis');
PlotPath = cgg_getDirectory(cfg_Results,'SubFolder_1');

PlotName=sprintf('Time-Peak_%s',this_RemovalType);
PlotPathName=[PlotPath filesep PlotName];
exportgraphics(InFigure,[PlotPathName, '.pdf'],'ContentType','vector');

close all

end





end

