function [outputTable] = cgg_procROIStatistics(inputTable)
%CGG_PROCROISTATISTICS Summary of this function goes here
%   Detailed explanation goes here
    % function outputTable = generateOutputTable(inputTable)
    uniqueCombinations = unique(inputTable(:, {'Monkey', 'Model_Variable', 'ROI'}));
    numCombinations = size(uniqueCombinations, 1);
    
    tableCell = cell(numCombinations, 1);
    
    for i = 1:numCombinations
        monkey = uniqueCombinations.Monkey(i);
        modelVariable = uniqueCombinations.Model_Variable(i);
        roi = uniqueCombinations.ROI(i);
        
        rows = inputTable.Monkey == monkey & ...
               inputTable.Model_Variable == modelVariable & ...
               inputTable.ROI == roi;
        
        plotDataList = inputTable.PlotData(rows);
        areaList = inputTable.Area(rows);
        
        uniqueAreas = unique(areaList);
        numAreas = length(uniqueAreas);

        TableRowNames = {'Positive (P-Value)','Positive (Z Statistic)','Negative (P-Value)','Negative (Z Statistic)','Difference (P-Value)','Difference (Z Statistic)','Combination (P-Value)','Combination (Z Statistic)'};
        
        tableData = zeros(8, numAreas + nchoosek(numAreas, 2));
        tableColNames = [uniqueAreas; join(nchoosek(uniqueAreas, 2),'_')];

        for j = 1:numAreas
            area = uniqueAreas{j};
            areaIndex = strcmp(areaList, area);
            plotData = plotDataList{areaIndex};

            ProportionPositive = plotData.ProportionPositive_ROI;
            CountPositive = plotData.Positive_ROI_Count;
            ProportionNegative = plotData.ProportionNegative_ROI;
            CountNegative = plotData.Negative_ROI_Count;

            [P_Value_Positive,Z_Value_Positive] = cgg_procTwoProportionZTest(ProportionPositive, CountPositive, 0, 0);
            [P_Value_Negative,Z_Value_Negative] = cgg_procTwoProportionZTest(ProportionNegative, CountNegative, 0, 0);
            [P_Value_Difference,Z_Value_Difference] = cgg_procTwoProportionZTest(ProportionPositive, CountPositive/2, ProportionNegative, CountNegative/2);
            [P_Value_Combination,Z_Value_Combination] = cgg_procTwoProportionZTest(ProportionPositive+ProportionNegative, CountPositive, 0, 0);
            
            tableData(1, j) = P_Value_Positive;
            tableData(2, j) = Z_Value_Positive;
            tableData(3, j) = P_Value_Negative;
            tableData(4, j) = Z_Value_Negative;
            tableData(5, j) = P_Value_Difference;
            tableData(6, j) = Z_Value_Difference;
            tableData(7, j) = P_Value_Combination;
            tableData(8, j) = Z_Value_Combination;
        end
        
        for j = 1:nchoosek(numAreas, 2)
            combination = nchoosek(uniqueAreas, 2);
            area1 = combination{j, 1};
            area2 = combination{j, 2};
            
            area1Index = strcmp(areaList, area1);
            area2Index = strcmp(areaList, area2);
            
            plotData1 = plotDataList{area1Index};
            plotData2 = plotDataList{area2Index};

            ProportionPositive1 = plotData1.ProportionPositive_ROI;
            CountPositive1 = plotData1.Positive_ROI_Count;
            ProportionNegative1 = plotData1.ProportionNegative_ROI;
            CountNegative1 = plotData1.Negative_ROI_Count;

            ProportionPositive2 = plotData2.ProportionPositive_ROI;
            CountPositive2 = plotData2.Positive_ROI_Count;
            ProportionNegative2 = plotData2.ProportionNegative_ROI;
            CountNegative2 = plotData2.Negative_ROI_Count;

            [P_Value_Positive,Z_Value_Positive] = cgg_procTwoProportionZTest(ProportionPositive1, CountPositive1, ProportionPositive2, CountPositive2);
            [P_Value_Negative,Z_Value_Negative] = cgg_procTwoProportionZTest(ProportionNegative1, CountNegative1, ProportionNegative2, CountNegative2);
            [P_Value_Difference,Z_Value_Difference] = cgg_procDifferenceOfDifferencesProportionTest(ProportionPositive1,ProportionNegative1,ProportionPositive2,ProportionNegative2,CountPositive1,CountPositive2);
            [P_Value_Combination,Z_Value_Combination] = cgg_procTwoProportionZTest(ProportionPositive1+ProportionNegative1, CountPositive1, ProportionPositive2+ProportionNegative2, CountPositive2);

            tableData(1, numAreas + j) = P_Value_Positive;
            tableData(2, numAreas + j) = Z_Value_Positive;
            tableData(3, numAreas + j) = P_Value_Negative;
            tableData(4, numAreas + j) = Z_Value_Negative;
            tableData(5, numAreas + j) = P_Value_Difference;
            tableData(6, numAreas + j) = Z_Value_Difference;
            tableData(7, numAreas + j) = P_Value_Combination;
            tableData(8, numAreas + j) = Z_Value_Combination;
            
        end
        
        tableCell{i} = array2table(tableData, 'RowNames', TableRowNames, 'VariableNames', tableColNames);
    end
    
    outputTable = table(tableCell, uniqueCombinations.Monkey, uniqueCombinations.Model_Variable, uniqueCombinations.ROI, ...
        'VariableNames', {'Table', 'Monkey', 'Model_Variable', 'ROI'});
end
