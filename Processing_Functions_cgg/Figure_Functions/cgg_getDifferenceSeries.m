function [Difference_Mean,Difference_ErrorMetric] = cgg_getDifferenceSeries(YValues_1,YValues_2,NumSamples,varargin)
%CGG_GETDIFFERENCESERIES Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
wantCI = CheckVararginPairs('wantCI', true, varargin{:});
else
if ~(exist('wantCI','var'))
wantCI=true;
end
end

if isfunction
SignificanceValue = CheckVararginPairs('SignificanceValue', 0.05, varargin{:});
else
if ~(exist('SignificanceValue','var'))
SignificanceValue=0.05;
end
end

%%

[Dimensions_1(1),Dimensions_1(2)] = size(YValues_1);
[Dimensions_2(1),Dimensions_2(2)] = size(YValues_2);

Dim_1 = find(~(Dimensions_1==NumSamples));
Dim_2 = find(~(Dimensions_2==NumSamples));

CountPerSample_1=sum(~isnan(YValues_1),Dim_1);
CountPerSample_1(CountPerSample_1==0)=NaN;
CountPerSample_1=diag(diag(CountPerSample_1));

CountPerSample_2=sum(~isnan(YValues_2),Dim_2);
CountPerSample_2(CountPerSample_2==0)=NaN;
CountPerSample_2=diag(diag(CountPerSample_2));

YValues_1_Mean = diag(diag(mean(YValues_1,Dim_1,"omitnan")));
YValues_2_Mean = diag(diag(mean(YValues_2,Dim_1,"omitnan")));

YValues_1_STD = diag(diag(std(YValues_1,[],Dim_1,"omitnan")));
YValues_2_STD = diag(diag(std(YValues_2,[],Dim_2,"omitnan")));

% YValues_1_STE = diag(diag(YValues_1_STD./sqrt(CountPerSample_1)));
% YValues_2_STE = diag(diag(YValues_2_STD./sqrt(CountPerSample_2)));

Difference_Mean = YValues_1_Mean - YValues_2_Mean;

V_1 = (YValues_1_STD.^2./CountPerSample_1);
V_2 = (YValues_2_STD.^2./CountPerSample_2);

Difference_STE = sqrt(V_1 + V_2);
% Difference_DF = ((V_1 + V_2).^2)./(V_1.^2./(CountPerSample_1 - 1)+V_2.^2./(CountPerSample_2 - 1));
Difference_DF = cat(2,CountPerSample_1,CountPerSample_2);
Difference_DF = mean(Difference_DF,2,"omitnan") - 1;

ts = tinv(1-SignificanceValue/2,Difference_DF);

Difference_CI = ts.*Difference_STE;

Difference_ErrorMetric=Difference_STE;
if wantCI
    Difference_ErrorMetric=Difference_CI;
end

Difference_Mean = Difference_Mean';
Difference_ErrorMetric = Difference_ErrorMetric';

end

