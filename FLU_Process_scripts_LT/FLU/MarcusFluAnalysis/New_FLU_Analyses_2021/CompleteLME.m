function lmes = CompleteLME(dataTable, dv, categoricalFactors, numericFactors, randomFactors)

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
    formula = [dv ' ~ ' TF{i1} ' + ' randomFormula];
    lmes.(basefFactor) = LMEandFixed(dataTable, formula);
    
    if i1 < numTF
        for i2 = i1+1:numTF
        end
    end
end



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
