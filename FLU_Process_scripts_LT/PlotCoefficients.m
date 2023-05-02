function PlotCoefficients(lme, coefficientNames)
%Plots specified coefficients of a linear-mixed effects model
%lme - the model
%coefficientNames - cell array of the coefficients desired


values = [];
cis = [];
ps = [];

nCs = length(coefficientNames);

for iCoeff = 1:nCs
    index = find(strcmp(lme.Coefficients.Name, coefficientNames{iCoeff}));
    values = [values; lme.Coefficients.Estimate(index)];
    cis = [cis; lme.Coefficients.Lower(index) lme.Coefficients.Upper(index)];
    ps = [ps; lme.Coefficients.pValue(index)];
end

bar(values', 'w');
hold on;
errorbar(1:nCs, values', values' - cis(:,1)', values' - cis(:,2)', 'k', 'linestyle', 'none');
xlim([0.5 nCs + 0.5])
xticks(1:nCs);
xticklabels(coefficientNames)
xlabel('Parameter');

yl = ylim;
ylabel('Beta Coefficient')
