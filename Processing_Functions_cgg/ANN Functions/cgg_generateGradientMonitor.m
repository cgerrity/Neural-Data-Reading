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
    end
    
    methods
        function monitor = cgg_generateGradientMonitor(varargin)
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

%% Assign Properties
monitor.Iteration = 0;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.Tiled_Plot = Tiled_Plot;
monitor.NumWeights = 0;
        end
        
        function updatePlot(monitor,GradientValuesNames,MeanGradient,STDGradient,MeanThresholdGradient,STDThresholdGradient)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here

            [Iteration,NumWeights] = size(MeanGradient);
            monitor.NumWeights = NumWeights;

            if NumWeights > 6
                PlotColors = hsv(NumWeights);
            end
            
            % Mean Gradient
            nexttile(monitor.Tiled_Plot,1,[1,1]);

            this_PlotValue = MeanGradient(:,1);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:NumWeights
                this_PlotValue = MeanGradient(:,widx);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if NumWeights < 10
            Legend_MeanGradient = legend;
            Legend_MeanGradient.Location = "best";
            Legend_MeanGradient.FontSize = 6;
            end
            title('Mean Gradient');

            % Mean Threshold Gradient
            nexttile(monitor.Tiled_Plot,2,[1,1]);

            this_PlotValue = MeanThresholdGradient(:,1);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:NumWeights
                this_PlotValue = MeanThresholdGradient(:,widx);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if NumWeights < 10
            Legend_MeanThresholdGradient = legend;
            Legend_MeanThresholdGradient.Location = "best";
            Legend_MeanThresholdGradient.FontSize = 6;
            end
            title('Mean Threshold Gradient');

            % STD Gradient
            nexttile(monitor.Tiled_Plot,3,[1,1]);

            this_PlotValue = STDGradient(:,1);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:NumWeights
                this_PlotValue = STDGradient(:,widx);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if NumWeights < 10
            Legend_STDGradient = legend;
            Legend_STDGradient.Location = "best";
            Legend_STDGradient.FontSize = 6;
            end
            title('Standard Deviation Gradient');

            % STD Threshold Gradient
            nexttile(monitor.Tiled_Plot,4,[1,1]);

            this_PlotValue = STDThresholdGradient(:,1);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(1),"Color",PlotColors(1,:));

            hold on
            for widx = 2:NumWeights
                this_PlotValue = STDThresholdGradient(:,widx);
            plot(this_PlotValue,"DisplayName",GradientValuesNames(widx),"Color",PlotColors(widx,:));
            end
            hold off
            if NumWeights < 10
            Legend_STDThresholdGradient = legend;
            Legend_STDThresholdGradient.Location = "best";
            Legend_STDThresholdGradient.FontSize = 6;
            end
            title('Standard Deviation Threshold Gradient');

            monitor.Iteration = Iteration;
        end

        function savePlot(monitor)
            iteration = monitor.Iteration;
            if iscell(iteration)
                iteration=iteration{1};
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Gradient-Monitor_Iteration-' num2str(iteration) ...
                monitor.SaveTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end
    end
end

