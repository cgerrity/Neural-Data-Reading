classdef cgg_generateFullReconstructionAndClassificationMonitor < handle
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
        Time_Frames
        HeightReconstruction
        HeightClassification
        NumDimensions
        RangeReconstruction
        SaveDir
        SaveTerm
        ExampleNumber
        ExampleTerm
    end
    
    methods
        function monitor = cgg_generateFullReconstructionAndClassificationMonitor(varargin)
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
RangeReconstruction = CheckVararginPairs('RangeReconstruction', [-4,4], varargin{:});
else
if ~(exist('RangeReconstruction','var'))
RangeReconstruction=[-4,4];
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

Time_Window = Time;

this_Time_Start = Time_Start;
this_Time_End = this_Time_Start+DataWidth;
this_Time = Time_Start:1/SamplingRate:this_Time_End;
this_Time(end) = [];

Time_Frames = cell(1,NumWindows);
Time_Frames{1} = this_Time;

for widx = 2:NumWindows
this_Time = this_Time+WindowStride;
Time_Frames{widx} = this_Time;
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
% Y_Name_Size = cfg_Plot.Y_Name_Size;
% Label_Size = cfg_Plot.Label_Size;

Line_Width_ProgressMonitor = 1;

%% Generate Plot

NumExamples = 2;
HeightReconstructionRatio = 0.5;
HeightClassification = 1;

% HeightReconstruction = HeightClassification*NumDimensions*(HeightReconstructionRatio/(1-HeightReconstructionRatio));
HeightReconstruction = 1;

% RowsTotal = (HeightClassification*NumDimensions+HeightReconstruction)*2;
% RowsTotal = (HeightClassification*NumDimensions+HeightReconstruction);
RowsTotal = (HeightClassification+HeightReconstruction);
ColumnsTotal = NumExamples;

Tiled_Plot=tiledlayout(RowsTotal,ColumnsTotal,"TileSpacing","tight","Padding","compact");

%% Training Reconstruction

this_ExampleIDX = 1;
this_Row = 1;

this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
nexttile(Tiled_Plot,this_TileIDX,[HeightReconstruction,1]);

p_GroundTruthTraining=plot(Time,randn(size(Time)),'DisplayName','Ground Truth','LineWidth',Line_Width_ProgressMonitor);
p_ReconstructionTraining=plot(Time,randn(size(Time)),'DisplayName','Reconstruction','LineWidth',Line_Width_ProgressMonitor);

xlabel('Time (s)','FontSize',X_Name_Size);


TileIDX_ReconstructionTraining = this_TileIDX;

%% Training Classification

PlotData = cell(1,NumDimensions);
for didx = 1:NumDimensions
    PlotData{didx} = randn(size(Time));
end

InSpan = [HeightClassification,1];
InTiledIDX=tilenum(Tiled_Plot,2,1);

[DimensionPlotsTraining,TileIDX_DimensionTraining_Within,Tiled_Plot_Training] = cgg_plotClassificationProbabilities(PlotData,Time,Tiled_Plot,InTiledIDX,InSpan);

TileIDX_DimensionTraining = InTiledIDX;

% DimensionPlotsTraining = cell(1,NumDimensions);
% TileIDX_DimensionTraining = cell(1,NumDimensions);
% 
% this_TileIDX=tilenum(Tiled_Plot,2,1);
% this_TileIDX
% % nexttile(Tiled_Plot,this_TileIDX,[HeightReconstruction,1]);
% nexttile(Tiled_Plot,this_TileIDX,[HeightClassification,1]);
% Tiled_Plot_Dimension=tiledlayout(Tiled_Plot,4,1,"TileSpacing","none","Padding","tight");

