classdef cgg_generateGradientMonitor < handle
    %CGG_GENERATEGRADIENTMONITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        NumWeights
        Iteration
        Tiled_Plot
        SaveDir
        SaveTerm
        PlotPercentile
        RecencyAmount
        OutlierWindow
        OutlierThreshold
        RangeFactor
        DataNames
        GradientValuesNames
        MeanGradient
        STDGradient
        MeanThresholdGradient
        STDThresholdGradient
        RunTerm
        X_Iteration
    end
    
    methods
        function [monitor,DataNames] = cgg_generateGradientMonitor(varargin)
            %CGG_GENERATEGRADIENTMONITOR Construct an instance of this class
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
PlotPercentile = CheckVararginPairs('PlotPercentile', 99, varargin{:});
else
if ~(exist('PlotPercentile','var'))
PlotPercentile=99;
end
end

if isfunction
RecencyAmount = CheckVararginPairs('RecencyAmount', 50, varargin{:});
else
if ~(exist('RecencyAmount','var'))
RecencyAmount=50;
end
end

if isfunction
OutlierWindow = CheckVararginPairs('OutlierWindow', 50, varargin{:});
else
if ~(exist('OutlierWindow','var'))
OutlierWindow=50;
end
end

if isfunction
OutlierWindow = CheckVararginPairs('OutlierWindow', 50, varargin{:});
else
if ~(exist('OutlierWindow','var'))
OutlierWindow=50;
end
end

if isfunction
OutlierThreshold = CheckVararginPairs('OutlierThreshold', 100, varargin{:});
else
if ~(exist('OutlierThreshold','var'))
OutlierThreshold=100;
end
end

if isfunction
RangeFactor = CheckVararginPairs('RangeFactor', 0.07, varargin{:});
else
if ~(exist('RangeFactor','var'))
RangeFactor=0.07;
end
end

if isfunction
Run = CheckVararginPairs('Run', 1, varargin{:});
else
if ~(exist('Run','var'))
Run=1;
end
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

%%

Tiled_Plot=tiledlayout(InFigure,2,2,"TileSpacing","tight","Padding","compact");

% Tile_Structure = struct;
% 
% % Mean Gradient
% Tile_Structure.MeanGradient = nexttile(monitor.Tiled_Plot,1,[1,1]);
% % Mean Threshold Gradient
% Tile_Structure.MeanThresholdGradient = nexttile(monitor.Tiled_Plot,2,[1,1]);
% % STD Gradient
% Tile_Structure.STDGradient = nexttile(monitor.Tiled_Plot,3,[1,1]);
% % STD Threshold Gradient
% Tile_Structure.STDThresholdGradient = nexttile(monitor.Tiled_Plot,4,[1,1]);

%% Assign Properties
monitor.Iteration = 0;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.Tiled_Plot = Tiled_Plot;
% monitor.Tile_Structure = Tile_Structure;
monitor.NumWeights = 0;
monitor.PlotPercentile = PlotPercentile;
monitor.RecencyAmount = RecencyAmount;
monitor.OutlierWindow = OutlierWindow;
monitor.OutlierThreshold = OutlierThreshold;
monitor.RangeFactor = RangeFactor;
monitor.GradientValuesNames = [];
monitor.MeanGradient = [];
monitor.STDGradient = [];
monitor.MeanThresholdGradient = [];
monitor.STDThresholdGradient = [];
monitor.X_Iteration = [];
monitor.RunTerm = sprintf('_Run-%d',Run);

%%

DataNames = cell(0);

DataNames{1} = 'GradientValuesNames';
DataNames{2} = 'MeanGradient';
DataNames{3} = 'STDGradient';
DataNames{4} = 'MeanThresholdGradient';
DataNames{5} = 'STDThresholdGradient';

