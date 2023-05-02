function [interpolatedData, numInterps] = interpolate_shortMissingData(inputData, timeStamps, maxNanTime, timeWindow, fsample)
%for sparse missing data, we can interpolate to find expected values.
%maxNanTime and timeWindow determine how sparse this data has to be: there
%can be no more than maxNanTime seconds of missing data in a period with
%duration = timeWindow.

%so if timeWindow = 0.1 and maxNanTime = 0.02, you are allowed 20 ms of
%missing data within a 100 ms period.

%we only interpolate in cases where you have either a single sample of
%missing data or two samples in a row, with good data on either side


interpolatedData = inputData;

sampleDur = nanmean(diff(timeStamps));

%find number of gaze samples that matches time criteria
maxNanSamples = ceil(maxNanTime * fsample);
sampleWindow = ceil(timeWindow * fsample);

%counter for number of single and double sample interpolations made
numInterps = [0 0];


%find indices of every missing sample with good data on either side
patterns = {[0 1 0], [0 1 1 0]};
for ipat=1:numel(patterns)
    singleNan = findPattern(isnan(inputData), patterns{ipat}) + 1;
    for i = 1:length(singleNan)
        %for each of the single-sample missing data pieces, find the rows from
        %the appropriate time window around it (so if timeWindow = 0.1s, go 50
        %ms back and 50ms forward from the single-sample missing data.
        st = max(1,ceil(singleNan(i) - sampleWindow/2));
        fn = min(length(inputData), floor(singleNan(i) + sampleWindow/2));
        timeWindowRows = st:fn;
        %(the max and min are in case the missing sample is close to the
        %beginning or end of the data)

        %find out how much data is missing within this period, and how much is
        %good
        nanRows = isnan(inputData(timeWindowRows));
        goodRows = timeWindowRows(~nanRows);

        if sum(nanRows) <= maxNanSamples %if there is less than the maximum amount of bad data, replace the single nan missing data point via interpolation
            ind = find(patterns{ipat}) + singleNan(i) - 1;
            
            interpolatedData(ind) = interp1(goodRows, inputData(goodRows), ind, 'pchip');
            numInterps(ipat) = numInterps(ipat) + 1;
        end
    end
end

% %now do the same for double missing data samples
% doubleNan = findPattern(isnan(inputData), [0 1 1 0]) + 1;
% for i = 1:length(doubleNan)
%     timeWindowRows = max(1,ceil(doubleNan(i) - sampleWindow/2)) : min(length(inputData), floor(doubleNan(i) + sampleWindow/2));
%     nanRows = isnan(inputData(timeWindowRows));
%     goodRows = timeWindowRows(~nanRows);
%     if sum(nanRows) <= maxNanSamples
%         interpolatedData(doubleNan(i):doubleNan(i)+1) = interp1(goodRows, inputData(goodRows), doubleNan(i):doubleNan(i)+1, 'pchip');
%         numInterps(2) = numInterps(2) + 1;
%     end
%         
% end
