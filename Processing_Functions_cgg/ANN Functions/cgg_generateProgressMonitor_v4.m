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
    end

    methods
        function monitor = cgg_generateProgressMonitor_v4(varargin)

isfunction=exist('varargin','var');

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
    case 'Regression'
        % MetricNames=["LossTraining","LossValidation"];
        NumLossPlots = 1;
    otherwise
end

PlotSplit=4;
InformationSpan=1;

Tiled_Plot=tiledlayout(NumLossPlots,PlotSplit,"TileSpacing","tight");

if NumLossPlots==2
    nexttile(Tiled_Plot,1,[1,PlotSplit-InformationSpan]);
    
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
    
    nexttile(Tiled_Plot,PlotSplit+1,[1,PlotSplit-InformationSpan]);
    
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
elseif NumLossPlots==1
    nexttile(Tiled_Plot,1,[1,PlotSplit-InformationSpan]);
    
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
end

PlotTable=table(PlotCell','VariableNames',...
    {'Plot'},'RowNames',PlotName');

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

drawnow;

monitor.Figure=InFigure;
monitor.Stop = false;
monitor.Status = false;
monitor.LossTransform = LossTransform;
monitor.Progress = 0;
monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;
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
            if iscell(this_Plot)
                this_Plot=this_Plot{1};
            end
            this_Plot.XData=[this_Plot.XData,PlotUpdate(1)];
            this_Plot.YData=[this_Plot.YData,PlotUpdate(2)];
        end
        function savePlot(monitor)
            iteration = monitor.InformationTable{'Iteration',"Value"};
            if iscell(iteration)
                iteration=iteration{1};
            end
            SavePathNameExt = [monitor.SaveDir filesep ...
                'Progress-Monitor' monitor.SaveTerm '_Iteration-' ...
                num2str(iteration) '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end
    end
end

