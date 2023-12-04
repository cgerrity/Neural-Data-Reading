function [OutTable] = cgg_gatherConfusionMatrixTablesOverIterations(CM_Table,varargin)
%CGG_GATHERCONFUSIONMATRIXTABLESOVERITERATIONS Summary of this function goes here
%   Detailed explanation goes here

% isfunction=exist('varargin','var');

% if isfunction
% AdditionalTable = CheckVararginPairs('AdditionalTable', false, varargin{:});
% else
% if ~(exist('AdditionalTable','var'))
% AdditionalTable=false;
% end
% end

OutTable=table();

if iscell(CM_Table)

    NumTables=numel(CM_Table);

    for tidx=1:NumTables
        this_CM_Table=CM_Table{tidx};
        this_NewPattern=string(['%s',sprintf('_Iter%d',tidx)]);
        this_CM_Table = cgg_procRenameTableVariables(this_CM_Table,"Window",this_NewPattern);
        if tidx==1
        OutTable=this_CM_Table;
        else
        OutTable=outerjoin(OutTable,this_CM_Table,'Keys',{'DataNumber','TrueValue','DataNumber','TrueValue'},'MergeKeys',true);
        end
    end

end
% %%
% if istable(CM_Table)
% 
%     this_CM_Table=CM_Table;
% 
%     hasIterationColumn = any(strcmp(...
%         this_CM_Table.Properties.VariableNames,'IterationNumber'));
%     if ~hasIterationColumn
%         this_CM_Table.IterationNumber(:)=1;
%     end
% 
%     OutTable=[OutTable;this_CM_Table];
% 
%     CurrentIteration=max(this_CM_Table.IterationNumber);
% 
%     if istable(AdditionalTable)
%         hasIterationColumnAdditional = any(strcmp(...
%             AdditionalTable.Properties.VariableNames,'IterationNumber'));
%         if ~hasIterationColumnAdditional
%         AdditionalTable.IterationNumber=CurrentIteration+1;
%         end
%         OutTable=[OutTable;AdditionalTable];
%     end
% end

%%
% IterationValues=unique(OutTable.IterationNumber,'stable');
% IterationNames = arrayfun(@(x) sprintf('Iteration_%d',x),IterationValues,'UniformOutput',false);

VariableNames=OutTable.Properties.VariableNames;
WindowIndices=contains(VariableNames,'Window');
WindowNames = extractBefore(VariableNames(WindowIndices),"_Iter");
WindowNames=unique(WindowNames,'stable');

IterationValues = unique(extractAfter(VariableNames(WindowIndices),"_Iter"),'stable');
IterationValues = cellfun(@(x) str2double(x),IterationValues);
IterationNames = compose('Iteration_%d',IterationValues);


NumWindows=numel(WindowNames);

% evalc('OutTable=unstack(OutTable,WindowIndices,''IterationNumber'');');

% OutTable=outerjoin(OutTable,this_CM_Table_2,'Keys',{'DataNumber','TrueValue','DataNumber','TrueValue'},'MergeKeys',true);

for widx=1:NumWindows
OutVariableNames=OutTable.Properties.VariableNames;
this_WindowName=[WindowNames{widx},'_'];
this_WindowIndices=contains(OutVariableNames,this_WindowName);

OutTable=mergevars(OutTable,this_WindowIndices,...
               "NewVariableName",WindowNames{widx},"MergeAsTable",true);

OutTable.(WindowNames{widx}).Properties.VariableNames=IterationNames;

end


end