% for didx = 1:NumDimensions
%     this_ExampleIDX = 1;
% % this_Row = HeightReconstruction+didx;
% this_Row = didx;
% 
% % this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
% this_TileIDX=tilenum(Tiled_Plot_Dimension,this_Row,this_ExampleIDX);
% nexttile(Tiled_Plot_Dimension,this_TileIDX,[HeightClassification,1]);
% 
% p_DimensionTraining=plot(Time,randn(size(Time)),'DisplayName',sprintf('Dimension %d',didx),'LineWidth',Line_Width_ProgressMonitor);
% 
% ylim([0,1]);
% 
% DimensionPlotsTraining{didx} = p_DimensionTraining;
% 
% TileIDX_DimensionTraining{didx} = this_TileIDX;
% end

%% Validation

this_ExampleIDX = 2;
this_Row = 1;

this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
nexttile(Tiled_Plot,this_TileIDX,[HeightReconstruction,1]);

p_GroundTruthValidation =plot(Time,randn(size(Time)),'DisplayName','Ground Truth','LineWidth',Line_Width_ProgressMonitor);
p_ReconstructionValidation=plot(Time,randn(size(Time)),'DisplayName','Reconstruction','LineWidth',Line_Width_ProgressMonitor);

xlabel('Time (s)','FontSize',X_Name_Size);

TileIDX_ReconstructionValidation = this_TileIDX;

%% Validation

PlotData = cell(1,NumDimensions);
for didx = 1:NumDimensions
    PlotData{didx} = randn(size(Time));
end

InSpan = [HeightClassification,1];
InTiledIDX=tilenum(Tiled_Plot,2,this_ExampleIDX);

[DimensionPlotsValidation,TileIDX_DimensionValidation_Within,Tiled_Plot_Validation] = cgg_plotClassificationProbabilities(PlotData,Time,Tiled_Plot,InTiledIDX,InSpan);

TileIDX_DimensionValidation = InTiledIDX;

% 
% DimensionPlotsValidation = cell(1,NumDimensions);
% TileIDX_DimensionValidation = cell(1,NumDimensions);
% 
% for didx = 1:NumDimensions
%     this_ExampleIDX = 2;
% % this_Row = 2*HeightReconstruction+didx+HeightClassification*NumDimensions;
% this_Row = HeightReconstruction+didx;
% 
% this_TileIDX=tilenum(Tiled_Plot,this_Row,this_ExampleIDX);
% nexttile(this_TileIDX,[HeightClassification,1]);
% 
% p_DimensionValidation=plot(Time,randn(size(Time)),'DisplayName',sprintf('Dimension %d',didx),'LineWidth',Line_Width_ProgressMonitor);
% 
% ylim([0,1]);
% 
% DimensionPlotsValidation{didx} = p_DimensionValidation;
% 
% TileIDX_DimensionValidation{didx} = this_TileIDX;
% end

%% Plot Saving
PlotCell={p_GroundTruthTraining,p_ReconstructionTraining,DimensionPlotsTraining,p_GroundTruthValidation,p_ReconstructionValidation,DimensionPlotsValidation};
PlotName={'GroundTruthTraining','ReconstructionTraining','DimensionTraining','GroundTruthValidation','ReconstructionValidation','DimensionValidation'};

