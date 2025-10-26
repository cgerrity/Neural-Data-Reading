function FilteredOutput = cgg_procFilterIdentifiersTable(Identifiers_Table,TrialFilter,TrialFilter_Value,Func)
%CGG_PROCFILTERIDENTIFIERSTABLEFUNCTION Summary of this function goes here
%   Detailed explanation goes here

FilteredOutput = [];

if all(~strcmp(TrialFilter,'All') & ~strcmp(TrialFilter,'Target Feature'))

DistributionVariable_Table=Identifiers_Table(:,TrialFilter);

if isMATLABReleaseOlderThan("R2024b")
VariableType = string(varfun(@class,DistributionVariable_Table,'OutputFormat','cell'));
else
VariableType = DistributionVariable_Table.Properties.VariableTypes;
end

if any(strcmp(VariableType,"cell"))
    FilteredOutput = cell(1,length(TrialFilter));
    for tidx = 1:size(DistributionVariable_Table,2)
        this_Var = DistributionVariable_Table{:,tidx};
        if strcmp(VariableType{tidx},"cell")
            % FilteredOutput{tidx} = unique([this_Var{:}]);
            FilteredOutput{tidx} = Func.Cell(this_Var,TrialFilter_Value);
        else
            % FilteredOutput{tidx} = unique(this_Var);
            FilteredOutput{tidx} = Func.Double(this_Var,TrialFilter_Value);
        end
    end
    FilteredOutput = Func.CellCombine(FilteredOutput);
else

    FilteredOutput = Func.Default(DistributionVariable_Table,TrialFilter_Value);
% FilteredOutput=unique(DistributionVariable_Table,'rows');
end


end

end

