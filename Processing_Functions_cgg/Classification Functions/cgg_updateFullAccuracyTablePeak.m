function fixedTable = cgg_updateFullAccuracyTablePeak(FullTable,varargin)
%CGG_UPDATEFULLACCURACYTABLEPEAK Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');
if isfunction
TimeRange = CheckVararginPairs('TimeRange', [], varargin{:});
else
if ~(exist('TimeRange','var'))
TimeRange=[];
end
end

if isfunction
cfg_Encoder = CheckVararginPairs('cfg_Encoder', struct(), varargin{:});
else
if ~(exist('cfg_Encoder','var'))
cfg_Encoder=struct();
end
end
%%

fixedTable = FullTable;

%%

if ~isempty(TimeRange)
    if isfield(cfg_Encoder,'Time_Start') && ...
        isfield(cfg_Encoder,'SamplingRate') && ...
        isfield(cfg_Encoder,'DataWidth') && ...
        isfield(cfg_Encoder,'WindowStride') && ...
        isfield(cfg_Encoder,'Time_End')
Time = cgg_getTime(cfg_Encoder.Time_Start,cfg_Encoder.SamplingRate,...
    cfg_Encoder.DataWidth,cfg_Encoder.WindowStride,NaN,0,...
    'Time_End',cfg_Encoder.Time_End);
    end
else
    return
end


%% For each possible entry

for hidx = 1:height(fixedTable)
    AccuracyTable = fixedTable(hidx,:);

    if ~ismember(AccuracyTable.Properties.VariableNames,'Window Accuracy')
        continue
    end
this_Window_Accuracy = AccuracyTable.('Window Accuracy'){1};

if exist("Time","var") && ~isempty(TimeRange)
TimeRangeIndices = Time > min(TimeRange) & Time < max(TimeRange);
this_Window_Accuracy(:,~TimeRangeIndices) = [];
Peak_Accuracy_New = max(this_Window_Accuracy,[],2);
AccuracyTable.('Accuracy'){1} = Peak_Accuracy_New;
end

fixedTable(hidx,:) = AccuracyTable;


varNames = fixedTable.Properties.VariableNames;

    for i = 1:length(varNames)
        currentVar = fixedTable.(varNames{i});
        
        % If the variable is a cell array, check each cell for tables
        if iscell(currentVar)
            for j = 1:numel(currentVar)
                if istable(currentVar{j})
                    currentVar{j} = cgg_updateFullAccuracyTablePeak(currentVar{j}, varargin{:});
                end
            end
            fixedTable.(varNames{i}) = currentVar;
            
        % If the variable is directly a table, process it recursively
        elseif istable(currentVar)
            fixedTable.(varNames{i}) = cgg_updateFullAccuracyTablePeak(currentVar, varargin{:});
        end
    end

end

end

