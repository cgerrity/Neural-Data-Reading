classdef cgg_generateFullAccuracyProgressMonitor < handle
    %CGG_GENERATEFULLACCURACYPROGRESSMONITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        PlotTable
        Iteration
        SaveDir
        SaveTerm
    end
    
    methods
        function monitor = cgg_generateFullAccuracyProgressMonitor(varargin)
            %CGG_GENERATEFULLACCURACYPROGRESSMONITOR Construct an instance of this class
            %   Detailed explanation goes here
%% Get Variable Arguments
isfunction=exist('varargin','var');

if isfunction
SaveDir = CheckVararginPairs('SaveDir', pwd, varargin{:});
else
if ~(exist('SaveDir','var'))
SaveDir=pwd;
end
end

if isfunction
SaveTerm = CheckVararginPairs('SaveTerm', '', varargin{:});
else
if ~(exist('SaveTerm','var'))
SaveTerm='';
end
end

if isfunction
Time_Start = CheckVararginPairs('Time_Start', -1.5, varargin{:});
else
if ~(exist('Time_Start','var'))
Time_Start=-1.5;
end
end

if isfunction
Time_End = CheckVararginPairs('Time_End', '', varargin{:});
else
if ~(exist('Time_End','var'))
Time_End='';
end
end

if isfunction
SamplingRate = CheckVararginPairs('SamplingRate', 1000, varargin{:});
else
if ~(exist('SamplingRate','var'))
SamplingRate=1000;
end
end

if isfunction
DataWidth = CheckVararginPairs('DataWidth', 100/SamplingRate, varargin{:});
else
if ~(exist('DataWidth','var'))
DataWidth=100/SamplingRate;
end
end

if isfunction
WindowStride = CheckVararginPairs('WindowStride', 50/SamplingRate, varargin{:});
else
if ~(exist('WindowStride','var'))
WindowStride=50/SamplingRate;
end
end

if isfunction
NumWindows = CheckVararginPairs('NumWindows', 59, varargin{:});
else
if ~(exist('NumWindows','var'))
NumWindows=59;
end
end

if isfunction
Z_Name = CheckVararginPairs('Z_Name', '', varargin{:});
else
if ~(exist('Z_Name','var'))
Z_Name='';
end
end

if isfunction
ZLimits = CheckVararginPairs('ZLimits', [0,1], varargin{:});
else
if ~(exist('ZLimits','var'))
ZLimits=[0,1];
end
end

%% Get Time 

if isempty(Time_End)
    Time_Start_Adjusted = Time_Start+DataWidth/2;
    Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
    % Time_End = Time(end)+DataWidth/2;
else
    Time = linspace(Time_Start,Time_End,NumWindows);
end

%% Generate Figure

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
InFigure.Visible='off';
monitor.Figure=InFigure;

%% Get Plot Parameters

cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;

X_Name_Size = cfg_Plot.X_Name_Size;
Y_Name_Size = cfg_Plot.Y_Name_Size;
Label_Size = cfg_Plot.Label_Size;

if ~isempty(SaveTerm)
SaveTerm = ['_' SaveTerm];
end

%% Generate Plot

Tiled_Plot=tiledlayout(2,1,"TileSpacing","tight");


%% Training Plot
nexttile(Tiled_Plot,1);

p_Accuracy_Training=imagesc(Time,1,rand(1,NumWindows));

xlabel('Time (s)','FontSize',X_Name_Size);
ylabel('Iteration','FontSize',Y_Name_Size);
InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
ylim("auto");

InFigure.CurrentAxes.YDir='normal';
InFigure.CurrentAxes.XDir='normal';
InFigure.CurrentAxes.XAxis.TickLength=[0,0];
InFigure.CurrentAxes.YAxis.TickLength=[0,0];
% view(2);

c_Plot_Training=colorbar('vert');
c_Plot_Training.Label.String = Z_Name;
c_Plot_Training.Label.FontSize = Y_Name_Size;

% xlim([Time_Start,Time_End]);

if ~isempty(ZLimits)
clim([ZLimits(1),ZLimits(2)]);
end

%% Validation Plot
nexttile(Tiled_Plot,2);

p_Accuracy_Validation=imagesc(Time,1,rand(1,NumWindows));

xlabel('Time (s)','FontSize',X_Name_Size);
ylabel('Iteration','FontSize',Y_Name_Size);
InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
ylim("auto");

InFigure.CurrentAxes.YDir='normal';
InFigure.CurrentAxes.XDir='normal';
InFigure.CurrentAxes.XAxis.TickLength=[0,0];
InFigure.CurrentAxes.YAxis.TickLength=[0,0];
view(2);

c_Plot_Validation=colorbar('vert');
c_Plot_Validation.Label.String = Z_Name;
c_Plot_Validation.Label.FontSize = Y_Name_Size;

% xlim([Time_Start,Time_End]);

if ~isempty(ZLimits)
clim([ZLimits(1),ZLimits(2)]);
end

%% Plot Saving
PlotCell={p_Accuracy_Training,p_Accuracy_Validation};
PlotName={'AccuracyTraining','AccuracyValidation'};

PlotTable=table(PlotCell',{Time,Time}','VariableNames',...
    {'Plot','Time'},'RowNames',PlotName');

%% Assign Properties
monitor.Iteration = 0;
monitor.PlotTable = PlotTable;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
        end

        function initializePlot(monitor,PlotName,PlotUpdate)
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            this_Plot.YData=PlotUpdate{1};
            this_Plot.CData=PlotUpdate{2};
        end

        function updatePlot(monitor,PlotName,PlotUpdate)
            monitor.Iteration = PlotUpdate{1};
            if monitor.Iteration > 1
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
                if iscell(this_Plot)
                    this_Plot=this_Plot{1};
                end 
            this_Plot.YData=[this_Plot.YData,PlotUpdate{1}];
            this_Plot.CData=[this_Plot.CData;diag(diag(PlotUpdate{2}))'];
            ylim("auto");
            else
                initializePlot(monitor,PlotName,PlotUpdate)
            end
        end

        function savePlot(monitor)
            iteration = monitor.Iteration;
            if iscell(iteration)
                iteration=iteration{1};
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Windowed-Accuracy' monitor.SaveTerm '_Iteration-' ...
                num2str(iteration) '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end

    end
end