TileIDXCell={TileIDX_ReconstructionTraining,TileIDX_DimensionTraining,TileIDX_ReconstructionValidation,TileIDX_DimensionValidation};
TileIDX_WithinCell={[],TileIDX_DimensionTraining_Within,[],TileIDX_DimensionValidation_Within};
Tile_PlotsCell={[],Tiled_Plot_Training,[],Tiled_Plot_Validation};
TileName={'ReconstructionTraining','DimensionTraining','ReconstructionValidation','DimensionValidation'};


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
monitor.Time_Frames = Time_Frames;
monitor.HeightReconstruction = HeightReconstruction;
monitor.HeightClassification = HeightClassification;
monitor.SamplingRate = SamplingRate;
monitor.Tiled_Plot = Tiled_Plot;
monitor.NumDimensions = NumDimensions;
monitor.RangeReconstruction = RangeReconstruction;
monitor.ExampleNumber = 1;
monitor.ExampleTerm = ['_Example-' num2str(monitor.ExampleNumber)];

        end

        function value = isClassification(~,PlotName)
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
            if isClassification(monitor,PlotName)
                TileIDX_Within=TileIDX_Within{DimensionIDX};
            end
        end

        function Time = getTime(monitor,PlotName)
            if isClassification(monitor,PlotName)
                Time = monitor.Time_Window;
            else
                Time = monitor.Time_Frames;
            end
        end

        function Height = getHeight(monitor,PlotName)
            if isClassification(monitor,PlotName)
                Height = monitor.HeightClassification;
            else
                Height = monitor.HeightReconstruction;
            end
        end
        
        function updatePlotReconstruction(monitor,PlotName,PlotUpdate)

            cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;
            X_Name_Size = cfg_Plot.X_Name_Size;
            Line_Width_ProgressMonitor = 1;

            Height = getHeight(monitor,PlotName);

            [Data_GroundTruth,Time_GroundTruth] = getDataAndTime(monitor,PlotUpdate.GroundTruth);
            [Data_Reconstruction,Time_Reconstruction] = getDataAndTime(monitor,PlotUpdate.Reconstruction);
            TileIDX = getTileIDX(monitor,PlotName,0);
            InTiled_Plot = monitor.Tiled_Plot;
            nexttile(InTiled_Plot,TileIDX,[Height,1]);

            plot(Time_GroundTruth,Data_GroundTruth,'DisplayName','Ground Truth','LineWidth',Line_Width_ProgressMonitor);
            hold on
            plot(Time_Reconstruction,Data_Reconstruction,'DisplayName','Reconstruction','LineWidth',Line_Width_ProgressMonitor);
            hold off

            xlabel('Time (s)','FontSize',X_Name_Size);
            ylim(monitor.RangeReconstruction);

        end

        function updatePlotSingleClassification(monitor,PlotName,PlotUpdate,DimensionIDX)
            Line_Width_ProgressMonitor = 1;
            
            [TileIDX,TileIDX_Within] = getTileIDX(monitor,PlotName,DimensionIDX);
            Time = getTime(monitor,PlotName);
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
            ylim([0,1]);

            % nexttile(TileIDX,[Height,1]);
            % 
            % NumClasses = height(PlotUpdate);
            % 
            % this_Data = PlotUpdate{1,"Data"};
            % this_Name = PlotUpdate{1,"Name"};
            % if iscell(this_Data)
            %     this_Data = this_Data{1};
            % end
            % if iscell(this_Name)
            %     this_Name = this_Name{1};
            % end
            % 
            % plot(Time,this_Data,'DisplayName',this_Name,'LineWidth',Line_Width_ProgressMonitor);
            % 
            % hold on
            % for cidx = 2:NumClasses
            %     this_Data = PlotUpdate{cidx,"Data"};
            %     this_Name = PlotUpdate{cidx,"Name"};
            %     if iscell(this_Data)
            %         this_Data = this_Data{1};
            %     end
            %     if iscell(this_Name)
            %         this_Name = this_Name{1};
            %     end
            % 
            %     plot(Time,this_Data,'DisplayName',this_Name,'LineWidth',Line_Width_ProgressMonitor);
            % end
            % hold off
            % 
            % this_legend = legend;
            % this_legend.Location = "best";
        end

        function updateIteration(monitor,iteration)
            PriorIteration = monitor.Iteration;
            monitor.Iteration = iteration;
            if PriorIteration ~= iteration
                monitor.ExampleNumber = 1;
                updateExampleTerm(monitor);
            end
        end

        function updateExampleTerm(monitor)
            monitor.ExampleTerm = ['_Example-' num2str(monitor.ExampleNumber)];
            monitor.ExampleNumber = monitor.ExampleNumber+1;
        end

        function updatePlotTitle(monitor,InTitle)
            title(monitor.Tiled_Plot,InTitle);
        end

        function savePlot(monitor)
            iteration = monitor.Iteration;
            if iscell(iteration)
                iteration=iteration{1};
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Reconstruction-Monitor_Iteration-' num2str(iteration) ...
                monitor.SaveTerm monitor.ExampleTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
            updateExampleTerm(monitor);
        end

    end
end

