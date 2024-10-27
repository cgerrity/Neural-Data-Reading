classdef cgg_generateComponentProgressMonitor < handle
%CGG_GENERATEPROGRESSMONITOR Summary of this function goes here
%   Detailed explanation goes here

    properties
        Figure
        PlotTable
        SaveDir
        SaveTerm
        PlotPercentile
        OutlierWindow
        OutlierThreshold
        RangeFactor
        DataNames
        WantClassificationLoss
        WantClassificationLossPerDimension
        WantKLLoss
        WantReconstructionLoss
        WantReconstructionLossPerChannel
        RunTerm
    end

    methods
        function [monitor,DataNames] = cgg_generateComponentProgressMonitor(varargin)

isfunction=exist('varargin','var');

if isfunction
NumAreas = CheckVararginPairs('NumAreas', 6, varargin{:});
else
if ~(exist('NumAreas','var'))
NumAreas=6;
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
WantKLLoss = CheckVararginPairs('WantKLLoss', false, varargin{:});
else
if ~(exist('WantKLLoss','var'))
WantKLLoss=false;
end
end

if isfunction
WantClassificationLoss = CheckVararginPairs('WantClassificationLoss', false, varargin{:});
else
if ~(exist('WantClassificationLoss','var'))
WantClassificationLoss=false;
end
end

if isfunction
WantReconstructionLoss = CheckVararginPairs('WantReconstructionLoss', false, varargin{:});
else
if ~(exist('WantReconstructionLoss','var'))
WantReconstructionLoss=false;
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
PlotPercentile = CheckVararginPairs('PlotPercentile', 99.99, varargin{:});
else
if ~(exist('PlotPercentile','var'))
PlotPercentile=99.99;
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
RangeFactor = CheckVararginPairs('RangeFactor', 0.2, varargin{:});
else
if ~(exist('RangeFactor','var'))
RangeFactor=0.2;
end
end

if isfunction
Run = CheckVararginPairs('Run', 1, varargin{:});
else
if ~(exist('Run','var'))
Run=1;
end
end
%%

cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;

X_Name_Size = cfg_Plot.X_Name_Size;
Y_Name_Size = cfg_Plot.Y_Name_Size;

Label_Size = cfg_Plot.Label_Size;
Line_Width_ProgressMonitor = cfg_Plot.Line_Width_ProgressMonitor;

if ~isempty(SaveTerm)
SaveTerm = ['_' SaveTerm];
end

%

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

WantReconstructionLossPerChannel = false;
if (NumAreas > 1) && WantReconstructionLoss
WantReconstructionLossPerChannel = true;
end

WantClassificationLossPerDimension = false;
if (NumDimensions > 1) && WantClassificationLoss
WantClassificationLossPerDimension = true;
end

NumLossPlots = 0;

if WantClassificationLoss
NumLossPlots = NumLossPlots+1;
end
if WantClassificationLossPerDimension
NumLossPlots = NumLossPlots+1;
end
if WantKLLoss
NumLossPlots = NumLossPlots+1;
end
if WantReconstructionLoss
NumLossPlots = NumLossPlots+1;
end
if WantReconstructionLossPerChannel
NumLossPlots = NumLossPlots+1;
end

PlotSplit=4;

Tiled_Plot=tiledlayout(NumLossPlots,PlotSplit,"TileSpacing","tight");
% Tiled_Plot=tiledlayout(NumLossPlots,PlotSplit,"TileSpacing","none");

PlotCell = cell(0);
PlotName = cell(0);
PlotTile = cell(0);
PlotGroup = NaN(0);
PlotValues = cell(0);
Current_Tile_Count = 1;

