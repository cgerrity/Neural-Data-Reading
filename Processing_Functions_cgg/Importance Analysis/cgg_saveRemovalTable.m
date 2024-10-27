function cgg_saveRemovalTable(RemovalTable,Folds,EpochDir,RemovalType,SessionName,SaveTerm,varargin)
%CGG_SAVEREMOVALTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
ResetAnalysis = CheckVararginPairs('ResetAnalysis', false, varargin{:});
else
if ~(exist('ResetAnalysis','var'))
ResetAnalysis=false;
end
end

NumFolds = length(Folds);

if ~iscell(RemovalTable)
RemovalTable = repmat({RemovalTable},[NumFolds,1]);
end

IANameExt = sprintf('IA_Table%s.mat',SaveTerm);

for fidx = 1:NumFolds
    Fold = Folds(fidx);
    IAPathNameExt = fullfile(EpochDir,'Analysis', ...
        'Importance Analysis',RemovalType,sprintf('Fold %d',Fold), ...
        SessionName,IANameExt);
    IA_Table = [];
    this_RemovalTable = RemovalTable{Fold};
    HasIA_Table = false;
    if isfile(IAPathNameExt)
        m_IA_Table = matfile(IAPathNameExt,"Writable",false);
        HasIA_Table = any(ismember(who(m_IA_Table),'IA_Table'));
        HasRemovalTable = any(ismember(who(m_IA_Table),'RemovalTable'));
            if HasIA_Table
            IA_Table = m_IA_Table.IA_Table;
            end
            if HasRemovalTable && ~ResetAnalysis
                continue
            end
    end

if ResetAnalysis
IAVariablesName = {'RemovalTable'};
IAVariables = {this_RemovalTable};
elseif HasIA_Table
IAVariablesName = {'IA_Table','RemovalTable'};
IAVariables = {IA_Table,this_RemovalTable};
else
IAVariablesName = {'RemovalTable'};
IAVariables = {this_RemovalTable};
end

cgg_saveVariableUsingMatfile(IAVariables,IAVariablesName,IAPathNameExt);

end


end

