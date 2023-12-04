function OutTable = cgg_procRenameTableVariables(InTable,NamePattern,NewPattern)
%CGG_PROCRENAMETABLEVARIABLES Summary of this function goes here
%   Detailed explanation goes here


VariableNames=InTable.Properties.VariableNames;
NameIndices=contains(VariableNames,NamePattern);
Names=VariableNames(NameIndices);

NumNames=numel(Names);

NewName=split(sprintf([char(NewPattern), '@'],Names{:}),'@');
NewName(NumNames+1)=[];

OutTable = renamevars(InTable,Names, NewName);

end