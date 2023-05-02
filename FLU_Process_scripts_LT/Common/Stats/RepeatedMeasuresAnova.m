function outStruct = RepeatedMeasuresAnova(subjData, factors, varnames)
%assumes data is in rows for each subject
%factors are same for each subject, refer to columns in data

subjData(isnan(sum(subjData,2)),:) = []; %remove missing data

nObs = size(subjData,2);

if size(factors,1) ~= nObs && size(factors,2) == nObs
    factors = factors';
end

if isnumeric(factors)
    within = array2table(factors, 'variablenames', varnames);
elseif iscell(factors)
    within = cell2table(factors, 'variablenames', varnames);
end

withinModel = varnames{1};
for i = 2:length(varnames)
    withinModel = [withinModel '*' varnames{i}]; %#ok<AGROW>
end

obnames = cell(1, nObs);
for i = 1:nObs
    obnames{i} = ['O' num2str(i)];
end

data = array2table(subjData, 'VariableNames', obnames);

outStruct.rm = fitrm(data, ['O1-O' num2str(nObs) '~1'], 'WithinDesign', within);
outStruct.table = ranova(outStruct.rm, 'WithinModel', withinModel);