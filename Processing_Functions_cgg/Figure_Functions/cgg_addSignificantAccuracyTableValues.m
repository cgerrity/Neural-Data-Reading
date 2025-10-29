function InTable = cgg_addSignificantAccuracyTableValues(InTable,AccuracyTable,SessionIDX,IsSignificant)
%CGG_ADDSIGNIFICANTACCURACYTABLEVALUES Summary of this function goes here
%   Detailed explanation goes here


Window_Accuracy = AccuracyTable.('Window Accuracy'){1};
Accuracy = AccuracyTable.('Accuracy'){1};
HasBlock = ismember("Block", AccuracyTable.Properties.VariableNames);

if IsSignificant
InTable.('Window Accuracy') = {[InTable.('Window Accuracy'){1};Window_Accuracy]};
InTable.('Accuracy') = {[InTable.('Accuracy'){1};Accuracy]};
InTable.('Session Number') = {[InTable.('Session Number'){1}; SessionIDX]};

if HasBlock
    WantAllAreas = true;
    Block = AccuracyTable.('Block'){1};
%%
    EachArea = InTable.("Not Present Areas"){1}.Properties.RowNames;
    [~,idx] = max(arrayfun(@(x) count(x, "-"),EachArea));
    EachArea = split(EachArea{idx},"-");
    AreaNames = Block.("Area Names");
    [~,idx] = max(cellfun(@numel, AreaNames));
    AllAreas = AreaNames{idx};
    RemovedNames = string(cellfun(@(x) join(x,"-"),AreaNames,"UniformOutput",false));
    PresentNames = cellfun(@(x) setdiff(AllAreas,x),AreaNames,"UniformOutput",false);
    NotPresentNames = string(cellfun(@(x) join(setdiff(EachArea,x),"-"),PresentNames,"UniformOutput",false));
    PresentNames = string(cellfun(@(x) join(x,"-"),PresentNames,"UniformOutput",false));
    PresentNames(PresentNames == "") = "None";
    NotPresentNames(NotPresentNames == "") = "None";
    AllAreasName = string(join(AllAreas,"-"));
    AllNotPresentEachArea = string(join(setdiff(EachArea,AllAreas),"-"));
    AllNotPresentEachArea(AllNotPresentEachArea == "") = "None";
%% Including All the areas regardless of how many probes per session
if WantAllAreas
NoneRemovedIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},"None");
InTable.("Removed Areas"){1}{NoneRemovedIDX,"Accuracy"}{1} = ...
    [InTable.("Removed Areas"){1}{NoneRemovedIDX,"Accuracy"}{1};Accuracy];
InTable.("Removed Areas"){1}{NoneRemovedIDX,"Window Accuracy"}{1} = ...
    [InTable.("Removed Areas"){1}{NoneRemovedIDX,"Window Accuracy"}{1};Window_Accuracy];

AllPresentIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},AllAreasName);
InTable.("Present Areas"){1}{AllPresentIDX,"Accuracy"}{1} = ...
    [InTable.("Present Areas"){1}{AllPresentIDX,"Accuracy"}{1};Accuracy];
InTable.("Present Areas"){1}{AllPresentIDX,"Window Accuracy"}{1} = ...
    [InTable.("Present Areas"){1}{AllPresentIDX,"Window Accuracy"}{1};Window_Accuracy];

NoneNotPresentIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},AllNotPresentEachArea);
InTable.("Not Present Areas"){1}{NoneNotPresentIDX,"Accuracy"}{1} = ...
    [InTable.("Not Present Areas"){1}{NoneNotPresentIDX,"Accuracy"}{1};Accuracy];
InTable.("Not Present Areas"){1}{NoneNotPresentIDX,"Window Accuracy"}{1} = ...
    [InTable.("Not Present Areas"){1}{NoneNotPresentIDX,"Window Accuracy"}{1};Window_Accuracy];
end
%%
for aidx = 1:length(AreaNames)
    this_BlockEntry = Block(aidx,:);
    this_RemovedName = RemovedNames(aidx);
    this_PresentName = PresentNames(aidx);
    this_NotPresentName = NotPresentNames(aidx);

    this_Accuracy = this_BlockEntry.('Accuracy'){1};
    this_Window_Accuracy = this_BlockEntry.('Window Accuracy'){1};

    %%
    RemovedIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},this_RemovedName);
InTable.("Removed Areas"){1}{RemovedIDX,"Accuracy"}{1} = ...
    [InTable.("Removed Areas"){1}{RemovedIDX,"Accuracy"}{1};this_Accuracy];
InTable.("Removed Areas"){1}{RemovedIDX,"Window Accuracy"}{1} = ...
    [InTable.("Removed Areas"){1}{RemovedIDX,"Window Accuracy"}{1};this_Window_Accuracy];

    PresentIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},this_PresentName);
InTable.("Present Areas"){1}{PresentIDX,"Accuracy"}{1} = ...
    [InTable.("Present Areas"){1}{PresentIDX,"Accuracy"}{1};this_Accuracy];
InTable.("Present Areas"){1}{PresentIDX,"Window Accuracy"}{1} = ...
    [InTable.("Present Areas"){1}{PresentIDX,"Window Accuracy"}{1};this_Window_Accuracy];

    NotPresentIDX = strcmp(InTable.("Removed Areas"){1}{:,"Area Names"},this_NotPresentName);
InTable.("Not Present Areas"){1}{NotPresentIDX,"Accuracy"}{1} = ...
    [InTable.("Not Present Areas"){1}{NotPresentIDX,"Accuracy"}{1};this_Accuracy];
InTable.("Not Present Areas"){1}{NotPresentIDX,"Window Accuracy"}{1} = ...
    [InTable.("Not Present Areas"){1}{NotPresentIDX,"Window Accuracy"}{1};this_Window_Accuracy];
end
%%

end

end

end

