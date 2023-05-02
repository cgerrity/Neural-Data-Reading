
subplot(2,2,1)
PlotDvMeansSingleLine(conditionData, 'Acc', 'Accuracy', suffix)
subplot(2,2,2)
PlotDvMeansSingleLine(conditionData, 'TimeTouchFromLiftOfHoldKey', 'Reach Time', suffix)
subplot(2,2,3)
PlotDvMeansSingleLine(conditionData, 'TotalFixations', 'Total Fixation Count', suffix)
subplot(2,2,4)
PlotDvMeansSingleLine(conditionData, 'ChosenBias', 'Chosen Fixation Bias', suffix)