
function comparisons = MultipleCompsRM(data, grouping, varargin)
%data: table or array, each row is a subject, each column is an observation
%grouping = vector of comparison groups, same length as number of columns
%in data. Means of each column in the same group will be compared.

%E.g. if the grouping is [1 2 1 2], there will be two comparisons made, one
%between columns 1 and 3, and one between columns 2 and 4. If the grouping
%is [1 1 1 1], there will be 6 comparisons made, between columns 1/2 1/3
%1/4, 2/3, 2/4, 3/4

%Not all groupings need to refer to the same number of columns

%Dunn-Sidak correction to alpha is used

%output: comparisons = table with k rows, where  = number of comparisons
%made. Columns: h, p, ci_lo, ci_hi, tstat, df, sd

data(sum(isnan(data),2) > 0, :) = [];

aFam = 0.05;

groups = unique(grouping);
k = 0;

for iG = 1:length(groups)
    nGroup = sum(grouping == groups(iG));
    k = k + nGroup * (nGroup - 1) / 2;
end

a = 1 - (1 - aFam) ^ (1/k);

comparisons = array2table(nan(k*2, 7), 'variablenames', {'h', 'p', 'ci_lo', 'ci_hi', 't', 'df', 'sd'});
comparisons = [table(repmat({''},k*2,1), 'variablenames', {'Comparison'}) comparisons];

test = 1;
for iG = 1:length(groups)
    g = groups(iG);
    cols = find(grouping == g);
    for iA = 1:length(cols)
        for iB = 1 : length(cols)
            if iA == iB
                continue;
            end
            [h, p, ci, stats] = ttest(data(:,cols(iA)), data(:,cols(iB)), 'alpha', a);
            if istable(data)
                comparisons{test,1} = {[data.VariableNames{cols(iA)} '_vs_' data.VariableNames{cols(iB)}]};
            elseif isempty(varargin)
                comparisons{test,1} = {['O' num2str(cols(iA)) '_vs_O' num2str(cols(iB))]};
            else
                comparisons{test,1} = {[varargin{1}{cols(iA)} '_vs_' varargin{1}{cols(iB)}]};
            end
            comparisons(test,2:end) = {h p ci(1) ci(2) stats.tstat, stats.df, stats.sd};
            test = test + 1;
        end
    end
end