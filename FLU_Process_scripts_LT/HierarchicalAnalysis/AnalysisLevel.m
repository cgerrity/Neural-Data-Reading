classdef AnalysisLevel
    %An AnalysisLevel object fully defines a level of analysis in a
    %hierarchy. 
    %For example, we might want to take the mean duration of fixations to targets on
    %the first five trials in each block, only for blocks where the subject
    %eventually passed an accuracy threshold of 80%, and only for subjects
    %who achieved this on at at least 75% of blocks.
    %This involves several distinct levels: fixations, trials, blocks, and
    %subjects. Each of these would have be defined as a unique analysis
    %level
    properties
        Name %string, solely for purposes of giving meaningful debug messages
        LevelDepth %integer, lower numbers indicate higher level in the hierarchy (e.g. subject might be 1, while fixation might be 5)
        Data %data table / matrix to be analyszed at this level
        DataSelector %Selector object (details given in Selector script, but in a nutshell selects rows from Data)
        DataProcessor %Processor object (details given in Processor script, but in a nutshell runs some function on rows of Data selected by DataSelector)
    end
    methods
        %check arguments to constructor are of right form
        function obj = AnalysisLevel(name, levelDepth, data, dataSelectorDetails, dataProcessorDetails)
            if ischar(name)
                obj.Name = name;
            else
                error('AnalysisLevel Name must be character vector.');
            end
            if isnumeric(levelDepth) && floor(levelDepth) == levelDepth
                obj.LevelDepth = levelDepth;
            else
                error(['AnalysisLevel LevelDepth for ' obj.Name ' must be integer.']);
            end
            if istable(data) || ismatrix(data)
                obj.Data = data;
            else
                error(['AnalysisLevel Data for ' obj.Name ' must be a 2D table or numeric array.']);
            end
            if iscell(dataSelectorDetails) && (length(dataSelectorDetails) == 3 || length(dataSelectorDetails) == 4)
                if ischar(dataSelectorDetails{1})
                    if isempty(find(strcmp({'all'}, dataSelectorDetails{1}), 1))
                        error('If first argument to Selector constructor is a string, it must be one of the following: "all".');
                    end
                elseif ~isa(dataSelectorDetails{1}, 'function_handle')
                    error(['First item in DataSelectorDetails for ' obj.Name ' must be a function handle.']);
                elseif ~iscell(dataSelectorDetails{2})
                    error(['Second item in DataSelectorDetails for ' obj.Name ' must be a cell.']);
%                 elseif istable(data)
%                     if ~ischar(dataSelectorDetails{3})
%                         error(['Third item in DataSelectorDetails for ' obj.Name ' must be a string if data is in table form.']);
%                     end
%                     if length(dataSelectorDetails) == 4
%                         if ~ischar(dataSelectorDetails{4}) 
%                             %technically this isn't right, as potentially 
%                             %lower level data could be in matrix while
%                             %upper level data is in table, or vice versa,
%                             %but fuck off
%                             error(['Fourth item in DataSelectorDetails for ' obj.Name ' must be a string if data is in table form.']);
%                         end
%                     end
%                 elseif ismatrix(data)
%                     if ~isnumeric(dataSelectorDetails{3}) || floor(dataSelectorDetails{3}) ~= dataSelectorDetails{3}
%                         error(['Third item in DataSelectorDetails for ' obj.Name ' must be an integer is data is in matrix form.'])
%                     end
%                     if length(dataSelectorDetails) == 4
%                         if ~isnumeric(dataSelectorDetails{4}) || floor(dataSelectorDetails{4}) ~= dataSelectorDetails{4}
%                             error(['Fourth item in DataSelectorDetails for ' obj.Name ' must be an integer is data is in matrix form.'])
%                         end
%                     end
                end
            else
                error(['AnalysisLevel DataSelectorDetails for ' obj.Name ' must be a cell with 3 or 4 elements.']);
            end
            obj.DataSelector = Selector(dataSelectorDetails{1}, data, dataSelectorDetails{2:end});
            
            if iscell(dataProcessorDetails) && (length(dataProcessorDetails) == 3)
                if ~isa(dataProcessorDetails{1},'function_handle')
                    error(['First item in DataProcessorDetails for ' obj.Name ' must be a function handle.']);
                end
                if ~iscell(dataProcessorDetails{2})
                    error(['Second item in DataProcessorDetails for ' obj.Name ' must be a cell array.']);
                end
                if ~isnumeric(dataProcessorDetails{3}) || floor(dataProcessorDetails{3}) ~= dataProcessorDetails{3}
                    error(['Third item in DataProcessorDetails for ' obj.Name ' must be an integer']);
                end
                