if WantClassificationLoss
this_TileRowIDX = (Current_Tile_Count-1)*PlotSplit+1;
this_Tile = nexttile(Tiled_Plot,this_TileRowIDX,[1,PlotSplit]);

    p_LossClassificationTraining=plot(NaN,NaN,'DisplayName','Training Classification Loss','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_LossClassificationValidation=plot(NaN,NaN,'DisplayName','Validation Classification Loss','LineWidth',Line_Width_ProgressMonitor);
    hold off
    box off
    legend([p_LossClassificationTraining,p_LossClassificationValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

NumPlotCell = numel(PlotCell);
PlotCell{NumPlotCell+1} = p_LossClassificationTraining;
PlotName{NumPlotCell+1} = 'ClassificationLossTraining';
PlotTile{NumPlotCell+1} = this_Tile;
PlotGroup{NumPlotCell+1} = Current_Tile_Count;
PlotValues{NumPlotCell+1} = [];
PlotCell{NumPlotCell+2} = p_LossClassificationValidation;
PlotName{NumPlotCell+2} = 'ClassificationLossValidation';
PlotTile{NumPlotCell+2} = this_Tile;
PlotGroup{NumPlotCell+2} = Current_Tile_Count;
PlotValues{NumPlotCell+2} = [];

Current_Tile_Count = Current_Tile_Count+1;
end

if WantClassificationLossPerDimension
this_TileRowIDX = (Current_Tile_Count-1)*PlotSplit+1;
this_Tile = nexttile(Tiled_Plot,this_TileRowIDX,[1,PlotSplit]);

NumPlotCell = numel(PlotCell);

PlotsClassification = gobjects(NumDimensions*2,1);
if NumDimensions > 7
PlotColors = jet(NumDimensions);
else
    PlotColors = [0 0.4470 0.7410; ...
        0.8500 0.3250 0.0980; ...
        0.9290 0.6940 0.1250; ...
        0.4940 0.1840 0.5560; ...
        0.4660 0.6740 0.1880; ...
        0.3010 0.7450 0.9330; ...
        0.6350 0.0780 0.1840];
end

for cidx = 1:NumDimensions

    this_DisplayNameTraining = sprintf('Training Dimension %d',cidx);
    this_DisplayNameValidation = sprintf('Validation Dimension %d',cidx);
    this_PlotNameTraining = sprintf('Dimension_%d_ClassificationLossTraining',cidx);
    this_PlotNameValidation = sprintf('Dimension_%d_ClassificationLossValidation',cidx);

    LightenFactor = 0.25;
    ValidationColor = PlotColors(cidx,:);
    TrainingColor = ValidationColor*LightenFactor + (1-LightenFactor);
    
    PlotsClassification(cidx)=plot(NaN,NaN,'DisplayName',this_DisplayNameTraining,'LineWidth',Line_Width_ProgressMonitor,'Color',TrainingColor,'LineStyle','-');
    if cidx == 1
        hold on 
    end
    PlotsClassification(cidx+NumDimensions)=plot(NaN,NaN,'DisplayName',this_DisplayNameValidation,'LineWidth',Line_Width_ProgressMonitor,'Color',ValidationColor,'LineStyle','-');

PlotCell{NumPlotCell+cidx} = PlotsClassification(cidx);
PlotName{NumPlotCell+cidx} = this_PlotNameTraining;
PlotTile{NumPlotCell+cidx} = this_Tile;
PlotGroup{NumPlotCell+cidx} = Current_Tile_Count;
PlotValues{NumPlotCell+cidx} = [];
PlotCell{NumPlotCell+cidx+NumDimensions} = PlotsClassification(cidx+NumDimensions);
PlotName{NumPlotCell+cidx+NumDimensions} = this_PlotNameValidation;
PlotTile{NumPlotCell+cidx+NumDimensions} = this_Tile;
PlotGroup{NumPlotCell+cidx+NumDimensions} = Current_Tile_Count;
PlotValues{NumPlotCell+cidx+NumDimensions} = [];

end
    hold off
    box off
    legend(PlotsClassification,"Location","best","NumColumns",2);
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

Current_Tile_Count = Current_Tile_Count+1;
end

if WantKLLoss
this_TileRowIDX = (Current_Tile_Count-1)*PlotSplit+1;
this_Tile = nexttile(Tiled_Plot,this_TileRowIDX,[1,PlotSplit]);

    p_LossKLTraining=plot(NaN,NaN,'DisplayName','Training KL Loss','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_LossKLValidation=plot(NaN,NaN,'DisplayName','Validation KL Loss','LineWidth',Line_Width_ProgressMonitor);
    hold off
    box off
    legend([p_LossKLTraining,p_LossKLValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

NumPlotCell = numel(PlotCell);
PlotCell{NumPlotCell+1} = p_LossKLTraining;
PlotName{NumPlotCell+1} = 'KLLossTraining';
PlotTile{NumPlotCell+1} = this_Tile;
PlotGroup{NumPlotCell+1} = Current_Tile_Count;
PlotValues{NumPlotCell+1} = [];
PlotCell{NumPlotCell+2} = p_LossKLValidation;
PlotName{NumPlotCell+2} = 'KLLossValidation';
PlotTile{NumPlotCell+2} = this_Tile;
PlotGroup{NumPlotCell+2} = Current_Tile_Count;
PlotValues{NumPlotCell+2} = [];

Current_Tile_Count = Current_Tile_Count+1;
end

if WantReconstructionLoss
this_TileRowIDX = (Current_Tile_Count-1)*PlotSplit+1;
this_Tile = nexttile(Tiled_Plot,this_TileRowIDX,[1,PlotSplit]);

    p_LossReconstructionTraining=plot(NaN,NaN,'DisplayName','Training Reconstruction Loss','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_LossReconstructionValidation=plot(NaN,NaN,'DisplayName','Validation Reconstruction Loss','LineWidth',Line_Width_ProgressMonitor);
    hold off
    box off
    legend([p_LossReconstructionTraining,p_LossReconstructionValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

NumPlotCell = numel(PlotCell);
PlotCell{NumPlotCell+1} = p_LossReconstructionTraining;
PlotName{NumPlotCell+1} = 'ReconstructionLossTraining';
PlotTile{NumPlotCell+1} = this_Tile;
PlotGroup{NumPlotCell+1} = Current_Tile_Count;
PlotValues{NumPlotCell+1} = [];
PlotCell{NumPlotCell+2} = p_LossReconstructionValidation;
PlotName{NumPlotCell+2} = 'ReconstructionLossValidation';
PlotTile{NumPlotCell+2} = this_Tile;
PlotGroup{NumPlotCell+2} = Current_Tile_Count;
PlotValues{NumPlotCell+2} = [];

Current_Tile_Count = Current_Tile_Count+1;
end

if WantReconstructionLossPerChannel
this_TileRowIDX = (Current_Tile_Count-1)*PlotSplit+1;
this_Tile = nexttile(Tiled_Plot,this_TileRowIDX,[1,PlotSplit]);

NumPlotCell = numel(PlotCell);

PlotsReconstruction = gobjects(NumAreas*2,1);
if NumAreas > 6
PlotColors = jet(NumAreas);
else
    % PlotColors = [0 0.4470 0.7410; ...
    %     0.8500 0.3250 0.0980; ...
    %     0.9290 0.6940 0.1250; ...
    %     0.4940 0.1840 0.5560; ...
    %     0.4660 0.6740 0.1880; ...
    %     0.3010 0.7450 0.9330; ...
    %     0.6350 0.0780 0.1840];
    PlotColors = [0.9098 0.0784 0.0863; ...
        1.0000 0.6471 0.0000; ...
        0.9804 0.9216 0.2118; ...
        0.4745 0.7647 0.0784; ...
        0.2824 0.4902 0.9059; ...
        0.4392 0.2118 0.6157];
end

for cidx = 1:NumAreas

    this_DisplayNameTraining = sprintf('Training Area %d',cidx);
    this_DisplayNameValidation = sprintf('Validation Area %d',cidx);
    this_PlotNameTraining = sprintf('Area_%d_ReconstructionLossTraining',cidx);
    this_PlotNameValidation = sprintf('Area_%d_ReconstructionLossValidation',cidx);
    
    LightenFactor = 0.25;
    ValidationColor = PlotColors(cidx,:);
    TrainingColor = ValidationColor*LightenFactor + (1-LightenFactor);

    PlotsReconstruction(cidx)=plot(NaN,NaN,'DisplayName',this_DisplayNameTraining,'LineWidth',Line_Width_ProgressMonitor,'Color',TrainingColor,'LineStyle','-');
    if cidx == 1
        hold on 
    end
    PlotsReconstruction(cidx+NumAreas)=plot(NaN,NaN,'DisplayName',this_DisplayNameValidation,'LineWidth',Line_Width_ProgressMonitor,'Color',ValidationColor,'LineStyle','-');

PlotCell{NumPlotCell+cidx} = PlotsReconstruction(cidx);
PlotName{NumPlotCell+cidx} = this_PlotNameTraining;
PlotTile{NumPlotCell+cidx} = this_Tile;
PlotGroup{NumPlotCell+cidx} = Current_Tile_Count;
PlotValues{NumPlotCell+cidx} = [];
PlotCell{NumPlotCell+cidx+NumAreas} = PlotsReconstruction(cidx+NumAreas);
PlotName{NumPlotCell+cidx+NumAreas} = this_PlotNameValidation;
PlotTile{NumPlotCell+cidx+NumAreas} = this_Tile;
PlotGroup{NumPlotCell+cidx+NumAreas} = Current_Tile_Count;
PlotValues{NumPlotCell+cidx+NumAreas} = [];

end
    hold off
    box off
    legend(PlotsReconstruction,"Location","best","NumColumns",2);
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

% Current_Tile_Count = Current_Tile_Count+1;
end

PlotTable=table(PlotCell',PlotGroup',PlotValues',PlotTile','VariableNames',...
    {'Plot','Group','Values','Tile'},'RowNames',PlotName');

monitor.PlotTable = PlotTable;

%%

drawnow;

monitor.Figure=InFigure;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.PlotPercentile = PlotPercentile;
monitor.OutlierWindow = OutlierWindow;
monitor.OutlierThreshold = OutlierThreshold;
monitor.RangeFactor = RangeFactor;
monitor.RunTerm = sprintf('_Run-%d',Run);

monitor.WantClassificationLoss = ...
    WantClassificationLoss;
monitor.WantClassificationLossPerDimension = ...
    WantClassificationLossPerDimension;
monitor.WantKLLoss = ...
    WantKLLoss;
monitor.WantReconstructionLoss = ...
    WantReconstructionLoss;
monitor.WantReconstructionLossPerChannel = ...
    WantReconstructionLossPerChannel;

%%
DataNames = cell(0);

DataNames{1} = 'iteration';
DataNames{2} = 'Loss_ReconstructionTraining';
DataNames{3} = 'Loss_KLTraining';
DataNames{4} = 'Loss_ClassificationTraining';
DataNames{5} = 'Loss_ReconstructionValidation';
DataNames{6} = 'Loss_KLValidation';
DataNames{7} = 'Loss_ClassificationValidation';
DataNames{8} = 'Loss_ReconstructionTrainingByComponent';
DataNames{9} = 'Loss_ReconstructionValidationByComponent';
DataNames{10} = 'Loss_ClassificationTrainingByDimension';
DataNames{11} = 'Loss_ClassificationValidationByDimension';

monitor.DataNames = DataNames;
        end

        function initializePlot(monitor,PlotName,PlotUpdate)
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            this_Plot.XData=[PlotUpdate(1)];
            this_Plot.YData=[PlotUpdate(2)];
        end
        function updatePlot(monitor,PlotName,PlotUpdate)
            this_Plot = monitor.PlotTable{PlotName,"Plot"};
            this_Tile = monitor.PlotTable{PlotName,"Tile"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            if iscell(this_Tile)
                this_Tile=this_Tile{1};
            end
            this_Plot.XData=[this_Plot.XData,PlotUpdate(1)];
            this_Plot.YData=[this_Plot.YData,PlotUpdate(2)];

            monitor.PlotTable{PlotName,"Values"}{1} = this_Plot.YData;
            this_Group = monitor.PlotTable{PlotName,"Group"}{1};
            this_GroupIDX = cell2mat(monitor.PlotTable.Group)==this_Group;
            this_GroupValues = monitor.PlotTable{this_GroupIDX,"Values"};

            DataLimits = cgg_getPlotRangeFromData_v2(this_GroupValues,monitor.RangeFactor,monitor.PlotPercentile,NaN);
            % DataLimits = cgg_getPlotRangeFromData(this_GroupValues,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            
            if DataLimits(2) > 0 && DataLimits(1) < 0
            DataLimits(1)=0;
            end
            if any(isnan(DataLimits))
            this_Tile.YLim = DataLimits;
            end
        end

        function saveLogPlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Progress-Monitor-Component' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm '_Log' monitor.RunTerm '.pdf'];
            
            NumPlots = height(monitor.PlotTable);

            PlotYData_Regular = cell(1,NumPlots);
            YLim_Regular = cell(1,NumPlots);

            for pidx = 1:NumPlots
                this_Plot = monitor.PlotTable{pidx,"Plot"};
                this_Tile = monitor.PlotTable{pidx,"Tile"};
                if iscell(this_Plot)
                    this_Plot=this_Plot{1};
                end
                if iscell(this_Tile)
                    this_Tile=this_Tile{1};
                end
                this_PlotYData_Regular = this_Plot.YData;
                PlotYData_Regular{pidx} = this_PlotYData_Regular;
                YLim_Regular{pidx} = this_Tile.YLim;
            end

            for pidx = 1:NumPlots

            this_Plot = monitor.PlotTable{pidx,"Plot"};
            this_Tile = monitor.PlotTable{pidx,"Tile"};
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            if iscell(this_Tile)
                this_Tile=this_Tile{1};
            end
            this_PlotYData_Regular = this_Plot.YData;
            this_PlotYDataLog = log(this_PlotYData_Regular);
            this_PlotYDataLog(isinf(this_PlotYDataLog)) = NaN;
            this_Plot.YData=this_PlotYDataLog;

            %%
            this_Group = monitor.PlotTable{pidx,"Group"}{1};
            this_GroupIDX = cell2mat(monitor.PlotTable.Group)==this_Group;
            this_GroupValues = monitor.PlotTable{this_GroupIDX,"Values"};

            if iscell(this_GroupValues)
                this_LogGroupValues = cellfun(@(x) log(x),this_GroupValues,'UniformOutput',false);
            %     this_LogGroupValues = cellfun(@(x) x(~isinf(x)),this_LogGroupValues,'UniformOutput',false);
            %     this_LogGroupValues_Max = cellfun(@(x) max(x,[],"all","omitmissing"),this_LogGroupValues,'UniformOutput',false);
            %     this_LogGroupValues_Min = cellfun(@(x) min(x,[],"all","omitmissing"),this_LogGroupValues,'UniformOutput',false);
            %     this_LogGroupValues_Max = cell2mat(this_LogGroupValues_Max);
            %     this_LogGroupValues_Min = cell2mat(this_LogGroupValues_Min);
            %     this_Log_Max = max(this_LogGroupValues_Max,[],"all","omitmissing");
            %     this_Log_Min = min(this_LogGroupValues_Min,[],"all","omitmissing");
            else
            %     this_LogGroupValues = log(this_GroupValues);
            %     this_LogGroupValues(isinf(this_LogGroupValues)) = NaN;
            %     this_Log_Max = max(this_LogGroupValues,[],"all","omitmissing");
            %     this_Log_Min = min(this_LogGroupValues,[],"all","omitmissing");
            end
            % 
            % this_Tile.YLim = [this_Log_Min,this_Log_Max];

            this_Tile.YLim = cgg_getPlotRangeFromData_v2(this_LogGroupValues,0,100,NaN);
            
            %%
            end

            saveas(monitor.Figure,SavePathNameExt);

            for pidx = 1:NumPlots
                this_Plot = monitor.PlotTable{pidx,"Plot"};
                this_Tile = monitor.PlotTable{pidx,"Tile"};
                if iscell(this_Plot)
                    this_Plot=this_Plot{1};
                end
                if iscell(this_Tile)
                    this_Tile=this_Tile{1};
                end
                this_Plot.YData=PlotYData_Regular{pidx};
                this_Tile.YLim=YLim_Regular{pidx};
            end
        end

        function savePlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Progress-Monitor-Component' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm monitor.RunTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);

            saveLogPlot(monitor,IsOptimal);
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
            LossInformation_Training = Monitor_Values.LossInformation_Training;
            LossInformation_Validation = Monitor_Values.LossInformation_Validation;
            % CM_Table_Training = Monitor_Values.CM_Table_Training;
            % CM_Table_Validation = Monitor_Values.CM_Table_Validation;
            % ClassNames = Monitor_Values.ClassNames;
            MonitorUpdate = struct();

            MonitorUpdate.iteration = Monitor_Values.iteration;

            MonitorUpdate.Loss_ReconstructionTraining = NaN;
            MonitorUpdate.Loss_KLTraining = NaN;
            MonitorUpdate.Loss_ClassificationTraining = NaN;
            MonitorUpdate.Loss_ReconstructionValidation = NaN;
            MonitorUpdate.Loss_KLValidation = NaN;
            MonitorUpdate.Loss_ClassificationValidation = NaN;
            MonitorUpdate.Loss_ReconstructionTrainingByComponent = NaN;
            MonitorUpdate.Loss_ReconstructionValidationByComponent = NaN;
            MonitorUpdate.Loss_ClassificationTrainingByDimension = NaN;
            MonitorUpdate.Loss_ClassificationValidationByDimension = NaN;

            UpdateValidation = ~isempty(LossInformation_Validation);

            if monitor.WantClassificationLoss
                MonitorUpdate.Loss_ClassificationTraining = LossInformation_Training.Loss_Classification;
                if UpdateValidation
                    MonitorUpdate.Loss_ClassificationValidation = LossInformation_Validation.Loss_Classification;
                end
            end

            if monitor.WantClassificationLossPerDimension
                MonitorUpdate.Loss_ClassificationTrainingByDimension = LossInformation_Training.Loss_Classification_PerDimension;
                if UpdateValidation
                    MonitorUpdate.Loss_ClassificationValidationByDimension = LossInformation_Validation.Loss_Classification_PerDimension;
                end
            end

            if monitor.WantKLLoss
                MonitorUpdate.Loss_KLTraining = LossInformation_Training.Loss_KL;
                if UpdateValidation
                    MonitorUpdate.Loss_KLValidation = LossInformation_Validation.Loss_KL;
                end
            end

            if monitor.WantReconstructionLoss
                MonitorUpdate.Loss_ReconstructionTraining = LossInformation_Training.Loss_Reconstruction;
                if UpdateValidation
                    MonitorUpdate.Loss_ReconstructionValidation = LossInformation_Validation.Loss_Reconstruction;
                end
            end

            if monitor.WantReconstructionLossPerChannel
                MonitorUpdate.Loss_ReconstructionTrainingByComponent = LossInformation_Training.Loss_Reconstruction_PerArea;
                if UpdateValidation
                    MonitorUpdate.Loss_ReconstructionValidationByComponent = LossInformation_Validation.Loss_Reconstruction_PerArea;
                end
            end

        end
    end
end

