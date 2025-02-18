function aggregatedResult = cgg_getAllEncoderAccuracyTable(aggregatedResult,filePath,varargin)
%CGG_AGGREGATETABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

%%

% IsScaled = contains(MatchType,'Scaled');
% if IsScaled
%         MatchType_Calc = extractAfter(MatchType,'Scaled-');
%         if isempty(MatchType_Calc)
%             MatchType_Calc = extractAfter(MatchType,'Scaled_');
%         end
%         if isempty(MatchType_Calc)
%             MatchType_Calc = extractAfter(MatchType,'Scaled');
%         end
% end

%%
    % Read the file into a table
    EncodingParameters = ReadYaml(filePath,0,true);
    EncodingParameters = rmfield(EncodingParameters,'varargin');
    Fold = EncodingParameters.Fold;
    % disp('Fold');
    % disp(Fold)
    EncodingParameters = rmfield(EncodingParameters,'Fold');

    [FolderPath,~,~] = fileparts(filePath);
    CM_TablePathNameExt = fullfile(FolderPath,'CM_Table.mat');

    % disp(CM_TablePathNameExt);

    if isfile(CM_TablePathNameExt)
        m_CM_Table = matfile(CM_TablePathNameExt,"Writable",false);
        CM_Table = m_CM_Table.CM_Table;
    else
        return
    end

    IterationPathNameExt = fullfile(FolderPath,'CurrentIteration.mat');

    if isfile(IterationPathNameExt)
        m_Iteration= matfile(IterationPathNameExt,"Writable",false);
        Epoch = m_Iteration.Epoch;
    else
        return
    end

    % [ClassNames,~,~,~] = cgg_getClassesFromCMTable(CM_Table);
%     MostCommon = [];
%     RandomChance = [];
% 
%     if istable(aggregatedResult)
%         HasVariable = any(ismember(aggregatedResult.Properties.VariableNames,'MostCommon')) & ...
%             any(ismember(aggregatedResult.Properties.VariableNames,'RandomChance'));
%         if HasVariable
%             Folds = aggregatedResult.Fold;
%             MostCommon = aggregatedResult.MostCommon;
%             RandomChance = aggregatedResult.RandomChance;
% 
%             SelectRow = find(cellfun(@(x) any(x==Fold),Folds),1);
%             if ~isempty(SelectRow)
%             this_RowFoldIDX = Folds{SelectRow} == Fold;
%             MostCommon = MostCommon{SelectRow}(this_RowFoldIDX);
%             RandomChance = RandomChance{SelectRow}(this_RowFoldIDX);
%             end
%         end
%     end
% 
%     if isempty(MostCommon) && isempty(RandomChance)
%     [MostCommon,RandomChance] = ...
%         cgg_getBaselineAccuracyMeasures(CM_Table.TrueValue, ...
%         ClassNames,MatchType_Calc,IsQuaddle);
%     end
% 
%     [~,~,this_WindowAccuracy] = ...
% cgg_procConfusionMatrixWindowsFromTable(...
% CM_Table,ClassNames,...
% 'MatchType',MatchType,...
% 'IsQuaddle',IsQuaddle,'MostCommon',MostCommon,'RandomChance',RandomChance);

%         [~,~,this_WindowAccuracy] = ...
% cgg_procConfusionMatrixWindowsFromTable(...
% CM_Table,ClassNames,...
% 'MatchType',MatchType,...
% 'IsQuaddle',IsQuaddle);
% 
%     this_Accuracy = max(this_WindowAccuracy);
    this_Accuracy = Epoch;

    FieldNames = fieldnames(EncodingParameters);

    for fidx = 1:length(FieldNames)
        this_FieldName = FieldNames{fidx};
        this_Variable = EncodingParameters.(this_FieldName);
        this_Variable = cgg_convertArrayToString(this_Variable);
        EncodingParameters.(this_FieldName) = this_Variable;
    end

    EncodingParameters = struct2table(EncodingParameters,"AsArray",true);
    newTable = EncodingParameters;
    
    %% Aggregate the result by vertically concatenating the tables
    if isempty(aggregatedResult)
        % If this is the first file, the result is the first table
        aggregatedResult = newTable;
        aggregatedResult.Fold = {Fold};
        aggregatedResult.Accuracy = {this_Accuracy};
        % aggregatedResult.MostCommon = {MostCommon};
        % aggregatedResult.RandomChance = {RandomChance};
    else
        % Otherwise, append the new table to the existing one
        Current_Rows = height(aggregatedResult);
        % aggregatedResult_NoFold = removevars(aggregatedResult,'Fold');
        % aggregatedResult_NoFold = removevars(aggregatedResult,["Fold","Accuracy","MostCommon","RandomChance"]);
        aggregatedResult_NoFold = removevars(aggregatedResult,["Fold","Accuracy"]);
        [aggregatedResult_tmp,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        idx = idx==1;
        newTable = aggregatedResult_tmp(idx,:); % newtable with same variables as aggregate
        newTable(:,ismissing(newTable)) = {"Missing"};
        [~,~,idx] = outerjoin(aggregatedResult_NoFold, newTable,"MergeKeys",true);
        IsMatchNewFold = length(idx) == Current_Rows;
        idx = idx==1;
        % disp({IsMatchNewFold,Fold});
        %%
        if ~IsMatchNewFold
            [aggregatedResult,~,idx] = outerjoin(aggregatedResult, newTable,"MergeKeys",true);
            MissingAggregate = ismissing(aggregatedResult);
            for hidx = 1:height(aggregatedResult)
            aggregatedResult(hidx,MissingAggregate(hidx,:)) = {"Missing"};
            end
            idx = idx==1;
        end
        aggregatedResult{idx,"Fold"} = {[aggregatedResult{idx,"Fold"}{1}, Fold]};
        aggregatedResult{idx,"Accuracy"} = {[aggregatedResult{idx,"Accuracy"}{1}, this_Accuracy]};
        % aggregatedResult{idx,"MostCommon"} = {[aggregatedResult{idx,"MostCommon"}{1}, MostCommon]};
        % aggregatedResult{idx,"RandomChance"} = {[aggregatedResult{idx,"RandomChance"}{1}, RandomChance]};
    end
end

