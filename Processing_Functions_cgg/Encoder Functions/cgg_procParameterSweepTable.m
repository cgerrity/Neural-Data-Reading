function [SweepAccuracy,SweepWindowAccuracy,SweepAllNames,RunTable,BestRunTable] = cgg_procParameterSweepTable(SweepName,SweepNameIgnore,cfg,varargin)
%CGG_PROCPARAMETERSWEEPTABLE Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
MatchType = CheckVararginPairs('MatchType', 'Scaled-BalancedAccuracy', varargin{:});
else
if ~(exist('MatchType','var'))
MatchType='Scaled-BalancedAccuracy';
end
end

if isfunction
IsQuaddle = CheckVararginPairs('IsQuaddle', true, varargin{:});
else
if ~(exist('IsQuaddle','var'))
IsQuaddle=true;
end
end

if isfunction
NumIterRand = CheckVararginPairs('NumIterRand', 2000, varargin{:});
else
if ~(exist('NumIterRand','var'))
NumIterRand=2000;
end
end

if isfunction
RunTable = CheckVararginPairs('RunTable', [], varargin{:});
else
if ~(exist('RunTable','var'))
RunTable=[];
end
end

if isfunction
BestRunTable = CheckVararginPairs('BestRunTable', [], varargin{:});
else
if ~(exist('BestRunTable','var'))
BestRunTable=[];
end
end

if isfunction
WantFinished = CheckVararginPairs('WantFinished', false, varargin{:});
else
if ~(exist('WantFinished','var'))
WantFinished=false;
end
end

if isfunction
WantValidation = CheckVararginPairs('WantValidation', false, varargin{:});
else
if ~(exist('WantValidation','var'))
WantValidation=false;
end
end


cfg_Encoder_Best = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2();

%%

IsScaled = contains(MatchType,'Scaled');
if IsScaled
        MatchType_Calc = extractAfter(MatchType,'Scaled-');
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled_');
        end
        if isempty(MatchType_Calc)
            MatchType_Calc = extractAfter(MatchType,'Scaled');
        end
else
    MatchType_Calc = MatchType;
end
%%
Target = cfg_Encoder_Best.Target;
EncodingParametersPath = cgg_getDirectory(cfg.ResultsDir,'Encoding');
% EncodingParametersPath = fullfile(EncodingParametersPath,Target,'Fold_1');
EncoderParametersFunc = @(x,y) cgg_getAllEncoderCMTable(x,y,...
    'WantFinished',WantFinished,'WantValidation',WantValidation);

if isempty(RunTable)
EncoderParameters_CM_Table = cgg_procDirectorySearchAndApply(EncodingParametersPath, ...
    'EncodingParameters.yaml', EncoderParametersFunc);
RunTable = EncoderParameters_CM_Table;
else
    EncoderParameters_CM_Table = RunTable;
end

%%
cfg_Encoder_Best = PARAMETERS_OPTIMAL_cgg_runAutoEncoder_v2();
EncodingParametersPath_Fold1 = fullfile(EncodingParametersPath,Target,'Fold_1');
cfg_Best = cgg_generateEncoderSubFolders_v2(EncodingParametersPath_Fold1,cfg_Encoder_Best);
Encoding_Best_ParametersPath = cgg_getDirectory(cfg_Best,'Classifier');
% BestPath =  extractBefore(cfg_Best.EncodingDir.path,Target);
BestNameExt = fullfile(extractAfter(Encoding_Best_ParametersPath,'Fold_1'),'EncodingParameters.yaml');
BestPath =  extractBefore(Encoding_Best_ParametersPath,'Fold_1');
if isempty(BestRunTable)
EncoderParameters_Best = cgg_procDirectorySearchAndApply(BestPath, ...
    BestNameExt, EncoderParametersFunc);
BestRunTable = EncoderParameters_Best;
else
   EncoderParameters_Best  = BestRunTable;
end

%%
% isempty(SweepNameIgnore)
this_SweepNameIgnore = [SweepNameIgnore, SweepName];
%%

Table_Best = removevars(EncoderParameters_Best,["Fold","CM_Table"]);
Table_Sweep = removevars(EncoderParameters_CM_Table,["Fold","CM_Table"]);

% Table_Sweep_Keep = Table_Sweep{:,SweepName};
Table_Best_Keep = Table_Best{:,SweepName};

Table_Sweep_Ignore = removevars(Table_Sweep,this_SweepNameIgnore);
Table_Best = removevars(Table_Best,this_SweepNameIgnore);

MatchIDX_Ignore = ismember(Table_Sweep_Ignore,Table_Best);
% MatchIDX_tmp = all(ismember(Table_Sweep_tmp,Table_Best_tmp),2);

