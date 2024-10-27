function PlotFolder = cgg_constructPlotFolderName(PlotInformation)
%CGG_CONSTRUCTPLOTFOLDERNAME Summary of this function goes here
%   Detailed explanation goes here

if isfield(PlotInformation,'WantCoverage')
    WantCoverage = PlotInformation.WantCoverage;
else
    WantCoverage = false;
end


if isfield(PlotInformation,'NeighborhoodSize')
    NeighborhoodSize = PlotInformation.NeighborhoodSize;
else
    NeighborhoodSize = [];
end

PlotFolder = PlotInformation.PlotVariable;

if PlotInformation.WantSignificant
    PlotFolder = [PlotFolder ' ~ Significant'];
end

if PlotInformation.WantProportionSignificant
    PlotFolder = [PlotFolder ' ~ Proportion Significant'];
end

if PlotInformation.WantSplitPositiveNegative
    PlotFolder = [PlotFolder ' ~ Positive & Negative'];
end

if WantCoverage
    PlotFolder = [PlotFolder ' ~ Coverage'];
end

if PlotInformation.WantDifference
    PlotFolder = [PlotFolder ' ~ Difference'];
end

PlotFolder = [PlotFolder ' ~ ' PlotInformation.PlotType];

if ~isempty(NeighborhoodSize)
    NeighborhoodName = sprintf(' ~ Neighborhood - %d',NeighborhoodSize);
    PlotFolder = [PlotFolder NeighborhoodName];
end

% if ~isempty(PlotInformation.SignificanceMimimum)
%     SignificanceMimimumName = sprintf(' ~ Significance Mimimum - %f',PlotInformation.SignificanceMimimum);
%     PlotFolder = [PlotFolder SignificanceMimimumName];
% end

end

