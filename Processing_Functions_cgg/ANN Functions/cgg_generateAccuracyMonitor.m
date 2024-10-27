classdef cgg_generateAccuracyMonitor < handle
    %CGG_GENERATEFULLRECONSTRUCTIONANDCLASSIFICATIONMONITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        PlotTable
        TileTable
        Tiled_Plot
        Iteration
        SamplingRate
        Time_Window
        HeightFull
        HeightSingleDimension
        NumDimensions
        RangeAccuracy
        SaveDir
        SaveTerm
    end
    
    methods
        function monitor = cgg_generateAccuracyMonitor(varargin)
            %CGG_GENERATEFULLRECONSTRUCTIONANDCLASSIFICATION Construct an instance of this class
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
NumDimensions = CheckVararginPairs('NumDimensions', 4, varargin{:});
else
if ~(exist('NumDimensions','var'))
NumDimensions=4;
end
end

if isfunction
RangeAccuracy = CheckVararginPairs('RangeAccuracy', [0,1], varargin{:});
else
if ~(exist('RangeAccuracy','var'))
RangeAccuracy=[0,1];
end
end

%% Get Time 

if isempty(Time_End)
    Time_Start_Adjusted = Time_Start+DataWidth/2;
    Time = Time_Start_Adjusted+((1:NumWindows)-1)*WindowStride;
else
    Time = linspace(Time_Start,Time_End,NumWindows);
end

Time_Window = Time;

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

Line_Width_ProgressMonitor = 1;

%% Generate Plot

NumExamples = 2;
HeightSingleDimension = 1;

HeightFull = 1;

RowsTotal = (HeightSingleDimension+HeightFull);
ColumnsTotal = NumExamples;

Tiled_Plot=tiledlayout(RowsTotal,ColumnsTotal,"TileSpacing","tight","Padding","compact");

%% Training Full Accuracy

this_ExampleIDX = 1;
this_Row = 1;

this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
nexttile(Tiled_Plot,this_TileIDX,[HeightFull,1]);

p_FullAccuracyTraining=plot(Time,randn(size(Time)),'DisplayName','Full Accuracy','LineWidth',Line_Width_ProgressMonitor);

xlabel('Time (s)','FontSize',X_Name_Size);

TileIDX_FullAccuracyTraining = this_TileIDX;

%% Training Single Dimension Accuracy

PlotData = cell(1,NumDimensions);
for didx = 1:NumDimensions
    PlotData{didx} = randn(size(Time));
end

InSpan = [HeightSingleDimension,1];
InTiledIDX=tilenum(Tiled_Plot,2,1);

[DimensionPlotsTraining,TileIDX_DimensionTraining_Within,Tiled_Plot_Training] = cgg_plotClassificationProbabilities(PlotData,Time,Tiled_Plot,InTiledIDX,InSpan);

TileIDX_DimensionTraining = InTiledIDX;

%% Validation Full Accuracy

this_ExampleIDX = 2;
this_Row = 1;

this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
nexttile(Tiled_Plot,this_TileIDX,[HeightFull,1]);

p_FullAccuracyValidation =plot(Time,randn(size(Time)),'DisplayName','Full Accuracy','LineWidth',Line_Width_ProgressMonitor);

xlabel('Time (s)','FontSize',X_Name_Size);

TileIDX_FullAccuracyValidation = this_TileIDX;

%% Validation Single Dimension Accuracy

PlotData = cell(1,NumDimensions);
for didx = 1:NumDimensions
    PlotData{didx} = randn(size(Time));
end

InSpan = [HeightSingleDimension,1];
InTiledIDX=tilenum(Tiled_Plot,2,this_ExampleIDX);

[DimensionPlotsValidation,TileIDX_DimensionValidation_Within,Tiled_Plot_Validation] = cgg_plotClassificationProbabilities(PlotData,Time,Tiled_Plot,InTiledIDX,InSpan);

TileIDX_DimensionValidation = InTiledIDX;

%% Plot Saving
PlotCell={p_FullAccuracyTraining,DimensionPlotsTraining,p_FullAccuracyValidation,DimensionPlotsValidation};
PlotName={'FullAccuracyTraining','DimensionTraining','FullAccuracyValidation','DimensionValidation'};

