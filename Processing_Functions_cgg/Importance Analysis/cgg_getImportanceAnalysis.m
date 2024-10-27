function [IA_Table,RemovalTable,TablesMatch] = cgg_getImportanceAnalysis(IAPathNameExt)
%CGG_GETIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

PauseMaximum = 10;

[HasIA_Table,HasRemovalTable] = cgg_checkImportanceAnalysis(IAPathNameExt);

IA_Table = [];
RemovalTable = [];
TablesMatch = true; 
% Default should be true because if one does not exist then they match
% because it will be used to make the other
% disp(IAPathNameExt)

% if isfile(IAPathNameExt)
% m_IA_Table = matfile(IAPathNameExt,"Writable",false);
% end
% 
% if HasIA_Table
% IA_Table = m_IA_Table.IA_Table;
% end
% if HasRemovalTable
% RemovalTable = m_IA_Table.RemovalTable;
% end

try
    if isfile(IAPathNameExt)
    m_IA_Table = matfile(IAPathNameExt,"Writable",false);
    end
    
    if HasIA_Table
    IA_Table = m_IA_Table.IA_Table;
    end
    if HasRemovalTable
    RemovalTable = m_IA_Table.RemovalTable;
    end
catch
  try
      pause(randi(PauseMaximum));
      if isfile(IAPathNameExt)
      m_IA_Table = matfile(IAPathNameExt,"Writable",false);
      end
    
      if HasIA_Table
      IA_Table = m_IA_Table.IA_Table;
      end
      if HasRemovalTable
      RemovalTable = m_IA_Table.RemovalTable;
      end
  catch
      pause(randi(PauseMaximum));
      if isfile(IAPathNameExt)
      m_IA_Table = matfile(IAPathNameExt,"Writable",false);
      end
    
      if HasIA_Table
      IA_Table = m_IA_Table.IA_Table;
      end
      if HasRemovalTable
      RemovalTable = m_IA_Table.RemovalTable;
      end
  end
end

% if HasRemovalTable && HasIA_Table
% % This is in case there are multiple instances running and they set
% % different values to the removal table while the IA_Table has already
% % been produced
% TablesMatch = AreTablesSameFunc(RemovalTable,IA_Table);
% end


end

