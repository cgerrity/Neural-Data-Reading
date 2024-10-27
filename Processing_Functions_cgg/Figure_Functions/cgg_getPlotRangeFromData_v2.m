function DataLimits = cgg_getPlotRangeFromData_v2(InData,RangeFactor,Percentile,RecencyAmount)
%CGG_GETPLOTRANGEFROMDATA_V2 Summary of this function goes here
%   Detailed explanation goes here


% NumSamples = [800,150,500];
% STD = [5,2,3];
% Mu = [10,2,3];
% OutlierSTD = 100;
% Percentile = 99;
% RecencyAmount = 100;
% RangeFactor = 0.1;
% 
% InData = cell(1,length(NumSamples));
% for sidx = 1:length(NumSamples)
% InData{sidx} = STD(sidx)*randn(1,NumSamples(sidx))+Mu(sidx);
% InData{sidx}(1) = randn(1)*OutlierSTD;
% InData{sidx}(2) = NaN;
% InData{sidx}(3) = (randi(2)*2-3)*Inf;
% end

this_Data = InData;

if iscell(InData)
    this_Data = cellfun(@(x) procAllChecks(x,RecencyAmount),this_Data,'UniformOutput',false);
    this_Data = [this_Data{:}];
else
    this_Data = procAllChecks(this_Data,RecencyAmount);
end

Limit_Upper = prctile(this_Data,Percentile);
Limit_Lower = prctile(this_Data,100-Percentile);


Range = Limit_Upper-Limit_Lower;
if Range <= 0
Range = 0.00001;
end

RangeAddition = Range*RangeFactor;

DataLimits = [Limit_Lower-RangeAddition,Limit_Upper+RangeAddition];

% histogram(this_Data,100)
% hold on
% xline(DataLimits(1));
% xline(DataLimits(2));
% hold off
% disp({max(this_Data),min(this_Data)});
%%
    function Output = makeLongArray(Input)
        Output = Input;
        InputSize = size(Output);
        if InputSize(1) > InputSize(2)
            Output = Output';
        end
    end

    function Output = getMostRecent(Input,Amount)
        if length(Input) > Amount
            Output = Input(:,end-Amount+1:end);
        elseif isnan(Amount)
            Output = Input;
        else
            Output = Input;
        end
    end

    function Output = removeInfinity(Input)
        Output = Input(~isinf(Input));
    end

    function Output = removeNaN(Input)
        Output = Input(~isnan(Input));
    end

    function Output = procAllChecks(Input,Amount)
        Output = Input;
        Output = makeLongArray(Output);
        Output = getMostRecent(Output,Amount);
        Output = removeInfinity(Output);
        Output = removeNaN(Output);
    end

end
