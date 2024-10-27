function RemovalTable = cgg_getRemovalTable(IAPathNameExt)
%CGG_GETIMPORTANCEANALYSIS Summary of this function goes here
%   Detailed explanation goes here

PauseMaximum = 10;

[~,HasRemovalTable] = cgg_checkImportanceAnalysis(IAPathNameExt);

RemovalTable = [];
% Default should be true because if one does not exist then they match
% because it will be used to make the other
% disp(IAPathNameExt)

try
if isfile(IAPathNameExt)
m_IA_Table = matfile(IAPathNameExt,"Writable",false);
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

  if HasRemovalTable
  RemovalTable = m_IA_Table.RemovalTable;
  end
  catch
  pause(randi(PauseMaximum));
  if isfile(IAPathNameExt)
  m_IA_Table = matfile(IAPathNameExt,"Writable",false);
  end

  if HasRemovalTable
  RemovalTable = m_IA_Table.RemovalTable;
  end
  end
end


end