TileIDXCell={TileIDX_FullAccuracyTraining,TileIDX_DimensionTraining,TileIDX_FullAccuracyValidation,TileIDX_DimensionValidation};
TileIDX_WithinCell={[],TileIDX_DimensionTraining_Within,[],TileIDX_DimensionValidation_Within};
Tile_PlotsCell={[],Tiled_Plot_Training,[],Tiled_Plot_Validation};
TileName={'FullAccuracyTraining','DimensionTraining','FullAccuracyValidation','DimensionValidation'};


PlotTable=table(PlotCell','VariableNames',...
    {'Plot'},'RowNames',PlotName');

TileTable=table(TileIDXCell',TileIDX_WithinCell',Tile_PlotsCell','VariableNames',...
    {'TileIDX','TileIDX_Within','Tile_Plots'},'RowNames',TileName');

%% Assign Properties
monitor.Iteration = 0;
monitor.PlotTable = PlotTable;
monitor.TileTable = TileTable;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.Time_Window = Time_Window;
monitor.HeightFull = HeightFull;
monitor.HeightSingleDimension = HeightSingleDimension;
monitor.SamplingRate = SamplingRate;
monitor.Tiled_Plot = Tiled_Plot;
monitor.NumDimensions = NumDimensions;
monitor.RangeAccuracy = RangeAccuracy;

        end

        function value = isDimension(~,PlotName)
            value = false;
            if contains(PlotName,"Dimension")
                value = true;
            end
        end

        function [Data,Time] = getDataAndTime(monitor,PlotUpdate)
            [Data, Time] = cgg_alignData(PlotUpdate, monitor.Time_Frames, monitor.SamplingRate);
            Data = mean(Data,1,"omitnan");
        end

        function [TileIDX,TileIDX_Within] = getTileIDX(monitor,PlotName,DimensionIDX)
            TileIDX = monitor.TileTable{PlotName,"TileIDX"};
            if iscell(TileIDX)
                TileIDX=TileIDX{1};
            end
            TileIDX_Within = monitor.TileTable{PlotName,"TileIDX_Within"};
            if iscell(TileIDX_Within)
                TileIDX_Within=TileIDX_Within{1};
            end
            if isDimension(monitor,PlotName)
                TileIDX_Within=TileIDX_Within{DimensionIDX};
            end
        end

        function Height = getHeight(monitor,PlotName)
            if isDimension(monitor,PlotName)
                Height = monitor.HeightSingleDimension;
            else
                Height = monitor.HeightFull;
            end
        end
        
        function updatePlotReconstruction(monitor,PlotName,PlotUpdate)

            cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;
            X_Name_Size = cfg_Plot.X_Name_Size;
            Line_Width_ProgressMonitor = 1;

            Height = getHeight(monitor,PlotName);

            Time = monitor.Time_Window;
            Data = PlotUpdate.FullAccuracy;
            
            TileIDX = getTileIDX(monitor,PlotName,0);
            InTiled_Plot = monitor.Tiled_Plot;
            nexttile(InTiled_Plot,TileIDX,[Height,1]);

            plot(Time,Data,'DisplayName','Full Accuracy','LineWidth',Line_Width_ProgressMonitor);

            xlabel('Time (s)','FontSize',X_Name_Size);
            ylim(monitor.RangeAccuracy);

        end

        function updatePlotSingleClassification(monitor,PlotName,PlotUpdate,DimensionIDX)
            Line_Width_ProgressMonitor = 1;
            
            [TileIDX,TileIDX_Within] = getTileIDX(monitor,PlotName,DimensionIDX);
            Time = monitor.Time_Window;
            Height = getHeight(monitor,PlotName);

            InTiled_Plot = monitor.Tiled_Plot;

            SubTiled_Plot = monitor.TileTable{PlotName,"Tile_Plots"};
            if iscell(SubTiled_Plot)
                SubTiled_Plot=SubTiled_Plot{1};
            end
            
            LastDim = false;
            if DimensionIDX == monitor.NumDimensions
                LastDim = true;
            end

            ClassPlots = cgg_plotSingleClassificationProbability(PlotUpdate,Time,InTiled_Plot,SubTiled_Plot,TileIDX,TileIDX_Within,[1,1],LastDim);
            ylim(monitor.RangeAccuracy);
        end

        function updateSaveTerm(monitor,InSaveTerm)
            title(monitor.SaveTerm,InSaveTerm);
        end

        function savePlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Accuracy-Monitor_Iteration-' ...
                InSaveTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end

    end
end

