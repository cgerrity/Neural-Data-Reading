function Value = cgg_getValueBasedOnNumberOfWorkers(Value,...
    MinimumWorkers,varargin)
%CGG_GETVALUEBASEDONNUMBEROFWORKERS Summary of this function goes here
%   This function alters the value by the number of workers compared to a
%   minimum. This is helpful if running multiple instances that may have a
%   different number of workers. Use this function to alter a value such as
%   number of iterations and have it scale to run proportionally similar
%   number for each worker.

isfunction=exist('varargin','var');

if isfunction
RelationFunc = CheckVararginPairs('RelationFunc', @(x,y) x*y, varargin{:});
else
if ~(exist('RelationFunc','var'))
RelationFunc=@(x,y) x*y;
end
end

% example:
% Value = 100; MinimumWorkers = 4;
% ValuePerWorker = 100/4 = 25;
% PoolSize = 32; Value = cgg_getValueBasedOnNumberOfWorkers(100,4);
% Value = 800; ValuePerWorker = 800/32 = 25;

P = gcp("nocreate"); % If no pool, do not create new one.
if isempty(P)
    PoolSize = 0;
else
    PoolSize = P.NumWorkers;
end

%%
if PoolSize > MinimumWorkers
    Factor = PoolSize/MinimumWorkers;
    Value = RelationFunc(Value,Factor);
% Value = Value*(PoolSize/MinimumWorkers);
end

end

