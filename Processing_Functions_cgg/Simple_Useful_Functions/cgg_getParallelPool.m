function pp = cgg_getParallelPool(varargin)
%CGG_GETPARALLELPOOL Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
WantThreads = CheckVararginPairs('WantThreads', false, varargin{:});
else
if ~(exist('WantThreads','var'))
WantThreads=false;
end
end

if isfunction
RequireChange = CheckVararginPairs('RequireChange', false, varargin{:});
else
if ~(exist('RequireChange','var'))
RequireChange=false;
end
end
%%
pc = parcluster;
this_JobStorageLocation = fullfile(...
    extractBefore(pc.JobStorageLocation,matlabRelease.Release),...
    getenv('SLURM_JOB_ID'),matlabRelease.Release);
pc.JobStorageLocation = this_JobStorageLocation;

%%
pp=gcp("nocreate");
IsThreads = isa(pp, 'parallel.ThreadPool');
HasPool = ~isempty(pp);
%% Get Number of Workers
if canUseGPU
    NumWorkers = gpuDeviceCount("available");
elseif ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
    cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
    % MinimumCores = cfg_Encoder.MiniBatchSize/cfg_Encoder.maxworkerMiniBatchSize;
    MinimumCores = Inf;
    NumWorkers = min([cores,MinimumCores]);
else
    NumWorkers = [];
end

%%

ChangeToThreads = WantThreads && ~IsThreads;
ChangeToNonThreads = ~WantThreads && IsThreads;
WantChange = ChangeToThreads || ChangeToNonThreads;
MustChange = WantChange && RequireChange;
NeedDelete = MustChange && HasPool;
MakeNewPool = NeedDelete || ~HasPool;

if NeedDelete
delete(pp);
end

if MakeNewPool
pp = generatePool(pc,WantThreads,NumWorkers);
end

%%

% if canUseGPU
%     numberOfGPUs = gpuDeviceCount("available");
%     % numberOfGPUs = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
%     p=gcp("nocreate");
%     if isempty(p) && WantThreads
%         pp = parpool('Threads',numberOfGPUs);
%     elseif isempty(p)
%         pp = parpool(pc,numberOfGPUs);
%     elseif WantChange && WantThreads
%         delete(p);
%         pp = parpool('Threads',numberOfGPUs);
%     elseif WantChange
%         delete(p);
%         pp = parpool(pc,numberOfGPUs);
%     end
% elseif ~isempty(getenv('SLURM_JOB_CPUS_PER_NODE'))
%     cores = str2double(getenv('SLURM_JOB_CPUS_PER_NODE'));
%     p=gcp("nocreate");
%     % MinimumCores = cfg_Encoder.MiniBatchSize/cfg_Encoder.maxworkerMiniBatchSize;
%     MinimumCores = Inf;
%     UsedCores = min([cores,MinimumCores]);
%     if isempty(p) && WantThreads
%         pp = parpool('Threads',UsedCores);
%     elseif isempty(p)
%         pp = parpool(pc,UsedCores);
%     elseif WantChange && WantThreads
%         delete(p);
%         pp = parpool('Threads',UsedCores);
%     elseif WantChange
%         delete(p);
%         pp = parpool(pc,UsedCores);
%     end
% else
%     p=gcp("nocreate");
%     if isempty(p) && WantThreads
%         pp = parpool('Threads');
%     elseif isempty(p)
%         pp = parpool(pc);
%     elseif WantChange && WantThreads
%         delete(p);
%         pp = parpool('Threads');
%     elseif WantChange
%         delete(p);
%         pp = parpool(pc);
%     end
% end

    function this_pp = generatePool(this_pc, this_WantThreads,this_NumWorkers)
        if this_WantThreads && ~isempty(this_NumWorkers)
            this_pp = parpool('Threads',this_NumWorkers);
        elseif ~this_WantThreads && ~isempty(this_NumWorkers)
            this_pp = parpool(this_pc,this_NumWorkers);
        elseif this_WantThreads && isempty(this_NumWorkers)
            this_pp = parpool('Threads');
        elseif ~this_WantThreads && isempty(this_NumWorkers)
            this_pp = parpool(this_pc);
        end
    end

end

