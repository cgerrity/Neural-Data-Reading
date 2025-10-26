function [thisused_GB,totalMemoryGB] = cgg_getMemoryInformation(varargin)
%CGG_GETMEMORYINFORMATION Summary of this function goes here
%   Detailed explanation goes here

isfunction=exist('varargin','var');

if isfunction
DisplayIndents = CheckVararginPairs('DisplayIndents', 0, varargin{:});
else
if ~(exist('DisplayIndents','var'))
DisplayIndents=0;
end
end
%%
IsThreads = isa(gcp('nocreate'), 'parallel.ThreadPool');
% fprintf('??? Using Threads based environment: %d\n', IsThreads);
if IsThreads
    try
        IsOnWorker = ~isempty(getCurrentTask());
    catch
        IsOnWorker = true;
    end
    % fprintf('??? Using Threads based environment and is on worker: %d\n', IsOnWorker);
    if IsOnWorker
        % fprintf('??? Exiting because is on threads and on worker\n');
        thisused_GB = NaN;
        totalMemoryGB = NaN;
        return
    end
end
% fprintf('??? NOT Exiting because is on threads and on worker\n');
%%
% this_pid = char(string(feature('getpid')));
current_pid = char(string(feature('getpid')));
ppid = current_pid;

while str2double(ppid) ~=1
    % disp(current_pid)
SystemInput = [sprintf('ps -O ppid -p %s',current_pid), ' | awk ''NR>1 {print $2}'''];
[~,ppid] = system(SystemInput);
ppid = string(str2double(ppid));
if str2double(ppid) ==1 
    break
else
current_pid = ppid;
% disp(ppid)
end

end

ppid = current_pid;
% SystemInput = sprintf('ps -O vsz=,rss= -p %s | awk ''NR>1 {print $2}''',ppid);
% [~, thisused_kb_vsz] = system(SystemInput);
% SystemInput = sprintf('ps -O vsz=,rss= -p %s | awk ''NR>1 {print $3}''',ppid);
% [~, thisused_kb_rss] = system(SystemInput);
% % thisused_bytes = str2double(thisused_kb) * 1024;
% thisused_bytes = (str2double(thisused_kb_vsz) + str2double(thisused_kb_rss)) * 1024;
% thisused_GB = thisused_bytes / (1024^3);
%%
[~,~,~,Current_System] = cgg_getBaseFolders();

%%
switch Current_System
    case 'ACCRE'
%%

[~,Environment_Variables]=system('env');
Environment_Variables=splitlines(Environment_Variables);
totalMemory=split(Environment_Variables(startsWith(Environment_Variables,"SLURM_MEM_PER_NODE")),'=');
totalMemory=str2double(totalMemory{2});
totalMemoryGB = totalMemory ./ (1024);

% ppid = char(string(feature('getpid')));
% % Get memory used by the parent process (resident set size in kB)
% [~, thisused_kb] = system(['ps -O rss -p ' ppid ' | awk ''NR>1 {print $2}''']);
% thisused_bytes = str2double(thisused_kb) * 1024;
% thisused_GB = thisused_bytes / (1024^3);

    case 'Personal Computer'
        [~, cmdout] = system('echo $OSTYPE');
        if contains(cmdout,"darwin")
    %%
[~, cmdout] = system('sysctl hw.memsize | awk ''{print $2}''');
totalMemoryBytes = str2double(cmdout);
totalMemoryGB = totalMemoryBytes / (1024^3);

% Get the parent process ID
% [~, ppid] = system('ps -p $PPID -l | awk ''NR>1 {print $3}''');
% ppid = strtrim(ppid);


% ppid = char(string(feature('getpid')));
% % Get memory used by the parent process (resident set size in kB)
% [~, thisused_kb] = system(['ps -O rss -p ' ppid ' | awk ''NR>1 {print $2}''']);
% thisused_bytes = str2double(thisused_kb) * 1024;
% thisused_GB = thisused_bytes / (1024^3);
        end
end

%%

% SystemInput = sprintf('ps -f %s',ppid);
% SystemInput = [sprintf('ps -f %s',ppid), ' | awk ''NR>1 {print $2}'''];
% SystemInput = sprintf('ps -O rss -p %s',ppid);
% SystemInput = [sprintf('ps -O rss -p %s',ppid), ' | awk ''NR>1 {print $2}'''];
% SystemInput = sprintf('ps -p %s -o %cpu,%mem,cmd',ppid);

