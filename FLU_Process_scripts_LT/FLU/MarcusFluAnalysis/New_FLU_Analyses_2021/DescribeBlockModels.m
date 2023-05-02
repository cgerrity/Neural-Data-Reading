function DescribeBlockModels(results)

dvs = {'LP', 'ProportionLps', 'PostLpAcc'};

for iDV = 1:length(dvs)
    fprintf('\n##############################################\n');
    fprintf(['Results for ' dvs{iDV} '\n']);
    DescribeBlockModel(results.(dvs{iDV}));
end


function DescribeBlockModel(results)

fprintf('\nEffect of adding ID_ED:\n')
fprintf(['\tDim + Stoch vs Dim + Stoch + ID_ED: ' ReportModelComparisonPval(results.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_p_Typ.SimInfo) '\n'])
fprintf(['\tDim + Stoch vs Dim + Stoch * ID_ED: ' ReportModelComparisonPval(results.LMEComp.Dim_p_Sto__vs__Dim_p_Sto_X_Typ.SimInfo) '\n'])
fprintf(['\tDim + Stoch vs Dim * Stoch * ID_ED: ' ReportModelComparisonPval(results.LMEComp.Dim_p_Sto__vs__Dim_X_Sto_X_Typ.SimInfo) '\n'])

fprintf('\nEffect of adding Dim * Stoch:\n')
fprintf(['\tDim + Stoch vs Dim * Stoch: ' ReportModelComparisonPval(results.LMEComp.Dim_p_Sto__vs__Dim_X_Sto.SimInfo) '\n'])

results.LMEs.Dim_p_Sto.AllSubjs.FixedEffects
results.LMEs.Dim_X_Sto.AllSubjs.FixedEffects

fprintf('\n\tVALUES\n')
fprintf(['\tDimensionality 2: ' MeanAndSEM(results.BlockMeans.Dim_2D.Stoch_All.IdEd_All) ...
    '; Dimensionality 5: ' MeanAndSEM(results.BlockMeans.Dim_5D.Stoch_All.IdEd_All) '\n']);
fprintf(['\tStochasticity 15: ' MeanAndSEM(results.BlockMeans.Dim_All.Stoch_15.IdEd_All) ...
    '; Stochasticity 30: ' MeanAndSEM(results.BlockMeans.Dim_All.Stoch_30.IdEd_All) '\n']);
fprintf(['\tDimensionality 2 & Stochasticity 15: ' MeanAndSEM(results.BlockMeans.Dim_2D.Stoch_15.IdEd_All) '\n']);
fprintf(['\tDimensionality 2 & Stochasticity 30: ' MeanAndSEM(results.BlockMeans.Dim_2D.Stoch_30.IdEd_All) '\n']);
fprintf(['\tDimensionality 5 & Stochasticity 15: ' MeanAndSEM(results.BlockMeans.Dim_5D.Stoch_15.IdEd_All) '\n']);
fprintf(['\tDimensionality 5 & Stochasticity 30: ' MeanAndSEM(results.BlockMeans.Dim_5D.Stoch_30.IdEd_All) '\n']);

function string = ReportModelComparisonPval(siminfo)
string = ['p = ' num2str(siminfo.pvalueSim) ' (CI ' num2str(siminfo.pvalueSimCI(1)) ', ' num2str(siminfo.pvalueSimCI(2)) ')'];

function string = MeanAndSEM(data)
string = ['Mean ' num2str(data.Mean) ', SEM ' num2str(data.SEM)];