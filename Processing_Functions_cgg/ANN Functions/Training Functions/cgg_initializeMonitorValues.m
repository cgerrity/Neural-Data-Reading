function Monitor_Values = cgg_initializeMonitorValues(Monitor_Values,DataStore,DataFormat,IsQuaddle,cfg_Monitor,PartitionType)
%CGG_INITIALIZEMONITORVALUES Summary of this function goes here
%   Detailed explanation goes here

if isempty(Monitor_Values)
Monitor_Values = struct();
end

if ~isfield(Monitor_Values,'NumReconstructionMonitorExamples')
NumReconstructionMonitorExamples = 10;
Monitor_Values.NumReconstructionMonitorExamples = NumReconstructionMonitorExamples;
end

if ~isfield(Monitor_Values,'ClassNames')
[ClassNames,~,~,~] = cgg_getClassesFromDataStore(DataStore);
Monitor_Values.ClassNames = ClassNames;
end

NumDisplayExamples=10;

Mbq_Display = minibatchqueue(shuffle(DataStore),...
    MiniBatchSize=NumDisplayExamples,...
    MiniBatchFormat=DataFormat);

this_FieldName_Mbq_Display = sprintf('Mbq_Display_%s',PartitionType);

Monitor_Values.(this_FieldName_Mbq_Display) = Mbq_Display;

% [X,T] = next(Mbq_Display);
% 
% this_FieldName_T_Classification = sprintf('T_Classification_%s',PartitionType);
% this_FieldName_T_Reconstruction = sprintf('T_Reconstruction_%s',PartitionType);
% 
% Monitor_Values.(this_FieldName_T_Classification) = T;
% Monitor_Values.(this_FieldName_T_Reconstruction) = X;

%%
TargetDataStore=DataStore.UnderlyingDatastores{2};
T=[];
% T=gather(tall(TargetDataStore));
evalc('T=gather(tall(TargetDataStore));');

if iscell(T)
if isnumeric(T{1})
    [Dim1,Dim2]=size(T{1});
    [Dim3,Dim4]=size(T);
if (Dim1>1&&Dim3>1)||(Dim2>1&&Dim4>1)
    T=T';
end
    T=cell2mat(T);
    [Dim1,Dim2]=size(T);
if Dim1<Dim2
    T=T';
end
end
end
TrueValue=T;
%%

% NumDataStore = numpartitions(DataStore);
% 
% Mbq = minibatchqueue(DataStore,...
%     MiniBatchSize=100,...
%     MiniBatchFormat=DataFormat);
% 
% T = cell(1,NumDataStore);
% 
% parfor didx = 1:NumDataStore
%     [~,this_T,~] = next(Mbq);
% T{didx} = this_T;
% end
% 
% [~,T,~] = next(Mbq);
% 
% TrueValue=double(extractdata(T)');

AccuracyMeasures = cfg_Monitor.AccuracyMeasures;

for midx = 1:length(AccuracyMeasures)
    MatchType = AccuracyMeasures{midx};
    MatchType_Calc = MatchType;
    IsScaled = contains(MatchType,'Scaled');
    if IsScaled
        MatchType_Calc = extractAfter(MatchType,'Scaled-');
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled_');
        end
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled');
        end
    end
    this_FieldName_IsScaled = sprintf('IsScaled_%s_%s',MatchType,PartitionType);
    Monitor_Values.(this_FieldName_IsScaled) = IsScaled;

[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(TrueValue,Monitor_Values.ClassNames,MatchType_Calc,IsQuaddle);
    this_FieldName_MostCommon = sprintf('MostCommon_%s_%s',MatchType,PartitionType);
    this_FieldName_MajorityClass = sprintf('majorityclass_%s_%s',MatchType,PartitionType);
    this_FieldName_RandomChance = sprintf('RandomChance_%s_%s',MatchType,PartitionType);
    this_FieldName_randomchance = sprintf('randomchance_%s_%s',MatchType,PartitionType);
    this_FieldName_Stratified = sprintf('Stratified_%s_%s',MatchType,PartitionType);
    this_FieldName_stratified = sprintf('stratified_%s_%s',MatchType,PartitionType);

    Monitor_Values.(this_FieldName_MostCommon) = MostCommon;
    Monitor_Values.(this_FieldName_MajorityClass) = MostCommon;
    Monitor_Values.(this_FieldName_RandomChance) = RandomChance;
    Monitor_Values.(this_FieldName_randomchance) = RandomChance;
    Monitor_Values.(this_FieldName_Stratified) = Stratified;
    Monitor_Values.(this_FieldName_stratified) = Stratified;

    if midx == 1
    this_FieldName_OptimalMostCommon = sprintf('MostCommon_%s_%s','Optimal',PartitionType);
    this_FieldName_OptimalRandomChance = sprintf('RandomChance_%s_%s','Optimal',PartitionType);
    this_FieldName_OptimalStratified = sprintf('Stratified_%s_%s','Optimal',PartitionType);
    Monitor_Values.OptimalAccuracyMeasure = MatchType;
    Monitor_Values.(this_FieldName_OptimalMostCommon) = MostCommon;
    Monitor_Values.(this_FieldName_OptimalRandomChance) = RandomChance;
    Monitor_Values.(this_FieldName_OptimalStratified) = Stratified;
    this_FieldName_OptimalIsScaled = sprintf('IsScaled_%s_%s','Optimal',PartitionType);
    Monitor_Values.(this_FieldName_OptimalIsScaled) = IsScaled;
    end

end

Monitor_Values.IsQuaddle = IsQuaddle;
Monitor_Values.MaximumValidationAccuracy = -Inf;
Monitor_Values.MinimumValidationLoss = Inf;

%%

end

