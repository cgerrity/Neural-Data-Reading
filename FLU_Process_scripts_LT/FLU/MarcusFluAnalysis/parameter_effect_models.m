function lmes = parameter_effect_models(dv, dvName, pars, parNames, factors, factorNames, subject)

%{
Runs a series of LMEs on data from a FLU task, first including subjects as
random factors, and then separately for each subject.

Inputs: 
dv: vector of values for the DV
dvName: string indicating the name of the DV
pars: array of values for model parameters we want to use as predictors of
the DV
parNames: cell of strings, indicating the names of each column of pars
factors: array of values for the experimental factors
factorNames: cell of strings, indicating the names of each factor
subject: array of subject numbers

note that dv, pars, factors, and subject must all have the same length, and
each of the names variables must have the same number of elements as the
number of columns in their corresponding array

example call:
lmes = parameter_effect_models(YLPs_MAT.YLPs_LP, 'LP', YLPs_MAT.XLPs_PAR, {'ExplRate', 'SaliencyCorrect', 'AttentionEnhancement', 'SaliencyError', 'MetaAwareness'}, [YLPs_MAT.XLPs_PROB YLPs_MAT.XLPs_LOAD], {'Validity', 'Load'}, YLPs_MAT.XLPs_Subject)
%}


%make data table
dataTable = array2table([dv pars factors subject], 'VariableNames', [dvName, parNames, factorNames 'Subject']);

dataTable.Subject = categorical(dataTable.Subject);
dataTable.(dvName) = zscore(dataTable.(dvName));
%define formula
mainFormula = [dvName ' ~ '];
for iP = 1:length(parNames)
    dataTable.(parNames{iP}) = zscore(dataTable.(parNames{iP}));
    mainFormula = [mainFormula parNames{iP}];
    if iP < length(parNames)
        mainFormula = [mainFormula ' + '];
    end
end

fullFormula = [mainFormula ' + '];
for iF = 1:size(factors,2)
    %change factors to categorical
    dataTable.(factorNames{iF}) = categorical(dataTable.(factorNames{iF}));
    fullFormula = [fullFormula factorNames{iF} ' '];
    if iF < size(factors,2)
        fullFormula = [fullFormula '* '];
    end
end


%run full model
lmes.AllSubj.AllConditions = fitlme(dataTable, [fullFormula ' + (1|Subject)'], 'dummyvarcoding', 'effects', 'fitmethod', 'reml');


%run smaller models for each subject
uniqueS = unique(subject);

for iS = 1:length(uniqueS)
    s = uniqueS(iS);
    subjTable = dataTable(dataTable.Subject == categorical(s), :);
    subjTable.Subject = [];
%         lmes.(['Subj' num2str(s)]).AllConditions = fitlme(subjTable, fullFormula, 'dummyvarcoding', 'effects', 'fitmethod', 'reml');
%     lmes.(['Subj' num2str(s)]).AllConditions = fitlm(subjTable, fullFormula);
end