function [lmes, modelCriteria, modelComparisons] = CompleteLME_3Factor(dataTable, dv, categoricalFactors, numericFactors, randomFactors)

TF = [categoricalFactors numericFactors];
numTF= length(TF);

%fix variable types
if islogical(dataTable.(dv))
    dataTable.(dv) = double(dataTable.(dv));
end
for iC = 1:length(categoricalFactors)
    dataTable.(categoricalFactors{iC}) = categorical(dataTable.(categoricalFactors{iC}));
end

%only making random factors additive...?
if ~isempty(randomFactors)
    randomFormula = ['(1|' randomFactors{1} ')'];
    if length(randomFactors) > 1
        for iR = 2:length(randomFactors)
            randomFormula = [randomFormula ' + (1|' randomFactors{iR} ')']; %#ok<AGROW>
        end
    end
end


for i1 = 1:numTF
    factor1 = TF{i1};
    formula = [dv ' ~ ' factor1 ' + ' randomFormula];
    lmes.(factor1) = LMEandFixed(dataTable, formula);
    if i1 < numTF
        for i2 = i1+1:numTF
            factor2 = TF{i2};
            formula = [dv ' ~ ' factor1 ' + ' factor2 ' + ' randomFormula];
            lmes.([factor1 '_P_' factor2]) = LMEandFixed(dataTable, formula);
            formula = [dv ' ~ ' factor1 ' * ' factor2 ' + ' randomFormula];
            lmes.([factor1 '_X_' factor2]) = LMEandFixed(dataTable, formula);
            if i2 < numTF
                factor3 = TF{i2+1};
                formula = [dv ' ~ ' factor1 ' + ' factor2 ' + ' factor3 ' + ' randomFormula];
                lmes.([factor1 '_P_' factor2 '_P_' factor3]) = LMEandFixed(dataTable, formula);
                formula = [dv ' ~ (' factor1 ' + ' factor2 ') * ' factor3 ' + ' randomFormula];
                lmes.([factor1 '_P_' factor2 '_X_' factor3]) = LMEandFixed(dataTable, formula);
                formula = [dv ' ~ ' factor1 ' * (' factor2 ' + ' factor3 ') + ' randomFormula];
                lmes.([factor1 '_X_' factor2 '_P_' factor3]) = LMEandFixed(dataTable, formula);
                formula = [dv ' ~ ' factor1 ' * ' factor2 ' * ' factor3 ' + ' randomFormula];
                lmes.([factor1 '_X_' factor2 '_X_' factor3]) = LMEandFixed(dataTable, formula);
            end
        end
    end
end

modelNames = fields(lmes);
nModels = length(modelNames);

aic = nan(nModels,1);
bic = nan(nModels,1);
logLikelihood = nan(nModels,1);
deviance = nan(nModels,1);

for i1 = 1:nModels-1
    aic(i1) = lmes.(modelNames{i1}).LME.ModelCriterion{1,1};
    bic(i1) = lmes.(modelNames{i1}).LME.ModelCriterion{1,2};
    logLikelihood(i1) = lmes.(modelNames{i1}).LME.ModelCriterion{1,3};
    deviance(i1) = lmes.(modelNames{i1}).LME.ModelCriterion{1,4};
    for i2 = i1+1:nModels
        modelComparisons.([modelNames{i1} '__VS__' modelNames{i2}]) = CompareLMEs(lmes.(modelNames{i1}).LME, lmes.(modelNames{i2}).LME);
    end
end

aic(i2) = lmes.(modelNames{i2}).LME.ModelCriterion{1,1};
bic(i2) = lmes.(modelNames{i2}).LME.ModelCriterion{1,2};
logLikelihood(i2) = lmes.(modelNames{i2}).LME.ModelCriterion{1,3};
deviance(i2) = lmes.(modelNames{i2}).LME.ModelCriterion{1,4};

modelCriteria = table(modelNames, aic, bic, logLikelihood, deviance);
% 
% function [categoricalFactors_reduced, numericFactors_reduced] = FixOrCat(factor, factorCount, categoricalFactors_reduced, numericFactors_reduced, numCategoricalFactors)
% if factorCount <= numCategoricalFactors
%     categoricalFactors_reduced = [categoricalFactors_reduced factor];
% else
%     numericFactors_reduced = [numericFactors_reduced factor];
% end

function model = LMEandFixed(dataTable, formula)
model.LME = fitlme(dataTable, formula, 'dummyvarcoding', 'effects', 'fitmethod', 'reml');
model.FixedEffects = anova(model.LME, 'DFMethod', 'Satterthwaite');


function compResults = CompareLMEs(lme1, lme2)
[compResults.Results, compResults.SimInfo] = compare(lme1, lme2, 'NSim', 500);