SweepTable = EncoderParameters_CM_Table(MatchIDX_Ignore,:);
% SweepTable_tmp = EncoderParameters_CM_Table(MatchIDX_tmp,:);
% SweepAllNames = SweepTable{:,SweepNameIgnore};
MatchBestIDX = ismember(removevars(SweepTable,["Fold","CM_Table"]),removevars(EncoderParameters_Best,["Fold","CM_Table"]));
% LoopCM_Table = LoopTable{:,"CM_Table"};
% LoopFolds = LoopTable{:,"Fold"};

Table_Sweep_Keep = SweepTable{:,SweepName};
MatchIDX_Remove = all(ismember(Table_Sweep_Keep,Table_Best_Keep),2);
MatchIDX_Remove(MatchBestIDX) = false;
% MatchIDX_Remove = ~MatchIDX_Remove;
% SweepTable_Remove = SweepTable;
% SweepTable_Remove(MatchIDX_Remove,:) = [];
% SweepTable_Remove = SweepTable;
SweepTable(MatchIDX_Remove,:) = [];
MatchBestIDX(MatchIDX_Remove) = [];
% SweepAllNames = SweepTable{:,SweepName};
% 
% SweepAllNames = join(SweepAllNames,":",2);
% 
% SweepAllNames(MatchBestIDX) = SweepAllNames(MatchBestIDX) + "*";
%%
SweepOrder_String = SweepTable{:,SweepName};
SweepOrder_Num = NaN(size(SweepOrder_String));
for nidx_1 = 1:size(SweepOrder_String,1)
    for nidx_2 = 1:size(SweepOrder_String,2)
SweepOrder_Num(nidx_1,nidx_2) = str2double(SweepOrder_String(nidx_1,nidx_2));
    end
end

[~,SweepOrderedIDX] = sortrows(SweepOrder_Num);
SweepTable = SweepTable(SweepOrderedIDX,:);
MatchBestIDX = MatchBestIDX(SweepOrderedIDX);
%%

CMTable_Best = EncoderParameters_Best{:,"CM_Table"};
CMTable_Best = CMTable_Best{1};
Folds = EncoderParameters_Best{:,"Fold"};
Folds = Folds{1};

NumFolds = length(Folds);

MostCommon = NaN(1,NumFolds);
RandomChance = NaN(1,NumFolds);
ClassNames = cell(1,NumFolds);

for fidx = 1:length(Folds)
    this_CM_Table = CMTable_Best{fidx};
[ClassNames{fidx},~,~,~] = cgg_getClassesFromCMTable(this_CM_Table);

[MostCommon(fidx),RandomChance(fidx)] = ...
        cgg_getBaselineAccuracyMeasures(this_CM_Table.TrueValue, ...
        ClassNames{fidx},MatchType_Calc,IsQuaddle,'NumIterRand',NumIterRand);

end

%%

SweepAccuracy = cell(height(SweepTable),1);
SweepWindowAccuracy = cell(height(SweepTable),1);

for ridx = 1:height(SweepTable)

    this_SweepTable = SweepTable(ridx,:);
    CMTable_Sweep = this_SweepTable{:,"CM_Table"};
    CMTable_Sweep = CMTable_Sweep{1};
    Folds_Sweep = this_SweepTable{:,"Fold"};
    Folds_Sweep = Folds_Sweep{1};

    this_NumFolds = length(Folds_Sweep);

   this_SweepAccuracy = NaN(this_NumFolds,1);
   this_SweepWindowAccuracy = cell(this_NumFolds,1);
    

    for fidx = 1:this_NumFolds
        this_Fold_Sweep = Folds_Sweep(fidx);
        this_CM_Table = CMTable_Sweep{fidx};
        this_Fold_SweepIDX = this_Fold_Sweep == Folds;
        this_ClassNames = ClassNames{this_Fold_SweepIDX};
        this_MostCommon = MostCommon(this_Fold_SweepIDX);
        this_RandomChance = RandomChance(this_Fold_SweepIDX);

[~,~,this_WindowAccuracy] = cgg_procConfusionMatrixWindowsFromTable(...
this_CM_Table,this_ClassNames,'MatchType',MatchType,...
'IsQuaddle',IsQuaddle,'MostCommon',this_MostCommon,...
'RandomChance',this_RandomChance);


    this_SweepAccuracy(fidx) = max(this_WindowAccuracy);
    this_SweepWindowAccuracy{fidx} = this_WindowAccuracy;
    end

SweepAccuracy{ridx} = this_SweepAccuracy;
SweepWindowAccuracy{ridx} = cell2mat(this_SweepWindowAccuracy);

end

%% Sweep Names

SweepAllNames = SweepTable{:,SweepName};

SweepAllNames = join(SweepAllNames,":",2);

SweepAllNames(MatchBestIDX) = SweepAllNames(MatchBestIDX) + "*";

end

