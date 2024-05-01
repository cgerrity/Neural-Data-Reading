function monitor = cgg_generateProgressMonitor_v3(varargin)
%CGG_GENERATEPROGRESSMONITOR Summary of this function goes here
%   Detailed explanation goes here


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

%%

cfg_Plot = PLOTPARAMETERS_cgg_plotPlotStyle;

X_Name_Size = cfg_Plot.X_Name_Size;
Y_Name_Size = cfg_Plot.Y_Name_Size;

Label_Size = cfg_Plot.Label_Size;
Line_Width = cfg_Plot.Line_Width;

%

InFigure=figure;
InFigure.Units="normalized";
InFigure.Position=[0,0,1,1];
InFigure.Units="inches";
InFigure.PaperUnits="inches";
PlotPaperSize=InFigure.Position;
PlotPaperSize(1:2)=[];
InFigure.PaperSize=PlotPaperSize;
% InFigure.Visible='off';

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
    
    p_AccuracyTraining=plot(1,0,'DisplayName','Training Accuracy','LineWidth',Line_Width);
    hold on
    p_AccuracyValidation=plot(1,0,'DisplayName','Validation Accuracy','LineWidth',Line_Width);
    p_MajorityClass=plot(1,0,'DisplayName','Majority Class','LineWidth',Line_Width);
    p_RandomChance=plot(1,0,'DisplayName','Random Chance','LineWidth',Line_Width);
    hold off

    box off
    legend([p_AccuracyTraining,p_AccuracyValidation,p_MajorityClass,...
        p_RandomChance],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Accuracy','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
    
    nexttile(Tiled_Plot,PlotSplit+1,[1,PlotSplit-InformationSpan]);
    
    p_LossTraining=plot(1,0,'DisplayName','Training Loss','LineWidth',Line_Width);
    hold on
    p_LossValidation=plot(1,0,'DisplayName','Validation Loss','LineWidth',Line_Width);
    hold off

    box off
    legend([p_LossTraining,p_LossValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
elseif NumLossPlots==1
    nexttile(Tiled_Plot,1,[1,PlotSplit-InformationSpan]);
    
    p_LossTraining=plot(1,0,'DisplayName','Training Loss','LineWidth',Line_Width);
    hold on
    p_LossValidation=plot(1,0,'DisplayName','Validation Loss','LineWidth',Line_Width);
    hold off

    box off
    legend([p_LossTraining,p_LossValidation],"Location","best");
    xlabel('Iteration','FontSize',X_Name_Size);
    ylabel('Loss','FontSize',Y_Name_Size);
    InFigure.CurrentAxes.XAxis.FontSize=Label_Size;
    InFigure.CurrentAxes.YAxis.FontSize=Label_Size;
end

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

Information_Display{Information_Display_Counter} = "\bfInformation\rm";
InformationValue_Display{Information_Display_Counter} = "";
IDX_Information = Information_Display_Counter;
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Workers";
IDX_Worker = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Execution Environment";
IDX_ExecutionEnvironment = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Learning Rate";
IDX_LearningRate = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Epoch";
IDX_Epoch = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;

Information_Display{Information_Display_Counter} = "Iteration";
IDX_Iteration = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;

if LogLoss
Information_Display{Information_Display_Counter} = "LossType";
IDX_LossType = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;
end

Information_Display{Information_Display_Counter} = "Loss";
IDX_Loss = Information_Display_Counter;
InformationValue_Display{Information_Display_Counter} = "NaN";
Information_Display_Counter = Information_Display_Counter + 1;


if WantKLLoss
    Information_Display{Information_Display_Counter} = "KL Loss";
    IDX_KL_Loss = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    Information_Display_Counter = Information_Display_Counter + 1;
end
if WantReconstructionLoss
    Information_Display{Information_Display_Counter} = "Reconstruction Loss";
    IDX_Reconstruction_Loss = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    Information_Display_Counter = Information_Display_Counter + 1;
end
if WantClassificationLoss
    Information_Display{Information_Display_Counter} = "Classification Loss";
    IDX_Classification_Loss = Information_Display_Counter;
    InformationValue_Display{Information_Display_Counter} = "NaN";
    Information_Display_Counter = Information_Display_Counter + 1;
end

% monitor.Status = "Configuring";
% monitor.Progress = 0;

executionEnvironment = "auto";

if LogLoss
LossType="Log";
end

if (executionEnvironment == "auto" && canUseGPU) || executionEnvironment == "gpu"
    ExecutionEnvironment="GPU";
else
    ExecutionEnvironment="CPU";
end


text(0,0.5, Information_Display,'Units','normalized');
text(0.5,0.5, InformationValue_Display,'Units','normalized');

InFigure=updateFigureText(InFigure,IDX_ExecutionEnvironment,ExecutionEnvironment);
% InFigure.Children.Children(1).Children(1).String{IDX_ExecutionEnvironment}= ExecutionEnvironment;

if LogLoss
    InFigure=updateFigureText(InFigure,IDX_LossType,LossType);
% InFigure.Children.Children(1).Children(1).String{IDX_LossType} = LossType;
end

%%



%%

monitor = InFigure;

drawnow;

    function InFigure = updateFigureText(InFigure,IDX,NewText)
        InFigure.Children.Children(1).Children(1).String{IDX}=NewText;
    end


end

