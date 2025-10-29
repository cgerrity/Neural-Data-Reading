function [MostCommon,RandomChance,Stratified] = cgg_getSpecifiedChanceLevels(cfg,varargin)
%CGG_GETSPECIFIEDCHANCELEVELS Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
Epoch = CheckVararginPairs('Epoch', 'Decision', varargin{:});
else
if ~(exist('Epoch','var'))
Epoch='Decision';
end
end

if isfunction
TrialFilter = CheckVararginPairs('TrialFilter', {'All'}, varargin{:});
else
if ~(exist('TrialFilter','var'))
TrialFilter={'All'};
end
end

if isfunction
TrialFilter_Value = CheckVararginPairs('TrialFilter_Value', NaN, varargin{:});
else
if ~(exist('TrialFilter_Value','var'))
TrialFilter_Value=NaN;
end
end

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
MatchType_Attention = CheckVararginPairs('MatchType_Attention', 'Scaled-MicroAccuracy', varargin{:});
else
if ~(exist('MatchType_Attention','var'))
MatchType_Attention='Scaled-MicroAccuracy';
end
end

if isfunction
AttentionalFilter = CheckVararginPairs('AttentionalFilter', '', varargin{:});
else
if ~(exist('AttentionalFilter','var'))
AttentionalFilter='';
end
end

if isfunction
Identifiers_Table = CheckVararginPairs('Identifiers_Table', [], varargin{:});
else
if ~(exist('Identifiers_Table','var'))
Identifiers_Table=[];
end
end

if isfunction
AdditionalTarget = CheckVararginPairs('AdditionalTarget', {}, varargin{:});
else
if ~(exist('AdditionalTarget','var'))
AdditionalTarget={};
end
end

if isfunction
Subset = CheckVararginPairs('Subset', '', varargin{:});
else
if ~(exist('Subset','var'))
Subset='';
end
end

if isfunction
wantSubset = CheckVararginPairs('wantSubset', true, varargin{:});
else
if ~(exist('wantSubset','var'))
wantSubset=true;
end
end

if isfunction
WantFilteredChance = CheckVararginPairs('WantFilteredChance', false, varargin{:});
else
if ~(exist('WantFilteredChance','var'))
WantFilteredChance=false;
end
end

if isfunction
WantDisplay = CheckVararginPairs('WantDisplay', false, varargin{:});
else
if ~(exist('WantDisplay','var'))
WantDisplay=false;
end
end

%% Ensure Subset and wantSubset Agree
[Subset,wantSubset] = cgg_verifySubset(Subset,wantSubset);
%% Get MatchType for given analysis

if ~isempty(AttentionalFilter)
    MatchType = MatchType_Attention;
end

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
%% Get Identifiers Table

if isempty(Identifiers_Table)
Identifiers_Table = cgg_getIdentifiersTable(cfg,wantSubset,'Epoch',Epoch,'AdditionalTarget',AdditionalTarget,'Subset',Subset);
end
%% Generate ClassNames
% FIXME: Need to Change if using a target other than Chosen Feature
TrueValueIDX=contains(Identifiers_Table.Properties.VariableNames,'Dimension ');
TrueValue=Identifiers_Table{:,TrueValueIDX};
Identifiers_Table.TrueValue = TrueValue;
[ClassNames,~,~,~] = cgg_getClassesFromCMTable(Identifiers_Table);
%% Generate Attention Weights

Identifiers_Table = cgg_getAttentionWeights(Identifiers_Table);
%% Filter Trials

% % Select whether to calculate chance based on the full dataset or strictly
% % the set being analyzed
% if WantSpecificChance
%     Chance_Table = CM_Table;
% else
    Chance_Table = Identifiers_Table;
% end

% Determine the attentional filter weights
if ~isempty(AttentionalFilter)
    Weights_Chance = Chance_Table.(AttentionalFilter);
else
    Weights_Chance = [];
end

% If WantFilteredChance is true then the chance levels are calculated using
% all the examples but weights the filtered out components as zero instead
% of not considering them. The TrueValues will represent the full set,
% which will affect the calculations of MostCommon and Stratified chance.
% ex. TrialFilter = 'Dimensionality'; TrialFilter_Value = 1;
% WantFilteredChance = false; All trials are included when calculating
% MostCommon and Stratified. 
% WantFilteredChance = true; 1-D trials are examined for calculating
% MostCommon and Stratified, but the possible values to consider are the
% whole dataset. This setting reflects best how the model is trained and
% the set to be analyzed. The TrueValues come from the whole dataset
% similar to training, but only the filtered values are considered for what
% values to examine.
% An alternate method was tested where the TrueValues and data to be
% examined come from the filtered dataset. This does not reflect the actual
% training since this would eliminate the possibility of certain classes.
% e.g. 3-D would have TrueValues that do not have any neutral features, but
% the model is able to assign neutral to these features regardless, making
% any comparison to the model unfair.
if all(~strcmp(TrialFilter,'All')) && WantFilteredChance
    FilterRowIDX=all((Chance_Table{:,TrialFilter}==TrialFilter_Value),2);
    % Chance_Table(~FilterRowIDX,:)=[];
    if isempty(Weights_Chance)
    Weights_Chance = ones(size(Chance_Table.TrueValue));
    end
    Weights_Chance(~FilterRowIDX,:)=0;
end
%%

[MostCommon,RandomChance,Stratified] = cgg_getBaselineAccuracyMeasures(...
    Chance_Table.TrueValue,ClassNames,MatchType_Calc,IsQuaddle,...
    'Weights',Weights_Chance);
if WantDisplay
fprintf('??? Chance Levels: Stratified~%.3f Random~%.3f Most Common~%.3f!\n',Stratified,RandomChance,MostCommon);
end
end

