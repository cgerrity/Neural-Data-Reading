classdef cgg_generateProgressMonitor_v4 < handle
%CGG_GENERATEPROGRESSMONITOR Summary of this function goes here
%   Detailed explanation goes here

    properties
        Figure
        Information
        InformationTable
        Time
        TimerValue
        PlotTable
        IDX_TimeElapsed
        Stop
        Status
        LossTransform
        Progress
        SaveDir
        SaveTerm
        OutlierWindow
        OutlierThreshold
        RangeFactor
        DataNames
        MatchType
        RunTerm
    end

    methods
        function [monitor,DataNames] = cgg_generateProgressMonitor_v4(varargin)

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'combinedaccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='combinedaccuracy';
end
end

if isfunction
LossType = CheckVararginPairs('LossType', 'Classification', varargin{:});
else
if ~(exist('LossType','var'))
LossType='Classification';
end
end

if isfunction
LogLoss = CheckVararginPairs('LogLoss', false, varargin{:});
else
if ~(exist('LogLoss','var'))
LogLoss=false;
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
%%

cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;

X_Name_Size = cfg_Plot.X_Name_Size;
Y_Name_Size = cfg_Plot.Y_Name_Size;

Label_Size = cfg_Plot.Label_Size;
Line_Width_ProgressMonitor = cfg_Plot.Line_Width_ProgressMonitor;

Text_Size = cfg_Plot.Text_Size;

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

switch LossType
    case 'Classification'
        % MetricNames=["MajorityClass","RandomChance","LossTraining","LossValidation","AccuracyTraining","AccuracyValidation"];
        NumLossPlots = 2;
    case 'CTC'
        % MetricNames=["MajorityClass","RandomChance","LossTraining","LossValidation","AccuracyTraining","AccuracyValidation"];
        NumLossPlots = 2;
    case 'Regression'
        % MetricNames=["LossTraining","LossValidation"];
        NumLossPlots = 1;
    otherwise
end

PlotSplit=4;
InformationSpan=1;

Tiled_Plot=tiledlayout(NumLossPlots,PlotSplit,"TileSpacing","tight");

