function sem = SEM(data, varargin)

%if varargin exists, it is the extra arguments to nanstd


if isempty(varargin)
    n = sum(~isnan(data));
    n(n == -1) = NaN;
    sem = nanstd(data) ./ sqrt(n);
else
    n = sum(~isnan(data), varargin{2});
    n(n == -1) = NaN;
    sem = nanstd(data, varargin{:}) ./ sqrt(n);
end
