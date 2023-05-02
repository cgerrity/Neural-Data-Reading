function [indices] = findMultiple(data, test)

%{
returns all indices of data that are part of test (e.g. if test is a subset
of subject numbers and data is a column of subject numbers from experimental 
data, returns all indices to data that contain an element of test.

test and data should both be vectors
%}

indicesSeparate = zeros(length(data), length(test));

for testCount = 1:length(test)
    indicesSeparate(:,testCount) = data==test(testCount);
end
indices = sum(indicesSeparate,2);
indices = find(indices == 1);