if NumLossPlots==2
    Tile_Accuracy = nexttile(Tiled_Plot,1,[1,PlotSplit-InformationSpan]);
    
    p_AccuracyTraining=plot(NaN,NaN,'DisplayName','Training Accuracy','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_AccuracyValidation=plot(NaN,NaN,'DisplayName','Validation Accuracy','LineWidth',Line_Width_ProgressMonitor);
    p_MajorityClass=plot(NaN,NaN,'DisplayName','Majority Class','LineWidth',Line_Width_ProgressMonitor);
    p_RandomChance=plot(NaN,NaN,'DisplayName','Random Chance','LineWidth',Line_Width_ProgressMonitor);
    hold off

    box off
    ylim([0,1]);
    legend([p_AccuracyTraining,p_AccuracyValidation,p_MajorityClass,...
        p_RandomChance],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Accuracy','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
    
    Tile_Loss = nexttile(Tiled_Plot,PlotSplit+1,[1,PlotSplit-InformationSpan]);
    
    p_LossTraining=plot(NaN,NaN,'DisplayName','Training Loss','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_LossValidation=plot(NaN,NaN,'DisplayName','Validation Loss','LineWidth',Line_Width_ProgressMonitor);
    hold off

    box off
    legend([p_LossTraining,p_LossValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

    PlotCell={p_AccuracyTraining,p_AccuracyValidation,p_MajorityClass,...
        p_RandomChance,p_LossTraining,p_LossValidation};
    PlotName={'AccuracyTraining','AccuracyValidation','MajorityClass',...
        'RandomChance','LossTraining','LossValidation'};
    PlotTile = {Tile_Accuracy,Tile_Accuracy,Tile_Accuracy,...
        Tile_Accuracy,Tile_Loss,Tile_Loss};
    PlotGroup = {1,1,1,1,2,2};
    PlotValues = {[],[],[],[],[],[]};
elseif NumLossPlots==1
    Tile_Loss = nexttile(Tiled_Plot,1,[1,PlotSplit-InformationSpan]);
    
    p_LossTraining=plot(NaN,NaN,'DisplayName','Training Loss','LineWidth',Line_Width_ProgressMonitor);
    hold on
    p_LossValidation=plot(NaN,NaN,'DisplayName','Validation Loss','LineWidth',Line_Width_ProgressMonitor);
    hold off

    box off
    legend([p_LossTraining,p_LossValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;

    PlotCell={p_LossTraining,p_LossValidation};
    PlotName={'LossTraining','LossValidation'};
    PlotTile = {Tile_Loss,Tile_Loss};
    PlotGroup = {2,2};
    PlotValues = {[],[]};
end

PlotTable=table(PlotCell',PlotGroup',PlotValues',PlotTile','VariableNames',...
    {'Plot','Group','Values','Tile'},'RowNames',PlotName');

monitor.PlotTable = PlotTable;

%%
nexttile(Tiled_Plot,PlotSplit,[NumLossPlots,1]);
Ax = gca;
Ax.Visible = 0;

Title_Loss="Loss";
if LogLoss
Title_Loss="Log_Loss";
end

Information_Display=cell(0);
Information_Display_Counter = 1;
InformationValue_Display=cell(0);
InformationIDX=cell(0);
InformationName=cell(0);

Information_Display{Information_Display_Counter} = "\bfInformation\rm";
InformationValue_Display{Information_Display_Counter} = "";
% IDX_Information = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationName{Information_Display_Counter} = 'Title';
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Workers";
% IDX_Worker = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'Workers';
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Execution Environment";
% IDX_ExecutionEnvironment = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'ExecutionEnvironment';
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Learning Rate";
% IDX_LearningRate = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'LearningRate';
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Epoch";
% IDX_Epoch = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'Epoch';
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Iteration";
% IDX_Iteration = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'Iteration';
Information_Display_Counter = Information_Display_Counter + 1;

if LogLoss
Information_Display{Information_Display_Counter} = "Loss Transform";
% IDX_LossType = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'LossTransform';
Information_Display_Counter = Information_Display_Counter + 1;
end

Information_Display{Information_Display_Counter} = "Loss";
% IDX_Loss = Information_Display_Counter;
InformationIDX{Information_Display_Counter} = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
InformationName{Information_Display_Counter} = 'Loss';
Information_Display_Counter = Information_Display_Counter + 1;


if WantKLLoss
    Information_Display{Information_Display_Counter} = "KL Loss";
    % IDX_KL_Loss = Information_Display_Counter;
    InformationIDX{Information_Display_Counter} = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    InformationName{Information_Display_Counter} = 'KL_Loss';
    Information_Display_Counter = Information_Display_Counter + 1;
end
if WantReconstructionLoss
    Information_Display{Information_Display_Counter} = "Reconstruction Loss";
    % IDX_Reconstruction_Loss = Information_Display_Counter;
    InformationIDX{Information_Display_Counter} = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    InformationName{Information_Display_Counter} = 'Reconstruction_Loss';
    Information_Display_Counter = Information_Display_Counter + 1;
end
if WantClassificationLoss
    Information_Display{Information_Display_Counter} = "Classification Loss";
    % IDX_Classification_Loss = Information_Display_Counter;
    InformationIDX{Information_Display_Counter} = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    InformationName{Information_Display_Counter} = 'Classification_Loss';
    Information_Display_Counter = Information_Display_Counter + 1;
end

InformationTable=table(Information_Display',InformationValue_Display',...
    InformationIDX','VariableNames',...
    {'Display','Value','IDX'},'RowNames',InformationName');

monitor.InformationTable = InformationTable;

% monitor.Status = "Configuring";
% monitor.Progress = 0;

executionEnvironment = "auto";

LossTransform="None";
if LogLoss
LossTransform="Log";
end

if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    ExecutionEnvironment="GPU";
else
    ExecutionEnvironment="CPU";
end


text(0,0.5, Information_Display,'Units','normalized','FontSize',Text_Size);
text(0.7,0.5, InformationValue_Display,'Units','normalized','FontSize',Text_Size);

monitor.Information = monitor.Figure.Children.Children(1).Children(1);

updateInformation(monitor,'ExecutionEnvironment',ExecutionEnvironment);
% monitor = updateInformationTable(monitor,'ExecutionEnvironment',ExecutionEnvironment);
% InFigure.Children.Children(1).Children(1).String{IDX_ExecutionEnvironment}= ExecutionEnvironment;

if LogLoss
    updateInformation(monitor,'LossType',LossTransform);
% InFigure.Children.Children(1).Children(1).String{IDX_LossType} = LossType;
end


%% Time Information

Time_Display=cell(0);
Time_Display_Counter = 1;

TimeValue_Display=cell(0);

Time_Display{Time_Display_Counter} = "\bfTime\rm";
TimeValue_Display{Time_Display_Counter} = "";
IDX_Time = Time_Display_Counter;
Time_Display_Counter = Time_Display_Counter + 1;

Time_Display{Time_Display_Counter} = "Time Start: ";
IDX_TimeStart = Time_Display_Counter;
TimeValue_Display{Time_Display_Counter} = string(datetime);
Time_Display_Counter = Time_Display_Counter + 1;

Time_Display{Time_Display_Counter} = "Elapsed Time: ";
IDX_TimeElapsed = Time_Display_Counter;
TimeValue_Display{Time_Display_Counter} = "NaN";
Time_Display_Counter = Time_Display_Counter + 1;

text(0,0.75, Time_Display,'Units','normalized','FontSize',Text_Size);
text(0.7,0.75, TimeValue_Display,'Units','normalized','FontSize',Text_Size);

monitor.Time = monitor.Figure.Children.Children(1).Children(1);
monitor.IDX_TimeElapsed = IDX_TimeElapsed;

monitor.TimerValue=tic;


%%

DataNames = cell(0);

DataNames{1} = 'epoch';
DataNames{2} = 'iteration';
DataNames{3} = 'learningrate';
DataNames{4} = 'lossTraining';
DataNames{5} = 'lossValidation';
DataNames{6} = 'accuracyTrain';
DataNames{7} = 'accuracyValidation';
DataNames{8} = 'majorityclass';
DataNames{9} = 'randomchance';
DataNames{10} = 'Loss_Reconstruction';
DataNames{11} = 'Loss_KL';
DataNames{12} = 'Loss_Classification';
%%

drawnow;

monitor.Figure=InFigure;
monitor.Stop = false;
monitor.Status = false;
monitor.LossTransform = LossTransform;
monitor.Progress = 0;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
monitor.OutlierWindow = OutlierWindow;
monitor.OutlierThreshold = OutlierThreshold;
monitor.RangeFactor = RangeFactor;
monitor.DataNames = DataNames;
monitor.MatchType = MatchType;
monitor.RunTerm = sprintf('_Run-%d',Run);

        end

        
        function updateFigureText(monitor,TextType,IDX,NewText)
            monitor.(TextType).String{IDX}=NewText;
        end

        function updateInformationTable(monitor,Name,NewText)
            monitor.InformationTable{Name,"Value"}={NewText};
        end

        function updateInformation(monitor,Name,NewText)
            IDX = monitor.InformationTable{Name,"IDX"};
            updateInformationTable(monitor,Name,NewText);
            if iscell(IDX)
                IDX=IDX{1};
            end
            updateFigureText(monitor,'Information',IDX,NewText);
        end
        function updateTime(monitor)
            TimeElapsed=seconds(toc(monitor.TimerValue));
            TimeElapsed.Format = 'hh:mm:ss';
            TimeElapsed = string(TimeElapsed);
            updateFigureText(monitor,'Time',monitor.IDX_TimeElapsed,TimeElapsed);
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

            DataLimits = cgg_getPlotRangeFromData(this_GroupValues,monitor.RangeFactor,monitor.OutlierWindow,monitor.OutlierThreshold);
            
            if DataLimits(2) > 0
            DataLimits(1)=0;
            end

            if any(contains(PlotName,"Accuracy")) || any(contains(PlotName,"Random")) || any(contains(PlotName,"Majority"))
                this_GroupValues_Max = cellfun(@(x) max(x,[],"all","omitmissing"),this_GroupValues,'UniformOutput',false);
                this_GroupValues_Max = cell2mat(this_GroupValues_Max);
                this_Max = max(this_GroupValues_Max,[],"all","omitmissing");
                if this_Max > 0
                DataLimits(2)=this_Max;
                end
            end

            if ~any(isnan(DataLimits))
            this_Tile.YLim = DataLimits;
            end
        end
        % function savePlot(monitor)
        %     iteration = monitor.InformationTable{'Iteration',"Value"};
        %     if iscell(iteration)
        %         iteration=iteration{1};
        %     end
        %     SavePathNameExt = [monitor.SaveDir filesep ...
        %         'Progress-Monitor' monitor.SaveTerm '_Iteration-' ...
        %         num2str(iteration) '.pdf'];
        %     saveas(monitor.Figure,SavePathNameExt);
        % end
        function savePlot(monitor,IsOptimal)
            InSaveTerm = 'Current';
            if IsOptimal
            InSaveTerm = 'Optimal';
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Progress-Monitor' monitor.SaveTerm '_Iteration-' ...
                InSaveTerm monitor.RunTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end

        function data = generateData(monitor,MonitorUpdate)
            NumData = length(monitor.DataNames);
            data = NaN(1,NumData);
            for didx = 1:NumData
                this_DataName = monitor.DataNames{didx};
                data(didx) = MonitorUpdate.(this_DataName);
            end
        end

        function MonitorUpdate = calcMonitorUpdate(monitor,Monitor_Values)
            LossInformation_Training = Monitor_Values.LossInformation_Training;
            LossInformation_Validation = Monitor_Values.LossInformation_Validation;
            CM_Table_Training = Monitor_Values.CM_Table_Training;
            CM_Table_Validation = Monitor_Values.CM_Table_Validation;
            ClassNames = Monitor_Values.ClassNames;
            MonitorUpdate = struct();
            
            MonitorUpdate.epoch = Monitor_Values.epoch;
            MonitorUpdate.iteration = Monitor_Values.iteration;
            MonitorUpdate.learningrate = Monitor_Values.learningrate;
            MonitorUpdate.lossTraining = ...
                cgg_extractData(LossInformation_Training.Loss_Encoder);

            FieldName_MostCommon_Training = ...
                sprintf('MostCommon_%s_Training',monitor.MatchType);
            FieldName_RandomChance_Training = ...
                sprintf('RandomChance_%s_Training',monitor.MatchType);
            FieldName_Stratified_Training = ...
                sprintf('Stratified_%s_Training',monitor.MatchType);
            RandomChance_Baseline_Training = ...
                Monitor_Values.(FieldName_RandomChance_Training);
            MostCommon_Baseline_Training = ...
                Monitor_Values.(FieldName_MostCommon_Training);
            Stratified_Baseline_Training = ...
                Monitor_Values.(FieldName_Stratified_Training);
            FieldName_MostCommon_Validation = ...
                sprintf('MostCommon_%s_Validation',monitor.MatchType);
            FieldName_RandomChance_Validation = ...
                sprintf('RandomChance_%s_Validation',monitor.MatchType);
            FieldName_Stratified_Validation = ...
                sprintf('Stratified_%s_Validation',monitor.MatchType);
            RandomChance_Baseline_Validation = ...
                Monitor_Values.(FieldName_RandomChance_Validation);
            MostCommon_Baseline_Validation = ...
                Monitor_Values.(FieldName_MostCommon_Validation);
            Stratified_Baseline_Validation = ...
                Monitor_Values.(FieldName_Stratified_Validation);

            FieldName_IsScaled_Training = ...
                sprintf('IsScaled_%s_Training',monitor.MatchType);
            IsScaled_Training = ...
                Monitor_Values.(FieldName_IsScaled_Training);
            FieldName_IsScaled_Validation = ...
                sprintf('IsScaled_%s_Validation',monitor.MatchType);
            IsScaled_Validation = ...
                Monitor_Values.(FieldName_IsScaled_Validation);

            HasTrainingCM_Table = istable(CM_Table_Training);

            if HasTrainingCM_Table
            [~,~,accuracyTraining] = ...
                cgg_procConfusionMatrixFromTable(CM_Table_Training,...
                ClassNames,'MatchType',monitor.MatchType,...
                'IsQuaddle',Monitor_Values.IsQuaddle,...
                'RandomChance',RandomChance_Baseline_Training,...
                'MostCommon',MostCommon_Baseline_Training,...
                'Stratified',Stratified_Baseline_Training);
            else
                accuracyTraining = NaN;
            end

            MonitorUpdate.accuracyTrain = accuracyTraining;

            if IsScaled_Validation
            % ChanceLevel_Validation = max([Stratified_Baseline_Validation,MostCommon_Baseline_Validation,RandomChance_Baseline_Validation]);
            ChanceLevel_Validation = Stratified_Baseline_Validation;
            MostCommon_Validation = (MostCommon_Baseline_Validation-ChanceLevel_Validation)/(1-ChanceLevel_Validation);
            RandomChance_Validation = (RandomChance_Baseline_Validation-ChanceLevel_Validation)/(1-ChanceLevel_Validation);
            Stratified_Validation = (Stratified_Baseline_Validation-ChanceLevel_Validation)/(1-ChanceLevel_Validation);
            else
            MostCommon_Validation = MostCommon_Baseline_Validation;
            RandomChance_Validation = RandomChance_Baseline_Validation;
            Stratified_Validation = Stratified_Baseline_Validation; 
            end
            
            MonitorUpdate.majorityclass = MostCommon_Validation;
            MonitorUpdate.randomchance = RandomChance_Validation;
            MonitorUpdate.stratified = Stratified_Validation;

            % MonitorUpdate.Loss_Reconstruction = LossInformation_Training.Loss_Reconstruction; 
            % MonitorUpdate.Loss_KL = LossInformation_Training.Loss_KL;
            % MonitorUpdate.Loss_Classification = LossInformation_Training.Loss_Classification;

            MonitorUpdate.Loss_Reconstruction = cgg_extractData(...
                LossInformation_Training.Loss_Reconstruction_Weighted); 
            MonitorUpdate.Loss_KL = cgg_extractData(...
                LossInformation_Training.Loss_KL_Weighted); 
            MonitorUpdate.Loss_Classification = cgg_extractData(...
                LossInformation_Training.Loss_Classification_Weighted); 

            MonitorUpdate.lossValidation = NaN;
            MonitorUpdate.accuracyValidation = NaN;

            HasValidationLoss = isstruct(LossInformation_Validation);
            HasValidationCM_Table = istable(CM_Table_Validation);

            if HasValidationLoss
            MonitorUpdate.lossValidation = ...
                cgg_extractData(LossInformation_Validation.Loss_Encoder);
            end

            if HasValidationCM_Table
                [~,~,accuracyValidation] = ...
                    cgg_procConfusionMatrixFromTable(CM_Table_Validation,...
                    ClassNames,'MatchType',monitor.MatchType,...
                    'IsQuaddle',Monitor_Values.IsQuaddle,...
                    'RandomChance',RandomChance_Baseline_Validation,...
                    'MostCommon',MostCommon_Baseline_Validation,...
                    'Stratified',Stratified_Baseline_Validation);

            MonitorUpdate.accuracyValidation = accuracyValidation;
            end

        end

    end
end

