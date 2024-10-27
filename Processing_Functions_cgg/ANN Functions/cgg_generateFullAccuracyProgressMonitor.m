classdef cgg_generateFullAccuracyProgressMonitor < handle
    %CGG_GENERATEFULLACCURACYPROGRESSMONITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        PlotTable
        Iteration
        SaveDir
        SaveTerm
        DataNames
        MatchType
        RunTerm
    end
    
    methods
        function [monitor,DataNames] = cgg_generateFullAccuracyProgressMonitor(varargin)
            %CGG_GENERATEFULLACCURACYPROGRESSMONITOR Construct an instance of this class
            %   Detailed explanation goes here
%% Get Variable Arguments
isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

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

if isfunction
Run = CheckVararginPairs('Run', 1, varargin{:});
else
if ~(exist('Run','var'))
Run=1;
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
Tile_Training = nexttile(Tiled_Plot,1);

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
Tile_Validation = nexttile(Tiled_Plot,2);

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
PlotTile = {Tile_Training,Tile_Validation};
PlotInitialized = {false,false};

PlotTable=table(PlotCell',{Time,Time}',PlotTile',PlotInitialized','VariableNames',...
    {'Plot','Time','Tile','Initialized'},'RowNames',PlotName');

%% Assign Properties
monitor.Iteration = 0;
monitor.PlotTable = PlotTable;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.MatchType = MatchType;
monitor.RunTerm = sprintf('_Run-%d',Run);

%%
DataNames = cell(0);

DataNames{1} = 'iteration';
DataNames{2} = 'WindowAccuracyTraining';
DataNames{3} = 'WindowAccuracyValidation';

monitor.DataNames = DataNames;
        end

        function initializePlot(monitor,PlotName,PlotUpdate)
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            this_Plot.YData=PlotUpdate{1};
            this_Plot.CData=PlotUpdate{2};
            monitor.PlotTable{PlotName,"Initialized"} = {true};
        end

        function updatePlot(monitor,PlotName,PlotUpdate)
            monitor.Iteration = PlotUpdate{1};
            this_Initialized = monitor.PlotTable{PlotName,"Initialized"};
            if iscell(this_Initialized)
                this_Initialized=this_Initialized{1};
            end
            if this_Initialized
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
            this_Tile = monitor.PlotTable{PlotName,"Tile"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            if iscell(this_Tile)
                this_Tile=this_Tile{1};
            end
            this_Plot.YData=[this_Plot.YData,monitor.Iteration];
            this_Plot.CData=[this_Plot.CData;diag(diag(PlotUpdate{2}))'];

            DataLimits = cgg_getPlotRangeFromData_v2(this_Plot.CData,0,100,NaN);
            % ylim("auto");
            
            if DataLimits(2) > 0
            DataLimits(1)=0;
            end
            % disp({DataLimits,any(isnan(DataLimits))});
            if DataLimits(1) < DataLimits(2) 
            this_Tile.CLim = DataLimits;
            end
            else
                initializePlot(monitor,PlotName,PlotUpdate)
            end
        end

        % function savePlot(monitor)
        %     iteration = monitor.Iteration;
        %     if iscell(iteration)
        %         iteration=iteration{1};
        %     end
        %     SavePathNameExt = [monitor.SaveDir filesep ...
        %         'Windowed-Accuracy' monitor.SaveTerm '_Iteration-' ...
        %         num2str(iteration) '.pdf'];
        %     saveas(monitor.Figure,SavePathNameExt);
        % end

        function savePlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Windowed-Accuracy' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm monitor.RunTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end

        function data = generateData(monitor,MonitorUpdate)
            NumData = length(monitor.DataNames);
            data = cell(1,NumData);
            for didx = 1:NumData
                this_DataName = monitor.DataNames{didx};
                data{didx} = MonitorUpdate.(this_DataName);
            end
        end

        function MonitorUpdate = calcMonitorUpdate(monitor,Monitor_Values)
            % LossInformation_Training = Monitor_Values.LossInformation_Training;
            % LossInformation_Validation = Monitor_Values.LossInformation_Validation;
            CM_Table_Training = Monitor_Values.CM_Table_Training;
            CM_Table_Validation = Monitor_Values.CM_Table_Validation;
            ClassNames = Monitor_Values.ClassNames;
            MonitorUpdate = struct();


            MonitorUpdate.iteration = Monitor_Values.iteration;

            FieldName_MostCommon_Training = ...
                sprintf('MostCommon_%s_Training',monitor.MatchType);
            FieldName_RandomChance_Training = ...
                sprintf('RandomChance_%s_Training',monitor.MatchType);
            RandomChance_Baseline_Training = ...
                Monitor_Values.(FieldName_RandomChance_Training);
            MostCommon_Baseline_Training = ...
                Monitor_Values.(FieldName_MostCommon_Training);
            FieldName_MostCommon_Validation = ...
                sprintf('MostCommon_%s_Validation',monitor.MatchType);
            FieldName_RandomChance_Validation = ...
                sprintf('RandomChance_%s_Validation',monitor.MatchType);
            RandomChance_Baseline_Validation = ...
                Monitor_Values.(FieldName_RandomChance_Validation);
            MostCommon_Baseline_Validation = ...
                Monitor_Values.(FieldName_MostCommon_Validation);

            HasTrainingCM_Table = istable(CM_Table_Training);

            if HasTrainingCM_Table
            [~,~,WindowAccuracyTraining] = ...
                cgg_procConfusionMatrixWindowsFromTable(...
                CM_Table_Training,ClassNames,...
                'MatchType',monitor.MatchType,...
                'IsQuaddle',Monitor_Values.IsQuaddle,...
                'RandomChance',RandomChance_Baseline_Training,...
                'MostCommon',MostCommon_Baseline_Training);
            else
                WindowAccuracyTraining = NaN;
            end

            MonitorUpdate.WindowAccuracyTraining = WindowAccuracyTraining;
            MonitorUpdate.WindowAccuracyValidation = NaN;

            HasValidationCM_Table = istable(CM_Table_Validation);

            if HasValidationCM_Table
            [~,~,WindowAccuracyValidation] = ...
                cgg_procConfusionMatrixWindowsFromTable(...
                CM_Table_Validation,ClassNames,...
                'MatchType',monitor.MatchType,...
                'IsQuaddle',Monitor_Values.IsQuaddle,...
                'RandomChance',RandomChance_Baseline_Validation,...
                'MostCommon',MostCommon_Baseline_Validation);
            MonitorUpdate.WindowAccuracyValidation = ...
                WindowAccuracyValidation;
            end


        end

    end
end

