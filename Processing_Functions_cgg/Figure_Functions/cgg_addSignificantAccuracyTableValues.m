function OutTable = cgg_addSignificantAccuracyTableValues(InTable,AccuracyTable,SessionIDX,IsSignificant)
%CGG_ADDSIGNIFICANTACCURACYTABLEVALUES Summary of this function goes here
%   Detailed explanation goes here

OutTable = InTable;

Window_Accuracy = AccuracyTable.('Window Accuracy'){1};
Accuracy = AccuracyTable.('Accuracy'){1};
HasBlock = any(ismember("Block", AccuracyTable.Properties.VariableNames));
HasLabel = any(ismember("Label Table", AccuracyTable.Properties.VariableNames));
HasClass = any(ismember("Class Table", AccuracyTable.Properties.VariableNames));

if IsSignificant
OutTable.('Window Accuracy') = {[OutTable.('Window Accuracy'){1};Window_Accuracy]};
OutTable.('Accuracy') = {[OutTable.('Accuracy'){1};Accuracy]};
OutTable.('Session Number') = {[OutTable.('Session Number'){1}; SessionIDX]};

if HasLabel
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Label Table","Accuracy",'IncludeNaNValues',true);
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Label Table","Window Accuracy",'IncludeNaNValues',true);
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Label Table","Session Number",'NonTableTerm',SessionIDX,'IncludeNaNValues',false);
end
if HasClass
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Class Table","Accuracy",'IncludeNaNValues',true);
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Class Table","Window Accuracy",'IncludeNaNValues',true);
    OutTable = cgg_addCorrespondingVariablesToTable(OutTable,AccuracyTable,"Class Table","Session Number",'NonTableTerm',SessionIDX,'IncludeNaNValues',false);
end

if HasBlock
    WantAllAreas = true;
    %%
    NumFolds = length(Accuracy);
    Block = AccuracyTable.('Block'){1};
    % NumberRemovedTable = Block.("Removal Counts");
    % ChannelCountPerArea = max(NumberRemovedTable,[],1);
    % NumberPresentTable = ChannelCountPerArea-NumberRemovedTable;
    % Weighting = ChannelCountPerArea./sum(ChannelCountPerArea{:,:},2);
    % Weighting = repmat(Weighting,[NumFolds,1]);
    % this_WeightingNames = Weighting.Properties.VariableNames;
    % Weighting = splitvars(table(num2cell(Weighting{:,:},1)));
    % Weighting.Properties.VariableNames = this_WeightingNames;
    [Weighting,~] = cgg_getChannelWeightingForIA(Block,NumFolds,0);
%%
    EachArea = OutTable.("Not Present Areas"){1}.Properties.RowNames;
    WantBlockSingleArea = ~any(contains(EachArea,"None"));
    AreaNames = Block.("Area Names");
    if WantBlockSingleArea
        [Weighting,FullWeighting] = cgg_getChannelWeightingForIA(Block,NumFolds,0);

        for aaidx = 1:length(EachArea)
            this_Area = EachArea{aaidx};
            this_AreaAccuracy = Accuracy.*FullWeighting.(this_Area);
            this_AreaWindow_Accuracy = Window_Accuracy.*FullWeighting.(this_Area);
            AreaIsNaN = isnan(FullWeighting.(this_Area));
        for aidx = 1:length(AreaNames)
            this_BlockEntry = Block(aidx,:);
        
            [~,this_FullWeighting] = cgg_getChannelWeightingForIA(Block,NumFolds,aidx);
            this_Accuracy = this_BlockEntry.('Accuracy'){1};
            this_Window_Accuracy = this_BlockEntry.('Window Accuracy'){1};
            this_Accuracy = this_Accuracy.*this_FullWeighting.(this_Area);
            this_Window_Accuracy = this_Window_Accuracy.*this_FullWeighting.(this_Area);

            if ~AreaIsNaN && isnan(this_FullWeighting.(this_Area))
                this_Accuracy = zeros(size(this_Accuracy));
                this_Window_Accuracy = zeros(size(this_Window_Accuracy));
            end
            this_AreaAccuracy = this_AreaAccuracy + this_Accuracy;
            this_AreaWindow_Accuracy = this_AreaWindow_Accuracy + this_Window_Accuracy;
        end

        OutTable = cgg_getBlockAccuracyAdditionSimplified(OutTable,...
            this_Area,this_Area,this_Area,...
            this_AreaAccuracy,this_AreaWindow_Accuracy,SessionIDX,Weighting);


        end
    else
    [~,idx] = max(arrayfun(@(x) count(x, "-"),EachArea));
    EachArea = split(EachArea{idx},"-");
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

OutTable = cgg_getBlockAccuracyAdditionSimplified(OutTable,...
    "None",AllAreasName,AllNotPresentEachArea,Accuracy,Window_Accuracy,...
    SessionIDX,Weighting);
end
%%
for aidx = 1:length(AreaNames)
    this_BlockEntry = Block(aidx,:);
    this_RemovedName = RemovedNames(aidx);
    this_PresentName = PresentNames(aidx);
    this_NotPresentName = NotPresentNames(aidx);

    this_Accuracy = this_BlockEntry.('Accuracy'){1};
    this_Window_Accuracy = this_BlockEntry.('Window Accuracy'){1};
    Weighting = cgg_getChannelWeightingForIA(Block,NumFolds,aidx);
    %%

    OutTable = cgg_getBlockAccuracyAdditionSimplified(OutTable,...
    this_RemovedName,this_PresentName,this_NotPresentName,...
    this_Accuracy,this_Window_Accuracy,SessionIDX,Weighting);

end
    end
%%

end

end

end

