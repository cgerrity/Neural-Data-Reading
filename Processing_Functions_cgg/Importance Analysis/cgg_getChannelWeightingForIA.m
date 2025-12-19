function [Weighting,FullWeightTable] = cgg_getChannelWeightingForIA(Block,NumFolds,SelectRow)
%CGG_GETCHANNELWEIGHTINGFORIA Summary of this function goes here
%   Detailed explanation goes here

    NumberRemovedTable = Block.("Removal Counts");
    ChannelCountPerArea = max(NumberRemovedTable,[],1);
    NumberPresentTable = ChannelCountPerArea-NumberRemovedTable;
    FullContributionTable = [NumberPresentTable;ChannelCountPerArea];
    FullWeightTable = FullContributionTable./sum(FullContributionTable{:,:},2);
    FullWeightTable = FullWeightTable./sum(FullWeightTable{:,:},1,"omitnan");

    if SelectRow == 0
    % Weighting = ChannelCountPerArea./sum(ChannelCountPerArea{:,:},2);
    CountTable = ChannelCountPerArea;
    FullWeightTable = FullWeightTable(end,:);
    else
    % Weighting = NumberPresentTable./sum(NumberPresentTable{:,:},2);
    % Weighting = Weighting(SelectRow,:);
    CountTable = NumberPresentTable(SelectRow,:);
    FullWeightTable = FullWeightTable(SelectRow,:);
    end
    Weighting = CountTable./sum(CountTable{:,:},2);
    %%
    Weighting = repmat(Weighting,[NumFolds,1]);
    CountTable = repmat(CountTable,[NumFolds,1]);
    WeightingNames = Weighting.Properties.VariableNames;
    CountTableNames = CountTable.Properties.VariableNames;
    WeightingNames = compose("%s%s",string(WeightingNames)',repmat(" Weight",[length(WeightingNames),1]));
    Weighting = splitvars(table(num2cell(Weighting{:,:},1)));
    CountTable = splitvars(table(num2cell(CountTable{:,:},1)));
    Weighting.Properties.VariableNames = WeightingNames;
    CountTable.Properties.VariableNames = CountTableNames;
    Weighting = [Weighting, CountTable];
end

