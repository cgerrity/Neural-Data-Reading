
function orderedData = PreserveTrialPosition(data, dataCol, minTrial, maxTrial)



orderedData = nan(1,maxTrial-minTrial+1);
orderedData(data.TrialInBlock - minTrial + 1) = data.(dataCol);