%%
% this_pid = char(string(feature('getpid')));
% current_pid = this_pid;
% ppid = current_pid;
% 
% while str2double(ppid) ~=1
%     disp(current_pid)
% SystemInput = [sprintf('ps -O ppid -p %s',current_pid), ' | awk ''NR>1 {print $2}'''];
% [~,ppid] = system(SystemInput);
% ppid = string(str2double(ppid));
% if str2double(ppid) ==1 
%     break
% else
% current_pid = ppid;
% disp(ppid)
% 
% end
% 
% end
% disp(ppid)
% disp(current_pid)
%%
% SystemInput = 'ps -O rss -p $(pgrep MATLAB) | awk ''{s+=$1} END {printf "%i", s}''';
% SystemInput = 'ps -O rss -p $(pgrep -P 29882) | awk ''{s+=$1} END {printf "%i", s}''';
% [~, aaaa] = system('ps -o rss -p $(pgrep -P 29882)');

%%
SystemInput = sprintf('ps -o pid -p $(pgrep -P %s)',ppid);
[~, All_PID] = system(SystemInput);
All_PID = strsplit(All_PID, {'\n', '\r'});
All_PID = All_PID';
All_PID = str2double(All_PID);
All_PID(isnan(All_PID)) = [];

Full_PID_List = [str2double(ppid);All_PID];

for pidx = 1:length(All_PID)
    this_pid = All_PID(pidx);
    this_SystemInput = sprintf('ps -o pid -p $(pgrep -P %d)',this_pid);
    [~, this_All_PID] = system(this_SystemInput);
    this_All_PID = strsplit(this_All_PID, {'\n', '\r'});
    this_All_PID = this_All_PID';
    this_All_PID = str2double(this_All_PID);
    this_All_PID(isnan(this_All_PID)) = [];
    Full_PID_List = [Full_PID_List;this_All_PID];
    for ppidx = 1:length(this_All_PID)
        this_pid = this_All_PID(ppidx);
        this_SystemInput = sprintf('ps -o pid -p $(pgrep -P %d)',this_pid);
        [~, this_this_All_PID] = system(this_SystemInput);
        this_this_All_PID = strsplit(this_this_All_PID, {'\n', '\r'});
        this_this_All_PID = this_this_All_PID';
        this_this_All_PID = str2double(this_this_All_PID);
        this_this_All_PID(isnan(this_this_All_PID)) = [];
        Full_PID_List = [Full_PID_List;this_this_All_PID];
    end
end
Full_PID_List = unique(Full_PID_List);
%%

thisused_kb = 0;
for pidx = 1:length(Full_PID_List)
SystemInput = sprintf('ps -o rss %d',Full_PID_List(pidx));
[~, this_RSS] = system(SystemInput);
this_RSS = strsplit(this_RSS, {'\n', '\r'});
this_RSS = this_RSS';
this_RSS = str2double(this_RSS);
this_RSS(isnan(this_RSS)) = [];
thisused_kb = thisused_kb + sum(this_RSS);
% disp(sum(this_RSS) / (1024^2))
end

thisused_bytes = thisused_kb * 1024;
thisused_GB = thisused_bytes / (1024^3);
%%
% 
% SystemInput = sprintf('ps -o rss -p $(pgrep -P %s)',ppid);
% [~, aaaa] = system(SystemInput);
% lines = strsplit(aaaa, {'\n', '\r'});
% lines = lines';
% bbbb = str2double(lines);
% bbbb(isnan(bbbb)) = [];
% thisused_kb = sum(bbbb);
% % [~, thisused_kb] = system(SystemInput);
% thisused_bytes = thisused_kb * 1024;
% thisused_GB = thisused_bytes / (1024^3);
%%
IndentFormat = repmat(sprintf(' '),1,DisplayIndents);

TotalMemoryFormat = [IndentFormat, '??? Total System Memory: %.2f GB\n'];
UsedMemoryFormat = [IndentFormat, '??? MATLAB Process Memory Usage (RSS): %.2f GB PID: %s\n'];
fprintf(TotalMemoryFormat, totalMemoryGB);
fprintf(UsedMemoryFormat, thisused_GB,ppid);

end

