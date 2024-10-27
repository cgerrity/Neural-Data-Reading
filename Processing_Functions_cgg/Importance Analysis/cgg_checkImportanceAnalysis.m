function [HasIA_Table,HasRemovalTable] = cgg_checkImportanceAnalysis(IAPathNameExt)
%CGG_CHECKIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

HasIA_Table = false;
HasRemovalTable = false;
PauseMaximum = 10;

if isfile(IAPathNameExt)
    try
        m_IA_Table = matfile(IAPathNameExt,"Writable",false);
        HasIA_Table = any(ismember(who(m_IA_Table),'IA_Table'));
        HasRemovalTable = any(ismember(who(m_IA_Table),'RemovalTable'));
    catch
        try
            pause(randi(PauseMaximum));
            m_IA_Table = matfile(IAPathNameExt,"Writable",false);
            HasIA_Table = any(ismember(who(m_IA_Table),'IA_Table'));
            HasRemovalTable = any(ismember(who(m_IA_Table),'RemovalTable'));
        catch
            pause(randi(PauseMaximum));
            m_IA_Table = matfile(IAPathNameExt,"Writable",false);
            HasIA_Table = any(ismember(who(m_IA_Table),'IA_Table'));
            HasRemovalTable = any(ismember(who(m_IA_Table),'RemovalTable'));
        end
    end
end

end