%                 processFunc, processArgs, outputSize)
            else
                error(['AnalysisLevel DataProcessorDetails for ' obj.Name ' must be a cell with 3 elements.']);
            end
            obj.DataProcessor = Processor(dataProcessorDetails{:});
        end
        
        function outputData = AnalyzeLevel(self, levelList, varargin)
            
            %initialize output data for current level
            nLevels = length(levelList) - (self.LevelDepth - 1);
            outputSize = zeros(1,nLevels);
            if nLevels > 1
                lowerLevelOutputSize = zeros(1,nLevels - 1);
            end
            for i = nLevels:-1:1
                outputSize(i) = levelList{i + self.LevelDepth - 1}.DataProcessor.OutputSize;
                if i > 1
                    lowerLevelOutputSize(i-1) = levelList{i + self.LevelDepth - 1}.DataProcessor.OutputSize;
                end
            end
            if length(outputSize) == 1
                outputData = nan(outputSize,1);
            else
                outputData = nan(outputSize);
            end
            if nLevels > 1
                if length(lowerLevelOutputSize) == 1
                    lowerLevelOutput = nan(1,lowerLevelOutputSize);
                else
                    lowerLevelOutput = nan(lowerLevelOutputSize);
                end
                    
            end
            
            %select appropriate data rows
            if self.LevelDepth == 1
                selection = self.DataSelector.Selection;
            else
                %if this is not the highest level of analysis, then previous
                %level's current selection should be incorporated as well
                if length(varargin) == 2
                    higherLevelSelectionColumnRef = varargin{1};
                    higherLevelCurrentValue = varargin{2};
                else
                    error(['AnalyzeLevel function for ' self.Name ' was passed inappropriate selection information.']);
                end
                
                %appropriate call to determine higher selection depends
                %on class of data and current higher selection value
                if istable(self.Data)
                    varRef = nan(1, length(higherLevelSelectionColumnRef));
                    for j = 1:length(higherLevelSelectionColumnRef)
                        try
                        varRef(j) = find(strcmp(self.Data.Properties.VariableNames, higherLevelSelectionColumnRef{j}));
                        catch
                            fred = 2;
                        end
                    end
%                     higherLevelSelectionColumns = self.Data.(higherLevelSelectionColumnRef{:});
                elseif ismatrix(self.Data)
                    varRef = higherLevelSelectionColumnRef;
%                     higherLevelSelectionColumns = self.Data(:,higherLevelSelectionColumnRef{:});
                end
                higherLevelSelectionColumns = self.Data(:,varRef);
                if istable(higherLevelSelectionColumns)
                    higherLevelSelectionColumns = table2array(higherLevelSelectionColumns);
                end
                
                if isnumeric(higherLevelCurrentValue)
                    higherSelection = ismember(higherLevelSelectionColumns, higherLevelCurrentValue, 'rows');
                elseif ischar(higherLevelCurrentValue)
                    higherSelection = ismember(higherLevelSelectionColumns, higherLevelCurrentValue, 'rows');
                end
                
                %combine current level selection with higher level
                %selection
                selection = self.DataSelector.Selection & higherSelection;
            end
            
            %
            if self.LevelDepth < length(levelList)
                if istable(self.Data)
                    varRef = nan(1,length(self.DataSelector.VarRefCurrentLevel));
                    for j = 1:length(self.DataSelector.VarRefCurrentLevel)
                        varRef(j) = find(strcmp(self.Data.Properties.VariableNames, self.DataSelector.VarRefCurrentLevel{j}));
                    end
                    dataForSelection = table2array(self.Data(:,varRef));
                elseif ismatrix(self.Data)
                    varRef = self.DataSelector.VarRefCurrentLevel;
                    dataForSelection = self.Data(:,varRef);
                end
%                 if istable(self.Data)
%                     temp = self.Data.(self.DataSelector.VarRefCurrentLevel{:});
%                     selectionValues = unique(temp(selection), 'rows', 'stable');
%                 elseif ismatrix(self.Data)
%                     selectionValues = unique(self.Data(selection,self.DataSelector.VarRefCurrentLevel{:}), 'rows', 'stable');
%                 end
                selectionValues = unique(dataForSelection(selection, :), 'rows', 'stable');
                %loop through all unique values at current level, obtain
                %lower level data
%                 nVals = length(selectionValues);
                nVals = size(selectionValues,1);
                lowerData = repmat(lowerLevelOutput, [ones(1,length(size(lowerLevelOutput))), nVals]);
                for i = 1:size(selectionValues,1)
                    if iscell(selectionValues)
                        currVal = selectionValues{i,:};
                    else
                        currVal = selectionValues(i,:);
                    end
                    S.subs = repmat({':'},1,ndims(lowerData));
                    if nVals > 1
                        S.subs{end} = i;
                    else
                        S.subs{1} = i;
                    end
                    S.type = '()';
                    try
                        lowerData = subsasgn(lowerData,S,AnalyzeLevel(levelList{self.LevelDepth+1}, levelList, self.DataSelector.VarRefLowerLevel, currVal));
                    catch
                        fred = 2;
                    end
                end
                %process all data from lower level
                func = self.DataProcessor.ProcessFunc;
                if isequal(func, @nanmean) || isequal(func, @nanstd) || isequal(func, @mean) || isequal(func, @std)
                    outputData = self.DataProcessor.RunProcessor(lowerData, length(levelList));
                else
                    outputData = self.DataProcessor.RunProcessor(lowerData);
                end
            else
                %process data from lowest level
                
                outputData = self.DataProcessor.RunProcessor(self.Data(selection,:));
            end
%             if size(outputData, ndims(outputData)) ~= self.DataProcessor.OutputSize
%                 error(['Ouput of DataProcessor for ' self.Name ' was ' num2str(size(outputData,1)) ' long, expected size of ' num2str(self.DataProcessor.OutputSize)]); 
%             end
        end
    end
end

    
