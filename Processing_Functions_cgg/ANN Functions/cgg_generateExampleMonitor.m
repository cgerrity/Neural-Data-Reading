classdef cgg_generateExampleMonitor < handle
    %CGG_GENERATEEXAMPLEMONITOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Figure
        PlotTable
        SaveDir
        SaveTerm
    end
    
    methods
        function monitor = cgg_generateExampleMonitor(varargin)
            %CGG_GENERATEEXAMPLEMONITOR Construct an instance of this class
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

monitor.SaveDir = SaveDir;
monitor.SaveTerm = SaveTerm;

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
                'Example-Monitor_Iteration-' ...
                InSaveTerm '.pdf'];
            saveas(monitor.Figure,SavePathNameExt);
        end
    end
end