monitor.DataNames = DataNames;
        end
        
        function updatePlot(monitor,GradientValuesNames,MeanGradient,STDGradient,MeanThresholdGradient,STDThresholdGradient)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            [~,this_NumWeights] = size(MeanGradient);
            monitor.NumWeights = this_NumWeights;

            if this_NumWeights > 7
            PlotColors = jet(this_NumWeights);
            else
                PlotColors = [0 0.4470 0.7410; ...
                    0.8500 0.3250 0.0980; ...
                    0.9290 0.6940 0.1250; ...
                    0.4940 0.1840 0.5560; ...
                    0.4660 0.6740 0.1880; ...
                    0.3010 0.7450 0.9330; ...
                    0.6350 0.0780 0.1840];
            end
            
            % Mean Gradient
            this_Tile = nexttile(monitor.Tiled_Plot,1,[1,1]);

            this_PlotValue = MeanGradient(:,1);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:this_NumWeights
                this_PlotValue = MeanGradient(:,widx);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if this_NumWeights < 10
            Legend_MeanGradient = legend;
            Legend_MeanGradient.Location = "best";
            Legend_MeanGradient.FontSize = 6;
            end
            title('Mean Gradient');

            % DataLimits = cgg_getPlotRangeFromData(MeanGradient,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            DataLimits = cgg_getPlotRangeFromData_v2(MeanGradient,monitor.RangeFactor,monitor.PlotPercentile,NaN);
            this_Tile.YLim = DataLimits;

            % Mean Threshold Gradient
            this_Tile = nexttile(monitor.Tiled_Plot,2,[1,1]);

            this_PlotValue = MeanThresholdGradient(:,1);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:this_NumWeights
                this_PlotValue = MeanThresholdGradient(:,widx);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if this_NumWeights < 10
            Legend_MeanThresholdGradient = legend;
            Legend_MeanThresholdGradient.Location = "best";
            Legend_MeanThresholdGradient.FontSize = 6;
            end
            title('Mean Threshold Gradient');

            % DataLimits = cgg_getPlotRangeFromData(MeanThresholdGradient,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            DataLimits = cgg_getPlotRangeFromData_v2(MeanThresholdGradient,monitor.RangeFactor,monitor.PlotPercentile,NaN);
            this_Tile.YLim = DataLimits;

            % STD Gradient
            this_Tile = nexttile(monitor.Tiled_Plot,3,[1,1]);

            this_PlotValue = STDGradient(:,1);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:this_NumWeights
                this_PlotValue = STDGradient(:,widx);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if this_NumWeights < 10
            Legend_STDGradient = legend;
            Legend_STDGradient.Location = "best";
            Legend_STDGradient.FontSize = 6;
            end
            title('Standard Deviation Gradient');

            % DataLimits = cgg_getPlotRangeFromData(STDGradient,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            DataLimits = cgg_getPlotRangeFromData_v2(STDGradient,monitor.RangeFactor,monitor.PlotPercentile,NaN);
            this_Tile.YLim = DataLimits;

            % STD Threshold Gradient
            this_Tile = nexttile(monitor.Tiled_Plot,4,[1,1]);

            this_PlotValue = STDThresholdGradient(:,1);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:this_NumWeights
                this_PlotValue = STDThresholdGradient(:,widx);
            plot(monitor.X_Iteration,this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if this_NumWeights < 10
            Legend_STDThresholdGradient = legend;
            Legend_STDThresholdGradient.Location = "best";
            Legend_STDThresholdGradient.FontSize = 6;
            end
            title('Standard Deviation Threshold Gradient');

            % DataLimits = cgg_getPlotRangeFromData(STDThresholdGradient,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            DataLimits = cgg_getPlotRangeFromData_v2(STDThresholdGradient,monitor.RangeFactor,monitor.PlotPercentile,NaN);
            this_Tile.YLim = DataLimits;

            % monitor.Iteration = NumX;
        end

        function updateZoom(monitor,IsRecent)
        
            this_RecencyAmount = NaN;
            if IsRecent
                this_RecencyAmount = monitor.RecencyAmount;
            end

        % Mean Gradient
        this_Tile = nexttile(monitor.Tiled_Plot,1,[1,1]);
        DataLimits = cgg_getPlotRangeFromData_v2(monitor.MeanGradient,monitor.RangeFactor,monitor.PlotPercentile,this_RecencyAmount);
        this_Tile.YLim = DataLimits;
        % Mean Threshold Gradient
        this_Tile = nexttile(monitor.Tiled_Plot,2,[1,1]);
        DataLimits = cgg_getPlotRangeFromData_v2(monitor.MeanThresholdGradient,monitor.RangeFactor,monitor.PlotPercentile,this_RecencyAmount);
        this_Tile.YLim = DataLimits;
        % STD Gradient
        this_Tile = nexttile(monitor.Tiled_Plot,3,[1,1]);
        DataLimits = cgg_getPlotRangeFromData_v2(monitor.STDGradient,monitor.RangeFactor,monitor.PlotPercentile,this_RecencyAmount);
        this_Tile.YLim = DataLimits;
        % STD Threshold Gradient
        this_Tile = nexttile(monitor.Tiled_Plot,4,[1,1]);
        DataLimits = cgg_getPlotRangeFromData_v2(monitor.STDThresholdGradient,monitor.RangeFactor,monitor.PlotPercentile,this_RecencyAmount);
        this_Tile.YLim = DataLimits;
           drawnow;
        end

        function savePlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Gradient-Monitor' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm monitor.RunTerm '.pdf'];
            updateZoom(monitor,false);
            saveas(monitor.Figure,SavePathNameExt);
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Gradient-Monitor-(Zoom)' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm monitor.RunTerm '.pdf'];
            updateZoom(monitor,true);
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
            % CM_Table_Training = Monitor_Values.CM_Table_Training;
            % CM_Table_Validation = Monitor_Values.CM_Table_Validation;
            % ClassNames = Monitor_Values.ClassNames;
            MonitorUpdate = struct();

            HasEncoder = contains(monitor.SaveTerm,'Encoder');
            HasDecoder = contains(monitor.SaveTerm,'Decoder');
            HasClassifier = contains(monitor.SaveTerm,'Classifier');
            iteration = Monitor_Values.iteration;
            monitor.X_Iteration = [monitor.X_Iteration,iteration];
            monitor.Iteration = iteration;
            %%
            if HasEncoder
                % this_Network = Monitor_Values.Encoder;
                GradientSelection = 'Encoder';
                SelectionIDX = true;
            elseif HasDecoder
                % this_Network = Monitor_Values.Decoder;
                GradientSelection = 'Decoder';
                SelectionIDX = true;
            elseif HasClassifier
                this_Network = Monitor_Values.Classifier;
                GradientSelection = 'Classifier';
                Classifier_Dimension = ...
                    str2double(extractAfter(monitor.SaveTerm,'Dimension-'));
                SelectionIDX = contains(this_Network.Learnables.Layer,...
                    sprintf("Dim_%d",Classifier_Dimension));
            end
            Gradients = Monitor_Values.Gradients.(GradientSelection);
            Gradients_PreThreshold = Monitor_Values. ...
                Gradients_PreThreshold.(GradientSelection);
            %%
            WeightIDX = contains(Gradients.Parameter,"Weights");
            WeightIDX = WeightIDX & SelectionIDX;
            %%
            if isempty(monitor.GradientValuesNames)
            GradientValuesNames_tmp = Gradients.Layer(WeightIDX) + "-" + Gradients.Parameter(WeightIDX);
            monitor.GradientValuesNames = GradientValuesNames_tmp;
            end
            GradientValues = Gradients.Value(WeightIDX);
            Gradients_PreThresholdValues = Gradients_PreThreshold.Value(WeightIDX);
            [XIDX,~] = size(monitor.MeanGradient);
            for gidx = 1:length(GradientValues)
              monitor.MeanGradient(XIDX+1,gidx) = mean(Gradients_PreThresholdValues{gidx},"all");
              monitor.STDGradient(XIDX+1,gidx) = std(Gradients_PreThresholdValues{gidx},[],"all");
              monitor.MeanThresholdGradient(XIDX+1,gidx) = mean(GradientValues{gidx},"all");
              monitor.STDThresholdGradient(XIDX+1,gidx) = std(GradientValues{gidx},[],"all");
            end
            %%
            MonitorUpdate.GradientValuesNames = monitor.GradientValuesNames;
            MonitorUpdate.MeanGradient = monitor.MeanGradient;
            MonitorUpdate.STDGradient = monitor.STDGradient;
            MonitorUpdate.MeanThresholdGradient = monitor.MeanThresholdGradient;
            MonitorUpdate.STDThresholdGradient = monitor.STDThresholdGradient;

        end
    end
end

