function finalOutput = HierarchicalAnalysis(varargin)

levelList = cell(length(varargin), 1);

for i = 1:length(varargin)
    levelList{i} = AnalysisLevel(varargin{i}{:});
end

finalOutput = levelList{1}.AnalyzeLevel(levelList);

% AnalysisLevel(name, levelDepth, data, dataSelectorDetails, dataProcessorDetails)